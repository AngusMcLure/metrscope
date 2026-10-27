source(testthat::test_path("../../R/scenario.R"))

testthat::test_that("new_adult creates and validates an adult object", {
  adult <- new_adult(60000)

  testthat::expect_s3_class(adult, "adult")
  testthat::expect_named(
    adult,
    c(
      "taxable_income",
      "reportable_fringe_benefits",
      "reportable_super_contributions",
      "net_investment_loss",
      "family_trust_distribution",
      "adjusted_fringe_benefits",
      "target_foreign_income",
      "tax_free_pension_benefit",
      "child_maintenance_expenditure"
    )
  )
  testthat::expect_identical(adult$taxable_income, 60000)
  testthat::expect_invisible(.validate_adult(adult))
})

testthat::test_that("new_adult rejects invalid taxable incomes", {
  invalid <- list(-1, 1.5, NA_real_, Inf, c(10000, 20000), "10000")
  for (income in invalid) {
    testthat::expect_error(new_adult(income), "taxable_income")
  }
})

testthat::test_that("adult validator rejects objects without the adult class", {
  testthat::expect_error(.validate_adult(list(taxable_income = 60000)), "adult object")
  testthat::expect_error(.validate_adult(structure(list(), class = "adult")),
                         "taxable_income")
})

testthat::test_that("new_scenario creates a scenario with one adult", {
  x <- new_scenario("2026-27", list(new_adult(60000)))

  testthat::expect_s3_class(x, "scenario")
  testthat::expect_named(
    x,
    c(
      "financial_year",
      "adults",
      "dependent_children",
      "appropriate_hospital_cover",
      "children"
    )
  )
  testthat::expect_identical(x$financial_year, "2026-27")
  testthat::expect_identical(x$adults[[1]]$taxable_income, 60000)
  testthat::expect_identical(x$dependent_children, 0L)
  testthat::expect_identical(x$appropriate_hospital_cover, FALSE)
  testthat::expect_identical(x$children, list())
})

testthat::test_that("new_scenario supports two adults", {
  x <- new_scenario("2026-27", list(new_adult(60000), new_adult(40000)))

  testthat::expect_length(x$adults, 2)
  testthat::expect_equal(vapply(x$adults, `[[`, numeric(1), "taxable_income"),
                         c(60000, 40000))
})

testthat::test_that("scenario validates financial year", {
  testthat::expect_error(new_scenario("", list(new_adult(60000))), "financial_year")
  testthat::expect_error(new_scenario(NA_character_, list(new_adult(60000))),
                         "financial_year")
  testthat::expect_error(new_scenario(c("2025-26", "2026-27"),
                                      list(new_adult(60000))), "financial_year")
  testthat::expect_error(new_scenario(2026, list(new_adult(60000))), "financial_year")
})

testthat::test_that("adult-list validator checks the count then validates each adult", {
  testthat::expect_error(.validate_adults(list()), "one or two adults")
  testthat::expect_error(.validate_adults(list(new_adult(10000), new_adult(20000),
                                               new_adult(30000))),
                         "one or two adults")
  testthat::expect_error(.validate_adults(list(new_adult(10000), list(taxable_income = 20000))),
                         "adults\\[\\[2\\]\\].*adult object")
  testthat::expect_error(new_scenario("2026-27", list(list())), "adult object")
})

testthat::test_that("scenario can record a year before its tax rules are implemented", {
  x <- new_scenario("2025-26", list(new_adult(60000)))

  testthat::expect_identical(x$financial_year, "2025-26")
  testthat::expect_identical(x$adults[[1]]$taxable_income, 60000)
})

testthat::test_that("scenario derives the dependent-child count from children", {
  one <- new_scenario("2026-27", list(new_adult(60000)),
                      children = list(new_child(5)))
  two <- new_scenario("2026-27", list(new_adult(60000)),
                      children = list(new_child(5), new_child(17, TRUE, "secondary")))

  testthat::expect_identical(one$dependent_children, 1L)
  testthat::expect_identical(two$dependent_children, 2L)
  testthat::expect_length(two$children, 2)
  testthat::expect_identical(two$dependent_children, 2L)
})
