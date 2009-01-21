#!/bin/csh -fx

#
# creator translation for TR7493 -- gene trap LF
#

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

date | tee -a ${LOG}
echo "--- Loading vocabularies..." | tee -a ${LOG}

cd ${CWD}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

insert MGI_Translation
values(@maxTKey + 1, 1017, 3982965, "Sanger Institute Gene Trap Resource - SIGTR", 1, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

insert MGI_Translation
values(@maxTKey + 1, 1017, 3982959, "Hicks GG", 2, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

insert MGI_Translation
values(@maxTKey + 1, 1017, 3982957, "Stanford WL", 3, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

insert MGI_Translation
values(@maxTKey + 1, 1017, 3982960, "Soriano P", 4, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

insert MGI_Translation
values(@maxTKey + 1, 1017, 3982958, "Exchangeable Gene Trap Clones", 5, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

insert MGI_Translation
values(@maxTKey + 1, 1017, 3982962, "Zambrowicz BP", 6, 1001, 1001, getdate(), getdate() )
go

declare @maxTKey integer
select @maxTKey = max(_Translation_key) from MGI_Translation

insert MGI_Translation
values(@maxTKey + 1, 1017, 3982964, "Richard H. Finnell at Texas Institute for Genomic Medicine", 7, 1001, 1001, getdate(), getdate() )
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

