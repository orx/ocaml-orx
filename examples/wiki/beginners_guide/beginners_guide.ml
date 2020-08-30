(* Orx demo project, roughly following the beginner's guide available here:
   http://orx-project.org/wiki/en/guides/beginners/main

   This tries to follow the guide fairly closely, hopefully making it easy to
   see how the Orx API calls used here match their C counterparts. *)

module Helpers = struct
  (* Create an explosion named name (defined in the game's configuration) at *)
  (* the object o *)
  let create_explosion_at_object (o : Orx.Object.t) (name : string) =
    let position = Orx.Object.get_world_position o in
    Orx.Vector.set_z position 0.0;
    let explosion = Orx.Object.create_from_config name |> Option.get in
    Orx.Object.set_position explosion position
end

(* Global game state *)

module State = struct
  type t = {
    mutable score : int;
    hero : Orx.Object.t;
    heros_gun : Orx.Object.t;
    score_object : Orx.Object.t;
    scene : Orx.Object.t;
    viewport : Orx.Viewport.t;
  }

  let state : t option ref = ref None

  let get () = Option.get !state

  (* Increase the score by a given amount *)
  let increase_score (state : t) (earned : int) : unit =
    state.score <- state.score + earned;
    let formatted_score = Fmt.strf "%06d" state.score in
    Orx.Object.set_text_string state.score_object formatted_score
end

module Physics = struct
  (* Event handler use when a new contact is added - two objects have come in *)
  (* contact with one another *)
  let on_add_contact
      (state : State.t)
      ~(sender : Orx.Object.t)
      ~(recipient : Orx.Object.t) =
    let sender_name = Orx.Object.get_name sender in
    let recipient_name = Orx.Object.get_name recipient in

    if String.equal sender_name "StarObject" then (
      Orx.Object.set_life_time sender 0.0;
      State.increase_score state 1000
    );
    if String.equal recipient_name "StarObject" then (
      Orx.Object.set_life_time recipient 0.0;
      State.increase_score state 1000
    );

    if String.equal sender_name "BulletObject" then (
      Helpers.create_explosion_at_object recipient "JellyExploder";
      Orx.Object.set_life_time sender 0.0;
      Orx.Object.set_life_time recipient 0.0;
      State.increase_score state 250
    );
    if String.equal recipient_name "BulletObject" then (
      Helpers.create_explosion_at_object sender "JellyExploder";
      Orx.Object.set_life_time sender 0.0;
      Orx.Object.set_life_time recipient 0.0;
      State.increase_score state 250
    );

    if
      String.equal recipient_name "HeroObject"
      && String.equal sender_name "MonsterObject"
    then (
      Helpers.create_explosion_at_object recipient "HeroExploder";
      Orx.Object.set_life_time sender 0.0;
      Orx.Object.enable recipient false;
      Orx.Object.add_time_line_track state.scene "PopUpGameOverTrack"
      |> Result.get_ok
    );
    if
      String.equal sender_name "HeroObject"
      && String.equal recipient_name "MonsterObject"
    then (
      Helpers.create_explosion_at_object sender "HeroExploder";
      Orx.Object.set_life_time recipient 0.0;
      Orx.Object.enable sender false;
      Orx.Object.add_time_line_track state.scene "PopUpGameOverTrack"
      |> Result.get_ok
    );

    Ok ()

  (* Main Orx event handler *)
  let event_handler
      (event : Orx.Event.t)
      (physics : Orx.Physics_event.t)
      (_payload : Orx.Physics_event.payload) =
    let state = State.get () in
    match physics with
    | Contact_add ->
      let sender = Orx.Event.get_sender_object event |> Option.get in
      let recipient = Orx.Event.get_recipient_object event |> Option.get in
      on_add_contact state ~sender ~recipient
    | Contact_remove -> Ok ()
end

let bootstrap () =
  (* Tell Orx where to look for our configuration file(s) *)
  Orx.Resource.add_storage Orx.Resource.Config
    "examples/wiki/beginners_guide/data/config" false

let init () =
  (* Get some values defined in the game's ini config *)
  let viewport = Orx.Viewport.create_from_config "Viewport" |> Option.get in
  let hero = Orx.Object.create_from_config "HeroObject" |> Option.get in
  let heros_gun = Orx.Object.get_first_child hero Owned_object |> Option.get in
  let score_object =
    Orx.Object.create_from_config "ScoreObject" |> Option.get
  in
  let scene = Orx.Object.create_from_config "Scene" |> Option.get in

  State.state :=
    Some { hero; heros_gun; viewport; score_object; scene; score = 0 };

  Orx.Object.create_from_config "PlatformObject" |> Option.get |> ignore;

  (* No shooting to start out *) Orx.Object.enable heros_gun false;

  (* Setup our physics event handler *)
  Orx.Event.add_handler Physics Physics.event_handler |> Result.get_ok;

  Ok ()

let run () =
  (* Get our global state *)
  let state = State.get () in

  (* Movement vectors *)
  let left_speed = Orx.Vector.make ~x:(-10.0) ~y:0.0 ~z:0.0 in
  let right_speed = Orx.Vector.make ~x:10.0 ~y:0.0 ~z:0.0 in
  let flip_left = Orx.Vector.make ~x:(-2.0) ~y:2.0 ~z:1.0 in
  let flip_right = Orx.Vector.make ~x:2.0 ~y:2.0 ~z:1.0 in

  let jump_speed = Orx.Vector.make ~x:0.0 ~y:(-600.0) ~z:0.0 in

  if Orx.Input.is_active "Quit" then
    (* Return an error to indicate that it's time to quit the engine *)
    Orx.Status.error
  else (
    (* Left/right movement *)
    if Orx.Input.is_active "GoLeft" then (
      Orx.Object.set_scale state.hero flip_left;
      Orx.Object.apply_impulse state.hero left_speed None |> Result.get_ok;
      Orx.Object.set_target_anim state.hero "HeroRun" |> Result.get_ok
    ) else if Orx.Input.is_active "GoRight" then (
      Orx.Object.set_scale state.hero flip_right;
      Orx.Object.apply_impulse state.hero right_speed None |> Result.get_ok;
      Orx.Object.set_target_anim state.hero "HeroRun" |> Result.get_ok
    ) else
      Orx.Object.set_target_anim state.hero "HeroIdle" |> Result.get_ok;

    (* Shooting *)
    if Orx.Input.is_active "Shoot" then
      Orx.Object.enable state.heros_gun true
    else
      Orx.Object.enable state.heros_gun false;

    (* Jumping *)
    if Orx.Input.is_active "Jump" && Orx.Input.has_new_status "Jump" then
      Orx.Object.apply_impulse state.hero jump_speed None |> Result.get_ok;

    (* Done! *)
    Orx.Status.ok
  )

(* Orx will handle all the cleanup we need *)

let exit () = ()

let () =
  (* Setup our bootstrap function *)
  Orx.Config.set_bootstrap bootstrap;
  (* Set the basename for Orx - used to know which config file to read *)
  Orx.Config.set_basename "tutorial";
  (* Start Orx and run the main loop *)
  Orx.Main.execute ~init ~run ~exit ()
