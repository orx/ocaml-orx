(* The action states the knight can be in *)
module Action = struct
  type t =
    | Idle
    | Lie
    | Run
    | Walk

  let to_string action =
    match action with
    | Idle -> "Idle"
    | Lie -> "Lie"
    | Run -> "Run"
    | Walk -> "Walk"
end

(* Convenience functions for setting target animation states *)
module Animation = struct
  let name ~action ~facing =
    Fmt.str "Knight%s%sAnimation" (Action.to_string action)
      (Facing.to_string facing)

  let set_target knight action facing =
    Orx.Object.set_target_anim_exn knight (name ~action ~facing)
end

let lie_down knight facing =
  Animation.set_target knight Lie facing;
  Orx.Object.set_speed knight Orx.Vector.(make ~x:0.0 ~y:0.0 ~z:0.0)

(* Get the knights velocity - speed and direction - based on player input. *)
let get_new_velocity knight action =
  (* Subtracting the input values for each axis like this gives us a value from
     -1.0 to 1.0 on each axis. For on/off inputs like a keyboard the values will
     be -1.0, 0.0 or 1.0. For an analog input like a joystick/thumbstick axis
     the value can be anything in that range. *)
  let horizontal = Orx.Input.get_value "Right" -. Orx.Input.get_value "Left" in
  let vertical = Orx.Input.get_value "Down" -. Orx.Input.get_value "Up" in
  (* Maximum movement speed is defined in config in knight.ini *)
  let top_speed =
    let section = Orx.Object.get_name knight in
    let key = Fmt.str "%sSpeed" (Action.to_string action) in
    Orx.Config.Value.get Float ~section ~key
  in
  let direction =
    let raw = Orx.Vector.make ~x:horizontal ~y:vertical ~z:0.0 in
    (* Normalize the direction vector if it's larger than 1.0 as a simple fix to
       avoid diagonal movement being greater than horizontal or vertical
       movement. *)
    if Float.abs (Orx.Vector.get_size raw) > 1.0 then
      Orx.Vector.normalize raw
    else
      raw
  in
  Orx.Vector.mulf direction top_speed

let get_new_facing velocity prev_facing : Facing.t =
  let x = Orx.Vector.get_x velocity in
  if x < 0.0 then
    Left
  else if x > 0.0 then
    Right
  else
    (* If we are not moving, continue facing in the direction we were
       previously *)
    prev_facing

let walk_or_run knight prev_facing =
  let action : Action.t =
    if Orx.Input.is_active "Walk" then
      Walk
    else
      Run
  in
  let prev_speed = Orx.Object.get_speed knight |> Orx.Vector.get_size in
  let velocity = get_new_velocity knight action in
  let now_facing = get_new_facing velocity prev_facing in
  State.facing := now_facing;
  Orx.Object.set_speed knight velocity;
  let speed = Orx.Vector.get_size velocity in
  if Orx.Vector.get_x velocity <> 0.0 || (speed <> 0.0 && prev_speed <> 0.0)
  then
    Animation.set_target knight action now_facing
  else if speed = 0.0 && prev_speed = 0.0 then
    Animation.set_target knight Idle now_facing

let input_handler (_ : Orx.Clock.Info.t) =
  let knight = Runtime.get_object "Knight" in
  let prev_facing = !State.facing in
  if Orx.Input.is_active "Lie" then
    lie_down knight prev_facing
  else
    walk_or_run knight prev_facing

let init () = Orx.Clock.register (Orx.Clock.get_core ()) input_handler
