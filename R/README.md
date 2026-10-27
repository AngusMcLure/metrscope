# R calculation engine

This directory is for reusable R functions that implement tax, benefits, household assumptions, and marginal effective tax rate calculations.

- Keep functions independent of Shiny and reactive state.
- Prefer explicit inputs and outputs, with financial year and material assumptions represented directly.
- Add `testthat` tests for new calculation logic, including boundaries and interactions.
- Document authoritative sources and effective dates for substantive policy rules.

The `new_adult()` and `new_scenario()` constructors are in [scenario.R](scenario.R). An adult currently stores a `taxable_income` field and has S3 class `adult`. A scenario stores a `financial_year` and a list of one or two adult objects. Children are intentionally not included yet and should be added as a separate field when child-dependent rules are implemented.

Example:

```r
scenario <- new_scenario(
  financial_year = "2026-27",
  adults = list(
    new_adult(taxable_income = 60000),
    new_adult(taxable_income = 40000)
  )
)
```

The validators are deliberately layered: `.validate_adult()` checks one adult object and its taxable income; `.validate_adults()` checks that the collection contains one or two entries, then iteratively applies `.validate_adult()` to each entry. `new_scenario()` uses that collection validator.

The public tax-rule functions `resident_income_tax()`, `lito()`, and `medicare_levy()` in [tax_core.R](tax_core.R) each accept one scenario and return a named numeric value for each adult (`adult_1`, and optionally `adult_2`). `individual_tax_components()` returns one row per adult. The 2026–27 tax and levy parameters are maintained separately as data in [policy_schedules_2026_27.R](policy_schedules_2026_27.R). The constructor records a financial year even if tax rules for that year have not yet been implemented; calculations fail clearly for unsupported years.
