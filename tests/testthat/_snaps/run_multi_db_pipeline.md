# run_multi_db_pipeline works

    Code
      files_to_snapshot %>% purrr::map_vec(function(filename) {
        stringr::str_replace(string = filename, pattern = "^/.*/16S", replacement = "./16S")
      }) %>% print()
    Output
       [1] "./16S/db_all/blast_seeds_output/Nitrospira.fasta"                                                              
       [2] "./16S/db_all/blast_seeds_output/Nitrospira_blast_seeds_summary_unique_taxonomic_rank_counts.csv"               
       [3] "./16S/db_all/blast_seeds_output/Nitrospira_taxonomy.txt"                                                       
       [4] "./16S/db_all/blast_seeds_output/blastdbcmd_failed.csv"                                                         
       [5] "./16S/db_all/blast_seeds_output/derep_and_clean_db/Nitrospira_derep_and_clean.fasta"                           
       [6] "./16S/db_all/blast_seeds_output/derep_and_clean_db/Nitrospira_derep_and_clean_taxonomy.txt"                    
       [7] "./16S/db_all/blast_seeds_output/derep_and_clean_db/Nitrospira_derep_and_clean_unique_taxonomic_rank_counts.txt"
       [8] "./16S/db_all/blast_seeds_output/derep_and_clean_db/Sequences_with_lowest_common_taxonomic_path_agreement.csv"  
       [9] "./16S/db_all/blast_seeds_output/derep_and_clean_db/Sequences_with_mostly_NA_taxonomic_paths.csv"               
      [10] "./16S/db_all/blast_seeds_output/derep_and_clean_db/Sequences_with_multiple_taxonomic_paths.csv"                
      [11] "./16S/db_all/blast_seeds_output/derep_and_clean_db/Sequences_with_single_taxonomic_path.csv"                   
      [12] "./16S/db_all/blast_seeds_output/summary.csv"                                                                   

