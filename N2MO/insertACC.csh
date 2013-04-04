#!/bin/csh -fx

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`        # current working directory

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "Starting in ${CWD}..." | tee -a ${LOG}

date | tee -a ${LOG}
echo "add accession for EPD0811_5_G02" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @maxAccKey integer
select @maxAccKey = max(_Accession_key) from ACC_Accession

insert into ACC_Accession
values(@maxAccKey + 1, "EPD0811_5_G02", "EPD0811_5_G", 02, 137, 989574, 28, 0, 1, 1014, 1014, getdate(), getdate()) 
go

EOSQL
