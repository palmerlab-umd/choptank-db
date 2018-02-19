# # insert soil measurements into database
# 
# library(uuid) # unique ids
# library(RPostgreSQL) # database
# library(knitr) # kable for table formatting
# library(readr) # read_csv
# library(DT) # data table formatting
# library(lubridate) # dates and times helpers
# source("/nfs/palmer-group-data/Choptank/choptank-db/db-functions.R")
# # read in soil moisture data
# sm <- read_csv("/nfs/khondula-data/Delmarva/data/soil_moisture/Field_measurements - SOIL_field_measurements.csv")
# 
# 
# 
# 
# # date, time, site, location, and 3 measurements: vol water content, soil EC (microsiemens per cm), and soil temp (deg C)
# 
# 
# # add new method for soil moisture
# dbGetQuery(db, "SELECT * FROM odm2.methods")
# 
# dbGetQuery(db, "DELETE from odm2.methods WHERE methodcode = 'VWC'")
# 
# db_add_new_method(methodname = "TDR soil moisture",
#                   methodtypecv = "instrumentDeployment",
#                   methodcode = "TDR",
#                   methoddescription = "Volumetric water content measurement using TDR probe")
# db_get_methods()
# # add new variable for soil moisture
# db_add_new_variable(variabletypecv = "Soil",
#                     variablecode = "volumetricWaterContent",
#                     variablenamecv = "Volumetric water content",
#                     variabledefinition = "Volume of liquid water relative to bulk volume. Used for example to quantify soil moisture")
# db_add_new_variable(variabletypecv = "Soil",
#                     variablecode = "temperature",
#                     variablenamecv = "Temperature",
#                     variabledefinition = "Temperature")
# db_add_new_variable(variabletypecv = "Soil",
#                     variablecode = "bulkElectricalConductivity",
#                     variablenamecv = "Bulk electrical conductivity",
#                     variabledefinition = "Bulk electrical conductivity of a medium measured using a sensor such as time domain reflectometry (TDR), as a raw sensor response in the measurement of a quantity like soil moisture.")
# 
# dbGetQuery(db, "SELECT * FROM odm2.variables")
# 
# # see if units are in units table
# dbGetQuery(db, "SELECT * FROM odm2.units WHERE unitsname = 'Percent'")
# dbGetQuery(db, "SELECT * FROM odm2.units WHERE unitsname = 'Degree Celcius'")
# dbGetQuery(db, "SELECT * FROM odm2.units WHERE unitsabbreviation = 'mS/cm'")
# 
# # insert new units
# 
# sql <- "INSERT INTO odm2.units (unitstypecv, unitsabbreviation, unitsname) VALUES ('Electrical conductivity', 'mS/cm', 'Millisiemen per Centimeter')"
# sql <- "DELETE FROM odm2.units WHERE unitsid = '1159'"
# dbGetQuery(db, sql)
# 
# 
# # percent is unitsid 522
# # degC is 1158
# # mS/cm is 581
# 
# 
# # format datetime in the dataset
# 
# sm$date <- strptime(sm$Date, 
#                           format = "%B %d, %Y",
#                           tz = "")
# sm$datetime <- strptime(paste(sm$Date, sm$Time),
#          format = "%B %d, %Y %H:%M:%S",
#          tz = "")
# 
# utcoffset <- format(Sys.time(), "%z")
# utcoffset <- as.integer(substr(utcoffset, 1,3))
# 
# sm$utcoffset <- utcoffset
# 
# # after making sure all the proper metadata are in the database
# 
# 
# db_get_variables()
# 
# methodcode = "TDR"
# variablecode = "volumetricWaterContent"
# unitsname = "Percent"
# sampledmediumcv = "soil"
# 
# resulttypecv = "measurement"
# censorcodecv = "notCensored"
# qualitycodecv = "unknown"
# aggregationstatisticcv = "sporadic"
# timeaggregationinterval = 1 # assume 1 minute
# timeaggregationintervalunitsid = 1157 # minute
# processlinglevelid = 1
# valuecount = 1
# actiontypecv = "instrumentDeployment"

