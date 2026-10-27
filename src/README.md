# Source code

Place application code and reusable calculation logic here.

Starting principles:
- All code will be in R
- In order to keep dependencies limited backend code can use the standard packages: i.e. base, datasets, graphics, grDevices, methods, stats, utils
- Additionally code can use the following packages: tidyverse, and shiny. Use of other packages requires permission
- Code development will follow best practice guidelines.
- Code will follow tidyverse style guide
- tests will use testthat for unit tests of functions. Tests should be added for calculation logic as it is introduced.
- renv will be used for package version management
- checks will be automated through GitHub actions
- Keep tax and benefit rules separate from user-interface code.
- Make financial-year and household assumptions explicit inputs where relevant.
- Record external sources for substantive policy rules.
