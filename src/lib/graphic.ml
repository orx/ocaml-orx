open Direct_bindings

include Orx_gen.Graphic

let get_size = Vector.get_vector get_size

let get_origin = Vector.get_vector get_origin

let set_flip (g : t) ~x ~y = set_flip g x y

let to_structure (g : t) : Structure.t =
  let g' = Ctypes.to_voidp g in
  match Structure.of_void_pointer g' with
  | Some s -> s
  | None -> assert false
