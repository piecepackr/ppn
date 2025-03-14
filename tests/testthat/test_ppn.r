library("dplyr", warn.conflicts = FALSE)
sf_read_ppn <- function(f) {
    read_ppn(system.file(paste0("ppn/", f, ".ppn"), package = "ppn"))[[1]]
}
sf_verify <- function(game_var, ...) {
    game_name <- gsub("_", "-", as.character(substitute(game_var)))
    expect_snapshot({
        cat(game_name, "\n")
        cat_move(game_var, ..., color = FALSE)
    })
}
test_that("parsing ppn files works as expected", {
    do.call(rlang::local_options, default_options())
    skip_on_os("windows")

    # stored in inst/ppn
    alien_city <- sf_read_ppn("alien-city")
    sf_verify(alien_city, reorient = "symbols")

    checkers <- sf_read_ppn("american-checkers")
    sf_verify(checkers)

    desfases <- sf_read_ppn("desfases")
    sf_verify(desfases, reorient = "symbols")

    four_field_kono <- sf_read_ppn("four-field-kono")
    sf_verify(four_field_kono, annotate=TRUE)

    # fujisan's PPN effectively tested in test_fujisan.R

    ice_floe <- sf_read_ppn("ice-floe")
    sf_verify(ice_floe)

    chess <- sf_read_ppn("international-chess")
    sf_verify(chess)

    japan <- sf_read_ppn("japan")
    sf_verify(japan)

    plans_of_action <- sf_read_ppn("plans-of-action")
    sf_verify(plans_of_action, reorient = "symbols")

    relativity <- sf_read_ppn("relativity")
    sf_verify(relativity)

    spaiji <- sf_read_ppn("spaiji")
    sf_verify(spaiji)

    tic_tac_toe <- sf_read_ppn("tic-tac-toe")
    expect_true(any(grepl("2. S\\@c1 2... M\\@a3", tic_tac_toe$movetext)))
    expect_equal(tic_tac_toe$moves[["setup."]], "t@b2")
    expect_equal(tic_tac_toe$moves[["1..."]], "M@a2")
    expect_equal(tic_tac_toe$comments[["1..."]], "? (1... M@a1)")
    sf_verify(tic_tac_toe)

    xiangqi <- sf_read_ppn("xiangqi")
    sf_verify(xiangqi)

    # on the fly
    ppn_multiple <- paste(c("---", "GameType: Ultima", "...", "1. c2-c4 1... c7-c5",
                            "---", "Event: Example 3 Game B", "...", "0. t@b4 cA@c3"),
                          collapse = "\n")
    ppn3 <- read_ppn(textConnection(ppn_multiple))
    g3a <- ppn3[[1]]
    df3a <- tail(g3a$dfs, 1)[[1]]
    expect_equal(g3a$metadata$GameType, "Ultima")

    g3b <- ppn3[[2]]
    expect_equal(g3b$metadata$Event, "Example 3 Game B")
    expect_equal(g3b$movetext, "0. t@b4 cA@c3")

    ppn_no_metadata <- "0. c5@b3 t@(2.5,2.5)"
    g4 <- read_ppn(textConnection(ppn_no_metadata))[[1]]
    expect_equal(g4$metadata, list())
    expect_equal(g4$movetext, "0. c5@b3 t@(2.5,2.5)")

    ppn_warning <- "---\n...\n1. S@b2 1. b2-b3"
    expect_warning(read_ppn(textConnection(ppn_warning)),
                   "Non-unique MoveNumbers")

    no_parse <- "---\nSetUp: Chess\n...\n1. b2-d2 1... g2-e2"
    g <- read_ppn(textConnection(no_parse), parse = FALSE)[[1]]
    expect_length(g, 2L)
    expect_equal(g$metadata, list(SetUp = "Chess"))
    expect_equal(g$movetext, "1. b2-d2 1... g2-e2")

    null <- "---\nSetUp: Chess\nMovetextParser: 'Null'\n...\n1. b2-d2 1... g2-e2"
    parser_null <- function(...) list()
    expect_warning(read_ppn(textConnection(null))[[1]])
    null_parser <- function(...) list()
    g <- read_ppn(textConnection(null))[[1]]
    expect_length(g, 0L)

    comments <- "---\n...\n{comment,with,commas}"
    g <- read_ppn(textConnection(comments))[[1]]
    expect_equal(g$comments[[2]], "comment,with,commas")

    ppn_bad_metadata <- "---\nttt\n...\n"
    expect_error(read_ppn(textConnection(ppn_bad_metadata)),
                 "The PPN metadata does not appear to be a YAML dictionary")
})

