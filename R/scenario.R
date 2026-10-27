# Minimal S3 adult and scenario objects.
#
# Adult objects contain taxable income and income-test adjustments used by
# the Medicare levy surcharge (MLS). Children and cover status are household
# fields because MLS thresholds and cover requirements operate at that level.
# The constructors do not validate whether tax rules exist for the requested
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

.validate_nonnegative_whole_amount <- function(amount, field) {
  valid <- is.numeric(amount) &&
    length(amount) == 1L &&
    !is.na(amount) &&
    is.finite(amount) &&
    amount >= 0 &&
    amount == floor(amount)

  if (!valid) {
    stop(
      sprintf("%s must be one finite, non-negative whole-dollar number.", field),
      call. = FALSE
    )
  }

  invisible(amount)
}

.validate_taxable_income <- function(taxable_income, field = "taxable_income") {
  .validate_nonnegative_whole_amount(taxable_income, field)
}

.validate_adult <- function(adult, field = "adult") {
  required <- c(
    "taxable_income",
    "reportable_fringe_benefits",
    "reportable_super_contributions",
    "net_investment_loss",
    "family_trust_distribution"
  )
  if (!inherits(adult, "adult") || !is.list(adult) ||
      !all(required %in% names(adult))) {
    stop(
      sprintf(
        "%s must be an adult object with taxable_income and all required MLS income fields.",
        field
      ),
      call. = FALSE
    )
  }

  for (name in required) {
    .validate_nonnegative_whole_amount(
      adult[[name]], paste0(field, "$", name)
    )
  }
  invisible(adult)
}

new_adult <- function(taxable_income,
                      reportable_fringe_benefits = 0,
                      reportable_super_contributions = 0,
                      net_investment_loss = 0,
                      family_trust_distribution = 0) {
  fields <- list(
    taxable_income = taxable_income,
    reportable_fringe_benefits = reportable_fringe_benefits,
    reportable_super_contributions = reportable_super_contributions,
    net_investment_loss = net_investment_loss,
    family_trust_distribution = family_trust_distribution
  )
  for (name in names(fields)) {
    .validate_nonnegative_whole_amount(fields[[name]], name)
  }
  structure(fields, class = "adult")
}

.validate_adults <- function(adults) {
  if (!is.list(adults) || length(adults) < 1L || length(adults) > 2L) {
    stop("adults must be a list containing one or two adults.", call. = FALSE)
  }

  for (i in seq_along(adults)) {
    .validate_adult(adults[[i]], sprintf("adults[[%d]]", i))
  }

  invisible(adults)
}

.validate_dependent_children <- function(dependent_children) {
  valid <- is.numeric(dependent_children) &&
    length(dependent_children) == 1L &&
    !is.na(dependent_children) &&
    is.finite(dependent_children) &&
    dependent_children >= 0 &&
    dependent_children == floor(dependent_children)

  if (!valid) {
    stop("dependent_children must be one finite, non-negative whole number.",
         call. = FALSE)
  }
  invisible(dependent_children)
}

.validate_scenario <- function(scenario) {
  if (!inherits(scenario, "scenario") || !is.list(scenario) ||
      is.null(scenario$financial_year) || is.null(scenario$adults)) {
    stop("scenario must be a scenario object with financial_year and adults.",
         call. = FALSE)
  }

  .validate_financial_year(scenario$financial_year, "scenario$financial_year")
  .validate_adults(scenario$adults)
  if (is.null(scenario$dependent_children)) {
    stop("scenario$dependent_children must be supplied.", call. = FALSE)
  }
  .validate_dependent_children(scenario$dependent_children)
  if (is.null(scenario$appropriate_hospital_cover) ||
      !is.logical(scenario$appropriate_hospital_cover) ||
      length(scenario$appropriate_hospital_cover) != 1L ||
      is.na(scenario$appropriate_hospital_cover)) {
    stop("scenario$appropriate_hospital_cover must be TRUE or FALSE.",
         call. = FALSE)
  }
  invisible(scenario)
}

new_scenario <- function(financial_year, adults, dependent_children = 0,
                         appropriate_hospital_cover = FALSE) {
  .validate_financial_year(financial_year)
  .validate_adults(adults)
  .validate_dependent_children(dependent_children)
  if (!is.logical(appropriate_hospital_cover) ||
      length(appropriate_hospital_cover) != 1L ||
      is.na(appropriate_hospital_cover)) {
    stop("appropriate_hospital_cover must be TRUE or FALSE.", call. = FALSE)
  }

  structure(
    list(
      financial_year = financial_year,
      adults = adults,
      dependent_children = dependent_children,
      appropriate_hospital_cover = appropriate_hospital_cover
    ),
    class = "scenario"
  )
}
