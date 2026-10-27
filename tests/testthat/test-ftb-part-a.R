source(testthat::test_path("../../R/policy_schedules_2026_27.R"))
source(testthat::test_path("../../R/scenario.R"))
source(testthat::test_path("../../R/tax_core.R"))

make_ftb_scenario <- function(income, children, partner_income = NULL, ...) {
  adults <- list(new_adult(income, ...))
  if (!is.null(partner_income)) {
    adults[[2]] <- new_adult(partner_income)
  }
  new_scenario(
    "2026-27",
    adults,
    children = children
  )
}

testthat::test_that("FTB-A uses child age-specific maximum and base rates", {
  young <- make_ftb_scenario(0, list(new_child(5)))
  teen <- make_ftb_scenario(0, list(new_child(14)))
  testthat::expect_equal(unname(family_tax_benefit_part_a(young)), 6139.30)
  testthat::expect_equal(unname(family_tax_benefit_part_a(teen)), 7989.85)

  above_limit <- make_ftb_scenario(129648, list(new_child(5)))
  testthat::expect_equal(unname(family_tax_benefit_part_a(above_limit)), 0)
})

testthat::test_that("FTB-A method 1 income test has boundary behaviour", {
  child <- list(new_child(5))
  free_area <- make_ftb_scenario(69131, child)
  over_free_area <- make_ftb_scenario(69132, child)
  base_rate <- make_ftb_scenario(89973, child)

  testthat::expect_equal(unname(family_tax_benefit_part_a(free_area)), 6139.30)
  testthat::expect_equal(unname(family_tax_benefit_part_a(over_free_area)), 6139.10)
  testthat::expect_equal(unname(family_tax_benefit_part_a(base_rate)), 1971)
  testthat::expect_equal(ftb_part_a_components(over_free_area)$income_test_method,
                         "method_1")
})

testthat::test_that("FTB-A method 2 reduces the base rate above the higher free area", {
  child <- list(new_child(5))
  at_threshold <- make_ftb_scenario(123078, child)
  just_over <- make_ftb_scenario(123079, child)
  nil_rate <- make_ftb_scenario(129648, child)

  testthat::expect_equal(unname(family_tax_benefit_part_a(at_threshold)), 1971)
  testthat::expect_equal(unname(family_tax_benefit_part_a(just_over)), 1970.70)
  testthat::expect_equal(unname(family_tax_benefit_part_a(nil_rate)), 0)
  testthat::expect_equal(ftb_part_a_components(just_over)$income_test_method,
                         "method_2")
})

testthat::test_that("larger families compare both rates above the higher income area", {
  children <- list(new_child(5), new_child(6), new_child(7))
  scenario <- make_ftb_scenario(123079, children)
  components <- ftb_part_a_components(scenario)

  testthat::expect_equal(components$ftb_part_a, 7628.20)
  testthat::expect_equal(components$income_test_method, "method_1_comparison")
})

testthat::test_that("FTB-A combines both adults' adjusted taxable income", {
  children <- list(new_child(5), new_child(14))
  low_family_income <- make_ftb_scenario(40000, children, partner_income = 20000)
  high_family_income <- make_ftb_scenario(40000, children, partner_income = 40000)

  testthat::expect_equal(
    ftb_part_a_components(low_family_income)$family_adjusted_taxable_income, 60000
  )
  testthat::expect_equal(
    ftb_part_a_components(high_family_income)$family_adjusted_taxable_income, 80000
  )
  testthat::expect_lt(
    unname(family_tax_benefit_part_a(high_family_income)),
    unname(family_tax_benefit_part_a(low_family_income))
  )
})

testthat::test_that("FTB adjusted taxable income uses its own income adjustments", {
  scenario <- make_ftb_scenario(
    50000, list(new_child(5)),
    adjusted_fringe_benefits = 2000,
    target_foreign_income = 1000,
    net_investment_loss = 500,
    tax_free_pension_benefit = 1000,
    reportable_super_contributions = 1500,
    child_maintenance_expenditure = 2000
  )
  testthat::expect_equal(
    ftb_part_a_components(scenario)$family_adjusted_taxable_income,
    54000
  )
})

testthat::test_that("FTB-A returns zero with no eligible children", {
  scenario <- new_scenario("2026-27", list(new_adult(50000)))
  testthat::expect_equal(unname(family_tax_benefit_part_a(scenario)), 0)
})

testthat::test_that("child inputs are validated", {
  testthat::expect_error(new_child(-1), "age")
  testthat::expect_error(new_child(20), "age")
  testthat::expect_error(new_child(16), "secondary school student")
  testthat::expect_error(new_child(15, TRUE), "under age 16")
  testthat::expect_error(new_child(17, NA), "TRUE or FALSE")
})
