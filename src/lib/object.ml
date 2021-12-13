open Common
open Direct_bindings

include Orx_gen.Object

type 'a associated_structure =
  | Body : Body.t associated_structure
  | Graphic : Graphic.t associated_structure
  | Sound : Sound.t associated_structure

let get_structure (type s) (o : t) (s : s associated_structure) : s option =
  let ( let* ) = Option.bind in
  match s with
  | Body ->
    let* structure = get_structure o Body in
    Body.of_void_pointer (Structure.to_void_pointer structure)
  | Graphic ->
    let* structure = get_structure o Graphic in
    Graphic.of_void_pointer (Structure.to_void_pointer structure)
  | Sound ->
    let* structure = get_structure o Sound in
    Sound.of_void_pointer (Structure.to_void_pointer structure)

let set_parent o parent =
  match Parent.set set_parent o parent with
  | Ok () -> ()
  | Error `Orx -> fail "Failed to set parent"

let set_owner o owner = Parent.set set_owner o owner

let get_repeat o =
  let x = Ctypes.allocate_n Ctypes.float ~count:1 in
  let y = Ctypes.allocate_n Ctypes.float ~count:1 in
  get_repeat o x y;
  (!@x, !@y)

type collision = {
  colliding_object : t;
  contact : Vector.t;
  normal : Vector.t;
}

let get_bounding_box = Obox.get_obox_exn get_bounding_box

let get_world_position = Vector.get_vector_exn get_world_position

let get_position = Vector.get_vector_exn get_position

let get_scale = Vector.get_vector_exn get_scale

let get_speed = Vector.get_vector_exn get_speed

let get_relative_speed = Vector.get_vector_exn get_relative_speed

let get_custom_gravity = Vector.get_optional_vector get_custom_gravity

let get_mass_center o =
  match Vector.get_optional_vector get_mass_center o with
  | Some v -> v
  | None -> invalid_arg Status.body_error_message

let apply_force ?location o f = apply_force o f location
let apply_impulse ?location o f = apply_impulse o f location

let raycast
    ?(self_flags = 0xffff)
    ?(check_mask = 0xffff)
    ?(early_exit = false)
    (v0 : Vector.t)
    (v1 : Vector.t) : collision option =
  let contact = Vector.allocate_raw () in
  let normal = Vector.allocate_raw () in
  let collision =
    raycast v0 v1
      (Unsigned.UInt16.of_int self_flags)
      (Unsigned.UInt16.of_int check_mask)
      early_exit (Some contact) (Some normal)
  in
  match collision with
  | None -> None
  | Some o -> Some { colliding_object = o; contact; normal }

type group =
  | All_groups
  | Group of string
  | Group_id of String_id.t

let group_id group =
  match group with
  | All_groups -> String_id.undefined
  | Group name -> String_id.get_id name
  | Group_id id -> id

let get_neighbor_list (box : Obox.t) group =
  match create_neighbor_list box (group_id group) with
  | None -> fail "Failed to allocate neighbor list"
  | Some bank ->
    let ptrs = Bank.to_list bank in
    let objects =
      List.map
        (fun p ->
          let ptr_ptr_void = Ctypes.from_voidp (Ctypes.ptr Ctypes.void) p in
          of_void_pointer !@ptr_ptr_void |> Option.get
        )
        ptrs
    in
    delete_neighbor_list bank;
    objects

let pick v group = pick v (group_id group)

let box_pick obox group = box_pick obox (group_id group)

let set_group_id o group =
  match set_group_id o (group_id group) with
  | Ok () -> ()
  | Error `Orx -> fail "Failed to set group id"

let set_group_id_recursive o group = set_group_id_recursive o (group_id group)

let get_seq get_f =
  let rec iter last () : _ Seq.node =
    match get_f last with
    | None -> Nil
    | Some v as this -> Cons (v, iter this)
  in
  iter None

let get_group (group : group) : t Seq.t =
  let group_id = group_id group in
  get_seq (fun o -> get_next o group_id)

let get_enabled (group : group) : t Seq.t =
  let group_id = group_id group in
  get_seq (fun o -> get_next o group_id)

let of_structure (s : Structure.t) : t option =
  of_void_pointer (Structure.to_void_pointer s)

let get_owner (o : t) : Parent.t option =
  match get_owner o with
  | None -> None
  | Some s -> Parent.of_void_pointer (Structure.to_void_pointer s)

