# FinallyAmazingLookingOutput

**falo**: custom themes for ggplot2 and more functions to create figures and tables.

falo sets plots in [Public Sans](https://fonts.google.com/specimen/Public+Sans). The font is downloaded once from Google Fonts and registered through systemfonts, so plots look the same on macOS, Windows and Linux, with or without Public Sans installed.

## Installation

```r
# install.packages("pak")
pak::pak("yourname/falo")
```

The first time FALO is loaded it downloads Public Sans. If that fails, run `falo_install_fonts()` later.

## Usage

```r
library(ggplot2)
library(falo)

theme_set(theme_allround())

ggplot(mpg, aes(displ, hwy, colour = drv)) +
  geom_point() +
  labs(title = "Bigger engines, fewer miles", x = "Displacement (l)", y = "Highway mpg")
```

Save an SVG with the fonts embedded, so it displays correctly on any computer:

```r
ggsave("figure.svg", width = 6, height = 5, web_fonts = falo_svg_fonts())
```

PNG files saved with `ggsave()` use ragg automatically and need nothing extra.

## Font names

Each weight of Public Sans is its own font family. Use these names in your own `element_text()` or `geom_text()` calls; `face = "bold"` has no effect on them.

| Family                   | Weight |
|--------------------------|--------|
| `"Public Sans Light"`    | 300    |
| `"Public Sans Regular"`  | 400    |
| `"Public Sans Semibold"` | 600    |
| `"Public Sans Bold"`     | 700    |

## Showing the fonts in Quarto and RStudio

The fonts only show on graphics devices that use systemfonts (ragg and svglite).

In Quarto documents, set ragg as the figure device in the YAML header:

```yaml
knitr:
  opts_chunk:
    dev: ragg_png
```

In RStudio, set *Tools → Global Options → General → Graphics → Backend* to **AGG** so the Plots pane uses the fonts.

The default PDF device does not know the fonts and fails with "invalid font type", so use `dev: ragg_png` for PDF output too, or save figures as SVG or PNG with `ggsave()`.
