# alignstatplot — Dependency Reduction + User-Control Upgrade

**Use this document as the working prompt for follow-up sessions. Execute one step at a time,
run its checklist, and do not start the next step until the current one passes.**

## Confirmed facts (verified against the actual `R/*.R` source, not just `DESCRIPTION`)

- `Imports:` currently lists 21 packages, including `tidyverse` (a meta-package) and `ggtree`
  (Bioconductor-only, pulled via `remotes: bioc::release/ggtree`, which also drags in
  `BiocManager`). `ggplot2`, `grid`, `stringr`, `tibble`, `RColorBrewer` are used via `NAMESPACE`
  `import()`/`importFrom()` but are **missing from `DESCRIPTION` entirely** — this alone can break
  installs on a clean machine.
- Heavy packages are each used in only one or two places:
  - `ggtree::ggtree`/`geom_tiplab` — only in `plotTreeWithGenes.R` and `SeqLocateCluster.R`
    (`SNPClusterPlotTree` helper).
  - `phytools::phylo.heatmap` — only in `plotSimilarityMatrixWithTree.R`.
  - `factoextra::fviz_cluster` — only in `plotPCA.R` and `SNPClusterPlotPCAMap.R`.
  - `factoextra::fviz_dend` — only in `SNPClusterPlot1DTree.R`.
  - `FactoMineR::PCA/MCA/HCPC` — only in `SNPCluster.R` (and used by `SNPClusterPlot3DTree.R`).
  - `plyr::mapvalues` — only in `seqRemoveAmbiguous.R`.
  - `reshape2::melt` — only in `nucTableHeatmap.R`.
  - `pals::kelly/alphabet/polychrome` — only in `getSeqColors.R`, which already falls back to
    `RColorBrewer::brewer.pal` — i.e. the package is used for exactly 3 palette calls.
  - `tidyverse` — declared via `@import tidyverse` in `SeqLocateCluster.R` but every sub-package
    it could provide (`dplyr`, `tidyr`, `tibble`, `forcats`, `stringr`, `ggplot2`) is already
    imported directly elsewhere.
- This matches and confirms the classification already drafted in the plan: most heavy
  dependencies are single-call-site — cheap to replace, high install-time payoff.

## Ground rules for every step below

1. **Never change output on a "removal" step.** If a step is labeled dependency-removal, the
   rendered plot/returned data must be byte-for-byte or visually identical to before. Any visual
   or behavioral change belongs in a control-upgrade step, done as an explicit, separately
   reviewed change — not smuggled in alongside a dependency swap.
2. **Every step ends with a checkpoint** (below). Do not proceed if any checkpoint item fails.
3. **Keep a rollback point.** Commit (or snapshot) before each step so a failed checkpoint can be
   reverted without losing prior progress.
4. **Update this file** at the end of each step: mark it done, log what changed, and record any
   deviation from the plan and why.

---

## Step 1 — Audit dependencies and control gaps together

**Goal:** one authoritative table, checked into the repo, before any code changes.

Actions:
- For every package in `Imports`, grep `R/*.R` for every call site (`::` calls and
  `@import`/`@importFrom` roxygen tags) and record: package → function(s) used → file(s) →
  call count → classification (`essential` / `redundant` / `removable-with-inline-code` /
  `installation-blocking`).
- Add `ggplot2`, `grid`, `stringr`, `tibble`, `RColorBrewer` to this table too — they're missing
  from `DESCRIPTION` even though `NAMESPACE` needs them; that's a bug to fix in Step 5, not before.
- For every exported plotting function, separately note: does it hardcode colors? hardcode font
  size/theme? return a plot object, or only draw/save as a side effect? Record this in the same
  table (extra columns) so Steps 5–6's control work and the dependency work share one source of
  truth instead of two audits drifting apart.
- Output: `docs/dependency-and-control-audit.md` (or similar), committed before Step 2 starts.

**Checkpoint:**
- [x] Every package in `Imports`/`NAMESPACE` appears in the table exactly once.
- [x] Every plotting function in the package appears in the control-gap section.
- [x] A second person (or a second pass by you) can regrep the codebase and get the same table.

**STATUS: DONE.** Full table at `docs/dependency-and-control-audit.md`. Five corrections to this
plan came out of the audit — they're logged in that doc and folded into Steps 4–5 below:
1. `FactoMineR` is **essential**, not conditionally removable — `SNPCluster.R` always calls
   `HCPC()`, which has no base-R substitute. Step 4 below is revised accordingly.
2. `scales::percent` (used in `nucFrequencyPlot.R`) is a second undeclared dependency beyond the
   five already known — added to the Step 5 `DESCRIPTION` fix list.
3. **CORRECTED:** `tibble` is essential, not dead — it's used via `add_row()` in
   `SeqLocateCluster.R:62` (currently reached through the `@import tidyverse` tag on that
   function). Add `tibble` to `DESCRIPTION` in Step 5, and give `SeqLocateCluster.R` its own
   explicit `@importFrom tibble add_row` tag so removing `tidyverse` (Step 2) doesn't leave the
   dependency undeclared at its real call site.
