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
#' @inheritParams textlint
#' @inheritParams init_textlintr
#' @param overwrite logical. If set `TRUE`, existing rules will be overwritten by the input rules.
#' @rdname update_lint_rules
#' @examples
#' \dontrun{
#' # Registrate all installed rules
#' update_lint_rules()
#' # Added a rule
#' update_lint_rules(rules = "common-misspellings", overwrite = FALSE)
#' # Overwite rules
#' update_lint_rules(rules = "common-misspellings", overwrite = TRUE)
#' }
#' @export
update_lint_rules <- function(rules = NULL, lintrc = ".textlintrc", overwrite = FALSE) { # nolint

  if (rlang::is_null(rules)) {
    l_rules <-
      sapply(
        dir(".textlintr/node_modules/", pattern = "^textlint-rule-"),
        function(x) gsub("textlint-rule-", "", x))

    names(l_rules) <-
      unname(l_rules)

  } else {
    l_rules <- as.list(rules)
    names(l_rules) <- rules
  }

  # Initialise
  if (rlang::is_false(file.exists(lintrc))) {
    writeLines(
      jsonlite::prettify(
        paste0(
          '{"rules": {',
          paste0("\"", l_rules, "\"", ": true", collapse = ","),
          '},"plugins": {"@textlint/markdown": {
      "extensions": [".Rmd"]}}}')),
      lintrc
    )
  } else {
    list_rules <-
      jsonlite::fromJSON(lintrc)

    l_rules <-
      lapply(l_rules, function(x) assign(x, TRUE))

    if (rlang::is_true(overwrite)) {
      list_rules$rules <- l_rules
    } else {
      list_rules$rules <-
        c(list_rules$rules, l_rules)
    }

    list_rules$rules <-
      as.list(list_rules$rules[unique(names(list_rules$rules))])

    jsonlite::write_json(
      list_rules,
      lintrc,
      auto_unbox = TRUE,
      pretty = TRUE
    )
  }
}
