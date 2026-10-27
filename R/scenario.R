# Minimal S3 scenario object.
#
# This object records the inputs currently needed by the implemented tax rules.
# It deliberately does not validate whether tax rules exist for the requested
# financial year; the calculation functions are responsible for that check.

new_scenario <- function(financial_year, taxable_income) {
  valid_financial_year <- is.character(financial_year) &&
    length(financial_year) == 1L &&
    !is.na(financial_year) &&
    nzchar(trimws(financial_year))

  if (!valid_financial_year) {
    stop("financial_year must be one non-empty character string.",
         call. = FALSE)
  }

  valid_taxable_income <- is.numeric(taxable_income) &&
    length(taxable_income) == 1L &&
    !is.na(taxable_income) &&
    is.finite(taxable_income) &&
    taxable_income >= 0 &&
    taxable_income == floor(taxable_income)

  if (!valid_taxable_income) {
    stop("taxable_income must be one finite, non-negative whole-dollar number.",
         call. = FALSE)
  }

  structure(
    list(
      financial_year = financial_year,
      taxable_income = taxable_income
    ),
    class = "scenario"
  )
}
