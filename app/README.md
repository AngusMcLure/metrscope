# Shiny application

The Shiny interface will live here, separate from the reusable calculation engine in the repository's root `R/` directory.

Keep this layer focused on input handling, validation, reactive coordination, and presentation. App-specific modules and helpers can live in `app/R/`; reusable calculations must remain in root `R/` and must not depend on Shiny.

The app has not been implemented yet. The deployment approach should be documented once a hosting target is chosen.
