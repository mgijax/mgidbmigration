#!/bin/csh -fx

#
# Migration for EUCOMMTools -- 

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
# Update EUCOMM references
#

date | tee -a ${LOG}
echo "--- Update EUCOMM Reference titles ---" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
UPDATE BIB_Refs
SET title = "Alleles produced for the EUCOMM and EUCOMMTools projects by the Wellcome Trust Sanger Institute"
WHERE _Refs_key = 156938
go

UPDATE BIB_Refs
SET title = "Alleles produced for the EUCOMM and EUCOMMTools projects by the Helmholtz Zentrum Muenchen GmbH (Hmgu)"
WHERE _Refs_key = 158158
go

EOSQL

#
# Update the 'Not Specified' MCLs associated with TAL loaded alleles to 'Orphaned'
#

date | tee -a ${LOG}
echo "--- Update 'Not Specified' MCLs to 'Approved' ---" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
SELECT ac._CellLine_key
INTO #toUpdate
FROM ALL_Allele a,
ALL_Allele_CellLine aac, ALL_Cellline ac,
ACC_Accession acc2
WHERE ac.cellLine = 'Not Specified'
AND aac._Allele_key = a._Allele_key
AND aac._MutantCellLine_key = ac._cellline_key
AND acc2.preferred=1
AND acc2.private=1
AND acc2._Object_key = a._Allele_key
AND acc2._LogicalDB_key in (125,126,138,143,166)
AND acc2._MGIType_key=11
go

CREATE INDEX idx1 on #toUpdate(_CellLine_key)
go

UPDATE ALL_CellLine
SET ac.cellLine = 'Orphaned'
FROM #toUpdate u, ALL_CellLine ac
WHERE u._CellLine_key = ac._CellLine_key
go

EOSQL

