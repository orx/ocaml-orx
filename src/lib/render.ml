include Orx_gen.Render

let get_world_position vector viewport =
  Vector.get_optional_vector
    (fun () v -> get_world_position vector viewport v)
    ()

let get_screen_position vector viewport =
  Vector.get_optional_vector
    (fun () v -> get_screen_position vector viewport v)
    ()
