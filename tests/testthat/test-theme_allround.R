test_that("theme_allround() is a ggplot2 theme set in Public Sans", {
  th <- theme_allround()
  expect_s3_class(th, "theme")
  expect_equal(th$text$family, "Public Sans Regular")
  expect_equal(th$plot.title$family, "Public Sans Bold")
  expect_equal(th$text$size, 14)
})
