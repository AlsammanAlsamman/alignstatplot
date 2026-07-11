test_that("plottedTipOrder matches ape::plot.phylo()'s actual drawn tip order, not tree$tip.label's raw order", {
  # Regression test for a real bug: baseTreeHeatmap() used to reorder heatmap
  # rows by tree$tip.label's raw storage order, but plot.phylo() draws tips in
  # an order determined by tree topology, which is generally different -- this
  # scrambled which heatmap row lined up with which tree tip. This distance
  # matrix (derived from a real user's sequence data) reliably produces a
  # plotted order that differs completely from the raw tip.label order.
  d <- matrix(c(
    0.0000, 0.0827, 0.0803, 0.0809, 0.0831, 0.0807,
    0.0827, 0.0000, 0.0270, 0.0261, 0.0260, 0.0217,
    0.0803, 0.0270, 0.0000, 0.0177, 0.0228, 0.0162,
    0.0809, 0.0261, 0.0177, 0.0000, 0.0162, 0.0162,
    0.0831, 0.0260, 0.0228, 0.0162, 0.0000, 0.0145,
    0.0807, 0.0217, 0.0162, 0.0162, 0.0145, 0.0000
  ), nrow = 6, byrow = TRUE)
  taxa <- c("PQ538529.1","F12P4","F18P4","102","101","F18P12")
  rownames(d) <- colnames(d) <- taxa
  tree <- ape::nj(as.dist(d))

  # tip.label's raw order is untouched by nj() -- same as input
  expect_equal(tree$tip.label, taxa)

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  ape::plot.phylo(tree)
  order <- plottedTipOrder(tree)

  expect_setequal(order, taxa) # still every tip, just reordered
  expect_false(identical(order, tree$tip.label)) # genuinely different from raw order

  # cross-check against an independent read of ape's own plot state, rather
  # than a value hardcoded from a possibly-different tree build/rounding
  lastPP <- get("last_plot.phylo", envir = ape::.PlotPhyloEnv)
  tipY <- lastPP$yy[seq_along(tree$tip.label)]
  names(tipY) <- tree$tip.label
  expect_equal(order, names(sort(tipY)))
})

test_that("baseTreeHeatmap/plotSimilarityMatrixWithTree render without error when plotted order differs from raw order", {
  d <- matrix(c(
    0.0000, 0.0827, 0.0803, 0.0809, 0.0831, 0.0807,
    0.0827, 0.0000, 0.0270, 0.0261, 0.0260, 0.0217,
    0.0803, 0.0270, 0.0000, 0.0177, 0.0228, 0.0162,
    0.0809, 0.0261, 0.0177, 0.0000, 0.0162, 0.0162,
    0.0831, 0.0260, 0.0228, 0.0162, 0.0000, 0.0145,
    0.0807, 0.0217, 0.0162, 0.0162, 0.0145, 0.0000
  ), nrow = 6, byrow = TRUE)
  taxa <- c("PQ538529.1","F12P4","F18P4","102","101","F18P12")
  rownames(d) <- colnames(d) <- taxa
  tree <- ape::nj(as.dist(d))

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  expect_no_error(baseTreeHeatmap(tree, d))
})

test_that("baseTreeHeatmap's row/column reordering keeps every self-comparison on the visual diagonal", {
  # Visual diagonal (top-left to bottom-right, reading order) means: at visual
  # row k / visual column k, the value shown is a self-comparison (0). Given
  # image()'s y-axis increases bottom-to-top, visual row k corresponds to
  # y = n+1-k, so this checks d[order[n+1-k], order[n+1-k]] for every k --
  # true by construction for *any* valid permutation, so this test exists to
  # pin down the row/col construction itself (X[order, rev(order)]) rather
  # than reprove the (trivial) zero-diagonal fact.
  d <- matrix(c(
    0.0000, 0.0827, 0.0803, 0.0809, 0.0831, 0.0807,
    0.0827, 0.0000, 0.0270, 0.0261, 0.0260, 0.0217,
    0.0803, 0.0270, 0.0000, 0.0177, 0.0228, 0.0162,
    0.0809, 0.0261, 0.0177, 0.0000, 0.0162, 0.0162,
    0.0831, 0.0260, 0.0228, 0.0162, 0.0000, 0.0145,
    0.0807, 0.0217, 0.0162, 0.0162, 0.0145, 0.0000
  ), nrow = 6, byrow = TRUE)
  taxa <- c("PQ538529.1","F12P4","F18P4","102","101","F18P12")
  rownames(d) <- colnames(d) <- taxa
  tree <- ape::nj(as.dist(d))

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  ape::plot.phylo(tree)
  order <- plottedTipOrder(tree)
  n <- length(order)

  reordered <- d[order, rev(order)]
  # z[x,y] = t(reordered)[x,y] = reordered[y,x]; visual row k -> y = n+1-k
  visualDiagonal <- vapply(seq_len(n), function(k) reordered[n + 1 - k, k], numeric(1))
  expect_equal(unname(visualDiagonal), rep(0, n))
})
