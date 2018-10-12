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

  skip_on_appveyor()
  withr::with_dir(
    tempdir(), {
      init_textlintr(c("common-misspellings",
                       "preset-jtf-style",
                       "no-todo"))
      expect_true(
        dir.exists(".textlintr")
      )
      expect_message(
        init_textlintr(),
        "Already, exits textlint.js"
      )
      writeLines(
        jsonlite::prettify(
          paste0(
            '{"rules": {',
            paste0("\"", "common-misspellings", "\"", ": true", collapse = ","),
            '},"plugins": {"@textlint/markdown": {
      "extensions": [".Rmd"]}}}')),
        ".textlintrc"
      )
      textlint_res_raw <-
        processx::run(
          command = ".textlintr/node_modules/textlint/bin/textlint.js",
          args = c("-f", "json",
                   "--rule", "common-misspellings",
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
      expect_equal(
        textlint_res_raw$status,
        1
      )
      expect_match(
        textlint_res_raw$stdout,
        ".messages.+type.+lint.+ruleId.+common-misspellings"
      )
      skip_if(dir.exists(".textlintr"))
      expect_false(
        dir.exists(".textlintr")
      )
    }
  )
})
