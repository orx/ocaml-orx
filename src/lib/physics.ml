include Orx_gen.Physics

let get_gravity = Vector.get_vector_exn (fun () v -> get_gravity v)

let check_collision_flag ~mask ~flag =
  Unsigned.UInt32.equal (Unsigned.UInt32.logand mask flag) flag