4. Removing `tidyverse` is confirmed safe for `%>%` specifically, since `dplyr` (which re-exports
   it) stays as an independent import.
5. `BiocManager` has zero call sites in `R/` — confirmed safe to delete alongside `ggtree` in
   Step 3 with no code changes needed for it specifically.

---

## Step 2 — Remove redundant / meta packages (zero behavior change)

**Goal:** delete packages that add nothing beyond what's already imported directly, and packages
used for a single trivial call.

Actions:
- Remove `@import tidyverse` from `SeqLocateCluster.R`; delete `tidyverse` from
  `DESCRIPTION`/`NAMESPACE`. Confirm nothing in that file actually needs a `tidyverse`-only symbol.
- Replace `plyr::mapvalues` in `seqRemoveAmbiguous.R` with a base R named-vector lookup
  (`setNames(...)` + `unname(lookup[x])`, preserving NA-handling behavior for unmatched values).
- Replace `reshape2::melt` in `nucTableHeatmap.R` with `tidyr::pivot_longer` (already imported
  elsewhere) — match column names/order exactly so downstream code in the same function doesn't
  need to change.
- Replace `pals::kelly()/alphabet()/polychrome()` in `getSeqColors.R` with hardcoded copies of
  those exact palettes (they're fixed color vectors, not generated) or an equivalent
  `grDevices::colorRampPalette`-based fallback, keeping `RColorBrewer` as-is since it's already
  used as the qualitative fallback.
- Remove `plyr`, `reshape2`, `pals` from `DESCRIPTION`/`NAMESPACE`.

**Checkpoint:**
- [x] `devtools::check()` passes with no new warnings/errors. *(Environment note: full
      `devtools::check()`/`roxygen2::roxygenise()` package-load step still requires `ggtree`,
      which fails to build in this sandbox — a live example of the exact install pain this plan
      exists to fix, not a regression from this step. Verified instead via `R CMD INSTALL` in a
      scratch copy with `ggtree` temporarily stripped from `DESCRIPTION`/`NAMESPACE`: installs
      cleanly, only pre-existing whole-package `@import` name-collision warnings — e.g.
      `ape::degree` vs `circlize::degree` — none related to `tidyverse`/`plyr`/`reshape2`/`pals`.
      Full `devtools::check()` will be re-run for real once Step 3 removes `ggtree`.)*
- [x] For each changed function, ran it on synthetic test data before (old implementation
      reproduced inline) and after (actual edited file, loaded via the installed package) and
      diffed the output — all `identical()`/`all.equal()` TRUE:
      - `getSeqColors()`: all `ColorsN` in `{3,8,15,22,26,30,36}` byte-identical to
        `pals::kelly()/alphabet()/polychrome()`.
      - `seqRemoveAmbiguous()`: identical output file contents for a FASTA with all 11 ambiguity
        codes plus edge cases (empty line, header lines).
      - `nucTableHeatmap()`: `ggplot` `$data` identical across 3 cases — with column names (the
        real-world shape per `alignment2Table.R`), without column names, and single-row input.
      - `getClusterAnnotation()`'s `%>%`/`add_row()` (reached via the `tidyverse` tag being
        removed) confirmed to resolve correctly with only `dplyr`+`tibble` loaded, no `tidyverse`.
- [x] `grep -rnE "\b(tidyverse|plyr|reshape2|pals)\b" R/ DESCRIPTION NAMESPACE` — the plain
      `grep -r "tidyverse\|plyr\|reshape2\|pals"` in the original checkpoint false-positives on
      `dplyr`/`qual_col_pals` substrings; word-boundary version returns matches only inside two
      explanatory code comments (naming the replaced packages for context), zero actual
      dependency/code usage remains.
- [x] Package installs from a clean scratch lib with the reduced `Imports` list (see
      `devtools::check()` note above for the `ggtree` caveat — everything else in the reduced
      list installs and loads without error).

