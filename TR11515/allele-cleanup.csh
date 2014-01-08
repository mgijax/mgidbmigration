#!/bin/csh -f

#
# Migration for TR11515
#
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

select am._Marker_key, a.*, u1.login, u2.login
from ALL_Allele a, ALL_Marker_Assoc am, MGI_User u1, MGI_User u2
where a._Marker_key is null
and a._CreatedBy_key = u1._User_key
and a._ModifiedBy_key = u2._User_key
and a._Allele_key = am._Allele_key
go

select a._Allele_key, am._Marker_key
into #toUpdate
from ALL_Allele a, ALL_Marker_Assoc am
where a._Marker_key is null
and a._Allele_key = am._Allele_key
go

update ALL_Allele
set a._Marker_key = t._Marker_key
from ALL_Allele a, #toUpdate t
where a._Allele_key = t._Allele_key
go

select am._Marker_key, a.*, u1.login, u2.login
from ALL_Allele a, ALL_Marker_Assoc am, MGI_User u1, MGI_User u2
where a._Marker_key is null
and a._CreatedBy_key = u1._User_key
and a._ModifiedBy_key = u2._User_key
and a._Allele_key = am._Allele_key
go

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

