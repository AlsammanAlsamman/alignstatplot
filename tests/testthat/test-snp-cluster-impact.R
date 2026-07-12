test_that("SNPClusterImpact scores SNPs, weighted toward higher-variance dimensions, sorted descending", {
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  it <- SNPClusterImpact(cl)

  expect_equal(colnames(it), c("SNP","Impact","Cos2","Cluster"))
  expect_equal(nrow(it), ncol(m))
  expect_equal(sort(it$SNP), sort(colnames(m)))
  expect_false(any(is.na(it$Impact)))
  expect_false(any(is.na(it$Cos2)))
  # sorted descending by Impact
  expect_equal(it$Impact, sort(it$Impact, decreasing = TRUE))
  # this fixture's HCPC-assigned clusters must match getClusterTable()'s (same source)
  ct <- getClusterTable(cl)
  expect_equal(it$Cluster[match(ct$Nucleotide, it$SNP)], as.character(ct$Cluster))
})

test_that("SNPClusterImpact rejects an object that isn't an HCPC result", {
  expect_error(SNPClusterImpact(list(foo = 1)), "HCPC object")
  expect_error(SNPClusterImpact(list(data.clust = data.frame(clust = 1))), "HCPC object")
})

test_that("filterHighImpactSNPs keeps the requested top-N highest-impact SNPs, in original column order", {
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  it <- SNPClusterImpact(cl)

  top5 <- it$SNP[order(-it$Impact)][1:5]
  f <- filterHighImpactSNPs(m, it, topN = 5)
  expect_equal(ncol(f), 5)
  expect_equal(sort(colnames(f)), sort(top5))
  # original column order preserved (not impact-rank order)
  expect_equal(colnames(f), colnames(m)[colnames(m) %in% top5])
})

test_that("filterHighImpactSNPs supports minImpact and defaults to the elbow point", {
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  it <- SNPClusterImpact(cl)

  fMin <- filterHighImpactSNPs(m, it, minImpact = 0)
  expect_equal(ncol(fMin), ncol(m)) # every SNP has Impact >= 0

  fDefault <- filterHighImpactSNPs(m, it)
  expect_true(ncol(fDefault) >= 1 && ncol(fDefault) <= ncol(m))
})

test_that("filterHighImpactSNPs rejects malformed input and conflicting/invalid arguments", {
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  it <- SNPClusterImpact(cl)

  expect_error(filterHighImpactSNPs(m, data.frame(x = 1)), "SNPClusterImpact")
  expect_error(filterHighImpactSNPs(m, it, topN = 2, minImpact = 1), "only one of")
  expect_error(filterHighImpactSNPs(m, it, topN = 0), "positive number")
  expect_error(filterHighImpactSNPs(m, it, minImpact = 1e9), "No SNP columns matched")
})

test_that("plotSNPClusterImpact renders a 2-panel patchwork and marks the chosen cutoff", {
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  it <- SNPClusterImpact(cl)

  p <- plotSNPClusterImpact(it)
  expect_s3_class(p, "patchwork")

  p2 <- plotSNPClusterImpact(it, topN = 3)
  expect_s3_class(p2, "patchwork")
})

test_that("plotSNPClusterImpact rejects malformed input and a non-positive topN", {
  expect_error(plotSNPClusterImpact(data.frame(x = 1)), "SNPClusterImpact")
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  it <- SNPClusterImpact(cl)
  expect_error(plotSNPClusterImpact(it, topN = 0), "positive number")
})
