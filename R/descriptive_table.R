#' Descriptive sample overview table
#'
#' Builds a publication-style descriptive table from a data frame that mixes
#' metric and categorical variables. Numeric columns get one row with the
#' mean, standard deviation, minimum and maximum; factor, character and
#' logical columns get one row per category with its percentage. The result
#' is a regular `tinytable` object, so you can keep styling it with
#' [tinytable::style_tt()] and export it with [tinytable::save_tt()].
#'
#' Missing values are dropped variable by variable, so percentages are shares
#' of the valid answers. With `weights`, means, standard deviations and
#' percentages are weighted; minimum and maximum are the observed range. The
#' weighted standard deviation is `sqrt(sum(w * (x - m)^2) / sum(w))`.
#'
#' @param data A data frame.
#' @param vars Character vector of the columns to describe, in the order they
#'   should appear. Defaults to all columns except `weights`.
#' @param weights Optional survey weights: the name of a column in `data` or a
#'   numeric vector with one value per row.
#' @param labels Optional named character vector of display labels, e.g.
#'   `c(age = "Age", migration = "Migration background")`. Columns without a
#'   label use their `"label"` attribute (as set by haven or labelled) or,
#'   failing that, the column name.
#' @param keep Optional named list giving the categories to show for a
#'   categorical variable, e.g. `list(gender = "Female", region = "East")`.
#'   Useful for binary variables where one row is enough. Logical columns show
#'   only `"Yes"` (the `TRUE` share) unless set here.
#' @param digits Decimal places for mean and SD. A value that would round to
#'   zero gets one extra decimal, e.g. `0.004` instead of `0.00`.
#' @param digits_pct Decimal places for percentages, with the same extra
#'   decimal for small non-zero shares.
#' @param caption Table caption, passed to [tinytable::tt()]. LaTeX and
#'   Quarto number captions themselves, so leave out "Table 2:" there.
#' @param notes Table note. `NULL` (the default) writes a note with N, the SD
#'   definition and whether the data are weighted. `FALSE` leaves the note
#'   out. Anything else is passed to the `notes` argument of
#'   [tinytable::tt()].
#' @param escape Escape characters that are special in LaTeX or HTML (such
#'   as the `%` header) so every output format renders. Set to `FALSE` if your
#'   labels contain LaTeX or HTML markup you want to keep.
#' @param ... Further arguments passed to [tinytable::tt()], such as `width`.
#'
#' @return A `tinytable` object.
#' @export
#' @examples
#' set.seed(1)
#' n <- 200
#' df <- data.frame(
#'   age       = round(runif(n, 16, 90)),
#'   attitude  = round(rnorm(n), 2),
#'   gender    = factor(sample(c("Female", "Male"), n, TRUE)),
#'   education = factor(sample(c("Low", "Intermediate", "High"), n, TRUE),
#'                      levels = c("Low", "Intermediate", "High")),
#'   w         = runif(n, 0.5, 1.5)
#' )
#'
#' tab <- descriptive_table(
#'   df,
#'   weights = "w",
#'   labels  = c(age = "Age", attitude = "Attitude index",
#'               gender = "Gender", education = "Education"),
#'   keep    = list(gender = "Female"),
#'   caption = "Table 1: Descriptive sample overview"
#' )
#' tab
#'
#' # Style and save it like any other tinytable
#' tinytable::save_tt(tab, tempfile(fileext = ".html"))
descriptive_table <- function(data,
                              vars = NULL,
                              weights = NULL,
                              labels = NULL,
                              keep = NULL,
                              digits = 2,
                              digits_pct = 1,
                              caption = NULL,
                              notes = NULL,
                              escape = TRUE,
                              ...) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  data <- as.data.frame(data)

  # Weights: column name or numeric vector
  weight_col <- NULL
  if (is.null(weights)) {
    w <- rep(1, nrow(data))
  } else if (is.character(weights) && length(weights) == 1) {
    if (!weights %in% names(data)) {
      stop("Weight column `", weights, "` is not in `data`.", call. = FALSE)
    }
    weight_col <- weights
    w <- data[[weights]]
  } else {
    w <- weights
  }
  if (!is.numeric(w) || length(w) != nrow(data)) {
    stop("`weights` must be a column name or a numeric vector with one value per row.",
         call. = FALSE)
  }
  if (any(w < 0, na.rm = TRUE)) {
    stop("`weights` must not be negative.", call. = FALSE)
  }

  if (is.null(vars)) vars <- setdiff(names(data), weight_col)
  missing_vars <- setdiff(vars, names(data))
  if (length(missing_vars) > 0) {
    stop("Not in `data`: ", paste(missing_vars, collapse = ", "), call. = FALSE)
  }
  if (length(vars) == 0) {
    stop("No variables to describe.", call. = FALSE)
  }

  rows <- lapply(vars, function(v) {
    x <- data[[v]]
    label <- desc_label(v, x, labels)
    if (is.logical(x)) {
      x <- factor(ifelse(x, "Yes", "No"), levels = c("Yes", "No"))
      if (is.null(keep[[v]])) keep[[v]] <- "Yes"
    }
    if (is.numeric(x)) {
      desc_metric_row(label, x, w, digits)
    } else if (is.factor(x) || is.character(x)) {
      desc_factor_rows(label, x, w, keep[[v]], digits_pct, v)
    } else {
      stop("Column `", v, "` is of class ", class(x)[1],
           "; use numeric, factor, character or logical columns.", call. = FALSE)
    }
  })
  body <- do.call(rbind, rows)
  # Blank but distinct headers for the two label columns
  colnames(body) <- c(" ", "  ", "%", "Mean", "SD", "Min", "Max")
  rownames(body) <- NULL

  if (is.null(notes)) {
    notes <- sprintf(
      "Note: SD refers to the standard deviation. N = %s%s.",
      format(nrow(data), big.mark = ","),
      if (is.null(weights)) "" else ", weighted data"
    )
  } else if (isFALSE(notes)) {
    notes <- NULL
  }

  tinytable::tt(body, caption = caption, notes = notes, theme = "empty",
                escape = escape, ...) |>
    tinytable::style_tt(j = 1:2, align = "l") |>
    tinytable::style_tt(j = 3:7, align = "r") |>
    # Rule under the header and under the last row, nothing else
    tinytable::style_tt(i = 0, line = "b", line_width = 0.08) |>
    tinytable::style_tt(i = nrow(body), line = "b", line_width = 0.08)
}

