# ocaml-orx - OCaml bindings to the Orx game library

[Orx] is "an open source, portable, lightweight, plugin-based, data-driven and
extremely easy to use 2D-oriented game engine."  Orx itself is written in C.

This repository provides bindings to use Orx from OCaml. The
sound, graphics, physics, input handling and more can be handled by Orx in C,
with the game logic written in OCaml.

These bindings are licensed under the [MIT license](LICENSE.md).

## Requirements

### Orx
You will need a working build of Orx. The official [beginner's guide][guide] has
instructions for installing Orx and its dependencies on your system. Make sure
the `$ORX` environment variable is defined in your environment as ocaml-orx uses
that to know where the Orx shared library and C headers are.

### OCaml libraries and tools
To compile orx-ocaml you will need the following, all available from [opam]:
* dune
* ctypes and ctypes-foreign
* fmt

Once those are installed, you can `dune build` to build the library,
`dune utop src` to explore the bindings from a REPL if you have [utop]
installed, or `dune exec examples/wiki/beginners_guide/beginners_guide.exe`
to try a (slightly modified) port of the Orx beginner's guide tutorial.

## Examples
The [beginner's guide][guide] project has been ported to OCaml in
[this example](examples/wiki/beginners_guide/beginners_guide.ml).

Some of the [tutorials][tutorials] have been ported [as well](examples/tutorial/).

You run run [run.sh](run.sh) to compile and execute the beginner's guide port
(only tested on Linux so far).

## About the bindings
The low level bindings are generated using [ctypes] stub generation and are
based on the structure used in [ocaml-yaml].

[Orx]: https://orx-project.org
[ctypes]: https://github.com/ocamllabs/ocaml-ctypes
[ocaml-yaml]: https://github.com/avsm/ocaml-yaml
[guide]: https://orx-project.org/wiki/en/guides/beginners/main
[tutorials]: https://github.com/orx/orx/tree/master/tutorial/src
[opam]: https://opam.ocaml.org
[utop]: https://opam.ocaml.org/packages/utop/
