include Orx_gen.Shader_event

let set_param_float payload v =
  if get_param_type payload <> Float then
    Fmt.invalid_arg "Shader param %s is not of type float"
      (get_param_name payload);
  set_param_float payload v

let set_param_vector payload v =
  if get_param_type payload <> Vector then
    Fmt.invalid_arg "Shader param %s is not of type vector"
      (get_param_name payload);
  set_param_vector payload v
