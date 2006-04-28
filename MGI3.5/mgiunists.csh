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

use ${MGD_DBNAME}
go

alter table MAP_Coord_Feature modify strand char(1) null
go

quit

EOSQL

# load coordinates
# must be done *after* the java libraries are re-built
#${UNISTSLOAD} | tee -a ${LOG}

date >> ${LOG}

