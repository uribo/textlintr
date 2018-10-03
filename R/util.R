is_installed_dependencies <- function(target = c("npm", "textlint")) {

  if (nchar(Sys.which(target)) == 0) {
    FALSE
  } else {
    TRUE
  }
}
