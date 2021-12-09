open Common
open Direct_bindings

include Orx_gen.Command

module Var_type = struct
  type 'a t = 'a Config.Value.t

  let to_ctype (type s) (v : s t) : Orx_types.Command_var_type.t =
    match v with
    | String -> String
    | Float -> Float
    | Int -> Int
    | Bool -> Bool
    | Vector -> Vector
    | Guid -> Guid
end

module Var_def = struct
  include Orx_gen.Command_var_def

  let set_name (v : t) name =
    Ctypes.setf !@v Orx_types.Command_var_def.name name
  let set_type (v : t) type_ =
    Ctypes.setf !@v Orx_types.Command_var_def.type_ (Var_type.to_ctype type_)

  let make name type_ =
    let v : t = allocate_raw () in
    set_name v name;
    set_type v type_;
    v
end

module Var = struct
  include Orx_gen.Command_var

  let set (type s) (var : t) (var_type : s Var_type.t) (v : s) =
    set_type var (Var_type.to_ctype var_type);
    match var_type with
    | String -> set_string var v
    | Float -> set_float var v
    | Int -> set_int var v
    | Bool -> set_bool var v
    | Vector -> set_vector var !@v
    | Guid -> set_guid var v

  let make var_type v =
    let var = allocate_raw () in
    set var var_type v;
    var

  let get (type s) (var : t) (var_type : s Var_type.t) : s =
    (let actual_var_type = get_type var in
     let requested_var_type = Var_type.to_ctype var_type in
     let correct_type =
       Orx_types.Command_var_type.equal actual_var_type requested_var_type
     in
     if not correct_type then
       Log.log "Incorrect variable type when reading from command variable"
    );
    match var_type with
    | String -> get_string var
    | Float -> get_float var
    | Int -> get_int var |> Int64.to_int
    | Bool -> get_bool var
    | Vector ->
      let vec = get_vector var in
      Vector.make
        ~x:(Ctypes.getf vec Orx_types.Vector.x)
        ~y:(Ctypes.getf vec Orx_types.Vector.y)
        ~z:(Ctypes.getf vec Orx_types.Vector.z)
    | Guid -> get_guid var
end

let command_handler = Ctypes.(uint32_t @-> Var.t @-> Var.t @-> returning void)

module Command_handler = (val Foreign.dynamic_funptr command_handler)

let registered_command_handlers : (string, Command_handler.t) Hashtbl.t =
  Hashtbl.create 16

let free_registered_handler name =
  match Hashtbl.find_opt registered_command_handlers name with
  | None -> ()
  | Some old_ptr ->
    Hashtbl.remove registered_command_handlers name;
    Command_handler.free old_ptr

let c_register =
  Ctypes.(
    Foreign.foreign "orxCommand_Register"
      (string
      @-> Command_handler.t
      @-> int
      @-> int
      @-> Var_def.t
      @-> Var_def.t
      @-> returning Status.t
      )
  )

let register
    name
    (f : Var.t array -> Var.t -> unit)
    (required_param_defs, optional_param_defs)
    return_def =
  let f_wrapper n_args (c_args : Var.t) (c_return : Var.t) =
    let n_args = Unsigned.UInt32.to_int n_args in
    let c_arg_array = Ctypes.CArray.from_ptr c_args n_args in
    let args =
      Array.init n_args (fun i -> Ctypes.CArray.get c_arg_array i |> Ctypes.addr)
    in
    f args c_return
  in
  let param_defs = List.append required_param_defs optional_param_defs in
  let c_param_defs =
    List.map Ctypes.( !@ ) param_defs |> Var_def.of_list |> Ctypes.CArray.start
  in
  let f_ptr = Command_handler.of_fun f_wrapper in
  let result =
    c_register name f_ptr
      (List.length required_param_defs)
      (List.length optional_param_defs)
      c_param_defs return_def
  in
  match result with
  | Ok () ->
    free_registered_handler name;
    Hashtbl.add registered_command_handlers name f_ptr;
    Ok ()
  | Error _ as e ->
    Command_handler.free f_ptr;
    e

let register_exn name f param_defs return_def =
  match register name f param_defs return_def with
  | Ok () -> ()
  | Error `Orx -> Fmt.invalid_arg "Unable to register command %s" name

let unregister name =
  match unregister name with
  | Ok _ as o ->
    free_registered_handler name;
    o
  | Error _ as e -> e

let unregister_exn name =
  match unregister name with
  | Ok () -> ()
  | Error `Orx -> Fmt.invalid_arg "Unable to unregister command %s" name

let unregister_all () =
  Hashtbl.iter
    (fun name _ptr -> unregister_exn name)
    registered_command_handlers

let evaluate command =
  let return = Var.allocate_raw () in
  let result : Var.t = evaluate command return in
  if Ctypes.is_null result then
    None
  else
    Some return

let evaluate_with_guid command guid =
  let return = Var.allocate_raw () in
  let result : Var.t = evaluate_with_guid command guid return in
  if Ctypes.is_null result then
    None
  else
    Some return
