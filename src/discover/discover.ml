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
    let header_basename = Filename.basename header in
    let header_path = Filename.dirname header in
    let c_flags = [ "-I"; header_path ] in
    let includes = [ header_basename ] in
    let platform =
      C.C_define.import c ~c_flags ~includes [ ("PLATFORM_NAME", String) ]
    in
    match platform with
    | [ (_, String "linux") ] -> Linux
    | [ (_, String "mac") ] -> Macos
    | [ (_, String "windows") ] -> Windows
    | _ -> failwith "Unsupported platform or operating system"
end

module Orx_info = struct
  let get_env () =
    match Sys.getenv_opt "ORX" with
    | Some orx -> orx
    | None -> C.die "The ORX environment variable must be set."

  type lib = {
    variant : string;
    basename : string;
    path : string;
  }

  let make_lib variant path =
    { variant; path; basename = Filename.basename path }

  let get_lib configurator lib_dir =
    let platform = Platform.detect configurator in
    let (prefix, extension) =
      match platform with
      | Linux -> ("lib", "so")
      | Macos -> ("lib", "dylib")
      | Windows -> ("", "dll")
    in
    (* Find debug, profile or release version of the orx library *)
    let variants = [ "orxd"; "orxp"; "orx" ] in
    let path v = lib_dir /+ Printf.sprintf "%s%s.%s" prefix v extension in
    let paths = List.map (fun v -> make_lib v (path v)) variants in
    match List.find_opt (fun lib -> Sys.file_exists lib.path) paths with
    | None -> C.die "The orx library was not found under %s" lib_dir
    | Some lib -> lib
end

module Orx_lib_staging = struct
  let lib_target_dirs =
    (* Several levels of directory to go up before we get to the source tree *)
    let dots = String.concat Filename.dir_sep [ ".."; ".."; ".."; ".." ] in
    List.map
      (fun parts -> List.fold_left Filename.concat dots parts)
      [
        [ "examples"; "tutorial" ];
        [ "examples"; "ocaml"; "top_down_movement"; "src" ];
        [ "examples"; "wiki"; "beginners_guide" ];
      ]

  let read_file path =
    let ic = open_in_bin path in
    let len = in_channel_length ic in
    let content = really_input_string ic len in
    close_in ic;
    content

  let write_file path ~data =
    let oc = open_out_bin path in
    output_string oc data;
    close_out oc

  let stage_orx_lib (lib : Orx_info.lib) =
    let lib_content = read_file lib.path in
    let targets = List.map (fun path -> path /+ lib.basename) lib_target_dirs in
    List.iter (fun target -> write_file target ~data:lib_content) targets
end

let add_cclib (flags : string list) : string list =
  List.map (fun flag -> [ "-cclib"; flag ]) flags |> List.flatten

let () =
  C.main ~name:"orx" (fun c ->
      let orx_dir = Orx_info.get_env () in
      let platform = Platform.detect c in
      let orx_c_link_dir = orx_dir /+ "lib" /+ "dynamic" in
      let orx_c_library = Orx_info.get_lib c orx_c_link_dir in
      Orx_lib_staging.stage_orx_lib orx_c_library;
      let orx_c_link_libs =
        let lorx = Printf.sprintf "-l%s" orx_c_library.variant in
        match platform with
        | Linux -> [ lorx; "-ldl"; "-lm"; "-lrt" ]
        | Macos -> [ lorx; "-ldl"; "-lm" ]
        | Windows -> [ lorx; "-lm" ]
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
      C.Flags.write_lines "orx-c-library.txt" [ orx_c_library.basename ];
      C.Flags.write_lines "orx-c-library-location.txt" [ orx_c_library.path ];
      C.Flags.write_sexp "orx-c-include-flags.sexp" [ orx_c_include_dir ];
      C.Flags.write_sexp "orx-c-link-flags.sexp" orx_c_link_flags;
      C.Flags.write_sexp "orx-ocaml-link-flags.sexp"
        (add_cclib orx_ocaml_link_flags)
  )
