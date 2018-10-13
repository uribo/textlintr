is_installed_dependencies <- function(target = c("npm", "textlint")) {
  if (nchar(Sys.which(target)) == 0 && !file.exists(".textlintr/node_modules/textlint/bin/textlint.js")) { # nolint
    FALSE
  }
  else {
    TRUE
  }
}
