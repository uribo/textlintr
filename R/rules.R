check_rule_exist <- function(lintrc = ".textlintrc") {
  if (rlang::is_false(file.exists(lintrc)))
    rlang::abort(
      crayon::red("Missing .textlintrc.\nYou can setup by",
                  crayon::bold("update_lint_rules()")))
}
