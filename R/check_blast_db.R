#' Check BLAST DB exists
#' 
#' The path of a BLAST DB should be the directory path + the name of the DB e.g
#' `path/to/blast-db` + `myDB` = `path/to/blast-db/myDB`. Usually the files in the
#' BLAST DB start with the name of the the DB e.g `myDB.ndb`, `myDB.ntf` ...
#'  
#' @param path path to BLAST DB
#' @param ncbi_bin is the path to blast+ tools if not in the user's path.
#'        Specify only if blastn and blastdbcmd  are not in your path.
#'        The default is ncbi_bin = NULL - if not specified in path do the
#'        following: ncbi_bin = "/my/local/ncbi-blast-2.10.1+/bin/".
#' 
#' @return Nothing or an error
check_blast_db <- function(path, ncbi_bin = NULL){

   if (!is.null(ncbi_bin)){
    blastdbcmd <- file.path(ncbi_bin, 'blastdbcmd')
  } else {
    blastdbcmd = 'blastdbcmd'
  }

  # We want to catch the output from blastdbcmd, and suppress warning if it failed
  result <- 
    suppressWarnings(
      system2(blastdbcmd, args = c('-db', path, '-info'), stdout = TRUE, stderr = TRUE)
    )

  has_error <- grepl('BLAST Database error', result[1])
  
  if (has_error){
    stop('The BLAST DB could not be found. Please revise the path given. \n', result)
  }
  
  invisible(NULL)
  
}
