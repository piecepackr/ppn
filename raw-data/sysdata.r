unicode_dice <- c("\u2680", "\u2681", "\u2682", "\u2683", "\u2684", "\u2685")
# excludes card back
unicode_cards <- c(intToUtf8(utf8ToInt("\U0001f0a1") + 0:13, multiple = TRUE), # spades
                   intToUtf8(utf8ToInt("\U0001f0b1") + 0:13, multiple = TRUE), # hearts
                   intToUtf8(utf8ToInt("\U0001f0c1") + 0:13, multiple = TRUE), # diamonds
                   intToUtf8(utf8ToInt("\U0001f0d1") + 0:13, multiple = TRUE), # clubs
                   "\U0001f0bf", "\U0001f0cf", "\U0001f0df", # jokers
                   intToUtf8(utf8ToInt("\U0001f0e0") + 0:21, multiple = TRUE)) # trumps
card2rank <- list()
for (r in 1:14) {
    card2rank[[unicode_cards[r]]] <- r
    card2rank[[unicode_cards[r+14]]] <- r
    card2rank[[unicode_cards[r+28]]] <- r
    card2rank[[unicode_cards[r+42]]] <- r
}
card2rank[[unicode_cards[57]]] <- 15
card2rank[[unicode_cards[58]]] <- 15
card2rank[[unicode_cards[59]]] <- 15
card2rank[[unicode_cards[60]]] <- 22
for (r in 1:21) {
    card2rank[[unicode_cards[r+60]]] <- r
}
card2suit <- list()
for (r in 1:14) {
    card2suit[[unicode_cards[r]]] <- 2
    card2suit[[unicode_cards[r+14]]] <- 1
    card2suit[[unicode_cards[r+28]]] <- 4
    card2suit[[unicode_cards[r+42]]] <- 3
}
card2suit[[unicode_cards[57]]] <- 4
card2suit[[unicode_cards[58]]] <- 2
card2suit[[unicode_cards[59]]] <- 1
card2suit[[unicode_cards[60]]] <- 5
for (r in 1:21) {
    card2suit[[unicode_cards[r+60]]] <- 5
}

unicode_dominoes <- intToUtf8(utf8ToInt("\U0001f030") + 0:99, multiple = TRUE)
ranks <- c(NA_integer_, rep(0L, 7), # 0H
           0L, rep(1L, 6), # 1H
           0:1, rep(2L, 5), # 2H
           0:2, rep(3L, 4), # 3H
           0:3, rep(4L, 3), # 4H
           0:4, rep(5L, 2), # 5H
           0:5, 6L) # 6H
ranks <- c(ranks, ranks)
suits <- c(NA_integer_, 0:6, # 0H
           rep(1L, 2), 2:6, # 1H
           rep(2L, 3), 3:6,
           rep(3L, 4), 4:6,
           rep(4L, 5), 5:6,
           rep(5L, 6), 6L,
           rep(6L, 7))
suits <- c(suits, suits)
angles <- c(90, rep(90, 7),  # 0H
            rep(270, 1), rep(90, 6), # 1H
            rep(270, 2), rep(90, 5), # 2H
            rep(270, 3), rep(90, 4), # 3H
            rep(270, 4), rep(90, 3), # 4H
            rep(270, 5), rep(90, 2), # 5H
            rep(270, 6), rep(90, 1)) # 6H
angles <- c(angles, angles - 90)
tile2rank <- list()
tile2suit <- list()
tile2angle <- list()
for (i in seq_along(unicode_dominoes)) {
    d <- unicode_dominoes[i]
    tile2rank[[d]] <- ranks[i]
    tile2suit[[d]] <- suits[i]
    tile2angle[[d]] <- angles[i]
}
# chess
unicode_chess_black <- c("\u265f", "\u265e", "\u265d", "\u265c", "\u265b", "\u265a")
unicode_chess_white <- c("\u2659", "\u2658", "\u2657", "\u2656", "\u2655", "\u2654")

# built-in macros
macros <- list(H = "\u2665", S = "\u2660", C = "\u2663", D = "\u2666",
               WH = "\u2664", WS = "\u2661", WD = "\u2662", WC = "\u2667",
               RJ = unicode_cards[57], BJ = unicode_cards[58],
               WJ = unicode_cards[59], TF = unicode_cards[60],
               p = unicode_chess_black[1], n = unicode_chess_black[2], b = unicode_chess_black[3],
               r = unicode_chess_black[4], q = unicode_chess_black[5], k = unicode_chess_black[6],
               P = unicode_chess_white[1], N = unicode_chess_white[2], B = unicode_chess_white[3],
               R = unicode_chess_white[4], Q = unicode_chess_white[5], K = unicode_chess_white[6])
card_macros <- paste0(rep(c("S", "H", "D", "C"), each = 14),
                      rep(c("A", 2:9, "T", "J", "C", "Q", "K"), 4))
trump_macros <- paste0("T", 1:21)
#### Add macros for jokers and trumps
for (i in seq_along(card_macros)) {
    c <- card_macros[i]
    macros[[c]] <- unicode_cards[i]
}
for (i in seq_along(trump_macros)) {
    c <- trump_macros[i]
    macros[[c]] <- unicode_cards[i+60]
}

domino_macros <- paste0(rep(0:6, each=7), "-", rep(0:6, 7))
for (i in seq_along(domino_macros)) {
    t <- domino_macros[i]
    macros[[t]] <- unicode_dominoes[51 + i]
}

color_suits <- c("R", "K", "G", "B", "Y", "W")

save(unicode_dice,
     unicode_cards, card2rank, card2suit,
     unicode_dominoes, tile2rank, tile2suit, tile2angle,
     unicode_chess_black,
     unicode_chess_white,
     color_suits, macros,
     file = "R/sysdata.rda", version = 2)
