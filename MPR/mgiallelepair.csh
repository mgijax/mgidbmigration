#!/bin/csh -f

#
# Migration for: Allele Pair
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Allele Pair Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename GXD_AllelePair, GXD_AllelePair_Old
go

end

EOSQL

${newmgddbschema}/table/GXD_AllelePair_create.object | tee -a ${LOG}
${newmgddbschema}/default/GXD_AllelePair_bind.object | tee -a ${LOG}

# keys/permissions will be handled in reconfig phase 

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

end

EOSQL

${newmgddbschema}/index/GXD_AllelePair_create.object | tee -a ${LOG}

date >> ${LOG}

