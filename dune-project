(lang dune 1.11)
(using fmt 1.2)
(name orx)

(license MIT)
(maintainers "Hezekiah M. Carty <hez@0ok.org>")
(authors "Hezekiah M. Carty <hez@0ok.org>")

(source (github orx/ocaml-orx))

(generate_opam_files true)

(package
 (name orx)
 (synopsis "OCaml interface to the Orx game engine")
 (depends
  ctypes
  ctypes-foreign
  (dune (>= 1.11))
  fmt
  (ocaml (>= 4.08.0))))