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
      expect_message(
        textlint(system.file("sample-correct.md", package = "textlintr"),
                 markers = FALSE)
      )
      lint_res <-
        capture.output(
          textlint(system.file("sample-correct.md", package = "textlintr"),
                   markers = FALSE))
      expect_length(lint_res, 1L)
      expect_equal(
        lint_res,
        "1 inputs \u2714 | 0 warnings \u2714"
      )
      expect_identical(
        lint_exec(system.file("sample-correct.md", package = "textlintr"),
                  format = c("json")),
        expect_warning(
          lint_exec(system.file("sample-correct.md", package = "textlintr"),
                    format = c("json", "pretty-error")
        )
        )
      )
    })
})
