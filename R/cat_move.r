#' View game in command-line terminal
#'
#' `cat_move()` prints a plaintext diagram of a single move to the terminal.
#' `cat_game()` prints a plaintext "animation" of every move to the terminal.
#'
#' @param game A list containing a parsed ppn game (as parsed by [read_ppn()])
#' @param move Which move to cat game state (after the move, will use `game$dfs[[move]]`)
#'             unless \code{NULL} in which case will print the game state after the last move.
#' @param ... Passed to [ppcli::cat_piece()].
#' @export
cat_move <- function(game, move = NULL, ...) {
    assert_suggested("ppcli")
    df <- get_df_from_move(game, move)
    ppcli::cat_piece(df, ...)
}

get_df_offsets <- function(df, lr, xoffset, yoffset, annotate = FALSE) {
    if (!(isFALSE(annotate) || annotate == "none")) {
        xlbound <- ifelse(lr$ymax >= 10, 1.0, 0.5)
        ylbound <- 0.5
    } else {
        xlbound <- 0
        ylbound <- 0
    }
    if (is.null(xoffset)) xoffset <- min2offset(lr$xmin, xlbound)
    if (is.null(yoffset)) yoffset <- min2offset(lr$ymin, ylbound)
    list(x = xoffset, y = yoffset)
}

#' @rdname cat_move
#' @param fps Frames per second.
#' @export
cat_game <- function(game, ..., fps = 1) {
    assert_suggested("ppcli")
    offset <- get_game_offsets(game, ...)
    for (ii in seq_along(game$dfs)) {
        prev <- system.time({
            out <- ppcli::cat_piece(game$dfs[[ii]], ..., xoffset=offset$x, yoffset=offset$y, file=NULL)
        })[["elapsed"]]
        dur <- ifelse(1/fps - prev > 0, 1/fps - prev, 0)
        Sys.sleep(dur)
        clear_screen()
        cat(out)
    }
}

clear_screen <- function() {
    switch(.Platform$OS.type,
           unix = system("clear"),
           windows = system("cls"))
}

get_game_offsets <- function(game, annotate = FALSE, ...) {
    ranges <- lapply(game$dfs, ppcli:::range_heuristic)
    ymax <- max(sapply(ranges, function(x) x$ymax), na.rm = TRUE)
    ymin <- min(sapply(ranges, function(x) x$ymin), na.rm = TRUE)
    xmin <- min(sapply(ranges, function(x) x$xmin), na.rm = TRUE)
    if (!(isFALSE(annotate) || annotate == "none")) {
        xoffset <- min2offset(xmin, ifelse(ymax >= 10, 1.0, 0.5))
        yoffset <- min2offset(ymin, 0.5)
    } else {
        xoffset <- min2offset(xmin, 0)
        yoffset <- min2offset(ymin, 0)
    }
    list(x = xoffset, y = yoffset)
}

get_df_from_move <- function(game, move = NULL) {
    if (is.null(move)) {
        utils::tail(game$dfs, 1)[[1]]
    } else {
        game$dfs[[move]]
    }
}

min2offset <- function(min, lbound = 0.5) {
    if (is.na(min)) {
        NA_real_
    } else if (min < lbound) {
        lbound - min
    } else {
        0
    }
}
