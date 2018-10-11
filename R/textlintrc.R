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

  if (rlang::is_false(is_installed_dependencies("npm")))
    rlang::abort("Can not find: npm") # nocov

  if (is_installed_dependencies("textlint") == FALSE) {
    if (dir.exists(".textlintr") == FALSE) {
      dir.create(".textlintr")

      file.copy(system.file("js/package.json",
                            package = "textlintr"),
                ".textlintr/package.json",
                overwrite = TRUE)
      processx::run(Sys.which("npm"),
                    args = c("install"),
                    wd = ".textlintr")
      update_lint_rules(rules)
      writeLines("*\n!/.gitignore",
                 ".textlintr/.gitignore")
      rlang::inform(
        crayon::green("Yeah! Install was successful"))

    } else {
      rlang::inform("Already, exits textlint.js")
    }
  }
}

#' Update .textlintrc
#'
#' @description Update the rule file (`.texlintrc`) which textlint checks.
#' To adopt the rule of the character string specified as argument. When
#' `NULL` is given, all installed rules are applied.
#' @inherit init_textlintr
#' @rdname update_lint_rules
#' @examples
#' \dontrun{
#'
#' update_lint_rules()
#' update_lint_rules(rules = "common-misspellings")
#' }
#' @export
update_lint_rules <- function(rules = NULL) {

  if (rlang::is_null(rules))
    rules <-
      sapply(
        dir(".textlintr/node_modules/", pattern = "^textlint-rule-"),
        function(x) gsub("textlint-rule-", "", x))

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
