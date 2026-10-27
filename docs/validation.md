# Validation notes: initial individual tax calculation

## Scope

The first executable calculation covers the 2026-27 Australian resident individual income tax brackets, Low Income Tax Offset (LITO), and standard individual Medicare levy phase-in.

It is deliberately not a full tax-return calculator. It assumes ordinary resident taxable income and does not currently calculate deductions, other offsets, Medicare levy surcharge (MLS), family Medicare levy thresholds, SAPTO-related thresholds, levy exemptions, HELP repayments, income-tested benefits, tax withholding, or tax rounding. Users and downstream code must not treat unsupported cases as fully assessed.

## Formula summary

Basic income tax before offsets is:
- $0 up to $18,200;
- 15% of taxable income above $18,200 up to $45,000;
- $4,020 plus 30% above $45,000 up to $135,000;
- $31,020 plus 37% above $135,000 up to $190,000;
- $51,370 plus 45% above $190,000.

LITO is $700 up to $37,500, reduces by 5 cents per dollar between $37,500 and $45,000, then by 1.5 cents per dollar between $45,000 and $66,667, and is zero thereafter. The offset is applied after basic income tax and cannot reduce income tax below zero.

For the standard individual Medicare levy case only, the function uses the $28,011 low-income threshold, a phase-in of 10% of taxable income above that threshold, capped at the standard 2% levy. This does not implement family thresholds or exemptions.

## Worked examples

Amounts below are unrounded model calculations and should be checked against the applicable ATO assessment rules before being treated as return-ready values.

| Taxable income | Income tax before LITO | LITO | Income tax after LITO | Medicare levy | Total modelled tax and levy |
|---:|---:|---:|---:|---:|---:|
| $18,200 | $0.00 | $700.00 | $0.00 | $0.00 | $0.00 |
| $30,000 | $1,770.00 | $700.00 | $1,070.00 | $198.90 | $1,268.90 |
| $45,000 | $4,020.00 | $325.00 | $3,695.00 | $900.00 | $4,595.00 |
| $66,667 | $10,520.10 | $0.00 | $10,520.10 | $1,333.34 | $11,853.44 |
| $100,000 | $20,520.00 | $0.00 | $20,520.00 | $2,000.00 | $22,520.00 |

The $18,200 example illustrates that modelled tax is zero after LITO, but does not imply that every person with that income is entitled to every offset or exemption under every circumstance. The Medicare levy assumes the standard individual threshold, not a family threshold.

## Validation plan

The test suite checks bracket values and continuity, LITO phase-out points, Medicare levy phase-in behaviour, component reconciliation, and rejection of invalid inputs. The tests use testthat conventions. The repository does not yet have package metadata or an initialized test harness, and R/Rscript is not available in the current execution environment; therefore the tests could not be run here. They must be run when the R environment and package scaffold are available.

## Sources

- [Income Tax Rates Act 1986, Schedule 7, Part I, effective 1 July 2026](https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html)
- [Medicare Levy Act 1986, compilation effective 1 July 2026](https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html)
- [ATO — Tax offsets and rebates (LITO)](https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates)
- [ATO — Medicare levy surcharge thresholds and rates](https://www.ato.gov.au/individuals-and-families/medicare-and-private-health-insurance/medicare-levy-surcharge/income-thresholds-and-rates)
