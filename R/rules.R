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
      "editorconfig",
      "en-capitalization",
      "en-max-word-count",
      "first-sentence-length",
      "general-novel-style-ja",
      "ginger",
      "helper",
      "hyogai-onkun",
      "incremental-headers",
      "ja-hiragana-daimeishi",
      "ja-hiragana-fukushi",
      "ja-hiragana-hojodoushi",
      "ja-no-abusage",
      "ja-no-mixed-period",
      "ja-no-redundant-expression",
      "ja-no-weak-phrase",
      "ja-unnatural-alphabet",
      "ja-yahoo-kousei",
      "languagetool",
      "max-appearence-count-of-words",
      "max-comma",
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
      "no-empty-section",
      "no-exclamation-question-mark",
      "no-hankaku-kana",
      "no-mix-dearu-desumasu",
      "no-mixed-zenkaku-and-hankaku-alphabet",
      "no-nfd",
      "no-start-duplicated-conjunction",
      "no-surrogate-pair",
      "no-todo",
      "period-in-list-item",
      "prefer-tari-tari",
      "preset-ja-technical-writing",
      "preset-japanese",
      "preset-JTF-style",
      "prh",
      "report-node-types",
      "rousseau",
      "sentence-length",
      "sjsj",
      "spacing",
      "spellcheck-tech-word",
      "spellchecker",
      "stop-words",
      "terminology",
      "unexpanded-acronym",
      "web-plus-db",
      "write-good")

  x <-
    unlist(lapply(x, tolower))

  if (!is.null(rules))
    x <- rules[rules %in% c(x)]

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
#' @rdname add_rules
#' @examples
#' \dontrun{
#' add_rules("first-sentence-length")
#' # Skip already exist are ignored
#' add_rules(c("no-todo", "first-sentence-length"))
#' }
#' @export
add_rules <- function(rules = NULL) {

  if (rlang::is_null(rules))
    rlang::abort("Please give one or more target rules.\nYou can check rule list by rule_sets()") # nolint

  rules <-
    match_rules(rules)

  list_pkg <-
    jsonlite::fromJSON(".textlintr/package.json")

  # nolint start
  list_pkg$devDependencies <-
    purrr::set_names(c(unlist(list_pkg$devDependencies),
                       paste0("^", purrr::map_chr(rules, "version"))),
                     names(list_pkg$devDependencies),
                     purrr::map_chr(rules, "name"))

  list_pkg$devDependencies <-
    as.list(list_pkg$devDependencies[unique(names(list_pkg$devDependencies))])
  # nolint end

  jsonlite::write_json(
    list_pkg,
    ".textlintr/package.json",
    auto_unbox = TRUE,
    pretty = TRUE
  )
  exec_res <-
    paste0(system(paste(Sys.which("npm"),
                 "--prefix ./.textlintr install ./.textlintr"),
           intern = TRUE),
           collapse = "\n")
  if (length(exec_res) == 0)
    rlang::abort("Oops, can not install packages")
  else
    rlang::inform(crayon::green("installed packages"))
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
    paste0(".textlintr/node_modules/",
           purrr::map_chr(rules, "name")),
    dir.exists
  )

}
