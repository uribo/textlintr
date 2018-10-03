context("test-textlint-ecosystems")

test_that("Get started", {
  expect_true(
    is_installed_dependencies("npm")
  )
  expect_false(
    is_installed_dependencies("textlint")
  )
  skip_on_travis()
  skip_on_appveyor()
  expect_false(
    is_installed_dependencies("yarn")
  )
})

test_that("We enable modify a .textlintrc", {
  withr::with_dir(
    tempdir(), {
      update_lint_rules(rules = "common-misspellings")
      expect_equal(
        nchar(paste(readLines(".textlintrc"), collapse = "")),
        180L
      )
    })
  withr::with_dir(
    tempdir(), {
      update_lint_rules(c("common-misspellings", "no-todo", "preset-jtf-style"))
      expect_equal(
        nchar(paste(readLines(".textlintrc"), collapse = "")),
        237L
      )
    })
})
