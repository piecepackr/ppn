uc_seq <- function(glyph, seq) {
    intToUtf8(utf8ToInt(glyph) + seq, multiple = TRUE)
}

unicode_dice <- uc_seq("\u2680", 0:5)

unicode_cards <- c(uc_seq("\U0001f0a1", 0:13), # spades
                   uc_seq("\U0001f0b1", 0:13), # hearts
                   uc_seq("\U0001f0c1", 0:13), # diamonds
                   uc_seq("\U0001f0d1", 0:13), # clubs
                   "\U0001f0bf", "\U0001f0cf", "\U0001f0df", # jokers
                   uc_seq("\U0001f0e0", 0:21), # trumps
                   "\U0001f0a0") # card back

card2rank <- list()
for (r in 1:14) {
    card2rank[[unicode_cards[r]]] <- r
    card2rank[[unicode_cards[r+14L]]] <- r
    card2rank[[unicode_cards[r+28L]]] <- r
    card2rank[[unicode_cards[r+42L]]] <- r
}
card2rank[[unicode_cards[57L]]] <- 15L
card2rank[[unicode_cards[58L]]] <- 15L
card2rank[[unicode_cards[59L]]] <- 15L
card2rank[[unicode_cards[60L]]] <- 22L
for (r in 1:21) {
    card2rank[[unicode_cards[r+60L]]] <- r
}
card2rank[[unicode_cards[82L]]] <- NA_integer_

card2suit <- list()
for (r in 1:14) {
    card2suit[[unicode_cards[r]]] <- 2L
    card2suit[[unicode_cards[r+14L]]] <- 1L
    card2suit[[unicode_cards[r+28L]]] <- 4L
    card2suit[[unicode_cards[r+42L]]] <- 3L
}
card2suit[[unicode_cards[57L]]] <- 4L # 3rd "red" joker
card2suit[[unicode_cards[58L]]] <- 2L # 1st "black" joker
card2suit[[unicode_cards[59L]]] <- 1L # 2nd "white" joker
card2suit[[unicode_cards[60L]]] <- 5L
for (r in 1:21) {
    card2suit[[unicode_cards[r+60L]]] <- 5L
}
card2suit[[unicode_cards[82L]]] <- NA_integer_

unicode_dominoes <- uc_seq("\U0001f030", 0:99)

unicode_chess_black <- uc_seq("\u265f", seq.int(0L, -5L))
unicode_chess_white <- uc_seq("\u2659", seq.int(0L, -5L))
unicode_chess_pieces <- c(uc_seq("\u2654", 0:11),
                          uc_seq("\U0001fa00", seq.int(0L, 4L * 16L + 8L - 1L)))

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
     unicode_dominoes,
     unicode_chess_pieces,
     color_suits, macros,
     file = "R/sysdata.rda", version = 2)
