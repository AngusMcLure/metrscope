# Validation specification: individual tax core and MLS, 2026–27

## Scope

The calculation engine models ordinary taxable income of an Australian resident individual, basic income tax, Low Income Tax Offset (LITO), the standard individual Medicare levy, and an initial Medicare levy surcharge (MLS) calculation.

MLS is the first household-dependent rule. It uses the combined income for MLS purposes of one or two adults, the number of dependent children, and a full-year household hospital-cover assumption. The scenario stores each adult's taxable income and MLS income-test adjustments; children and hospital-cover status are separate household fields.

The current MLS implementation is intentionally limited to full-year household circumstances. It does not model part-year cover, changes in relationship status, exemptions or prescribed-person rules, adult dependants, or assessable First Home Super Saver released amounts. It assumes the supplied dependent-child count is the number of MLS-dependent children. It is an analytical model, not a substitute for an ATO assessment.

The code returns unrounded mathematical amounts. Tax-return rounding and other assessment rules must be specified before results are presented as official liability estimates.

## Deliberate modelling assumptions and exclusions

These are intentional scope decisions for this model, not features currently planned for implementation. Results should be interpreted on that basis.

- **Full-financial-year household circumstances:** hospital-cover status is represented by one Boolean for the whole financial year. Part-year cover and changes in cover during the year are not modelled.
- **Stable relationship and household structure:** a scenario has one or two adults. Two adults are assumed to be spouses for MLS purposes; one adult with dependent children represents a single-parent family. Relationship changes and changes in household composition during the year are not modelled.
- **Dependent children only:** the model takes a count of MLS-dependent children and applies the published additional-child threshold increment. It does not represent adult dependants or determine eligibility/dependency status from individual circumstances.
- **No special MLS exemptions or prescribed-person cases:** the model does not assess exemptions or prescribed-person rules.
- **Limited MLS income inputs:** the implemented income-test adjustments are reportable fringe benefits, reportable super contributions, net investment loss, and family trust distribution amounts. Assessable First Home Super Saver released amounts are not represented.
- **Appropriate cover is a household-level assumption:** `appropriate_hospital_cover = TRUE` means the taxpayer(s) and all relevant dependants had appropriate private patient hospital cover for the entire financial year. The default `FALSE` assumes no appropriate full-year household cover; it does not infer cover from other inputs.
- **Ordinary individual tax circumstances:** the model currently covers resident income tax, LITO, the standard individual Medicare levy, and the initial MLS calculation. Family-threshold Medicare levy reductions, SAPTO and other offsets, HELP repayments, family payments, childcare and housing support, and other transfer-payment interactions are outside scope.
- **No tax-return rounding or official assessment simulation:** outputs are unrounded mathematical amounts. The model does not reproduce all tax-return rounding, assessment, or personal-circumstance rules and is not a substitute for an ATO assessment or professional tax advice.
- **Financial-year coverage is explicit:** only 2026–27 is implemented. Requests for unsupported years fail rather than silently using a different year's rules.

These assumptions are part of the current model contract. They should remain visible in the user-facing documentation wherever results are presented, rather than being left only in implementation details or test cases.

## Official sources and parameters

