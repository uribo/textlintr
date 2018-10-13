textlintr
=========

[![Travis-CI Build Status](https://travis-ci.org/uribo/textlintr.svg?branch=master)](https://travis-ci.org/uribo/textlintr) [![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/uribo/textlintr?branch=master&svg=true)](https://ci.appveyor.com/project/uribo/textlintr) [![CRAN status](https://www.r-pkg.org/badges/version/textlintr)](https://cran.r-project.org/package=textlintr) [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Codecov test coverage](https://codecov.io/gh/uribo/textlintr/branch/master/graph/badge.svg)](https://codecov.io/gh/uribo/textlintr?branch=master)

Textlintr is package that wrapper natural language lint tools [`textlint.js`](https://textlint.github.io/) for R. You can combine rules freely to check for misspellings and so on.

Installation
------------

You can install the development version of textlintr from [GitHub](https://github.com/uribo/textlintr) with:

``` r
# install.packages("remotes")
remotes::install_github("uribo/textlintr")
```

Get Started
-----------

1. Initialise textlint environments (install `textlint.js` and some rules)
    - `init_textlintr(rules = c("common-misspellings", "prh"))`
    - A list of rules can be confirmed with `rule_sets()`
2. Configure `.textlintrc`
3. Run `textlint("target.md")`
4. Want to add a rule? --- You can supplement rules by running `add_rule()`

### Demo

``` r
library(textlintr)
init_textlintr(rules = c("common-misspellings"))

lint_target <- 
  system.file("sample.md", package = "textlintr")

textlint(lint_target)
```

<p align="center">
<img src="man/figures/textlintr-demo.png" />
</p>

Code of Conduct
-----------

The environment for collaboration should be friendly, inclusive, respectful, and safe for everyone, so all participants must obey this repository’s [code of conduct](.github/CODE_OF_CONDUCT.md).
