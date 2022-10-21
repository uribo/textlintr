################################
# last update: 2022-10-21
################################
library(magrittr)

x <-
  rvest::read_html("https://github.com/textlint/textlint/wiki/Collection-of-textlint-rule")

rules <-
  x %>%
  rvest::html_elements(css = "#wiki-body > div.markdown-body > h4 > a") %>%
  rvest::html_text() %>%
  stringr::str_subset("^textlint-rule") %>%
  stringr::str_remove("textlint-rule-") %>%
  ensurer::ensure(length(.) == 81L)

# 出力内容をrules.R rule_sets()に与える
# rules %>%
#   sort() %>%
#   dput()


# usethis::use_data(rule_sets, overwrite = TRUE)
