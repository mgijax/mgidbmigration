#!/bin/csh -fx

#
# convert 
#	GXD_GelLaneStructure
#	GXD_ISResultStructure
#
# from:
# 	_Strucuture_key
#
# to:
# 	_EMAPA_Term_key
# 	_Stage_key
#
# using:
# 	MGI_EMAPS_Mapping
# 	VOC_Term_EMAPA
# 	VOC_Term_EMAPS
# 	ACC_Accession
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#${PG_MGD_DBSCHEMADIR}/table/GXD_GelLaneStructure_truncate.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_drop.object | tee -a $LOG || exit 1

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

select count(*) from GXD_GelLaneStructure_old;
select count(*) from GXD_GelLaneStructure;
select count(*) from GXD_ISResultStructure_old;
select count(*) from GXD_ISResultStructure;

-- query to help with comparison testing
SELECT s._Stage_key, sn.structure, emapat.term
FROM MGI_EMAPS_Mapping m, 
	ACC_Accession a1, ACC_Accession a2, VOC_Term emapst, VOC_Term_EMAPS emaps,
	VOC_Term_EMAPA emapa, VOC_Term emapat,
	GXD_Structure s, GXD_StructureName sn
where m.accID = a1.accID
and a1._MGIType_key = 38
and a1._Object_key = s._Structure_key
and s._StructureName_key = sn._StructureName_key
and m.emapsID = a2.accID
and a2._MGIType_key = 13
and a2._Object_key = emapst._Term_key
and emapst._Term_key = emaps._Term_key
and emaps._emapa_term_key = emapa._Term_key
and emapa._Term_key = emapat._Term_key
order by s._Stage_key, sn.structure
;

INSERT INTO GXD_GelLaneStructure
SELECT g._gellane_key, emapa._Term_key, emaps._Stage_key, g.creation_date, g.modification_date
FROM MGI_EMAPS_Mapping m, 
	ACC_Accession a1, ACC_Accession a2, VOC_Term emapst, VOC_Term_EMAPS emaps,
	VOC_Term_EMAPA emapa, VOC_Term emapat,
	GXD_GelLaneStructure_old g
where m.accID = a1.accID
and a1._MGIType_key = 38
and a1._Object_key = g._Structure_key
and m.emapsID = a2.accID
and a2._MGIType_key = 13
and a2._Object_key = emapst._Term_key
and emapst._Term_key = emaps._Term_key
and emaps._emapa_term_key = emapa._Term_key
and emapa._Term_key = emapat._Term_key
;

INSERT INTO GXD_ISResultStructure
SELECT g._result_key, emapa._Term_key, emaps._Stage_key, g.creation_date, g.modification_date
FROM MGI_EMAPS_Mapping m, 
	ACC_Accession a1, ACC_Accession a2, VOC_Term emapst, VOC_Term_EMAPS emaps,
	VOC_Term_EMAPA emapa, VOC_Term emapat,
	GXD_ISResultStructure_old g
where m.accID = a1.accID
and a1._MGIType_key = 38
and a1._Object_key = g._Structure_key
and m.emapsID = a2.accID
and a2._MGIType_key = 13
and a2._Object_key = emapst._Term_key
and emapst._Term_key = emaps._Term_key
and emaps._emapa_term_key = emapa._Term_key
and emapa._Term_key = emapat._Term_key
;

select count(*) from GXD_GelLaneStructure_old;
select count(*) from GXD_GelLaneStructure;
select count(*) from GXD_ISResultStructure_old;
select count(*) from GXD_ISResultStructure;

DROP TABLE MGI_EMAPS_Mapping;
DROP TABLE GXD_GelLaneStructure_old;
DROP TABLE GXD_ISResultStructure_old;
DROP TABLE GXD_Structure;
DROP TABLE GXD_StructureName;
DROP FROM ACC_MGITYPE WHERE _MGIType_key = 38;

EOSQL
date | tee -a ${LOG}

#${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
