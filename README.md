textlintr
=========

[![CRAN status](https://www.r-pkg.org/badges/version/textlintr)](https://cran.r-project.org/package=textlintr) [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

The goal of textlintr is to ...

Installation
------------

You can install the development version of textlintr from [GitHub](https://github.com/uribo/textlintr) with:

``` r
# install.packages("remotes")
remotes::install_github("uribo/textlintr")
```

Get Started
-----------

### Prepare textlint ecosystems

Textlintr also requires the external program [textlint](https://github.com/textlint/textlint). You may download textlint and custom rules using npm or yarn. Next, just write a `.textlintrc` file.

### Demo

``` r
library(textlintr)

lint_target <- 
  system.file("sample.md", package = "textlintr")

textlint(lint_target)
```

<p align="center">
<img src="man/figures/textlintr-demo.png" />
</p>
