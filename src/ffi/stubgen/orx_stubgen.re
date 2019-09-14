let prefix = "orx_stub";

let prologue = {|
#include <orx.h>

orxSTATUS ml_orx_thread_pre() {
  caml_c_thread_register();
  return orxSTATUS_SUCCESS;
}

void ml_orx_thread_post() {
  caml_c_thread_unregister();
  return orxSTATUS_SUCCESS;
}

void ml_orx_thread_set_prepost() {
  orxThread_SetPrePost(&ml_orx_thread_pre, &ml_orx_thread_post, NULL);
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
|};

let () = {
  let (generate_ml, generate_c) = (ref(false), ref(false));
  Arg.(
    parse(
      [
        ("-ml", Set(generate_ml), "Generate ML"),
        ("-c", Set(generate_c), "Generate C (bindings)"),
      ],
      _ => failwith("unexpected anonymous argument"),
      "stubgen [-ml|-c]",
    )
  );
  switch (generate_ml^, generate_c^) {
  | (false, false)
  | (true, true) => failwith("Exactly one of -ml, -c, -t must be specified")
  | (true, false) =>
    Cstubs.write_ml(
      Format.std_formatter,
      ~prefix,
      (module Orx_bindings.Bindings),
    )
  | (false, true) =>
    print_endline(prologue);
    Cstubs.write_c(
      Format.std_formatter,
      ~prefix,
      (module Orx_bindings.Bindings),
    );
  };
};