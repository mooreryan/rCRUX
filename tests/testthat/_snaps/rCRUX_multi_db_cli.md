# rCRUX_multi_db.R CLI program works

    Code
      files_to_snapshot %>% purrr::map_vec(function(filename) {
        stringr::str_replace(string = filename, pattern = "^/.*/16S", replacement = "./16S")
      }) %>% print()
    Output
       [1] "./16S/db_1/blast_seeds_output/Nitrospira.fasta"                                                  
       [2] "./16S/db_1/blast_seeds_output/Nitrospira_blast_seeds_summary_unique_taxonomic_rank_counts.csv"   
       [3] "./16S/db_1/blast_seeds_output/Nitrospira_taxonomy.txt"                                           
       [4] "./16S/db_1/blast_seeds_output/blastdbcmd_failed.csv"                                             
       [5] "./16S/db_1/blast_seeds_output/summary.csv"                                                       
       [6] "./16S/db_1/get_seeds_local/Nitrospira_filtered_get_seeds_local_output_with_taxonomy.csv"         
       [7] "./16S/db_1/get_seeds_local/Nitrospira_filtered_get_seeds_local_unique_taxonomic_rank_counts.csv" 
       [8] "./16S/db_1/get_seeds_local/Nitrospira_primers_selected_for_blastn.fasta"                         
       [9] "./16S/db_1/get_seeds_local/Nitrospira_unfiltered_get_seeds_local_output.csv"                     
      [10] "./16S/db_2/blast_seeds_output/Nitrospira.fasta"                                                  
      [11] "./16S/db_2/blast_seeds_output/Nitrospira_blast_seeds_summary_unique_taxonomic_rank_counts.csv"   
      [12] "./16S/db_2/blast_seeds_output/Nitrospira_taxonomy.txt"                                           
      [13] "./16S/db_2/blast_seeds_output/blastdbcmd_failed.csv"                                             
      [14] "./16S/db_2/blast_seeds_output/summary.csv"                                                       
      [15] "./16S/db_2/get_seeds_local/Nitrospira_filtered_get_seeds_local_output_with_taxonomy.csv"         
      [16] "./16S/db_2/get_seeds_local/Nitrospira_filtered_get_seeds_local_unique_taxonomic_rank_counts.csv" 
      [17] "./16S/db_2/get_seeds_local/Nitrospira_primers_selected_for_blastn.fasta"                         
      [18] "./16S/db_2/get_seeds_local/Nitrospira_unfiltered_get_seeds_local_output.csv"                     
      [19] "./16S/db_3/blast_seeds_output/Nitrospira.fasta"                                                  
      [20] "./16S/db_3/blast_seeds_output/Nitrospira_blast_seeds_summary_unique_taxonomic_rank_counts.csv"   
      [21] "./16S/db_3/blast_seeds_output/Nitrospira_taxonomy.txt"                                           
      [22] "./16S/db_3/blast_seeds_output/blastdbcmd_failed.csv"                                             
      [23] "./16S/db_3/blast_seeds_output/summary.csv"                                                       
      [24] "./16S/db_3/get_seeds_local/Nitrospira_filtered_get_seeds_local_output_with_taxonomy.csv"         
      [25] "./16S/db_3/get_seeds_local/Nitrospira_filtered_get_seeds_local_unique_taxonomic_rank_counts.csv" 
      [26] "./16S/db_3/get_seeds_local/Nitrospira_primers_selected_for_blastn.fasta"                         
      [27] "./16S/db_3/get_seeds_local/Nitrospira_unfiltered_get_seeds_local_output.csv"                     
      [28] "./16S/db_4/blast_seeds_save/blast_seeds_passed_filter.txt"                                       
      [29] "./16S/db_4/blast_seeds_save/blastdbcmd_failed.txt"                                               
      [30] "./16S/db_4/blast_seeds_save/num_rounds.txt"                                                      
      [31] "./16S/db_4/blast_seeds_save/output_table.txt"                                                    
      [32] "./16S/db_4/blast_seeds_save/too_many_ns.txt"                                                     
      [33] "./16S/db_4/blast_seeds_save/unsampled_indices.txt"                                               
      [34] "./16S/db_4/get_seeds_local/Nitrospira_primers_selected_for_blastn.fasta"                         
      [35] "./16S/db_4/get_seeds_local/Nitrospira_temp_blast_output.csv"                                     
      [36] "./16S/db_collated/blast_seeds_output/Nitrospira.fasta"                                           
      [37] "./16S/db_collated/blast_seeds_output/Nitrospira_taxonomy.txt"                                    
      [38] "./16S/db_collated/blast_seeds_output/summary.csv"                                                
      [39] "./16S/db_collated/derep_and_clean_db/Nitrospira_derep_and_clean.fasta"                           
      [40] "./16S/db_collated/derep_and_clean_db/Nitrospira_derep_and_clean_taxonomy.txt"                    
      [41] "./16S/db_collated/derep_and_clean_db/Nitrospira_derep_and_clean_unique_taxonomic_rank_counts.txt"
      [42] "./16S/db_collated/derep_and_clean_db/Sequences_with_lowest_common_taxonomic_path_agreement.csv"  
      [43] "./16S/db_collated/derep_and_clean_db/Sequences_with_mostly_NA_taxonomic_paths.csv"               
      [44] "./16S/db_collated/derep_and_clean_db/Sequences_with_multiple_taxonomic_paths.csv"                
      [45] "./16S/db_collated/derep_and_clean_db/Sequences_with_single_taxonomic_path.csv"                   
