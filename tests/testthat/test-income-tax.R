testthat::test_that("resident tax brackets are continuous at boundaries", {
  testthat::expect_equal(income_tax_before_offsets_2026_27(18200), 0)
  testthat::expect_equal(income_tax_before_offsets_2026_27(45000), 4020)
  testthat::expect_equal(income_tax_before_offsets_2026_27(135000), 31020)
  testthat::expect_equal(income_tax_before_offsets_2026_27(190000), 51370)

  testthat::expect_equal(
    income_tax_before_offsets_2026_27(45001) -
      income_tax_before_offsets_2026_27(45000),
    0.30,
    tolerance = 1e-8
  )
  testthat::expect_equal(
    income_tax_before_offsets_2026_27(135001) -
      income_tax_before_offsets_2026_27(135000),
    0.37,
    tolerance = 1e-8
  )
  testthat::expect_equal(
    income_tax_before_offsets_2026_27(190001) -
      income_tax_before_offsets_2026_27(190000),
    0.45,
    tolerance = 1e-8
  )
})

testthat::test_that("LITO phases out at the specified income thresholds", {
  testthat::expect_equal(lito_2026_27(0), 700)
  testthat::expect_equal(lito_2026_27(37500), 700)
  testthat::expect_equal(lito_2026_27(45000), 325)
  testthat::expect_equal(lito_2026_27(66667), 0)
  testthat::expect_equal(lito_2026_27(70000), 0)
  testthat::expect_equal(lito_2026_27(40000), 575)
  testthat::expect_equal(lito_2026_27(50000), 250)
})

testthat::test_that("standard individual Medicare levy phases in", {
  testthat::expect_equal(medicare_levy_individual_2026_27(28011), 0)
  testthat::expect_equal(medicare_levy_individual_2026_27(28012), 0.1)
  testthat::expect_equal(medicare_levy_individual_2026_27(100000), 2000)
  testthat::expect_true(
    medicare_levy_individual_2026_27(30000) < 0.02 * 30000
  )
})

testthat::test_that("component ledger reconciles", {
  result <- calculate_individual_tax_2026_27(100000)
  testthat::expect_equal(result$financial_year, "2026-27")
  testthat::expect_equal(result$total_income_tax_and_medicare_levy, 22520)
  testthat::expect_equal(result$components$amount[1], 20520)
  testthat::expect_equal(result$components$amount[2], 0)
  testthat::expect_equal(result$components$amount[3], 2000)
  testthat::expect_equal(sum(result$components$amount), 22520)
})

testthat::test_that("invalid taxable income is rejected", {
  testthat::expect_error(income_tax_before_offsets_2026_27(-1))
  testthat::expect_error(income_tax_before_offsets_2026_27(NA_real_))
  testthat::expect_error(income_tax_before_offsets_2026_27(c(100, 200)))
  testthat::expect_error(income_tax_before_offsets_2026_27(Inf))
})

testthat::test_that("non-refundable LITO is not applied beyond tax payable", {
  result <- calculate_individual_tax_2026_27(10000)
  testthat::expect_equal(result$components$amount[1], 0)
  testthat::expect_equal(result$components$amount[2], 0)
  testthat::expect_equal(result$total_income_tax_and_medicare_levy, 0)
})
