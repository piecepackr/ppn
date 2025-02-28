default_options <- function() {
    list(ppn.default_colored_bit_cfg = NULL)
}

#' Movetext parsers
#'
#' `default_parser()` is the default PPN movetext parser.
#'
#' @examples
#' l <- read_ppn(system.file("ppn/relativity.ppn", package = "ppn"),
#'               parse = FALSE)[[1]]
#' game <- default_parser(l$movetext, l$metadata)
#' @param movetext A named character vector of move text.
#' @param metadata A named list of metadata
#' @param ... Should be empty for `default_parser()`.  Otherwise passed to `default_parser()`.
#' @param scale_factor How many inches a coordinate unit is worth.
#' @param default_system Default game system to use for setup functions.
#' @return A named list of data frames with parsed game states.
#' @rdname ppn_parsers
#' @export
default_parser <- function(movetext = character(), 
                           metadata = list(),
                           ...,
                           scale_factor = NULL,
                           default_system = "piecepack") {
    check_dots_empty(...)
    game_list <- list(metadata = metadata, movetext = movetext)
    df <- get_starting_df(metadata, default_system)
    if (!is.null(scale_factor))
        attr(df, "scale_factor") <- scale_factor
    state <- create_state(df, metadata)
    move_list <- parse_moves(movetext, df = df, state = state)
    game_list <- c(game_list, move_list)
    game_list
}

#' @rdname ppn_parsers
#' @export
alquerque_parser <- function(movetext = character(), 
                             metadata = list(), ...) {
    local_options(ppn.default_colored_bit_cfg = "alquerque")
    default_parser(movetext, metadata, ..., default_system = "alquerque")
}

#' @rdname ppn_parsers
#' @export
marble_parser <- function(movetext = character(), 
                          metadata = list(),
                          ...) {
    local_options(ppn.default_colored_bit_cfg = "marbles")
    default_parser(movetext, metadata, ..., default_system = "marbles")
}

df_none <- function() {
    tibble::tibble(piece_side = character(0L),
                   suit = integer(0L), rank = integer(0L),
                   cfg = character(0),
                   x = numeric(0), y = numeric(0), angle = numeric(0))
}

get_starting_df <- function(metadata, default_system = "piecepack") {
    setup <- metadata$SetUp
    if (!is.null(setup)) {
        return(get_starting_df_from_field(setup, default_system))
    }
    game_type <- metadata$GameType
    if (!is.null(game_type)) {
        return(get_starting_df_from_field(game_type, default_system))
    }
    return(initialize_df(df_none()))
}

get_starting_df_from_field <- function(field, default_system = "piecepack") {
    field0 <- field
    df <- tryCatch({
        if (is.character(field)) {
            df <- ppdf::setup_by_name(field, default_system, getter = ppn_get)
        } else if (is.list(field)) {
            names(field) <- normalize_name(names(field))
            if (!hasName(field, "system"))
                field$system <- default_system
            field$getter <- ppn_get
            df <- do.call(ppdf::setup_by_name, field)
        }
        initialize_df(df)
    }, error = function(e) {
        if (is.list(field))
            msg <- paste0("Couldn't process SetUp/GameType:\n", yaml::as.yaml(field0))
        else
            msg <- paste("Couldn't process SetUp/GameType:", field0)
        msg <- c(msg, i = e$message)
        abort(msg, class = "initialize_setup", parent = e)
    })
    return(df)
}

ppn_get <- function(name) {
    fn <- try(get(name, envir=getNamespace("ppdf")), silent = TRUE)
    if (inherits(fn, "try-error"))
        fn <- try(get(name, envir=getNamespace("piecenikr")), silent = TRUE)
    if (inherits(fn, "try-error"))
        fn <- tryCatch(dynGet(name), error = function(e) get(name))
    fn
}

initialize_df <- function(df) {
    df$id <- as.character(seq_len(nrow(df)))
    if (!hasName(df, "angle")) df$angle <- 0
    df$angle <- ifelse(is.na(df$angle), 0, df$angle)
    df$rank <- ifelse(is.na(df$rank), 1L, df$rank)
    df$suit <- ifelse(is.na(df$suit), 1L, df$suit)
    if (is.null(df[["cfg"]])) df$cfg <- "piecepack"
    df
}

create_state <- function(df, metadata = list()) {
    if (!is.null(attr(df, "scale_factor"))) {
        scale_factor <- attr(df, "scale_factor")
    } else {
        scale_factor <- 1.0
    }
    as.environment(list(df_move_start = df,
                        macros = c(metadata$Macros, attr(df, "macros"), macros),
                        max_id = nrow(df),
                        active_id = character(),
                        scale_factor = as.numeric(scale_factor)))
}