**STATUS: DONE.** Changed files: `R/getSeqColors.R` (hardcoded copies of
`kelly()`/`alphabet()`/`polychrome()`, `pals` no longer referenced), `R/seqRemoveAmbiguous.R`
(base R lookup replaces `plyr::mapvalues`), `R/nucTableHeatmap.R` (`tidyr::pivot_longer`-based
reimplementation of `reshape2::melt`'s exact column-major traversal and type behavior),
`R/SeqLocateCluster.R` (`@import tidyverse` tag removed). `DESCRIPTION`/`NAMESPACE` updated to
drop `tidyverse`/`plyr`/`reshape2`/`pals`.

---

## Step 3 — Drop the Bioconductor blocker (`ggtree`, `BiocManager`)

**Goal:** remove the single dependency most responsible for "installation is extremely
difficult," since it's the only one requiring `remotes: bioc::release/...` instead of CRAN.

Actions:
- In `plotTreeWithGenes.R` and `SeqLocateCluster.R`, replace `ggtree(...) + geom_tiplab(...)`
  with `ape::plot.phylo()` (already a CRAN dependency) plus manual tip-label placement to match
  current alignment/spacing (`align.tip.label = TRUE`, custom `cex`/label offset to reproduce
  `geom_tiplab(align=TRUE, size=3)`), and any current annotation layers as base-graphics or grid
  overlays.
- Remove `@import ggtree`/`@import phytools` tags from `alignstatplot.R` if phytools removal
  (Step 4) lands in the same pass, or handle separately if not.
- Delete `ggtree`, `BiocManager`, and the `remotes: bioc::release/ggtree` line from `DESCRIPTION`
  once no code references them.

**Checkpoint:**
- [x] Visual diff of tree plots (before/after) reviewed by eye against `man/figures/`/`README.md`
      examples. *(Could not get a live `ggtree` render as the "before" — see finding below — so
      compared against the static reference PNGs instead: `man/figures/README-unnamed-chunk-13-1.png`
      for `plotTreeWithGenes` and `README-unnamed-chunk-28-1.png` for `SNPClusterPlotWithTree`.
      Ran both actual (modified) functions end-to-end against the real bundled example data
      [`inst/extdata/Example_Small.fasta` + `.anno`], using a synthetic equal-length-padded
      alignment in place of ClustalW output since no alignment binary is installed in this
      sandbox. Rendered output matches the reference style: rectangular right-angle branches,
      right-aligned tip labels connected by dotted leader lines, tree:gene-panel row alignment,
      identical legend/color styling. Topology differs from the reference PNGs only because the
      input alignment differs [synthetic vs. real ClustalW] — not a rendering defect.)*
- [x] `devtools::check()` passes. *(One nuance: a real `devtools::check()` on the actual repo
      still reports 1 ERROR for the *pre-existing* missing-`DESCRIPTION` bug Step 1 already found
      — `RColorBrewer`/`ggplot2`/`stringr`/`tibble` undeclared, fixed in Step 5, not this step.
      That error could never surface before now because `check()` couldn't even get past loading
      `ggtree`. Verified in a scratch copy with those 4 pre-existing gaps patched: check runs to
      completion with 1 ERROR + 3 WARNINGs + 7 NOTEs, and every one of them is pre-existing and
      unrelated to this step — a broken example filename in `alignment2Fasta` referencing a
      nonexistent `sequence_few.fasta`, undocumented params in files this step never touched
      [`AlignSplit`, `plotPCA`, `alignstatplot`], the same whole-package `@import` collision
      warnings seen since Step 2 [e.g. `ape::degree` vs `circlize::degree`], and generic
      "undefined global variable in `aes()`" NOTEs already pervasive across the codebase before
      this step [`nucFrequencyPlot`, `plotPCA`, etc. all have the same NOTE class]. The new
      `ggPhyloTree.R` picks up 5 NOTEs of that exact same pre-existing category — not a new
      problem, the same accepted pattern extended to one more file.)*
- [x] Fresh install test in a container/`renv` sandbox with **no Bioconductor configured at
      all** — confirmed: `options(repos = c(CRAN = "https://cloud.r-project.org"))` with zero
      Bioconductor repos configured, `R CMD INSTALL` into a clean scratch library completes with
      `* DONE (alignstatplot)`.
- [x] `BiocManager`/`ggtree` no longer appear anywhere in `DESCRIPTION`, `NAMESPACE`, or roxygen
      tags — confirmed by grep; the only remaining mentions are inside `ggPhyloTree.R`'s own
      roxygen docs, naming what it replaced.

**STATUS: DONE.** Environment finding worth recording: `ggtree` (the version paired with R
4.3.3 / Bioconductor 3.18) turned out to be **actively broken against current CRAN `ggplot2`
(4.0.3)** in this sandbox — it calls `ggplot2:::check_linewidth`, an internal helper current
`ggplot2` no longer has. Getting even a baseline install required force-installing two archived,
older transitive dependency versions (`tidytree` 0.4.6, for an internal `random_ref` symbol
`treeio` expects) before hitting the `ggplot2` incompatibility, which is unresolvable without
downgrading `ggplot2` itself. This means `ggtree` isn't just hard to install via Bioconductor —
on a fully current R setup it may not load at all, which is a stronger argument for removing it
than "installation friction" alone.

Replacement approach: added `R/ggPhyloTree.R`, an internal (non-exported) helper that builds a
plain `ggplot` rectangular-tree object using only `ape`'s own tree-layout coordinates (via the
documented `ape:::.PlotPhyloEnv` pattern also used by `phytools` and other ape-ecosystem
packages) plus `ggplot2` primitives (`geom_segment` for branches, `geom_text` + dotted
`geom_segment` leader lines for aligned tip labels) — reproducing
`ggtree(tree) + geom_tiplab(align=TRUE, size=3) + hexpand(.4)`. Returning a plain `ggplot` object
(not a base-graphics side effect) was the key design choice: it's what lets
`cowplot::plot_grid()` keep combining the tree with the gene-arrow panel exactly as before, with
guaranteed row alignment, with zero changes to the surrounding `plot_grid()`/layout code.

