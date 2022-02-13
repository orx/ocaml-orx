let init () =
  (* Create the game's viewport *)
  let (_ : Orx.Viewport.t) = Orx.Viewport.create_from_config_exn "Viewport" in

  (* Setup the game scene *)
  let (_ : Orx.Object.t) = Orx.Object.create_from_config_exn "Scene" in

  (* Initialize knight behavior *)
  Knight.init ();

  Ok ()

let run () =
  if Orx.Input.is_active "Quit" then
    (* Returning an error indicates that the engine should exit *)
    Orx.Status.error
  else
    Orx.Status.ok

let () =
  (* Start the game engine loop *)
  Orx.Main.start ~config_dir:"examples/ocaml/top_down_movement/data/config"
    ~init ~run "main"
