# Resident individual income tax components for 2026-27.
#
# Scope: Australian resident individual with ordinary taxable income; standard
# individual Medicare levy threshold; no Medicare levy surcharge, exemptions,
# family-threshold reductions, SAPTO, other offsets, HELP repayments, or
# income-tested benefits. Amounts are returned unrounded.
#
# Sources:
# - Income Tax Rates Act 1986, Schedule 7, Part I (effective 1 July 2026):
#   https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
# - Medicare Levy Act 1986 (effective 1 July 2026):
#   https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
# - ATO tax offsets and rebates (LITO):
#   https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates

.validate_nonnegative_scalar <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x < 0) {
    stop(sprintf("'%s' must be one finite, non-negative number.", name),
         call. = FALSE)
  }
  invisible(x)
}

# Basic resident income tax before offsets for 2026-27.
income_tax_before_offsets_2026_27 <- function(taxable_income) {
  .validate_nonnegative_scalar(taxable_income, "taxable_income")
  x <- taxable_income

  if (x <= 18200) return(0)
  if (x <= 45000) return((x - 18200) * 0.15)
  if (x <= 135000) return(4020 + (x - 45000) * 0.30)
  if (x <= 190000) return(31020 + (x - 135000) * 0.37)

  51370 + (x - 190000) * 0.45
}

# Low Income Tax Offset (LITO) for 2026-27.
lito_2026_27 <- function(taxable_income) {
  .validate_nonnegative_scalar(taxable_income, "taxable_income")
  x <- taxable_income

  if (x <= 37500) return(700)
  if (x <= 45000) return(max(0, 700 - 0.05 * (x - 37500)))
  if (x <= 66667) return(max(0, 325 - 0.015 * (x - 45000)))

  0
}

# Standard Medicare levy for an individual using the general individual
# low-income threshold, with no family threshold or exemption.
medicare_levy_individual_2026_27 <- function(taxable_income) {
  .validate_nonnegative_scalar(taxable_income, "taxable_income")
  x <- taxable_income
  threshold <- 28011

  if (x <= threshold) return(0)

  # The phase-in is 10% of income above the threshold, capped at the
  # standard 2% levy.
  min(0.02 * x, 0.10 * (x - threshold))
}

# Auditable component ledger. This is an annual liability estimate, not PAYG
# withholding or personal tax advice. See docs/validation.md for exclusions.
calculate_individual_tax_2026_27 <- function(taxable_income) {
  .validate_nonnegative_scalar(taxable_income, "taxable_income")

  tax_before_offsets <- income_tax_before_offsets_2026_27(taxable_income)
  lito_entitlement <- lito_2026_27(taxable_income)
  lito_applied <- min(tax_before_offsets, lito_entitlement)
  tax_after_lito <- tax_before_offsets - lito_applied
  medicare_levy <- medicare_levy_individual_2026_27(taxable_income)

  # These rows are additive components. Subtotals and totals are returned
  # separately to prevent downstream code from accidentally double-counting.
  components <- data.frame(
    component = c(
      "Income tax before offsets",
      "LITO applied",
      "Medicare levy"
    ),
    amount = c(
      tax_before_offsets,
      -lito_applied,
      medicare_levy
    ),
    stringsAsFactors = FALSE
  )

  list(
    financial_year = "2026-27",
    taxable_income = taxable_income,
    components = components,
    total_income_tax_and_medicare_levy = tax_after_lito + medicare_levy,
    scope = paste(
      "Resident individual; ordinary taxable income; LITO; standard",
      "individual Medicare levy threshold only. Excludes MLS, exemptions,",
      "family thresholds, SAPTO, other offsets, HELP and benefits."
    )
  )
}