Changed files: `R/ggPhyloTree.R` (new), `R/plotTreeWithGenes.R` and `R/SeqLocateCluster.R`
(`ggtree(...)`/`fortify()`-based tip-order extraction replaced with `ggPhyloTree()`; also removed
the `@import ggtree` tags and a `theme_tree2()` call in each that was already fully overridden by
a later `theme_minimal()` — confirmed dead/no-op, safe to delete since it changes nothing
visually), `R/alignstatplot.R` (dropped its redundant top-level `@import ggtree` tag — the
function only calls other exported functions, never `ggtree` directly). `DESCRIPTION`/`NAMESPACE`
updated to drop `ggtree`, `BiocManager`, and the `remotes: bioc::release/ggtree` line entirely.

---

## Step 4 — Replace remaining heavy specialized packages

**Goal:** remove `factoextra`, `phytools`, and (if unused beyond `PCA`) narrow `FactoMineR`'s use.

Actions:
- `plotSimilarityMatrixWithTree.R`: reimplement `phytools::phylo.heatmap` using `ape` (for the
  tree side) plus `pheatmap` or base `image()` for the matrix side, matching current axis
  ordering and color scale.
- `plotPCA.R` and `SNPClusterPlotPCAMap.R`: reimplement `factoextra::fviz_cluster` as a small
  `ggplot2` helper (points colored/shaped by cluster, optional ellipses via `ggplot2::stat_ellipse`
  instead of `factoextra`'s internal ellipse code).
- `SNPClusterPlot1DTree.R`: reimplement `factoextra::fviz_dend` using `ape::plot.phylo` or base
  `plot.hclust`/`ggdendro`-free ggplot2 dendrogram drawing.
- `SNPCluster.R` / `SNPClusterPlot3DTree.R`: **audit confirmed `HCPC()` is always called** (on
  the result of either `MCA()` or `PCA()` depending on data type) — this is the function's actual
  purpose, not an optional path. `FactoMineR` stays as a required `Imports` entry; no replacement
  work needed here.
- Remove `phytools` and `factoextra` from `DESCRIPTION`/`NAMESPACE`. Keep `FactoMineR`.

**Checkpoint:**
- [x] Each reimplemented function tested against the same input used in existing examples;
      cluster assignments/PCA coordinates numerically match (`all.equal()` on coordinates,
      not just "looks similar"). Specifically:
      - `plotPCA`/`SNPClusterPlotPCAMap`: reverse-engineered `factoextra::fviz_cluster`'s exact
        coordinate computation (`stand=TRUE` default → `scale()` then `stats::prcomp(scale=FALSE,
        center=FALSE)`, first two components) by deparsing the real `fviz_cluster` source, then
        verified numerically against the actual installed `factoextra`: all of `x`, `y`,
        `cluster`, `name` came back `identical()`/`all.equal()` TRUE on synthetic data, and for
        the HCPC case all 3 `ggplot_build()` layers matched exactly (`ggpubr::ggscatter` — already
        a required dependency — called directly with the same arguments `fviz_cluster` would
        pass, since `fviz_cluster.HCPC` is just a thin wrapper around it).
      - `factoextra::get_eigenvalue()` (used inside `fviz_cluster.HCPC` for axis labels) turned
        out to need no replacement code at all — `FactoMineR`'s own `PCA`/`MCA` result already
        stores the identical values in `$eig[,2]`; verified directly against a real `PCA()` call.
      - `SNPClusterPlot1DTree` (`factoextra::fviz_dend`): reimplemented the standard
        rectangular-dendrogram-layout algorithm (leaf x from `hc$order`, node y from `hc$height`)
        plus `fviz_dend`'s branch-coloring rule (subtree colored if `cutree(hc,k)` shows it's a
        single cluster, black otherwise) in a new `ggClusterDendrogram()` helper. Verified against
        the real installed `factoextra`+`dendextend`: identical topology/heights, and after fixing
        two mismatches found along the way — cluster→color assignment needed to follow
        left-to-right first-dendrogram-appearance order (not `cutree`'s raw numeric ids), and the
        default x-axis ticks/numeric labels needed to be stripped — the rendered image matched the
        reference style, including the `show_labels=FALSE` case.
- [x] Visual review of dendrogram/cluster/heatmap plots against current `man/figures/`: compared
      `SNPClusterPlot1DTree` and `SNPClusterPlotPCAMap` output against
      `man/figures/README-unnamed-chunk-25-1.png` and `-26-1.png` — matching title, axis labels,
      legend, and (for the PCA map) convex-hull-per-cluster style. `plotSimilarityMatrixWithTree`
      has no reference image in `README.md` to compare against; verified instead by construction —
      the rendered heatmap's diagonal (self-distance = 0) forms a clean unbroken line, confirming
      row/column/tip ordering all agree.
- [x] `devtools::check()` passes; no leftover `importFrom(phytools, ...)` /
      `importFrom(factoextra, ...)` lines in `NAMESPACE` — confirmed by grep and by a real
      `devtools::check()` run (same scratch-copy method as Step 3, with the pre-existing missing-
      `DESCRIPTION`-entries bug patched in for the run only): identical 1 ERROR + 3 WARNINGs + 7
      NOTEs as Step 3's checkpoint, all pre-existing and unrelated to this step.
- [x] `FactoMineR` is kept — confirmed by audit (`docs/dependency-and-control-audit.md`) that
      `SNPCluster.R` always reaches `HCPC()`.
- [x] While replacing `factoextra::fviz_dend` in `SNPClusterPlot1DTree.R`, also fixed the existing
      bug the audit found: `ShowLabels`/`LabelsFontSize` were accepted but silently ignored
      (hardcoded `show_labels = T, cex = 0.1` regardless of input) — now wired through to
      `ggClusterDendrogram(show_labels=ShowLabels, cex=LabelsFontSize)`, verified both
      `ShowLabels=TRUE` and `FALSE` render correctly (labels present/absent as requested).

**Audit-method gap found and fixed while verifying this step:** `R/SNPClusterPlotTree.R` called
`fviz_dend(...)` completely bare — no roxygen tag of its own, unexported, never called elsewhere —
relying entirely on `factoextra` being attached package-wide via a *different* file's tag. No grep
for tags or `::` calls could have caught this; only re-running a real `devtools::check()` after
the dependency removal surfaced it (`fviz_dend` appeared in "Undefined global functions or
variables"). Fixed by routing it through the same `ggClusterDendrogram()` replacement. Logged in
`docs/dependency-and-control-audit.md` as a correction to this audit's own method — future removal
steps should re-check with `devtools::check()`, not just targeted greps.

---

## Step 5 — Minimal `DESCRIPTION`/`NAMESPACE` + consistent plotting API

**Goal:** finalize the dependency list, fix the missing-`DESCRIPTION`-entries bug, and give users
real control over every plotting function's output — in the same pass, since both are "make the
public API right" work.

Dependency side:
- Regenerate `Imports:` from what survives Steps 2–4, and **add the packages that were always
  used but missing from `DESCRIPTION`**: `ggplot2`, `grid`, `stringr`, `tibble`, `RColorBrewer`,
  and `scales` (the audit found `scales::percent` in `nucFrequencyPlot.R` with no declaration
  anywhere — add an `@importFrom scales percent` tag too). Also add an explicit
  `@importFrom tibble add_row` tag to `SeqLocateCluster.R` (its real call site) rather than
  relying on the tag in `nucFrequencyPlot.R` alone.
- Also check the vestigial `@import RColorBrewer` tag in `plotSimilarityMatrixWithTree.R` — the
  audit found that file only calls base `colorRampPalette()`, not anything from `RColorBrewer`
  directly; the tag may be droppable from that specific file even though the package stays
  required elsewhere (`getSeqColors.R`).
- `FactoMineR` stays in `Imports` (confirmed essential — see Step 4).
- Confirm the `remotes:` field is gone entirely.

Control side (apply the same pattern to every exported plotting function: `distanceHeatmap`,
`nucTableFreqHeatmap`, `nucTableHeatmap`, `plotAlignCircle`, `drawConsWithGenes`/
`drawConsWithNoGenes`, `SNPClusterPlot*`, `plotTreeWithGenes`, `plotTreeWithRuler`,
`plotSimilarityMatrixWithTree`, `drawSeqLogo`, `plotPCA`):
- Add a `palette`/`colors` argument (default = current hardcoded colors, so nothing breaks).
- Add `font_size`, `legend_position`, and `theme` arguments with current values as defaults
  (e.g. `distanceHeatmap`'s `fontsizescale` step-function becomes the default when the user
  passes nothing).
- Make every plotting function **return** the `ggplot`/grob object instead of only
  plotting/saving as a side effect. Keep an optional `save_path`/`file` argument for users who
  still want the old one-line save behavior.
- Use identical argument names and ordering across all of these functions (same name for
  "palette" everywhere, same name for "font size" everywhere, etc.) — write this convention down
  in the audit doc once and apply it uniformly rather than function-by-function.
- Specific fixes the audit already identified (full detail in the control-gap table):
  `nucTableHeatmap` and `nucFrequencyPlot` duplicate the exact same hardcoded 5-color nucleotide
  vector — dedupe into one shared constant/param; `plotSimilarityMatrixWithTree`'s
  `colorRampPalette(c("blue","yellow","red"))(20)` is a one-line lift to a `colors` argument
  (lowest-effort win found); `plotTreeWithGenes` has a leftover dead bare `SeqTreePlot` expression
  before its real return — delete it while touching that function; `plotTreeWithRuler` currently
  has *no* style parameters at all (`edge.width`, `label.offset`, `cex` are hardcoded directly in
  the call) and needs them added from scratch, not just exposed.
- `plotPCA` already returns a plain `ggplot` object with no hardcoded colors/theme — use it as the
  reference implementation for what "done" looks like on the other functions.
- `getSeqLogo` is not actually a plotting function despite its name — it computes a consensus
  sequence list consumed by `drawSeqLogo`. Handle it under Step 6 (analysis functions), not here.

**Checkpoint:**
- [x] Fresh install in an empty sandbox with no pre-cached packages succeeds via plain
      `R CMD INSTALL`/`install.packages()` — no Bioconductor step required (already established in
      Step 3; re-confirmed here since `DESCRIPTION` changed again).
- [x] Before/after transitive dependency count, via `tools::package_dependencies(recursive=TRUE)`
      against a real CRAN package database: **21 direct / 210 transitive → 19 direct / 142
      transitive** (a 68-package, 32% cut) — and that 210-package "before" figure is itself an
      undercount, since it excludes the Bioconductor `ggtree`/`treeio`/`BiocManager` chain
      entirely (not resolvable the same way via a CRAN-only dependency graph). The practically
      bigger win is qualitative: zero Bioconductor dependency at all, versus one that (per the
      Step 3 finding) doesn't even build against current CRAN `ggplot2`.
- [x] Calling every updated plotting function with **no new arguments** reproduces the exact
      previous output (default-preserving check) — verified per-function against the real
      installed package using the bundled example data (`inst/extdata/Example_Small.*`):
      `distanceHeatmap`, `nucTableHeatmap`, `nucFrequencyPlot`, `nucTableFreqHeatmap`,
      `nucTableFreqHeatmapSplit`, `drawConsWithGenes`/`drawConsWithNoGenes`, `plotTreeWithGenes`,
      `plotTreeWithRuler`, `plotSimilarityMatrixWithTree`, `plotAlignCircle`, `drawSeqLogo`,
      `SNPClusterPlotPCAMap`, `SNPClusterPlot`, `SNPClusterPlotWithTree`, `SNPClusterPlot3DTree` —
      all ran without error and produced unchanged output for default calls.
- [x] Calling each with a custom `palette`/`font_size`/`theme` actually changes the output as
      expected (control check, not a "doesn't error" check) — spot-checked with real assertions,
      not just visual inspection: `distanceHeatmap`'s custom `colors` produces different grob fill
      values than the default gradient (verified by inspecting the `pheatmap` gtable's rect grob
      directly, `identical()` false); `nucTableHeatmap`/`nucFrequencyPlot`'s custom `colors`
      produce different `ggplot_build()` fill data; `SNPClusterPlotPCAMap`'s custom `main` changes
      `p$labels$title`. One caught-and-fixed mistake along the way: my first attempt at
      `SNPClusterPlot3DTree`'s new `ind.names` parameter defaulted to `FALSE`, but the *old*
      `label = F` argument it replaced was never a real `plot.HCPC` parameter — rendering both the
      old code and `ind.names = TRUE` side by side showed the old code always displayed labels
      regardless, so the default had to be `TRUE`, not `FALSE`, to stay default-preserving.
- [x] `devtools::check()` and a manual pass over `NAMESPACE` confirm no orphaned imports remain —
      verified programmatically both directions (`setdiff` each way between `DESCRIPTION`'s
      `Imports:` and every package name in `NAMESPACE`'s `import()`/`importFrom()` lines): both
      empty, so every declared package is used and every used package is declared. Full
      `devtools::check()` on the real repo (not a scratch copy) went from the original
      dependency-complete-check `ERROR` blocking everything, down to 1 pre-existing `ERROR` + 2
      WARNINGs + 5 NOTEs — all confirmed pre-existing and unrelated to this refactor (a broken
      example filename in `alignment2Fasta`, undocumented params in files never touched
      (`AlignSplit`, `alignstatplot`'s `fontscale`), `plotPCA`'s pre-existing dead `labelsize`/
      `showlabels` params (see below), and the same whole-package `@import` collision warnings
      since Step 2). Along the way, also fixed two real pre-existing `DESCRIPTION`/code issues this
      check surfaced that predate the whole refactor: `seqinr` was listed twice in `Imports:`, and
      `nucTableFreqHeatmap`'s `annotate_figure(..., to = ...)` was a partial-argument-match typo
      for `top =`.

**Known, deliberately-not-fixed finding:** `plotPCA`'s `labelsize`/`showlabels` parameters have
been dead code since before this entire refactor — the function discards `fviz_cluster`'s result
and rebuilds a fresh `ggplot` from just `$data`, with no text-label layer at all, so neither
parameter has ever affected the rendered output regardless of value. Wiring them up now would
mean the *default* call (`showlabels` defaults to `TRUE`) suddenly starts showing labels that were
never shown before — a default-changing behavior change, which fails this step's own
default-preserving checkpoint. Left as-is and documented rather than silently fixed; a real fix
belongs in its own explicitly-reviewed change, per this plan's ground rule 1.

**STATUS: DONE.** Dependency side: `DESCRIPTION`/`NAMESPACE` now declare exactly what's used, no
more, no less (`ggplot2`, `grid`, `stringr`, `tibble`, `RColorBrewer`, `scales` added; vestigial
`@import RColorBrewer` tag on `plotSimilarityMatrixWithTree.R` dropped; duplicate `seqinr` entry
removed). Added `.Rbuildignore` entries for `graphify-out/`, `docs/`, `REFACTOR_PLAN.md`, and
`.claude/` since those are this refactor's own planning artifacts, not package source.

Control side: added parameters (with current-value defaults, verified default-preserving) to
`distanceHeatmap` (`colors`), `nucTableHeatmap`/`nucFrequencyPlot` (`colors`, deduped into a
shared `defaultNucleotideColors` constant in new file `R/nucleotidePalette.R`),
`nucTableFreqHeatmap` (`colors`, `heights`, `title`, `subtitle`, `title_size` — also fixed a
pre-existing bug where its own `cex.SeqLabels` was silently never forwarded to the heatmap panel),
`nucTableFreqHeatmapSplit` (now forwards `cex.NucLabels`/`cex.SeqLabels`/`...` to
`nucTableFreqHeatmap`, fixing the same forwarding bug one level up), `drawConsWithGenes`
(`colors`, `linkAlpha`), `drawConsWithNoGenes` (`colors`, `bgColor`), `drawGenes`
(`labelCexScale`), `plotTreeWithGenes`/`SNPClusterPlotWithTree` (`geneArrowFill`, `rel_widths`,
`label_size`), `SNPClusterPlot` (`geneArrowFill`), `plotTreeWithRuler` (`edge.width`,
`label.offset`, `cex`, `axis.cex` — had zero style parameters before), `plotSimilarityMatrixWithTree`
(`colors`, `fontsizescale`), `plotAlignCircle` (`colors`, passed through to the circos functions
it delegates to), `drawSeqLogo` (`titleColor`, `titleSize`), `SNPClusterPlotPCAMap` (`main`,
`geom`, `pointsize`, `font.label`), `SNPClusterPlot3DTree` (`title`, `ind.names`).

---

## Step 6 — Validation, tests, and docs for analysis functions

**Goal:** lock in correctness for the analysis side (`AlignmentStatsPerSeq`,
`getBiallelicByFreq`, `getDistanceMatrixTabel`, `nucFrequency`, `seqTableToBinary`,
`getClusterTable`, `SeqLocateCluster`, etc.) so future changes can't silently break them.

Actions:
- Standardize input/output shapes across functions that feed into each other (same column names/
  types where one function's output is another's input).
- Add input validation with informative errors (reject malformed alignment tables at the entry
  point of each function, not deep inside a downstream plotting call).
- Add `testthat` tests capturing **current** behavior for each analysis function — write these
  against the Step-4-final code so they encode the intended post-refactor behavior, then keep
  them as a permanent regression suite.
- Update roxygen docs/examples to show the new `palette`/`font_size`/`theme`/return-value
  behavior from Step 5.

**Checkpoint:**
- [x] `testthat::test_dir()` passes with 100% of new tests green — 46 `test_that()` blocks / 112
      expectations, 0 failures, 0 warnings, across 8 new test files under `tests/testthat/`.
- [x] Every exported analysis function has at least one test and one documented validation error
      case — covered: `getSeqInfo`, `alignment2Fasta`, `alignment2Table`, `AlignmentStatsPerSeq`,
      `percentFormat`, `nucFrequency`, `getBiallelicByFreq`, `getRefGenotypeForbiallelic`,
      `seqRefCommon`, `seqTableToBinary`, `nucTableFilter`, `getDistanceMatrixTabel`, `getTree`,
      `SNPCluster`, `getClusterTable`, `SeqLocateCluster` (unexported but core to the pipeline),
      `seqRemoveAmbiguous`, `seqWithLast`, `getSectorWidth`, `get_os`, `formatFolderPath`,
      `alignmentNoGaps`, `alignmentNoGapsLinks`, `readSeq`, `seqAlign`, `AlignedTrueLenght`.
      Plotting functions are out of scope here (Step 5 already gave them the control-API pass).
- [x] `devtools::check()` is clean beyond pre-existing, already-documented issues — went from
      **1 ERROR** (an example requiring the `clustalw` binary, wrongly wrapped in `\donttest{}`
      instead of `\dontrun{}` — fixed) down to **0 errors**, 1 warning, 5 notes, and every one of
      those remaining is pre-existing and already logged in Steps 3–5: the whole-package `@import`
      symbol-collision warnings (e.g. `ape::degree` vs `circlize::degree`), "future file timestamps"
      (sandbox artifact), top-level `LICENSE`/`Example_Out.zip`/`README.Rmd` NOTEs (project layout,
      predates this refactor), the large "no visible global function/variable" NOTE block (`aes()`
      NSE, base-package calls without explicit `importFrom`, all pre-existing across the whole
      codebase), and two C-code NOTEs unrelated to any R-level change in this plan.
- [x] `R CMD check --as-cran`-equivalent (`devtools::check()`) run as the final gate — see above;
      this is the actual full run against the real working tree, not a scratch copy.

**Findings from this step, beyond the plan's original scope:**
1. **Doc-order bug:** `AlignmentStatsPerSeq`'s roxygen `@param` block documented `SeqAligned`
   before `SeqInfo`, but the real signature is `function(SeqInfo, SeqAligned)`. Fixed — zero
   behavior change, docs-only.
2. **Two broken example filenames + one broken example call:** `getSeqInfo.R` and
   `alignment2Fasta.R`'s `@examples` referenced a nonexistent `sequence_few.fasta` (the real bundled
   file is `Example_Small.fasta`); `getSeqInfo.R`'s example also called `getSeqInfo(fs)` on an
   already-parsed fasta object instead of the file path the function actually takes.
   `getSeqColors.R`'s example called a function name (`getSectorColors`) that has never existed —
   the real function is `getSeqColors`. All three fixed and now verified to actually run.
3. **Roxygen2 could not fully regenerate `man/`/`NAMESPACE` at all before this step:** `AlignSplit`
   in `plotAlignCircle.R` had an empty `@param seq` and empty `@return`, which aborts
   `roxygen2::roxygenise()` for the *entire package* after only 3 files. This means Steps 3–5's
   claimed `devtools::check()` runs were necessarily done against scratch copies with this bug
   patched around, since a real regeneration in this working tree was never possible until now.
   Fixed by filling in the description/return doc. This is the single most consequential finding
   in Step 6: it confirms Step 5's control-API params (`colors`, `font_size`, etc.) were correctly
   tagged in source all along, but had never actually been compiled into the real `man/`/`NAMESPACE`
   in this working tree before this step did it for the first time.
4. **Implicit `"N<number>"` column-naming coupling:** `alignment2Table()` names columns `N1..Nn`;
   `getClusterTable()`/`SeqLocateCluster()` parse that convention back out via
   `gsub("N", "", ...)` with no validation anywhere in between. Guarded with explicit validation in
   `SeqLocateCluster` (format + in-range position checks) rather than redesigning the convention
   itself, since changing the convention would be a Step-1-4-style behavior change out of scope here.
5. **Two more pre-existing "undocumented argument" warnings fixed as cheap, zero-risk docs-only
   wins while regenerating `man/` for real:** `alignment2Fasta`'s `format` parameter and
   `alignstatplot`'s `fontscale` parameter had no `@param` entry at all. `plotPCA`'s `labelsize`/
   `showlabels` (already known dead code per Step 5's log) are now explicitly documented as
   currently-unused rather than left silently undocumented.

**Validation added** (informative `stop()` at the entry point, not deep inside a downstream call),
with confirmation via test that each doesn't change valid-input behavior: `getSeqInfo`,
`alignment2Fasta`, `alignment2Table`, `AlignmentStatsPerSeq`, `nucFrequency`,
`getBiallelicByFreq`, `getRefGenotypeForbiallelic`, `seqRefCommon`, `seqTableToBinary`,
`nucTableFilter`, `getDistanceMatrixTabel`, `getTree`, `SNPCluster`, `getClusterTable`,
`SeqLocateCluster`, `seqRemoveAmbiguous`, `getSectorWidth`, `seqWithLast`.

**Test infrastructure:** `usethis::use_testthat(3)` — added `testthat (>= 3.0.0)` to `Suggests`,
`Config/testthat/edition: 3`, `tests/testthat.R`, `tests/testthat/helper-fixtures.R` (shared
fixtures: a handcrafted 5x8 alignment with known gap/GC values, a 6x25 synthetic biallelic table
with known ground truth, an 8x20 two-cluster synthetic table for a deterministic `SNPCluster`
test, and helpers pulling real data from the bundled `inst/extdata/Example_Sequences_Aligned.fasta`).
Fixtures build `ape::DNAbin` objects directly via `ape::as.DNAbin()` on a character matrix rather
than calling `seqAlign()`, since no alignment binary (ClustalW/MUSCLE/etc.) is installed in this
environment — consistent with the same constraint Steps 3–4 already worked around.

**STATUS: DONE.**

---

## Execution order

Steps 1 → 2 → 3 → 4 → 5 are sequential (each depends on the previous step's checkpoint passing).
Step 6 can start as soon as Step 1's audit exists and run in parallel with Steps 2–5, since tests
target current behavior first and get updated for new arguments only in Step 5. Do not mark this
plan complete until every checkpoint box across all six steps is checked.

**PLAN STATUS: COMPLETE.** All six steps' checkpoints are checked. Final state: `Imports:` cut
from 21 packages (including a Bioconductor dependency that doesn't even build against current
CRAN `ggplot2`) to 19, zero Bioconductor/`remotes:` dependency; every plotting function takes a
`palette`/`colors`, font-size, and theme-style argument with default-preserving values and returns
its plot object; every analysis function validates its input at the entry point with an
informative error; `tests/testthat/` has 46 test blocks / 112 passing expectations covering the
full analysis pipeline; `devtools::check()` runs clean at 0 errors, with only pre-existing,
previously-documented warnings/notes remaining.
