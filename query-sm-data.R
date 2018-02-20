# connect to database first 

# structure of the query:
# SELECT all relevant columns, prefixed by the alias for the table it is from
# FROM list all the tables included and their aliases
# WHERE... AND... for all conditions and links between tables

# example query for all soil measurements from soil chamber QB SC E
sql <- "SELECT mrv.datavalue, mrv.valuedatetime, sf.samplingfeaturecode, r.featureactionid, v.variablecode, u.unitsname
 FROM odm2.measurementresultvalues mrv, odm2.results r, odm2.variables v, odm2.units u, odm2.samplingfeatures sf, odm2.featureactions fa
 WHERE r.variableid = v.variableid 
 AND r.featureactionid = fa.featureactionid
 AND fa.samplingfeatureid = sf.samplingfeatureid
 AND r.unitsid = u.unitsid
 AND mrv.resultid = r.resultid 
 AND r.sampledmediumcv = 'soil'
 AND sf.samplingfeaturecode = 'KLH QB SC E'"

sql <- gsub("\n", "", sql)
dbGetQuery(db, sql)


# function to query soil data from a given chamber site

get_sm_data <- function(sitecode = "KLH QB SC B"){
  
  sql <- paste0("SELECT mrv.datavalue, mrv.valuedatetime, sf.samplingfeaturecode, r.featureactionid, v.variablecode, u.unitsname
 FROM odm2.measurementresultvalues mrv, odm2.results r, odm2.variables v, odm2.units u, odm2.samplingfeatures sf, odm2.featureactions fa
 WHERE r.variableid = v.variableid 
 AND r.featureactionid = fa.featureactionid
 AND fa.samplingfeatureid = sf.samplingfeatureid
 AND r.unitsid = u.unitsid
 AND mrv.resultid = r.resultid 
 AND r.sampledmediumcv = 'soil'
 AND sf.samplingfeaturecode = '", sitecode, "'")
  
  sql <- gsub("\n", "", sql)
  dbGetQuery(db, sql)
}

# probably only works for one site code at a time 
# apply over a vector of sitecodes then rbind to get data from multiple sites
get_sm_data(sitecode = "KLH QB SC C")
