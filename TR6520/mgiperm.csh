#!/bin/csh -f

#
# Migration for: Permissions (TR 6343)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Permission Migration...' | tee -a ${LOG}

${newmgddbschema}/table/MGI_RoleTask_create.object | tee -a ${LOG}
${newmgddbschema}/table/MGI_UserRole_create.object | tee -a ${LOG}

${newmgddbschema}/default/MGI_RoleTask_bind.object | tee -a ${LOG}
${newmgddbschema}/default/MGI_UserRole_bind.object | tee -a ${LOG}

${newmgddbschema}/key/MGI_RoleTask_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_UserRole_create.object | tee -a ${LOG}

${newmgddbschema}/key/MGI_User_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_create.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_drop.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_create.object | tee -a ${LOG}

${newmgddbschema}/index/MGI_RoleTask_create.object | tee -a ${LOG}
${newmgddbschema}/index/MGI_RoleTask_create.object | tee -a ${LOG}
${newmgddbschema}/index/MGI_UserRole_create.object | tee -a ${LOG}
${newmgddbschema}/index/MGI_UserRole_create.object | tee -a ${LOG}
${newmgddbschema}/index/MGI_UserTask_create.object | tee -a ${LOG}

${newmgddbschema}/procedure/PRB_processAnonymousSource_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/PRB_processAnonymousSource_create.object | tee -a ${LOG}

${newmgddbschema}/view/MGI_UserRole_View_create.object | tee -a ${LOG}

${newmgddbperms}/curatorial/table/MGI_UserRole_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/PRB_processAnonymousSource_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_UserRole_View_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_UserTask_View_grant.object | tee -a ${LOG}

./roletaskload.csh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

end

EOSQL

date >> ${LOG}

