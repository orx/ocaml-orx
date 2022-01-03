let prefix = "orx_stub"

let prologue =
  {|
#include <orx.h>

/* Commands */

static orxINLINE orxCOMMAND_VAR_TYPE ml_orx_command_var_get_type(orxCOMMAND_VAR *v) {
  return v->eType;
}

static orxINLINE void ml_orx_command_var_set_type(orxCOMMAND_VAR *v, orxCOMMAND_VAR_TYPE t) {
  v->eType = t;
}

#define ML_ORX_COMMAND_VAR_GET(FIELD_TYPE, NAME, FIELD) \
static orxINLINE FIELD_TYPE ml_orx_command_var_get_##NAME(orxCOMMAND_VAR *v) { \
  return v->FIELD; \
}
ML_ORX_COMMAND_VAR_GET(orxVECTOR, vector, vValue)
ML_ORX_COMMAND_VAR_GET(orxSTRING, string, zValue)
ML_ORX_COMMAND_VAR_GET(orxS64, int, s64Value)
ML_ORX_COMMAND_VAR_GET(orxFLOAT, float, fValue)
ML_ORX_COMMAND_VAR_GET(orxBOOL, bool, bValue)
ML_ORX_COMMAND_VAR_GET(orxU64, guid, u64Value)

#define ML_ORX_COMMAND_VAR_SET(FIELD_TYPE, NAME, FIELD) static orxINLINE void ml_orx_command_var_set_##NAME(orxCOMMAND_VAR *v, FIELD_TYPE vv) { v->FIELD = vv; }
ML_ORX_COMMAND_VAR_SET(orxVECTOR, vector, vValue)
ML_ORX_COMMAND_VAR_SET(orxSTRING, string, zValue)
ML_ORX_COMMAND_VAR_SET(orxS64, int, s64Value)
ML_ORX_COMMAND_VAR_SET(orxFLOAT, float, fValue)
ML_ORX_COMMAND_VAR_SET(orxBOOL, bool, bValue)
ML_ORX_COMMAND_VAR_SET(orxU64, guid, u64Value)

/* Shader events */

static orxINLINE void ml_orx_shader_param_set_float(orxSHADER_EVENT_PAYLOAD *payload, orxFLOAT v) {
  orxASSERT(payload->eParamType == orxSHADER_PARAM_TYPE_FLOAT);
  payload->fValue = v;
}

static orxINLINE void ml_orx_shader_param_set_vector(orxSHADER_EVENT_PAYLOAD *payload, orxVECTOR *v) {
  orxASSERT(payload->eParamType == orxSHADER_PARAM_TYPE_VECTOR);
  orxVector_Copy(&(payload->vValue), v);
}
|}

let prologue = String.split_on_char '\n' prologue |> List.map String.trim

let () =
  let (generate_ml, generate_c) = (ref false, ref false) in
  Arg.(
    parse
      [
        ("-ml", Set generate_ml, "Generate ML");
        ("-c", Set generate_c, "Generate C (bindings)");
      ]
      (fun _ -> failwith "unexpected anonymous argument")
      "stubgen [-ml|-c]"
  );

  match (!generate_ml, !generate_c) with
  | (false, false) | (true, true) ->
    failwith "Exactly one of -ml, -c must be specified"
  | (true, false) ->
    Cstubs.write_ml Format.std_formatter ~prefix (module Orx_bindings.Bindings)
  | (false, true) ->
    List.iter print_endline prologue;
    Cstubs.write_c Format.std_formatter ~prefix (module Orx_bindings.Bindings)
