#' The allrounder theme
#'
#' A clean, minimal theme set in Public Sans: no grid lines, dark axis lines,
#' a bold title, light subtitle and caption, semibold axis titles and facet
#' labels, and a compact legend on top. Text and label geoms use Public Sans
#' Regular as well.
#'
#' @param base_size Base font size in points.
#'
#' @return A ggplot2 theme.
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   labs(title = "Heavier cars use more fuel", x = "Weight", y = "Miles per gallon") +
#'   theme_allround()
#'
#' # Draw with a systemfonts-aware device such as ragg (used by ggsave() for PNG)
#' ggsave(tempfile(fileext = ".png"), p, width = 6, height = 4)
#'
#' # Use the theme for all plots in a script
#' theme_set(theme_allround())
theme_allround <- function(base_size = 14) {
  # base_family also sets the font of text and label geoms (ggplot2 >= 4.0)
  theme_minimal(base_family = "Public Sans Regular", base_size = base_size) +
    theme(
      # No grid lines; dark axis lines instead
      panel.grid = element_blank(),
      axis.line  = element_line(colour = "grey25", linewidth = 0.8),
      # Bold title, light subtitle and caption
      plot.title    = element_text(family = "Public Sans Bold", size = rel(1.1), margin = margin(b = 10)),
      plot.subtitle = element_text(family = "Public Sans Light"),
      plot.caption  = element_text(family = "Public Sans Light"),
      # Semibold axis titles, slightly smaller axis text
      axis.title = element_text(family = "Public Sans Semibold", size = rel(0.9)),
      axis.text  = element_text(size = rel(0.9)),
      # Facet labels: semibold text in a grey box
      strip.text       = element_text(family = "Public Sans Semibold", size = rel(1)),
      strip.background = element_rect(fill = "grey95", colour = "grey25", linewidth = 0.8),
      # Compact legend on top, with its title to the left of the keys
      legend.position       = "top",
      legend.justification  = "center",
      legend.title.position = "left",
      legend.title  = element_text(family = "Public Sans Semibold", size = rel(0.8)),
      legend.text   = element_text(size = rel(0.8)),
      legend.margin = margin(0)
    )
}

#' @importFrom ggplot2 theme_minimal theme element_blank element_line
#'   element_text element_rect margin rel
NULL
