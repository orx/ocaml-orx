include Orx_gen.Body_part

let set_self_flags part flags =
  set_self_flags part (Unsigned.UInt16.of_int flags)

let get_self_flags part = get_self_flags part |> Unsigned.UInt16.to_int

let set_check_mask part mask = set_check_mask part (Unsigned.UInt16.of_int mask)

let get_check_mask part = get_check_mask part |> Unsigned.UInt16.to_int
