test_that("view_game works as expected", {
    do.call(rlang::local_options, default_options())

    g <- list(metadata = NULL, movetext = character())
    g <- append_to_ppn(g, "1. S@b2")
    expect_equal(nrow(g$dfs[["1."]]), 1)

    ppn <- read_ppn(system.file("ppn/tic-tac-toe.ppn", package = "ppn"))
    game <- ppn[[1]]

    tmp <- tempfile(fileext = ".ppn")
    write_ppn(list(game), file = tmp)
    game2 <- read_ppn(tmp)[[1]]
    expect_equal(game$moves, game2$moves)
    expect_snapshot(write_ppn(list(game2), ""))
    unlink(tmp)

    move <- tail(names(game$moves), 1)
    prev <- prev_move(game, move)
    expect_equal(move, "4.")
    expect_equal(prev, "3...")
    expect_equal(next_move(game, prev), "4.")

    skip_on_os("windows")
    expect_snapshot(print_screen(game, move, clear = FALSE, color = FALSE))

    skip_if_not_installed("argparse")
    p <- get_parser()
    expect_snapshot(p$print_help())
})
