# Dependency & Plot-Control Audit

Step 1 deliverable for `REFACTOR_PLAN.md`. Built by grepping every `@import`/`@importFrom` tag,
every `::` call site, and every representative function call across `R/*.R` — not from
`DESCRIPTION` alone. Anyone can regenerate this by re-running the greps in the "Method" section
at the bottom.

## Known blind spot in this audit's method (found during Step 4)

`R/SNPClusterPlotTree.R` calls `fviz_dend(SNPCluster, show_labels = T, cex = 0.1)` completely
bare — no `@import`/`@importFrom` tag of its own, no roxygen comments at all, not exported, and
never called by any other function in the package. It relied entirely on `factoextra` being
attached package-wide via a *different* file's `@import`/`@importFrom` tag (since `@import`
attaches at the whole package's `NAMESPACE`, any file can call an imported function unqualified
regardless of which file declared the tag). This is invisible to a grep for tags or `::` calls —
the only thing that reliably catches it is `R CMD check`'s "no visible global function
definition" / "Undefined global functions or variables" scan, which flags any bare symbol that
doesn't resolve once the dependency is actually removed. **Re-run a real `devtools::check()`
after each dependency removal, not just the targeted greps** — that's what caught this. Fixed by
routing it through the same `ggClusterDendrogram()` replacement as `SNPClusterPlot1DTree`.

## Corrections to the plan's prior assumptions

These came out of the grep pass and change what Steps 3–4 should do:

1. **`FactoMineR` is essential, not conditionally removable.** `SNPCluster.R` always calls
   `HCPC()` on the result of either `MCA()` or `PCA()` — `HCPC` (hierarchical clustering on
   principal/multiple-correspondence components, with automatic cluster-count selection) is the
   actual point of the function, not an optional extra. There is no realistic base-R substitute
   for `HCPC` specifically. **Revise Step 4: keep `FactoMineR` as `essential`, drop the
   "replace with `prcomp()`" option.**
2. **`scales` is used but declared nowhere** — `R/nucFrequencyPlot.R:20` calls `scales::percent`,
   and `scales` appears in neither `DESCRIPTION` nor any `@import`/`@importFrom` tag. This is a
   second real "missing from DESCRIPTION" bug beyond the five the plan already knew about
   (`ggplot2`, `grid`, `stringr`, `tibble`, `RColorBrewer`). **Add `scales` to the Step 5
   DESCRIPTION fix list.**
