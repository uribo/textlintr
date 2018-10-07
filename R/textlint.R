#' Textlint a given file
#'
#' @param file filename whose target to textlint
#' @param lintrc file path to .textlintrc. Default, searcing from current directory.
#' @rdname textlint
#' @examples
#' \dontrun{
#' lint_target <-
#'   system.file("sample.md", package = "textlintr")
#' textlint(lint_target)
#' }
#' @export
textlint <- function(file = NULL, lintrc = ".textlintrc") {

  input_full_path <-
    normalizePath(file)

  lint_res <-
    lint_exec(input_full_path, lintrc)

  lint_res_parsed <-
    lint_parse(lint_res)

  if (rlang::is_false(is.data.frame(lint_res_parsed))) {
    rlang::inform("Great! There is no place to modify. ")
  } else {

    markers <-
      unname(apply(lint_res_parsed, 1, function(x) {
        marker <- list()
        marker$type <- "style"
        marker$file <- input_full_path
        marker$line <- as.numeric(x["line"])
        marker$column <- as.numeric(x["column"])
        marker$message <- as.character(x["message"])
        marker
      }))

    rstudioapi::callFun("sourceMarkers",
                        name       = "textlintr",
                        markers    = markers,
                        basePath   = NULL,
                        autoSelect = "first")
  }
}

lint_exec <- function(file = NULL, lintrc = ".textlintrc") {
  if (rlang::is_false(file.exists(lintrc)))
    rlang::abort("Missing .textlintrc.\nYou can setup by update_lint_rules()")

  input_full_path <-
    normalizePath(file)

  exec_textlint_path <-
    if (is_installed_dependencies("textlint") == FALSE) {
      if (file.exists(".textlintr/node_modules/textlint/bin/textlint.js") == TRUE) { # nolint
        ".textlintr/node_modules/textlint/bin/textlint.js"
      } else {
        rlang::abort("Setup is not complete or textlint is not installed in the global.\nFirst, use init_textlintr() to install textlint.") # nolint
      }
    } else {
      "textlint"
    }

  lint_res <-
    processx::run(command = exec_textlint_path,
                  args = c("-f", "json", input_full_path),
                  error_on_status = FALSE)

  lint_res$input_full_path <-
    input_full_path

  lint_res
}

lint_parse <- function(lint_res) {
  lint_res <-
    gsub(
      paste0(",\"filePath\":\"", lint_res$input_full_path, "\"\\}\\]"),
      "",
      gsub("\\[\\{\"messages\":", "", lint_res$stdout))

  jsonlite::fromJSON(lint_res)
}
