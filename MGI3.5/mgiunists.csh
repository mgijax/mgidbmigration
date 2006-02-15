#!/bin/csh -f

#
# Process UniSTS data
#
# Usage:  mgiunists.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

alter table MGI_Coord_Feature modify strand char(1) null
go

quit

EOSQL

date >> ${LOG}

