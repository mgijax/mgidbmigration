#!/bin/csh -fx

#
# delete dup alleles and everything associated
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

#
# load a production backup into mgd and radar
#

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

echo "--- do deletes ---" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* use to delete from ALL_Allele_CellLine, ALL_Allele_Mutation, ALL_Allele */
select accid, _Object_key as _Allele_key
into #allelesToDelete
from ACC_Accession
where _MGIType_key = 11
and accid in  ('33373', '118822', '118823', '89792', '101612', '118801')
union
select accid, _Object_key as _Allele_key
from ACC_Accession
where _MGIType_key = 11
and _Object_key in (828784, 828915)
go

/* use to delete from ACC_Accession */
select a._Accession_key, a.accid
into #accToDelete
from ACC_Accession a, #allelesToDelete d
/* Allele project ids */
where a._Object_key  = d._Allele_key
and a._MGIType_key = 11
and a._LogicalDB_key = 138
union
select a._Accession_key, a.accid
/* MCL IDs */
from ACC_Accession a, #allelesToDelete d
where a._Object_key  = d._Allele_key
/* Allele MGI ID */
and a._MGIType_key = 11
and a._LogicalDB_key = 1
and prefixPart = 'MGI:'
union
select a._Accession_key, a.accid
from ACC_Accession a, #allelesToDelete d, ALL_Allele_CellLine ac
where d._Allele_key = ac._Allele_key
and ac._MutantCellLine_key = a._Object_key
and a._MGIType_key = 28
and a._LogicalDB_key = 137
go

/* use to delete from ALL_CellLine */
select _MutantCellLine_key as _CellLine_key
into #mclToDelete
from ALL_Allele_CellLine a, #allelesToDelete d
where d._Allele_key = a._Allele_key
go

/* use to delete from MGI_Note_Chunk and MGI_Note */
select n._Note_key
into #notesToDelete
from MGI_Note n, #allelesToDelete d
where d._Allele_key = n._Object_key
and n._MGIType_key = 11
go

delete MGI_NoteChunk
from MGI_NoteChunk mnc, #notesToDelete d
where d._Note_key = mnc._Note_key
go

delete MGI_Note
from MGI_Note mn, #notesToDelete d
where d._Note_key = mn._Note_key
go

/* Note: there are no ACC_AccessionReference records */
delete ACC_Accession
from ACC_Accession a, #accToDelete d
where a._Accession_key = d._Accession_key
go

delete ALL_Allele_CellLine
from ALL_Allele_CellLine aac, #mclToDelete d
where aac._MutantCellLine_key = d._CellLine_key
go

delete ALL_CellLine
from ALL_CellLine ac, #mclToDelete d
where ac._CellLine_key = d._CellLine_key
go

delete ALL_Allele_Mutation
from ALL_Allele_Mutation a, #allelesToDelete d
where a._Allele_key = d._Allele_key
go

delete ALL_Allele
from ALL_Allele a, #allelesToDelete d
where a._Allele_key = d._Allele_key
go

EOSQL

date | tee -a ${LOG}