test_that("parsing simplified piece notation works as expected", {
    do.call(rlang::local_options, default_options())
    df0 <- initialize_df(df_none())

    t <- parse_piece("t")
    expect_equal(t$suit, 1)
    expect_equal(t$rank, 1)
    expect_equal(t$angle, 0)
    expect_equal(t$piece_side, "tile_back")
    expect_equal(t$cfg, "piecepack")
    t <- parse_piece("t,a45,subpack'")
    expect_equal(t$suit, 1)
    expect_equal(t$rank, 1)
    expect_equal(t$angle, 45)
    expect_equal(t$piece_side, "tile_back")
    expect_equal(t$cfg, "subpack")
    cC <- parse_piece("cC^")
    expect_equal(cC$suit, 3)
    expect_equal(cC$rank, 1)
    expect_equal(cC$angle, 0)
    expect_equal(cC$piece_side, "coin_back")
    dSn270 <- parse_piece("dSn>")
    expect_equal(dSn270$suit, 1)
    expect_equal(dSn270$rank, 1)
    expect_equal(dSn270$angle, 270)
    expect_equal(dSn270$piece_side, "die_face")
    c5 <- parse_piece("c5v")
    expect_equal(c5$suit, 1)
    expect_equal(c5$rank, 6)
    expect_equal(c5$angle, 180)
    expect_equal(c5$piece_side, "coin_face")
    expect_equal(c5$cfg, "piecepack")
    cn <- parse_piece("n")
    cR <- parse_piece("[]")
    expect_equal(cR$suit, 1)
    expect_equal(cR$piece_side, "card_back")
    expect_equal(cR$cfg, "playing_cards_tarot")
    cn2 <- parse_piece("0")
    expect_equal(cn, cn2)
    ca <- parse_piece("af<")
    expect_equal(ca$rank, 2)
    expect_equal(ca$angle, 90)
    expect_equal(ca$piece_side, "coin_face")
    pM <- parse_piece("pMb")
    expect_equal(pM$suit, 2)
    expect_equal(pM$rank, 1)
    expect_equal(pM$angle, 0)
    expect_equal(pM$piece_side, "pawn_back")
    pt <- parse_piece("▲S")
    expect_equal(pt$piece_side, "pyramid_top")
    pl <- parse_piece("▲Sl")
    expect_equal(pl$piece_side, "pyramid_left")
    pr <- parse_piece("▲Sr")
    expect_equal(pr$piece_side, "pyramid_right")
    mM <- parse_piece("mM")
    expect_equal(mM$piece_side, "matchstick_face")
    sM <- parse_piece("sM")
    expect_equal(sM$piece_side, "saucer_back")
    s <- parse_piece("s")
    expect_equal(s$piece_side, "saucer_face")
    # playing cards expansion
    H <- parse_piece("\u2665")
    expect_equal(H$piece_side, "coin_back")
    expect_equal(H$cfg, "playing_cards_expansion")
    expect_equal(H$suit, 1)
    S <- parse_piece("\u2660d")
    expect_equal(S$piece_side, "die_face")
    expect_equal(S$cfg, "playing_cards_expansion")
    expect_equal(S$suit, 2)
    C <- parse_piece("\u2663p")
    expect_equal(C$piece_side, "pawn_face")
    expect_equal(C$cfg, "playing_cards_expansion")
    expect_equal(C$suit, 3)
    D <- parse_piece("\u26665")
    expect_equal(D$piece_side, "tile_face")
    expect_equal(D$cfg, "playing_cards_expansion")
    expect_equal(D$suit, 4)
    # dual piecepacks expansion
    D <- parse_piece("\u26625")
    expect_equal(D$piece_side, "tile_face")
    expect_equal(D$cfg, "dual_piecepacks_expansion")
    expect_equal(D$suit, 4)
    # icehouse pieces
    I <- parse_piece("Y2/\\")
    expect_equal(I$piece_side, "pyramid_top")
    expect_equal(I$cfg, "icehouse_pieces")
    expect_equal(I$rank, 2)
    expect_equal(I$suit, 5)
    I <- parse_piece("xW1")
    expect_equal(I$piece_side, "pyramid_top")
    expect_equal(I$cfg, "icehouse_pieces")
    expect_equal(I$rank, 1)
    expect_equal(I$suit, 6)
    # subpack
    c5 <- parse_piece("\u03bcc5v")
    expect_equal(c5$suit, 1)
    expect_equal(c5$rank, 6)
    expect_equal(c5$angle, 180)
    expect_equal(c5$piece_side, "coin_face")
    expect_equal(c5$cfg, "subpack")
    c5 <- parse_piece("\u00b5c5v")
    expect_equal(c5$suit, 1)
    expect_equal(c5$rank, 6)
    expect_equal(c5$angle, 180)
    expect_equal(c5$piece_side, "coin_face")
    expect_equal(c5$cfg, "subpack")
    c5 <- parse_piece("uc5v")
    expect_equal(c5$suit, 1)
    expect_equal(c5$rank, 6)
    expect_equal(c5$angle, 180)
    expect_equal(c5$piece_side, "coin_face")
    expect_equal(c5$cfg, "subpack")
    # hexpack
    ht <- parse_piece("\u2b22")
    expect_equal(ht$piece_side, "tile_back")
    expect_equal(ht$cfg, "hexpack")
    # standard dice
    d <- parse_piece("Bd4")
    expect_equal(d$piece_side , "die_face")
    expect_equal(d$rank, 4L)
    expect_equal(d$suit, 4L)
    expect_equal(d$cfg, "dice")
    d <- parse_piece("\u2681")
    expect_equal(d$piece_side , "die_face")
    expect_equal(d$rank, 2L)
    expect_equal(d$suit, 6L)
    expect_equal(d$cfg, "dice")
    d <- parse_piece("R\u2682")
    expect_equal(d$rank, 3L)
    expect_equal(d$suit, 1L)
    d <- parse_piece("K\u2683")
    expect_equal(d$piece_side , "die_face")
    expect_equal(d$rank, 4L)
    expect_equal(d$suit, 2L)
    expect_equal(d$cfg, "dice")
    d <- parse_piece("Y\u2684")
    expect_equal(d$rank, 5L)
    expect_equal(d$suit, 5L)
    d <- parse_piece("G\u2685")
    expect_equal(d$rank, 6L)
    expect_equal(d$suit, 3L)
    # playing cards
    c <- parse_piece("\U0001f0cd") # queen of diamonds
    expect_equal(c$rank, 13)
    expect_equal(c$suit, 4)
    expect_equal(c$cfg, "playing_cards_tarot")
    c <- parse_piece("\U0001f0e6") # trump-6
    expect_equal(c$rank, 6)
    expect_equal(c$suit, 5)
    expect_equal(c$cfg, "playing_cards_tarot")

    df <- process_move(df0, "`SJ'@b4")
    expect_equal(df$rank, 11)
    expect_equal(df$suit, 2)
    expect_equal(df$cfg, "playing_cards_tarot")
    expect_error(process_move(df, "`boobear'@b4"),
                 "Macro boobear is unknown")

    # dominoes
    df <- process_move(df0, "`4-3'@b4")
    expect_equal(df$rank, 4L)
    expect_equal(df$suit, 5L)
    expect_equal(df$angle, 180)
    expect_equal(df$cfg, "dominoes")

    df <- process_move(df0, "R`6-3'<@b4")
    expect_equal(df$rank, 4L)
    expect_equal(df$suit, 7L)
    expect_equal(df$angle, 270)
    expect_equal(df$cfg, "dominoes_red")

    df <- process_move(df0, "Y`5-2',a45@b4")
    expect_equal(df$rank, 3L)
    expect_equal(df$suit, 6L)
    expect_equal(df$angle, 225)
    expect_equal(df$cfg, "dominoes_yellow")

    df <- process_move(df0, "B\U0001f062@b4")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 1L)
    expect_equal(df$angle, 0)
    expect_equal(df$piece_side, "tile_back")
    expect_equal(df$cfg, "dominoes_blue")

    df <- process_move(df0, "Wt@b4")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 6L)
    expect_equal(df$piece_side, "tile_back")
    expect_equal(df$cfg, "dominoes_white")

    df <- process_move(df0, "Bt,r12,s10@b4")
    expect_equal(df$rank, 13L)
    expect_equal(df$suit, 11L)
    expect_equal(df$piece_side, "tile_face")
    expect_equal(df$cfg, "dominoes_blue")

    # chess
    df <- process_move(df0, "Rb`q'@b4")
    expect_equal(df$rank, 5L)
    expect_equal(df$suit, 1L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "chess2")
    df <- process_move(df0, "uBb`N'@b4")
    expect_equal(df$rank, 2L)
    expect_equal(df$suit, 4L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "chess1")
    df <- process_move(df0, "u`n'@b4")
    expect_equal(df$rank, 2L)
    expect_equal(df$suit, 2L)
    expect_equal(df$piece_side, "bit_face")
    expect_equal(df$cfg, "chess1")
    df <- process_move(df0, "`K'@b4")
    expect_equal(df$rank, 6L)
    expect_equal(df$suit, 6L)
    expect_equal(df$piece_side, "bit_face")
    expect_equal(df$cfg, "chess2")

    # checkers
    df <- process_move(df0, "Gc@e5")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 3L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "checkers2")

    df <- process_move(df0, "u\u26c0@e5")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 6L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "checkers1")

    df <- process_move(df0, "\u26c2@e5")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 2L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "checkers2")

    df <- process_move(df0, "G\u26c2@e5")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 3L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "checkers2")

    df <- process_move(df0, "[X]@e5")
    expect_equal(df$rank, 8L)
    expect_equal(df$suit, 3L)
    expect_equal(df$piece_side, "board_face")
    expect_equal(df$cfg, "checkers2")

    df <- process_move(df0, "\u26c1@e5")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 6L)
    expect_equal(df$piece_side, "bit_face")
    expect_equal(df$cfg, "checkers2")

    df <- process_move(df0, "\u26c3@e5")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 2L)
    expect_equal(df$piece_side, "bit_face")
    expect_equal(df$cfg, "checkers2")

    df <- process_move(df0, "R\u26c3@e5")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 1L)
    expect_equal(df$piece_side, "bit_face")
    expect_equal(df$cfg, "checkers2")

    # go
    df <- process_move(df0, "[#]@i9")
    expect_equal(df$rank, 19L)
    expect_equal(df$suit, 2L)
    expect_equal(df$piece_side, "board_face")
    expect_equal(df$cfg, "go")

    df <- process_move(df0, "Y[#]@i9")
    expect_equal(df$rank, 19L)
    expect_equal(df$suit, 5L)
    expect_equal(df$piece_side, "board_face")
    expect_equal(df$cfg, "go")

    df <- process_move(df0, "()@b4")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 2L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "go")
    df <- process_move(df0, "Ys@b4")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 5L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "go")

    # meeples
    df <- process_move(df0, "Gm@b4")
    expect_equal(df$rank, 1L)
    expect_equal(df$suit, 3L)
    expect_equal(df$piece_side, "bit_back")
    expect_equal(df$cfg, "meeples")

})

