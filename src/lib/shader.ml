include Orx_gen.Shader

let set_float_param_exn shader name value =
  let argument = Ctypes.(allocate float value) in
  match set_float_param shader name 0 argument with
  | Error `Orx ->
    Fmt.invalid_arg "Unable to set parameter %s to %g in shader %s" name value
      (get_name shader)
  | Ok () -> ()

let set_vector_param_exn shader name value =
  match set_vector_param shader name 0 value with
  | Error `Orx ->
    Fmt.invalid_arg "Unable to set parameter %s to %a in shader %s" name
      Vector.pp value (get_name shader)
  | Ok () -> ()
