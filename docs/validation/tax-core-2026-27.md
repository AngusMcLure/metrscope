# Validation specification: individual tax core, 2026–27

## Scope

This is the first calculation slice for metrscope: ordinary taxable income of an Australian resident individual, basic income tax, Low Income Tax Offset (LITO), and the standard individual Medicare levy. It deliberately excludes Medicare levy surcharge (MLS), family-threshold Medicare levy reductions, SAPTO-related provisions, exemptions, other tax offsets, HELP repayments, and all transfer payments.

The code returns unrounded mathematical amounts. It is an analytical model, not a substitute for an ATO assessment; tax-return rounding and other assessment rules must be specified before the results are presented as official liability estimates.

## Official sources and parameters

- [Income Tax Rates Act 1986 — compilation effective 1 July 2026, Schedule 7 Part I](https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html): resident marginal rates for 2026–27 are 0% to $18,200, 15% over $18,200 to $45,000, 30% over $45,000 to $135,000, 37% over $135,000 to $190,000, and 45% above $190,000.
- [ATO — Low income tax offset](https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates): maximum $700 to $37,500; taper of 5 cents per dollar from $37,500 to $45,000; then 1.5 cents per dollar from $45,000 to $66,667; nil thereafter. LITO is non-refundable and does not reduce the Medicare levy.
- [Medicare Levy Act 1986 — compilation effective 1 July 2026](https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html): standard individual low-income threshold $28,011 and phase-in limit $35,013; standard levy 2% above the phase-in limit. Between the threshold and phase-in limit, the levy is 10% of the excess over the threshold.

## Component calculations

Let (y) be taxable income.

Basic income tax before offsets is the piecewise sum of the resident marginal rates. In compact form:

| Taxable income band | Basic income tax |
|---|---|
| (y \leq 18{,}200) | (0) |
| (18{,}200 < y \leq 45{,}000) | (0.15(y-18{,}200)) |
| (45{,}000 < y \leq 135{,}000) | (4{,}020+0.30(y-45{,}000)) |
| (135{,}000 < y \leq 190{,}000) | (31{,}020+0.37(y-135{,}000)) |
| (y > 190{,}000) | (51{,}370+0.45(y-190{,}000)) |

LITO is calculated separately and applied only against basic income tax, with income tax after LITO floored at zero. The Medicare levy is then reported separately; unused LITO does not reduce it.

For the standard individual Medicare levy case:

- (y \leq 28{,}011): levy is zero.
- (28{,}011 < y < 35{,}013): levy is (0.10(y-28{,}011)).
- (y \geq 35{,}013): levy is (0.02y).

The implementation should keep these components separate so that later household and transfer rules can be added without hiding where the change comes from.

## Worked examples

Amounts below are unrounded model outputs, not tax-return assessments. They assume standard LITO eligibility and the standard individual Medicare levy case.

| Taxable income | Basic income tax | LITO | Income tax after LITO | Medicare levy | Total tax and levy |
|---:|---:|---:|---:|---:|---:|
| $26,000 | $1,170.00 | $700.00 | $470.00 | $0.00 | $470.00 |
| $30,000 | $1,770.00 | $700.00 | $1,070.00 | $198.90 | $1,268.90 |
| $60,000 | $8,520.00 | $100.00 | $8,420.00 | $1,200.00 | $9,620.00 |
| $100,000 | $20,520.00 | $0.00 | $20,520.00 | $2,000.00 | $22,520.00 |

## Boundary and validation cases

The test suite covers:
- values at and one dollar either side of each resident tax bracket boundary;
- LITO at $37,500, $45,000 and $66,667, including its non-refundable application;
- Medicare levy at $28,011 and around the $35,013 phase-in limit;
- component separation and arithmetic for worked examples;
- invalid, missing, non-finite, non-scalar and fractional taxable-income inputs.

At $35,012 the phase-in formula gives $700.10; at $35,013 the 2% formula gives $700.26. This small jump follows the statutory threshold/phase-in definitions and should be preserved rather than smoothed away.

## Not yet validated

- The test file has been authored but has not been run in R in this environment.
- These are formula-level unit tests, not independent validation against an official 2026–27 assessment.
- Final tax-return rounding, the full family Medicare levy calculation, MLS, SAPTO, exemptions and other offsets remain outside this slice.
- No METR or benefit interactions are implemented yet.