let get_parent (o : t) : Parent.t option =
  match get_parent o with
  | None -> None
  | Some s -> Parent.of_void_pointer (Structure.to_void_pointer s)

type _ child =
  | Child_object : t child
  | Owned_object : t child
  | Child_camera : camera child

let get_camera_children (o : t) : Camera.t Seq.t =
  get_seq (fun c ->
      let c = Option.map Camera.to_void_pointer c in
      let s = get_next_child o c Camera in
      let p = Option.map Structure.to_void_pointer s in
      Option.map Camera.of_void_pointer p |> Option.join
  )

let get_object_children (o : t) : t Seq.t =
  get_seq (fun c ->
      let c = Option.map to_void_pointer c in
      let s = get_next_child o c Object in
      let p = Option.map Structure.to_void_pointer s in
      Option.map of_void_pointer p |> Option.join
  )

let get_owned_children (o : t) : t Seq.t =
  let rec iter sibling () : _ Seq.node =
    match get_owned_sibling sibling with
    | None -> Nil
    | Some next -> Cons (next, iter next)
  in
  match get_owned_child o with
  | None -> Seq.empty
  | Some first -> fun () -> Cons (first, iter first)

let get_children (type c) (o : t) (child : c child) : c Seq.t =
  match child with
  | Child_object -> get_object_children o
  | Owned_object -> get_owned_children o
  | Child_camera -> get_camera_children o

let get_first_child (type c) (o : t) (child : c child) : c option =
  match child with
  | Child_object -> get_child o
  | Owned_object -> get_owned_child o
  | Child_camera ->
    get_next_child o None Camera
    |> Option.map Structure.to_void_pointer
    |> Option.map Camera.of_void_pointer
    |> Option.join

let rec get_children_recursive o kind =
  let children = get_children o kind in
  Seq.flat_map
    (fun child -> Seq.cons child (get_children_recursive child kind))
    children

let iter_children_recursive f o kind = Seq.iter f (get_children_recursive o kind)

let iter_recursive f o kind =
  f o;
  iter_children_recursive f o kind

let to_guid (o : t) : Structure.Guid.t =
  match to_void_pointer o |> Structure.of_void_pointer with
  | Some s -> Structure.get_guid s
  | None -> assert false

let get_guid = to_guid

let of_guid (guid : Structure.Guid.t) : t option =
  let ( let* ) = Option.bind in
  let* s = Structure.get guid in
  of_void_pointer (Ctypes.to_voidp s)

(* Exception-raising variants of functions which use config names *)

let create_from_config_exn = create_exn create_from_config "object"

let add_fx_exn_wrapper add o name =
  add o name |> Status.raise "Unable to add FX %s" name
let add_fx_exn = add_fx_exn_wrapper add_fx
let add_unique_fx_exn = add_fx_exn_wrapper add_unique_fx
let remove_fx_exn o name =
  remove_fx o name |> Status.raise "Unable to remove FX %s" name
let remove_all_fxs_exn o =
  remove_all_fxs o
  |> Status.raise "Unable to remove all FXs from %s" (get_name o)
let remove_all_fxs_recursive_exn o =
  remove_all_fxs_recursive o
  |> Status.raise "Unable to recursively remove all FXs from %s" (get_name o)

let add_shader_exn o name =
  add_shader o name |> Status.raise "Unable to add shader %s" name
let remove_shader_exn o name =
  remove_shader o name |> Status.raise "Unable to remove shader %s" name

let add_time_line_track_exn o name =
  add_time_line_track o name
  |> Status.raise "Unable to add time line track %s" name
let remove_time_line_track_exn o name =
  remove_time_line_track o name
  |> Status.raise "Unable to remove time line track %s" name

let set_target_anim_exn o name =
  set_target_anim o name
  |> Status.raise "Unable to set target animation %s" name

let set_current_anim_exn o name =
  set_current_anim o name
  |> Status.raise "Unable to set target animation %s" name

let add_sound_exn o name =
  add_sound o name |> Status.raise "Unable to add sound %s" name
let remove_sound_exn o name =
  remove_sound o name |> Status.raise "Unable to remove sound %s" name

let of_guid_exn guid =
  match of_guid guid with
  | Some o -> o
  | None ->
    Fmt.invalid_arg "Unable to find object with GUID %a" Structure.Guid.pp guid
