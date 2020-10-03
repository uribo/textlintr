#' Check textlint running environment
#' @inheritParams is_available_textlint
#' @export
#' @examples
#' \dontrun{
#' is_available_textlint()
#' }
#' @rdname check_dependencies
check_dependencies_available <- function(.node_module_path = NULL) {
  list(
    node = is_available_node(),
    npm = is_available_npm(),
    textlint = is_available_textlint(.node_module_path),
    textlint_path = search_textlint_path(.node_module_path)
  )
}

is_available_npm <- function() {
  if (nchar(Sys.which("npm")) == 0L) {
    FALSE
  } else {
    TRUE
  }
}
is_available_node <- function() {
  if (nchar(Sys.which("node")) == 0L) {
    FALSE
  } else {
    TRUE
  }
}

#' Test for the existence of textlint as a prerequisite
#' @param .node_module_path By default, it refers to the global path
#' and local directory. If an arbitrary path is given, it refers to that path.
#' @rdname is_available_textlint
#' @examples
#' \dontrun{
#' is_available_textlint()
#' }
#' @export
is_available_textlint <- function(.node_module_path = NULL) {
  if (is_available_npm() == FALSE) {
    rlang::inform("Please make sure that npm is available.")
    FALSE
  } else {
    if (is.null(.node_module_path) == FALSE) {
      if (
        sum(grepl("^textlint$",
                  list.files(.node_module_path))) == 1L) {
        TRUE
      }
    } else {
        if (sum(grepl("^textlint$",
                      list.files(search_npm_root_path()))) == 1L) {
          TRUE
        } else {
          if (sum(grepl("^textlint$",
                        list.files("node_modules"))) == 1L) {
            TRUE
          } else {
            FALSE
          }
        }
    }
  }
}

search_npm_root_path <- function() {
  if (is_available_npm() == FALSE) {
    rlang::inform("Please make sure that npm is available.")
  } else {
    res <-
      processx::run(command = Sys.which("npm"),
                  args = c("root", "-g"),
                  error_on_status = FALSE,
                  echo = FALSE)
    gsub("\n", "", res$stdout)
  }
}

find_textlintjs <- function(path) {
  grep(
    "bin/textlint.js",
    list.files(
      grep("/textlint$",
           list.files(path,
                      full.names = TRUE),
           value = TRUE),
      all.files = TRUE,
      full.names = TRUE,
      recursive = TRUE
    ),
    value = TRUE
  )
}

search_textlint_path <- function(.node_module_path = NULL) {
  if (rlang::is_true(is_available_textlint(.node_module_path))) {
    if (is.null(.node_module_path) == FALSE) {
      res <-
        find_textlintjs(.node_module_path)
    } else {
      res <-
        find_textlintjs(search_npm_root_path())
      if (length(res) == 0L) {
        res <-
          find_textlintjs(path = "node_modules/")
      }
    }
    res
  } else {
    rlang::inform("Check, textlint install first.")
  }
}
