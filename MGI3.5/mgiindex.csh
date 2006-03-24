#!/bin/csh -fx

#
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop index HMD_Homology_Marker.idx_Marker_fkey
go

drop index HMD_Homology_Marker.idx_Homology_fkey
go

quit

EOSQL

${newmgddbschema}/index/HMD_Homology_Marker_drop.object | tee -a ${LOG}
${newmgddbschema}/index/HMD_Homology_Marker_create.object | tee -a ${LOG}

date | tee -a  ${LOG}

