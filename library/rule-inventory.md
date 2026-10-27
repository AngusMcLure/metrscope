# Initial Australian tax and benefits rule inventory

## Purpose

This inventory defines the policy areas to investigate for the first useful version of metrscope. It is a planning and research register, not a statement that any listed rule has been verified or implemented. Before implementing a rule, identify its authoritative source, applicable financial year or effective dates, eligibility conditions, calculation method, interactions, and validation cases.

The initial scope is Australian resident individuals and working-age households, including single adults, couples, and families with children. This inventory now includes a first source-based review for 2026–27. It is a policy summary for planning, not a fully researched legal specification or implementation-ready parameter file. Retirees, non-residents, complex tax arrangements, and other special cases may be added later. Do not silently treat out-of-scope cases as if the model fully supports them.

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

## Source-based rule summaries: initial scope for 2026–27

**Reference period:** Australian financial year 1 July 2026 to 30 June 2027. The sources below were checked on 27 October 2026. Some official guidance pages are maintained as live pages and may show the current rate rather than a versioned historical snapshot. Before implementation, save the applicable source version or extract the parameters into a year-specific configuration with a recorded verification date.

These summaries describe the main mechanisms and material interactions. They are not a substitute for checking each eligibility condition, exception, indexation rule, and legislative definition.

### Priority 1 — income tax and levies

#### Individual income tax for Australian residents

For ordinary taxable income of a resident individual in 2026–27, the *Income Tax Rates Act 1986* sets a tax-free threshold of $18,200, then marginal rates of 15% on the portion above $18,200 up to $45,000; 30% on the portion above $45,000 up to $135,000; 37% on the portion above $135,000 up to $190,000; and 45% above $190,000. These are marginal brackets, not rates applied to all income. The 15% rate is specific to 2026–27; the Act provides a 14% rate for 2027–28 and later years, so the tax year must be an explicit input.

Source: [Income Tax Rates Act 1986, compilation effective 1 July 2026 — Schedule 7, Part I](https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html).

**Model inputs and treatment**
- Calculate taxable income from assessable income less allowable deductions, with offsets applied after basic income tax is calculated.
- The initial model should focus on ordinary resident individual income. Treat foreign residents, working-holiday-maker income, minors' special rules, special income components, and complex residency changes as out of scope until separately specified.
- Calculate annual tax liability, not employer PAYG withholding. Withholding is a cash-flow mechanism and may differ from final liability.
- Keep deductions aggregated only where their character does not materially affect another calculation. Family-assistance adjusted taxable income is a separate measure and may add back amounts such as net investment losses or reportable items.

#### Low Income Tax Offset (LITO)

The ATO's published LITO schedule gives a maximum offset of $700 for taxable income up to $37,500; a reduction of 5 cents per dollar between $37,500 and $45,000; then a reduction of 1.5 cents per dollar between $45,000 and $66,667, above which the offset is nil. LITO is a non-refundable offset: it reduces income tax payable but cannot itself produce a refund beyond reducing tax to zero. The ATO states that the Low and Middle Income Tax Offset (LMITO) ended after 2021–22 and should not be included for 2026–27.

Source: [ATO — Tax offsets and rebates, including LITO](https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates).

**Model treatment:** calculate LITO as a distinct tax-offset component and show its change separately from gross income tax. Confirm the current ATO page and legislation when freezing parameters for implementation.

#### Medicare levy

The general Medicare levy is 2%, but the *Medicare Levy Act 1986* provides low-income thresholds, reduced levy phase-ins, family thresholds that vary with dependent children, and special treatment for people eligible for the Seniors and Pensioners Tax Offset (SAPTO). The compilation effective 1 July 2026 sets the general individual threshold at $28,011 and phase-in limit at $35,013; for those entitled to SAPTO, the corresponding figures are $44,268 and $55,335. The family threshold is $47,238 plus $4,338 for each relevant dependent child/student, with separate provisions for SAPTO-eligible families. The Act's family calculation and exemptions mean a flat 2% applied to everyone is not sufficient.

Source: [Medicare Levy Act 1986, compilation effective 1 July 2026](https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html).

**Model inputs and treatment**
- Include taxable income, spouse/family circumstances, relevant dependants and SAPTO eligibility where supported.
- Implement the low-income threshold and phase-in formula, family threshold provisions, and relevant exemptions; document which medical/residency exemptions are out of scope.
- Keep Medicare levy separate from income tax in the component ledger, even if the interface also presents a combined tax-and-levy total.

#### Medicare levy surcharge (MLS)

The MLS is additional to the Medicare levy. It can apply when income for surcharge purposes exceeds the relevant single or family threshold and the taxpayer/family did not hold appropriate private patient hospital cover for the relevant period. The surcharge rate depends on the applicable income tier; income for surcharge purposes is not necessarily taxable income alone. The current *Medicare Levy Act 1986* contains the surcharge provisions, while thresholds/tier definitions are linked to the private health insurance legislation and are subject to change.

