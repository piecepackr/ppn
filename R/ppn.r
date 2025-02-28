#' Read PPN files
#'
#' Read/write Portable Piecepack Notation (PPN) files
#' @param file Filename, if "" will use `stdout()`
#' @param parse Logical of whether to parse the moves in the ppn file
#' @param games A list of parsed PPN games (as returned by `read_ppn()`)
#' @return A list, for each game in the file a list containing info about the game
#' @import stringr
#' @examples
#' list.files(system.file("ppn", package = "ppn"))
#' file <- system.file("ppn/tic-tac-toe.ppn", package = "ppn")
#' games <- read_ppn(file)
#' tmp <- tempfile(fileext = ".ppn")
#' write_ppn(games, tmp)
#' unlink(tmp)
#' @export
#' @seealso [plot_move()], [animate_game()], and [cat_move()] for visualizing parsed ppn games.
read_ppn <- function(file, parse = TRUE) {
    list_ppns <- parse_ppn_file(file)
    lapply(list_ppns, parse_ppn_game, parse = parse)
}

#' @rdname read_ppn
#' @export
write_ppn <- function(games = list(), file = "") {
    ppn <- unlist(lapply(games, as_ppn))
    if (file == "") file <- stdout()
    writeLines(ppn, file)
}

# Parse ppn files
#
# Parses ppn file
# @param file Filename
# @return A list, each element is a character vector containing the text of the PPN games within that file
parse_ppn_file <- function(file) {
    text <- readlines_ppn(file)
    parse_contents(text)
}

parse_contents <- function(text) {
    game_starts <- grep("^-{3}", text)
    if (length(game_starts) == 0L || game_starts[1L] != 1L) {
        game_starts <- c(1L, game_starts)
    }
    game_ends <- c(game_starts[-1L]-1L, length(text))
    contents <- list()
    for (ii in seq(game_starts)) {
        contents[[ii]] <- text[game_starts[ii]:game_ends[ii]]
    }
    contents
}

readlines_ppn <- function(file) {
    tryCatch({
        readLines(file)
    }, warning = function(w) {
        abort(w$message, class = "readlines_ppn", parent = w)
    }, error = function(e) {
        msg <- paste("Couldn't read the file", file)
        msg <- c(msg, i = e$message)
        abort(msg, class = "readlines_ppn", parent = e)
    })
}

# Parse ppn game
#
# Parses (single) ppn game text to get Metadata and Movetext
# @param text Character vector of ppn game text
# @return A list with a named list element named `Metadata`
#         and character vector element named `Movetext`
parse_ppn_game <- function(text, parse = TRUE) {
    l <- extract_metadata_movetext(text)
    if (parse) {
        parse_movetext(l$movetext, l$metadata)
    } else {
        list(metadata = l$metadata, movetext = l$movetext)
    }
}

extract_metadata_movetext <- function(text) {
    yaml_end <- grep("^\\.{3}", text)
    if (length(yaml_end) == 0L) {
        yaml_end <- grep("^[[:blank:]]+|^$", text)
    }
    if (length(yaml_end) > 0L) {
        metadata <- yaml_load(text[1L:yaml_end[1L]])
        if (yaml_end[1]<length(text)) {
            movetext <- text[(yaml_end[1L]+1L):length(text)]
        } else {
            movetext <- character()
        }
    } else {
        metadata <- list()
        movetext <- text
    }
    if (is.null(metadata))
        metadata <- list()
    if (!is.list(metadata)) {
        text <- paste(paste("  ", yaml::as.yaml(metadata), collapse = "\n"))
        msg <- c("The PPN metadata does not appear to be a YAML dictionary",
                 i = paste("The PPN metadata is:\n", text))
        abort(msg, class = "extract_metadata")
    }
    list(metadata = metadata, movetext = movetext)
}

yaml_load <- function(text) {
    tryCatch(yaml::yaml.load(text),
             warning = function(w) {
                abort(w$message, class = "yaml_load")
             },
             error = function(e) {
                text <- paste(paste(" ", text), collapse = "\n")
                msg <- c("YAML parsing error:", i = e$message,
                         i = paste("Failed to parse the following YAML text:\n", text))
                abort(msg, class = "yaml_load")
             })
}

parse_movetext <- function(movetext, metadata) {
    parser <- metadata$MovetextParser
    if (is.null(parser)) {
        default_parser(movetext, metadata)
    } else {
        if (is.character(parser)) {
            parser_name <- parser
            .l <- list()
        } else if (is.list(parser)) {
            names(parser) <- normalize_name(names(parser))
            i_name <- which("name" %in% names(parser))
            parser_name <- parser[["name"]]
            .l <- parser[-i_name]
        }
        fn_name <- paste0(normalize_name(parser_name), "_parser")
        fn <- tryCatch(
            ppn_get(fn_name),
            error = function(e1) {
                tryCatch({
                    fn_name_deprecated <- paste0("parser_", normalize_name(parser_name))
                    fn <- ppn_get(fn_name_deprecated)
                    .Deprecated(fn_name, old = fn_name_deprecated)
                    fn
                }, error = function(e2) e1)
            })
        .l$movetext <- movetext
        .l$metadata <- metadata
        do.call(fn, .l)
    }
}
