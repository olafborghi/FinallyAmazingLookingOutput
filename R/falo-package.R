#' @keywords internal
"_PACKAGE"

# ragg is imported so it is always installed: ggsave() uses it for PNG files
# when available, and Quarto/knitr chunks need dev = "ragg_png" to show
# registered fonts (see README).
#' @importFrom ragg agg_png
NULL
