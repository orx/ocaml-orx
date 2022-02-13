let global_section = "Runtime"

let get_object name =
  Orx.Config.get Orx.Config.get_guid ~section:global_section ~key:name
  |> Orx.Object.of_guid_exn
