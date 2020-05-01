let ( !@ ) = Ctypes.( !@ )

module Orx_gen = Orx_bindings.Bindings (Generated)
module Color = Orx_gen.Color
module Display = Orx_gen.Display
module Fx_event_details = Orx_gen.Fx_event_details
module Input_event_details = Orx_gen.Input_event_details
module Sound_event_details = Orx_gen.Sound_event_details
module Resource = Orx_gen.Resource
module Sound = Orx_gen.Sound
module String_id = Orx_gen.String_id
module Structure = Orx_gen.Structure
module Viewport = Orx_gen.Viewport
module Status = Orx_gen.Status
module Clock_modifier = Orx_types.Clock_modifier
module Clock_priority = Orx_types.Clock_priority
module Clock_info = Orx_types.Clock_info
module Clock_type = Orx_types.Clock_type
module Module_id = Orx_types.Module_id
module Event_type = Orx_types.Event_type
module Config_event = Orx_types.Config_event
module Fx_event = Orx_types.Fx_event
module Input_event = Orx_types.Input_event
module Object_event = Orx_types.Object_event
module Physics_event = Orx_types.Physics_event
module Sound_event = Orx_types.Sound_event
module Input_mode = Orx_types.Input_mode
module Input_type = Orx_types.Input_type
module Mouse_axis = Orx_types.Mouse_axis
module Mouse_button = Orx_types.Mouse_button
module Sound_status = Orx_types.Sound_status

