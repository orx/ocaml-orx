open Common

include Orx_gen.Obox

let make ~pos ~pivot ~size angle : t =
  let ob = allocate_raw () in
  let (_ : t) = set_2d ob pos pivot size angle in
  ob

let copy (ob : t) =
  let copied : t = allocate_raw () in
  let (_ : t) = copy copied ob in
  copied

let get_center (ob : t) : Vector.t =
  let center = Vector.allocate_raw () in
  let (_ : Vector.t) = get_center ob center in
  center

let move (ob : t) (v : Vector.t) : t =
  let moved : t = allocate_raw () in
  let (_ : t) = move moved ob v in
  moved

let rotate_2d (ob : t) angle : t =
  let rotated : t = allocate_raw () in
  let (_ : t) = rotate_2d rotated ob angle in
  rotated

(* For internal use *)

(* Wrapper for functions which return a obox property. *)
(* Orx uses the return value to indicate if the get was a success or not. *)
let get_obox_exn get o =
  let v = allocate_raw () in
  match get o v with
  | None -> fail "Failed to allocate obox"
  | Some _v -> v
