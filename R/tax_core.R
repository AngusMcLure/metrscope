# Core individual tax calculations.
#
# Public tax-rule functions accept a single scenario object. Policy schedules
# are data, maintained separately in R/policy_schedules_2026_27.R. See
# docs/validation/tax-core-2026-27.md.
# Amounts are returned without final tax-return rounding.

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

.validate_scenario <- function(scenario) {
  if (!inherits(scenario, "scenario") || !is.list(scenario) ||
      is.null(scenario$financial_year) || is.null(scenario$taxable_income)) {
    stop("scenario must be a scenario object with financial_year and taxable_income.",
         call. = FALSE)
  }

  # Reuse the same validation rules as the constructor in case fields have
  # been modified after construction.
  valid_financial_year <- is.character(scenario$financial_year) &&
    length(scenario$financial_year) == 1L &&
    !is.na(scenario$financial_year) &&
    nzchar(trimws(scenario$financial_year))
  if (!valid_financial_year) {
    stop("scenario$financial_year must be one non-empty character string.",
         call. = FALSE)
  }
  .validate_taxable_income(scenario$taxable_income)

  invisible(scenario)
}

.validate_piecewise_schedule <- function(schedule) {
  required <- c("lower_bound", "upper_bound", "value_at_lower", "slope")
  if (!is.data.frame(schedule) || !all(required %in% names(schedule)) ||
      nrow(schedule) < 1L) {
    stop("schedule must be a non-empty data frame with the required columns.",
         call. = FALSE)
  }

  numeric_columns <- vapply(schedule[required], is.numeric, logical(1))
  if (!all(numeric_columns)) {
    stop("All piecewise schedule columns must be numeric.", call. = FALSE)
  }

  if (anyNA(schedule[required]) ||
      any(!is.finite(schedule$lower_bound)) ||
      any(!is.finite(schedule$value_at_lower)) ||
      any(!is.finite(schedule$slope)) ||
      any(is.na(schedule$upper_bound)) ||
      any(schedule$upper_bound <= schedule$lower_bound)) {
    stop("Schedule bounds, values, or slopes are invalid.", call. = FALSE)
  }

  if (schedule$lower_bound[1] != 0 ||
      any(diff(schedule$lower_bound) <= 0) ||
      any(schedule$upper_bound[-nrow(schedule)] !=
          schedule$lower_bound[-1]) ||
      !is.infinite(schedule$upper_bound[nrow(schedule)]) ||
      schedule$upper_bound[nrow(schedule)] < 0) {
    stop("Schedule must start at zero and contain contiguous intervals ending at Inf.",
         call. = FALSE)
  }

  invisible(schedule)
}

# Evaluate a piecewise-linear policy schedule.
#
# Each row covers [lower_bound, upper_bound). The amount is anchored by
# value_at_lower and changes at slope per unit of input. Discontinuities are
# allowed when the policy specifies a cliff; callers should test those points.
evaluate_piecewise_schedule <- function(input, schedule) {
  if (!is.numeric(input) || length(input) != 1L || is.na(input) ||
      !is.finite(input) || input < 0) {
    stop("input must be one finite, non-negative number.", call. = FALSE)
  }
  .validate_piecewise_schedule(schedule)

  row <- findInterval(input, schedule$lower_bound)
  row <- max(1L, min(row, nrow(schedule)))

  schedule$value_at_lower[row] +
    schedule$slope[row] * (input - schedule$lower_bound[row])
}

# Return the policy schedules for an explicitly requested financial year.
# Add a new case here when a new year's schedule has been implemented and
# validated; never silently substitute a different year.
.policy_schedules_for_year <- function(financial_year) {
  valid <- is.character(financial_year) &&
    length(financial_year) == 1L &&
    !is.na(financial_year) &&
    nzchar(financial_year)

  if (!valid) {
    stop("financial_year must be one non-empty character string.",
         call. = FALSE)
  }

  switch(
    financial_year,
    "2026-27" = policy_schedules_2026_27,
    stop(
      sprintf(
        "Unsupported financial_year '%s'. Supported financial years: 2026-27.",
        financial_year
      ),
      call. = FALSE
    )
  )
}

.policy_schedule_value <- function(input, schedule_name, financial_year) {
  policy_schedules <- .policy_schedules_for_year(financial_year)
  policy_rule <- policy_schedules[[schedule_name]]

  if (is.null(policy_rule) || is.null(policy_rule$schedule)) {
    stop(
      sprintf(
        "No policy schedule named '%s' is available for financial year %s.",
        schedule_name, financial_year
      ),
      call. = FALSE
    )
  }

  evaluate_piecewise_schedule(input, policy_rule$schedule)
}

resident_income_tax <- function(scenario) {
  .validate_scenario(scenario)
  .policy_schedule_value(
    scenario$taxable_income, "resident_income_tax", scenario$financial_year
  )
}

lito <- function(scenario) {
  .validate_scenario(scenario)
  max(0, .policy_schedule_value(
    scenario$taxable_income, "lito", scenario$financial_year
  ))
}

medicare_levy <- function(scenario) {
  .validate_scenario(scenario)
  .policy_schedule_value(
    scenario$taxable_income, "medicare_levy_individual", scenario$financial_year
  )
}

# Component-level annual liability for a standard resident individual.
# The Medicare levy is separate because LITO does not reduce it.
individual_tax_components <- function(scenario) {
  .validate_scenario(scenario)

  taxable_income <- scenario$taxable_income
  financial_year <- scenario$financial_year
  basic_tax <- resident_income_tax(scenario)
  lito_entitlement <- lito(scenario)
  lito_applied <- min(basic_tax, lito_entitlement)
  income_tax_after_lito <- basic_tax - lito_applied
  levy <- medicare_levy(scenario)

  list(
    financial_year = financial_year,
    taxable_income = taxable_income,
    basic_income_tax = basic_tax,
    lito = lito_entitlement,
    lito_applied = lito_applied,
    income_tax_after_lito = income_tax_after_lito,
    medicare_levy = levy,
    total_tax_and_levies = income_tax_after_lito + levy
  )
}
