# Core individual tax calculations.
#
# Public tax-rule functions accept a scenario object and calculate the relevant
# rule for each adult. Individual rules are evaluated per adult; the Medicare
# levy surcharge (MLS) additionally uses household income, dependent children,
# and hospital-cover status. Policy parameters are in
# R/policy_schedules_2026_27.R.
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

.apply_individual_rule <- function(scenario, schedule_name) {
  incomes <- .scenario_adult_incomes(scenario)
  values <- vapply(
    incomes,
    function(income) {
      .policy_schedule_value(
        income, schedule_name, scenario$financial_year
      )
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
  .apply_individual_rule(scenario, "lito")
}

medicare_levy <- function(scenario) {
  .apply_individual_rule(scenario, "medicare_levy_individual")
}

# Income used to determine the applicable MLS threshold tier. These additions
# affect the threshold test, but not all are included in the surcharge base.
.adult_mls_income <- function(adult) {
  adult$taxable_income +
    adult$reportable_fringe_benefits +
    adult$reportable_super_contributions +
    adult$net_investment_loss +
    adult$family_trust_distribution
}

# Calculate the annual MLS for each adult in a scenario.
#
# Scope: full-year household circumstances and cover status. The scenario's
# cover flag means the taxpayer(s) and all relevant dependants had appropriate
# hospital cover for the full year. Part-year cover, relationship changes,
# exemptions, prescribed-person rules, and assessable FHSS released amounts
# are not modelled. The surcharge base is taxable income plus reportable fringe
# benefits; other MLS income adjustments determine the threshold tier only.
medicare_levy_surcharge <- function(scenario) {
  .validate_scenario(scenario)
  policy <- .policy_schedules_for_year(scenario$financial_year)$medicare_levy_surcharge

  incomes <- .scenario_adult_incomes(scenario)
  names(incomes) <- paste0("adult_", seq_along(incomes))
  zero <- stats::setNames(rep(0, length(incomes)), names(incomes))

  if (scenario$appropriate_hospital_cover) {
    return(zero)
  }

  adult_mls_income <- vapply(scenario$adults, .adult_mls_income, numeric(1))
  family_mls_income <- sum(adult_mls_income)
  uses_family_threshold <- length(scenario$adults) == 2L ||
    scenario$dependent_children > 0

  if (uses_family_threshold) {
    thresholds <- policy$family_thresholds +
      policy$extra_child_threshold * max(0, scenario$dependent_children - 1)
  } else {
    thresholds <- policy$single_thresholds
  }

  rate <- if (family_mls_income <= thresholds[1]) {
    policy$rates[1]
  } else if (family_mls_income <= thresholds[2]) {
    policy$rates[2]
  } else if (family_mls_income <= thresholds[3]) {
    policy$rates[3]
  } else {
    policy$rates[4]
  }

  individual_threshold_income <- adult_mls_income > policy$individual_income_threshold
  surcharge_base <- vapply(
    scenario$adults,
    function(adult) adult$taxable_income + adult$reportable_fringe_benefits,
    numeric(1)
  )
  surcharge <- ifelse(individual_threshold_income, surcharge_base * rate, 0)
  names(surcharge) <- names(incomes)
  surcharge
}

# Adjusted taxable income for FTB purposes. This differs from MLS income:
# it includes adjusted fringe benefits, target foreign income, tax-free pension
# or benefit amounts, reportable super contributions and subtracts child
# maintenance expenditure.
.adult_ftb_adjusted_taxable_income <- function(adult) {
  adult$taxable_income +
    adult$adjusted_fringe_benefits +
    adult$target_foreign_income +
    adult$net_investment_loss +
    adult$tax_free_pension_benefit +
    adult$reportable_super_contributions -
    adult$child_maintenance_expenditure
}

.ftb_part_a_calculation <- function(scenario) {
  .validate_scenario(scenario)
  policy <- .policy_schedules_for_year(scenario$financial_year)$family_tax_benefit_part_a
  children <- scenario$ftb_children
  if (length(children) == 0L) {
    return(list(
      family_adjusted_taxable_income = max(0, sum(vapply(
        scenario$adults, .adult_ftb_adjusted_taxable_income, numeric(1)
      ))),
      maximum_rate = 0,
      base_rate = 0,
      income_test_method = "none",
      income_test_reduction = 0,
      ftb_part_a = 0
    ))
  }

  family_ati <- max(0, sum(vapply(
    scenario$adults, .adult_ftb_adjusted_taxable_income, numeric(1)
  )))
  child_rates <- vapply(children, function(child) {
    if (child$age < 13) {
      policy$standard_rate_under_13
    } else {
      policy$standard_rate_13_and_over
    }
  }, numeric(1))
  maximum_rate <- sum(child_rates)
  base_rate <- length(children) * policy$base_rate_per_child

  if (family_ati <= policy$higher_income_free_area) {
    reduction <- max(0, family_ati - policy$income_free_area) *
      policy$method_1_taper
    rate <- max(base_rate, maximum_rate - reduction)
    reduction <- maximum_rate - rate
    method <- "method_1"
  } else {
    income_above_higher_area <- family_ati - policy$higher_income_free_area
    method_1_rate <- max(
      0,
      maximum_rate -
        (policy$higher_income_free_area - policy$income_free_area) *
          policy$method_1_taper -
        income_above_higher_area * policy$method_2_taper
    )
    method_2_rate <- max(
      0,
      base_rate - income_above_higher_area * policy$method_2_taper
    )
    rate <- max(method_1_rate, method_2_rate)
    if (method_1_rate > method_2_rate) {
      method <- "method_1_comparison"
      reduction <- maximum_rate - rate
    } else {
      method <- "method_2"
      reduction <- base_rate - rate
    }
  }

  list(
    family_adjusted_taxable_income = family_ati,
    maximum_rate = maximum_rate,
    base_rate = base_rate,
    income_test_method = method,
    income_test_reduction = reduction,
    ftb_part_a = rate
  )
}

# Calculate the annual FTB Part A rate after the family income test but before
# the maintenance income test, FTB-A supplement, Rent Assistance, Energy
# Supplement, and other eligibility-related adjustments.
family_tax_benefit_part_a <- function(scenario) {
  result <- .ftb_part_a_calculation(scenario)
  stats::setNames(result$ftb_part_a, "family")
}

# Expose the main intermediate quantities so downstream METR calculations can
# show why a change in either adult's income changes the household payment.
ftb_part_a_components <- function(scenario) {
  result <- .ftb_part_a_calculation(scenario)
  data.frame(
    financial_year = scenario$financial_year,
    family_adjusted_taxable_income = result$family_adjusted_taxable_income,
    maximum_rate = result$maximum_rate,
    base_rate = result$base_rate,
    income_test_method = result$income_test_method,
    income_test_reduction = result$income_test_reduction,
    ftb_part_a = result$ftb_part_a
  )
}

# Component-level annual liability for each standard resident individual.
# LITO does not reduce the Medicare levy. MLS is shown separately and is
# included in total_tax_and_levies.
individual_tax_components <- function(scenario) {
  incomes <- .scenario_adult_incomes(scenario)
  basic_tax <- resident_income_tax(scenario)
  lito_entitlement <- lito(scenario)
  lito_applied <- pmin(basic_tax, lito_entitlement)
  income_tax_after_lito <- basic_tax - lito_applied
  levy <- medicare_levy(scenario)
  mls <- medicare_levy_surcharge(scenario)

  data.frame(
    adult = seq_along(incomes),
    financial_year = rep(scenario$financial_year, length(incomes)),
    taxable_income = unname(incomes),
    basic_income_tax = unname(basic_tax),
    lito = unname(lito_entitlement),
    lito_applied = unname(lito_applied),
    income_tax_after_lito = unname(income_tax_after_lito),
    medicare_levy = unname(levy),
    medicare_levy_surcharge = unname(mls),
    total_tax_and_levies = unname(income_tax_after_lito + levy + mls)
  )
}
