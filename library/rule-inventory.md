# Initial Australian tax and benefits rule inventory

## Purpose

This inventory defines the policy areas to investigate for the first useful version of metrscope. It is a planning and research register, not a statement that any listed rule has been verified or implemented. Before implementing a rule, identify its authoritative source, applicable financial year or effective dates, eligibility conditions, calculation method, interactions, and validation cases.

The initial scope is Australian resident individuals and working-age households, including single adults, couples, and families with children. Retirees, non-residents, complex tax arrangements, and other special cases may be added later. Do not silently treat out-of-scope cases as if the model fully supports them.

## Modelling principles

1. **Calculate components before aggregates.** Each tax, transfer, subsidy, contribution, or cost should be calculated as a distinct component. The overall marginal effective tax rate (METR) is derived from scenario differences; it is not a substitute for the underlying calculations.
2. **Compare scenarios consistently.** Evaluate a baseline household and a changed household using the same financial year, policy assumptions, resource definitions, and calculation conventions. Recalculate all components affected by the change, including interactions.
3. **Support different kinds of changes.** Scenario changes may include income amount or type, partner income, having or changing the number/age of children, rent, childcare use or fees, and employment/activity circumstances. Do not assume every scenario is an earnings-only METR.
4. **Make resource measures explicit.** At minimum, distinguish cash available to spend from broader resources that include employer superannuation. Decide and document how tax on super contributions, restricted/non-cash benefits, childcare costs, and other costs are treated in each measure. Never add unlike components into one headline total without defining the measure.
5. **Show gross and net component effects.** For each scenario, retain baseline amount, changed amount, difference, sign/direction, category, calculation period, source/rule reference, and explanatory notes where feasible. The interface should show an aggregate result and a component-level breakdown.
6. **Keep policy separate from modelling choices.** Mark simplifications and exclusions explicitly. A simplified representation is acceptable only when its likely effect and limitations are understood; do not assume two rules are interchangeable merely because they have similar labels.
7. **Use authoritative, year-specific evidence.** Prefer legislation and official guidance from the responsible Australian Government agency. Record the source and the date checked in the [source register](source-register.md). Do not enter guessed thresholds or rates as verified facts.

## Inventory fields

Each row below is an area to investigate, not an implemented rule.

- **Area / component:** policy or financial-flow component.
- **Inputs and eligibility:** household and income information needed.
- **Calculation and interactions:** what needs to be calculated and which other components may be affected.
- **Resource classification:** cash income, tax/levy, transfer, subsidy, superannuation, cost, or other.
- **Initial treatment:** explicit calculation, aggregate approximation, or out of scope.
- **Period and source:** financial year/effective dates and specific authoritative source to be recorded in the source register.
- **Status:** use 'not researched', 'researched', 'specified', 'implemented', or 'validated'. These are distinct stages; listing a topic here does not mean it is researched.

## Initial rule inventory