3. **CORRECTED — `tibble` is essential, not dead code.** An earlier pass of this audit grepped
   only for `tibble()`/`as_tibble()` and found nothing, but missed `add_row()` — also a `tibble`
   function. `SeqLocateCluster.R:62` calls `clusterAnnoTable %>% add_row(...)` inside
   `getClusterAnnotation()`. That call currently resolves via the `@import tidyverse` tag on the
   same function (tidyverse re-exports tibble's functions) — so removing `tidyverse` in Step 2
   would break it *unless* `tibble` stays imported at the package level. It does: `tibble` also
   has its own `@import tibble` tag in `nucFrequencyPlot.R`, and `@import` attaches at the whole
   package's `NAMESPACE`, not per file — so `add_row()` keeps working after `tidyverse` is
   removed. **Add `tibble` to `DESCRIPTION`'s `Imports:` in Step 5 alongside `ggplot2`/`grid`/
   `stringr`/`RColorBrewer`/`scales` — do not drop it.**
4. **Removing `tidyverse` is confirmed safe for the `%>%` pipe specifically.** `%>%` is used in
   6 files (`alignment2Fasta.R`, `nucFrequencyPlot.R`, `plotPCA.R`, `plotTreeWithGenes.R`,
   `SeqLocateCluster.R`). R attaches `@import`ed packages at the package namespace level (not
   per-file), and `dplyr` — which re-exports `%>%` from `magrittr` and is already an independent
   `Imports` entry — stays regardless of the `tidyverse` removal. So dropping `tidyverse` will not
   break any `%>%` call site, confirmed by keeping `dplyr` in Step 2.
5. **`BiocManager` has zero call sites in `R/`** — confirmed by grep, it only exists to let
   `remotes::install_github()` fetch `ggtree` from Bioconductor at install time. This fully
   supports Step 3's plan to delete it once `ggtree` is gone; no code references need updating.

## Package usage table

| Package | Classification | Files (call sites) | Functions actually called | Notes |
|---|---|---|---|---|
| `tidyverse` | redundant | `SeqLocateCluster.R` (`@import` only, L43) | none directly — meta-package | Every sub-package it could supply (`dplyr`, `tidyr`, `tibble`, `forcats`, `stringr`, `ggplot2`) is already an independent import. Drop in Step 2. |
| `plyr` | removable-with-inline-code | `seqRemoveAmbiguous.R` | `mapvalues()` — 1 call site | Single lookup-table call; base R `setNames()`/vector-index replacement. Drop in Step 2. |
| `reshape2` | removable-with-inline-code | `nucTableHeatmap.R` | `melt()` — 1 call site | Replace with `tidyr::pivot_longer` (already imported elsewhere). Drop in Step 2. |
| `pals` | removable-with-inline-code | `getSeqColors.R` (L15, L18, L21) | `kelly()`, `alphabet()`, `polychrome()` — 3 call sites | Fixed palettes, not generated — can be hardcoded as literal color vectors. `RColorBrewer::brewer.pal` fallback in the same file stays. Drop in Step 2. |
| `ggtree` | **RESOLVED (Step 3)** — was installation-blocking | was `plotTreeWithGenes.R` (L94), `SeqLocateCluster.R` (L105 tag, L124 call) | was `ggtree()`, `geom_tiplab()`, `hexpand()`, and a dead-code `theme_tree2()` call in each (already fully overridden by a later `theme_minimal()`, confirmed no visual effect) | Replaced with `R/ggPhyloTree.R`, an internal ggplot2+ape-only tree layout helper. Turned out to also be actively broken against current CRAN `ggplot2` 4.0.3 in this environment (calls `ggplot2:::check_linewidth`, an internal helper removed in ggplot2 4.x) — not just hard to install, potentially unloadable on a fully current R setup. Fully removed from `DESCRIPTION`/`NAMESPACE`. |
| `BiocManager` | **RESOLVED (Step 3)** — was installation-blocking | none in `R/` | none | Confirmed zero in-package usage; dropped alongside `ggtree` and the `remotes:` line. |
| `phytools` | **RESOLVED (Step 4)** — was removable-with-inline-code | was `plotSimilarityMatrixWithTree.R` (L10 tag, L38 call); `@import` also in `alignstatplot.R` (L13, unused directly) | was `phylo.heatmap()` — 1 call site | Replaced with `R/baseTreeHeatmap.R`: `ape::plot.phylo` + base `graphics::image()` side by side via `layout()`. Row alignment verified with a controlled test (row value = tip index) before integrating. |
| `factoextra` | **RESOLVED (Step 4)** — was removable-with-inline-code | was `plotPCA.R` (L6 tag, L18 call), `SNPClusterPlotPCAMap.R` (L5 tag, L8 call), `SNPClusterPlot1DTree.R`/`SNPClusterPlotTree.R` (2 more call sites — see blind-spot note above) | was `fviz_cluster()` — 3 call sites total, `fviz_dend()` — 2 call sites total | Replaced with hand-verified reimplementations: `fviz_cluster` coordinates via `scale()`+`stats::prcomp()` (numerically identical, verified against real factoextra), `fviz_cluster.HCPC` via direct `ggpubr::ggscatter()` call (ggpubr already required elsewhere), `fviz_dend` via new `R/ggClusterDendrogram.R`. |
| `FactoMineR` | **essential** (revised — see correction #1) | `SNPCluster.R` (L10 tag, L17/L22/L27), `SNPClusterPlot3DTree.R` (`@import`, L7; uses base `plot()` on the `HCPC` object) | `MCA()`, `PCA()`, `HCPC()` — all 3 always reachable, `HCPC` always called | Do not remove in Step 4 — keep as a required `Imports` entry. |
| `seqinr` | essential | `getSeqInfo.R`, `getDistanceMatrixTabel.R`, `plotAlignCircle.R`, `readSeq.R` | `read.fasta()` ×3, `getName()`, `getLength()`, `dist.alignment()` | Core FASTA I/O and alignment-distance computation; no reasonable substitute. Keep. |
| `circlize` | essential | `drawConsWithGenes.R`, `drawConsWithNoGenes.R`, `drawGenes.R` | `circos.*` family (init, genomicLink, axis, track, clear, etc.) | The circos-plot engine — the package's signature visualization. Keep. |
| `ape` | essential | `getTree.R` (L8 tag, L11 call), `plotTreeWithRuler.R` (L8 tag, L13 call), `seqAlign.R` (`@import`, function body not grepped here) | `nj()`, `plot.phylo()` | Already a CRAN dependency and the target replacement for `ggtree`/`phytools` in Steps 3–4 — keep and lean on more, not less. |
| `pheatmap` | essential | `distanceHeatmap.R` | `pheatmap()` — 1 call site | Only heatmap engine used; keep. |
| `gggenes` | essential | `plotTreeWithGenes.R`, `SeqLocateCluster.R` (×2 more call sites at L135/L177) | `geom_gene_arrow()`, `theme_genes()` | Specific gene-arrow geoms with no drop-in substitute; low transitive-dependency risk. Keep. |
| `ggseqlogo` | essential | `drawSeqLogo.R` (L13 tag, L40 call) | `ggseqlogo()` — 1 call site | Sequence-logo rendering; no reasonable inline substitute. Keep. |
| `cowplot` | essential | `plotTreeWithGenes.R` (L97), `SeqLocateCluster.R` (L153) | `plot_grid()` — 2 call sites | Simple layout combinator; low risk, keep (could be replaced with `patchwork` later to cut one package, not in scope now). |
| `patchwork` | essential | `drawSeqLogo.R` (L50–51) | `wrap_plots()`, `plot_layout()` | Used for the multi-plot seq-logo layout; keep. |
| `ggpubr` | essential | `nucTableFreqHeatmap.R` | `ggarrange()`, `rremove()` ×4, `annotate_figure()` | Drives the fixed 3-row layout flagged in the control-gap section below; keep the package, but the layout itself should become configurable in Step 5. |
| `forcats` | essential | `plotTreeWithGenes.R` (L76), `SeqLocateCluster.R` (L135, L177) | `fct_inorder()` — 3 call sites | Small, single-function usage but no zero-dependency inline substitute that's simpler than keeping it; keep. |
| `dplyr` | essential | `alignment2Fasta.R`, `nucFrequencyPlot.R`, `plotPCA.R` (`group_by`, `slice`), `plotTreeWithGenes.R`, `SeqLocateCluster.R` (×2) | `%>%` (6 files), `group_by()`, `slice()` | Also the source of `%>%` after `tidyverse` is dropped (see correction #4). Keep. |
| `tidyr` | essential | `nucTableFreqHeatmap.R` (`arrange()`, note: `arrange` is actually a `dplyr` function — verify attribution in Step 5 cleanup) | `arrange()` (attribution TBD) | Declared as target replacement for `reshape2::melt` in Step 2 (`pivot_longer`) — keep regardless. |
| `stringr` | essential | `AlignmentStats.R`, `alignmentNoGaps.R`, `alignmentNoGapsLinks.R`, `plotAlignCircle.R`, `SeqLocateCluster.R` | `str_locate_all()` ×2, `str_replace_all()`, `str_count()` ×2, `str_split_fixed()` | Missing from `DESCRIPTION` (bug) — add in Step 5. Otherwise keep, real usage throughout. |
| `ggplot2` | essential | Used pervasively (`nucFrequencyPlot.R`, `nucTableHeatmap.R`, `plotPCA.R`, `drawSeqLogo.R`, `plotTreeWithGenes.R`, `saveSeqPlotList.R`, `alignstatplot.R`, etc.) | `ggplot()`, `geom_*`, `theme()`, `scale_fill_manual()`, `ggsave()` (also via `::` in 3 files) | Missing from `DESCRIPTION` (bug) — add in Step 5. Foundation of nearly every plot function. |
| `grid` | essential | `nucTableFreqHeatmap.R`, `plotTreeWithGenes.R`, `SeqLocateCluster.R` (×3) | `unit()`, `gpar()`, `textGrob()` | Missing from `DESCRIPTION` (bug) — add in Step 5. |
| `tibble` | essential (corrected — see correction #3) | `nucFrequencyPlot.R` (`@import` tag, L9); actual call site is `SeqLocateCluster.R:62` (`add_row()`, reached today via the `tidyverse` tag on that function) | `add_row()` — 1 call site | Add to `DESCRIPTION` in Step 5. Also add an explicit `@importFrom tibble add_row` tag to `SeqLocateCluster.R` itself so the dependency is declared where it's actually used, not just incidentally available via another file's tag. |
| `RColorBrewer` | essential | `getSeqColors.R` (L6 tag, `brewer.pal` call), `plotSimilarityMatrixWithTree.R` (L9 tag, unused directly — only `colorRampPalette`, a base `grDevices` function, is called there) | `brewer.pal()` | Missing from `DESCRIPTION` (bug) — add in Step 5. Note `plotSimilarityMatrixWithTree.R`'s `@import RColorBrewer` tag looks vestigial (it only calls base `colorRampPalette`) — verify and possibly drop that one tag specifically. |
| `scales` | **essential, undeclared** (new finding — see correction #2) | `nucFrequencyPlot.R` (L20) | `percent()` — 1 call site | Not in `DESCRIPTION`, no `@import`/`@importFrom` tag at all. Add to `DESCRIPTION` + add an `@importFrom scales percent` tag in Step 5. |
| `stats` | essential | `plotPCA.R` (L7 tag) | `kmeans()` | Base R recommended package, always available — no install cost. Keep. |

## Plotting-function control-gap table

**RESOLVED (Step 5).** Every control gap identified below now has a corresponding parameter
(current hardcoded value kept as the default, verified default-preserving). See
`REFACTOR_PLAN.md`'s Step 5 section for the full list of added parameters per function and the
verification method. The two exceptions, both deliberate: `plotPCA`'s `labelsize`/`showlabels`
were already dead code before this refactor and fixing them would change default output (logged
in the plan, not fixed); `SNPClusterPlot3DTree`'s control surface is inherently limited to what
`FactoMineR`'s own `plot.HCPC` method exposes (noted below, not a gap introduced by this audit).

Every exported function whose name/purpose is "produce a plot" (18 functions), reviewed for
hardcoded colors, hardcoded font/theme/layout, and whether it returns a reusable object or only
has a side effect.

| Function | Hardcoded colors | Hardcoded font/theme/layout | Return behavior | Notes |
|---|---|---|---|---|
| `distanceHeatmap` | Uses `pheatmap` defaults, no palette arg | `fontsizescale` step-function (0.5→0.1 by matrix size) fully hardcoded, not overridable even though it's the only tunable | Returns `pheatmap()`'s object (also draws as a side effect) | Needs a `palette`/`colors` param; `fontsizescale` heuristic should become the *default*, not the only option. |
| `nucTableHeatmap` | `scale_fill_manual(values=c("red","blue","green","yellow","black"))` hardcoded, **duplicated verbatim** in `nucFrequencyPlot` | `theme()` axis text sizes parameterized (`cex.NucLabels`, `cex.SeqLabels`) — partially good | Returns `p` (ggplot object) — good | Extract the shared 5-color nucleotide palette into one constant/param used by both functions instead of duplicating the literal vector. |
| `nucFrequencyPlot` | Same hardcoded 5-color vector as above (duplicate literal) | `theme()` grid-line/axis toggles partially parameterized (`xlabel` arg) | Returns `p` — good | Same palette-dedup fix as `nucTableHeatmap`. |
| `nucTableFreqHeatmap` | No direct color use (delegates to the two above) | Fully hardcoded `ggarrange` layout: `ncol=1,nrow=3`, `heights=c(0.2,-0.05,0.8)`, `font.label` size/color/face, fixed title text via `textGrob` | Returns `p` — good | Layout should become parameters (heights, title text, label font) rather than fixed literals. |
| `nucTableFreqHeatmapSplit` | N/A (wraps the above) | N/A | Returns a list of plots — good, composable | No changes needed beyond whatever its wrapped function gains. |
| `plotAlignCircle` | Colors come from `getSeqColors()` internally, not passed through | Not fully reviewed for theme — base circlize side effect | Side-effect only (circlize draws to current device) | Circlize plots are inherently device-drawing, not ggplot-returnable; consider accepting a pre-computed color vector as an argument instead of always calling `getSeqColors()` internally. |
| `drawConsWithGenes` | Colors always derived internally via `getSeqColors(ColorsN)` — no override param | Only `cex.SeqLabels` exposed; sector width, alpha (`0.4` in `adjustcolor`), border color (`"white"`) all hardcoded | Side-effect only (circlize; ends on `circos.clear()`) | Add a `colors`/`palette` argument so `getSeqColors()` becomes the default, not the only option. |
| `drawConsWithNoGenes` | Hardcoded `"#CCCCCC"` background color plus internal `getSeqColors()` derivation | `cex.SeqLabels`, `cex.bpLabels` exposed (good) — but label facing/offset (`adj=c(1.05,0.5)`) hardcoded | Side-effect only (circlize) | Same palette-override fix as `drawConsWithGenes`; expose the grey background color too. |
| `drawGenes` | Colors passed in via caller (not reviewed as hardcoded here) | `labels.cex = 0.4 * par("cex")` hardcoded, not a parameter at all | Side-effect only (circlize) | Expose the `0.4` label-scale multiplier as an argument. |
| `drawSeqLogo` | `theme(plot.title = element_text(color = "red", size = 5))` — hardcoded red title color and fixed size 5, buried inside the function | Layout (`plot_layout(ncol=1, ...)`) and `ggsave()` dimensions parameterized via `width`/`height` args — partially good | Mixed: returns/saves via `saveSeqPlotList()` in one branch, may just print in another | Expose title color/size; clarify the return-vs-save branching so callers always get the object back regardless of `outFolder`. |
| `plotPCA` | **No hardcoded colors** — `aes(fill=cluster)` is data-driven | No hardcoded theme; comment literally says "you can now customize this by using ggplot syntax" | Returns the `ggplot` object directly — good | Already the best-behaved plotting function in the package; use it as the template/reference for retrofitting the others in Step 5. |
| `plotSimilarityMatrixWithTree` | `colorRampPalette(colors=c("blue","yellow","red"))(20)` hardcoded inline, not a parameter, despite being trivially easy to expose | Font size (`genfsize`) appears parameterized (name suggests so — verify) | Returns `figure` (`phylo.heatmap` object) — good | Lowest-effort win in the whole audit: just lift the existing local `colors` variable to a function argument with the current gradient as default. |
| `plotTreeWithGenes` | `geom_gene_arrow(fill="white")` hardcoded | Multiple `theme()` calls hardcoded, `rel_widths=c(1,2)` and `label_size=1` hardcoded in the final `plot_grid()` call; also has a dead bare `SeqTreePlot` expression before the real return (leftover debug line, harmless but should be removed for cleanliness) | Returns via `plot_grid()` — good | Expose gene-arrow fill, `rel_widths`, and `label_size`; delete the dead line while touching this function in Step 5. |
| `plotTreeWithRuler` | No color usage (base `plot.phylo`, black/white only) | `edge.width=1`, `label.offset=0`, `cex=0.5` all hardcoded directly in the call — **not even wired to the function's own arguments**, since the function signature takes only `(SeqInfo, myClustalWAlignment)` with no style params at all | Side-effect only (base graphics `plot.phylo` + `axis`) | Needs style parameters added from scratch — currently has none. |
| `SNPClusterPlot1DTree` | No color param | Accepts `ShowLabels`/`LabelsFontSize` arguments **but ignores them** — hardcodes `show_labels = T, cex = 0.1` in the `fviz_dend()` call regardless of what's passed in | Returns `fviz_dend()` object — good | **This is an existing bug, not just a control gap**: the documented parameters currently do nothing. Fix in Step 4 while replacing `factoextra` anyway. |
| `SNPClusterPlot3DTree` | No color param | `label=F` hardcoded; `angle` is the only exposed control | Side-effect only (base `plot()` method dispatch on the `HCPC`/`FactoMineR` object, not a capturable ggplot) | Base-graphics 3D plot from `FactoMineR`; limited control surface inherent to the underlying `plot.HCPC` method — note this constraint rather than over-promising full control here. |
| `SNPClusterPlotPCAMap` | No color param | `main = "SNP Cluster PCA Map"` hardcoded title; `geom = "point"` hardcoded | Returns `fviz_cluster()` object — good | Expose `title`/`geom` as parameters when `factoextra` is replaced in Step 4. |

### Not actually plotting functions (naming is misleading — reclassified during audit)

- `getSeqLogo` — despite the name, this computes the consensus-sequence list used by
  `drawSeqLogo`; it returns `ConsusSeqList` (a list of consensus sequences), not a plot. Treat as
  an **analysis** function in Step 6, not a plotting function in Step 5.

## Method (to regenerate this table)

```sh
grep -n "@import" R/*.R
grep -noE "[A-Za-z0-9_.]+::[A-Za-z0-9_.]+" R/*.R | sort
grep -n "HCPC\(" R/*.R                     # confirms FactoMineR::HCPC is always reached
grep -rn "scales" R/*.R DESCRIPTION         # confirms undeclared scales dependency
grep -rn "tibble(\|as_tibble(" R/*.R        # confirms tibble has zero call sites
grep -rn "BiocManager" R/*.R                # confirms zero in-package usage
```
For each plotting function, `grep -nE "#[0-9A-Fa-f]{6}|col ?=|color ?=|fill ?=|fontsize|cex ?=|theme\(|scale_(fill|color|colour)|brewer.pal|ggsave\(" R/<File>.R` plus a read of the function's final expression to determine return-vs-side-effect behavior.
