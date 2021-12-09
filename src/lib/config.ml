open Common
open Direct_bindings

let wrap_get_vector = Vector.get_vector
include Orx_gen.Config

let load_from_memory s = load_from_memory s (String.length s)

let bootstrap_function = Ctypes.(void @-> returning Orx_gen.Status.t)

module Bootstrap_function = (val Foreign.dynamic_funptr bootstrap_function)
module Bootstrap_function_store = Ptr_store.Make (Bootstrap_function)

let c_set_bootstrap =
  Ctypes.(
    Foreign.foreign "orxConfig_SetBootstrap"
      (Bootstrap_function.t @-> returning Orx_gen.Status.t)
  )

let set_bootstrap f =
  let f_ptr = Bootstrap_function.of_fun f in
  match c_set_bootstrap f_ptr with
  | Ok () ->
    Bootstrap_function_store.retain Bootstrap_function_store.default_handle
      f_ptr;
    Ok ()
  | Error _ as e ->
    Bootstrap_function.free f_ptr;
    e

let set_bootstrap f =
  match set_bootstrap f with
  | Ok () -> ()
  | Error `Orx -> fail "Unable to set config bootstrap function"

let free_bootstrap () = Bootstrap_function_store.release_all (fun _ptr -> Ok ())

let set_list_string (key : string) (values : string list) =
  let length = List.length values in
  let c_values = Ctypes.CArray.of_list Ctypes.string values in
  set_list_string key (Ctypes.CArray.start c_values) length

let append_list_string (key : string) (values : string list) =
  let length = List.length values in
  let c_values = Ctypes.CArray.of_list Ctypes.string values in
  append_list_string key (Ctypes.CArray.start c_values) length

let get_vector (key : string) : Vector.t = wrap_get_vector get_vector key

let get_list_vector (key : string) (i : int option) : Vector.t =
  wrap_get_vector (fun k v -> get_list_vector k i v) key

let if_has_value (key : string) (getter : string -> 'a) : 'a option =
  if has_value key then
    Some (getter key)
  else
    None

let with_section (section : string) f =
  push_section section;
  Fun.protect ~finally:pop_section f

let exists ~section ~key =
  has_section section && with_section section (fun () -> has_value key)

let get (get : string -> 'a) ~(section : string) ~(key : string) : 'a =
  with_section section (fun () -> get key)

let set (set : string -> 'a -> unit) (v : 'a) ~(section : string) ~(key : string)
    : unit =
  with_section section (fun () -> set key v)

let get_seq (getter : string -> 'a) ~section ~key : 'a Seq.t =
  if exists ~section ~key then (
    let rec next () = Seq.Cons (get getter ~section ~key, next) in
    next
  ) else
    Seq.empty

let get_list_item
    (get : string -> int option -> 'a)
    (i : int option)
    ~(section : string)
    ~(key : string) : 'a =
  with_section section (fun () -> get key i)

let get_list
    (get : string -> int option -> 'a)
    ~(section : string)
    ~(key : string) : 'a list =
  let get_all () =
    let count = get_list_count key in
    List.init count (fun i -> get key (Some i))
  in
  with_section section get_all

(* Helpers to get all the sections, or all the keys in a section *)
let get_sections () : string list =
  let count = get_section_count () in
  List.init count (fun i -> get_section i)

let get_current_section_keys () : string list =
  let count = get_key_count () in
  List.init count (fun i -> get_key i)

let get_section_keys (section : string) =
  with_section section get_current_section_keys

module Value = struct
  type _ t =
    | String : string t
    | Int : int t
    | Float : float t
    | Bool : bool t
    | Vector : Vector.t t
    | Guid : Structure.Guid.t t

  let to_proper_string (type v) (typ : v t) : string =
    match typ with
    | String -> "String"
    | Int -> "Int"
    | Float -> "Float"
    | Bool -> "Bool"
    | Vector -> "Vector"
    | Guid -> "GUID"

  let to_string typ = String.lowercase_ascii (to_proper_string typ)

  let getter (type v) (typ : v t) : string -> v =
    match typ with
    | String -> get_string
    | Int -> get_int
    | Float -> get_float
    | Bool -> get_bool
    | Vector -> get_vector
    | Guid -> get_guid

  let setter (type v) (typ : v t) : string -> v -> unit =
    match typ with
    | String -> set_string
    | Int -> set_int
    | Float -> set_float
    | Bool -> set_bool
    | Vector -> set_vector
    | Guid -> set_guid

  let get (type v) (typ : v t) ~section ~key : v =
    get (getter typ) ~section ~key

  let find typ ~section ~key =
    if has_section section then
      with_section section (fun () ->
          if has_value key then
            Some ((getter typ) key)
          else
            None
      )
    else
      None

  let set (type v) (typ : v t) (x : v) ~section ~key : unit =
    set (setter typ) x ~section ~key

  let clear ~section ~key : unit =
    with_section section (fun () -> clear_value key |> Status.ignore)

  let update (type v) (typ : v t) (f : v option -> v option) ~section ~key :
      unit =
    with_section section (fun () ->
        let set = setter typ in
        let get = getter typ in
        let current =
          if has_value key then
            Some (get key)
          else
            None
        in
        match f current with
        | None -> clear_value key |> Status.ignore
        | Some updated -> set key updated
    )
end
