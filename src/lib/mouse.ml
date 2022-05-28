include Orx_gen.Mouse

let get_position = Vector.get_optional_vector (fun () v -> get_position v)

let get_position_exn () =
  match get_position () with
  | Some v -> v
  | None -> invalid_arg "Unable to get mouse position"

let get_move_delta = Vector.get_optional_vector (fun () v -> get_move_delta v)
