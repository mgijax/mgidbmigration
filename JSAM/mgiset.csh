#!/bin/csh -f

#
# Migration for MGI Set
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "MGI Set Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

/* Restricted Sequences */

insert into MGI_Set values(1002, 13, 'Restricted Sequences', 1300, 1300, getdate(), getdate())
go

select seq = identity(5), setKey = 1002, t._Term_key
into #members
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term in ('TIGR Mouse Gene Index', 'DoTS', 'SWISS-PROT', 'TrEMBL')
go

declare @memberKey integer
select @memberKey = max(_SetMember_key) + 1 from MGI_SetMember

insert into MGI_SetMember
select @memberKey + seq, setKey, _Term_key, seq, 1300, 1300, getdate(), getdate()
from #members
go

checkpoint
go

quit

EOSQL

date >> ${LOG}

