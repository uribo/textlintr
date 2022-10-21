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

rule_normalise <- function(rules = NULL) {
  purrr::modify_if(
    rules,
      .p = function(.x) {
        grepl("^textlint-(rule)",
              .x)
      },
      .f = function(.x) {
        gsub(pattern = "textlint-rule-",
             replacement = "",
             x = .x)
      }
    )
}

#' Available rule names
#'
#' @inheritParams init_textlintr
#' @rdname rule_sets
#' @examples
#' rule_sets(rules = c("common-misspellings", "preset-jtf-style"))
#' @export
rule_sets <- function(rules = NULL) {
  x <-
    c(
      "a3rt-proofreading",
      "abbr-within-parentheses",
      "alex",
      "apostrophe",
      "common-misspellings",
      "date-weekday-mismatch",
      "diacritics",
      "doubled-spaces",
      "editorconfig",
      "en-capitalization",
      "en-max-word-count",
      "en-spell",
      "first-sentence-length",
      "footnote-order",
      "general-novel-style-ja",
      "ginger",
      "helper",
      "incremental-headers",
      "ja-hiragana-fukushi",
      "ja-hiragana-hojodoushi",
      "ja-hiragana-keishikimeishi",
      "ja-joyo-or-jinmeiyo-kanji",
      "ja-kyoiku-kanji",
      "ja-no-abusage",
      "ja-no-inappropriate-words",
      "ja-no-mixed-period",
      "ja-no-orthographic-variants",
      "ja-no-redundant-expression",
      "ja-no-weak-phrase",
      "ja-simple-user-dictionary",
      "ja-unnatural-alphabet",
      "ja-yahoo-kousei",
      "jis-charset",
      "joyo-kanji",
      "languagetool",
      "max-appearence-count-of-words",
      "max-comma",
      "max-doc-width",
      "max-kanji-continuous-len",
      "max-length-of-title",
      "max-number-of-lines",
      "max-ten",
      "ng-word",
      "no-dead-link",
      "no-double-negative-ja",
      "no-doubled-conjunction",
      "no-doubled-conjunctive-particle-ga",
      "no-doubled-joshi",
      "no-dropping-the-ra",
      "no-empty-element",
      "no-empty-section",
      "no-exclamation-question-mark",
      "no-hankaku-kana",
      "no-hoso-kinshi-yogo",
      "no-mix-dearu-desumasu",
      "no-mixed-zenkaku-and-hankaku-alphabet",
      "no-nfd",
      "no-start-duplicated-conjunction",
      "no-surrogate-pair",
      "no-todo",
      "no-zero-width-spaces",
      "period-in-list-item",
      "prefer-tari-tari",
      "preset-ja-engineering-paper",
      "preset-ja-spacing",
      "preset-ja-technical-writing",
      "preset-japanese",
      "preset-jtf-style",
      "prh",
      "report-node-types",
      "rousseau",
      "sentence-length",
      "sjsj",
      "spellchecker",
      "spelling",
      "stop-words",
      "terminology",
      "unexpanded-acronym",
      "use-si-units",
      "write-good",
      "zh-half-and-full-width-bracket"
    )
  x <-
    unlist(lapply(x, tolower))
  if (!is.null(rules)) {
    rules <-
      rule_normalise(rules)
    x <- rules[rules %in% c(x)]
  }
  x
}

match_rules <- function(rules) {
  search_res <-
    lapply(rule_sets(rules),
           function(x) {
             paste0(system(paste(Sys.which("npm"),
                                 "search", "--json", x),
                           intern = TRUE),
                    collapse = "\n")
           })
    purrr::map(purrr::map(
      purrr::keep(search_res, ~ length(.x) != 0),
      ~ jsonlite::fromJSON(.)[c("name", "version")]),
      ~ subset(.x, grepl("^textlint-rule-", .x$name)))
}

#' Install textlint rule modules
#'
#' @inheritParams init_textlintr
#' @param scope 'global' or 'dev.
#' @rdname add_rules
#' @examples
#' \dontrun{
#' add_rules("first-sentence-length", "dev")
#' # Skip already exist are ignored
#' add_rules(c("no-todo", "first-sentence-length"), scope = "dev")
#' # Global install
#' add_rules("first-sentence-length", "global")
#' }
#' @export
add_rules <- function(rules = NULL, scope = c("dev", "global")) {
  if (rlang::is_null(rules))
    rlang::abort("Please give one or more target rules.\nYou can check rule list by rule_sets()") # nolint
  rules <-
    purrr::map_chr(match_rules(rules),
                   "name")
  packer::npm_install(rules,
                      scope = scope)
}

#' Check if rule is installed
#'
#' @inheritParams init_textlintr
#' @rdname is_rule_exist
#' @examples
#' \dontrun{
#' is_rule_exist("no-todo")
#' is_rule_exist("first-sentence-length")
#' }
#' @export
is_rule_exist <- function(rules) {
  rules <-
    match_rules(rules)
  purrr::map_lgl(
    paste0(gsub("textlint/.+",
                "",
                search_textlint_path()),
           purrr::map_chr(rules, "name")),
    dir.exists)
}
