open Common
open Direct_bindings

include Orx_gen.Input

let get_binding (name : string) (index : int) =
  let type_ = Ctypes.allocate_n Orx_types.Input_type.t ~count:1 in
  let id = Ctypes.allocate_n Ctypes.int ~count:1 in
  let mode = Ctypes.allocate_n Orx_types.Input_mode.t ~count:1 in
  match get_binding name index type_ id mode with
  | Error _ as e -> Status.open_error e
  | Ok () -> Ok (!@type_, !@id, !@mode)
