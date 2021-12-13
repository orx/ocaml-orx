open Common
include Orx_gen.Texture

let get_size texture =
  let width = Ctypes.allocate_n Ctypes.float ~count:1 in
  let height = Ctypes.allocate_n Ctypes.float ~count:1 in
  match get_size texture width height with
  | Error `Orx -> Fmt.invalid_arg "Unable to retrieve texture size"
  | Ok () -> (!@width, !@height)
