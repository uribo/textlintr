context("test-textlint")

test_that("Check text", {

  skip_on_appveyor()
  withr::with_dir(
    tempdir(), {
      update_lint_rules(c("common-misspellings", "preset-jtf-style", "no-todo"))
      lint_res <-
        capture.output(textlint(system.file("sample.md", package = "textlintr"),
                                markers = FALSE))
      expect_length(lint_res, 6L)
    })
})
