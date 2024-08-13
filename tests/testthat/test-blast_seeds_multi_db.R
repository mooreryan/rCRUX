test_that("blast_seeds_multi_db", {
  # This is data taken from the above test.  TODO: get a better way to do this.
  seeds_output_data <- readr::read_csv("qseqid.x,gi,accession,mismatch_forward,forward_start,forward_stop,staxids,distinct_entries.x,qseqid.y,mismatch_reverse,reverse_start,reverse_stop,distinct_entries.y,product_length,taxid,species,superkingdom,kingdom,phylum,subphylum,superclass,class,subclass,order,family,subfamily,genus,infraorder,subcohort,superorder,superfamily,tribe,subspecies,subgenus,species.group,parvorder,varietas
forward_row_1,0,CP011801.1,0,651,668,42253,2,reverse_row_1,0,1497,1482,2,846,42253,Nitrospira moscoviensis,Bacteria,NA,Nitrospirae,NA,NA,Nitrospira,NA,Nitrospirales,Nitrospiraceae,NA,Nitrospira,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA
forward_row_1,0,HM485589.1,0,651,668,876851,2,reverse_row_1,0,1499,1484,2,848,876851,Nitrospira calida,Bacteria,NA,Nitrospirae,NA,NA,Nitrospira,NA,Nitrospirales,Nitrospiraceae,NA,Nitrospira,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA
forward_row_1,0,EU559167.1,0,658,675,330214,2,reverse_row_1,0,1505,1490,2,847,330214,Nitrospira defluvii,Bacteria,NA,Nitrospirae,NA,NA,Nitrospira,NA,Nitrospirales,Nitrospiraceae,NA,Nitrospira,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA
forward_row_1,0,HQ686084.1,0,651,668,314229,2,reverse_row_1,0,1498,1483,2,847,314229,Nitrospira marina,Bacteria,NA,Nitrospirae,NA,NA,Nitrospira,NA,Nitrospirales,Nitrospiraceae,NA,Nitrospira,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA
forward_row_1,0,DQ059545.1,0,651,668,330214,2,reverse_row_1,0,1497,1482,2,846,330214,Nitrospira defluvii,Bacteria,NA,Nitrospirae,NA,NA,Nitrospira,NA,Nitrospirales,Nitrospiraceae,NA,Nitrospira,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA
forward_row_1,0,FP929003.1,0,658,675,330214,2,reverse_row_1,0,1505,1490,2,847,330214,Nitrospira defluvii,Bacteria,NA,Nitrospirae,NA,NA,Nitrospira,NA,Nitrospirales,Nitrospiraceae,NA,Nitrospira,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA
")

  # Write the seeds_output_data to the temporary file
  seeds_output_path <- tempfile()
  readr::write_csv(seeds_output_data, seeds_output_path)

  output_directory_path_top <- tempdir()
  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
  )

  blast_db_path <- system.file(
    package = "rCRUX", "mock-db/mock-db-sequences-split"
  )

  blast_db_paths <- paste0(
    file.path(blast_db_path, "mock-db-sequences.part_00"),
    1:3
  )

  accession_taxa_sql_path <- system.file(
    package = "rCRUX",
    "mock-db/taxonomizr-ncbi-db-small.sql"
  )

  metabarcode_name <- "Nitrospira"

  combined_outfiles <- blast_seeds_multi_db(
    seeds_output_path = seeds_output_path,
    blast_db_paths = blast_db_paths,
    accession_taxa_sql_path = accession_taxa_sql_path,
    output_directory_path = output_directory_path,
    metabarcode_name = metabarcode_name,
    expand_vectors = TRUE,
    minimum_length = 5,
    maximum_length = 900,
    num_threads = 1
  )

  lapply(combined_outfiles, function(filename) {
    expect_snapshot_file(filename)
  })
})

test_that("blast_seeds_multi_db throws if blast_db_path is given", {
  expect_error(
    blast_seeds_multi_db(
      blast_db_paths = "",
      output_directory_path = "",
      metabarcode_name = "",
      blast_db_path = ""
    ),
    "arguments.*not allowed.*blast_db_path"
  )
})
