#!/bin/csh -f

#
# TR 8001/TIGR to DFCI
#
# Usage:  tigr.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update ACC_LogicalDB
set name = 'DFCI',
description = 'Dana Farber Cancer Institute'
where _LogicalDB_key = 35
go

update ACC_ActualDB
set name = 'DFCI',
url = 'http://compbio.dfci.harvard.edu/tgi/cgi-bin/tgi/tc_report.pl?tc=@@@@&species=mouse'
where _ActualDB_key = 43
go

update MGI_User
set login = 'dfci_seqload',
name = 'DFCI Sequence Load'
where _User_key = 1313
go

update MGI_User
set login = 'dfci_assocload',
name = 'DFCI Association Load'
where _User_key = 1426
go

update VOC_Term
set term = 'DFCI Mouse Gene Index',
abbreviation = 'DFCI Mouse Gene Index'
where _Term_key = 316381
go

EOSQL

date >> ${LOG}

