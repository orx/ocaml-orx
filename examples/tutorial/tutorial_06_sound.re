// Adaptation of the sound tutorial from Orx
// This example is a direct adaptation of the 06_sound.c tutorial from Orx

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
    music: Orx.Sound.t,
  };

  let state: ref(option(t)) = ref(None);

  let get = () => get_some(state^);
};

let event_message = (event: Orx.Event.t, kind) => {
  assert(Orx.Event.to_type(event) == Sound);

  let sound = Orx.Sound_event.get_sound(event);
  let recipient = Orx.Event.get_recipient_object(event);
  Fmt.pr(
    "Sound [%s]@@[%s] has %s@.",
    Orx.Sound.get_name(sound),
    Orx.Object.get_name(recipient),
    kind,
  );
};

let event_handler = (event: Orx.Event.t) => {
  let state = State.get();
  if (Orx.Object.equal(state.soldier, Orx.Event.get_recipient_object(event))) {
    switch (Orx.Event.to_event(event, Sound)) {
    | Start => event_message(event, "started")
    | Stop => event_message(event, "stopped")
    | _ => ()
    };
  };
  Ok();
};

let update_state = (state: State.t, clock_info: Orx.Clock.Info.t) => {
  if (Orx.Input.has_been_activated("RandomSFX")) {
    Orx.Object.add_sound(state.soldier, "RandomBip") |> get_ok;

    Orx.Config.push_section("Tutorial") |> get_ok;
    Orx.Object.set_rgb(state.soldier, Orx.Config.get_vector("RandomColor"))
    |> get_ok;
    Orx.Object.set_alpha(state.soldier, 1.0) |> get_ok;
    Orx.Config.pop_section() |> get_ok;
  };

  if (Orx.Input.has_been_activated("DefaultSFX")) {
    Orx.Object.add_sound(state.soldier, "DefaultBip") |> get_ok;
    Orx.Object.set_rgb(
      state.soldier,
      Orx.Vector.make(~x=1.0, ~y=1.0, ~z=1.0),
    )
    |> get_ok;
  };

  if (Orx.Input.is_active("PitchUp")) {
    Orx.Sound.set_pitch(
      state.music,
      min(Orx.Sound.get_pitch(state.music) +. 0.01, 1.0),
    )
    |> get_ok;
    Orx.Object.set_rotation(
      state.soldier,
      Orx.Object.get_rotation(state.soldier)
      +. 4.0
      *. Orx.Clock.Info.get_dt(clock_info),
    )
    |> get_ok;
  };
  if (Orx.Input.is_active("PitchDown")) {
    Orx.Sound.set_pitch(
      state.music,
      max(Orx.Sound.get_pitch(state.music) -. 0.01, 0.0),
    )
    |> get_ok;
    Orx.Object.set_rotation(
      state.soldier,
      Orx.Object.get_rotation(state.soldier)
      -. 4.0
      *. Orx.Clock.Info.get_dt(clock_info),
    )
    |> get_ok;
  };

  if (Orx.Input.is_active("VolumeDown")) {
    Orx.Sound.set_volume(
      state.music,
      max(Orx.Sound.get_volume(state.music) -. 0.05, 0.0),
    )
    |> get_ok;
    Orx.Object.set_scale(
      state.soldier,
      Orx.Vector.scale(
        Orx.Object.get_scale(state.soldier) |> get_some,
        0.98,
      ),
    )
    |> get_ok;
  };
  if (Orx.Input.is_active("VolumeUp")) {
    Orx.Sound.set_volume(
      state.music,
      min(Orx.Sound.get_volume(state.music) +. 0.05, 1.0),
    )
    |> get_ok;
    Orx.Object.set_scale(
      state.soldier,
      Orx.Vector.scale(
        Orx.Object.get_scale(state.soldier) |> get_some,
        1.02,
      ),
    )
    |> get_ok;
  };
};

let update = (clock_info: Orx.Clock.Info.t) => {
  let state = State.get();

  if (Orx.Input.has_been_activated("ToggleMusic")) {
    Orx.Object.enable(state.soldier, !Orx.Object.is_enabled(state.soldier));
  };
  if (Orx.Object.is_enabled(state.soldier)) {
    update_state(state, clock_info);
  };
};

let init = () => {
  // Print out a hint to the user about what's to come
  let get_name = (binding: string): string => {
    let (type_, id, mode) = Orx.Input.get_binding(binding, 0) |> get_ok;
    Orx.Input.get_binding_name(type_, id, mode);
  };
  Fmt.pr(
    "@.- '%s' & '%s' will change the music volume (+ soldier size)@."
    ^^ "- '%s' & '%s' will change the music pitch (+ soldier rotation)@."
    ^^ "- '%s' will toggle music (+ soldier display)@."
    ^^ "- '%s' will play a random SFX on the soldier (+ change its color)@."
    ^^ "- '%s' will the default SFX on the soldier (+ restore its color)@."
    ^^ "! The sound effect will be played only if the soldier is active@.",
    get_name("VolumeUp"),
    get_name("VolumeDown"),
    get_name("PitchUp"),
    get_name("PitchDown"),
    get_name("ToggleMusic"),
    get_name("RandomSFX"),
    get_name("DefaultSFX"),
  );

  Orx.Viewport.create_from_config("Viewport") |> get_some |> ignore;
  let soldier = Orx.Object.create_from_config("Soldier") |> get_some;
  let clock = Orx.Clock.find_first(-1.0, Core) |> get_some;
  Orx.Object.add_sound(soldier, "Music") |> get_ok;
  let music = Orx.Object.get_last_added_sound(soldier) |> get_some;
  Orx.Sound.play(music) |> get_ok;
  Orx.Clock.register(clock, update, Main, Normal) |> get_ok;
  Orx.Event.add_handler(Sound, event_handler) |> get_ok;

  State.state := Some({soldier, music});

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
  Orx.Config.set_basename("06_Sound") |> get_ok;
  Orx.Main.execute(~init, ~run, ~exit, ());
};
