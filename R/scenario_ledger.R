# Scenario representation and component-ledger contract.
#
# This layer compares supplied component results; it does not implement policy
# rules or infer resource effects from component categories. Callers must
# explicitly provide signed effects on cash and broader resources to avoid
# hidden assumptions or double-counting (for example, childcare subsidy).
#
# Required ledger columns:
# - component_id: stable key used to align the same component across scenarios
# - label, category: human-readable name and broad classification
# - amount: non-negative magnitude in the declared scenario period
# - effect_on_cash: signed contribution to disposable cash resources
# - effect_on_broader_resources: signed contribution to the declared broader
#   resource measure (for example, one that includes employer superannuation)
# - source_ref, notes: traceability and scenario-specific explanation

.scenario_ledger_columns <- c(
  "component_id", "label", "category", "amount",
  "effect_on_cash", "effect_on_broader_resources", "source_ref", "notes"
)

.validate_scenario_ledger <- function(ledger) {
  if (!is.data.frame(ledger) ||
      !all(.scenario_ledger_columns %in% names(ledger))) {
    stop(
      paste0(
        "ledger must be a data frame with columns: ",
        paste(.scenario_ledger_columns, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  if (nrow(ledger) > 0L) {
    text_columns <- c(
      "component_id", "label", "category", "source_ref", "notes"
    )
    if (!all(vapply(ledger[text_columns], is.character, logical(1)))) {
      stop("Ledger identifier and descriptive columns must be character.", 
           call. = FALSE)
    }

    if (anyNA(ledger[text_columns]) ||
        any(!nzchar(trimws(ledger$component_id))) ||
        any(!nzchar(trimws(ledger$label))) ||
        any(!nzchar(trimws(ledger$category))) ||
        anyDuplicated(ledger$component_id)) {
      stop(
        "Ledger text fields must not be missing, required labels must be non-empty, and component_id values must be unique.",
        call. = FALSE
      )
    }
  }

  numeric_columns <- c(
    "amount", "effect_on_cash", "effect_on_broader_resources"
  )
  if (!all(vapply(ledger[numeric_columns], is.numeric, logical(1)))) {
    stop("Ledger amount and resource-effect columns must be numeric.",
         call. = FALSE)
  }

  if (anyNA(ledger[numeric_columns]) ||
      any(!is.finite(as.matrix(ledger[numeric_columns]))) ||
      any(ledger$amount < 0)) {
    stop(
      "Ledger numeric values must be finite and non-missing; amount must be non-negative.",
      call. = FALSE
    )
  }

  invisible(ledger)
}

# Construct a scenario with explicit period and financial year.
new_scenario <- function(
    scenario_id,
    financial_year,
    period,
    inputs = list(),
    ledger) {
  scalar_text <- function(x) {
    is.character(x) && length(x) == 1L && !is.na(x) &&
      nzchar(trimws(x))
  }

  if (!scalar_text(scenario_id) || !scalar_text(financial_year) ||
      !scalar_text(period)) {
    stop(
      "scenario_id, financial_year, and period must be non-empty strings.",
      call. = FALSE
    )
  }
  if (!is.list(inputs)) {
    stop("inputs must be a list.", call. = FALSE)
  }
  .validate_scenario_ledger(ledger)

  structure(
    list(
      scenario_id = scenario_id,
      financial_year = financial_year,
      period = period,
      inputs = inputs,
      ledger = ledger[.scenario_ledger_columns]
    ),
    class = "metrscope_scenario"
  )
}

.validate_scenario <- function(scenario, argument_name) {
  if (!inherits(scenario, "metrscope_scenario") ||
      !is.list(scenario) ||
      is.null(scenario$scenario_id) ||
      is.null(scenario$financial_year) ||
      is.null(scenario$period) ||
      is.null(scenario$inputs)) {
    stop(argument_name, " must be created by new_scenario().",
         call. = FALSE)
  }
  .validate_scenario_ledger(scenario$ledger)
  invisible(scenario)
}

# Compare two scenarios by stable component_id. A missing component in either
# scenario is treated as zero for amount and both resource effects. The caller
# remains responsible for ensuring that omitted components genuinely mean zero.
compare_scenarios <- function(baseline, changed) {
  .validate_scenario(baseline, "baseline")
  .validate_scenario(changed, "changed")

  if (!identical(baseline$financial_year, changed$financial_year)) {
    stop("Scenarios must use the same financial_year.", call. = FALSE)
  }
  if (!identical(baseline$period, changed$period)) {
    stop("Scenarios must use the same period.", call. = FALSE)
  }

  left <- baseline$ledger
  right <- changed$ledger
  names(left)[names(left) %in% c(
    "label", "category", "amount", "effect_on_cash",
    "effect_on_broader_resources", "source_ref", "notes"
  )] <- paste0(names(left)[names(left) %in% c(
    "label", "category", "amount", "effect_on_cash",
    "effect_on_broader_resources", "source_ref", "notes"
  )], "_baseline")
  names(right)[names(right) %in% c(
    "label", "category", "amount", "effect_on_cash",
    "effect_on_broader_resources", "source_ref", "notes"
  )] <- paste0(names(right)[names(right) %in% c(
    "label", "category", "amount", "effect_on_cash",
    "effect_on_broader_resources", "source_ref", "notes"
  )], "_changed")

  result <- merge(left, right, by = "component_id", all = TRUE, sort = FALSE)

  # Prefer changed-scenario metadata where available; otherwise retain baseline.
  result$label <- ifelse(
    is.na(result$label_changed), result$label_baseline, result$label_changed
  )
  result$category <- ifelse(
    is.na(result$category_changed),
    result$category_baseline,
    result$category_changed
  )
  result$source_ref <- ifelse(
    is.na(result$source_ref_changed),
    result$source_ref_baseline,
    result$source_ref_changed
  )
  result$notes <- ifelse(
    is.na(result$notes_changed), result$notes_baseline, result$notes_changed
  )

  numeric_pairs <- c(
    "amount", "effect_on_cash", "effect_on_broader_resources"
  )
  for (column in numeric_pairs) {
    baseline_column <- paste0(column, "_baseline")
    changed_column <- paste0(column, "_changed")
    result[[baseline_column]][is.na(result[[baseline_column]])] <- 0
    result[[changed_column]][is.na(result[[changed_column]])] <- 0
    result[[paste0("delta_", column)]] <-
      result[[changed_column]] - result[[baseline_column]]
  }

  result <- result[c(
    "component_id", "label", "category",
    "amount_baseline", "amount_changed", "delta_amount",
    "effect_on_cash_baseline", "effect_on_cash_changed",
    "delta_effect_on_cash",
    "effect_on_broader_resources_baseline",
    "effect_on_broader_resources_changed",
    "delta_effect_on_broader_resources",
    "source_ref", "notes"
  )]
  result <- result[order(result$component_id), , drop = FALSE]
  rownames(result) <- NULL

  structure(
    list(
      financial_year = baseline$financial_year,
      period = baseline$period,
      baseline_scenario_id = baseline$scenario_id,
      changed_scenario_id = changed$scenario_id,
      components = result,
      totals = list(
        baseline_cash_effect = sum(baseline$ledger$effect_on_cash),
        changed_cash_effect = sum(changed$ledger$effect_on_cash),
        delta_cash_effect = sum(changed$ledger$effect_on_cash) -
          sum(baseline$ledger$effect_on_cash),
        baseline_broader_resource_effect =
          sum(baseline$ledger$effect_on_broader_resources),
        changed_broader_resource_effect =
          sum(changed$ledger$effect_on_broader_resources),
        delta_broader_resource_effect =
          sum(changed$ledger$effect_on_broader_resources) -
          sum(baseline$ledger$effect_on_broader_resources)
      )
    ),
    class = "metrscope_scenario_comparison"
  )
}
