# R calculation engine

This directory is for reusable R functions that implement tax, benefits, household assumptions, and marginal effective tax rate calculations.

- Keep functions independent of Shiny and reactive state.
- Prefer explicit inputs and outputs, with financial year and material assumptions represented directly.
- Add `testthat` tests for new calculation logic, including boundaries and interactions.
- Document authoritative sources and effective dates for substantive policy rules.

The `new_adult()`, `new_ftb_child()`, and `new_scenario()` constructors are in [scenario.R](scenario.R). Adults store taxable income, MLS income-test adjustments, and the additional fields used to calculate FTB adjusted taxable income. Scenarios store the financial year, one or two adults, the dependent-child count used for MLS, full-year hospital-cover status, and an optional list of age-specific FTB children.

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

The public individual tax-rule functions `resident_income_tax()`, `lito()`, and `medicare_levy()` accept one scenario and return a named numeric value for each adult. `medicare_levy_surcharge()` uses household income, dependent children, and full-year cover status to determine the tier, then calculates the surcharge separately for each adult. `family_tax_benefit_part_a()` returns the annual family FTB-A rate after the family income test, while `ftb_part_a_components()` exposes the intermediate calculations. The FTB-A result excludes the maintenance income test, supplements, and detailed eligibility adjustments. `individual_tax_components()` returns one row per adult, with MLS shown separately and included in `total_tax_and_levies`.

The 2026–27 tax and levy parameters are maintained separately as data in [policy_schedules_2026_27.R](policy_schedules_2026_27.R). The scenario constructor records a financial year even if tax rules for that year have not yet been implemented; calculations fail clearly for unsupported years.

The MLS model deliberately assumes full-year household cover status, stable household composition, and (for two-adult scenarios) a spousal relationship. The FTB-A model assumes supplied FTB child records satisfy the core eligibility requirements and excludes maintenance tests, supplements, shared-care calculations, and detailed eligibility rules. It does not assess special exemptions or prescribed-person cases, adult dependants, or assessable First Home Super Saver released amounts. Family-threshold Medicare levy reductions, SAPTO and other offsets, HELP repayments, family payments, childcare and housing support, and other transfer-payment interactions are also outside scope. Outputs are unrounded model amounts, not an official assessment. These are intentional scope assumptions, documented in the [tax-core validation specification](../docs/validation/tax-core-2026-27.md), alongside sources and tests.
