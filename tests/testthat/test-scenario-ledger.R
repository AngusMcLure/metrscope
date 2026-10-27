source(testthat::test_path("../../R/scenario_ledger.R"))

scenario_ledger <- function(
    ids = c("earnings", "income_tax"),
    labels = c("Gross earnings", "Income tax"),
    categories = c("income", "tax"),
    amounts = c(1000, 100),
    cash_effects = c(1000, -100),
    broader_effects = c(1000, -100),
    sources = c("illustrative", "illustrative"),
    notes = c("", "")) {
  data.frame(
    component_id = ids,
    label = labels,
    category = categories,
    amount = amounts,
    effect_on_cash = cash_effects,
    effect_on_broader_resources = broader_effects,
    source_ref = sources,
    notes = notes,
    stringsAsFactors = FALSE
  )
}

testthat::test_that("scenario records require explicit period and ledger", {
  ledger <- scenario_ledger()
  scenario <- new_scenario(
    "baseline", "2026-27", "annual", list(gross_income = 50000), ledger
  )

  testthat::expect_s3_class(scenario, "metrscope_scenario")
  testthat::expect_identical(scenario$financial_year, "2026-27")
  testthat::expect_identical(scenario$period, "annual")
  testthat::expect_equal(nrow(scenario$ledger), 2L)
  testthat::expect_error(
    new_scenario("", "2026-27", "annual", list(), ledger),
    "non-empty strings"
  )
  testthat::expect_error(
    new_scenario("baseline", "2026-27", "annual", NULL, ledger),
    "inputs must be a list"
  )
})

testthat::test_that("ledger validates required fields, values, and unique keys", {
  ledger <- scenario_ledger()
  testthat::expect_error(
    new_scenario("baseline", "2026-27", "annual", list(), ledger["amount"]),
    "columns"
  )

  duplicate_ids <- rbind(ledger, ledger[1, ])
  testthat::expect_error(
    new_scenario("baseline", "2026-27", "annual", list(), duplicate_ids),
    "unique"
  )

  negative_amount <- ledger
  negative_amount$amount[1] <- -1
  testthat::expect_error(
    new_scenario("baseline", "2026-27", "annual", list(), negative_amount),
    "non-negative"
  )

  non_finite_effect <- ledger
  non_finite_effect$effect_on_cash[1] <- Inf
  testthat::expect_error(
    new_scenario("baseline", "2026-27", "annual", list(), non_finite_effect),
    "finite"
  )
})

testthat::test_that("scenario comparison aligns components and calculates signed deltas", {
  baseline <- new_scenario(
    "baseline", "2026-27", "annual", list(gross_income = 50000),
    scenario_ledger()
  )
  changed <- new_scenario(
    "changed", "2026-27", "annual", list(gross_income = 51000),
    scenario_ledger(
      ids = c("earnings", "income_tax", "ftb_a"),
      labels = c("Gross earnings", "Income tax", "Family Tax Benefit A"),
      categories = c("income", "tax", "transfer"),
      amounts = c(1100, 130, 50),
      cash_effects = c(1100, -130, 50),
      broader_effects = c(1100, -130, 50),
      sources = c("illustrative", "illustrative", "illustrative"),
      notes = c("", "", "Illustrative transfer component")
    )
  )

  comparison <- compare_scenarios(baseline, changed)
  testthat::expect_s3_class(comparison, "metrscope_scenario_comparison")
  testthat::expect_equal(comparison$components$delta_amount[
    comparison$components$component_id == "earnings"
  ], 100)
  testthat::expect_equal(comparison$components$delta_effect_on_cash[
    comparison$components$component_id == "income_tax"
  ], -30)
  testthat::expect_equal(comparison$components$delta_effect_on_cash[
    comparison$components$component_id == "ftb_a"
  ], 50)
  testthat::expect_equal(comparison$totals$delta_cash_effect, 20)
  testthat::expect_equal(comparison$totals$delta_broader_resource_effect, 20)
})

testthat::test_that("scenario comparison requires matching financial year and period", {
  baseline <- new_scenario(
    "baseline", "2026-27", "annual", list(), scenario_ledger()
  )
  wrong_year <- new_scenario(
    "changed", "2025-26", "annual", list(), scenario_ledger()
  )
  wrong_period <- new_scenario(
    "changed", "2026-27", "fortnightly", list(), scenario_ledger()
  )

  testthat::expect_error(
    compare_scenarios(baseline, wrong_year), "same financial_year"
  )
  testthat::expect_error(
    compare_scenarios(baseline, wrong_period), "same period"
  )
})

testthat::test_that("component amount and resource effects remain distinct", {
  ledger <- scenario_ledger(
    ids = "childcare_fee",
    labels = "Out-of-pocket childcare cost",
    categories = "cost",
    amounts = 200,
    cash_effects = -200,
    broader_effects = -200,
    sources = "illustrative",
    notes = "Net cost after subsidy; subsidy is not separately added to cash."
  )
  scenario <- new_scenario("baseline", "2026-27", "fortnightly", list(), ledger)

  testthat::expect_equal(scenario$ledger$amount, 200)
  testthat::expect_equal(scenario$ledger$effect_on_cash, -200)
  testthat::expect_match(scenario$ledger$notes, "not separately added")
})
