let ( !@ ) = Ctypes.( !@ )

let fail fmt = Fmt.kstr failwith ("Orx: " ^^ fmt)

let create_exn create_from_config what name =
  match create_from_config name with
  | Some o -> o
  | None -> Fmt.invalid_arg "Unable to create %s %s" what name

(* Common types *)

type camera = Orx_gen.Camera.t
type obj = Orx_gen.Object.t
