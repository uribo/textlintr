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
    lint_exec(file, lintrc)

  lint_res_parsed <-
    lint_parse(lint_res)

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

lint_exec <- function(file = NULL, lintrc = ".textlintrc") {
  if (rlang::is_false(file.exists(lintrc)))
    rlang::abort("Missing .textlintrc")

  input_full_path <-
    normalizePath(file)

  lint_res <-
    processx::run(command = "textlint",
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
