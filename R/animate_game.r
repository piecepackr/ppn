#' Animate a ppn game
#'
#' Animate a ppn game
#' @param game A list containing a parsed ppn game (as parsed by [read_ppn()])
#' @param ... Passed to [piecepackr::animate_piece()]
#' @inheritParams piecepackr::animate_piece
#' @seealso [piecepackr::animate_piece()]
#' @return Nothing, as a side effect saves an animation of ppn game
#' @examples
#'   game_file <- system.file("ppn/tic-tac-toe.ppn", package = "ppn")
#'   game <- read_ppn(game_file)[[1]]
#'   if (require("gifski")) {
#'     animate_game(game, file = "tic-tac-toe.gif")
#'     unlink("tic-tac-toe.gif")
#'   }
#' @export
animate_game <- function(game, file = "animation.gif", annotate = TRUE, ...,
                         .f = piecepackr::grid.piece, cfg = NULL, envir = NULL,
                         n_transitions = 0L, n_pauses = 1L, fps = n_transitions + n_pauses,
                         width = NULL, height = NULL, ppi = NULL,
                         annotation_scale = NULL) {
    assert_suggested("piecepackr")
    piecepackr::animate_piece(
        game$dfs, file = file, annotate = annotate, ...,
        .f = .f, cfg = cfg, envir = envir, n_transitions = n_transitions,
        n_pauses = n_pauses, fps = fps, width = width, height = height,
        ppi = ppi, annotation_scale = annotation_scale
    )
}