- [Income Tax Rates Act 1986 — compilation effective 1 July 2026, Schedule 7 Part I](https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html): resident marginal rates for 2026–27 are 0% to $18,200, 15% over $18,200 to $45,000, 30% over $45,000 to $135,000, 37% over $135,000 to $190,000, and 45% above $190,000.
- [ATO — Low income tax offset](https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates): maximum $700 to $37,500; taper of 5 cents per dollar from $37,500 to $45,000; then 1.5 cents per dollar from $45,000 to $66,667; nil thereafter. LITO is non-refundable and does not reduce the Medicare levy.
- [Medicare Levy Act 1986 — compilation effective 1 July 2026](https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html): standard individual low-income threshold $28,011 and phase-in limit $35,013; standard levy 2% above the phase-in limit. Between the threshold and phase-in limit, the levy is 10% of the excess over the threshold.
- [Australian Government — private health insurance and the Medicare levy surcharge](https://www.privatehealth.gov.au/health_insurance/surcharges_incentives/medicare_levy.htm): for 2026–27, single thresholds are $105,000, $123,000 and $164,000; family thresholds are $210,000, $246,000 and $328,000. The family thresholds increase by $1,500 for each dependent child after the first. Surcharge rates are 0%, 1%, 1.25% and 1.5%.
- [ATO — income for surcharge purposes](https://www.ato.gov.au/api/public/content/0-5f0fcd18-9557-451f-9f9b-11ce935ea237): MLS income testing includes taxable income, reportable fringe benefits, reportable super contributions, net investment losses, and amounts on which family trust distribution tax has been paid. Net investment losses comprise net financial investment loss and net rental property loss.

## Data-driven policy schedules

Public tax functions accept a scenario object. The current implementation supports `2026-27` only; unsupported years fail clearly rather than falling back to another year. The generic piecewise schedule evaluator is in `R/tax_core.R`, and policy parameters are stored in `R/policy_schedules_2026_27.R`.

Income tax, LITO and the standard Medicare levy are represented as piecewise-linear schedules. Each row covers `[lower_bound, upper_bound)` and evaluates to `value_at_lower + slope * (input - lower_bound)`. MLS is not a single individual piecewise schedule: its tier depends on household income and composition, so the thresholds and rates are stored separately and applied by explicit calculation logic.

## Family Tax Benefit Part A

The initial FTB-A implementation calculates an annual rate after applying the family adjusted-taxable-income test, but **before** the maintenance income test, FTB-A supplement, Rent Assistance, Energy Supplement, and other eligibility-related adjustments. It is intended for marginal-effect exploration, not to reproduce a complete Centrelink assessment.

### Inputs and adjusted taxable income

Each adult contributes their adjusted taxable income (ATI) to the family total. The implemented ATI is:

```text
ATI = taxable income
    + adjusted fringe benefits total
    + target foreign income
    + total net investment loss
    + tax-free pension or benefit amounts
    + reportable superannuation contributions
    - child maintenance expenditure
```

The scenario accepts FTB children separately from the dependent-child count used for MLS. Each FTB child is represented by an age from 0 to 19; ages 16–19 must be marked as secondary-school students. This is a simplified eligibility representation, not a full test of all FTB child conditions.

### Income test and rates

The 2026–27 parameters are stored in `R/policy_schedules_2026_27.R` and sourced from Services Australia and the Department of Social Services Family Assistance Guide:

- The income-free area is $69,131.
- The higher income-free area is $123,078.
- Below or at the higher income-free area, Method 1 reduces the sum of maximum age-specific child rates by 20 cents for each dollar of family ATI above $69,131, but not below the base rate.
- Above $123,078, Method 2 reduces the sum of base rates by 30 cents for each dollar of family ATI above $123,078, down to zero. The Method 1 comparison rate is also calculated using a 30-cent taper above $123,078, and the higher of the two rates is used; this matters for larger families.
- The maximum annual rate used is $6,139.30 per child aged under 13 and $7,989.85 per child aged 13–19 who meets the model's secondary-school condition. The base rate is $1,971 per eligible child.

The function `family_tax_benefit_part_a(scenario)` returns the annual family rate after this income test. `ftb_part_a_components(scenario)` exposes family ATI, maximum rate, base rate, selected method, income-test reduction, and resulting FTB-A rate for itemised downstream calculations.

### Deliberate scope assumptions and exclusions

These are intentional scope decisions, not features currently planned for implementation:

- The model assumes the listed children qualify as FTB children; it does not assess residence, care percentages/shared care, immunisation or health-check reductions, age-related exceptions, or other detailed eligibility conditions.
- The maintenance income test and maintenance action test are not modelled. Child maintenance expenditure is included only as an ATI adjustment; child support received or payable is not used to reduce the calculated FTB-A rate.
- The FTB-A supplement and its separate $80,000 income test are excluded, as are Rent Assistance, Energy Supplement, newborn payments and multiple-birth allowances.
- Income-support-payment exceptions to the FTB-A income test are not modelled.
- The calculation is annual and does not model changes in care, relationship status, or income estimates during the year.
- ATI is calculated from the fields represented in this model. Other legal or personal circumstances affecting eligibility or ATI may not be represented.
- The output is an unrounded formula-level annual rate, not a complete Services Australia assessment.

Official references:
- [Services Australia — Income test for FTB Part A](https://www.servicesaustralia.gov.au/income-test-for-family-tax-benefit-part?context=22151)
- [DSS Family Assistance Guide — Current FTB rates and income-test amounts](https://guides.dss.gov.au/family-assistance-guide/3/1/1/20)
- [DSS Family Assistance Guide — Adjusted taxable income](https://guides.dss.gov.au/family-assistance-guide/1/1/a/20)
- [DSS Family Assistance Guide — Calculating a rate of FTB](https://guides.dss.gov.au/family-assistance-guide/3/1/1/10)
- [DSS Family Assistance Guide — Method 2 income test and comparison with Method 1](https://guides.dss.gov.au/family-assistance-guide/3/1/8/20)

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
- FTB-A maximum and base rates by child age;
- FTB-A income-free and higher-income-free-area boundaries, including the transition to nil;
- combined adult ATI and FTB-specific ATI adjustments;
- FTB child input validation;
- invalid income and household inputs, and unsupported financial years.

At $35,012 the standard Medicare levy phase-in formula gives $700.10; at $35,013 the 2% formula gives $700.26. This small jump follows the statutory threshold/phase-in definitions and is preserved rather than smoothed away.

## Not yet independently validated

- Automated tests are formula-level tests; they are not independent validation against an official 2026–27 assessment.
- The initial MLS model omits part-year cover, relationship changes, exemptions, prescribed-person rules, adult dependants, and First Home Super Saver released amounts. The initial FTB-A model excludes maintenance tests, supplements, shared-care and detailed eligibility rules as described above.
- Family-threshold Medicare levy reductions, SAPTO, other offsets, HELP repayments, FTB-A maintenance tests and supplements, Rent Assistance, childcare and housing support, and other transfer-payment interactions remain outside the current scope.
- No baseline-versus-changed-scenario METR calculation or benefit interactions are implemented yet.
