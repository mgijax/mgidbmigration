#!/bin/csh -f

#
# Migration for: JAX Strain (TR 5565)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Strain Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

end

EOSQL

${newmgddbschema}/table/PRB_Strain_Genotype_create.object | tee -a ${LOG}
${newmgddbschema}/index/PRB_Strain_Genotype_create.object | tee -a ${LOG}

${newmgddbschema}/key/PRB_Strain_Genotype_create.object | tee -a ${LOG}
${newmgddbschema}/key/GXD_Genotype_drop.object | tee -a ${LOG}
${newmgddbschema}/key/GXD_Genotype_create.object | tee -a ${LOG}
${newmgddbschema}/key/PRB_Strain_drop.object | tee -a ${LOG}
${newmgddbschema}/key/PRB_Strain_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_create.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_drop.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_create.object | tee -a ${LOG}

${newmgddbschema}/view/MGI_Reference_Strain_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_RefType_Strain_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/PRB_Strain_Genotype_View_create.object | tee -a ${LOG}

${newmgddbperms}/public/table/PRB_Strain_Genotype_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_Reference_Strain_View_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_RefType_Strain_View_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/PRB_Strain_Genotype_View_grant.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

declare @key integer
select @key = max(_RefAssocType_key) + 1 from MGI_RefAssocType

insert into MGI_RefAssocType
values (@key, 10, 'Selected', 0, 1000, 1000, getdate(), getdate())

insert into MGI_RefAssocType
values (@key + 1, 10, 'Additional', 0, 1000, 1000, getdate(), getdate())

go

end

EOSQL

date >> ${LOG}