| Area / component | Inputs and eligibility to investigate | Calculation and interactions to investigate | Initial treatment | Status |
|---|---|---|---|---|
| Resident individual income tax | Financial year, tax residency, taxable income, deductions and relevant offsets | Tax brackets and thresholds; tax-free threshold; taxable-income definition; rounding; interactions with income-tested payments | Explicit core calculation; start with common resident circumstances | not researched |
| Medicare levy and applicable variations | Taxable income, family status, dependants and relevant eligibility/exemption information | Standard levy and relevant low-income thresholds, reductions or exemptions; avoid assuming every taxpayer pays the same effective levy | Explicit where in initial scope; document exclusions | not researched |
| Deductions | Total deductions and any characteristics that affect adjusted income or eligibility tests | Taxable income versus adjusted income measures used by transfers; distinguish a simple total from items with materially different treatment | Aggregate where safe; retain distinctions affecting other tests | not researched |
| Individual tax offsets and rebates | Eligibility characteristics and relevant income measures | Broadly applicable offsets, phase-ins/phase-outs and interactions with tax payable | Prioritise common, material cases; defer uncommon cases explicitly | not researched |
| HELP / other income-contingent repayments | Relevant loan status, repayment income and financial year | Repayment thresholds and rates; distinguish repayment liability from income tax and clarify cash-flow conventions | Consider for initial scope; decide explicitly | not researched |
| Family Tax Benefit Part A | Family composition, child ages, family income measures, care arrangements and relevant circumstances | Rates, income tests, thresholds, supplements and interactions with Part B and other payments | Explicit core family-payment candidate | not researched |
| Family Tax Benefit Part B | Couple/single-parent status, youngest child age, relevant individual/family income and eligibility conditions | Eligibility and income tests; interaction with Part A and household changes | Explicit core family-payment candidate | not researched |
| Child Care Subsidy | Child and care details, approved care, fees, activity/eligibility details, family income and hours | Subsidy rate, applicable hourly fee cap, activity test and relevant limits; effect of childcare use and fees on net resources | Explicit or carefully scoped approximation; document assumptions | not researched |
| Commonwealth Rent Assistance | Eligible payment/family status, rent, household composition and relevant thresholds | Eligibility, rent thresholds, maximum rates and tapering; interaction with qualifying payments | Explicit candidate where eligibility can be modelled transparently | not researched |
| Other working-age income support (e.g. JobSeeker Payment, Parenting Payment, Disability Support Pension) | Payment-specific eligibility, partner income, assets where relevant, income types and reporting period | Payment-specific income tests, tapers, waiting periods or exclusions where in scope; interactions with tax and family payments | Select a justified subset; otherwise mark out of scope rather than approximate silently | not researched |
| Employer superannuation contributions and contributions tax | Ordinary time earnings or other relevant earnings basis, contribution rate, caps and relevant circumstances | Separate employer contribution from wages; identify contributions tax and any material eligibility/means-test treatment | Report separately; include in broader resource measure only under an explicit definition | not researched |
| Other income and reportable amounts | Interest, investment or other income; salary sacrifice/reportable fringe benefits where relevant | Tax treatment and possible effects on adjusted taxable/family income or payment tests | Add common material types; otherwise document exclusions | not researched |
| Household costs affected by circumstances | Childcare out-of-pocket costs and other selected costs that change with the scenario | Difference in costs between baseline and changed scenario; avoid mixing costs into a transfer or tax component | Include only where measurable and relevant to a declared resource measure | not researched |
| Additional child or changed household composition | Child number/ages, partner status, care arrangements, childcare and housing circumstances | Recalculate every affected tax, transfer, subsidy and included cost; do not model as a standalone “child effect” without component results | Scenario-level integration test, after component rules are specified | not researched |
| Housing, assets and other means tests | Rent, assets, home ownership and payment-specific circumstances | Identify where an asset or housing test is essential for eligibility; do not assume income alone determines eligibility | Scope decision required for each payment | not researched |

## Scenario and resource accounting specification

For a baseline scenario S0 and changed scenario S1, calculate each in-scope component under the same rules and period. For component j, retain:

- baseline amount Cj(S0);
- changed amount Cj(S1);
- difference ΔCj = Cj(S1) − Cj(S0);
- component type and resource classification;
- applicable source, financial year, assumptions, and explanatory information.

Aggregate changes only after defining which components belong to a selected resource measure. A possible cash-resource measure is:

D_cash = cash earnings after tax and repayments + cash transfers − included out-of-pocket costs.

A broader compensation/resource measure may additionally include employer superannuation or other non-cash items, with relevant taxes and restrictions treated consistently. These are candidate definitions, not final decisions; specify the selected measures before reporting METRs.

For an earnings scenario, a finite-change METR can be reported as:

METR = 1 − ΔD / ΔY,

where ΔY is the specified change in gross earnings and ΔD is the corresponding change in the chosen resource measure. Report the earnings increment and resource definition alongside the result. Finite-change METRs may depend on the size of the increment, particularly near thresholds, tapers and eligibility cliffs.

For non-earnings changes (such as having another child), report component and aggregate changes directly. Do not label the result an earnings METR unless a meaningful earnings increment is actually being evaluated.

## Suggested sequencing

1. Research and specify resident income tax and Medicare levy for one selected financial year, including boundary cases.
2. Define the resource measure(s), ledger categories, sign conventions, and scenario-comparison contract before presenting METR results.
3. Research Family Tax Benefit Parts A and B, Child Care Subsidy, and Rent Assistance, documenting eligibility and interactions before implementation.
4. Add other income-tested payments only after deciding which eligibility and means tests the first version can credibly support.
5. Validate both individual components and combined scenarios, including income thresholds, partner income, and changes in child or household circumstances.

## Official starting points

Use these as discovery starting points only; find and record the specific page, legislation or instrument, version, and effective dates for each rule before implementation.

- Australian Taxation Office: https://www.ato.gov.au/
- Federal Register of Legislation: https://www.legislation.gov.au/
- Services Australia: https://www.servicesaustralia.gov.au/
- Department of Social Services: https://www.dss.gov.au/
