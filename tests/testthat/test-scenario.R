source(testthat::test_path("../../R/scenario.R"))

testthat::test_that("new_scenario creates a scenario with one adult", {
  x <- new_scenario("2026-27", list(list(taxable_income = 60000)))

  testthat::expect_s3_class(x, "scenario")
  testthat::expect_named(x, c("financial_year", "adults"))
  testthat::expect_identical(x$financial_year, "2026-27")
  testthat::expect_identical(x$adults[[1]]$taxable_income, 60000)
})

testthat::test_that("new_scenario supports two adults", {
  x <- new_scenario(
    "2026-27",
    list(list(taxable_income = 60000), list(taxable_income = 40000))
  )

  testthat::expect_length(x$adults, 2)
  testthat::expect_equal(vapply(x$adults, `[[`, numeric(1), "taxable_income"),
                         c(60000, 40000))
})

testthat::test_that("scenario validates financial year", {
  testthat::expect_error(new_scenario("", list(list(taxable_income = 60000))),
                         "financial_year")
  testthat::expect_error(new_scenario(NA_character_, list(list(taxable_income = 60000))),
                         "financial_year")
  testthat::expect_error(new_scenario(c("2025-26", "2026-27"),
                                      list(list(taxable_income = 60000))),
                         "financial_year")
  testthat::expect_error(new_scenario(2026, list(list(taxable_income = 60000))),
                         "financial_year")
})

testthat::test_that("scenario validates the number and structure of adults", {
  testthat::expect_error(new_scenario("2026-27", list()),
                         "one or two adults")
  testthat::expect_error(new_scenario("2026-27", list(
    list(taxable_income = 10000), list(taxable_income = 20000),
    list(taxable_income = 30000)
  )), "one or two adults")
  testthat::expect_error(new_scenario("2026-27", list(list())),
                         "taxable_income")
})

testthat::test_that("scenario validates adult taxable incomes", {
  invalid <- list(-1, 1.5, NA_real_, Inf, c(10000, 20000), "10000")
  for (income in invalid) {
    testthat::expect_error(
      new_scenario("2026-27", list(list(taxable_income = income))),
      "taxable_income"
    )
  }
})

testthat::test_that("scenario can record a year before its tax rules are implemented", {
  x <- new_scenario("2025-26", list(list(taxable_income = 60000)))

  testthat::expect_identical(x$financial_year, "2025-26")
  testthat::expect_identical(x$adults[[1]]$taxable_income, 60000)
})
