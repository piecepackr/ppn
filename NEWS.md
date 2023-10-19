ppn 0.1.0
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
