include Orx_gen.Input_event

let map_to_ocaml_array f carray =
  let len = Ctypes.CArray.length carray in
  Array.init len (fun i -> f (Ctypes.CArray.get carray i))

let map_one i f get_field payload =
  let all = get_field payload in
  f (Ctypes.CArray.get all i)

let make_getters get_field to_ocaml =
  ( (fun payload -> map_to_ocaml_array to_ocaml (get_field payload)),
    fun ?(i = 0) payload -> map_one i to_ocaml get_field payload
  )

let (get_input_types, get_input_type) = make_getters get_input_type Fun.id

let (get_input_ids, get_input_id) =
  make_getters get_input_id Unsigned.UInt.to_int

let (get_input_modes, get_input_mode) = make_getters get_input_mode Fun.id

let (get_input_values, get_input_value) = make_getters get_input_value Fun.id
