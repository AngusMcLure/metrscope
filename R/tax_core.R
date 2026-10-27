# Core individual tax calculations.
#
# Public tax-rule functions accept a single scenario object and calculate the
# relevant individual rule for each adult in that scenario. Policy schedules
# are data, maintained separately in R/policy_schedules_2026_27.R. See
# docs/validation/tax-core-2026-27.md.
# Amounts are returned without final tax-return rounding.

.scenario_adult_incomes <- function(scenario) {
  .validate_scenario(scenario)
  incomes <- vapply(scenario$adults, function(adult) adult$taxable_income,
                    numeric(1))
  names(incomes) <- paste0("adult_", seq_along(incomes))
  incomes
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
  .validate_financial_year(financial_year)

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

.apply_individual_rule <- function(scenario, schedule_name, floor_at_zero = FALSE) {
  incomes <- .scenario_adult_incomes(scenario)
  values <- vapply(
    incomes,
    function(income) {
      value <- .policy_schedule_value(
        income, schedule_name, scenario$financial_year
      )
      if (floor_at_zero) max(0, value) else value
    },
    numeric(1)
  )
  names(values) <- names(incomes)
  values
}

resident_income_tax <- function(scenario) {
  .apply_individual_rule(scenario, "resident_income_tax")
}

lito <- function(scenario) {
  .apply_individual_rule(scenario, "lito", floor_at_zero = TRUE)
}

medicare_levy <- function(scenario) {
  .apply_individual_rule(scenario, "medicare_levy_individual")
}

# Component-level annual liability for each standard resident individual.
# LITO does not reduce the Medicare levy. Rows correspond to adults in the
# order supplied to new_scenario().
individual_tax_components <- function(scenario) {
  incomes <- .scenario_adult_incomes(scenario)
  basic_tax <- resident_income_tax(scenario)
  lito_entitlement <- lito(scenario)
  lito_applied <- pmin(basic_tax, lito_entitlement)
  income_tax_after_lito <- basic_tax - lito_applied
  levy <- medicare_levy(scenario)

  data.frame(
    adult = seq_along(incomes),
    financial_year = rep(scenario$financial_year, length(incomes)),
    taxable_income = unname(incomes),
    basic_income_tax = unname(basic_tax),
    lito = unname(lito_entitlement),
    lito_applied = unname(lito_applied),
    income_tax_after_lito = unname(income_tax_after_lito),
    medicare_levy = unname(levy),
    total_tax_and_levies = unname(income_tax_after_lito + levy)
  )
}
