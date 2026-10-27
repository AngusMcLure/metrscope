# Core individual tax calculations for 2026–27.
#
# Scope: ordinary taxable income of an Australian resident individual, standard
# LITO eligibility, and the standard individual Medicare levy threshold/phase-in.
# This is not a complete tax assessment. See docs/validation/tax-core-2026-27.md.
#
# Sources:
# - Income Tax Rates Act 1986, Schedule 7, Part I (compilation effective 1 July 2026):
#   https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
# - Medicare Levy Act 1986 (compilation effective 1 July 2026):
#   https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
# - ATO, Low income tax offset:
#   https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates
#
# Amounts are returned without final tax-return rounding. Taxable income is
# expected to be a non-negative whole-dollar amount, as normally reported.

.validate_taxable_income <- function(taxable_income) {
  valid <- is.numeric(taxable_income) &&
    length(taxable_income) == 1L &&
    !is.na(taxable_income) &&
    is.finite(taxable_income) &&
    taxable_income >= 0 &&
    taxable_income == floor(taxable_income)

  if (!valid) {
    stop("taxable_income must be one finite, non-negative whole-dollar number.",
         call. = FALSE)
  }

  invisible(taxable_income)
}

# Basic resident income tax before offsets, for 2026–27.
resident_income_tax_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)
  income <- taxable_income

  if (income <= 18200) {
    return(0)
  }
  if (income <= 45000) {
    return((income - 18200) * 0.15)
  }
  if (income <= 135000) {
    return(4020 + (income - 45000) * 0.30)
  }
  if (income <= 190000) {
    return(31020 + (income - 135000) * 0.37)
  }

  51370 + (income - 190000) * 0.45
}

# Low Income Tax Offset for eligible Australian resident individuals.
# This function implements the ATO's published 2026–27-relevant schedule;
# eligibility beyond residency/taxable-income scope is not modelled here.
lito_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)
  income <- taxable_income

  if (income <= 37500) {
    return(700)
  }
  if (income <= 45000) {
    return(700 - 0.05 * (income - 37500))
  }
  if (income <= 66667) {
    return(max(0, 325 - 0.015 * (income - 45000)))
  }

  0
}

# Standard individual Medicare levy for 2026–27.
# Excludes family threshold/reduction rules, SAPTO-related treatment,
# exemptions, and Medicare levy surcharge.
medicare_levy_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)
  income <- taxable_income
  threshold <- 28011
  phase_in_limit <- 35013

  if (income <= threshold) {
    return(0)
  }
  if (income < phase_in_limit) {
    return(0.10 * (income - threshold))
  }

  0.02 * income
}

# Component-level annual liability for a standard resident individual.
# The Medicare levy is separate because LITO does not reduce it.
individual_tax_components_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)

  basic_tax <- resident_income_tax_2026_27(taxable_income)
  lito <- lito_2026_27(taxable_income)
  income_tax_after_lito <- max(0, basic_tax - lito)
  medicare_levy <- medicare_levy_2026_27(taxable_income)

  list(
    financial_year = "2026-27",
    taxable_income = taxable_income,
    basic_income_tax = basic_tax,
    lito = lito,
    income_tax_after_lito = income_tax_after_lito,
    medicare_levy = medicare_levy,
    total_tax_and_levies = income_tax_after_lito + medicare_levy
  )
}