# make new action using method TDR, action type instrumentDeployment	
# link action and sampling feature in feature action table
# make a new result in the results table associated with the feature action
# insert measurement results and measurement result values, associated with the result id

# for each row in SM data frame:
## make a new action using method "TDR"
## get action ID, and identify sampling feature ID --> insert new row into FA table

## make 3 results linked to that feature action ID (one for each variable)
## for each result, make a measurements results entry
## then a measurement results values entry

sql_blanks <- 'WITH 
newact AS (
INSERT INTO odm2.actions (
  actiontypecv, 
  methodid, 
  begindatetime,
  begindatetimeutcoffset)
VALUES (
  \'%s\', 
  (SELECT methodid FROM odm2.methods WHERE methodcode = \'%s\'), 
  \'%s\', 
  \'%s\')
RETURNING actionid),

newfa AS (
INSERT into odm2.featureactions (
  samplingfeatureid, 
  actionid)
VALUES (
  (SELECT samplingfeatureid FROM odm2.samplingfeatures WHERE samplingfeaturecode = \'%s\'),
  (SELECT newact.actionid FROM newact))
RETURNING featureactionid),

newresult AS (
INSERT INTO odm2.results (
  featureactionid,
  resultuuid,
  resulttypecv,
  variableid,
  unitsid,
  processinglevelid,
  sampledmediumcv, 
  valuecount)
VALUES (
  (SELECT newfa.featureactionid FROM newfa),
  \'%s\',
  \'%s\',
  (SELECT variableid FROM odm2.variables WHERE variablecode = \'volumetricWaterContent\'),
  (SELECT unitsid FROM odm2.units WHERE unitsname = \'Percent\'),
  \'%s\',
  \'%s\',
  \'%s\'),
(
  (SELECT newfa.featureactionid FROM newfa),
  \'%s\',
  \'%s\',
  (SELECT variableid FROM odm2.variables WHERE variablecode = \'bulkElectricalConductivity\'),
  (SELECT unitsid FROM odm2.units WHERE unitsname = \'Millisiemen per Centimeter\'),
  \'%s\',
  \'%s\',
  \'%s\'),
(
  (SELECT newfa.featureactionid FROM newfa),
  \'%s\',
  \'%s\',
  (SELECT variableid FROM odm2.variables WHERE variablecode = \'temperature\'),
  (SELECT unitsid FROM odm2.units WHERE unitsname = \'Degree Celcius\'),
  \'%s\',
  \'%s\',
  \'%s\')
RETURNING resultid, variableid),

newmr1 AS (
INSERT INTO odm2.measurementresults (
  resultid,
  censorcodecv,
  qualitycodecv,
  aggregationstatisticcv,
  timeaggregationinterval,
  timeaggregationintervalunitsid)
VALUES (
  (SELECT newresult.resultid FROM newresult WHERE variableid = (SELECT variableid FROM odm2.variables WHERE variablecode = \'volumetricWaterContent\')),
  \'%s\',
  \'%s\', 
  \'%s\', 
  \'%s\', 
  \'%s\')),

newmrv1 AS (
INSERT INTO odm2.measurementresultvalues (
  resultid,
  datavalue,
  valuedatetime,
  valuedatetimeutcoffset)
VALUES (
  (SELECT newresult.resultid FROM newresult WHERE variableid = (SELECT variableid FROM odm2.variables WHERE variablecode = \'volumetricWaterContent\')),
  \'%s\',
  \'%s\', 
  \'%s\')),

newmr2 AS (
INSERT INTO odm2.measurementresults (
  resultid,
  censorcodecv,
  qualitycodecv,
  aggregationstatisticcv,
  timeaggregationinterval,
  timeaggregationintervalunitsid)
VALUES (
  (SELECT newresult.resultid FROM newresult WHERE variableid = (SELECT variableid FROM odm2.variables WHERE variablecode = \'bulkElectricalConductivity\')),
  \'%s\',
  \'%s\', 
  \'%s\', 
  \'%s\', 
  \'%s\')),

newmrv2 AS (
INSERT INTO odm2.measurementresultvalues (
  resultid,
  datavalue,
  valuedatetime,
  valuedatetimeutcoffset)
VALUES (
  (SELECT newresult.resultid FROM newresult WHERE variableid = (SELECT variableid FROM odm2.variables WHERE variablecode = \'bulkElectricalConductivity\')),
  \'%s\',
  \'%s\', 
  \'%s\')),

newmr3 AS (
INSERT INTO odm2.measurementresults (
  resultid,
  censorcodecv,
  qualitycodecv,
  aggregationstatisticcv,
  timeaggregationinterval,
  timeaggregationintervalunitsid)
VALUES (
  (SELECT newresult.resultid FROM newresult WHERE variableid = (SELECT variableid FROM odm2.variables WHERE variablecode = \'temperature\')),
  \'%s\',
  \'%s\', 
  \'%s\', 
  \'%s\', 
  \'%s\'))

INSERT INTO odm2.measurementresultvalues (
  resultid,
  datavalue,
  valuedatetime,
  valuedatetimeutcoffset)
VALUES (
  (SELECT newresult.resultid FROM newresult WHERE variableid = (SELECT variableid FROM odm2.variables WHERE variablecode = \'temperature\')),
  \'%s\',
  \'%s\', 
  \'%s\')

'
  

sql <- sprintf(sql_blanks,
               actiontypecv, methodcode, sm$datetime[1], utcoffset,
               paste("KLH", paste(sm$Site, sm$Location)[1]),
               # results
               UUIDgenerate(), resulttypecv, processlinglevelid, sampledmediumcv, valuecount,
               UUIDgenerate(), resulttypecv, processlinglevelid, sampledmediumcv, valuecount,
               UUIDgenerate(), resulttypecv, processlinglevelid, sampledmediumcv, valuecount,
              # Measurement results
              censorcodecv, qualitycodecv, aggregationstatisticcv, timeaggregationinterval, timeaggregationintervalunitsid,
              sm$VWC_percent[1], sm$datetime[1], utcoffset,
              censorcodecv, qualitycodecv, aggregationstatisticcv, timeaggregationinterval, timeaggregationintervalunitsid,
              sm$soil_EC_mscm[1], sm$datetime[1], utcoffset,
               censorcodecv, qualitycodecv, aggregationstatisticcv, timeaggregationinterval, timeaggregationintervalunitsid,
              sm$soil_temp_C[1], sm$datetime[1], utcoffset
               )
  
# insert_methaneDissolved_results <- function(x){
#   # create SQL statement
#   sql <- sprintf(sql_blanks,
#                  UUIDgenerate(), 'specimen', ch4_data$Exetainer_ID[x],
#                  ch4_data$sampledescription[x], 
#                  'isChildOf', ch4_data$Site[x],
#                  'specimenCollection', methodcode, as.character(ch4_data$date[x]),
#                  utcoffset, 
#                  UUIDgenerate(), 'measurement', variablecode, unitsname,
#                  '3', # processing level 2 id is 3
#                  sampledmedium, '1',
#                  censorcodecv, qualitycodecv, aggregationstatisticcv,
#                  timeaggregationinterval, timeaggregationintervalunitsid,
#                  ch4_data$orig_liq_conc[x], as.character(ch4_data$date[x]), utcoffset)
#   # remove line endings
#   sql <- gsub("\n", "", sql)
#   # insert into database
#   dbGetQuery(db, sql)
# }

  sql <- gsub("\n", "", sql)
  write(sql, "sql.txt")
  
  # insert into database
  dbGetQuery(db, sql)
  
  dbGetQuery(db, "SELECT * FROM odm2.measurementresultvalues")

# dbGetQuery(db, "SELECT * FROM odm2.samplingfeatures")

# head(sm)
# 
# new_actions <- data.frame("actiontypecv" = "instrumentDeployment",
#                           "methodid" = methodcode,
#                           "begindatetime" = as.character(sm$date),
#                           "begindatetimeutcoffset" = sm$utcoffset,
#                           stringsAsFactors = FALSE)
