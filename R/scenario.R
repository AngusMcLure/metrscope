# Minimal S3 scenario object.
#
# A scenario records one or two adults. Children and other household
# circumstances can be added separately when the relevant rules are modelled.
# The constructor does not validate whether tax rules exist for the requested
# financial year; the calculation functions are responsible for that check.

.validate_financial_year <- function(financial_year, field = "financial_year") {
  valid <- is.character(financial_year) &&
    length(financial_year) == 1L &&
    !is.na(financial_year) &&
    nzchar(trimws(financial_year))

  if (!valid) {
    stop(sprintf("%s must be one non-empty character string.", field),
         call. = FALSE)
  }

  invisible(financial_year)
}

.validate_taxable_income <- function(taxable_income, field = "taxable_income") {
  valid <- is.numeric(taxable_income) &&
    length(taxable_income) == 1L &&
    !is.na(taxable_income) &&
    is.finite(taxable_income) &&
    taxable_income >= 0 &&
    taxable_income == floor(taxable_income)

  if (!valid) {
    stop(
      sprintf("%s must be one finite, non-negative whole-dollar number.", field),
      call. = FALSE
    )
  }

  invisible(taxable_income)
}

.validate_adults <- function(adults) {
  if (!is.list(adults) || length(adults) < 1L || length(adults) > 2L) {
    stop("adults must be a list containing one or two adults.", call. = FALSE)
  }

  for (i in seq_along(adults)) {
    adult <- adults[[i]]
    if (!is.list(adult) || is.null(adult$taxable_income)) {
      stop(
        sprintf("adults[[%d]] must be a list with a taxable_income field.", i),
        call. = FALSE
      )
    }
    .validate_taxable_income(
      adult$taxable_income,
      sprintf("adults[[%d]]$taxable_income", i)
    )
  }

  invisible(adults)
}

new_scenario <- function(financial_year, adults) {
  .validate_financial_year(financial_year)
  .validate_adults(adults)

  structure(
    list(
      financial_year = financial_year,
      adults = adults
    ),
    class = "scenario"
  )
}
