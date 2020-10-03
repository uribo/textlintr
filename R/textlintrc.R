#' Initialise a textlint
#'
#' @param rules the name of rule; see [rule_sets()] and [https://github.com/textlint/textlint/wiki/Collection-of-textlint-rule](https://github.com/textlint/textlint/wiki/Collection-of-textlint-rule).
#' @rdname init_textlintr
#' @examples
#' \dontrun{
#' init_textlintr()
#' }
#' @export
init_textlintr <- function(rules = "common-misspellings") {
  if (rlang::is_false(is_available_npm()))
    rlang::abort("Can not find: npm") # nocov
  # Install textlit, rules, and copy .textlintr
  if (rlang::is_false(is_available_textlint())) {
    packer::npm_install("textlint", scope = "dev")
    df_dep_rules <-
        match_rules(rules)
    packer::npm_install(purrr::map_chr(df_dep_rules,
                                       "name"),
                        scope = "dev")
    update_lint_rules(rules)
    rlang::inform(crayon::green("Yeah! Install was successful"))
    } else {
    rlang::inform(crayon::cyan("Already, exits textlint.js"))
  }
}

#' Update .textlintrc
#'
#' @description Update the rule file (`.texlintrc`) which textlint checks.
#' To adopt the rule of the character string specified as argument. When
#' `NULL` is given, all installed rules are applied.
#' @inheritParams textlint
#' @inheritParams init_textlintr
#' @param overwrite logical. If set `TRUE`, existing rules will be overwritten
#' by the input rules.
#' @inheritParams is_available_textlint
#' @rdname update_lint_rules
#' @examples
#' \dontrun{
#' # Register all installed rules
#' update_lint_rules()
#' # Added a rule
#' update_lint_rules(rules = "common-misspellings", overwrite = FALSE)
#' # Overwrite rules
#' update_lint_rules(rules = "common-misspellings", overwrite = TRUE)
#' }
#' @export
update_lint_rules <- function(rules = NULL, lintrc = ".textlintrc", overwrite = FALSE, .node_module_path = NULL) { # nolint
  # Combine rule-sets
  if (rlang::is_null(rules)) {
    l_rules <-
      sapply(
        dir(gsub("textlint/.+",
                 "",
                purrr::pluck(check_dependencies_available(.node_module_path),
                             "textlint_path")),
            pattern = "^textlint-rule-"),
        function(x) gsub("textlint-rule-", "", x))
    names(l_rules) <-
      unname(l_rules)
  } else {
    rule <-
      gsub("textlint-rule-", "", rules)
    l_rules <-
      as.list(rule)
    names(l_rules) <-
      rules
  }
  # Initialise .textlintrc
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
      jsonlite::read_json(lintrc, auto_unbox = TRUE)
    l_rules <-
      lapply(l_rules, function(x) assign(x, TRUE))
    if (rlang::is_true(overwrite)) {
      list_rules$rules <-
        l_rules
    } else {
      # append
      list_rules$rules <-
        c(list_rules$rules, l_rules)
    }
    list_rules$rules <-
      as.list(list_rules$rules[unique(names(list_rules$rules))])
    list_rules$rules <-
      purrr::modify_if(list_rules$rules,
                       is.list,
                       ~ purrr::modify_depth(.x, 1, ~ I(.x)))
    jsonlite::write_json(
      list_rules,
      lintrc,
      auto_unbox = TRUE,
      pretty = TRUE
    )
  }
}
