#!/bin/csh -f

#
# Migration for: Voc Assocations
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Voc Associations Migration...' | tee -a ${LOG}

${newmgddbschema}/table/MGI_VocAssociation_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_VocAssociation_create.object | tee -a ${LOG}
${newmgddbschema}/index/MGI_VocAssociation_create.object | tee -a ${LOG}
${newmgddbschema}/default/MGI_VocAssociation_bind.object | tee -a ${LOG}

${newmgddbschema}/table/MGI_VocAssociationType_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_VocAssociationType_create.object | tee -a ${LOG}
${newmgddbschema}/index/MGI_VocAssociationType_create.object | tee -a ${LOG}
${newmgddbschema}/default/MGI_VocAssociationType_bind.object | tee -a ${LOG}
${newmgddbschema}/trigger/MGI_VocAssociationType_create.object | tee -a ${LOG}

# keys/permissions will be handled in reconfig phase 

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

end

EOSQL

date >> ${LOG}

