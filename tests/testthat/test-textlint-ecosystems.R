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
      skip_if(dir.exists(".textlintr/"))
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
      expect_match(
        processx::run("ls", c("-l", Sys.which("npm")))[[2]],
        "lrwxrwxrwx 1 root root .+ /usr/bin/npm -> ../lib/node_modules/npm/bin/npm-cli.js\n"
      )
    }
  )
})
