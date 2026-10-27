# Machine-readable 2026–27 policy schedules.
#
# Each piecewise schedule row applies on [lower_bound, upper_bound), and its
# value is value_at_lower + slope * (input - lower_bound). MLS is household-
# tiered rather than a single piecewise-linear function, so its thresholds
# and rates are stored separately below.

policy_schedules_2026_27 <- list(
  resident_income_tax = list(
    label = "Resident individual income tax before offsets",
    unit = "AUD annual liability",
    input = "taxable_income",
    financial_year = "2026-27",
    sources = c(
      "https://www.legislation.gov.au/C2004A03348/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html"
    ),
    schedule = data.frame(
      lower_bound = c(0, 18200, 45000, 135000, 190000),
      upper_bound = c(18200, 45000, 135000, 190000, Inf),
      value_at_lower = c(0, 0, 4020, 31020, 51370),
      slope = c(0, 0.15, 0.30, 0.37, 0.45)
    )
  ),
  lito = list(
    label = "Low Income Tax Offset entitlement",
    unit = "AUD annual offset",
    input = "taxable_income",
    financial_year = "2026-27",
    sources = c(
      "https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/tax-offsets-and-rebates"
    ),
    schedule = data.frame(
      lower_bound = c(0, 37500, 45000, 66667),
      upper_bound = c(37500, 45000, 66667, Inf),
      value_at_lower = c(700, 700, 325, 0),
      slope = c(0, -0.05, -0.015, 0)
    )
  ),
  medicare_levy_individual = list(
    label = "Standard individual Medicare levy",
    unit = "AUD annual levy",
    input = "taxable_income",
    financial_year = "2026-27",
    sources = c(
      "https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html"
    ),
    schedule = data.frame(
      lower_bound = c(0, 28011, 35013),
      upper_bound = c(28011, 35013, Inf),
      value_at_lower = c(0, 0, 700.26),
      slope = c(0, 0.10, 0.02)
    )
  ),
  medicare_levy_surcharge = list(
    label = "Medicare levy surcharge",
    financial_year = "2026-27",
    sources = c(
      "https://www.legislation.gov.au/C2004A03351/2026-07-01/2026-07-01/text/original/epub/OEBPS/document_1/document_1.html",
      "https://www.privatehealth.gov.au/health_insurance/surcharges_incentives/medicare_levy.htm"
    ),
    individual_income_threshold = 28011,
    single_thresholds = c(105000, 123000, 164000),
    family_thresholds = c(210000, 246000, 328000),
    extra_child_threshold = 1500,
    rates = c(0, 0.01, 0.0125, 0.015)
  )
)
