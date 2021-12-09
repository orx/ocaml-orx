type t =
  | Camera of Orx_gen.Camera.t
  | Object of Orx_gen.Object.t

let set setter child (parent : t option) =
  let to_parent_ptr (p : t) =
    match p with
    | Camera c -> Orx_gen.Camera.to_void_pointer c
    | Object o -> Orx_gen.Object.to_void_pointer o
  in
  setter child (Option.map to_parent_ptr parent)

let of_void_pointer p : t option =
  match Orx_gen.Object.of_void_pointer p with
  | Some o -> Some (Object o)
  | None ->
    ( match Orx_gen.Camera.of_void_pointer p with
    | Some c -> Some (Camera c)
    | None -> None
    )
