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
      p <-
        processx::process$new("npm", "--version", stdout = "|", stderr = "|")
      expect_equal(
        p$get_exit_status(),
        0)
      expect_identical(
        p$read_all_output(),
        "6.4.1\n")
    }
  )
})
