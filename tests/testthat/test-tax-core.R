# These tests source the calculation file directly because the package
# scaffold and test runner are not yet configured.
source(testthat::test_path("../../R/policy_schedules_2026_27.R"))
source(testthat::test_path("../../R/scenario.R"))
source(testthat::test_path("../../R/tax_core.R"))

testthat::test_that("resident tax brackets have the correct boundaries", {
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 18200)), 0)
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 18201)), 0.15)
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 45000)), 4020)
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 45001)), 4020.30)
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 135000)), 31020)
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 135001)), 31020.37)
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 190000)), 51370)
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 190001)), 51370.45)
})

testthat::test_that("LITO tapers and floors at zero", {
  testthat::expect_equal(lito(new_scenario("2026-27", 0)), 700)
  testthat::expect_equal(lito(new_scenario("2026-27", 37500)), 700)
  testthat::expect_equal(lito(new_scenario("2026-27", 37501)), 699.95)
  testthat::expect_equal(lito(new_scenario("2026-27", 45000)), 325)
  testthat::expect_equal(lito(new_scenario("2026-27", 45001)), 324.985)
  testthat::expect_equal(lito(new_scenario("2026-27", 66667)), 0)
  testthat::expect_equal(lito(new_scenario("2026-27", 70000)), 0)
})

testthat::test_that("Medicare levy threshold and phase-in boundaries are correct", {
  testthat::expect_equal(medicare_levy(new_scenario("2026-27", 28011)), 0)
  testthat::expect_equal(medicare_levy(new_scenario("2026-27", 28012)), 0.10)
  testthat::expect_equal(medicare_levy(new_scenario("2026-27", 35012)), 700.10)
  testthat::expect_equal(medicare_levy(new_scenario("2026-27", 35013)), 700.26)
  testthat::expect_equal(medicare_levy(new_scenario("2026-27", 50000)), 1000)
})

testthat::test_that("LITO reduces income tax but not the Medicare levy", {
  result <- individual_tax_components(new_scenario("2026-27", 30000))
  testthat::expect_equal(result$basic_income_tax, 1770)
  testthat::expect_equal(result$lito, 700)
  testthat::expect_equal(result$lito_applied, 700)
  testthat::expect_equal(result$income_tax_after_lito, 1070)
  testthat::expect_equal(result$medicare_levy, 198.9)
  testthat::expect_equal(result$total_tax_and_levies, 1268.9)
})

testthat::test_that("worked examples reproduce the documented component totals", {
  low <- individual_tax_components(new_scenario("2026-27", 26000))
  testthat::expect_equal(low$basic_income_tax, 1170)
  testthat::expect_equal(low$lito, 700)
  testthat::expect_equal(low$income_tax_after_lito, 470)
  testthat::expect_equal(low$medicare_levy, 0)
  testthat::expect_equal(low$total_tax_and_levies, 470)

  middle <- individual_tax_components(new_scenario("2026-27", 60000))
  testthat::expect_equal(middle$basic_income_tax, 8520)
  testthat::expect_equal(middle$lito, 100)
  testthat::expect_equal(middle$income_tax_after_lito, 8420)
  testthat::expect_equal(middle$medicare_levy, 1200)
  testthat::expect_equal(middle$total_tax_and_levies, 9620)
})

testthat::test_that("scenario inputs are validated by the tax rules", {
  bad_income <- structure(
    list(financial_year = "2026-27", taxable_income = c(10000, 20000)),
    class = "scenario"
  )
  testthat::expect_error(individual_tax_components(bad_income), "one finite")
  testthat::expect_error(resident_income_tax(list(financial_year = "2026-27", taxable_income = 45000)),
                         "scenario object")
  bad_year <- structure(
    list(financial_year = NA_character_, taxable_income = 45000),
    class = "scenario"
  )
  testthat::expect_error(lito(bad_year), "financial_year must be")
})

testthat::test_that("unused non-refundable LITO is not treated as negative tax", {
  result <- individual_tax_components(new_scenario("2026-27", 10000))
  testthat::expect_equal(result$lito, 700)
  testthat::expect_equal(result$lito_applied, 0)
  testthat::expect_equal(result$income_tax_after_lito, 0)
  testthat::expect_equal(result$total_tax_and_levies, 0)
})


testthat::test_that("generic piecewise schedules evaluate intervals and slopes", {
  schedule <- data.frame(
    lower_bound = c(0, 10, 20),
    upper_bound = c(10, 20, Inf),
    value_at_lower = c(0, 0, 5),
    slope = c(0, 0.5, 1)
  )

  testthat::expect_equal(evaluate_piecewise_schedule(0, schedule), 0)
  testthat::expect_equal(evaluate_piecewise_schedule(10, schedule), 0)
  testthat::expect_equal(evaluate_piecewise_schedule(12, schedule), 1)
  testthat::expect_equal(evaluate_piecewise_schedule(20, schedule), 5)
  testthat::expect_equal(evaluate_piecewise_schedule(23, schedule), 8)
})

testthat::test_that("2026-27 policy schedules reproduce the existing tax rules", {
  testthat::expect_equal(
    evaluate_piecewise_schedule(45000, policy_schedules_2026_27$resident_income_tax$schedule),
    4020
  )
  testthat::expect_equal(
    evaluate_piecewise_schedule(40000, policy_schedules_2026_27$lito$schedule),
    575
  )
  testthat::expect_equal(
    evaluate_piecewise_schedule(35012, policy_schedules_2026_27$medicare_levy_individual$schedule),
    700.10
  )
  testthat::expect_equal(
    evaluate_piecewise_schedule(35013, policy_schedules_2026_27$medicare_levy_individual$schedule),
    700.26
  )
})

testthat::test_that("piecewise schedule rejects malformed interval definitions", {
  bad_gap <- data.frame(
    lower_bound = c(0, 11),
    upper_bound = c(10, Inf),
    value_at_lower = c(0, 0),
    slope = c(0, 1)
  )
  testthat::expect_error(evaluate_piecewise_schedule(5, bad_gap), "contiguous")

  bad_order <- data.frame(
    lower_bound = c(0, 20),
    upper_bound = c(10, Inf),
    value_at_lower = c(0, 0),
    slope = c(0, 1)
  )
  testthat::expect_error(evaluate_piecewise_schedule(5, bad_order), "contiguous")

  testthat::expect_error(
    evaluate_piecewise_schedule(-1, policy_schedules_2026_27$lito$schedule),
    "non-negative"
  )
})


testthat::test_that("public tax functions require a supported financial year", {
  testthat::expect_equal(resident_income_tax(new_scenario("2026-27", 45000)), 4020)
  testthat::expect_equal(lito(new_scenario("2026-27", 40000)), 575)
  testthat::expect_equal(medicare_levy(new_scenario("2026-27", 50000)), 1000)
  testthat::expect_error(resident_income_tax(new_scenario("2025-26", 45000)),
                         "Unsupported financial_year")
  bad_year <- structure(
    list(financial_year = NA_character_, taxable_income = 40000),
    class = "scenario"
  )
  testthat::expect_error(lito(bad_year), "financial_year must be")
  testthat::expect_error(individual_tax_components(new_scenario("2025-26", 40000)),
                         "Unsupported financial_year")
})
