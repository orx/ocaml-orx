/* Orx demo project, roughly following the beginner's guide available here:
   http://orx-project.org/wiki/en/guides/beginners/main

   This tries to follow the guide fairly closely, hopefully making it easy to
   see how the Orx API calls used here match their C counterparts. */

// Helper functions for unwrapping values.  Proper error handling would be
// ideal in a full game implementation but would obscure the intent in this
// translation of the beginner's guide.
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

module Helpers = {
  // Create an explosion named name (defined in the game's configuration) at
  // the object o
  let create_explosion_at_object = (o: Orx.Object.t, name: string) => {
    let position = Orx.Object.get_world_position(o) |> get_some;
    Orx.Vector.set_z(position, 0.0);
    let explosion = Orx.Object.create_from_config(name) |> get_some;
    Orx.Object.set_position(explosion, position) |> get_ok;
  };
};

// Global game state
module State = {
  type t = {
    mutable score: int,
    hero: Orx.Object.t,
    heros_gun: Orx.Object.t,
    score_object: Orx.Object.t,
    scene: Orx.Object.t,
    viewport: Orx.Viewport.t,
  };

  let state: ref(option(t)) = ref(None);

  let get = () => get_some(state^);

  // Increase the score by a given amount
  let increase_score = (state: t, earned: int): unit => {
    state.score = state.score + earned;
    let formatted_score = Fmt.strf("%06d", state.score);
    Orx.Object.set_text_string(state.score_object, formatted_score) |> get_ok;
  };
};

module Physics = {
  // Event handler use when a new contact is added - two objects have come in
  // contact with one another
  let on_add_contact =
      (state: State.t, ~sender: Orx.Object.t, ~recipient: Orx.Object.t) => {
    let sender_name = Orx.Object.get_name(sender);
    let recipient_name = Orx.Object.get_name(recipient);

    if (String.equal(sender_name, "StarObject")) {
      Orx.Object.set_life_time(sender, 0.0) |> get_ok;
      State.increase_score(state, 1000);
    };
    if (String.equal(recipient_name, "StarObject")) {
      Orx.Object.set_life_time(recipient, 0.0) |> get_ok;
      State.increase_score(state, 1000);
    };

    if (String.equal(sender_name, "BulletObject")) {
      Helpers.create_explosion_at_object(recipient, "JellyExploder");
      Orx.Object.set_life_time(sender, 0.0) |> get_ok;
      Orx.Object.set_life_time(recipient, 0.0) |> get_ok;
      State.increase_score(state, 250);
    };
    if (String.equal(recipient_name, "BulletObject")) {
      Helpers.create_explosion_at_object(sender, "JellyExploder");
      Orx.Object.set_life_time(sender, 0.0) |> get_ok;
      Orx.Object.set_life_time(recipient, 0.0) |> get_ok;
      State.increase_score(state, 250);
    };

    if (String.equal(recipient_name, "HeroObject")
        && String.equal(sender_name, "MonsterObject")) {
      Helpers.create_explosion_at_object(recipient, "HeroExploder");
      Orx.Object.set_life_time(sender, 0.0) |> get_ok;
      Orx.Object.enable(recipient, false);
      Orx.Object.add_time_line_track(state.scene, "PopUpGameOverTrack")
      |> get_ok;
    };
    if (String.equal(sender_name, "HeroObject")
        && String.equal(recipient_name, "MonsterObject")) {
      Helpers.create_explosion_at_object(sender, "HeroExploder");
      Orx.Object.set_life_time(recipient, 0.0) |> get_ok;
      Orx.Object.enable(sender, false);
      Orx.Object.add_time_line_track(state.scene, "PopUpGameOverTrack")
      |> get_ok;
    };

    Ok();
  };

  // Main Orx event handler
  let event_handler = (event: Orx.Event.t) => {
    let state = State.get();
    switch (Orx.Event.to_event(event, Physics)) {
    | Contact_add =>
      let sender = Orx.Event.get_sender_object(event);
      let recipient = Orx.Event.get_recipient_object(event);
      on_add_contact(state, ~sender, ~recipient);
    | Contact_remove => Ok()
    };
  };
};

let bootstrap = () => {
  // Tell Orx where to look for our configuration file(s)
  Orx.Resource.add_storage(
    Orx.Resource.Config,
    "examples/wiki/beginners_guide/data/config",
    false,
  );
};

let init = () => {
  // Get some values defined in the game's ini config
  let viewport = Orx.Viewport.create_from_config("Viewport") |> get_some;
  let hero = Orx.Object.create_from_config("HeroObject") |> get_some;
  let heros_gun = Orx.Object.get_child_object(hero) |> get_some;
  let score_object = Orx.Object.create_from_config("ScoreObject") |> get_some;
  let scene = Orx.Object.create_from_config("Scene") |> get_some;

  State.state :=
    Some({hero, heros_gun, viewport, score_object, scene, score: 0});

  Orx.Object.create_from_config("PlatformObject") |> get_some |> ignore;

  // No shooting to start out
  Orx.Object.enable(heros_gun, false);

  // Setup our physics event handler
  Orx.Event.add_handler(Physics, Physics.event_handler) |> get_ok;

  Ok();
};

let run = () => {
  // Get our global state
  let state = State.get();

  // Movement vectors
  let left_speed = Orx.Vector.make(~x=-1.0, ~y=0.0, ~z=0.0);
  let right_speed = Orx.Vector.make(~x=1.0, ~y=0.0, ~z=0.0);
  let flip_left = Orx.Vector.make(~x=-2.0, ~y=2.0, ~z=1.0);
  let flip_right = Orx.Vector.make(~x=2.0, ~y=2.0, ~z=1.0);

  let jump_speed = Orx.Vector.make(~x=0.0, ~y=-600.0, ~z=0.0);

  if (Orx.Input.is_active("Quit")) {
    // Return an error to indicate that it's time to quit the engine
    Error();
  } else {
    // Left/right movement
    if (Orx.Input.is_active("GoLeft")) {
      Orx.Object.set_scale(state.hero, flip_left) |> get_ok;
      Orx.Object.apply_impulse(state.hero, left_speed, None) |> get_ok;
      Orx.Object.set_target_anim(state.hero, "HeroRun") |> get_ok;
    } else if (Orx.Input.is_active("GoRight")) {
      Orx.Object.set_scale(state.hero, flip_right) |> get_ok;
      Orx.Object.apply_impulse(state.hero, right_speed, None) |> get_ok;
      Orx.Object.set_target_anim(state.hero, "HeroRun") |> get_ok;
    } else {
      Orx.Object.set_target_anim(state.hero, "HeroIdle") |> get_ok;
    };

    // Shooting
    if (Orx.Input.is_active("Shoot")) {
      Orx.Object.enable(state.heros_gun, true);
    } else {
      Orx.Object.enable(state.heros_gun, false);
    };

    // Jumping
    if (Orx.Input.is_active("Jump") && Orx.Input.has_new_status("Jump")) {
      Orx.Object.apply_impulse(state.hero, jump_speed, None) |> get_ok;
    };

    // Done!
    Ok();
  };
};

// Orx will handle all the cleanup we need
let exit = () => ();

let () = {
  // Setup our bootstrap function
  Orx.Config.set_bootstrap(bootstrap) |> get_ok;
  // Set the basename for Orx - used to know which config file to read
  Orx.Config.set_basename("tutorial") |> get_ok;
  // Start Orx and run the main loop
  Orx.Main.execute(~init, ~run, ~exit, ());
};
