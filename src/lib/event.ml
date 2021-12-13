open Common
open Direct_bindings

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

let make_flags
    (type event payload)
    (event_type : (event, payload) Event_type.t)
    (event_ids : event list) : event_flag =
  match event_type with
  | Anim -> to_flags event_ids Orx_types.Anim_event.map_to_constant
  | Fx -> to_flags event_ids Orx_types.Fx_event.map_to_constant
  | Input -> to_flags event_ids Orx_types.Input_event.map_to_constant
  | Object -> to_flags event_ids Orx_types.Object_event.map_to_constant
  | Physics -> to_flags event_ids Orx_types.Physics_event.map_to_constant
  | Shader -> to_flags event_ids Orx_types.Shader_event.map_to_constant
  | Sound -> to_flags event_ids Orx_types.Sound_event.map_to_constant
  | Time_line -> to_flags event_ids Orx_types.Time_line_event.map_to_constant

let all_events (type event payload) (event_type : (event, payload) Event_type.t)
    : event list =
  let firsts l = List.map fst l in
  match event_type with
  | Anim -> firsts Orx_types.Anim_event.map_to_constant
  | Fx -> firsts Orx_types.Fx_event.map_to_constant
  | Input -> firsts Orx_types.Input_event.map_to_constant
  | Object -> firsts Orx_types.Object_event.map_to_constant
  | Physics -> firsts Orx_types.Physics_event.map_to_constant
  | Shader -> firsts Orx_types.Shader_event.map_to_constant
  | Sound -> firsts Orx_types.Sound_event.map_to_constant
  | Time_line -> firsts Orx_types.Time_line_event.map_to_constant

let get_sender_object (event : t) : Object.t option =
  Object.of_void_pointer (Ctypes.getf !@event Orx_types.Event.sender)

let get_sender_structure (event : t) : Structure.t option =
  Structure.of_void_pointer (Ctypes.getf !@event Orx_types.Event.sender)

let get_recipient_object (event : t) : Object.t option =
  Object.of_void_pointer (Ctypes.getf !@event Orx_types.Event.recipient)

let get_recipient_structure (event : t) : Structure.t option =
  Structure.of_void_pointer (Ctypes.getf !@event Orx_types.Event.recipient)

let event_handler = Ctypes.(t @-> returning Orx_gen.Status.t)

module Event_handler = (val Foreign.dynamic_funptr event_handler)
module Event_handler_store = Ptr_store.Make (Event_handler)

let c_add_handler =
  Ctypes.(
    Foreign.foreign "ml_orx_event_add_handler"
      (Orx_types.Event_type.t
      @-> Event_handler.t
      @-> uint32_t
      @-> uint32_t
      @-> returning Orx_gen.Status.t
      )
  )

let add_handler :
    type e p.
    ?handle:Event_handler_store.handle ->
    ?events:e list ->
    (e, p) Event_type.t ->
    (t -> e -> p -> Status.t) ->
    unit =
 fun ?(handle = Event_handler_store.default_handle) ?events event_type callback ->
  let callback event =
    let f =
      match event_type with
      | Anim ->
        fun () -> callback event (to_event event Anim) (to_payload event Anim)
      | Fx -> fun () -> callback event (to_event event Fx) (to_payload event Fx)
      | Input ->
        fun () -> callback event (to_event event Input) (to_payload event Input)
      | Object ->
        fun () ->
          callback event (to_event event Object) (to_payload event Object)
      | Physics ->
        fun () ->
          callback event (to_event event Physics) (to_payload event Physics)
      | Shader ->
        fun () ->
          callback event (to_event event Shader) (to_payload event Shader)
      | Sound ->
        fun () -> callback event (to_event event Sound) (to_payload event Sound)
      | Time_line ->
        fun () ->
          callback event (to_event event Time_line) (to_payload event Time_line)
    in
    match f () with
    | result -> result
    | exception exn ->
      Log.log "Unhandled exception in event callback: %a" Fmt.exn_backtrace
        (exn, Printexc.get_raw_backtrace ());
      raise exn
  in
  let callback_ptr = Event_handler.of_fun callback in
  let add_flags =
    match (event_type, events) with
    | ((Sound as et), None) -> make_flags et [ Start; Stop; Add; Remove ]
    | (et, Some es) -> make_flags et es
    | (et, None) -> make_flags et (all_events et)
  in
  let remove_flags = Unsigned.UInt32.max_int in
  let result =
    c_add_handler
      (Event_type.to_c_any event_type)
      callback_ptr add_flags remove_flags
  in
  match result with
  | Ok () -> Event_handler_store.retain handle callback_ptr
  | Error `Orx ->
    Event_handler.free callback_ptr;
    fail "Failed to set event callback"

let c_remove_handler =
  Ctypes.(
    Foreign.foreign "orxEvent_RemoveHandler"
      (Orx_types.Event_type.t @-> Event_handler.t @-> returning Status.t)
  )

let remove_handler_ptr event_type callback_ptr =
  c_remove_handler (Event_type.to_c_any event_type) callback_ptr

let remove_handler event_type handle =
  Event_handler_store.release handle (fun ptr ->
      remove_handler_ptr event_type ptr
  )
let remove_all_handlers event_type =
  Event_handler_store.release_all (fun ptr -> remove_handler_ptr event_type ptr)

module Handle = struct
  type t = Event_handler_store.handle
  let default = Event_handler_store.default_handle
  let make = Event_handler_store.make_handle
end
