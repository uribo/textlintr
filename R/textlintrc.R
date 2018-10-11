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

  if (is_installed_dependencies("textlint") == FALSE) {
    if (dir.exists(".textlintr") == FALSE) {
      dir.create(".textlintr")

      df_dep_rules <-
        match_rules(rules)

      jsonlite::write_json(
        list(
          name = "textlintr",
          version = "0.0.1",
          devDependencies =
            purrr::list_merge(
              textlint = "^11.0.0",
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
