# Source register

Use one entry per official page, publication, dataset, or legislative source that supports a rule in the model. Keep the entry concise and update its review status when the source is checked.

## Entry template

### [Short source title]
- **Responsible agency / publisher:**
- **URL:**
- **Source type:** legislation / official guidance / data / other
- **Topic:** tax / benefit / payment / interaction
- **Applicable financial year or effective dates:**
- **Published or updated date:**
- **Date checked:**
- **Rules or calculations supported:**
- **Important eligibility assumptions or exceptions:**
- **Implementation status:** not assessed / assessed / implemented / validated
- **Validation evidence or notes:**

## Initial authoritative starting points

- Australian Taxation Office: https://www.ato.gov.au/
- Federal Register of Legislation: https://www.legislation.gov.au/
- Services Australia: https://www.servicesaustralia.gov.au/
- Department of Social Services: https://www.dss.gov.au/

These are starting points, not a complete or pre-validated source inventory. Select the specific source and applicable version for each rule before implementation.


## Sources reviewed for the initial 2026–27 rule inventory

**Review date:** 27 October 2026. These entries document source pages consulted for the policy summaries in [rule-inventory.md](rule-inventory.md). Live pages may change; record an effective-year snapshot and recheck rates and thresholds before implementation.

### Resident income tax rates
- **Responsible agency / publisher:** Federal Register of Legislation; administered by Treasury
- **URL:** https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
- **Source type:** legislation
- **Topic:** tax
- **Applicable financial year or effective dates:** Compilation effective 1 July 2026; includes 2026–27 resident marginal rates
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** Resident individual tax brackets and marginal rates under Schedule 7, Part I of the Income Tax Rates Act 1986
- **Important eligibility assumptions or exceptions:** Ordinary resident taxable income only; special treatment for foreign residents, working holiday makers, minors and special income components is not covered by the initial summary
- **Implementation status:** assessed
- **Validation evidence or notes:** Source read for policy summary; no code or worked examples validated.

### Medicare levy and surcharge
- **Responsible agency / publisher:** Federal Register of Legislation; administered by Treasury
- **URL:** https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
- **Source type:** legislation
- **Topic:** tax / levy
- **Applicable financial year or effective dates:** Compilation effective 1 July 2026
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** Medicare levy rate, low-income threshold and phase-in, family threshold provisions, and surcharge provisions
- **Important eligibility assumptions or exceptions:** SAPTO eligibility, family composition, dependants, exemptions, private hospital cover and income-for-surcharge purposes require explicit treatment
- **Implementation status:** assessed
- **Validation evidence or notes:** Current compilation inspected; threshold/tier handling needs tests and source-specific parameterisation.

### Low Income Tax Offset
- **Responsible agency / publisher:** Australian Taxation Office
- **URL:** https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates
- **Source type:** official guidance
- **Topic:** tax / offset
- **Applicable financial year or effective dates:** Current ATO guidance checked 27 October 2026; verify the applicable income-year parameters before implementation
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** LITO amount, income-based phase-out, non-refundable treatment; LMITO ended after 2021–22
- **Important eligibility assumptions or exceptions:** Taxable income and tax payable are required; other offsets may affect final liability
- **Implementation status:** assessed
- **Validation evidence or notes:** Guidance reviewed; parameter snapshot and boundary tests still required.

### Adjusted taxable income for family assistance
- **Responsible agency / publisher:** Services Australia
- **URL:** https://www.servicesaustralia.gov.au/what-adjusted-taxable-income?context=22151
- **Source type:** official guidance
- **Topic:** benefit / payment interaction
- **Applicable financial year or effective dates:** Live guidance; checked 27 October 2026
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** ATI components relevant to family assistance, including taxable income, foreign income, net investment losses, reportable fringe benefits, reportable super contributions and certain tax-free payments
- **Important eligibility assumptions or exceptions:** Components can differ by payment; child support paid is deducted for family-assistance ATI purposes. Do not reuse one ATI function for every payment without checking its definition.
- **Implementation status:** assessed
- **Validation evidence or notes:** Used to establish the need for separate taxable-income and ATI calculations.

### Family Tax Benefit Part A
- **Responsible agency / publisher:** Services Australia
- **URLs:** https://www.servicesaustralia.gov.au/family-tax-benefit-part-payment-rates?context=22151 ; https://www.servicesaustralia.gov.au/income-test-for-family-tax-benefit-part?context=22151
- **Source type:** official guidance
- **Topic:** benefit / family payment
- **Applicable financial year or effective dates:** Current rates page includes 2026–27 annual supplement; live income-test page checked 27 October 2026
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** Child-age-based maximum and base rates, annual supplement, ATI taper stages and eligibility considerations
- **Important eligibility assumptions or exceptions:** Child age/study, care percentage, maintenance tests, immunisation/schooling conditions and family-size limits can affect entitlement
- **Implementation status:** assessed
- **Validation evidence or notes:** Summary only; eligibility and parameter boundaries require further research and tests.

