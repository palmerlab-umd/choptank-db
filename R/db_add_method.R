db_add_method <- function(methodtypecv, methodcode, methodname, methoddescription){
  
  sql <- sprintf("INSERT INTO odm2.methods 
                 (methodtypecv, methodcode, methodname, methoddescription) 
                 VALUES
                 ('%s', '%s', '%s', '%s')", 
                 methodtypecv, methodcode, methodname, methoddescription)
  
  sql <- gsub("\n", "", sql)
  dbGetQuery(db, sql) 
  
}