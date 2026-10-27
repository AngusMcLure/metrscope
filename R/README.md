# R calculation engine

This directory is for reusable R functions that implement tax, benefits, household assumptions, and marginal effective tax rate calculations.

- Keep functions independent of Shiny and reactive state.
- Prefer explicit inputs and outputs, with financial year and material assumptions represented directly.
- Add `testthat` tests for new calculation logic, including boundaries and interactions.
- Document authoritative sources and effective dates for substantive policy rules.

See [the development guidelines](../docs/development.md). The initial 2026–27 resident individual tax functions are in [income-tax.R](income-tax.R). Their supported scope and limitations are documented in [the validation notes](../docs/validation.md).
