context("test-rules")

test_that("Available rules", {

  res <-
    rule_sets(rules = c("common-misspellings", "preset-jtf-style"))
  expect_length(
    res, 2L
  )
  expect_equal(
    sort(res),
    c("common-misspellings", "preset-jtf-style")
  )

  res <-
    rule_sets(NULL)
  expect_length(
    res,
    66L
  )

})

test_that(".textlintrc works", {

  expect_error(
    configure_lint_rules(lintrc = "textlintrc"),
    "Missing .textlintrc."
  )

  withr::with_dir(
    tempdir(), {
      expect_error(
        update_lint_rules(rules = ""),
        "Please specify at least one rule."
      )

      update_lint_rules(rules = c("common-misspellings",
                                  "preset-jtf-style"))
      res <-
        configure_lint_rules(".textlintrc", open = FALSE)
      expect_is(res, "list")
      expect_length(res, 2)
      expect_named(res, c("common-misspellings",
                          "preset-jtf-style"))
      update_lint_rules(rules = c("preset-ja-technical-writing"))
      res <-
        configure_lint_rules()
      expect_named(res, c("preset-ja-technical-writing"))
      expect_true(res[[1]])
    }
  )
})
