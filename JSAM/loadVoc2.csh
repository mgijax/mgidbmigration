#!/bin/csh -f

#
# Load VOC vocabularies
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "Vocabulary Migration..." | tee -a ${LOG}
 
${NEWVOCLOAD} `pwd`/provider.config >>& ${LOG}

date >> ${LOG}
exit 0

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

select seqNum = identity(10), t._Term_key, synonym = "RefSeq (RNA, polypeptide)"
into #toadd
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "RefSeq"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ:Rodent (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ:Rodent"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ:Patent (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ:Patent"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ:HTC (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ:HTC"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ:EST (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ:EST"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ:HTG (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ:HTG"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ:STS (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ:STS"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ:GSS (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ:GSS"

union
select seqNum = identity(10), t._Term_key, synonym = "GenBank/EMBL/DDBJ (DNA, RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "GenBank/EMBL/DDBJ"

union
select seqNum = identity(10), t._Term_key, synonym = "TIGR Mouse Gene Index (RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "TIGR Mouse Gene Index"

union
select seqNum = identity(10), t._Term_key, synonym = "DoTS (RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "DoTS"

union
select seqNum = identity(10), t._Term_key, synonym = "NIA Mouse Gene Index (RNA)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "NIA Mouse Gene Index"

union
select seqNum = identity(10), t._Term_key, synonym = "SWISS-PROT (polypeptide)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "SWISS-PROT"

union
select seqNum = identity(10), t._Term_key, synonym = "TrEMBL (polypeptide)"
from VOC_Vocab v, VOC_Term t
where v.name = 'Sequence Provider'
and v._Vocab_key = t._Vocab_key
and t.term = "TrEMBL"
go

declare @synKey integer
select @synKey = max(_Synonym_key) from VOC_Synonym

insert into VOC_Synonym
select @synKey + seqNum, _Term_key, synonym, getdate(), getdate()
from #toAdd
go

checkpoint
go

quit

EOSQL

date >> ${LOG}