Sources: [Medicare Levy Act 1986, sections 8B–8D](https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html); [ATO — Medicare levy surcharge thresholds and rates](https://www.ato.gov.au/individuals-and-families/medicare-and-private-health-insurance/medicare-levy-surcharge/income-thresholds-and-rates).

**Model treatment:** make hospital-cover status and coverage period explicit inputs. Use the official threshold/tier values for the selected year; do not hard-code old thresholds from undated summaries. Treat MLS as a separate levy component.

#### Deductions, reportable amounts and adjusted taxable income

Taxable income is not the same as adjusted taxable income (ATI) used for family assistance. Services Australia describes ATI as potentially including taxable income, foreign income and tax-exempt foreign income, total net investment losses, reportable fringe benefits, reportable superannuation contributions, certain tax-free pensions/benefits, and other specified items. Child support paid is deducted for family-assistance ATI purposes. Employer compulsory super contributions are not the same as reportable personal super contributions; do not automatically add all employer super to ATI.

Source: [Services Australia — What adjusted taxable income is](https://www.servicesaustralia.gov.au/what-adjusted-taxable-income?context=22151).

**Model treatment:** maintain separate variables/functions for taxable income and the ATI definition applicable to each payment. In particular, a salary increase may affect FTB and CCS through ATI, not simply through taxable income. Record reportable fringe benefits, reportable super contributions, investment losses, foreign income and child support paid as separate inputs where needed; simplify only with a documented limitation.

### Priority 2 — family payments

#### Family Tax Benefit Part A (FTB-A)

FTB-A is assessed per eligible child. The rate depends on child age and number, family ATI, care percentage and eligibility requirements. Services Australia's current rate page lists maximum fortnightly rates of $235.48 for a child aged 0–12 and $306.46 for a child aged 13–15 or an eligible secondary student aged 16–19; the listed base rate is $75.60 per child per fortnight. The 2026–27 annual supplement is listed as up to $970.90 per eligible child, subject to eligibility and balancing.

The income test has two stages. The current Services Australia page says maximum-rate eligibility applies at family ATI of $69,131 or less; between $69,131 and $123,078, the rate reduces by 20 cents per dollar above the lower threshold until the base rate is reached. A second test reduces FTB-A by 30 cents per dollar above $123,078 until nil, subject to family-size/child-age limits and other provisions. These published figures should be checked again against the current page and applicable legislation before implementing 2026–27 parameters.

Sources: [Services Australia — FTB-A payment rates](https://www.servicesaustralia.gov.au/family-tax-benefit-part-payment-rates?context=22151); [Services Australia — FTB-A income test](https://www.servicesaustralia.gov.au/income-test-for-family-tax-benefit-part?context=22151).

**Other material conditions/interactions:** child eligibility and age/study requirements, percentage of care, maintenance action test in relevant cases, maintenance income test, immunisation and Healthy Start for School requirements, and possible inclusion of Rent Assistance with FTB-A. A simplified first version should state exactly which of these are implemented and which are assumed satisfied.

#### Family Tax Benefit Part B (FTB-B)

FTB-B is a family-level payment for eligible single-parent/carer families and some partnered families. The youngest child's age and the income of both adults matter. For partnered families, the primary earner must be below the applicable threshold; the secondary earner has an income-free area, after which the payment tapers. Single-parent families use a different income test. Services Australia's current page lists the primary-earner/single-parent threshold as $124,327, a secondary-earner free area of $7,154, and a reduction of 20 cents per dollar above that amount. The listed maximum fortnightly rate is $200.34 when the youngest child is aged 0–4 and $139.86 when aged 5–18, subject to eligibility. The page also notes that FTB-B is not payable on days Parental Leave Pay is paid.

Sources: [Services Australia — FTB-B income test](https://www.servicesaustralia.gov.au/income-test-for-family-tax-benefit-part-b?context=22151); [Services Australia — FTB-B payment rates](https://www.servicesaustralia.gov.au/family-tax-benefit-part-b-payment-rates?context=22151).

**Model treatment:** retain each adult's ATI and identify the primary and secondary earner. Do not approximate FTB-B using combined family income alone. Include youngest-child age and Parental Leave Pay overlap if those cases are supported; otherwise mark them out of scope.

#### Shared income basis and annual reconciliation

Family assistance generally uses a family income estimate for the financial year, including income already earned and income expected for the remainder of the year. Payment rates may be balanced after year-end against actual income. A model of final annual entitlement and a model of fortnightly cash received during the year are different outputs.

Source: [Services Australia — Family income estimate for family assistance](https://www.servicesaustralia.gov.au/your-family-income-estimate-for-family-assistance-payments?context=22151).

**Model treatment:** initial METR outputs should clearly state whether they represent estimated annual entitlement after reconciliation or cash payments during the year. Annualised scenario comparisons are the cleaner first implementation; fortnightly payment timing and reconciliation can be added separately.

### Priority 3 — housing and childcare support

#### Commonwealth Rent Assistance (CRA)

CRA is generally an additional, non-taxable payment for eligible people receiving a qualifying payment and paying eligible rent above a minimum threshold. The rate rises by 75 cents for each additional dollar of eligible rent above the relevant threshold, up to a maximum. Rates and thresholds depend on household/payment category, rent, and whether the person is a single sharer, a couple, or a family with children. Eligible families commonly receive CRA with FTB-A; it should not be modelled as a universal rent subsidy available to every renter.

Source: [Services Australia — How much Rent Assistance you can get](https://www.servicesaustralia.gov.au/how-much-rent-assistance-you-can-get?context=22206); [Services Australia — Rent Assistance overview and eligibility](https://www.servicesaustralia.gov.au/rent-assistance).

**Model inputs/treatment:** eligible payment or FTB-A status, relationship and family composition, eligible rent/accommodation type, rent frequency and amount, and current rate table. Calculate CRA as its own transfer component and recompute it when income changes affect the qualifying payment or when rent/household composition changes. Rates are indexed twice yearly (20 March and 20 September), so version them by effective date, not only by financial year.

#### Child Care Subsidy (CCS): income test and fee cap

CCS is paid to the approved provider to reduce eligible fees; it is not normally cash paid directly to the family. The subsidy percentage applies to the lower of the actual hourly fee and the government hourly rate cap, and the family pays the remainder plus any fees above the cap and other non-subsidised costs. The rate depends on family ATI and may be higher for eligible families with more than one child aged five or younger. Services Australia's current page lists a standard rate of 90% at family income up to $88,520, reducing by 1 percentage point for every $5,000 of income above that threshold, reaching 0% at $538,520. These thresholds and formulas should be checked against the effective-year rules before coding.

Sources: [Services Australia — How income affects CCS](https://www.servicesaustralia.gov.au/your-income-can-affect-child-care-subsidy?context=41186); [Services Australia — How much CCS you can get](https://www.servicesaustralia.gov.au/how-much-child-care-subsidy-you-can-get?context=41186); [Services Australia — CCS hourly rate caps by care type and child age](https://www.servicesaustralia.gov.au/type-child-care-you-use-can-affect-child-care-subsidy?context=41186).

**Model inputs/treatment:** family ATI, each child's age, approved care type, fee per session and session hours, hours of care, and relevant multiple-child rate. Use a separate childcare-cost component: gross eligible fees, CCS subsidy, and out-of-pocket fees. Do not count CCS as unrestricted cash income as well as subtracting the reduced childcare fee, which would double-count the subsidy.

#### CCS subsidised hours / participation rules

From 5 January 2026, the former CCS activity test was replaced. Services Australia says eligible families can receive at least 72 hours of subsidised care per fortnight; 100 hours are available where each partner (if applicable) does more than 48 hours of recognised participation per fortnight, or where a valid exemption applies. Its page describes the detailed hour bands, including special treatment for very low activity and a family-income condition. These are eligibility/hour rules separate from the CCS percentage income test.

Source: [Services Australia — Recognised participation and subsidised hours for CCS](https://www.servicesaustralia.gov.au/recognised-participation-and-activity-test-for-child-care-subsidy?context=41186).

**Model treatment:** represent subsidised hours as a distinct eligibility calculation from the subsidy percentage. If activity/participation is simplified in the first version, explicitly state the assumption (for example, that the household receives enough subsidised hours to cover its entered care hours) rather than silently assuming all care is subsidised.

### Cross-component interactions to preserve

- **Employment income increase:** recalculate individual income tax, LITO, Medicare levy and MLS where relevant; recalculate each adult's ATI; then recalculate FTB-A, FTB-B, CCS and any income-tested qualifying payment. Recompute out-of-pocket childcare cost and any CRA whose qualifying payment or FTB-A entitlement changes.
- **Another child:** recalculate FTB-A child rates and family-size limits, FTB-B eligibility/youngest-child age, CCS child-specific rates and fees, CRA family category and thresholds, and relevant Medicare family thresholds. Do not encode a single “child effect”.
- **Superannuation and salary packaging:** separate employer super contributions from cash wages. Assess reportable fringe benefits and reportable personal super contributions according to the relevant ATI definition; do not assume ordinary compulsory employer super is automatically ATI.
- **Annual versus fortnightly amounts:** tax is generally assessed over an income year, while many transfer rates and income tests use fortnightly amounts or annual ATI estimates. Preserve the official assessment period and make conversions explicit; do not apply an annual threshold directly to fortnightly income without a justified conversion.
- **Component ledger:** retain gross wage change, income tax, LITO, Medicare levy, MLS, each family payment, CRA, gross childcare fees, CCS, out-of-pocket childcare costs and superannuation as separate rows. Aggregate only into a named resource measure.

## Research status and cautions

The rule summaries above have been researched against official sources, but they have **not** been independently validated against worked examples or a complete legal reading of every eligibility provision. In particular:
- current live agency pages are not always a year-specific archived snapshot;
- exact annual parameters, indexation dates and rounding rules must be frozen in configuration and reviewed before implementation;
- family payments, CCS and CRA have eligibility conditions beyond income and the headline taper rules;
- tax offsets and levies require explicit sequencing and eligibility assumptions;
- no calculation code or validated tax/benefit calculator has been created by this documentation update.

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
