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

${newmgddbschema}/view/MGI_RoleTask_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_UserRole_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_UserTask_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/VOC_Term_UserRole_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/VOC_Term_UserTask_View_create.object | tee -a ${LOG}

${newmgddbschema}/procedure/PRB_processAnonymousSource_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/PRB_processAnonymousSource_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_checkUserRole_create.object.object | tee -a ${LOG}
${newmgddbschema}/procedure/ACC_drop.logical | tee -a ${LOG}
${newmgddbschema}/procedure/ACC_create.logical | tee -a ${LOG}

${newmgddbperms}/curatorial/table/ALL_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/GXD_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/HMD_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/MGI_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/MRK_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/NOM_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/PRB_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/VOC_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/ALL_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/GXD_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/HMD_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/MGI_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/MRK_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/NOM_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/PRB_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/table/VOC_revoke.logical | tee -a ${LOG}

${newmgddbperms}/curatorial/table/ALL_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/GXD_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/HMD_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/MGI_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/MRK_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/NOM_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/PRB_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/VOC_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/ALL_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/GXD_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/HMD_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/MGI_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/MRK_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/NOM_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/PRB_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/VOC_grant.logical | tee -a ${LOG}

${newmgddbperms}/public/procedure/ACC_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/procedure/MRK_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/procedure/NOM_revoke.logical | tee -a ${LOG}
${newmgddbperms}/public/procedure/PRB_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ACC_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/MRK_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/NOM_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/PRB_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/VOC_revoke.logical | tee -a ${LOG}

${newmgddbperms}/public/procedure/ACC_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/procedure/MRK_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/procedure/NOM_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/procedure/PRB_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ACC_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/MRK_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/NOM_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/PRB_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/VOC_grant.logical | tee -a ${LOG}

${newmgddbperms}/public/procedure/MGI_checkUserRole_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/view/VOC_grant.logical | tee -a ${LOG}

${newmgddbschema}/trigger/ACC_drop.logical | tee -a ${LOG}
${newmgddbschema}/trigger/ACC_create.logical | tee -a ${LOG}
${newmgddbschema}/trigger/ALL_drop.logical | tee -a ${LOG}
${newmgddbschema}/trigger/ALL_create.logical | tee -a ${LOG}
${newmgddbschema}/trigger/MRK_Notes_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/MRK_Notes_create.object | tee -a ${LOG}

./roletaskload.csh | tee -a ${LOG}
./userroleload.csh | tee -a ${LOG}

date >> ${LOG}

