#!/bin/csh -fx

#
# Mocked up cell line lab code vocab terms and translations TR7493 -- gene trap LF
# Assumes vocab and translation type exist in the database
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv CWD `pwd`	# current working directory

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

###----------------------------------###
###--- load lab code vocabularies ---###
###----------------------------------###

setenv JNUM "J:141210"
setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

date | tee -a ${LOG}
echo "--- Loading lab code vocabulary..." | tee -a ${LOG}

cd ${CWD}

../loadSimpleVocab.py ../vocabs/fakeLabCodes.txt "Cell Line Lab Code" ${JNUM} -1 ${DB_PARMS} | tee -a ${LOG}

###-----------------------------------------------------###
###--- load translation from raw creator to lab code ---###
###-----------------------------------------------------###

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "GGTC"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "GGTC", 1, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "BayGenomics"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "BayGenomics", 2, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "SIGTR"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "Sanger Institute Gene Trap Resource - SIGTR", 3, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "ESDB"

insert into MGI_Translation
values (@maxTKey + 1, 1018,  @termKey, "Hicks GG", 4, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "CMHD"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "Stanford WL", 5, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "FHCRC"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "Soriano P", 6, 1001, 1001, getdate(), getdate()
)
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "TIGEM"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "TIGEM", 7, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "EGTC"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "Exchangeable Gene Trap Clones", 8, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "Lexicon Genetics"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "Zambrowicz BP", 9, 1001, 1001, getdate(), getdate())
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

declare @termKey integer
select @termKey = _Term_key from VOC_Term
where _Vocab_key = 71
and term = "TIGM"

insert into MGI_Translation
values (@maxTKey + 1, 1018, @termKey, "Richard H. Finnell at Texas Institute for Genomic Medicine", 10, 1001, 1001, getdate(), getdate())
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

