context("test-textlint-ecosystems")

test_that("Get started", {
  expect_true(
    is_available_npm()
  )
  expect_false(
    is_available_textlint()
  )
})

test_that("Activate on textlint", {
  withr::with_dir(
    tempdir(), {
      skip_if(dir.exists("node_modules"))
      expect_message(
        init_textlintr(c("common-misspellings",
                         "preset-jtf-style",
                         "no-todo")),
        "Install was successful"
      )
      expect_true(
        dir.exists("node_modules")
      )
      expect_true(
        file.exists(search_textlint_path(.node_module_path = "node_modules"))
      )
      expect_silent(
        check_rule_exist()
      )
      expect_message(
        init_textlintr(),
        "Already, exits textlint.js"
      )
      textlint_res_raw <-
        processx::run(
          command = search_textlint_path("node_modules"),
          args = c("-f", "json",
                   "--rule", "common-misspellings",
                   normalizePath(
                     system.file("sample.md", package = "textlintr"))),
          error_on_status = FALSE)
      expect_is(
        textlint_res_raw,
        "list"
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
        c("common-misspellings", "helper",
          "no-todo", "preset-jtf-style", "prh"),
        ignore.order = TRUE
      )
      expect_true(is_rule_exist("preset-jtf-style"))
      expect_false(is_rule_exist("first-sentence-length"))

      add_rules("first-sentence-length", scope = "dev")
      update_lint_rules(overwrite = TRUE)
      expect_named(
        configure_lint_rules(),
        c("common-misspellings", "first-sentence-length", "helper",
          "no-todo", "preset-jtf-style", "prh"),
        ignore.order = TRUE
      )
      expect_equal(
        nchar(paste(readLines(".textlintrc"), collapse = "")),
        258L
      )
      jsonlite::write_json(
        list(
          rules = list(
            "common-misspellings" = TRUE,
            "prh" = list(
              "rulePaths" = I(system.file("prh/r.yml", package = "textlintr"))
            )
          ),
          plugins = list(
            "@textlint/markdown" = list(
              "extensions" = ".Rmd"
            )
          )
        ),
        ".textlintrc",
        auto_unbox = TRUE
      )
      # Don't modify box element #17
      update_lint_rules("no-todo", overwrite = FALSE)
      textlint_res_raw2 <-
        processx::run(
          command = search_textlint_path("node_modules"),
          args = c("-f", "json",
                   "--rule", "common-misspellings",
                   normalizePath(
                     system.file("sample.md", package = "textlintr"))),
          error_on_status = FALSE)
      expect_equal(
        textlint_res_raw2$status,
        1L
      )
      expect_match(
        textlint_res_raw2$stdout,
        "Rmarkdown => R Markdown"
      )
      processx::run(
        command = "npm",
        args = c("uninstall",
                 "textlint-rule-first-sentence-length"),
        wd = "node_modules",
        error_on_status = FALSE)
      update_lint_rules(overwrite = TRUE)
      expect_equal(
        nchar(paste(readLines(".textlintrc"), collapse = "")),
        208L
      )
      skip_if(dir.exists(".textlintr"))
      expect_false(
        dir.exists(".textlintr")
      )
    }
  )
})
