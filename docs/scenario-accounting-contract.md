# Scenario comparison and component-ledger contract

## Purpose and status

This document defines the initial software contract for comparing two household scenarios. It is a modelling interface, not a tax or benefit rule specification. The functions in `R/scenario_ledger.R` align supplied component results and calculate differences; they do not calculate tax, eligibility, benefit rates, or policy interactions.

## Scenario object

A scenario created by `new_scenario()` contains:

- `scenario_id`: stable identifier for this scenario;
- `financial_year`: explicit Australian financial-year label (for example, `2026-27`);
- `period`: the period represented by all monetary amounts in the ledger (for example, `annual` or `fortnightly`);
- `inputs`: a named list of scenario inputs, kept separate from calculated results;
- `ledger`: one row per calculated component.

Comparisons are permitted only when both scenarios use the same financial year and period. The current contract does not convert between periods or infer missing inputs.

## Component ledger

Every ledger row has these columns:

| Field | Meaning |
| --- | --- |
| `component_id` | Stable key used to match the same component between scenarios; unique within a scenario |
| `label` | Display label |
| `category` | Broad component type, such as income, tax, transfer, cost, or superannuation |
| `amount` | Non-negative magnitude of the component for the declared period |
| `effect_on_cash` | Signed contribution to the chosen disposable-cash measure |
| `effect_on_broader_resources` | Signed contribution to a separately defined broader-resource measure |
| `source_ref` | Source, rule, or calculation reference; use an explicit placeholder for illustrative test data |
| `notes` | Assumptions or explanation; may be empty |

The amount is a display magnitude, not the signed effect. For example, a tax liability may have `amount = 100` and `effect_on_cash = -100`. Both resource-effect fields are explicit inputs: the ledger does not infer their values from `category` or `amount`. This prevents hidden choices about whether an item belongs in a measure.

For the initial implementation, resource effects are supplied by the calculation that creates each row. Before using a broader-resource total in a user-facing METR, the project must define that measure precisely, including employer superannuation, contributions tax, non-cash items, and any relevant restrictions.

### Avoiding double counting

Each economic effect must be represented once in a selected aggregate. In particular, Child Care Subsidy is generally paid to the provider and reduces the family's fee. An implementation may represent gross fees and a subsidy offset as separate signed ledger rows, or record only the net out-of-pocket cost. It must not both count the subsidy as unrestricted cash paid to the family and subtract the already-reduced fee. The correct representation must be documented for each component.

The same principle applies to superannuation: employer contributions are not cash wages. Include them only in a clearly named broader-resource measure, and treat contributions tax consistently.

## Scenario comparison

`compare_scenarios(baseline, changed)` matches rows by `component_id`, returning baseline amount, changed amount, amount difference, each resource effect in both scenarios, and the difference in each resource effect.

For component (j):

- `delta_amount = amount_changed - amount_baseline`;
- `delta_effect_on_cash = effect_on_cash_changed - effect_on_cash_baseline`;
- `delta_effect_on_broader_resources = effect_on_broader_resources_changed - effect_on_broader_resources_baseline`.

A component present in only one ledger is treated as zero in the other scenario. This is appropriate only if omission genuinely means that the component has zero value in that scenario; callers must not use omission to represent an uncalculated or unknown result. Stable component identifiers and explicit zero rows are preferable when absence could be ambiguous.

The comparison also returns totals of the signed resource effects in each scenario and their differences. These totals are arithmetic summaries of the supplied rows, not a declaration that the selected resource measures are final or policy-complete.

## METR is a later layer

For an earnings change, a finite-change METR may be calculated only after choosing the resource measure and identifying the gross earnings change (Delta Y):

`METR = 1 - Delta D / Delta Y`

where (Delta D) is the change in the selected resource measure. Report the earnings increment, financial year, period, and resource definition. Do not calculate a METR for a non-earnings change, and do not silently substitute a finite-difference result for a point marginal rate.

## Deliberate non-goals

This contract does not:

- implement any tax, transfer, subsidy, superannuation, or cost rule;
- establish final definitions for cash disposable income or broader resources;
- automatically calculate adjusted taxable income, family income, eligibility, or interactions;
- convert annual and fortnightly amounts;
- implement rounding or financial-year policy parameters;
- claim that illustrative ledger values are authoritative or validated.

Those decisions belong in subsequent, separately tested calculation components and policy specifications.
