include Orx_gen.Body

let get_parts (body : t) : Body_part.t Seq.t =
  let rec iter prev_part () =
    match get_next_part body prev_part with
    | None -> Seq.Nil
    | Some next as part -> Seq.Cons (next, iter part)
  in
  iter None
