#!/bin/csh -f

#
# Usage:  journal.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

declare @vocabKey integer
select @vocabKey = max(_Vocab_key) + 1 from VOC_Vocab
insert into VOC_Vocab values (@vocabKey, 22864, 1, 1, 1, 'Journal', getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, 'Dev Biol', null, 1, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 1, @vocabKey, 'Development', null, 2, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 2, @vocabKey, 'Dev Dyn', null, 3, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 3, @vocabKey, 'Gene Expr Patterns', null, 4, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 4, @vocabKey, 'Mech Dev', null, 5, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 5, @vocabKey, 'PLoS Biol', null, 6, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 6, @vocabKey, 'BMC Biochem', null, 7, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 7, @vocabKey, 'BMC Biol', null, 8, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 8, @vocabKey, 'BMC Biotechnol', null, 9, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 9, @vocabKey, 'BMC Cancer', null, 10, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 10, @vocabKey, 'BMC Cell Biol', null, 11, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 11, @vocabKey, 'BMC Complement Altern Med', null, 12, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 12, @vocabKey, 'BMC Dev Biol', null, 13, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 13, @vocabKey, 'BMC Evol Biol', null, 14, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 14, @vocabKey, 'BMC Genet', null, 15, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 15, @vocabKey, 'BMC Genomics', null, 16, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 16, @vocabKey, 'BMC Med', null, 17, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 17, @vocabKey, 'BMC Mol Biol', null, 18, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 18, @vocabKey, 'BMC Neurosci', null, 19, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 19, @vocabKey, 'BMC Ophthalmol', null, 20, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 20, @vocabKey, 'Cell Death Differ', null, 21, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 21, @vocabKey, 'Oncogene', null, 22, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 22, @vocabKey, 'Nature', null, 23, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 23, @vocabKey, 'Nat Cell Biol', null, 24, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 24, @vocabKey, 'Nat Genet', null, 25, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 25, @vocabKey, 'Nat Immunol', null, 26, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 26, @vocabKey, 'Nat Med', null, 27, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 27, @vocabKey, 'Nat Neurosci', null, 28, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 28, @vocabKey, 'Nat Struct Biol', null, 29, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 29, @vocabKey, 'Nat Biotechnol', null, 30, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 30, @vocabKey, 'Nat Rev Cancer', null, 31, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 31, @vocabKey, 'Nat Rev Genet', null, 32, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 32, @vocabKey, 'Nat Rev Immunol', null, 33, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 33, @vocabKey, 'Nat Rev Mol Cell Bio', null, 34, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 34, @vocabKey, 'Nat Rev Neurosci', null, 35, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go
declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Journal'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey + 35, @vocabKey, 'Biotechnology', null, 36, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @noteTypeKey integer
select @noteTypeKey = max(_NoteType_key) + 1 from MGI_NoteType
insert into MGI_NoteType values(@noteTypeKey, 13, 'Journal Copyright', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

quit

EOSQL

./journal.py | tee -a ${LOG}
${NOTELOAD} -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -I${DATAFILE} -M${NOTEMODE} -O"${OBJECTTYPE}" -T"${NOTETYPE}" | tee -a ${LOG}

date >> ${LOG}

