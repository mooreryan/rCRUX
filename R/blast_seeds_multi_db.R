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

  outfiles <- lapply(seq_along(blast_db_paths), function(n) {
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

    outfiles <- list(
      summary = file.path(
        blast_seeds_outdir, "summary.csv"
      ),
      recovered_seqs = file.path(
        blast_seeds_outdir,
        paste0(metabarcode_name, ".fasta")
      ),
      taxonomy = file.path(
        blast_seeds_outdir,
        paste0(metabarcode_name, "_taxonomy.txt")
      ),
      failed = file.path(
        blast_seeds_outdir, "blastdbcmd_failed.csv"
      ),
      unique_tax_rank_counts = file.path(
        blast_seeds_outdir,
        paste0(
          metabarcode_name,
          "_blast_seeds_summary_unique_taxonomic_rank_counts.csv"
        )
      )
    )

    all_outfiles_exist <- lapply(outfiles, file.exists)

    if (!all(unlist(all_outfiles_exist))) {
      stop("Not all output files were generated successfully.")
    }

    outfiles
  })

  final_outfiles <- list(
    summary = file.path(
      combined_out_path, "summary.csv"
    ),
    recovered_seqs = file.path(
      combined_out_path,
      paste0(metabarcode_name, ".fasta")
    ),
    taxonomy = file.path(
      combined_out_path,
      paste0(metabarcode_name, "_taxonomy.txt")
    ),
    failed = file.path(
      combined_out_path, "blastdbcmd_failed.csv"
    ),
    unique_tax_rank_counts = file.path(
      combined_out_path,
      paste0(
        metabarcode_name,
        "_blast_seeds_summary_unique_taxonomic_rank_counts.csv"
      )
    )
  )

  collate_summaries(
    blast_seeds_outfiles = outfiles, summary_outfile = final_outfiles$summary
  )

  collate_taxonomies(
    blast_seeds_outfiles = outfiles,
    taxonomy_outfile = final_outfiles$taxonomy
  )

  collate_fastas(
    blast_seeds_outfiles = outfiles,
    fasta_outfile = final_outfiles$recovered_seqs
  )

  collate_failures(
    blast_seeds_outfiles = outfiles,
    failures_outfile = final_outfiles$failed
  )

  collate_tax_rank_counts(
    blast_seeds_outfiles = outfiles,
    tax_rank_counts_outfile = final_outfiles$unique_tax_rank_counts
  )

  final_outfiles
}
