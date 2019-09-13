// Adaptation of the FX tutorial from Orx
// This example is a direct adaptation of the 07_FX.c tutorial from Orx

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
  type t = {
    soldier: Orx.Object.t,
    mutable soldier_fx_lock: bool,
    box: Orx.Object.t,
    mutable selected_fx: string,
  };

  let state: ref(option(t)) = ref(None);

  let get = () => get_some(state^);
};

let input_event_handler = (event: Orx.Event.t) => {
  assert(Orx.Event.to_type(event) == Input);

  // Do nothing for now...

  Ok();
};

let fx_event_handler = (event: Orx.Event.t) => {
  assert(Orx.Event.to_type(event) == Fx);

  let state = State.get();
  let recipient = Orx.Event.get_recipient_object(event);
  let actual_event = Orx.Event.to_event(event, Fx);
  switch (actual_event) {
  | Start =>
    Fmt.pr(
      "FX <%s>@<%s> has started!@.",
      Orx.Fx_event.get_name(event),
      Orx.Object.get_name(recipient),
    );
    if (Orx.Object.equal(recipient, state.soldier)) {
      state.soldier_fx_lock = true;
    };
  | Stop =>
    Fmt.pr(
      "FX <%s>@<%s> has stopped!@.",
      Orx.Fx_event.get_name(event),
      Orx.Object.get_name(recipient),
    );
    if (Orx.Object.equal(recipient, state.soldier)) {
      state.soldier_fx_lock = false;
    };
  | Add
  | Remove
  | Loop => ()
  };

  Ok();
};

let update = (_clock_info: Orx.Clock.Info.t) => {
  let state = State.get();

  let possible_fx_inputs = [
    ("SelectMultiFX", "MultiFX"),
    ("SelectWobble", "WobbleFX"),
    ("SelectCircle", "CircleFX"),
    ("SelectFade", "FadeFX"),
    ("SelectFlash", "FlashFX"),
    ("SelectMove", "MoveFX"),
    ("SelectFlip", "FlipFX"),
  ];
  let found =
    List.find_opt(
      ((input, _fx)) => Orx.Input.is_active(input),
      possible_fx_inputs,
    );
  switch (found) {
  | None =>
    // No relevant input so there's nothing to do...
    ()
  | Some((_input, fx_name)) => state.selected_fx = fx_name
  };

  if (!state.soldier_fx_lock) {
    if (Orx.Input.is_active("ApplyFX") && Orx.Input.has_new_status("ApplyFX")) {
      Orx.Object.add_fx(state.soldier, state.selected_fx, ~unique=true)
      |> get_ok;
    };
  };
};

let init = () => {
  // Print out a hint to the user about what's to come
  let get_name = (binding: string): string => {
    let (type_, id, mode) = Orx.Input.get_binding(binding, 0) |> get_ok;
    Orx.Input.get_binding_name(type_, id, mode);
  };
  Fmt.pr(
    "@.- To select the FX to apply:@."
    ^^ " . '%s' => Wobble@."
    ^^ " . '%s' => Circle@."
    ^^ " . '%s' => Fade@."
    ^^ " . '%s' => Flash@."
    ^^ " . '%s' => Move@."
    ^^ " . '%s' => Flip@."
    ^^ " . '%s' => MultiFX that contains the slots of 4 of the above FXs@."
    ^^ "- '%s' will apply the current selected FX on soldier@."
    ^^ "* Only once FX will be applied at a time in this tutorial@."
    ^^ "* However an object can support up to 8 FXs at the same time@."
    ^^ "* Box has a looping rotating FX applied directly from config, requiring no code@.",
    get_name("SelectWobble"),
    get_name("SelectCircle"),
    get_name("SelectFade"),
    get_name("SelectFlash"),
    get_name("SelectMove"),
    get_name("SelectFlip"),
    get_name("SelectMultiFX"),
    get_name("ApplyFX"),
  );

  Orx.Viewport.create_from_config("Viewport") |> get_some |> ignore;

  let soldier = Orx.Object.create_from_config("Soldier") |> get_some;
  let box = Orx.Object.create_from_config("Box") |> get_some;
  State.state :=
    Some({soldier, box, soldier_fx_lock: false, selected_fx: "WobbleFX"});

  let clock = Orx.Clock.find_first(-1.0, Core) |> get_some;
  Orx.Clock.register(clock, update, Main, Normal) |> get_ok;

  Orx.Event.add_handler(Fx, fx_event_handler) |> get_ok;
  Orx.Event.add_handler(Input, input_event_handler) |> get_ok;

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
  Orx.Config.set_basename("07_FX") |> get_ok;
  Orx.Main.execute(~init, ~run, ~exit, ());
};