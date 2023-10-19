#' @importFrom dplyr bind_rows mutate
#' @importFrom ppdf normalize_name
#' @importFrom rlang %||% abort .data
#' @importFrom tibble tibble
#' @importFrom utils hasName
NULL

assert_suggested <- function (package) {
    calling_fn <- deparse(sys.calls()[[sys.nframe() - 1]])
    if (!requireNamespace(package, quietly = TRUE)) {
        msg <- c(sprintf("You need to install the suggested package %s to use %s.",
            sQuote(package), sQuote(calling_fn)), i = sprintf("Use %s.",
            sQuote(sprintf("install.packages(\"%s\")", package))))
        abort(msg, class = "piecepackr_suggested_package")
    }
}

# We require `{snakecase}` so in `Imports`
# But we only use it indirectly from `{ppdf}` which has it in its `Suggests`
# This should suppress a CRAN NOTE about `{snakecase}` being in `Imports` but not used
dont_run <- function(x) {
    snakecase::to_snake_case(x)
}

to_x <- function(t, r) r * cos(pi * t / 180)
to_y <- function(t, r) r * sin(pi * t / 180)
