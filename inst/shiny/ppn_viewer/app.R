# URL parameters supported:
#
# ppn - Raw PPN text to use
# system.file - Name of file accessible by `system.file()` to read PPN from;
#               will try prepending "ppn/" and postpending ".ppn"
# package - Name of package to feed to `system.file()` to be used with `system.file` parameter
# op_scale - Numeric value greater than or equal to zero; "oblique projection" scale
# op_angle - Numeric from 0 to 360; "oblique projection" angle
# annotate - Either "none", "algebraic", or "cartesian"
#
library("ppn")
library("rlang")
library("shiny")
if (has_fansi) {
    options(cli.num_colors = 256L)
} else {
    options(cli.num_colors = 1L)
}

txt <- ""

ui <- fluidPage(
    tags$head(tags$style(HTML("
        pre.diagram {
            font-family: FreeMono, mono;
            line-height: 100%;
            font-size: 24px;
        }"))),
    fluidRow(column(5, gameUI("game", txt), hr(), moveUI("move")),
             column(7, plotUI("plot")))
)

server <- function(input, output, session) {
    if (!has_animation)
        showNotification("Neither 'animation' or 'gifski' packages installed.  GIF animation disabled.",
                         type = "warning")

    if (!has_fansi)
        showNotification("`{fansi}` package not installed. `cat_piece()`'s `color` option disabled.",
                         type = "warning")
    if (!has_piecenikr)
        showNotification("`{piecenickr}` package not installed.  `icehouse_pieces` support disabled.",
                         type = "warning")
    if (!has_rgl)
        showNotification("`{rgl}` package not installed. webGL support disabled.",
                         type = "warning")
    if (!has_tweenr)
        showNotification("'tweenr' package not installed.  Animation transitions disabled.",
                         type = "warning")

    if (!has_dejavu)
        showNotification('"Dejavu Sans" font not detected.  Falling back to "sans" style.',
                         type = "warning")


    game <- gameServer("game")
    move <- moveServer("move", game)
    plotServer("plot", game, move)
}

shinyApp(ui, server)
