type 'a format_logger =
  ('a, Format.formatter, unit, unit, unit, unit) format6 -> 'a

let log fmt = Fmt.kstr Orx_gen.Log.log fmt
let terminal fmt = Fmt.kstr Orx_gen.Log.terminal fmt
let file fmt = Fmt.kstr Orx_gen.Log.file fmt
let console fmt = Fmt.kstr Orx_gen.Log.console fmt
