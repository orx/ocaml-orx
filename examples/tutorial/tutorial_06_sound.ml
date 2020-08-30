(* Adaptation of the sound tutorial from Orx *)
(* This example is a direct adaptation of the 06_sound.c tutorial from Orx *)

module State = struct
  type t = {
    soldier : Orx.Object.t;
    music : Orx.Sound.t;
  }

  let state : t option ref = ref None

  let get () = Option.get !state
end

let event_message
    (event : Orx.Event.t)
    (sound_event_payload : Orx.Sound_event.payload)
    kind =
  let sound = Orx.Sound_event.get_sound sound_event_payload in
  let recipient = Orx.Event.get_recipient_object event |> Option.get in
  Fmt.pr "Sound [%s]@@[%s] has %s@." (Orx.Sound.get_name sound)
    (Orx.Object.get_name recipient)
    kind

let event_handler
    (event : Orx.Event.t)
    (sound_event : Orx.Sound_event.t)
    (payload : Orx.Sound_event.payload) =
  let state = State.get () in
  match Orx.Event.get_recipient_object event with
  | None -> Error `Orx
  | Some recipient ->
    if Orx.Object.equal state.soldier recipient then (
      match sound_event with
      | Start -> event_message event payload "started"
      | Stop -> event_message event payload "stopped"
      | _ -> ()
    );
    Ok ()

let update_state (state : State.t) (clock_info : Orx.Clock.Info.t) =
  if Orx.Input.has_been_activated "RandomSFX" then (
    Orx.Object.add_sound state.soldier "RandomBip" |> Result.get_ok;

    Orx.Config.push_section "Tutorial";
    Orx.Object.set_rgb state.soldier (Orx.Config.get_vector "RandomColor")
    |> Result.get_ok;
    Orx.Object.set_alpha state.soldier 1.0 |> Result.get_ok;
    Orx.Config.pop_section ()
  );

  if Orx.Input.has_been_activated "DefaultSFX" then (
    Orx.Object.add_sound state.soldier "DefaultBip" |> Result.get_ok;
    Orx.Object.set_rgb state.soldier (Orx.Vector.make ~x:1.0 ~y:1.0 ~z:1.0)
    |> Result.get_ok
  );

  if Orx.Input.is_active "PitchUp" then (
    Orx.Sound.set_pitch state.music
      (min (Orx.Sound.get_pitch state.music +. 0.01) 1.0);
    Orx.Object.set_rotation state.soldier
      (Orx.Object.get_rotation state.soldier
      +. (4.0 *. Orx.Clock.Info.get_dt clock_info)
      )
  );
  if Orx.Input.is_active "PitchDown" then (
    Orx.Sound.set_pitch state.music
      (max (Orx.Sound.get_pitch state.music -. 0.01) 0.0);
    Orx.Object.set_rotation state.soldier
      (Orx.Object.get_rotation state.soldier
      -. (4.0 *. Orx.Clock.Info.get_dt clock_info)
      )
  );

  if Orx.Input.is_active "VolumeDown" then (
    Orx.Sound.set_volume state.music
      (max (Orx.Sound.get_volume state.music -. 0.05) 0.0);
    Orx.Object.set_scale state.soldier
      (Orx.Vector.mulf (Orx.Object.get_scale state.soldier) 0.98)
  );
  if Orx.Input.is_active "VolumeUp" then (
    Orx.Sound.set_volume state.music
      (min (Orx.Sound.get_volume state.music +. 0.05) 1.0);
    Orx.Object.set_scale state.soldier
      (Orx.Vector.mulf (Orx.Object.get_scale state.soldier) 1.02)
  )

let update (clock_info : Orx.Clock.Info.t) =
  let state = State.get () in

  if Orx.Input.has_been_activated "ToggleMusic" then
    Orx.Object.enable state.soldier (not (Orx.Object.is_enabled state.soldier));
  if Orx.Object.is_enabled state.soldier then update_state state clock_info

let init () =
  (* Print out a hint to the user about what's to come *)
  let get_name (binding : string) : string =
    let (type_, id, mode) = Orx.Input.get_binding binding 0 |> Result.get_ok in
    Orx.Input.get_binding_name type_ id mode
  in
  Fmt.pr
    ("@.- '%s' & '%s' will change the music volume (+ soldier size)@."
    ^^ "- '%s' & '%s' will change the music pitch (+ soldier rotation)@."
    ^^ "- '%s' will toggle music (+ soldier display)@."
    ^^ "- '%s' will play a random SFX on the soldier (+ change its color)@."
    ^^ "- '%s' will the default SFX on the soldier (+ restore its color)@."
    ^^ "! The sound effect will be played only if the soldier is active@."
    )
    (get_name "VolumeUp") (get_name "VolumeDown") (get_name "PitchUp")
    (get_name "PitchDown") (get_name "ToggleMusic") (get_name "RandomSFX")
    (get_name "DefaultSFX");

  Orx.Viewport.create_from_config "Viewport" |> Option.get |> ignore;
  let soldier = Orx.Object.create_from_config "Soldier" |> Option.get in
  let clock = Orx.Clock.find_first (-1.0) Core |> Option.get in
  Orx.Object.add_sound soldier "Music" |> Result.get_ok;
  let music = Orx.Object.get_last_added_sound soldier |> Option.get in
  Orx.Sound.play music;
  Orx.Clock.register clock update Main Normal;
  Orx.Event.add_handler Sound event_handler;

  State.state := Some { soldier; music };

  Ok ()

let run () =
  if Orx.Input.is_active "Quit" then
    Orx.Status.error
  else
    Orx.Status.ok

let exit () = ()

let bootstrap () =
  (* Tell Orx where to look for our configuration file(s) *)
  Orx.Resource.add_storage Orx.Resource.Config "examples/tutorial/data" false

let () =
  Orx.Config.set_bootstrap bootstrap;
  Orx.Config.set_basename "06_Sound";
  Orx.Main.execute ~init ~run ~exit ()
