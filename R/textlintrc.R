#' Initialise a textlint
#'
#' @param rules lint rule
#' @rdname init_textlintr
#' @examples
#' \dontrun{
#' init_textlintr()
#' }
#' @export
init_textlintr <- function(rules = "common-misspellings") {
  if (is_installed_dependencies("textlint") == FALSE) {
    if (dir.exists(".textlintr") == FALSE) {
      dir.create(".textlintr")

      file.copy(system.file("js/package.json",
                            package = "textlintr"),
                ".textlintr/package.json",
                overwrite = TRUE)
      processx::run("npm",
                    args = c("install"),
                    wd = ".textlintr")
      update_lint_rules(rules)
      writeLines("*\n!/.gitignore",
                 ".textlintr/.gitignore")

    } else {
      rlang::inform("Already, exits textlint.js")
    }
  }
}

#' Update .textlintrc
#' @inherit init_textlintr
#' @rdname update_lint_rules
#' @examples
#' \dontrun{
#' update_lint_rules(rules = "common-misspellings")
#' }
#' @export
update_lint_rules <- function(rules = "common-misspellings") {

  if (nchar(rules)[1] == 0)
    rlang::abort("Please specify at least one rule.")

  writeLines(
    jsonlite::prettify(
      paste0(
        '{"rules": {',
        paste0("\"", rules, "\"", ": true", collapse = ","),
        '},"plugins": {"@textlint/markdown": {
      "extensions": [".Rmd"]}}}')),
    ".textlintrc"
  )
}
