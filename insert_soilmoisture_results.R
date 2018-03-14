
  
insert_soilmoisture_results <- function(x){
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
    # create SQL statement
    sql <- sprintf(sql_blanks,
                   "instrumentDeployment", "TDR", sm$datetime[x], sm$utcoffset[x],
                   sm$samplingfeaturecode[x],
                   # results
                   UUIDgenerate(), "measurement", 1, "soil", 1,
                   UUIDgenerate(), "measurement", 1, "soil", 1,
                   UUIDgenerate(), "measurement", 1, "soil", 1,
                   # Measurement results
                   "notCensored", "unknown", "sporadic", 1, 1157,
                   sm$VWC_percent[x], sm$datetime[x], sm$utcoffset[x],
                   "notCensored", "unknown", "sporadic", 1, 1157,
                   sm$soil_EC_mscm[x], sm$datetime[x], sm$utcoffset[x],
                   "notCensored", "unknown", "sporadic", 1, 1157,
                   sm$soil_temp_C[x], sm$datetime[x], sm$utcoffset[x]
    )  # remove line endings
    sql <- gsub("\n", "", sql)
    # insert into database
    dbGetQuery(db, sql)
  }