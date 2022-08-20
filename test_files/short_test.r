accession_taxa_path <- "/data/home/galoscarleo/taxonomy/accessionTaxa.sql"
db_path <- "/data/home/galoscarleo/nt"

RCRUX.dev::get_blast_seeds("TAGAACAGGCTCCTCTAG", "TTAGATACCCCACTATGC",
    "short_test/", "12S_V5F1", accession_taxa_path,
    organism = c("7776", "7777"), return_table = FALSE)