#!/bin/csh -f

#
# Migration for: Headers
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Header Migration...' | tee -a ${LOG}

${newmgddbschema}/table/VOC_AnnotHeader_create.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_AnnotHeader_create.object | tee -a ${LOG}
${newmgddbschema}/index/VOC_AnnotHeader_create.object | tee -a ${LOG}
${newmgddbschema}/default/VOC_AnnotHeader_bind.object | tee -a ${LOG}

# keys/permissions will be handled in reconfig phase 

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

declare @labelKey integer
select @labelKey = max(_Label_key + 1) from DAG_Label
insert into DAG_Label values(@labelKey, 'Header', getdate(), getdate())
go

end

EOSQL

date >> ${LOG}

