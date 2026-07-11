#Shared color constants for the newer statistical plots, validated for categorical
#CVD-safety (fixed hue order, never cycled) and sequential magnitude encoding by the
#dataviz skill's palette validator. Kept as internal constants (not exported) so each
#new plotting function references one source of truth instead of hardcoding hex values.

#Sequential single-hue ramp (blue, light->dark) for magnitude/gradient fills.
.alignstatplotSequential<-c("#cde2fb", "#86b6ef", "#3987e5", "#1c5cab", "#0d366b")

#Fixed-order categorical palette (8 hues, CVD-safe adjacent ordering) for discrete
#series with a small number of categories (e.g. annotated region types).
.alignstatplotCategorical<-c(
  "#2a78d6", "#1baf7a", "#eda100", "#008300",
  "#4a3aa7", "#e34948", "#e87ba4", "#eb6834"
)
