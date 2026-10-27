# Validation specification: individual tax core and MLS, 2026–27

## Scope

The calculation engine models ordinary taxable income of an Australian resident individual, basic income tax, Low Income Tax Offset (LITO), the standard individual Medicare levy, and an initial Medicare levy surcharge (MLS) calculation.

MLS is the first household-dependent rule. It uses the combined income for MLS purposes of one or two adults, the number of dependent children, and a full-year household hospital-cover assumption. The scenario stores each adult's taxable income and MLS income-test adjustments; children and hospital-cover status are separate household fields.

The current MLS implementation is intentionally limited to full-year household circumstances. It does not model part-year cover, changes in relationship status, exemptions or prescribed-person rules, adult dependants, or assessable First Home Super Saver released amounts. It assumes the supplied dependent-child count is the number of MLS-dependent children. It is an analytical model, not a substitute for an ATO assessment.

The code returns unrounded mathematical amounts. Tax-return rounding and other assessment rules must be specified before results are presented as official liability estimates.

## Official sources and parameters

- [Income Tax Rates Act 1986 — compilation effective 1 July 2026, Schedule 7 Part I](https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html): resident marginal rates for 2026–27 are 0% to $18,200, 15% over $18,200 to $45,000, 30% over $45,000 to $135,000, 37% over $135,000 to $190,000, and 45% above $190,000.
- [ATO — Low income tax offset](https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates): maximum $700 to $37,500; taper of 5 cents per dollar from $37,500 to $45,000; then 1.5 cents per dollar from $45,000 to $66,667; nil thereafter. LITO is non-refundable and does not reduce the Medicare levy.
- [Medicare Levy Act 1986 — compilation effective 1 July 2026](https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html): standard individual low-income threshold $28,011 and phase-in limit $35,013; standard levy 2% above the phase-in limit. Between the threshold and phase-in limit, the levy is 10% of the excess over the threshold.
- [Australian Government — private health insurance and the Medicare levy surcharge](https://www.privatehealth.gov.au/health_insurance/surcharges_incentives/medicare_levy.htm): for 2026–27, single thresholds are $105,000, $123,000 and $164,000; family thresholds are $210,000, $246,000 and $328,000. The family thresholds increase by $1,500 for each dependent child after the first. Surcharge rates are 0%, 1%, 1.25% and 1.5%.
- [ATO — income for surcharge purposes](https://www.ato.gov.au/api/public/content/0-5f0fcd18-9557-451f-9f9b-11ce935ea237): MLS income testing includes taxable income, reportable fringe benefits, reportable super contributions, net investment losses, and amounts on which family trust distribution tax has been paid. Net investment losses comprise net financial investment loss and net rental property loss.

## Data-driven policy schedules

Public tax functions accept a scenario object. The current implementation supports `2026-27` only; unsupported years fail clearly rather than falling back to another year. The generic piecewise schedule evaluator is in `R/tax_core.R`, and policy parameters are stored in `R/policy_schedules_2026_27.R`.

Income tax, LITO and the standard Medicare levy are represented as piecewise-linear schedules. Each row covers `[lower_bound, upper_bound)` and evaluates to `value_at_lower + slope * (input - lower_bound)`. MLS is not a single individual piecewise schedule: its tier depends on household income and composition, so the thresholds and rates are stored separately and applied by explicit calculation logic.

## Component calculations

Let (y_i) be adult (i)'s taxable income.

Basic income tax before offsets is the piecewise sum of resident marginal rates:

| Taxable income band | Basic income tax |
|---|---|
| (y \leq 18{,}200) | (0) |
| (18{,}200 < y \leq 45{,}000) | (0.15(y-18{,}200)) |
| (45{,}000 < y \leq 135{,}000) | (4{,}020+0.30(y-45{,}000)) |
| (135{,}000 < y \leq 190{,}000) | (31{,}020+0.37(y-135{,}000)) |
| (y > 190{,}000) | (51{,}370+0.45(y-190{,}000)) |

LITO entitlement is calculated separately from the amount actually applied. The applied offset is the lesser of the entitlement and basic income tax; income tax after LITO is therefore never negative. LITO does not reduce the Medicare levy.

For the standard individual Medicare levy case:

- (y \leq 28{,}011): levy is zero.
- (28{,}011 < y < 35{,}013): levy is (0.10(y-28{,}011)).
- (y \geq 35{,}013): levy is (0.02y).

### Medicare levy surcharge

For each adult, the implementation calculates income for MLS threshold purposes as:

```text
MLS income = taxable income
           + reportable fringe benefits
           + reportable super contributions
           + net investment loss
           + family trust distribution amount
```

The family total is the sum of adult MLS incomes. A single adult without dependent children uses the single thresholds. A couple, or a single adult with dependent children, uses the family thresholds. In the current scenario API, a scenario with two adults assumes they are spouses for MLS purposes; a single-parent scenario has one adult and a positive dependent-child count. The family thresholds increase by $1,500 for each dependent child after the first.

The family total selects the rate tier: 0% up to the first threshold, 1% above the first threshold through the second, 1.25% above the second through the third, and 1.5% above the third. An adult is only charged where their own MLS income exceeds $28,011. The surcharge amount is the selected rate multiplied by that adult's taxable income plus reportable fringe benefits; reportable super contributions and net investment losses affect the threshold tier but are not included in this surcharge base.

The scenario field `appropriate_hospital_cover` means that the taxpayer(s) and all relevant dependants had appropriate private patient hospital cover for the entire financial year. When it is `TRUE`, MLS is zero for all adults. It defaults to `FALSE`, which means the model assumes no appropriate full-year household cover unless specified otherwise.

MLS is returned separately as `medicare_levy_surcharge` in `individual_tax_components()`, and included in `total_tax_and_levies`.

## Worked examples

Amounts are unrounded model outputs, not tax-return assessments. The examples assume standard LITO eligibility, the standard individual Medicare levy case, no relevant MLS income adjustments, no appropriate hospital cover, and no dependants unless stated.

| Scenario | MLS income | MLS rate | MLS |
|---|---:|---:|---:|
| Single adult, taxable income $105,000 | $105,000 | 0% | $0 |
| Single adult, taxable income $105,001 | $105,001 | 1% | $1,050.01 |
| Couple, taxable incomes $150,000 and $70,000 | $220,000 family total | 1% | $1,500 and $700 respectively |
| Single parent, taxable income $211,000, one dependent child | $211,000 | 1% | $2,110 |
| Same single parent with two dependent children | $211,000 | 0% | $0 |

For the couple example, the household total selects the tier, but the surcharge is calculated separately for each adult. For the single-parent examples, the family threshold is $210,000 with one child and $211,500 with two children.

## Boundary and validation cases

The test suite covers:
- resident tax bracket boundaries and LITO taper points;
- Medicare levy threshold and phase-in limit;
- MLS single and family tier boundaries;
- combined partner income selecting a family tier;
- the individual MLS income threshold within a high-income household;
- the additional-child threshold increment;
- MLS income adjustments affecting tier selection without being included in the surcharge base;
- full-year appropriate hospital cover;
- invalid income and household inputs, and unsupported financial years.

At $35,012 the standard Medicare levy phase-in formula gives $700.10; at $35,013 the 2% formula gives $700.26. This small jump follows the statutory threshold/phase-in definitions and is preserved rather than smoothed away.

## Not yet independently validated

- Automated tests are formula-level tests; they are not independent validation against an official 2026–27 assessment.
- The initial MLS model omits part-year cover, relationship changes, exemptions, prescribed-person rules, adult dependants, and First Home Super Saver released amounts.
- Family-threshold Medicare levy reductions, SAPTO, other offsets, HELP repayments, family payments, and other transfer payments remain outside the current scope.
- No baseline-versus-changed-scenario METR calculation or benefit interactions are implemented yet.
