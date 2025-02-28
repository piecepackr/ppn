ppn 0.2.0 (development)
=======================

Deprecated features
-------------------

* Custom movetext parsers should now be of the form `name_parser()`
  instead of `parser_name()`.

New features
------------

* We now export (and document their arguments) the following movetext parsers

  + `alquerque_parser()`
  + `default_parser()`
  + `marble_parser()`

Bug fixes and minor improvements
--------------------------------

* The following tweaks to PPN:

  + If a `PieceSpec` is missing `Piece` and is a colored suit
    and it's side is not l, r, or x then it is now assumed to
    be a "bit" (instead of a "tile").
  + If a "marbles" "bit" is missing its rank assume that
    its rank is `9L` (i.e. 1" marble).

ppn 0.1.1
=========

Functions for reading/writing Portable Piecepack Notation (PPN) files:

* `read_ppn()` parses Portable Piecepack Notation (PPN) files.
* `write_ppn()` writes Portable Piecepack Notation files.

Functions for visualizing moves in a parsed game:

* `plot_move()` visualizes moves in a parsed game via `piecepackr::render_piece()`.
* `animate_game()` visualizes moves in a parsed game via `piecepackr::animate_game()`.
* `cat_move()` and `cat_game()` visualizes moves in a parsed game via `ppcli::cat_piece()`.

Interactive PPN viewers:

* `view_game()` provides interactive PPN viewers with a choice of a `{shiny}` app and a `{cli}` command-line interface.
