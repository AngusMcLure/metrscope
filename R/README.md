# R calculation engine

This directory is for reusable R functions that implement tax, benefits, household assumptions, and marginal effective tax rate calculations.

- Keep functions independent of Shiny and reactive state.
- Prefer explicit inputs and outputs, with financial year and material assumptions represented directly.
- Add `testthat` tests for new calculation logic, including boundaries and interactions.
- Document authoritative sources and effective dates for substantive policy rules.

The `new_adult()` and `new_scenario()` constructors are in [scenario.R](scenario.R). An adult stores taxable income and optional MLS income-test adjustments: reportable fringe benefits, reportable super contributions, net investment loss, and a family trust distribution amount. A scenario stores the financial year, one or two adults, the number of dependent children, and whether the household had appropriate hospital cover for the full year.

Example:

```r
scenario <- new_scenario(
  financial_year = "2026-27",
  adults = list(
    new_adult(taxable_income = 150000),
    new_adult(taxable_income = 70000)
  ),
  dependent_children = 2,
  appropriate_hospital_cover = FALSE
)
individual_tax_components(scenario)
```

The validators are deliberately layered: `.validate_adult()` checks one adult object and its income fields; `.validate_adults()` checks that the collection contains one or two entries, then iteratively applies `.validate_adult()` to each entry. `new_scenario()` uses that collection validator and validates the household inputs.

The public tax-rule functions `resident_income_tax()`, `lito()`, and `medicare_levy()` in [tax_core.R](tax_core.R) accept one scenario and return a named numeric value for each adult (`adult_1`, and optionally `adult_2`). `medicare_levy_surcharge()` uses household income, dependent children, and the full-year cover assumption to determine the rate tier, then calculates the surcharge separately for each adult. `individual_tax_components()` returns one row per adult, with MLS shown separately and included in `total_tax_and_levies`.

The 2026–27 tax and levy parameters are maintained separately as data in [policy_schedules_2026_27.R](policy_schedules_2026_27.R). The scenario constructor records a financial year even if tax rules for that year have not yet been implemented; calculations fail clearly for unsupported years.

The MLS model deliberately assumes full-year household cover status, stable household composition, and (for two-adult scenarios) a spousal relationship. It does not assess special exemptions or prescribed-person cases, adult dependants, or assessable First Home Super Saver released amounts. Family-threshold Medicare levy reductions, SAPTO and other offsets, HELP repayments, family payments, childcare and housing support, and other transfer-payment interactions are also outside scope. Outputs are unrounded model amounts, not an official assessment. These are intentional scope assumptions, documented in the [tax-core validation specification](../docs/validation/tax-core-2026-27.md), alongside sources and tests.
