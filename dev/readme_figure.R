# Draws the example figure shown in README.md.
# Run from the package root: Rscript dev/readme_figure.R

devtools::load_all()
library(ggplot2)

theme_set(theme_allround())

cars <- transform(mpg, drive = factor(drv, levels = c("f", "r", "4"),
                                      labels = c("Front", "Rear", "4WD")))

p <- ggplot(cars, aes(displ, hwy, colour = drive, fill = drive)) +
  geom_point(alpha = 0.5, size = 2, position = position_jitter(0.05, 0.3, seed = 1)) +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 5), alpha = 0.2) +
  scale_colour_brewer(palette = "Dark2", aesthetics = c("colour", "fill")) +
  labs(
    title    = "Bigger engines, fewer miles",
    subtitle = "Highway fuel economy by engine size, with GAM smooths",
    x        = "Displacement (litres)",
    y        = "Highway miles per gallon",
    colour   = "Drive", fill = "Drive",
    caption  = "Data: ggplot2::mpg"
  )

ggsave("man/figures/README-theme_allround.png", p,
       width = 7, height = 5, dpi = 200, bg = "white")
