(** {1 Directions a character can be facing} *)

type t =
  | Left
  | Right

val to_string : t -> string
(** [to_string facing] is returns a string representation of [facing] suitable
    for use with config value. *)
