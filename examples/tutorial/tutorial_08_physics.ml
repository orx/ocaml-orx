(* Adaptation of the physics tutorial from Orx *)
(* This example is a direct adaptation of the 08_Physics.c tutorial from Orx *)

module State = struct
  type t = Orx.Camera.t

  let state : t option ref = ref None

  let get () = Option.get !state
end

let event_handler
    (event : Orx.Event.t)
    (physics : Orx.Physics_event.t)
    (_payload : Orx.Physics_event.payload) =
  ( match physics with
  | Contact_remove -> ()
  | Contact_add ->
    let sender = Orx.Event.get_sender_object event |> Option.get in
    let recipient = Orx.Event.get_recipient_object event |> Option.get in
    Orx.Object.add_fx sender "Bump" |> ignore;
    Orx.Object.add_fx recipient "Bump" |> ignore
  );

  Ok ()

let update (clock_info : Orx.Clock.Info.t) =
  let camera = State.get () in
  let delta_rotation =
    if Orx.Input.is_active "RotateLeft" then
      Some (4.0 *. Orx.Clock.Info.get_dt clock_info)
    else if Orx.Input.is_active "RotateRight" then
      Some (-4.0 *. Orx.Clock.Info.get_dt clock_info)
    else
      None
  in

  match delta_rotation with
  | None -> ()
  | Some delta ->
    (* Rotate the camera *)
    let current_rotation = Orx.Camera.get_rotation camera in
    Orx.Camera.set_rotation camera (current_rotation +. delta) |> Result.get_ok;

    (* Rotate gravity *)
    let gravity =
      Orx.Vector.rotate_2d (Orx.Physics.get_gravity () |> Option.get) delta
    in
    Orx.Physics.set_gravity gravity |> Result.get_ok

let init () =
  let (type_, id, mode) =
    Orx.Input.get_binding "RotateLeft" 0 |> Result.get_ok
  in
  let input_rotate_left = Orx.Input.get_binding_name type_ id mode in
  let (type_, id, mode) =
    Orx.Input.get_binding "RotateRight" 0 |> Result.get_ok
  in
  let input_rotate_right = Orx.Input.get_binding_name type_ id mode in

  Fmt.pr "- '%s' & '%s' will rotate the camera@." input_rotate_left
    input_rotate_right;
  Fmt.pr "* Gravity will follow the camera@.";
  Fmt.pr "* a bump visual FX is played on objects that collide@.";

  let viewport = Orx.Viewport.create_from_config "Viewport" |> Option.get in
  let camera = Orx.Viewport.get_camera viewport |> Option.get in

  let clock = Orx.Clock.find_first (-1.0) Core |> Option.get in
  Orx.Clock.register clock update Main Normal |> Result.get_ok;

  State.state := Some camera;

  Orx.Event.add_handler Physics event_handler |> Result.get_ok;

  Orx.Object.create_from_config "Scene" |> Option.get |> ignore;

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
  Orx.Config.set_basename "08_Physics";
  Orx.Main.execute ~init ~run ~exit ()
