test_that("SNPCluster + getClusterTable + SeqLocateCluster form a consistent, deterministic pipeline", {
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  expect_s3_class(cl, "HCPC")

  ct <- getClusterTable(cl)
  expect_equal(colnames(ct), c("Nucleotide","Cluster"))
  expect_equal(nrow(ct), ncol(m))
  expect_equal(sort(ct$Nucleotide), sort(colnames(m)))
  # Deterministic given this fixture (verified stable across repeated runs).
  ordered_cluster <- as.character(ct$Cluster[order(as.numeric(gsub("N","",ct$Nucleotide)))])
  expect_equal(ordered_cluster,
               as.character(c(1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3)))

  SeqAligned <- lapply(seq_len(nrow(m)), function(i) unname(m[i, ]))
  names(SeqAligned) <- rownames(m)
  located <- SeqLocateCluster(SeqAligned, ct)

  expect_equal(length(located), nrow(m))
  # every non-gap position gets overwritten with its cluster id (as character)
  expect_equal(located[[1]], ordered_cluster)
})

test_that("getClusterTable rejects an object that isn't an HCPC result", {
  expect_error(getClusterTable(list(foo = 1)), "HCPC object")
  expect_error(getClusterTable(list(data.clust = data.frame(x = 1))), "HCPC object")
})

test_that("SNPCluster rejects empty input and a non-positive ncp", {
  expect_error(SNPCluster(matrix(nrow = 0, ncol = 0)), "non-empty")
  m <- make_two_cluster_table()
  expect_error(SNPCluster(m, ncp = 0), "positive number")
})

test_that("SeqLocateCluster rejects malformed cluster tables", {
  m <- make_two_cluster_table()
  cl <- SNPCluster(m, ncp = 5)
  ct <- getClusterTable(cl)
  SeqAligned <- lapply(seq_len(nrow(m)), function(i) unname(m[i, ]))
  names(SeqAligned) <- rownames(m)

  bad_names <- ct
  colnames(bad_names) <- c("Foo","Bar")
  expect_error(SeqLocateCluster(SeqAligned, bad_names), "Nucleotide.*Cluster")

  bad_format <- ct
  bad_format$Nucleotide[1] <- "X1"
  expect_error(SeqLocateCluster(SeqAligned, bad_format), "naming convention")

  out_of_range <- ct
  out_of_range$Nucleotide[1] <- "N9999"
  expect_error(SeqLocateCluster(SeqAligned, out_of_range), "out-of-range")
})
