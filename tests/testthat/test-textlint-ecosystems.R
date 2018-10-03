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

test_that("Activate on textlint", {

  withr::with_dir(
    tempdir(), {
      skip_if(dir.exists(".textlintr"))
      expect_false(
        dir.exists(".textlintr")
      )
      init_textlintr()
      expect_true(
        dir.exists(".textlintr")
      )
      expect_message(
        init_textlintr(),
        "Already, exits textlint.js"
      )

      textlint_res_raw <-
        processx::run(
          command = ".textlintr/node_modules/textlint/bin/textlint.js",
          args = c("-f", "json",
                   normalizePath(
                     system.file("sample.md", package = "textlintr"))),
          error_on_status = FALSE)
      expect_is(
        textlint_res_raw,
        "list"
      )
      expect_length(
        textlint_res_raw,
        4
      )
    }
  )
})
