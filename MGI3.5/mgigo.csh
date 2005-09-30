#!/bin/csh -f

#
# TR 5188/GO Qualfiers
#
# Usage:  mgigo.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename VOC_AnnotType, VOC_AnnotType_Old
go

sp_rename VOC_Annot, VOC_Annot_Old
go

quit

EOSQL

#
# adding _QualifierVocab_key
#

${newmgddbschema}/table/VOC_AnnotType_drop.object | tee -a ${LOG}
${newmgddbschema}/table/VOC_AnnotType_create.object | tee -a ${LOG}
${newmgddbschema}/default/VOC_AnnotType_bind.object | tee -a ${LOG}
${newmgddbschema}/index/VOC_AnnotType_create.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_AnnotType_create.object | tee -a ${LOG}

#
# adding _Qualifier_key
#

${newmgddbschema}/table/VOC_Annot_drop.object | tee -a ${LOG}
${newmgddbschema}/table/VOC_Annot_create.object | tee -a ${LOG}
${newmgddbschema}/default/VOC_Annot_bind.object | tee -a ${LOG}
${newmgddbschema}/index/VOC_Annot_create.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Annot_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

declare @vocabKey integer
select @vocabKey = max(_Vocab_key) + 1 from VOC_Vocab
insert into VOC_Vocab values (@vocabKey, 73993, 1, 1, 0, 'GO Qualifiers', getdate(), getdate())
go

declare @synTypeKey integer
select @synTypeKey = max(_SynonymType_key) + 1 from MGI_Synonym
insert into MGI_SynonymType values (@synTypekey, 13, NULL, 'GO', 'Official GO-version', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'GO Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, 'NOT', null, 1, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 13 and synonymType = 'GO'
declare @synKey integer
select @synKey = max(_Synonym_key) + 1 from MGI_Synonym
insert into MGI_Synonym values (@synKey, @termKey, 13, @synTypeKey, 73993, 'NOT', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'GO Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, 'colocalizes with', null, 2, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 13 and synonymType = 'GO'
declare @synKey integer
select @synKey = max(_Synonym_key) + 1 from MGI_Synonym
insert into MGI_Synonym values (@synKey, @termKey, 13, @synTypeKey, 73993, 'colocalizes_with', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'GO Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, 'NOT colocalizes with', null, 3, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 13 and synonymType = 'GO'
declare @synKey integer
select @synKey = max(_Synonym_key) + 1 from MGI_Synonym
insert into MGI_Synonym values (@synKey, @termKey, 13, @synTypeKey, 73993, 'NOT|colocalizes_with', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'GO Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, 'contributes to', null, 4, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 13 and synonymType = 'GO'
declare @synKey integer
select @synKey = max(_Synonym_key) + 1 from MGI_Synonym
insert into MGI_Synonym values (@synKey, @termKey, 13, @synTypeKey, 73993, 'contributes_to', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'GO Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, 'NOT contributes to', null, 5, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 13 and synonymType = 'GO'
declare @synKey integer
select @synKey = max(_Synonym_key) + 1 from MGI_Synonym
insert into MGI_Synonym values (@synKey, @termKey, 13, @synTypeKey, 73993, 'NOT|contributes_to', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'GO Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, '', null, 6, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
declare @synTypeKey integer
select @synTypeKey = _SynonymType_key from MGI_SynonymType where _MGIType_key = 13 and synonymType = 'GO'
declare @synKey integer
select @synKey = max(_Synonym_key) + 1 from MGI_Synonym
insert into MGI_Synonym values (@synKey, @termKey, 13, @synTypeKey, 73993, '', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

/* generic qualifier vocabulary for */
/* PhenoSlim (1001), MP (1002), InterPro (1003), Strain/Super (1004), OMIM/Marker (1005), OMIM/Human (1006), PIRSF (1007)

declare @vocabKey integer
select @vocabKey = max(_Vocab_key) + 1 from VOC_Vocab
insert into VOC_Vocab values (@vocabKey, 22864, 1, 1, 0, 'Generic Annotation Qualifiers', getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Generic Annotation Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, 'NOT', null, 1, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Generic Annotation Qualifiers'
declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, @vocabKey, '', null, 6, 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

/* migrate VOC_AnnotType, VOC_Annot: GO */

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'GO Qualifiers'
declare @NOTtermKey integer
select @NOTtermKey = _Term_key from VOC_Term where _Vocab_key = @vocabKey and term = 'NOT'
declare @termKey integer
select @termKey = _Term_key from VOC_Term where _Vocab_key = @vocabKey and term = ''

insert into VOC_AnnotType
select o._AnnotType_key, o._MGIType_key, o._Vocab_key, o._EvidenceVocab_key, @vocabKey,
o.name, o.creation_date, o.modification_date
from VOC_AnnotType_Old o
where o._AnnotType_key = 1000

insert into VOC_Annot
select o._Annot_key, o._AnnotType_key, o._Object_key, o._Term_key, @NOTtermKey, o.creation_date, o.modification_date
from VOC_Annot_Old o
where o._AnnotType_key = 1000 and o.isNot = 1

insert into VOC_Annot
select o._Annot_key, o._AnnotType_key, o._Object_key, o._Term_key, @termKey, o.creation_date, o.modification_date
from VOC_Annot_Old o
where o._AnnotType_key = 1000 and o.isNot = 0

go

/* migrate VOC_AnnotType, VOC_Annot: all but GO */

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Generic Annotation Qualifiers'
declare @NOTtermKey integer
select @NOTtermKey = _Term_key from VOC_Term where _Vocab_key = @vocabKey and term = 'NOT'
declare @termKey integer
select @termKey = _Term_key from VOC_Term where _Vocab_key = @vocabKey and term = ''

insert into VOC_AnnotType
select o._AnnotType_key, o._MGIType_key, o._Vocab_key, o._EvidenceVocab_key, @vocabKey,
o.name, o.creation_date, o.modification_date
from VOC_AnnotType_Old o
where o._AnnotType_key != 1000

insert into VOC_Annot
select o._Annot_key, o._AnnotType_key, o._Object_key, o._Term_key, @NOTtermKey, o.creation_date, o.modification_date
from VOC_Annot_Old o
where o._AnnotType_key != 1000 and o.isNot = 1

insert into VOC_Annot
select o._Annot_key, o._AnnotType_key, o._Object_key, o._Term_key, @termKey, o.creation_date, o.modification_date
from VOC_Annot_Old o
where o._AnnotType_key != 1000 and o.isNot = 0

go

quit

EOSQL

date >> ${LOG}

