test_that("blast_seeds_multi_db throws if blast_db_path is given", {
  expect_error(
    blast_seeds_multi_db(
      blast_db_paths = "",
      output_directory_path = "",
      metabarcode_name = "",
      blast_db_path = "",
      parallel_jobs = 2
    ),
    "arguments.*not allowed.*blast_db_path"
  )
})
