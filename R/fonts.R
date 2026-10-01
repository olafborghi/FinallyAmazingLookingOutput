# The Public Sans weights used by falo:
# - family: the name the weight is registered under (use it in element_text())
# - file:   the file name systemfonts::get_from_google_fonts() saves it as
# - weight: the CSS weight svglite writes for it in SVG files
public_sans <- data.frame(
  family = c("Public Sans Light", "Public Sans Regular", "Public Sans Semibold", "Public Sans Bold"),
  file   = c("Public Sans-300.ttf", "Public Sans-regular.ttf", "Public Sans-600.ttf", "Public Sans-700.ttf"),
  weight = c(300, 400, 600, 700)
)

# Folder for the font files: falo's own user data folder, which R places
# correctly on every OS. Override with options(falo.font_dir = "some/folder").
font_dir <- function() {
  getOption("falo.font_dir", tools::R_user_dir("falo", which = "data"))
}

font_paths <- function() {
  file.path(font_dir(), public_sans$file)
}

#' Install and register the falo fonts
#'
#' Downloads the static Public Sans font files from Google Fonts (only if they
#' are not downloaded yet) and registers each weight as its own font family:
#' `"Public Sans Light"`, `"Public Sans Regular"`, `"Public Sans Semibold"` and
#' `"Public Sans Bold"`. Use these names as `family` in ggplot2; `face = "bold"`
#' has no effect on them.
#'
#' This runs automatically when falo is loaded, so you only need to call it
#' yourself if the download failed (e.g. because you were offline).
#'
#' @param force Download the files again even if they exist.
#'
#' @return The paths to the font files, invisibly.
#' @export
#' @examples
#' \dontrun{
#' falo_install_fonts()
#' }
falo_install_fonts <- function(force = FALSE) {
  paths <- font_paths()
  if (force || !all(file.exists(paths))) {
    # A failed download is caught here and reported by the check below
    try(suppressWarnings(
      systemfonts::get_from_google_fonts("Public Sans", dir = font_dir())
    ), silent = TRUE)
  }
  if (!all(file.exists(paths))) {
    stop(
      "Could not download Public Sans from Google Fonts. ",
      "Check your internet connection and run `falo::falo_install_fonts()`.",
      call. = FALSE
    )
  }
  for (i in seq_along(paths)) {
    systemfonts::register_font(public_sans$family[i], plain = paths[i])
  }
  invisible(paths)
}

#' Fonts to embed in SVG files
#'
#' Returns the falo fonts as `@font-face` rules with the font data embedded, for
#' the `web_fonts` argument of [svglite::svglite()]. Pass it on through
#' [ggplot2::ggsave()] so the saved SVG shows the right fonts on any computer,
#' even without Public Sans installed.
#'
#' @return A list of [svglite::font_face()] specifications.
#' @export
#' @examples
#' \dontrun{
#' ggplot2::ggsave("figure.svg", width = 6, height = 5, web_fonts = falo_svg_fonts())
#' }
falo_svg_fonts <- function() {
  falo_install_fonts()
  # Each weight is looked up by its registered name (`local`), so svglite embeds
  # exactly the file used for drawing. Don't pass the file via `ttf` instead:
  # with embed = TRUE and no `local`, svglite also embeds the system's default
  # sans font in every rule.
  lapply(seq_len(nrow(public_sans)), function(i) {
    svglite::font_face(
      "Public Sans",
      local = public_sans$family[i],
      weight = public_sans$weight[i],
      embed = TRUE
    )
  })
}