test_that("parsing algebraic coordinates works as expected", {
    expect_equal(get_algebraic_x("c4"), 3)
    expect_equal(get_algebraic_y("d5"), 5)
    expect_equal(get_algebraic_x("aa12"), 27)
    expect_equal(get_algebraic_y("aa12"), 12)
})

test_that("process_submove works as expected", {
    do.call(rlang::local_options, default_options())

    expect_equal(process_submove(tibble(), ""), tibble())

    df <- ppdf::piecepack_four_field_kono()
    df$cfg <- "piecepack"
    df <- initialize_df(df)
    expect_equal(nrow(df), 20)

    df <- process_submove(df, "*b4")
    df <- process_submove(df, "*d2")
    expect_equal(nrow(df), 18)

    df <- process_submove(df, "b2=dC4")
    expect_equal(nrow(df), 18)
    expect_true(any(grepl("die_face", df$piece_side)))

    expect_error(process_submove(df, "!"))
    expect_error(get_id_from_coords(df, "e5"))

    df <- read_ppn(textConnection("1. S@a{1..6} M@a1 5a1-b1"))[[1]]$dfs[[2]]
    expect_equal(sum(near(df$x, 1)), 2)
    expect_equal(sum(near(df$x, 2)), 5)
})

test_that("parse_moves works as expected", {
    do.call(rlang::local_options, default_options())

    l <- parse_moves(c("S@b4", "M@b2"))
    df1 <- l$dfs[[2]]
    expect_equal(nrow(df1), 2)

    l <- parse_moves(c("S@b4", "2. M@b2"))
    df2 <- l$dfs[[3]]
    expect_equal(nrow(df2), 2)
    expect_equal(df1, df2)

    df <- insert_df(df1, df2, 1)
    expect_equal(nrow(df), 4)
    expect_equal(df$suit, rep(1:2, each = 2))
})

