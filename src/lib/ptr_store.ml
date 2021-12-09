module type S = sig
  type ptr
  type handle
  val default_handle : handle
  val make_handle : unit -> handle
  val retain : handle -> ptr -> unit
  val release : handle -> (ptr -> Orx_gen.Status.t) -> unit
  val release_all : (ptr -> Orx_gen.Status.t) -> unit
end

module Make (Ptr : Foreign.Funptr) = struct
  type handle = int
  let next_handle : handle ref = ref 0
  let make_handle () =
    let v = !next_handle in
    incr next_handle;
    v
  let default_handle = make_handle ()
  let store : (handle, Ptr.t) Hashtbl.t = Hashtbl.create 16
  let retain handle v = Hashtbl.add store handle v
  let rec release handle (free : Ptr.t -> Orx_gen.Status.t) =
    match Hashtbl.find_opt store handle with
    | None -> ()
    | Some ptr ->
      Hashtbl.remove store handle;
      free ptr |> Orx_gen.Status.ignore;
      Ptr.free ptr;
      release handle free
  let release_all (free : Ptr.t -> Orx_gen.Status.t) =
    let ptrs = Hashtbl.to_seq_values store in
    Seq.iter
      (fun ptr ->
        free ptr |> Orx_gen.Status.ignore;
        Ptr.free ptr
      )
      ptrs;
    Hashtbl.reset store
end
