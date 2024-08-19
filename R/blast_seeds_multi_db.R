check_files_exist <- function(files) {
  all_files_exist <- files %>%
    lapply(file.exists) %>%
    unlist() %>%
    all()

  if (all_files_exist) {
    files
  } else {
    stop("Not all output files were generated successfully.")
  }
}

# Read all the summaries and dereplicate them.
collate_summaries <- function(blast_seeds_outfiles, summary_outfile) {
  purrr::map_dfr(blast_seeds_outfiles, function(filenames) {
    if (!is.list(filenames)) {
      warning("SOMETHING WEIRD HAPPENED AND THIS IS NOT A LIST")
      print(str(filenames))
      lg$error(filenames, what = "filenames should have been a list")
    }
    readr::read_csv(filenames[["summary"]])
  }) %>%
    dplyr::distinct() %>%
    readr::write_csv(summary_outfile)
}

# Read all the taxonomy files and dereplicate them.
collate_taxonomies <- function(blast_seeds_outfiles, taxonomy_outfile) {
  purrr::map_dfr(blast_seeds_outfiles, function(filenames) {
    readr::read_tsv(filenames[["taxonomy"]])
  }) %>%
    dplyr::distinct() %>%
    readr::write_tsv(taxonomy_outfile)
}

# Read all the fasta files and dereplicate them.
collate_fastas <- function(blast_seeds_outfiles, fasta_outfile) {
  fastas <- sapply(blast_seeds_outfiles, function(l) l[["recovered_seqs"]])
  args <- c("rmdup", "-o", fasta_outfile, fastas)

  # TODO: take location of seqkit command as an arg.
  system2(command = "seqkit", args = args)
}

make_outfile_names <- function(dir, metabarcode_name) {
  list(
    dir = dir,
    summary = file.path(dir, "summary.csv"),
    recovered_seqs = file.path(dir, paste0(metabarcode_name, ".fasta")),
    taxonomy = file.path(dir, paste0(metabarcode_name, "_taxonomy.txt"))
  )
}


# Returns the collated output directory path.
blast_seeds_multi_db <- function(
    blast_db_paths,
    output_directory_path,
    metabarcode_name,
    parallel_jobs,
    ...) {
  check_forbidden_args(
    additional_args = list(...),
    forbidden_args = c("blast_db_path")
  )

  collated_output_path <- file.path(
    output_directory_path, "db_collated"
  )

  collated_blast_seeds_output_path <- file.path(
    collated_output_path, "blast_seeds_output"
  )

  dir.create(
    collated_blast_seeds_output_path,
    recursive = TRUE, mode = "0750", showWarnings = FALSE
  )

  blast_seeds_outfiles <- parallel::mclapply(
    X = seq_along(blast_db_paths),
    FUN = function(n) {
      blast_db_path <- blast_db_paths[[n]]

      lg$trace("blast_db_path from blast_seeds_multi_db", what = blast_db_path)

      message("working on blast_db_path: ", blast_db_path)

      out_path <- create_sub_output_directory(output_directory_path, n)

      blast_seeds(
        blast_db_path = blast_db_path,
        output_directory_path = out_path,
        metabarcode_name = metabarcode_name,
        ...
      )

      blast_seeds_outdir <- file.path(out_path, "blast_seeds_output")

      make_outfile_names(
        dir = blast_seeds_outdir,
        metabarcode_name = metabarcode_name
      ) %>%
        check_files_exist()
    },
    mc.preschedule = FALSE,
    mc.cores = parallel_jobs,
    mc.allow.recursive = FALSE
  )

  collated_outfiles <- make_outfile_names(
    dir = collated_blast_seeds_output_path,
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

  collated_output_path
}
