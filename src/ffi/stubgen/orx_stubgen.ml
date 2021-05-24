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

#define ML_ORX_COMMAND_VAR_SET(FIELD_TYPE, NAME, FIELD) \
static orxINLINE void ml_orx_command_var_set_##NAME(orxCOMMAND_VAR *v, FIELD_TYPE vv) { \
  v->FIELD = vv; \
}
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

/* Event handlers */

orxSTATUS ml_orx_event_add_handler(orxEVENT_TYPE event_type, orxEVENT_HANDLER event_handler, orxU32 add_id_flags, orxU32 remove_id_flags) {
  orxSTATUS result = orxSTATUS_SUCCESS;
  result = orxEvent_AddHandler(event_type, event_handler);
  if (result == orxSTATUS_SUCCESS) {
    result = orxEvent_SetHandlerIDFlags(event_handler, event_type, NULL, add_id_flags, remove_id_flags);
  }
  return result;
}

/* Threads */

orxSTATUS ml_orx_thread_start(void *_context) {
  int status = 0;
  status = caml_c_thread_register();
  return (status ? orxSTATUS_SUCCESS : orxSTATUS_FAILURE);
}

orxSTATUS ml_orx_thread_stop(void *_context) {
  int status = 0;
  status = caml_c_thread_unregister();
  return (status ? orxSTATUS_SUCCESS : orxSTATUS_FAILURE);
}

void ml_orx_thread_set_callbacks() {
  orxThread_SetCallbacks(&ml_orx_thread_start, &ml_orx_thread_stop, NULL);
  return;
}

/* Main engine entrypoint */

void ml_orx_execute(int argc, char **argv,
                    orxMODULE_INIT_FUNCTION init,
                    orxMODULE_RUN_FUNCTION run,
                    orxMODULE_EXIT_FUNCTION exit) {
    orx_Execute(argc,
                argv,
                init,
                run,
                exit);
    return;
}
|}

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

  (* OCaml/C concurrency model to use in the generated stubs *)
  match (!generate_ml, !generate_c) with
  | (false, false) | (true, true) ->
    failwith "Exactly one of -ml, -c must be specified"
  | (true, false) ->
    Cstubs.write_ml Format.std_formatter ~prefix (module Orx_bindings.Bindings)
  | (false, true) ->
    print_endline prologue;
    Cstubs.write_c Format.std_formatter ~prefix (module Orx_bindings.Bindings)
