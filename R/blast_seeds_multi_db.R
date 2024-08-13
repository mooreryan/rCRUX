check_forbidden_args <- function(additional_args, forbidden_args) {
  forbidden_present <-
    forbidden_args[forbidden_args %in% names(additional_args)]

  if (length(forbidden_present) > 0) {
    stop(
      "The following arguments are not allowed: ",
      paste(forbidden_present, collapse = ", ")
    )
  }
}

# Read all the summaries and dereplicate them.
collate_summaries <- function(blast_seeds_outfiles, summary_outfile) {
  purrr::map_dfr(blast_seeds_outfiles, function(filenames) {
    readr::read_csv(filenames$summary)
  }) %>%
    dplyr::distinct() %>%
    readr::write_csv(summary_outfile)
}

# Read all the taxonomy files and dereplicate them.
collate_taxonomies <- function(blast_seeds_outfiles, taxonomy_outfile) {
  purrr::map_dfr(blast_seeds_outfiles, function(filenames) {
    readr::read_tsv(filenames$taxonomy)
  }) %>%
    dplyr::distinct() %>%
    readr::write_tsv(taxonomy_outfile)
}

# Read all the fasta files and dereplicate them.
collate_fastas <- function(blast_seeds_outfiles, fasta_outfile) {
  fastas <- sapply(blast_seeds_outfiles, function(l) l$recovered_seqs)
  args <- c("rmdup", "-o", fasta_outfile, fastas)

  # TODO: take location of seqkit command as an arg.
  system2(command = "seqkit", args = args)
}

collate_failures <- function(blast_seeds_outfiles, failures_outfile) {
  purrr::map_dfr(seq_along(blast_seeds_outfiles), function(i) {
    filenames <- blast_seeds_outfiles[[i]]

    readr::read_csv(filenames$failed) |>
      # We add a column here because the "failures" only make sense in the
      # context of the database in which they were searched against.
      dplyr::mutate(i = i)
  }) %>%
    readr::write_csv(failures_outfile)
}

collate_tax_rank_counts <- function(
    blast_seeds_outfiles,
    tax_rank_counts_outfile) {
  purrr::map_dfr(seq_along(blast_seeds_outfiles), function(i) {
    filenames <- blast_seeds_outfiles[[i]]

    readr::read_csv(filenames$unique_tax_rank_counts) |>
      # Not sure if this is the best way to handle this.  Probably we will need
      # to redo the counts on the collated output files.
      dplyr::mutate(i = i)
  }) %>%
    readr::write_csv(tax_rank_counts_outfile)
}

make_outfile_names <- function(dir, metabarcode_name) {
  list(
    summary = file.path(dir, "summary.csv"),
    recovered_seqs = file.path(dir, paste0(metabarcode_name, ".fasta")),
    taxonomy = file.path(dir, paste0(metabarcode_name, "_taxonomy.txt")),
    failed = file.path(dir, "blastdbcmd_failed.csv"),
    unique_tax_rank_counts = file.path(
      dir,
      paste0(
        metabarcode_name,
        "_blast_seeds_summary_unique_taxonomic_rank_counts.csv"
      )
    )
  )
}

blast_seeds_multi_db <- function(
    blast_db_paths,
    output_directory_path,
    metabarcode_name,
    ...) {
  check_forbidden_args(
    additional_args = list(...),
    forbidden_args = c("blast_db_path")
  )

  combined_out_path <- file.path(
    output_directory_path, "db_all", "blast_seeds_output"
  )
  dir.create(
    combined_out_path,
    recursive = TRUE, mode = "0750", showWarnings = FALSE
  )

  blast_seeds_outfiles <- lapply(seq_along(blast_db_paths), function(n) {
    blast_db_path <- blast_db_paths[[n]]

    message("working on blast_db_path: ", blast_db_path)

    # TODO: pull this into a function with the one from the other function.
    out_path <- file.path(output_directory_path, paste0("db_", n))
    dir.create(out_path, recursive = TRUE, mode = "0750", showWarnings = FALSE)

    # TODO: does blast_seeds have a table output?
    blast_seeds(
      blast_db_path = blast_db_path,
      output_directory_path = out_path,
      metabarcode_name = metabarcode_name,
      ...
    )

    blast_seeds_outdir <- file.path(out_path, "blast_seeds_output")

    outfiles <- make_outfile_names(
      dir = blast_seeds_outdir,
      metabarcode_name = metabarcode_name
    )

    all_outfiles_exist <- lapply(outfiles, file.exists)

    if (!all(unlist(all_outfiles_exist))) {
      stop("Not all output files were generated successfully.")
    }

    outfiles
  })

  collated_outfiles <- make_outfile_names(
    dir = combined_out_path,
    metabarcode_name = metabarcode_name
  )

  collate_summaries(
    blast_seeds_outfiles = blast_seeds_outfiles,
    summary_outfile = collated_outfiles$summary
  )

  collate_taxonomies(
    blast_seeds_outfiles = blast_seeds_outfiles,
    taxonomy_outfile = collated_outfiles$taxonomy
  )

  collate_fastas(
    blast_seeds_outfiles = blast_seeds_outfiles,
    fasta_outfile = collated_outfiles$recovered_seqs
  )

  collate_failures(
    blast_seeds_outfiles = blast_seeds_outfiles,
    failures_outfile = collated_outfiles$failed
  )

  collate_tax_rank_counts(
    blast_seeds_outfiles = blast_seeds_outfiles,
    tax_rank_counts_outfile = collated_outfiles$unique_tax_rank_counts
  )

  collated_outfiles
}
