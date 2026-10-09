desc_data <- function() {
  data.frame(
    age    = c(20, 30, 40, NA),
    gender = factor(c("Female", "Male", "Female", "Male")),
    city   = c("A", "B", "B", NA),
    member = c(TRUE, FALSE, TRUE, TRUE),
    w      = c(1, 1, 2, 1)
  )
}

test_that("descriptive_table() returns a tinytable with the expected body", {
  tab <- descriptive_table(desc_data()[1:4])
  expect_s4_class(tab, "tinytable")
  body <- tab@data
  expect_equal(names(body), c(" ", "  ", "%", "Mean", "SD", "Min", "Max"))
  # age (1 row) + gender (2) + city (2) + member (1, "Yes" only)
  expect_equal(nrow(body), 6)
  expect_equal(body[[1]], c("age", "gender", "", "city", "", "member"))
  expect_equal(body[[2]], c("", "Female", "Male", "A", "B", "Yes"))
})

test_that("unweighted statistics drop missing values per variable", {
  body <- descriptive_table(desc_data()[1:4])@data
  expect_equal(body$Mean[1], "30.00")
  expect_equal(body$SD[1], format(round(sqrt(200 / 3), 2), nsmall = 2))
  expect_equal(body$Min[1], "20")
  expect_equal(body$Max[1], "40")
  expect_equal(body$`%`[4:5], c("33.3", "66.7"))  # city: 1 of 3 valid answers
  expect_equal(body$`%`[6], "75.0")
})

test_that("weights change means and percentages", {
  body <- descriptive_table(desc_data(), weights = "w")@data
  expect_false("w" %in% body[[1]])
  # age: (20 + 30 + 2 * 40) / 4 = 32.5
  expect_equal(body$Mean[1], "32.50")
  # gender: Female = (1 + 2) / 5
  expect_equal(body$`%`[2], "60.0")
  expect_equal(descriptive_table(desc_data()[1:4], weights = desc_data()$w)@data, body)
})

test_that("vars, labels, keep and notes work", {
  df <- desc_data()
  attr(df$age, "label") <- "Age in years"
  tab <- descriptive_table(df, vars = c("gender", "age"),
                           labels = c(gender = "Gender"),
                           keep = list(gender = "Female"))
  expect_equal(tab@data[[1]], c("Gender", "Age in years"))
  expect_match(unlist(tab@notes), "N = 4")
  expect_length(descriptive_table(df, notes = FALSE)@notes, 0)
  expect_match(unlist(descriptive_table(df, weights = "w")@notes), "weighted")
  expect_equal(unlist(descriptive_table(df, notes = "Custom")@notes), "Custom")
})

test_that("values that round to zero get one more decimal", {
  expect_equal(desc_num(c(1.234, -0.004, 0.0012, -0.0004, 0, NA), 2),
               c("1.23", "-0.004", "0.001", "0.000", "0.00", ""))
  body <- descriptive_table(data.frame(x = c(-1.004, 1)))@data
  expect_equal(body$Mean, "-0.002")
})

test_that("descriptive_table() gives clear errors", {
  df <- desc_data()
  expect_error(descriptive_table(1:3), "data frame")
  expect_error(descriptive_table(df, vars = "nope"), "nope")
  expect_error(descriptive_table(df, weights = "nope"), "nope")
  expect_error(descriptive_table(df, weights = c(-1, 1, 1, 1)), "negative")
  expect_error(descriptive_table(df, keep = list(gender = "Other")), "Other")
  df$when <- Sys.Date()
  expect_error(descriptive_table(df), "when")
})

test_that("descriptive_table() renders to HTML, LaTeX and Markdown", {
  tab <- descriptive_table(desc_data(), caption = "Overview")
  for (ext in c(".html", ".tex", ".md")) {
    f <- tempfile(fileext = ext)
    tinytable::save_tt(tab, f)
    expect_true(file.exists(f))
  }
})
