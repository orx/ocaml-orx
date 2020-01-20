// Adaptation of the scrolling tutorial from Orx
// This example is a direct adaptation of the 09_Scrolling.c tutorial from Orx

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

let update = (clock_info: Orx.Clock.Info.t) => {
  let camera = State.get();

  Orx.Config.push_section("Tutorial") |> get_ok;
  let scroll_speed = Orx.Config.get_vector("ScrollSpeed");
  Orx.Config.pop_section() |> get_ok;

  let scroll_speed =
    Orx.Vector.scale(scroll_speed, Orx.Clock.Info.get_dt(clock_info));

  let move_x =
    if (Orx.Input.is_active("CameraRight")) {
      Orx.Vector.get_x(scroll_speed);
    } else if (Orx.Input.is_active("CameraLeft")) {
      -. Orx.Vector.get_x(scroll_speed);
    } else {
      0.0;
    };
  let move_y =
    if (Orx.Input.is_active("CameraUp")) {
      -. Orx.Vector.get_y(scroll_speed);
    } else if (Orx.Input.is_active("CameraDown")) {
      Orx.Vector.get_y(scroll_speed);
    } else {
      0.0;
    };
  let move_z =
    if (Orx.Input.is_active("CameraZoomIn")) {
      Orx.Vector.get_z(scroll_speed);
    } else if (Orx.Input.is_active("CameraZoomOut")) {
      -. Orx.Vector.get_z(scroll_speed);
    } else {
      0.0;
    };
  let move = Orx.Vector.make(~x=move_x, ~y=move_y, ~z=move_z);

  let camera_position = Orx.Camera.get_position(camera);
  Orx.Camera.set_position(camera, Orx.Vector.add(camera_position, move))
  |> get_ok;
};

let init = () => {
  // Print out a hint to the user about what's to come
  let get_name = (binding: string): string => {
    let (type_, id, mode) = Orx.Input.get_binding(binding, 0) |> get_ok;
    Orx.Input.get_binding_name(type_, id, mode);
  };

  Fmt.pr(
    "- '%s', '%s', '%s' & '%s' will move the camera@."
    ^^ "- '%s' & '%s' will zoom in/out@."
    ^^ "* The scrolling and auto-scaling of objects is data-driven, no code required@."
    ^^ "* The sky background will follow the camera (parent/child frame relation)@.",
    get_name("CameraUp"),
    get_name("CameraLeft"),
    get_name("CameraDown"),
    get_name("CameraRight"),
    get_name("CameraZoomIn"),
    get_name("CameraZoomOut"),
  );

  let viewport = Orx.Viewport.create_from_config("Viewport") |> get_some;
  let camera = Orx.Viewport.get_camera(viewport) |> get_some;
  State.state := Some(camera);

  let clock = Orx.Clock.find_first(-1.0, Core) |> get_some;
  Orx.Clock.register(clock, update, Main, Normal) |> get_ok;

  Orx.Object.create_from_config("Scene") |> get_some |> ignore;

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
  Orx.Config.set_basename("09_Scrolling") |> get_ok;
  Orx.Main.execute(~init, ~run, ~exit, ());
};
