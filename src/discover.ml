module C = Configurator.V1

let ( /+ ) = Filename.concat

module Platform = struct
  type t =
    | Linux
    | Macos
    | Windows

  (* OS detection logic based on Revery's:
     https://github.com/revery-ui/revery/blob/master/src/Native/config/discover.re *)
  let detect_header =
    {|
#if __APPLE__
  #define PLATFORM_NAME "mac"
#elif __linux__
  #define PLATFORM_NAME "linux"
#elif WIN32
  #define PLATFORM_NAME "windows"
#endif
|}

  let detect c =
    let header =
      let file = Filename.temp_file "discover" "os.h" in
      let fd = open_out file in
      output_string fd detect_header;
      close_out fd;
      file
    in
    let platform =
      C.C_define.import c ~includes:[ header ] [ ("PLATFORM_NAME", String) ]
    in
    match platform with
    | [ (_, String "linux") ] -> Linux
    | [ (_, String "mac") ] -> Macos
    | [ (_, String "windows") ] -> Windows
    | _ -> failwith "Unsupported platform or operating system"
end

let orx_env () =
  match Sys.getenv_opt "ORX" with
  | Some orx -> orx
  | None -> C.die "The ORX environment variable must be set."

let add_cclib (flags : string list) : string list =
  List.map (fun flag -> [ "-cclib"; flag ]) flags |> List.flatten

let () =
  C.main ~name:"orx" (fun c ->
      let orx_dir = orx_env () in
      let platform = Platform.detect c in
      let orx_c_link_dir = orx_dir /+ "lib" /+ "dynamic" in
      let orx_c_link_libs =
        match platform with
        | Linux -> [ "-lorxd"; "-ldl"; "-lm"; "-lrt" ]
        | Macos -> [ "-rpath"; orx_c_link_dir; "-lorxd"; "-ldl"; "-lm" ]
        | Windows -> [ "-lorxd"; "-lm" ]
      in

      let orx_c_link_flags = ("-L" ^ orx_c_link_dir) :: orx_c_link_libs in
      let orx_c_include_dir = "-I" ^ (orx_dir /+ "include") in
      let orx_ocaml_link_flags =
        match platform with
        | Linux | Macos -> orx_c_link_flags
        | Windows -> "-link" :: "-Wl,--export-all-symbols" :: orx_c_link_flags
      in
      C.Flags.write_lines "orx-c-include-flags.txt" [ orx_c_include_dir ];
      C.Flags.write_lines "orx-c-link-flags.txt" orx_c_link_flags;
      C.Flags.write_sexp "orx-c-include-flags.sexp" [ orx_c_include_dir ];
      C.Flags.write_sexp "orx-c-link-flags.sexp" orx_c_link_flags;
      C.Flags.write_sexp "orx-ocaml-link-flags.sexp"
        (add_cclib orx_ocaml_link_flags)
  )