### Family Tax Benefit Part B
- **Responsible agency / publisher:** Services Australia
- **URLs:** https://www.servicesaustralia.gov.au/income-test-for-family-tax-benefit-part-b?context=22151 ; https://www.servicesaustralia.gov.au/family-tax-benefit-part-b-payment-rates?context=22151
- **Source type:** official guidance
- **Topic:** benefit / family payment
- **Applicable financial year or effective dates:** Live guidance checked 27 October 2026
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** Single-parent and partnered-family income tests, primary/secondary earner distinction, youngest-child age and maximum rates
- **Important eligibility assumptions or exceptions:** Grandparent carers, parental leave pay overlap and other special circumstances require separate handling
- **Implementation status:** assessed
- **Validation evidence or notes:** Summary only; parameters must be frozen for the selected year and tested.

### Family income estimate and reconciliation
- **Responsible agency / publisher:** Services Australia
- **URL:** https://www.servicesaustralia.gov.au/your-family-income-estimate-for-family-assistance-payments?context=22151
- **Source type:** official guidance
- **Topic:** benefit / payment interaction
- **Applicable financial year or effective dates:** Live guidance checked 27 October 2026
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** Income estimate for the financial year, including past income and expected income; annual balancing
- **Important eligibility assumptions or exceptions:** Estimated in-year cash payments differ from final annual entitlement after reconciliation
- **Implementation status:** assessed
- **Validation evidence or notes:** Use annual entitlement as initial comparison convention unless in-year payment timing is explicitly modelled.

### Child Care Subsidy
- **Responsible agency / publisher:** Services Australia
- **URLs:** https://www.servicesaustralia.gov.au/your-income-can-affect-child-care-subsidy?context=41186 ; https://www.servicesaustralia.gov.au/how-much-child-care-subsidy-you-can-get?context=41186 ; https://www.servicesaustralia.gov.au/type-child-care-you-use-can-affect-child-care-subsidy?context=41186 ; https://www.servicesaustralia.gov.au/recognised-participation-and-activity-test-for-child-care-subsidy?context=41186
- **Source type:** official guidance
- **Topic:** benefit / childcare subsidy
- **Applicable financial year or effective dates:** Live guidance checked 27 October 2026; participation/hours rules include changes from 5 January 2026
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** Income-based subsidy percentage, fee/hourly cap, child-age and care-type differences, and subsidised hours
- **Important eligibility assumptions or exceptions:** CCS percentage and subsidised hours are separate calculations; multiple-child rates and participation exemptions may apply
- **Implementation status:** assessed
- **Validation evidence or notes:** Need year-specific rates/caps and tests. Avoid double-counting subsidy as both income and a reduction in childcare costs.

### Commonwealth Rent Assistance
- **Responsible agency / publisher:** Services Australia
- **URLs:** https://www.servicesaustralia.gov.au/how-much-rent-assistance-you-can-get?context=22206 ; https://www.servicesaustralia.gov.au/rent-assistance
- **Source type:** official guidance
- **Topic:** benefit / housing support
- **Applicable financial year or effective dates:** Live guidance checked 27 October 2026; rates updated 20 March and 20 September
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** Eligibility as an additional payment with qualifying payments, rent thresholds, 75-cent taper and maximum rates by household category
- **Important eligibility assumptions or exceptions:** Not a universal payment for all renters; qualifying payment, accommodation/rent type, household composition and sharer status matter
- **Implementation status:** assessed
- **Validation evidence or notes:** Current live rates need to be snapshotted and checked against the applicable effective date before implementation.


## Sources used by the initial executable tax calculation

### 2026–27 resident individual tax, LITO and standard Medicare levy
- **Responsible agency / publisher:** Federal Register of Legislation; Australian Taxation Office
- **URLs:**
  - https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
  - https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html
  - https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates
- **Source type:** legislation and official guidance
- **Topic:** individual income tax / offset / levy
- **Applicable financial year or effective dates:** 2026–27; legislation compilations effective 1 July 2026
- **Date checked:** 2026-10-27
- **Rules or calculations supported:** resident tax brackets, LITO phase-out and standard individual Medicare levy low-income phase-in
- **Important eligibility assumptions or exceptions:** Ordinary resident taxable income; assumes the standard individual Medicare levy threshold and does not implement family thresholds, SAPTO, levy exemptions, Medicare levy surcharge, other offsets, HELP repayments or benefits
- **Implementation status:** implemented
- **Validation evidence or notes:** R functions and testthat tests added in R/tax_core.R and tests/testthat/test-tax-core.R. R/Rscript was unavailable in the implementation environment, so tests were not run. Worked examples and scope are documented in docs/validation/tax-core-2026-27.md; independent validation against ATO examples remains outstanding.
