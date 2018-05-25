
# insert measurements for soil moisture from new_measurements dataframe
# insert new action using method = soilmoistureTDR
# RETURNING actionid
# insert new feature action with new actionid
# RETURNING featureactionid
# insert 3 new results with new featureactionid
# insert measurement results for volumetric water content
# insert measurement result values for volumetric water content
# insert measurement results for soil temp
# insert measurement result values for soil temp
# insert measurement results for soil conductivity
# insert measurement result values for soil conductity

db_insert_measurements_sm <- function(x){
  
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
    (SELECT unitsid FROM odm2.units WHERE unitsname = \'Degree Celsius\'),
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
  # create SQL statement
  sql <- sprintf(sql_blanks,
                 actiontypecv, "soilmoistureTDR", 
                 new_measurements$datetime[x], 
                 utcoffset,
                 new_measurements$samplingfeaturecode[x],
                 # results
                 UUIDgenerate(), resulttypecv, 1, sampledmediumcv, 1,
                 UUIDgenerate(), resulttypecv, 1, sampledmediumcv, 1,
                 UUIDgenerate(), resulttypecv, 1, sampledmediumcv, 1,
                 # Measurement results
                 censorcodecv, qualitycodecv, aggregationstatisticcv, timeaggregationinterval, timeaggregationintervalunitsid,
                 new_measurements$VWC_percent[x], new_measurements$datetime[x], utcoffset,
                 censorcodecv, qualitycodecv, aggregationstatisticcv, timeaggregationinterval, timeaggregationintervalunitsid,
                 new_measurements$soil_EC_mscm[x], new_measurements$datetime[x], utcoffset,
                 censorcodecv, qualitycodecv, aggregationstatisticcv, timeaggregationinterval, timeaggregationintervalunitsid,
                 new_measurements$soil_temp_C[x], new_measurements$datetime[x], utcoffset
  )  # remove line endings
  sql <- gsub("\n", "", sql)
  # insert into database
  dbGetQuery(db, sql)
}
