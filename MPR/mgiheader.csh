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

declare @labelKey integer
select @labelKey = _Label_key from DAG_Label where label = 'Header'

select a._Object_key, d._Node_key, labelKey = @labelKey
into #headers
from ACC_Accession a, VOC_Term t, VOC_VocabDAG vd, DAG_Node d
where a.accID in ('MP:0005375', 'MP:0005386', 'MP:0005385', 'MP:0005384', 'MP:0005383',
'MP:0005382', 'MP:0005381', 'MP:0005380', 'MP:0005379', 'MP:0005378', 'MP:0005377',
'MP:0005397', 'MP:0005376', 'MP:0005387', 'MP:0005374', 'MP:0005373', 'MP:0005372',
'MP:0005371', 'MP:0005370', 'MP:0005369', 'MP:0002873', 'MP:0005395', 'MP:0005368',
'MP:0005367', 'MP:0005389', 'MP:0005388', 'MP:0005390', 'MP:0005393', 'MP:0005394',
'MP:0005392', 'MP:0002006', 'MP:0005391')
and a.preferred = 1
and a._Object_key = t._Term_key
and t._Vocab_key = vd._Vocab_key
and vd._DAG_key = d._DAG_key
and t._Term_key = d._Object_key
go

update DAG_Node
set _Label_key = labelKey
from #headers h, DAG_Node d
where h._Node_key = d._Node_key
go

end

EOSQL

date >> ${LOG}