# Display label: `labels` argument, then "label" attribute, then column name
desc_label <- function(name, x, labels) {
  if (!is.null(labels) && !is.na(labels[name])) return(unname(labels[name]))
  lab <- attr(x, "label", exact = TRUE)
  if (is.character(lab) && length(lab) == 1) return(lab)
  name
}

# One row for a numeric variable: weighted mean and SD, observed min and max
desc_metric_row <- function(label, x, w, digits) {
  ok <- !is.na(x) & !is.na(w)
  x <- as.numeric(x[ok])
  w <- w[ok]
  if (length(x) == 0 || sum(w) == 0) {
    m <- s <- NA_real_
    mn <- mx <- ""
  } else {
    m <- sum(w * x) / sum(w)
    s <- sqrt(sum(w * (x - m)^2) / sum(w))
    mn <- format(min(x), trim = TRUE)
    mx <- format(max(x), trim = TRUE)
  }
  data.frame(var = label, cat = "", pct = "",
             mean = desc_num(m, digits), sd = desc_num(s, digits),
             min = mn, max = mx)
}

# One row per category: weighted percentage of valid answers
desc_factor_rows <- function(label, x, w, keep, digits_pct, name) {
  x <- as.factor(x)
  ok <- !is.na(x) & !is.na(w)
  p <- 100 * tapply(w[ok], x[ok], sum) / sum(w[ok])
  p[is.na(p)] <- 0
  if (!is.null(keep)) {
    unknown <- setdiff(keep, names(p))
    if (length(unknown) > 0) {
      stop("`keep` for `", name, "` names unknown categories: ",
           paste(unknown, collapse = ", "), call. = FALSE)
    }
    p <- p[keep]
  }
  data.frame(var = c(label, rep("", length(p) - 1)),
             cat = names(p), pct = desc_num(p, digits_pct),
             mean = "", sd = "", min = "", max = "")
}

# Fixed decimals; non-zero values that round to zero get one more decimal
# (0.004 -> "0.004"), and adding 0 turns "-0.000" into "0.000"
desc_num <- function(x, digits) {
  tiny <- !is.na(x) & x != 0 & round(x, digits) == 0
  d <- as.integer(ifelse(tiny, digits + 1, digits))
  out <- sprintf("%.*f", d, round(x, d) + 0)
  out[is.na(x)] <- ""
  out
}
