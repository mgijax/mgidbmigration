#!/bin/csh -f

#
# Usage:  journal.csh
#

cd `dirname $0`

setenv NOTEMODE incremental
setenv NOTEDATAFILE journal.rpt
setenv NOTEOBJECTYPE "Vocabulary Term"
setenv NOTETYPE "Journal Copyright"

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* delete previous keys that exist from a previous migration/test */
delete from VOC_Term where _Vocab_key = 48 and sequenceNum >= 44
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 1, @vocabKey, 'J Clin Invest', null, 44, 0, 1000, 1000, getdate(), getdate())
insert into VOC_Term values (@termKey + 2, @vocabKey, 'J Biol Chem', null, 45, 0, 1000, 1000, getdate(), getdate())
insert into VOC_Term values (@termKey + 3, @vocabKey, 'J Lipid Res', null, 46, 0, 1000, 1000, getdate(), getdate())
go

quit

EOSQL

./journal.py | tee -a ${LOG}
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${NOTEDATAFILE} -M${NOTEMODE} -O"${NOTEOBJECTYPE}" -T"${NOTETYPE}" | tee -a ${LOG}

date >> ${LOG}

