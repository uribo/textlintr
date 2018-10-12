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
      # skip_if(dir.exists(".textlintr/node_modules/"))
      init_textlintr(c("common-misspellings",
                       "preset-jtf-style",
                       "no-todo"))
      expect_true(
        dir.exists(".textlintr")
      )
      expect_silent(
        check_rule_exist()
      )
      expect_message(
        init_textlintr(),
        "Already, exits textlint.js"
      )
      validity_rules <-
        configure_lint_rules()
      expect_is(
        validity_rules,
        "list"
      )
      expect_length(
        validity_rules,
        3L
      )
      expect_named(
        validity_rules,
        c("common-misspellings", "preset-jtf-style", "no-todo"),
        ignore.order = TRUE
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

      update_lint_rules()
      validity_rules <-
        configure_lint_rules()
      expect_length(
        validity_rules,
        5L
      )
      expect_named(
        validity_rules,
        c("common-misspellings", "helper", "no-todo", "preset-jtf-style", "prh"),
        ignore.order = TRUE
      )
      expect_true(is_rule_exist("preset-jtf-style"))
      expect_false(is_rule_exist("first-sentence-length"))

      add_rules("first-sentence-length")
      update_lint_rules(overwrite = TRUE)
      expect_named(
        configure_lint_rules(),
        c("common-misspellings", "first-sentence-length", "helper",
          "no-todo", "preset-jtf-style", "prh"),
        ignore.order = TRUE
      )
      processx::run(
        command = ".textlintr/node_modules/textlint/bin/textlint.js",
        args = c("uninstall",
                 "textlint-rule-first-sentence-length"),
        error_on_status = FALSE)

      skip_if(dir.exists(".textlintr"))
      expect_false(
        dir.exists(".textlintr")
      )
    }
  )
})
