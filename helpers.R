get_site_names_like <- function(x, ...){
  agrep(pattern = x, samplingfeatures$samplingfeaturecode, ignore.case = TRUE, value = TRUE, ...)
}

check_samplingfeaturecodes <- function(new_codes){
  if(!exists("samplingfeatures")){stop("samplingfeatures data frame missing")}
  
  data.frame(new_codes = new_codes,
             in_db = new_codes %in% 
               samplingfeatures$samplingfeaturecode) %>%
    dplyr::filter(!in_db) %>% arrange(new_codes)  
}
