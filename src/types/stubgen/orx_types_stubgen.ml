let prefix = "orx_stub"

let prologue = {|
#include <orx.h>
|}

let () =
  print_endline prologue;
  Cstubs.Types.write_c Format.std_formatter (module Orx_types_bindings.Bindings)