test_that("^ notation works as expected", {
    do.call(rlang::local_options, default_options())
    df0 <- initialize_df(df_none())
    state0 <- create_state(df0)

    # refer to piece by id
    df <- process_submove(df0, "S@b2", state0)
    expect_true(near(df$x, 2))
    expect_equal(nrow(df), 1)
    expect_equal(df$suit, 1)
    df <- process_submove(df, "1=M", state0)
    expect_equal(df$suit, 2)
    df <- process_submove(df, "1..1-c3", state0)
    expect_true(near(df$x, 3))
    expect_equal(nrow(df), 1)
    df <- process_submove(df, "*1..1", state0)
    expect_equal(nrow(df), 0)

    # ^ notation
    df <- process_move(df0, "S@b2 M@d4", state0)
    df1 <- process_move(df, "&b2-d4 d4-f6", state0)
    expect_equal(df1$suit[2], 1)
    expect_true(near(df1$x[2], 6))
    df2 <- process_move(df, "b2-d4 ^d4-f6", state0)
    expect_equal(df2$suit[2], 2)
    expect_true(near(df2$x[2], 6))
})

test_that("at move works with piece index", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    df <- process_move(df, "S@b2 M@b2 C@b2")
    expect_equal(get_id_from_piece_id("b2[3]", df), "1")
    expect_equal(get_id_from_piece_id("b2[2]", df), "2")
    expect_equal(get_id_from_piece_id("b2[1]", df), "3")
    expect_equal(df$suit, 1:3)
    df <- process_move(df, "A@d4%b2[3]")
    expect_equal(df$suit, c(1, 4, 2, 3))
    df <- process_move(df, "A@%b2[2]")
    expect_equal(df$suit, c(1, 4, 2, 4, 3))
})

