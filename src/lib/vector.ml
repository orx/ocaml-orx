open Common

include Orx_gen.Vector

let get_x (v : t) : float = Ctypes.getf !@v Orx_types.Vector.x

let get_y (v : t) : float = Ctypes.getf !@v Orx_types.Vector.y

let get_z (v : t) : float = Ctypes.getf !@v Orx_types.Vector.z

let equal_2d (a : t) (b : t) : bool =
  Float.equal (get_x a) (get_x b) && Float.equal (get_y a) (get_y b)

let pp ppf (v : t) = Fmt.pf ppf "(%g, %g, %g)" (get_x v) (get_y v) (get_z v)

let make ~x ~y ~z : t =
  let v = allocate_raw () in
  let (_ : t) = set v x y z in
  v

let set_x (v : t) (x : float) : unit = Ctypes.setf !@v Orx_types.Vector.x x

let set_y (v : t) (y : float) : unit = Ctypes.setf !@v Orx_types.Vector.y y

let set_z (v : t) (z : float) : unit = Ctypes.setf !@v Orx_types.Vector.z z

let make_one_vec_op op =
  let f' ~(target : t) (v : t) : unit =
    let (_ : t) = op target v in
    ()
  in
  let f (v : t) : t =
    let target : t = allocate_raw () in
    f' ~target v;
    target
  in
  (f', f)

let (copy', copy) = make_one_vec_op copy

let (normalize', normalize) = make_one_vec_op normalize

let (reciprocal', reciprocal) = make_one_vec_op reciprocal

let (round', round) = make_one_vec_op round

let (floor', floor) = make_one_vec_op floor

let (neg', neg) = make_one_vec_op neg

let make_two_vec_op op =
  let f' ~(target : t) (v1 : t) (v2 : t) : unit =
    let (_ : t) = op target v1 v2 in
    ()
  in
  let f (v1 : t) (v2 : t) : t =
    let target : t = allocate_raw () in
    f' ~target v1 v2;
    target
  in
  (f', f)

let (add', add) = make_two_vec_op add

let (sub', sub) = make_two_vec_op sub

let (mul', mul) = make_two_vec_op mul

let (div', div) = make_two_vec_op div

let (cross', cross) = make_two_vec_op cross

let make_one_vec_one_float_op op =
  let f' ~(target : t) (v : t) (x : float) : unit =
    let (_ : t) = op target v x in
    ()
  in

  let f (v : t) (x : float) : t =
    let target : t = allocate_raw () in
    f' ~target v x;
    target
  in
  (f', f)

let (mulf', mulf) = make_one_vec_one_float_op mulf

let (divf', divf) = make_one_vec_one_float_op divf

let (rotate_2d', rotate_2d) = make_one_vec_one_float_op rotate_2d

let make_two_vec_one_float_op op =
  let f' ~(target : t) (v1 : t) (v2 : t) (x : float) : unit =
    let (_ : t) = op target v1 v2 x in
    ()
  in

  let f (v1 : t) (v2 : t) (x : float) : t =
    let target : t = allocate_raw () in
    f' ~target v1 v2 x;
    target
  in
  (f', f)

let (lerp', lerp) = make_two_vec_one_float_op lerp

let move_x (v : t) (delta : float) : unit = set_x v (get_x v +. delta)

let move_y (v : t) (delta : float) : unit = set_y v (get_y v +. delta)

let move_z (v : t) (delta : float) : unit = set_z v (get_z v +. delta)

let of_rotation (rotation : float) : t =
  let x = cos rotation in
  let y = sin rotation in
  make ~x ~y ~z:0.0

let to_rotation (v : t) : float = Float.atan2 (get_y v) (get_x v)

(* For internal use *)

(* Wrapper for functions which return a vector property. *)
(* Orx uses the return value to indicate if the get was a success or not. *)
let get_optional_vector get o =
  let v = allocate_raw () in
  match get o v with
  | None -> None
  | Some _v -> Some v

let get_vector_exn get o =
  match get_optional_vector get o with
  | None -> fail "Failed to set vector"
  | Some v -> v

let get_vector get o =
  let v = allocate_raw () in
  let (_ : t) = get o v in
  v
