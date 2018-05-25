# add sampling group annotations

# site_groups_data

# dbGetQuery(db, "SELECT annotationid, annotationtext FROM odm2.annotations WHERE annotationtext = 'IRIS tubes'")

# for each row in site groups table

# dbListFields(db, c("odm2", "samplingfeatureannotations"))

# get the id of the sampling feature from the samplingfeatures table
# get the annotation id from the annotations table

insert_samplingfeature_annotations <- function(x){
  sql <- 'INSERT INTO odm2.samplingfeatureannotations
        (samplingfeatureid, annotationid)
  VALUES(
  (SELECT samplingfeatureid FROM odm2.samplingfeatures WHERE samplingfeaturecode = \'%s\'),
  (SELECT annotationid FROM odm2.annotations WHERE annotationtext = \'%s\')
  )
  '
  sql <- sprintf(sql, new_annotations$samplingfeaturecode[x], new_annotations$annotation[x])
  sql <- gsub("\n", "", sql)
  
  dbGetQuery(db, sql)
  
}

# sapply(30:nrow(site_groups_data), function(x) insert_samplingfeature_annotations(x))