module Texture = struct
  include Orx_gen.Texture

  let get_size texture =
    let width = Ctypes.allocate_n Ctypes.float ~count:1 in
    let height = Ctypes.allocate_n Ctypes.float ~count:1 in
    match get_size texture width height with
    | Error `Orx -> None
    | Ok () -> Some (!@width, !@height)
end

module Bank = struct
  include Orx_gen.Bank

  let rec to_list
      (b : t)
      (cell : unit Ctypes.ptr option)
      (ptrs : unit Ctypes.ptr list) =
    match get_next b cell with
    | None -> List.rev ptrs
    | Some ptr as next_cell -> to_list b next_cell (ptr :: ptrs)

  let to_list (b : t) : unit Ctypes.ptr list = to_list b None []
end

module Vector = struct
  include Orx_gen.Vector

  let get_x (v : t) : float = Ctypes.getf !@v Orx_types.Vector.x

  let get_y (v : t) : float = Ctypes.getf !@v Orx_types.Vector.y

  let get_z (v : t) : float = Ctypes.getf !@v Orx_types.Vector.z

  let make ~x ~y ~z : t =
    let v = allocate_raw () in
    let (_ : t) = set v x y z in
    v

  let set_x (v : t) (x : float) : unit = Ctypes.setf !@v Orx_types.Vector.x x

  let set_y (v : t) (y : float) : unit = Ctypes.setf !@v Orx_types.Vector.y y

  let set_z (v : t) (z : float) : unit = Ctypes.setf !@v Orx_types.Vector.z z

  let make_one_vec_op op =
    let f' ~(target : t) (v : t) : unit =
      let (_ : t) = op target v in
      ()
    in
    let f (v : t) : t =
      let target : t = allocate_raw () in
      f' ~target v;
      target
    in
    (f', f)

  let (copy', copy) = make_one_vec_op copy

  let (normalize', normalize) = make_one_vec_op normalize

  let (reciprocal', reciprocal) = make_one_vec_op reciprocal

  let (round', round) = make_one_vec_op round

  let (floor', floor) = make_one_vec_op floor

  let (neg', neg) = make_one_vec_op neg

  let make_two_vec_op op =
    let f' ~(target : t) (v1 : t) (v2 : t) : unit =
      let (_ : t) = op target v1 v2 in
      ()
    in
    let f (v1 : t) (v2 : t) : t =
      let target : t = allocate_raw () in
      f' ~target v1 v2;
      target
    in
    (f', f)

  let (add', add) = make_two_vec_op add

  let (sub', sub) = make_two_vec_op sub

  let (mul', mul) = make_two_vec_op mul

  let (div', div) = make_two_vec_op div

  let (cross', cross) = make_two_vec_op cross

  let make_one_vec_one_float_op op =
    let f' ~(target : t) (v : t) (x : float) : unit =
      let (_ : t) = op target v x in
      ()
    in

    let f (v : t) (x : float) : t =
      let target : t = allocate_raw () in
      f' ~target v x;
      target
    in
    (f', f)

  let (mulf', mulf) = make_one_vec_one_float_op mulf

  let (divf', divf) = make_one_vec_one_float_op divf

  let (rotate_2d', rotate_2d) = make_one_vec_one_float_op rotate_2d

  let make_two_vec_one_float_op op =
    let f' ~(target : t) (v1 : t) (v2 : t) (x : float) : unit =
      let (_ : t) = op target v1 v2 x in
      ()
    in

    let f (v1 : t) (v2 : t) (x : float) : t =
      let target : t = allocate_raw () in
      f' ~target v1 v2 x;
      target
    in
    (f', f)

  let (lerp', lerp) = make_two_vec_one_float_op lerp

  let move_x (v : t) (delta : float) : unit = set_x v (get_x v +. delta)

  let move_y (v : t) (delta : float) : unit = set_y v (get_y v +. delta)

  let move_z (v : t) (delta : float) : unit = set_z v (get_z v +. delta)
end

module Obox = struct
  include Orx_gen.Obox

  let make ~pos ~pivot ~size angle : t =
    let ob = allocate_raw () in
    let (_ : t) = set_2d ob pos pivot size angle in
    ob

  let copy (ob : t) =
    let copied : t = allocate_raw () in
    let (_ : t) = copy copied ob in
    copied

  let get_center (ob : t) : Vector.t =
    let center = Vector.allocate_raw () in
    let (_ : Vector.t) = get_center ob center in
    center

  let move (ob : t) (v : Vector.t) : t =
    let moved : t = allocate_raw () in
    let (_ : t) = move moved ob v in
    moved

  let rotate_2d (ob : t) angle : t =
    let rotated : t = allocate_raw () in
    let (_ : t) = rotate_2d rotated ob angle in
    rotated
end

(* Wrapper for functions which return a vector property. *)
(* Orx uses the return value to indicate if the get was a success or not. *)
let get_optional_vector get o =
  let v = Vector.allocate_raw () in
  match get o v with
  | None -> None
  | Some _v -> Some v

let get_vector get o =
  let v = Vector.allocate_raw () in
  let (_ : Vector.t) = get o v in
  v

(* Wrapper for functions which return a obox property. *)
(* Orx uses the return value to indicate if the get was a success or not. *)
let get_optional_obox get o =
  let v = Obox.allocate_raw () in
  match get o v with
  | None -> None
  | Some _v -> Some v

module Render = struct
  include Orx_gen.Render

  let get_world_position vector viewport =
    get_optional_vector (fun () v -> get_world_position vector viewport v) ()
end

module Mouse = struct
  include Orx_gen.Mouse

  let get_position = get_optional_vector (fun () v -> get_position v)

  let get_move_delta = get_optional_vector (fun () v -> get_move_delta v)
end

module Graphic = struct
  include Orx_gen.Graphic

  let get_size = get_vector get_size

  let get_origin = get_vector get_origin

  let to_structure (g : t) : Structure.t =
    let g' = Ctypes.to_voidp g in
    Structure.of_any g'
end

module Camera = struct
  include Orx_gen.Camera

  type parent = unit Ctypes.ptr

  let get_position = get_vector get_position
end

module Input = struct
  include Orx_gen.Input

  let get_binding (name : string) (index : int) =
    let type_ = Ctypes.allocate_n Orx_types.Input_type.t ~count:1 in
    let id = Ctypes.allocate_n Ctypes.int ~count:1 in
    let mode = Ctypes.allocate_n Orx_types.Input_mode.t ~count:1 in
    match get_binding name index type_ id mode with
    | Error _ as e -> Status.open_error e
    | Ok () -> Ok (!@type_, !@id, !@mode)
end

module Physics = struct
  include Orx_gen.Physics

  let get_gravity = get_optional_vector (fun () v -> get_gravity v)
end

module Object = struct
  include Orx_gen.Object

  type collision = {
    colliding_object : t;
    contact : Vector.t;
    normal : Vector.t;
  }

  let get_bounding_box = get_optional_obox get_bounding_box

  let get_world_position = get_optional_vector get_world_position

  let get_position = get_optional_vector get_position

  let get_scale = get_optional_vector get_scale

  let get_speed = get_optional_vector get_speed

  let get_relative_speed = get_optional_vector get_relative_speed

  let get_custom_gravity = get_optional_vector get_custom_gravity

  let get_mass_center = get_optional_vector get_mass_center

  let raycast
      ?(self_flags = 0xffff)
      ?(check_mask = 0xffff)
      ?(early_exit = false)
      ~(v0 : Vector.t)
      ~(v1 : Vector.t) : collision option =
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

  let add_fx ?(delay : float option) ~(unique : bool) (o : t) (fx : string) =
    match delay with
    | None ->
      if unique then
        add_unique_fx o fx
      else
        add_fx o fx
    | Some time ->
      if unique then
        add_unique_delayed_fx o fx time
      else
        add_delayed_fx o fx time

  let get_neighbor_list (box : Obox.t) (group_id : String_id.t) =
    match create_neighbor_list box group_id with
    | None -> None
    | Some bank ->
      let ptrs = Bank.to_list bank in
      let objects = List.map of_void_pointer ptrs in
      delete_neighbor_list bank;
      Some objects

  let get_list (group_id : String_id.t) =
    let rec loop (o : t option) (accu : t list) =
      match get_next o group_id with
      | None -> List.rev accu
      | Some next as o_next -> loop o_next (next :: accu)
    in
    loop None []

  let to_camera_parent = to_void_pointer
end

module Event = struct
  include Orx_gen.Event

  type event_flag = Unsigned.UInt32.t

  let to_flag (event_id : 'a) (map_to_constant : ('a * int64) list) =
    match List.assoc_opt event_id map_to_constant with
    | None -> Fmt.invalid_arg "Unhandled event id when looking up flag"
    | Some event -> get_flag (Unsigned.UInt32.of_int64 event)

  let to_flags (event_ids : 'a list) (map_to_constant : ('a * int64) list) =
    let flags =
      List.map (fun event_id -> to_flag event_id map_to_constant) event_ids
    in
    List.fold_left
      (fun flag id -> Unsigned.UInt32.logor flag id)
      Unsigned.UInt32.zero flags

  let make_flags (type a) (event_type : a event) (event_ids : a list) :
      event_flag =
    match event_type with
    | Config -> to_flags event_ids Orx_types.Config_event.map_to_constant
    | Fx -> to_flags event_ids Orx_types.Fx_event.map_to_constant
    | Input -> to_flags event_ids Orx_types.Input_event.map_to_constant
    | Object -> to_flags event_ids Orx_types.Object_event.map_to_constant
    | Physics -> to_flags event_ids Orx_types.Physics_event.map_to_constant
    | Sound -> to_flags event_ids Orx_types.Sound_event.map_to_constant

  let get_sender_object (event : t) : Object.t =
    Object.of_void_pointer (Ctypes.getf !@event Orx_types.Event.sender)

  let get_recipient_object (event : t) : Object.t =
    Object.of_void_pointer (Ctypes.getf !@event Orx_types.Event.recipient)

  let event_handler = Ctypes.(t @-> returning Orx_gen.Status.t)

  let c_add_handler =
    Ctypes.(
      Foreign.foreign ~release_runtime_lock:false "ml_orx_event_add_handler"
        (Orx_types.Event_type.t
        @-> Foreign.funptr ~runtime_lock:false event_handler
        @-> uint32_t
        @-> uint32_t
        @-> returning Orx_gen.Status.t
        ))

  (* Hold onto callbacks so they're not collected *)
  let registered_callbacks : (t -> Orx_gen.Status.t) list ref = ref []

  let add_handler (event_type : Orx_types.Event_type.t) callback =
    let callback event =
      match callback event with
      | result -> result
      | exception exn ->
        Fmt.epr "Unhandled exception in event callback: %a@." Fmt.exn_backtrace
          (exn, Printexc.get_raw_backtrace ());
        raise exn
    in
    registered_callbacks := callback :: !registered_callbacks;
    let add_flags =
      match event_type with
      | Sound -> make_flags Sound [ Start; Stop; Add; Remove ]
      | _ -> Unsigned.UInt32.max_int
    in
    let remove_flags = Unsigned.UInt32.max_int in
    c_add_handler event_type callback add_flags remove_flags
end

module Clock = struct
  include Orx_gen.Clock

  let callback = Ctypes.(Info.t @-> ptr void @-> returning void)

  let c_register =
    Ctypes.(
      Foreign.foreign ~release_runtime_lock:false "orxClock_Register"
        (t
        @-> Foreign.funptr ~runtime_lock:false callback
        @-> ptr void
        @-> Orx_types.Module_id.t
        @-> Orx_types.Clock_priority.t
        @-> returning Orx_gen.Status.t
        ))

  (* Hold onto callbacks so they're not collected *)
  let registered_callbacks : (Info.t -> unit Ctypes.ptr -> unit) list ref =
    ref []

  let register (clock : t) callback module_ priority =
    let callback_wrapper info _ctx =
      match callback info with
      | () -> ()
      | exception exn ->
        Fmt.epr "Unhandled exception in clock callback: %a@." Fmt.exn_backtrace
          (exn, Printexc.get_raw_backtrace ());
        raise exn
    in
    registered_callbacks := callback_wrapper :: !registered_callbacks;
    c_register clock callback_wrapper Ctypes.null module_ priority
end

module Config = struct
  include Orx_gen.Config

  let bootstrap_function = Ctypes.(void @-> returning Orx_gen.Status.t)

  let set_bootstrap =
    Ctypes.(
      Foreign.foreign ~release_runtime_lock:false "orxConfig_SetBootstrap"
        (Foreign.funptr bootstrap_function @-> returning Orx_gen.Status.t))

  let set_list_string (key : string) (values : string list) =
    let length = List.length values in
    let c_values = Ctypes.CArray.of_list Ctypes.string values in
    set_list_string key (Ctypes.CArray.start c_values) length

  let append_list_string (key : string) (values : string list) =
    let length = List.length values in
    let c_values = Ctypes.CArray.of_list Ctypes.string values in
    append_list_string key (Ctypes.CArray.start c_values) length

  let get_vector (key : string) : Vector.t option =
    get_optional_vector get_vector key

  let get_list_vector (key : string) (i : int option) : Vector.t option =
    get_optional_vector (fun k v -> get_list_vector k i v) key

  let with_section (section : string) f =
    match push_section section with
    | Error _ as e -> Status.open_error e
    | Ok () ->
      let result = f () in
      ( match pop_section () with
      | Error _ as e -> Status.open_error e
      | Ok () -> Ok result
      )

  let get (get : string -> 'a) ~(section : string) ~(key : string) :
      ('a, 'err) result =
    with_section section (fun () -> get key)

  let get_list_item
      (get : string -> int option -> 'a)
      (i : int option)
      ~(section : string)
      ~(key : string) : ('a, 'error) result =
    with_section section (fun () -> get key i)

  let get_list
      (get : string -> int option -> 'a)
      ~(section : string)
      ~(key : string) : ('a list, [> `Orx ]) result =
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
end

module Orx_thread = struct
  let set_ocaml_callbacks =
    Ctypes.(
      Foreign.foreign ~release_runtime_lock:false "ml_orx_thread_set_callbacks"
        (void @-> returning void))
end

module Main = struct
  let init_function = Ctypes.(void @-> returning Orx_gen.Status.t)

  let run_function = Ctypes.(void @-> returning Orx_gen.Status.t)

  let exit_function = Ctypes.(void @-> returning void)

  (* This is wrapped differently because the underlying orx function is *)
  (* inlined in orx.h *)
  let execute_c =
    Ctypes.(
      Foreign.foreign ~release_runtime_lock:false "ml_orx_execute"
        (int
        @-> ptr string
        @-> Foreign.funptr ~runtime_lock:false init_function
        @-> Foreign.funptr ~runtime_lock:false run_function
        @-> Foreign.funptr ~runtime_lock:false exit_function
        @-> returning void
        ))

  let execute ~init ~run ~exit () =
    (* Start the orx main loop *)
    let empty_argv = Ctypes.from_voidp Ctypes.string Ctypes.null in
    execute_c 0 empty_argv (Sys.opaque_identity init) (Sys.opaque_identity run)
      (Sys.opaque_identity exit)
end
