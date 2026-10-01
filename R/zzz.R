falo_env <- new.env(parent = emptyenv())

# On load, make sure the fonts are downloaded and registered. Registrations only
# last for the R session, so this runs every time falo is loaded. The outcome is
# reported on attach, because R discourages messages from .onLoad().
.onLoad <- function(libname, pkgname) {
  had_fonts <- all(file.exists(font_paths()))
  falo_env$font_status <- tryCatch(
    {
      falo_install_fonts()
      if (had_fonts) "ok" else "downloaded"
    },
    error = function(e) conditionMessage(e)
  )
}

.onAttach <- function(libname, pkgname) {
  status <- falo_env$font_status
  if (identical(status, "downloaded")) {
    packageStartupMessage("falo: downloaded Public Sans to ", font_dir())
  } else if (!identical(status, "ok")) {
    packageStartupMessage("falo: Public Sans is not available, plots use the default font.\n", status)
  }
}
