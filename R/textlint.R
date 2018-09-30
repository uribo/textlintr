#' Textlint a given file
#'
#' @param file filename whose target to textlint
#' @param lintrc file path to .textlintrc. Default, searcing from current directory.
#' @rdname textlint
#' @export
textlint <- function(file = NULL, lintrc = ".textlintrc") {

  if (rlang::is_false(file.exists(lintrc)))
    rlang::abort("Missing .textlintrc")

  input_full_path <-
    normalizePath(file)

  lint_res <-
    processx::run(command = "textlint",
                  args = c("-f", "json", input_full_path),
                  error_on_status = FALSE)

  lint_res <-
    gsub(
      paste0(",\"filePath\":\"", input_full_path, "\"\\}\\]"),
      "",
      gsub("\\[\\{\"messages\":", "", lint_res$stdout))

  lint_res_parsed <-
    jsonlite::fromJSON(lint_res)

  markers <-
    unname(apply(lint_res_parsed, 1, function(x) {
      marker <- list()
      marker$type <- "style"
      marker$file <- input_full_path
      marker$line <- as.numeric(x["line"])
      marker$column <- as.numeric(x["column"])
      marker$message <- x["message"]
      marker
    }))

  rstudioapi::callFun("sourceMarkers",
                      name       = "textlintr",
                      markers    = markers,
                      basePath   = NULL,
                      autoSelect = "first")
}
