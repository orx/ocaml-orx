open Common
open Direct_bindings

include Orx_gen.Camera

let set_parent camera parent = Parent.set set_parent camera parent

let get_parent camera =
  match get_parent camera with
  | None -> None
  | Some s -> Parent.of_void_pointer (Structure.to_void_pointer s)

let get_position = Vector.get_vector get_position

let create_from_config_exn = create_exn create_from_config "camera"

let set_frustum camera ~width ~height ~near ~far =
  set_frustum camera width height near far
