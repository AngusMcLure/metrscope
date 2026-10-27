source(testthat::test_path("../../R/scenario.R"))

testthat::test_that("new_scenario creates a minimal S3 scenario", {
  x <- new_scenario("2026-27", 60000)

  testthat::expect_s3_class(x, "scenario")
  testthat::expect_named(x, c("financial_year", "taxable_income"))
  testthat::expect_identical(x$financial_year, "2026-27")
  testthat::expect_identical(x$taxable_income, 60000)
})

testthat::test_that("scenario validates financial year", {
  testthat::expect_error(new_scenario("", 60000), "financial_year")
  testthat::expect_error(new_scenario(NA_character_, 60000), "financial_year")
  testthat::expect_error(new_scenario(c("2025-26", "2026-27"), 60000),
                         "financial_year")
  testthat::expect_error(new_scenario(2026, 60000), "financial_year")
})

testthat::test_that("scenario validates taxable income", {
  testthat::expect_error(new_scenario("2026-27", -1), "non-negative")
  testthat::expect_error(new_scenario("2026-27", 1.5), "whole-dollar")
  testthat::expect_error(new_scenario("2026-27", NA_real_), "finite")
  testthat::expect_error(new_scenario("2026-27", Inf), "finite")
  testthat::expect_error(new_scenario("2026-27", c(10000, 20000)),
                         "whole-dollar")
})

testthat::test_that("scenario can record a year before its tax rules are implemented", {
  x <- new_scenario("2025-26", 60000)

  testthat::expect_identical(x$financial_year, "2025-26")
  testthat::expect_identical(x$taxable_income, 60000)
})
