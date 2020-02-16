let prefix = "orx_stub"

let prologue =
  {|
#include <orx.h>

orxSTATUS ml_orx_event_add_handler(orxEVENT_TYPE event_type, orxEVENT_HANDLER event_handler, orxU32 add_id_flags, orxU32 remove_id_flags) {
  orxSTATUS result = orxSTATUS_SUCCESS;
  result = orxEvent_AddHandler(event_type, event_handler);
  if (result == orxSTATUS_SUCCESS) {
    result = orxEvent_SetHandlerIDFlags(event_handler, event_type, NULL, add_id_flags, remove_id_flags);
  }
  return result;
}

orxSTATUS ml_orx_thread_start(void *_context) {
  caml_c_thread_register();
  return orxSTATUS_SUCCESS;
}

void ml_orx_thread_stop(void *_context) {
  caml_c_thread_unregister();
  return orxSTATUS_SUCCESS;
}

void ml_orx_thread_set_callbacks() {
  orxThread_SetCallbacks(&ml_orx_thread_start, &ml_orx_thread_stop, NULL);
  return;
}

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
      "stubgen [-ml|-c]");

  (* OCaml/C concurrency model to use in the generated stubs *)
  let concurrency = Cstubs.sequential in
  match (!generate_ml, !generate_c) with
  | (false, false) | (true, true) ->
    failwith "Exactly one of -ml, -c, -t must be specified"
  | (true, false) ->
    Cstubs.write_ml ~concurrency Format.std_formatter ~prefix
      (module Orx_bindings.Bindings)
  | (false, true) ->
    print_endline prologue;
    Cstubs.write_c ~concurrency Format.std_formatter ~prefix
      (module Orx_bindings.Bindings)
