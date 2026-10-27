# R calculation engine

This directory is for reusable R functions that implement tax, benefits, household assumptions, and marginal effective tax rate calculations.

- Keep functions independent of Shiny and reactive state.
- Prefer explicit inputs and outputs, with financial year and material assumptions represented directly.
- Add `testthat` tests for new calculation logic, including boundaries and interactions.
- Document authoritative sources and effective dates for substantive policy rules.

See [the development guidelines](../docs/development.md). The minimal S3 scenario constructor `new_scenario()` is in [scenario.R](scenario.R); it stores only `financial_year` and `taxable_income`. It intentionally does not decide whether tax rules are implemented for a given year. The generic piecewise-linear evaluator and financial-year-aware functions `resident_income_tax()`, `lito()`, `medicare_levy()`, and `individual_tax_components()` are in [tax_core.R](tax_core.R); the 2026–27 tax and levy parameters are maintained as data in [policy_schedules_2026_27.R](policy_schedules_2026_27.R). Their supported scope and limitations are documented in [the tax-core validation specification](../docs/validation/tax-core-2026-27.md).
