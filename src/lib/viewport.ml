open Common
open Direct_bindings

include Orx_gen.Viewport

let of_structure (s : Structure.t) : t option =
  of_void_pointer (Structure.to_void_pointer s)

let create_from_config_exn = create_exn create_from_config "viewport"

let get_shader_exn ?(index = 0) v =
  match get_shader_pointer v with
  | None ->
    Fmt.invalid_arg "No shader pointer associated with viewport %s" (get_name v)
  | Some pointer ->
    ( match Orx_gen.Shader_pointer.get_shader pointer index with
    | None ->
      Fmt.invalid_arg "No shader %d associated with viewport %s" index
        (get_name v)
    | Some shader -> shader
    )

let get_exn name =
  match get name with
  | None -> Fmt.invalid_arg "No viewport %s available" name
  | Some viewport -> viewport
