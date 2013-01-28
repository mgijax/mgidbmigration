#!/bin/csh -fx

#
###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | ${MGI_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

select * from snp_test..SNP_Population order by subHandle
go

select _Term_key, term from VOC_Term where _Vocab_key = 51
go

select accID, _Object_key from ACC_Accession where _LogicalDB_key = 77
go

select  _LogicalDB_key, name from ACC_LogicalDB where description like '%dbsnp%'
go

EOSQL

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

