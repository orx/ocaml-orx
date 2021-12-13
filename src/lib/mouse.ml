include Orx_gen.Mouse

let get_position = Vector.get_optional_vector (fun () v -> get_position v)

let get_move_delta = Vector.get_optional_vector (fun () v -> get_move_delta v)
