# Core individual tax calculations.
#
# Policy schedules are data, maintained separately in
# R/policy_schedules_2026_27.R. See docs/validation/tax-core-2026-27.md.
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

# Generic named access to a schedule in a financial-year policy configuration.
.policy_schedule_value <- function(input, schedule_name, policy_schedules) {
  if (!is.list(policy_schedules) ||
      is.null(policy_schedules[[schedule_name]]) ||
      is.null(policy_schedules[[schedule_name]]$schedule)) {
    stop(sprintf("No policy schedule named '%s' was supplied.", schedule_name),
         call. = FALSE)
  }

  evaluate_piecewise_schedule(
    input = input,
    schedule = policy_schedules[[schedule_name]]$schedule
  )
}

# Compatibility wrappers keep the calculation API readable while the
# financial-year-specific policy data remains separate from calculation logic.
resident_income_tax_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)
  .policy_schedule_value(
    taxable_income, "resident_income_tax", policy_schedules_2026_27
  )
}

lito_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)
  max(0, .policy_schedule_value(
    taxable_income, "lito", policy_schedules_2026_27
  ))
}

medicare_levy_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)
  .policy_schedule_value(
    taxable_income, "medicare_levy_individual", policy_schedules_2026_27
  )
}

# Component-level annual liability for a standard resident individual.
# The Medicare levy is separate because LITO does not reduce it.
individual_tax_components_2026_27 <- function(taxable_income) {
  .validate_taxable_income(taxable_income)

  basic_tax <- resident_income_tax_2026_27(taxable_income)
  lito <- lito_2026_27(taxable_income)
  lito_applied <- min(basic_tax, lito)
  income_tax_after_lito <- basic_tax - lito_applied
  medicare_levy <- medicare_levy_2026_27(taxable_income)

  list(
    financial_year = "2026-27",
    taxable_income = taxable_income,
    basic_income_tax = basic_tax,
    lito = lito,
    lito_applied = lito_applied,
    income_tax_after_lito = income_tax_after_lito,
    medicare_levy = medicare_levy,
    total_tax_and_levies = income_tax_after_lito + medicare_levy
  )
}
