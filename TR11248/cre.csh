#!/bin/csh -fx

#
# Migration for TR11248
# Cre/GXD_Expression
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

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(*) from GXD_Expression where isForGXD = 1 and isRecombinase = 0
go
select count(*) from GXD_Expression where isForGXD = 0 and isRecombinase = 1
go
select count(*) from GXD_Expression where isForGXD = 0 and isRecombinase = 1 and _AssayType_key = 10
go
select count(*) from GXD_Expression where isForGXD = 0 and isRecombinase = 1 and _AssayType_key = 11
go
select count(*) from GXD_Expression where isForGXD = 1 and isRecombinase = 0 and _AssayType_key = 9
go
select count(*) from GXD_Expression where isForGXD = 1 and isRecombinase = 1 and _AssayType_key = 9
go
select count(*) from GXD_Expression where isForGXD = 1 and isRecombinase = 1 and _AssayType_key != 9
go

select distinct a.accID as 'isForGXD=0/isRecombinase=1'
from GXD_Expression e, ACC_Accession a where e.isForGXD = 0 and e.isRecombinase = 1
and e._Assay_key = a._Object_key
and a._MGIType_key = 8
go

select distinct a.accID as 'isForGXD=1/isRecombinase=0/9'
from GXD_Expression e, ACC_Accession a where e.isForGXD = 1 and e.isRecombinase = 0 and e._AssayType_key = 9
and e._Assay_key = a._Object_key
and a._MGIType_key = 8
go

select distinct a.accID as 'isForGXD=1/isRecombinase=1'
from GXD_Expression e, ACC_Accession a where e.isForGXD = 1 and e.isRecombinase = 1 and e._AssayType_key = 9
and e._Assay_key = a._Object_key
and a._MGIType_key = 8
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

