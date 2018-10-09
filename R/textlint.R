#' Textlint a given file
#'
#' @param file filename whose target to textlint
#' @param lintrc file path to .textlintrc. Default, searcing from current directory.
#' @param markers modified output format. If `true`, the result of lint is
#' displayed in RStudio's marker panel (Only when running with RStudio version higher
#' than 0.99.225).
#' @rdname textlint
#' @examples
#' \dontrun{
#' lint_target <-
#'   system.file("sample.md", package = "textlintr")
#' textlint(lint_target)
#' }
#' @export
textlint <- function(file = NULL, lintrc = ".textlintrc", markers = TRUE) {

  input_full_path <-
    normalizePath(file)

  lint_res <-
    lint_exec(input_full_path, lintrc, "json")

  lint_res_parsed <-
    lint_parse(lint_res)

  lint_summary(lint_res_parsed)
  if (lint_res$status == 0L) {
    rlang::inform(
      crayon::green("Great! There is no place to modify."))

  } else if (rstudioapi::hasFun("sourceMarkers") & rlang::is_true(markers)) {
    rstudio_source_markers(input_full_path, lint_res_parsed) # nocov
  } else {
    lint_result_cli(input_full_path, lint_res_parsed)
  }
}

lint_exec <- function(file = NULL, lintrc = ".textlintrc",
                      format = c("json", "checkstyle", "compact", "jslint-xml",
                                 "junit", "pretty-error", "stylish",
                                 "table", "tap", "unix")) {
  check_rule_exist(lintrc)

  rlang::arg_match(format)
  input_full_path <-
    normalizePath(file)

  exec_textlint_path <-
    if (is_installed_dependencies("textlint") == FALSE) {
      if (file.exists(".textlintr/node_modules/textlint/bin/textlint.js") == TRUE) { # nolint
        ".textlintr/node_modules/textlint/bin/textlint.js"
      } else {
        rlang::abort("Setup is not complete or textlint is not installed in the global.\nFirst, use init_textlintr() to install textlint.") # nocov nolint
      }
    } else {
      "textlint" # nocov
    }

  if (rlang::is_true(length(format) > 1)) {
    rlang::warn("The string to give to format must be one.\n'json' is forcibly applied.")
    format <- "json"
  }

  lint_res <-
    processx::run(command = exec_textlint_path,
                  args = c("-f", format, input_full_path),
                  error_on_status = FALSE,
                  echo = FALSE)

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

rstudio_source_markers <- function(input_full_path, lint_res_parsed) {
  #nocov start
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
  # nocov end
}

lint_result_cli <- function(input_full_path, lint_res_parsed) {

  if (is.data.frame(lint_res_parsed)) {
    cat(paste0("In: ", crayon::underline(input_full_path)))
    cli::cat_line()
    for (i in seq_len(nrow(lint_res_parsed))) {
      cat(paste0(crayon::silver(paste(cli::symbol$tick,
                                      lint_res_parsed$ruleId[i])), # nolint
                 ": ",
                 crayon::red(lint_res_parsed$message[i]),
                 paste("\n",
                       cli::symbol$arrow_right,
                       paste0(input_full_path, lint_res_parsed$line[i],
                              ":",
                              lint_res_parsed$column[i])),
                 "\n"))
    }
  }
}

lint_summary <- function(lint_res_parsed) {

  n_warns <-
    ifelse(is.data.frame(lint_res_parsed), nrow(lint_res_parsed), 0L)

  cat(paste(
    crayon::green("1 inputs", cli::symbol$tick),
    ifelse(
      n_warns >= 1,
      crayon::yellow(paste0(n_warns, " warnings"), cli::symbol$warning),
      crayon::green(paste0(n_warns, " warnings"), cli::symbol$tick)
    ),
    sep = " | "
  ))
  cli::cat_line()
}
