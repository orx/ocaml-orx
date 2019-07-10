// Adaptation of the physics tutorial from Orx
// This example is a direct adaptation of the 08_Physics.c tutorial from Orx

// Helper functions for unwrapping values.
let get_ok = (r: result('a, _)): 'a => {
  switch (r) {
  | Ok(x) => x
  | Error(_) => invalid_arg("get_ok: argument must be Ok(_)")
  };
};
let get_some = (o: option('a)): 'a => {
  switch (o) {
  | Some(x) => x
  | None => invalid_arg("get_some: argument must be Some(_)")
  };
};

module State = {
  type t = Orx.Camera.t;

  let state: ref(option(t)) = ref(None);

  let get = () => get_some(state^);
};

let event_handler = (event: Orx.Event.t) => {
  switch (Orx.Event.to_event(event, Physics)) {
  | Contact_remove => ()
  | Contact_add =>
    let sender = Orx.Event.get_sender_object(event);
    let recipient = Orx.Event.get_recipient_object(event);
    Orx.Object.add_fx(sender, "Bump") |> ignore;
    Orx.Object.add_fx(recipient, "Bump") |> ignore;
  };

  Ok();
};

let update = (clock_info: Orx.Clock.Info.t) => {
  let camera = State.get();
  let delta_rotation =
    if (Orx.Input.is_active("RotateLeft")) {
      Some(4.0 *. Orx.Clock.Info.get_dt(clock_info));
    } else if (Orx.Input.is_active("RotateRight")) {
      Some((-4.0) *. Orx.Clock.Info.get_dt(clock_info));
    } else {
      None;
    };

  switch (delta_rotation) {
  | None => ()
  | Some(delta) =>
    // Rotate the camera
    let current_rotation = Orx.Camera.get_rotation(camera);
    Orx.Camera.set_rotation(camera, current_rotation +. delta) |> get_ok;

    // Rotate gravity
    let gravity = Orx.Vector.rotate_2d(Orx.Physics.get_gravity(), delta);
    Orx.Physics.set_gravity(gravity) |> get_ok;
  };
};

let init = () => {
  let (type_, id, mode) = Orx.Input.get_binding("RotateLeft", 0) |> get_ok;
  let input_rotate_left = Orx.Input.get_binding_name(type_, id, mode);
  let (type_, id, mode) = Orx.Input.get_binding("RotateRight", 0) |> get_ok;
  let input_rotate_right = Orx.Input.get_binding_name(type_, id, mode);

  Fmt.pr(
    "- '%s' & '%s' will rotate the camera@.",
    input_rotate_left,
    input_rotate_right,
  );
  Fmt.pr("* Gravity will follow the camera@.");
  Fmt.pr("* a bump visual FX is played on objects that collide@.");

  let viewport = Orx.Viewport.create_from_config("Viewport");
  let camera = Orx.Viewport.get_camera(viewport) |> get_some;

  let clock = Orx.Clock.find_first(-1.0, Core) |> get_some;
  Orx.Clock.register(clock, update, Main, Normal) |> get_ok;

  State.state := Some(camera);

  Orx.Event.add_handler(Physics, event_handler) |> get_ok;

  Orx.Object.create_from_config("Sky") |> get_some |> ignore;
  Orx.Object.create_from_config("Walls") |> get_some |> ignore;

  Orx.Config.with_section("Tutorial", () => {
    for (_ in 1 to Orx.Config.get_int("BoxNumber")) {
      Orx.Object.create_from_config("Box") |> get_some |> ignore;
    }
  })
  |> get_ok;

  Ok();
};

let run = () =>
  if (Orx.Input.is_active("Quit")) {
    Error();
  } else {
    Ok();
  };

let exit = () => ();

let bootstrap = () => {
  // Tell Orx where to look for our configuration file(s)
  Orx.Resource.add_storage(
    Orx.Resource.Config,
    "examples/tutorial/data",
    false,
  );
};

let () = {
  Orx.Config.set_bootstrap(bootstrap) |> get_ok;
  Orx.Config.set_basename("08_Physics") |> get_ok;
  Orx.Main.execute(~init, ~run, ~exit, ());
};