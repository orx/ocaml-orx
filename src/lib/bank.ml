include Orx_gen.Bank

let rec to_list
    (b : t)
    (cell : unit Ctypes.ptr option)
    (ptrs : unit Ctypes.ptr list) =
  match get_next b cell with
  | None -> List.rev ptrs
  | Some ptr as next_cell -> to_list b next_cell (ptr :: ptrs)

let to_list (b : t) : unit Ctypes.ptr list = to_list b None []
