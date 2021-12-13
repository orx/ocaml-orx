open Common
open Direct_bindings

include Orx_gen.Clock

let () =
  if
    Clock_info.assumed_clock_modifier_number
    <> Unsigned.Size_t.to_int Clock_info.clock_modifier_number
  then
    Fmt.failwith
      "orxCLOCK_MODIFIER_NUMBER is %d but the OCaml bindings expect it to be \
       %d - fix and recompile the bindings"
      (Unsigned.Size_t.to_int Clock_info.clock_modifier_number)
      Clock_info.assumed_clock_modifier_number

let callback = Ctypes.(Info.t @-> ptr void @-> returning void)

module Clock_callback = (val Foreign.dynamic_funptr callback)
module Clock_callback_store = Ptr_store.Make (Clock_callback)
module Clock_timer_callback_store = Ptr_store.Make (Clock_callback)

let c_register =
  Ctypes.(
    Foreign.foreign "orxClock_Register"
      (t
      @-> Clock_callback.t
      @-> ptr void
      @-> Orx_types.Module_id.t
      @-> Orx_types.Clock_priority.t
      @-> returning Orx_gen.Status.t
      )
  )

let register
    ?(handle = Clock_callback_store.default_handle)
    ?(module_id = Module_id.Main)
    ?(priority = Clock_priority.Normal)
    (clock : t)
    callback =
  let callback_wrapper info _ctx =
    match callback info with
    | () -> ()
    | exception exn ->
      Log.log "Unhandled exception in clock callback for clock %s: %a"
        (get_name clock) Fmt.exn_backtrace
        (exn, Printexc.get_raw_backtrace ());
      raise exn
  in
  let callback_ptr = Clock_callback.of_fun callback_wrapper in
  match c_register clock callback_ptr Ctypes.null module_id priority with
  | Ok () -> Clock_callback_store.retain handle callback_ptr
  | Error `Orx ->
    Clock_callback.free callback_ptr;
    fail "Failed to set clock callback"

let unregister_ptr =
  Ctypes.(
    Foreign.foreign "orxClock_Unregister"
      (t @-> Clock_callback.t @-> returning Status.t)
  )

let unregister clock handle =
  Clock_callback_store.release handle (fun ptr -> unregister_ptr clock ptr)

let unregister_all clock =
  Clock_callback_store.release_all (fun ptr -> unregister_ptr clock ptr)

module Callback_handle = struct
  type t = Clock_callback_store.handle
  let default = Clock_callback_store.default_handle
  let make = Clock_callback_store.make_handle
end

let get_exn name =
  match get name with
  | Some clock -> clock
  | None -> Fmt.invalid_arg "Unable to get %s clock" name

let get_core () = get_exn "core"

let create tick_size =
  match create tick_size with
  | Some clock -> clock
  | None -> failwith "Unable to allocate clock"

let create_from_config_exn = create_exn create_from_config "clock"

let all_timers_delay = -1.0

let c_add_timer =
  Ctypes.(
    Foreign.foreign "orxClock_AddTimer"
      (t
      @-> Clock_callback.t
      @-> float
      @-> int32_t
      @-> ptr void
      @-> returning Status.t
      )
  )

let add_timer
    ?(handle = Clock_timer_callback_store.default_handle)
    clock
    callback
    delay
    repetition =
  if delay <= 0.0 then
    Fmt.invalid_arg "Orx.Clock.add_timer: delay must be > 0.0, is %g" delay;
  let callback_wrapper info _ctx =
    match callback info with
    | () -> ()
    | exception exn ->
      Log.log "Unhandled exception in clock timer callback for clock %s: %a"
        (get_name clock) Fmt.exn_backtrace
        (exn, Printexc.get_raw_backtrace ());
      raise exn
  in
  let callback_ptr = Clock_callback.of_fun callback_wrapper in
  match
    c_add_timer clock callback_ptr delay (Int32.of_int repetition) Ctypes.null
  with
  | Ok () ->
    Clock_timer_callback_store.retain handle callback_ptr;
    Ok ()
  | Error _ as e ->
    Clock_callback.free callback_ptr;
    e

let add_timer ?handle clock callback delay repetition =
  match add_timer ?handle clock callback delay repetition with
  | Ok () -> ()
  | Error `Orx -> Fmt.failwith "Failed to add timer to clock %s" (get_name clock)

let c_remove_timer =
  Ctypes.(
    Foreign.foreign "orxClock_RemoveTimer"
      (t @-> Clock_callback.t_opt @-> float @-> ptr void @-> returning Status.t)
  )

let remove_timer_ptr clock callback_ptr =
  let delay = all_timers_delay in
  c_remove_timer clock callback_ptr delay Ctypes.null

let remove_timer clock handle =
  Clock_timer_callback_store.release handle (fun ptr ->
      remove_timer_ptr clock (Some ptr)
  )

let remove_all_timers clock =
  Clock_timer_callback_store.release_all (fun ptr ->
      remove_timer_ptr clock (Some ptr)
  )

module Timer_handle = struct
  type t = Clock_timer_callback_store.handle
  let default = Clock_timer_callback_store.default_handle
  let make = Clock_timer_callback_store.make_handle
end
