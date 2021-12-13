include Orx_gen.Resource

let add_storage group storage first =
  add_storage (string_of_group group) storage first

let remove_storage group storage =
  remove_storage (Option.map string_of_group group) storage

let sync group = sync (Option.map string_of_group group)
