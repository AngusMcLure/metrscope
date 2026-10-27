source(testthat::test_path("../../R/policy_schedules_2026_27.R"))
source(testthat::test_path("../../R/scenario.R"))
source(testthat::test_path("../../R/tax_core.R"))

testthat::test_that("single MLS thresholds and rates have correct boundaries", {
  make_single <- function(income) {
    new_scenario("2026-27", list(new_adult(income)))
  }

  testthat::expect_equal(
    unname(medicare_levy_surcharge(make_single(105000))),
    0
  )
  testthat::expect_equal(
    unname(medicare_levy_surcharge(make_single(105001))),
    1050.01
  )
  testthat::expect_equal(
    unname(medicare_levy_surcharge(make_single(123001))),
    1537.5125
  )
  testthat::expect_equal(
    unname(medicare_levy_surcharge(make_single(164001))),
    2460.015
  )
})

testthat::test_that("partner income determines family tier but each adult has own surcharge base", {
  couple <- new_scenario(
    "2026-27",
    list(new_adult(150000), new_adult(70000))
  )

  testthat::expect_equal(
    unname(medicare_levy_surcharge(couple)),
    c(1500, 700)
  )
  components <- individual_tax_components(couple)
  testthat::expect_equal(components$medicare_levy_surcharge, c(1500, 700))
  testthat::expect_equal(
    components$total_tax_and_levies,
    components$income_tax_after_lito + components$medicare_levy +
      components$medicare_levy_surcharge
  )
})

testthat::test_that("individual income threshold still applies within a high-income family", {
  couple <- new_scenario(
    "2026-27",
    list(new_adult(201000), new_adult(10000))
  )

  testthat::expect_equal(
    unname(medicare_levy_surcharge(couple)),
    c(2010, 0)
  )
})

testthat::test_that("dependent children increase family thresholds after the first child", {
  one_child <- new_scenario(
    "2026-27",
    list(new_adult(211000)),
    dependent_children = 1
  )
  two_children <- new_scenario(
    "2026-27",
    list(new_adult(211000)),
    dependent_children = 2
  )

  testthat::expect_equal(unname(medicare_levy_surcharge(one_child)), 2110)
  testthat::expect_equal(unname(medicare_levy_surcharge(two_children)), 0)
})

testthat::test_that("MLS income adjustments determine the tier but not the surcharge base", {
  scenario <- new_scenario(
    "2026-27",
    list(new_adult(104000, reportable_super_contributions = 2000))
  )

  testthat::expect_equal(
    unname(medicare_levy_surcharge(scenario)),
    1040
  )
})

testthat::test_that("appropriate full-year household hospital cover removes MLS", {
  scenario <- new_scenario(
    "2026-27",
    list(new_adult(200000), new_adult(100000)),
    appropriate_hospital_cover = TRUE
  )

  testthat::expect_equal(unname(medicare_levy_surcharge(scenario)), c(0, 0))
})

testthat::test_that("MLS inputs are validated", {
  testthat::expect_error(new_adult(60000, reportable_fringe_benefits = -1),
                         "reportable_fringe_benefits")
  testthat::expect_error(new_scenario("2026-27", list(new_adult(60000)),
                                      dependent_children = 1.5),
                         "dependent_children")
  testthat::expect_error(new_scenario("2026-27", list(new_adult(60000)),
                                      appropriate_hospital_cover = NA),
                         "appropriate_hospital_cover")
  testthat::expect_error(
    medicare_levy_surcharge(new_scenario("2025-26", list(new_adult(60000)))),
    "Unsupported financial_year"
  )
})