test_that("hyphen move works with piece index", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    df <- process_move(df, "S@b2 M@b2 C@b2 A@c3")
    df <- process_move(df, "c3-%b2[2]")
    expect_equal(df$suit, c(1, 2, 4, 3))
})

test_that("underscore move works", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    df <- process_move(df, "S@b2 M@b2 C@b2 A@c3")
    df <- process_move(df, "b2[2]_c3")
    expect_equal(df$suit, c(2, 1, 3, 4))
    df <- process_move(df, "b2[1]_%c3[1]")
    expect_equal(df$suit, c(2, 1, 3, 4))
    df <- process_move(df, "c3_%b2")
    expect_equal(df$suit, c(2, 4, 1, 3))
})

test_that("backslash move works", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    df <- process_move(df, "S@b2 M@b2")
    df <- process_move(df, "C\\b2")
    expect_equal(df$suit, c(3, 1, 2))
    df <- process_move(df, "C\\b2%b2")
    expect_equal(df$suit, c(3, 1, 3, 2))
    df <- process_move(df, "A\\%b2[2]")
    expect_equal(df$suit, c(3, 1, 4, 3, 2))
})

test_that("swap works as expected", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    state <- create_state(df)
    df <- process_move(df, "S@b2 M@d4", state)
    expect_equal(df$suit[which(df$x == 2)], 1)
    expect_equal(df$suit[which(df$x == 4)], 2)
    df <- process_move(df, "b2#d4", state)
    expect_equal(df$suit[which(df$x == 4)], 1)
    expect_equal(df$suit[which(df$x == 2)], 2)
})

test_that("rotations work as expected", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    df <- process_move(df, "S@b2 b2@>45")
    expect_equal(df$angle, -45)
    df <- process_move(df, "b2@>-45")
    expect_equal(df$angle, 0)
    df <- process_move(df, "b2@>-90")
    expect_equal(df$angle, 90)
    df <- initialize_df(df_none())
    df <- process_move(df, "C3@(1.5,1.5) S@a1 M@b2 3?C3@>180|b2")
    expect_equal(df$angle, rep(-180, 3))
    expect_equal(df$x, c(2.5,3,2))
    expect_equal(df$y, c(2.5,3,2))
    df <- process_move(df, "3?C3@>-180$?M")
    expect_equal(df$angle, rep(0, 3))
    expect_equal(df$x, c(1.5,1,2))
    expect_equal(df$y, c(1.5,1,2))
    df <- process_move(df, "3?C3$>180")
    expect_equal(df$angle, rep(-180, 3))
    expect_equal(df$x, c(1.5,2,1))
    expect_equal(df$y, c(1.5,2,1))
})

test_that("address works as expected", {
    do.call(rlang::local_options, default_options())

    df <- read_ppn(textConnection("1. t@(1.5,1.5) S@{a,b}{1,2}"))[[1]]$dfs[[2]]
    expect_equal(mean(df$x), 1.5)
    expect_equal(get_xy("&5(1.5,1.5)", df)$x, 1.5)

    dfn <- initialize_df(df_none())
    state <- create_state(df)
    df <- process_move(dfn, "S@b2 d@b2", state)
    expect_equal(df$piece_side, c("coin_back", "die_face"))
    df <- process_move(df, "&?d[2]-c3", state)
    expect_equal(df$x, c(2,3))
    expect_equal(get_xy("", df, state)$x, 3)
})

test_that("Identifying pieces with brackets works", {
    do.call(rlang::local_options, default_options())

    expect_equal(get_indices_from_brackets("2:3"), 3:2)
    expect_equal(get_indices_from_brackets("2:3,1"), c(1, 3, 2))
    df <- initialize_df(df_none())
    df <- process_move(df, "S@b2 M@b2 C@b2 A@b2")
    expect_equal(df$suit, 1:4)
    df <- process_move(df, "*b2[2:3]")
    expect_equal(df$suit, c(1,4))
    df <- initialize_df(df_none())
    df <- process_move(df, "S@b2 M@b2 C@b2 A@b2 b2[2:3]-c2")
    expect_equal(df$suit, c(1, 4, 2, 3))
    df <- process_move(df, "b2[2]:c2")
    expect_equal(df$suit, c(4, 2, 1))
})

