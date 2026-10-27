# Exercise input validation in the generic evaluator in addition to the
# policy-specific validation covered by test-tax-core.R.
source(testthat::test_path("../../R/policy_schedules_2026_27.R"))
source(testthat::test_path("../../R/tax_core.R"))

testthat::test_that("generic evaluator rejects invalid inputs", {
  schedule <- policy_schedules_2026_27$resident_income_tax$schedule

  testthat::expect_error(evaluate_piecewise_schedule(NA_real_, schedule),
                         "finite, non-negative")
  testthat::expect_error(evaluate_piecewise_schedule(Inf, schedule),
                         "finite, non-negative")
  testthat::expect_error(evaluate_piecewise_schedule(-1, schedule),
                         "finite, non-negative")
  testthat::expect_error(evaluate_piecewise_schedule(c(1, 2), schedule),
                         "finite, non-negative")
})

testthat::test_that("generic evaluator rejects malformed schedule values", {
  valid <- data.frame(
    lower_bound = c(0, 10),
    upper_bound = c(10, Inf),
    value_at_lower = c(0, 5),
    slope = c(0.5, 1)
  )

  bad_slope <- valid
  bad_slope$slope[1] <- NA_real_
  testthat::expect_error(evaluate_piecewise_schedule(5, bad_slope),
                         "invalid")

  bad_terminal_interval <- valid
  bad_terminal_interval$upper_bound[2] <- 100
  testthat::expect_error(evaluate_piecewise_schedule(5, bad_terminal_interval),
                         "ending at Inf")
})
