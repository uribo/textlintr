#' Config textlint rule file
#'
#' @inheritParams textlint
#' @param open If you want to modify a `.textlintrc`, set `TRUE`. (deafult `FALSE`)
#' @rdname textlint_rules
#' @examples
#' \dontrun{
#' configure_lint_rules()
#' }
#' @return list
#' @export
configure_lint_rules <- function(lintrc = ".textlintrc", open = FALSE) {

  check_rule_exist(lintrc)

  # nocov start
  if (rlang::is_true(open))
    if (rlang::is_true(rstudioapi::isAvailable()))
      rstudioapi::navigateToFile(lintrc)
  else
    utils::edit(lintrc)
  # nocov end

  jsonlite::read_json(lintrc)[["rules"]]

}

check_rule_exist <- function(lintrc = ".textlintrc") {
  if (rlang::is_false(file.exists(lintrc)))
    rlang::abort(
      crayon::red("Missing .textlintrc.\nYou can setup by",
                  crayon::bold("update_lint_rules()")))
}