test_that("Move multiple pieces works as expected", {
    do.call(rlang::local_options, default_options())

    df <- tail(process_moves(tibble(), c("S@b2", "S@b2", "S@b2")), 1)[[1]]
    expect_equal(sum(near(df$x, 2)), 3)
    df <- process_submove(df, "2b2-c3")
    expect_equal(sum(near(df$x, 2)), 1)
    expect_equal(sum(near(df$x, 3)), 2)
    expect_equal(nrow(df), 3)
    df <- process_submove(df, "b2:2c3")
    expect_equal(sum(near(df$x, 2)), 0)
    expect_equal(sum(near(df$x, 3)), 1)
    expect_equal(nrow(df), 1)
    df <- tail(process_moves(tibble(), c("S@b2", "S@b2", "S@b2")), 1)[[1]]
    df <- process_submove(df, "3b2-c3")
    expect_equal(sum(near(df$x, 2)), 0)
    expect_equal(sum(near(df$x, 3)), 3)
    df <- process_submove(df, "c3-b2")
    expect_equal(sum(near(df$x, 2)), 1)
    expect_equal(sum(near(df$x, 3)), 2)
    df <- process_submove(df, "2c3:b2")
    expect_equal(sum(near(df$x, 2)), 2)
    expect_equal(sum(near(df$x, 3)), 0)
    expect_equal(nrow(df), 2)
})

test_that("move numbers work as expected", {
    do.call(rlang::local_options, default_options())

    ppn <- "---\n...\n1. S@b2;M@b3;C@b4 {what happens ; here?}"
    game <- read_ppn(textConnection(ppn))[[1]]
    expect_equal(names(game$moves), c("SetupFn.", "1.", "1..", "1..."))
    expect_equal(game$moves[[3]], "M@b3")
    expect_equal(game$moves[[4]], "C@b4")
    expect_equal(game$comments[[4]], "what happens ; here?")
})


test_that("non-greedy search works as expected", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    state <- create_state(df)
    df <- process_move(df, "S4@b2 M3v@b4 dS4@b2", state)
    expect_equal(nrow(df), 3)
    df <- process_move(df, "*?S4", state)
    expect_equal(nrow(df), 2)
    df <- process_move(df, "*?dS", state)
    expect_equal(nrow(df), 1)
    expect_equal(df$angle, 180)
    df <- process_move(df, "M3>@b2 *?M3", state)
    expect_equal(nrow(df), 1)
    expect_equal(df$angle, 180)
    expect_error(process_move(df, "*?A3"), "Couldn't find a match")
    df <- process_move(df, "?tf-(1.5,1.5) S@a1 M@b2", state)
    expect_equal(df$x, c(1.5, 1, 2))
    df <- process_move(df, "3?tf-2R", state)
    expect_equal(df$x, c(3.5, 3, 4))
    expect_error(process_move(df, "3/tf-2R", state), "Failed to parse coordinates: /tf")
})
test_that("greedy search works as expected", {
    do.call(rlang::local_options, default_options())

    df <- read_ppn(textConnection("1. S@{a..f}2"))[[1]]$dfs[[2]]
    expect_equal(nrow(df), 6)
    df <- process_move(df, "*?S")
    expect_equal(nrow(df), 5)
    df <- process_move(df, "*/S")
    expect_equal(nrow(df), 0)
})

test_that("move chaining works as expected", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    state <- create_state(df)
    expect_equal(state$active_id, character())
    expect_error(process_move(df, "-b2", state), "Couldn't find any active pieces")
    df <- process_move(df, "S@b1", state)
    expect_equal(state$active_id, "1")
    df <- process_move(df, "A@b2", state)
    expect_equal(state$active_id, "2")
    df <- process_move(df, "?S-b3", state)
    expect_equal(state$active_id, "1")
    df <- process_move(df, "*?S", state)
    expect_equal(state$active_id, character())
    df <- process_move(df, "M\\b2 2b2_b3", state)
    expect_equal(state$active_id, c("3", "2"))
    df <- process_move(df, "?M~C", state)
    expect_equal(state$active_id, "3..1")
    df <- process_move(df, "?A#?C", state)
    expect_equal(state$active_id, "2")
    df <- process_move(df, "?C@>90", state)
    expect_equal(state$active_id, "3..1")
    df <- process_move(df, "?C=S4", state)
    expect_equal(state$active_id, "3..2")
    df <- process_move(df, "?A-c4 -d4")
    expect_equal(df$x, c(2, 4))
})

