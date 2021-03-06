% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rules.R
\name{is_rule_exist}
\alias{is_rule_exist}
\title{Check if rule is installed}
\usage{
is_rule_exist(rules)
}
\arguments{
\item{rules}{the name of rule; see \code{\link[=rule_sets]{rule_sets()}} and \url{https://github.com/textlint/textlint/wiki/Collection-of-textlint-rule}.}
}
\description{
Check if rule is installed
}
\examples{
\dontrun{
is_rule_exist("no-todo")
is_rule_exist("first-sentence-length")
}
}
