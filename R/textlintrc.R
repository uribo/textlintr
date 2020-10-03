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

  if (rlang::is_false(is_installed_dependencies("npm")))
    rlang::abort("Can not find: npm") # nocov

  # Install textlit, rules, and copy .textlintr
  if (rlang::is_false(is_installed_dependencies("textlint"))) {
      dir.create(".textlintr")

      df_dep_rules <-
        match_rules(rules)

      jsonlite::write_json(
        list(
          name = "textlintr",
          version = "0.0.1",
          devDependencies =
            purrr::list_merge(
              textlint = "^11.2.5",
              purrr::set_names(purrr::map(
                purrr::map(df_dep_rules, "version"),
                ~ paste0("^", .)),
                purrr::map(df_dep_rules, "name"))
            )
        ),
        ".textlintr/package.json",
        auto_unbox = TRUE,
        pretty = TRUE
      )

      system(paste(Sys.which("npm"),
                   "--prefix ./.textlintr install ./.textlintr"))
      update_lint_rules(rules)
      writeLines("*\n!/.gitignore",
                 ".textlintr/.gitignore")
      rlang::inform(
        crayon::green("Yeah! Install was successful"))

    } else {
      rlang::inform("Already, exits textlint.js")
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
#' # Register all installed rules
#' update_lint_rules()
#' # Added a rule
#' update_lint_rules(rules = "common-misspellings", overwrite = FALSE)
#' # Overwrite rules
#' update_lint_rules(rules = "common-misspellings", overwrite = TRUE)
#' }
#' @export
update_lint_rules <- function(rules = NULL, lintrc = ".textlintrc", overwrite = FALSE) { # nolint

  # Combine rule-sets
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
      list_rules$rules <- l_rules
    } else {
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