test_that("relative moves work as expected", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    state <- create_state(df)
    expect_error(process_move(df, 'S"d4'), "Don't know how to handle move S\"d4")
    expect_error(process_move(df, "S@<2,2>"), "Don't know where this location is relative to")
    df <- process_move(df, "Sd@b1 Ad@c4", state)
    expect_equal(df$x, c(2,3))
    expect_equal(df$y, c(1,4))
    df <- process_move(df, "?Sd-<2,2>", state)
    expect_equal(df$x, c(3,4))
    expect_equal(df$y, c(4,3))
    df <- process_move(df, "?Ad-2E", state)
    expect_equal(df$x, c(4,5))
    expect_equal(df$y, c(3,4))
    df <- process_move(df, "?Ad-2E$?Sd", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2E ?Ad-2W ?Ad-2N ?Ad-2S", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2NE ?Ad-2SW ?Ad-2NW ?Ad-2SE", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2NNE ?Ad-2SSW ?Ad-2NNW ?Ad-2SSE", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2NNE ?Ad-2SSW ?Ad-2NNW ?Ad-2SSE", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2R ?Ad-2L ?Ad-2U ?Ad-2D", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2UR ?Ad-2DL ?Ad-2UL ?Ad-2DR", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2UUR ?Ad-2DDL ?Ad-2UUL ?Ad-2DDR", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2UUR ?Ad-2DDL ?Ad-2UUL ?Ad-2DDR", state)
    expect_equal(df$x, c(4,6))
    expect_equal(df$y, c(3,3))
    df <- process_move(df, "?Ad-2L|2U|(2,2)", state)
    expect_equal(df$x, c(4,0))
    expect_equal(df$y, c(3,4))
    df <- process_move(df, "!?Sd", state)
    expect_equal(df$suit, c(4,1))
})

test_that("partial piece update (tilde)", {
    do.call(rlang::local_options, default_options())

    df <- initialize_df(df_none())
    state <- create_state(df)
    df <- process_move(df, "S@b2", state)
    expect_equal(df$suit, 1)
    expect_equal(df$id, "1")
    expect_equal(df$angle, 0)
    df <- process_move(df, "?S~<", state)
    expect_equal(df$suit, 1)
    expect_equal(df$id, "1")
    expect_equal(df$angle, 90)
    df <- process_move(df, "?S~M", state)
    expect_equal(df$suit, 2)
    expect_equal(df$id, "1..1")
    expect_equal(df$angle, 90)
    expect_equal(df$rank, 1)
    df <- process_move(df, "?M~2", state)
    expect_equal(df$rank, 3)
    df <- process_move(df, "?M~t", state)
    expect_equal(df$id, "1..3")
    expect_equal(df$piece_side, "tile_back")
    df <- process_move(df, "?M=R2/\\", state)
    expect_equal(df$id, "1..4")
    expect_equal(df$rank, 2)
    expect_equal(df$angle, 0)
    expect_equal(df$cfg, "icehouse_pieces")
    df <- process_move(df, "?R\u25b3~1", state)
    expect_equal(df$rank, 1)
    expect_equal(df$id, "1..5")
    df <- process_move(df, "?R/\\~f", state)
    expect_equal(df$id, "1..5.1")
    expect_equal(df$piece_side, "pyramid_face")
    df <- process_move(df, "*?/\\ S@b2 ?S~\u2665")
    expect_equal(df$id, "2..1")
    expect_equal(df$piece_side, "coin_back")
    expect_equal(df$cfg, "playing_cards_expansion")
})

test_that("flipping pieces works", {
    do.call(rlang::local_options, default_options())

    ps <- c("tile_face", "coin_back", "pawn_top", "pyramid_top", "pyramid_face",
            "tile_base", "card_left", "bit_right", "die_face")
    ps_flipped <- flip_ps(ps)
    expect_equal(ps_flipped, c("tile_back", "coin_face", "pawn_base", "pyramid_face", "pyramid_top",
                               "tile_top", "card_right", "bit_left", "die_face"))
    df <- initialize_df(df_none())
    state <- create_state(df)
    df <- process_move(df, "S@b2 S5d@b3 M@b4 +/S", state)
    expect_equal(df$piece_side, c("coin_face", "die_face", "coin_back"))
    expect_equal(df$id, c("1.1", "2.1", "3"))
    expect_equal(df$rank, c(1L, 3L, 1L))
})

