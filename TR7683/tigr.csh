#!/bin/csh -f

#
# TR 8001/TIGR to DFCI
#
# Usage:  tigr.csh
#
# This finishes up the back-end changes for the TIGR to DFCI switch
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update VOC_Term
set term = 'DFCI Mouse Gene Index',
abbreviation = 'DFCI Mouse Gene Index'
where _Term_key = 316381
go

EOSQL

date >> ${LOG}

