#!/bin/csh -f

#
# Migration for TR11248
# Cre/GXD_Expression
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/scrum-dog/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv s $1

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0

use ${MGD_DBNAME}
go

select a.accID, e.isForGXD, e.isRecombinase
from GXD_Expression e, ACC_Accession a
where e._Assay_key = a._Object_key
and a._MGIType_key = 8
and a.accID = "${s}"
go

EOSQL

