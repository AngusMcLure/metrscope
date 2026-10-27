# Validation documentation

The current calculation scope is documented in the [2026–27 tax-core, Medicare levy surcharge, and FTB-A validation specification](validation/tax-core-2026-27.md).

That document records the scope, official sources, formulas, worked examples, boundary tests, and limitations for functions in `R/tax_core.R`. The test suite includes `tests/testthat/test-tax-core.R`, `tests/testthat/test-scenario.R`, `tests/testthat/test-medicare-levy-surcharge.R`, and `tests/testthat/test-ftb-part-a.R`.

R tests have not been run locally in the current environment because R/Rscript is unavailable. GitHub Actions should be checked for the proposed branch before treating the tests as passed.
