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

test_that("Activate on textlint", {

  withr::with_dir(
    tempdir(), {
      expect_equal(
        system("npm --version", intern = TRUE),
        "6.4.1"
      )
    }
  )
  withr::with_dir(
    tempdir(), {
      expect_message(
        init_textlintr(c("common-misspellings",
                         "preset-jtf-style",
                         "no-todo")),
        "Install was successful"
      )
      expect_true(
        dir.exists(".textlintr")
      )
      expect_true(
        file.exists(".textlintr/node_modules/textlint/bin/textlint.js")
      )
      expect_silent(
        check_rule_exist()
      )
      expect_message(
        init_textlintr(),
        "Already, exits textlint.js"
      )
    }
  )
})
