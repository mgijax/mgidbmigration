#!/bin/csh -fx

#
# Vocabs/Translations/Misc stuff for TR7493 -- gene trap LF
#

###----------------------###
###--- initialization ---###
###----------------------###

setenv MGICONFIG /usr/local/mgi/live/mgiconfig
source ${MGICONFIG}/master.config.csh

setenv CWD `pwd`	# current working directory

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

###-----------------------------###
###--- load new vocabularies ---###
###-----------------------------###

setenv JNUM "J:141210"
#setenv JNUM "J:1"
setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

date | tee -a ${LOG}
echo "--- Loading vocabularies..." | tee -a ${LOG}

cd ${CWD}

./loadSimpleVocab.py vocabs/alleleMode.txt "Allele Mode" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/genotypeExistsAs.txt "Genotype Exists As" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/alleleTrans.txt "Allele Transmission" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/clCreator.txt "Cell Line Creator" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/cellLineType.txt "Cell Line Type" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/vectorType.txt "Cell Line Vector Type" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/derivationType.txt "Derivation Type" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/seqTagMethod.txt "Sequence Tag Method" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/vectorEnd.txt "Gene Trap Vector End" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/reverseComp.txt "Reverse Complement" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py vocabs/seqAlleleAssoc.txt "Sequence Allele Association Qualifier" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}

#./loadSimpleVocab.py vocabs/condiVector.txt "Conditional Vector" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
#./loadSimpleVocab.py vocabs/revVector.txt "Reversed Vector" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}

###--------------------------------------------------------------------------###
###--- new vocabs (no terms yet)                                             ###
###--------------------------------------------------------------------------###

date | tee -a ${LOG}
echo "--- Creating TranslationTypes and Misc stuff" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* add new derivation mgi type */
declare @maxMKey integer
select @maxMKey = max(_MGIType_key) from ACC_MGIType

insert ACC_MGIType
values(@maxMKey + 1, "Cell Line Derivation", "ALL_CellLine_Derivation", "_Derivation_key", null, null, 1001, 1001, getdate(), getdate())
go

/* add new TIGM logicalDB for cell line id (existing one will be used for sequence tag id) */
/* Note: not linking therefore no actualDB record needed */

declare @maxLKey integer
select @maxLKey = max(_LogicalDB_key) from ACC_LogicalDB

insert ACC_LogicalDB
values(@maxLKey + 1, "TIGM Cell Line", "Texas Institute for Genomic Medicine Cell Line", 1, 1001, 1001, getdate(), getdate() )
go

/* no terms for these vocabs yet, just create the vocab */
declare @maxVKey integer
select @maxVKey = max(_Vocab_key) from VOC_Vocab

insert VOC_Vocab
values(@maxVKey + 1, 142303, -1, 1, 0, "Marker-Allele Association Qualifier", getdate(), getdate() )
go

declare @maxVKey integer
select @maxVKey = max(_Vocab_key) from VOC_Vocab

insert VOC_Vocab
values(@maxVKey + 1, 142303, -1, 1, 0, "Cell Line Lab Code", getdate(), getdate() )
go

/* add new term to Allele Status vocab */
declare @maxTKey integer
select @maxTKey = max(_Term_key) from VOC_Term

insert VOC_Term
values(@maxTKey + 1, 37, "Autoload", "Autoload", 1, 0, 1001, 1001, getdate(), getdate())
go

/* add new term to Allele Molecular Mutation vocab */
declare @maxTKey integer
select @maxTKey = max(_Term_key) from VOC_Term

insert VOC_Term
values(@maxTKey + 1, 36, "Insertion of gene trap vector", null, 1, 0, 1001, 1001, getdate(), getdate())
go

/* new translation types (no translations yet) */ 
declare @maxTKey integer
select @maxTKey = max(_TranslationType_key) from MGI_TranslationType

insert into MGI_TranslationType
values (@maxTKey + 1, 28, null, "Parent Cell Line", null, 0, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_TranslationType_key) from MGI_TranslationType

declare @dMgiTypeKey integer
select @dMgiTypeKey = _MGIType_key from ACC_MGIType
where name = "Cell Line Derivation"

insert into MGI_TranslationType
values (@maxTKey + 1, @dMgiTypeKey, null, "Derivation", null, 0, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_TranslationType_key) from MGI_TranslationType

declare @cVocabKey integer
select @cVocabKey = _Vocab_key from VOC_Vocab
where name = "Cell Line Creator"

insert into MGI_TranslationType
values (@maxTKey + 1, 13,  @cVocabKeY, "Cell Line Creator", null, 0, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_TranslationType_key) from MGI_TranslationType

declare @cVocabKey integer
select @cVocabKey = _Vocab_key from VOC_Vocab
where name = "Cell Line Lab Code"

insert into MGI_TranslationType
values (@maxTKey + 1, 13, @cVocabKey,  "Cell Line Lab Code", null, 0, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_TranslationType_key) from MGI_TranslationType

declare @cVocabKey integer
select @cVocabKey = _Vocab_key from VOC_Vocab
where name =  "Cell Line Vector Type"

insert into MGI_TranslationType
values (@maxTKey + 1, 13, @cVocabKey, "Vector to Vector Type", null, 0, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_TranslationType_key) from MGI_TranslationType

declare @dMgiTypeKey integer
select @dMgiTypeKey = _MGIType_key from ACC_MGIType
where name = "Cell Line Derivation"

insert into MGI_TranslationType
values (@maxTKey + 1, @dMgiTypeKey, null, "Vector to Derivation", null, 0, 1001, 1001, getdate(), getdate() )
go


/* misc additions/revisions */

/* add new synonym type for cell lines */
declare @maxSynonymTypeKey integer
select @maxSynonymTypeKey = max(_SynonymType_key) from MGI_SynonymType

insert MGI_SynonymType (_SynonymType_key, _MGIType_key, _Organism_key, synonymType, definition, allowOnlyOne)
values (@maxSynonymTypeKey + 1, 28, null, "synonym", "synonym for cell line", 0)
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

