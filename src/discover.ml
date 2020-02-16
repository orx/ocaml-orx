module C = Configurator.V1

let ( /+ ) = Filename.concat

let orx_env () =
  match Sys.getenv_opt "ORX" with
  | Some orx -> orx
  | None -> C.die "The ORX environment variable must be set."

let add_cclib (flags : string list) : string list =
  List.map (fun flag -> [ "-cclib"; flag ]) flags |> List.flatten

let () =
  C.main ~name:"orx" (fun _c ->
      let orx_dir = orx_env () in
      let orx_c_link_dir = "-L" ^ (orx_dir /+ "lib" /+ "dynamic") in
      let orx_c_link_libs = [ "-lorxd"; "-ldl"; "-lm"; "-lrt" ] in
      let orx_c_flags = orx_c_link_dir :: orx_c_link_libs in
      let orx_c_include_dir = "-I" ^ (orx_dir /+ "include") in
      C.Flags.write_lines "orx-c-include-flags.txt" [ orx_c_include_dir ];
      C.Flags.write_lines "orx-c-link-flags.txt" orx_c_flags;
      C.Flags.write_sexp "orx-c-include-flags.sexp" [ orx_c_include_dir ];
      C.Flags.write_sexp "orx-c-link-flags.sexp" orx_c_flags;
      C.Flags.write_sexp "orx-ocaml-link-flags.sexp" (add_cclib orx_c_flags))
