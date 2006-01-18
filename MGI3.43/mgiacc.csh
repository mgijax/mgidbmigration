#!/bin/csh -f

#
# Usage:  mgiacc.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

alter table ACC_Accession modify prefixPart varchar(30) null
go

alter table ACC_AccessionMax modify prefixPart varchar(30) not null
go

quit

EOSQL

date >> ${LOG}

