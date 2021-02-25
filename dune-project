(lang dune 2.0)

(name orx)

(license MIT)

(maintainers "Hezekiah M. Carty <hez@0ok.org>")

(authors "Hezekiah M. Carty <hez@0ok.org>")

(source
 (github orx/ocaml-orx))

(generate_opam_files true)

(package
 (name orx)
 (synopsis "OCaml interface to the Orx game engine")
 (depends
  (ctypes (>= 0.18.0))
  ctypes-foreign
  (dune
   (>= 2.8.2))
  dune-configurator
  fmt
  (ocaml
   (>= 4.08.0))))
