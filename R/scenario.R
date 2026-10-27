# Minimal S3 adult and scenario objects.
#
# Adult objects contain taxable income and income-test adjustments used by
# the Medicare levy surcharge (MLS) and Family Tax Benefit Part A (FTB-A).
# Children are represented individually; the scenario derives the dependent-child
# count used by MLS from this list. Hospital-cover status is a household field.
# The constructors do not validate whether tax rules exist for the requested
# financial year; the calculation functions are responsible for that check.

.validate_financial_year <- function(financial_year, field = "financial_year") {
  valid <- is.character(financial_year) &&
    length(financial_year) == 1L &&
    !is.na(financial_year) &&
    nzchar(trimws(financial_year))

  if (!valid) {
    stop(sprintf("%s must be one non-empty character string.", field),
         call. = FALSE)
  }

  invisible(financial_year)
}

.validate_nonnegative_whole_amount <- function(amount, field) {
  valid <- is.numeric(amount) &&
    length(amount) == 1L &&
    !is.na(amount) &&
    is.finite(amount) &&
    amount >= 0 &&
    amount == floor(amount)

  if (!valid) {
    stop(
      sprintf("%s must be one finite, non-negative whole-dollar number.", field),
      call. = FALSE
    )
  }

  invisible(amount)
}

.validate_taxable_income <- function(taxable_income, field = "taxable_income") {
  .validate_nonnegative_whole_amount(taxable_income, field)
}

.validate_adult <- function(adult, field = "adult") {
  if (!inherits(adult, "adult") || !is.list(adult) ||
      is.null(adult$taxable_income)) {
    stop(
      sprintf("%s must be an adult object with a taxable_income field.", field),
      call. = FALSE
    )
  }
  .validate_taxable_income(adult$taxable_income,
                           paste0(field, "$taxable_income"))

  required_income_fields <- c(
    "reportable_fringe_benefits",
    "reportable_super_contributions",
    "net_investment_loss",
    "family_trust_distribution",
    "adjusted_fringe_benefits",
    "target_foreign_income",
    "tax_free_pension_benefit",
    "child_maintenance_expenditure"
  )
  if (!all(required_income_fields %in% names(adult))) {
    stop(
      sprintf("%s must include all required income fields.", field),
      call. = FALSE
    )
  }

  for (name in required_income_fields) {
    .validate_nonnegative_whole_amount(
      adult[[name]], paste0(field, "$", name)
    )
  }
  invisible(adult)
}

new_adult <- function(taxable_income,
                      reportable_fringe_benefits = 0,
                      reportable_super_contributions = 0,
                      net_investment_loss = 0,
                      family_trust_distribution = 0,
                      adjusted_fringe_benefits = 0,
                      target_foreign_income = 0,
                      tax_free_pension_benefit = 0,
                      child_maintenance_expenditure = 0) {
  fields <- list(
    taxable_income = taxable_income,
    reportable_fringe_benefits = reportable_fringe_benefits,
    reportable_super_contributions = reportable_super_contributions,
    net_investment_loss = net_investment_loss,
    family_trust_distribution = family_trust_distribution,
    adjusted_fringe_benefits = adjusted_fringe_benefits,
    target_foreign_income = target_foreign_income,
    tax_free_pension_benefit = tax_free_pension_benefit,
    child_maintenance_expenditure = child_maintenance_expenditure
  )
  for (name in names(fields)) {
    .validate_nonnegative_whole_amount(fields[[name]], name)
  }
  structure(fields, class = "adult")
}

.validate_adults <- function(adults) {
  if (!is.list(adults) || length(adults) < 1L || length(adults) > 2L) {
    stop("adults must be a list containing one or two adults.", call. = FALSE)
  }

  for (i in seq_along(adults)) {
    .validate_adult(adults[[i]], sprintf("adults[[%d]]", i))
  }

  invisible(adults)
}

.validate_dependent_children <- function(dependent_children) {
  valid <- is.numeric(dependent_children) &&
    length(dependent_children) == 1L &&
    !is.na(dependent_children) &&
    is.finite(dependent_children) &&
    dependent_children >= 0 &&
    dependent_children == floor(dependent_children)

  if (!valid) {
    stop("dependent_children must be one finite, non-negative whole number.",
         call. = FALSE)
  }
  invisible(dependent_children)
}

