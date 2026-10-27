# These tests source the calculation file directly because the package
# scaffold and test runner are not yet configured.
source(testthat::test_path("../../R/tax_core.R"))

testthat::test_that("resident tax brackets have the correct boundaries", {
  testthat::expect_equal(resident_income_tax_2026_27(18200), 0)
  testthat::expect_equal(resident_income_tax_2026_27(18201), 0.15)
  testthat::expect_equal(resident_income_tax_2026_27(45000), 4020)
  testthat::expect_equal(resident_income_tax_2026_27(45001), 4020.30)
  testthat::expect_equal(resident_income_tax_2026_27(135000), 31020)
  testthat::expect_equal(resident_income_tax_2026_27(135001), 31020.37)
  testthat::expect_equal(resident_income_tax_2026_27(190000), 51370)
  testthat::expect_equal(resident_income_tax_2026_27(190001), 51370.45)
})

testthat::test_that("LITO tapers and floors at zero", {
  testthat::expect_equal(lito_2026_27(0), 700)
  testthat::expect_equal(lito_2026_27(37500), 700)
  testthat::expect_equal(lito_2026_27(37501), 699.95)
  testthat::expect_equal(lito_2026_27(45000), 325)
  testthat::expect_equal(lito_2026_27(45001), 324.985)
  testthat::expect_equal(lito_2026_27(66667), 0)
  testthat::expect_equal(lito_2026_27(70000), 0)
})

testthat::test_that("Medicare levy threshold and phase-in boundaries are correct", {
  testthat::expect_equal(medicare_levy_2026_27(28011), 0)
  testthat::expect_equal(medicare_levy_2026_27(28012), 0.10)
  testthat::expect_equal(medicare_levy_2026_27(35012), 700.10)
  testthat::expect_equal(medicare_levy_2026_27(35013), 700.26)
  testthat::expect_equal(medicare_levy_2026_27(50000), 1000)
})

testthat::test_that("LITO reduces income tax but not the Medicare levy", {
  result <- individual_tax_components_2026_27(30000)
  testthat::expect_equal(result$basic_income_tax, 1770)
  testthat::expect_equal(result$lito, 700)
  testthat::expect_equal(result$income_tax_after_lito, 1070)
  testthat::expect_equal(result$medicare_levy, 198.9)
  testthat::expect_equal(result$total_tax_and_levies, 1268.9)
})

testthat::test_that("worked examples reproduce the documented component totals", {
  low <- individual_tax_components_2026_27(26000)
  testthat::expect_equal(low$basic_income_tax, 1170)
  testthat::expect_equal(low$lito, 700)
  testthat::expect_equal(low$income_tax_after_lito, 470)
  testthat::expect_equal(low$medicare_levy, 0)
  testthat::expect_equal(low$total_tax_and_levies, 470)

  middle <- individual_tax_components_2026_27(60000)
  testthat::expect_equal(middle$basic_income_tax, 8520)
  testthat::expect_equal(middle$lito, 100)
  testthat::expect_equal(middle$income_tax_after_lito, 8420)
  testthat::expect_equal(middle$medicare_levy, 1200)
  testthat::expect_equal(middle$total_tax_and_levies, 9620)
})

testthat::test_that("invalid taxable income is rejected", {
  testthat::expect_error(resident_income_tax_2026_27(-1), "non-negative")
  testthat::expect_error(lito_2026_27(1.5), "whole-dollar")
  testthat::expect_error(medicare_levy_2026_27(NA_real_), "finite")
  testthat::expect_error(individual_tax_components_2026_27(c(10000, 20000)),
                         "one finite")
})
