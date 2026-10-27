# Machine-readable 2026–27 policy schedules.
#
# Each schedule is piecewise linear. A row applies on
# [lower_bound, upper_bound), and its value is:
#   value_at_lower + slope * (income - lower_bound)
#
# Slope is the marginal change in the rule amount per additional dollar of
# the schedule's input. A positive slope increases a liability/benefit amount;
# a negative slope decreases it. The last interval has upper_bound = Inf.
#
# These values are policy parameters, not calculation logic. Keep the
# financial year and source references alongside the schedule definitions.

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
  )
)
