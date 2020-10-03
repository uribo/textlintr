# context("test-textlint")
#
# test_that("Check text", {
#   skip_on_appveyor()
#   withr::with_dir(
#     tempdir(), {
#       expect_silent(
#         update_lint_rules(
#           c("common-misspellings", "preset-jtf-style", "no-todo"),
#           overwrite = TRUE)
#       )
#       lint_res <-
#         capture.output(textlint(system.file("sample.md", package = "textlintr"),
#                                 markers = FALSE))
#       expect_length(lint_res, 6L)
#       expect_message(
#         textlint(system.file("sample-correct.md", package = "textlintr"),
#                  markers = FALSE)
#       )
#       lint_res <-
#         capture.output(
#           textlint(system.file("sample-correct.md", package = "textlintr"),
#                    markers = FALSE))
#       expect_length(lint_res, 2L)
#       expect_equal(
#         lint_res[1],
#         "1 inputs \u2713 | 0 warnings \u2713"
#       )
#       expect_identical(
#         lint_exec(system.file("sample-correct.md", package = "textlintr"),
#                   format = c("json")),
#         expect_warning(
#           lint_exec(system.file("sample-correct.md", package = "textlintr"),
#                     format = c("json", "pretty-error")
#         )
#         )
#       )
#     })
# })
#
# test_that("Works, another rule files", {
#   skip_on_appveyor()
#   withr::with_dir(
#     tempdir(), {
#       lint_res <-
#         capture.output(
#           textlint(system.file("sample.md", package = "textlintr"),
#                    lintrc = system.file(
#                      "textlintrc-samples/textlintrc-prh.yml",
#                      package = "textlintr"),
#                    markers = FALSE))
#       expect_equal(
#         lint_res[1],
#         "1 inputs \u2713 | 3 warnings !"
#       )
#       expect_length(
#         lint_res,
#         8L
#       )
#     })
# })
