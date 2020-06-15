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
      let orx_c_link_libs =
        if Sys.win32 then
          [ "-lorxd"; "-lm" ]
        else
          [ "-lorxd"; "-ldl"; "-lm"; "-lrt" ]
      in
      let orx_c_link_flags = orx_c_link_dir :: orx_c_link_libs in
      let orx_c_include_dir = "-I" ^ (orx_dir /+ "include") in
      let orx_ocaml_link_flags =
        if Sys.win32 then
          "-link" :: "-Wl,--export-all-symbols" :: orx_c_link_flags
        else
          orx_c_link_flags
      in
      C.Flags.write_lines "orx-c-include-flags.txt" [ orx_c_include_dir ];
      C.Flags.write_lines "orx-c-link-flags.txt" orx_c_link_flags;
      C.Flags.write_sexp "orx-c-include-flags.sexp" [ orx_c_include_dir ];
      C.Flags.write_sexp "orx-c-link-flags.sexp" orx_c_link_flags;
      C.Flags.write_sexp "orx-ocaml-link-flags.sexp"
        (add_cclib orx_ocaml_link_flags))
