type t =
  | Left
  | Right

let to_string t =
  match t with
  | Left -> "Left"
  | Right -> "Right"
