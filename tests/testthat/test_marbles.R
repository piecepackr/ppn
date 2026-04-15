test_that("marbles works as expected", {
    do.call(local_options, default_options())
    local_options(ppn.default_colored_bit_cfg = "marbles")
    d <- parse_piece("K")
    expect_equal(d$piece_side , "bit_back")
    expect_equal(d$rank, 9L)
    expect_equal(d$suit, 2L)
    expect_equal(d$cfg, "marbles")
})
