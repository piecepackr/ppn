#' Plot game move
#'
#' Plot game move
#' @inheritParams animate_game
#' @param ... Passed to [piecepackr::render_piece()]
#' @param move Which move to plot game state (after the move, will use `game$dfs[[move]]`)
#'             unless `NULL` in which case will plot the game state after the last move.
#' @param bg Background color (`"transparent"` for transparent)
#' @return An invisible list of the dimensions of the image, as a side effect saves a graphic
#' @import grDevices
#' @export
plot_move <- function(game, file = NULL,  move = NULL, annotate = TRUE, ...,
                      .f = piecepackr::grid.piece, cfg = NULL, envir = NULL,
                      width = NULL, height = NULL, ppi = 72,
                      bg = "white", annotation_scale = NULL) {
    assert_suggested("piecepackr")
    df <- get_df_from_move(game, move)
    piecepackr::render_piece(
        df, file = file, ...,
        .f = .f, cfg = cfg, envir = envir,
        width = width, height = height, ppi = ppi, bg = bg,
        annotate = annotate, annotation_scale = NULL
    )
}