test_that("scale_factor works as expected", {
    do.call(rlang::local_options, default_options())

    scale <- "MovetextParser:\n  Name: Default\n  ScaleFactor: 2\n...\n1. S@a2"
    df <- tail(read_ppn(textConnection(scale))[[1]]$dfs, 1)[[1]]
    expect_true(near(df$x, 2))
    expect_true(near(df$y, 4))
    scale <- "MovetextParser:\n  Name: Default\n  ScaleFactor: 2\n...\n1. S@a2 a2-b3 M@d3 b3:d3"
    df <- tail(read_ppn(textConnection(scale))[[1]]$dfs, 1)[[1]]
    expect_true(near(df$x, 8))
    expect_true(near(df$y, 6))

    df <- initialize_df(df_none())
    attr(df, "scale_factor") <- 2
    state <- create_state(df)
    df <- process_move(df, "S@b2 M@c3", state)
    expect_equal(df$x, c(4, 6))
    df <- process_move(df, "c3-b2", state)
    expect_equal(df$x, c(4, 4))
    expect_equal(df$suit, 1:2)
    df <- process_move(df, "b2[2]-%b2", state)
    expect_equal(df$x, c(4, 4))
    expect_equal(df$suit, 2:1)
    df <- process_move(df, "b2[2]_%b2[1]", state)
    expect_equal(df$x, c(4, 4))
    expect_equal(df$suit, 2:1)
    df <- process_move(df, "C@%b2[1]", state)
    expect_equal(df$x, c(4, 4, 4))
    expect_equal(df$suit, c(2:1, 3))
    df <- process_move(df, "A\\%b2[1]", state)
    expect_equal(df$x, c(4, 4, 4, 4))
    expect_equal(df$suit, c(2:1, 4, 3))
})

test_that("Setup and GameType work as expected", {
    do.call(rlang::local_options, default_options())

    chess1 <- "GameType: Chess\n"
    df1 <- read_ppn(textConnection(chess1))[[1]]$dfs[[1]]
    chess2 <- "GameType:\n  Name: Chess\n"
    df2 <- read_ppn(textConnection(chess1))[[1]]$dfs[[1]]
    expect_true(identical(df1, df2))
    chess3 <- "SetUp: Chess\n\nMovetextParser:\n  Name: Default\n...\n"
    df3 <- read_ppn(textConnection(chess3))[[1]]$dfs[[1]]
    expect_true(identical(df1, df3))
    chess4 <- "SetUp:\n  Name: Chess\nMovetextParser: Default\n...\n"
    df4 <- read_ppn(textConnection(chess4))[[1]]$dfs[[1]]
    expect_true(identical(df1, df4))
    chess5 <- "SetUp:\n  Name: Chess\n  System: Piecepack\nGameType: Hostage Chess\n...\n"
    df5 <- read_ppn(textConnection(chess5))[[1]]$dfs[[1]]
    expect_true(identical(df1, df5))
    chess6 <- "---\nSetUp:\n  Chess\nGameType: Hostage Chess\n...\n"
    df6 <- read_ppn(textConnection(chess6))[[1]]$dfs[[1]]
    expect_true(identical(df1, df6))
    chess7 <- "GameType:\n  Name: Chess\n  System: Piecepack\n...\n"
    df7 <- read_ppn(textConnection(chess7))[[1]]$dfs[[1]]
    expect_true(identical(df1, df7))
    chess8 <- "GameType:\n  Name: Chess\n  System: Stackpack\n...\n"
    df8 <- read_ppn(textConnection(chess8))[[1]]$dfs[[1]]
    expect_false(identical(df1, df8))
    chess9 <- "GameType:\n  Name: Chess\n  Has Subpack: true\n...\n"
    df9 <- read_ppn(textConnection(chess9))[[1]]$dfs[[1]]
    expect_true(identical(df8, df9))

    text_macros <- "---\nMacros:\n  p: Sp\n...\n1. `p'@b2\n"
    df <- read_ppn(textConnection(text_macros))[[1]]$dfs[[2]]
    expect_equal(df$cfg, "piecepack")
    expect_equal(df$suit, 1)
    expect_equal(df$piece_side, "pawn_face")

    none1 <- ""
    df1 <- read_ppn(textConnection(none1))[[1]]$dfs[[1]]
    expect_equal(nrow(df1), 0)
    none2 <- "GameType: None\n...\n"
    df2 <- read_ppn(textConnection(none2))[[1]]$dfs[[1]]
    expect_equal(nrow(df2), 0)
    none3 <- "GameType: Tak\nSetUp:  None\n...\n"
    df3 <- read_ppn(textConnection(none3))[[1]]$dfs[[1]]
    expect_equal(nrow(df3), 0)
})

test_that("ID computation works as expected", {
    do.call(rlang::local_options, default_options())

    expect_equal(compute_plus_id(c("23", "24.2", "24..1.1", "30..2")), c("23.1", "24.3", "24..1.2", "30..2.1"))
    expect_equal(compute_equal_id(c("23", "24.2", "24..1.1", "30..2")), c("23..1", "24..1", "24..2", "30..3"))
})
