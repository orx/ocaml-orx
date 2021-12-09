open Direct_bindings

let init_function = Ctypes.(void @-> returning Orx_gen.Status.t)
module Init_function = (val Foreign.dynamic_funptr init_function)

let run_function = Ctypes.(void @-> returning Orx_gen.Status.t)
module Run_function = (val Foreign.dynamic_funptr run_function)

let exit_function = Ctypes.(void @-> returning void)
module Exit_function = (val Foreign.dynamic_funptr exit_function)

(* This is wrapped differently because the underlying orx function is *)
(* inlined in orx.h *)
let execute_c =
  Ctypes.(
    Foreign.foreign "ml_orx_execute"
      (int
      @-> ptr string
      @-> Init_function.t
      @-> Run_function.t
      @-> Exit_function.t
      @-> returning void
      )
  )

let execute ~init ~run ~exit () =
  (* Start the orx main loop *)
  let empty_argv = Ctypes.from_voidp Ctypes.string Ctypes.null in
  Init_function.with_fun init @@ fun init_ptr ->
  Run_function.with_fun run @@ fun run_ptr ->
  Exit_function.with_fun exit @@ fun exit_ptr ->
  Fun.protect
    ~finally:(fun () -> Config.free_bootstrap ())
    (fun () -> execute_c 0 empty_argv init_ptr run_ptr exit_ptr)

let start ?config_dir ?exit ~init ~run name =
  let bootstrap () =
    match config_dir with
    | None -> Status.ok
    | Some dir -> Resource.add_storage Config dir false
  in
  Config.set_bootstrap bootstrap;
  Fun.protect
    ~finally:(fun () -> Config.free_bootstrap ())
    (fun () ->
      Config.set_basename name;
      let exit = Option.value exit ~default:(fun () -> ()) in
      execute ~init ~run ~exit ()
    )