# Child facts are shared across policies; each policy applies its own rules.
.validate_children <- function(children) {
  if (!is.list(children)) {
    stop("children must be a list of child objects.", call. = FALSE)
  }
  for (i in seq_along(children)) {
    child <- children[[i]]
    field <- sprintf("children[[%d]]", i)
    required <- c("age", "full_time_student", "study_type",
                  "australian_resident", "maintained_by_family")
    if (!inherits(child, "child") || !is.list(child) ||
        !all(required %in% names(child))) {
      stop(sprintf("%s must be a child object with all required fields.", field),
           call. = FALSE)
    }
    if (!is.numeric(child$age) || length(child$age) != 1L ||
        is.na(child$age) || !is.finite(child$age) ||
        child$age < 0 || child$age > 24 || child$age != floor(child$age)) {
      stop(sprintf("%s$age must be a whole number from 0 to 24.", field),
           call. = FALSE)
    }
    if (!is.logical(child$full_time_student) ||
        length(child$full_time_student) != 1L ||
        is.na(child$full_time_student)) {
      stop(sprintf("%s$full_time_student must be TRUE or FALSE.", field),
           call. = FALSE)
    }
    if (!is.character(child$study_type) || length(child$study_type) != 1L ||
        is.na(child$study_type) ||
        !child$study_type %in% c("none", "secondary", "tertiary", "other")) {
      stop(sprintf(
        "%s$study_type must be one of 'none', 'secondary', 'tertiary', or 'other'.",
        field
      ), call. = FALSE)
    }
    if (child$full_time_student && child$study_type == "none") {
      stop(sprintf("%s$study_type cannot be 'none' for a full-time student.", field),
           call. = FALSE)
    }
    for (name in c("australian_resident", "maintained_by_family")) {
      value <- child[[name]]
      if (!is.logical(value) || length(value) != 1L || is.na(value)) {
        stop(sprintf("%s$%s must be TRUE or FALSE.", field, name), call. = FALSE)
      }
    }
  }
  invisible(children)
}

# MLS and FTB-A use different eligibility rules for the same child facts.
.is_mls_dependent_child <- function(child) {
  isTRUE(child$australian_resident) &&
    isTRUE(child$maintained_by_family) &&
    (child$age < 21 ||
       (child$age < 25 && isTRUE(child$full_time_student) &&
          child$study_type %in% c("secondary", "tertiary")))
}

.is_ftb_a_child <- function(child) {
  child$age < 16 ||
    (child$age <= 19 && isTRUE(child$full_time_student) &&
       identical(child$study_type, "secondary"))
}

new_child <- function(age, full_time_student = FALSE, study_type = "none",
                      australian_resident = TRUE,
                      maintained_by_family = TRUE) {
  child <- structure(
    list(
      age = age,
      full_time_student = full_time_student,
      study_type = study_type,
      australian_resident = australian_resident,
      maintained_by_family = maintained_by_family
    ),
    class = "child"
  )
  .validate_children(list(child))
  child
}

.validate_scenario <- function(scenario) {
  if (!inherits(scenario, "scenario") || !is.list(scenario) ||
      is.null(scenario$financial_year) || is.null(scenario$adults)) {
    stop("scenario must be a scenario object with financial_year and adults.",
         call. = FALSE)
  }

  .validate_financial_year(scenario$financial_year, "scenario$financial_year")
  .validate_adults(scenario$adults)
  if (is.null(scenario$dependent_children)) {
    stop("scenario$dependent_children must be supplied.", call. = FALSE)
  }
  .validate_dependent_children(scenario$dependent_children)
  if (is.null(scenario$children)) {
    stop("scenario$children must be supplied.", call. = FALSE)
  }
  .validate_children(scenario$children)
  expected_dependent_children <- sum(vapply(
    scenario$children, .is_mls_dependent_child, logical(1)
  ))
  if (scenario$dependent_children != expected_dependent_children) {
    stop("scenario$dependent_children must equal the number of MLS-dependent children.",
         call. = FALSE)
  }
  if (is.null(scenario$appropriate_hospital_cover) ||
      !is.logical(scenario$appropriate_hospital_cover) ||
      length(scenario$appropriate_hospital_cover) != 1L ||
      is.na(scenario$appropriate_hospital_cover)) {
    stop("scenario$appropriate_hospital_cover must be TRUE or FALSE.",
         call. = FALSE)
  }
  invisible(scenario)
}

new_scenario <- function(financial_year, adults,
                         appropriate_hospital_cover = FALSE,
                         children = list()) {
  .validate_financial_year(financial_year)
  .validate_adults(adults)
  .validate_children(children)
  dependent_children <- sum(vapply(
    children, .is_mls_dependent_child, logical(1)
  ))
  if (!is.logical(appropriate_hospital_cover) ||
      length(appropriate_hospital_cover) != 1L ||
      is.na(appropriate_hospital_cover)) {
    stop("appropriate_hospital_cover must be TRUE or FALSE.", call. = FALSE)
  }

  structure(
    list(
      financial_year = financial_year,
      adults = adults,
      dependent_children = dependent_children,
      appropriate_hospital_cover = appropriate_hospital_cover,
      children = children
    ),
    class = "scenario"
  )
}
