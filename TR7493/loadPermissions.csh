#!/bin/csh -fx

#
# creator permissions for TR7493 -- gene trap LF
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#source ${MGICONFIG}/master.config.csh

source ../Configuration

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
echo "--- Loading permissions..." | tee -a ${LOG}

cd ${CWD}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- remove role = "Pheno:Tier 2 (support)", 706919
delete from MGI_RoleTask where _Role_key = 706919
go
delete from MGI_UserRole where _Role_key = 706919
go
delete from VOC_Term where _Vocab_key = 33 and _Term_key = 706919
go

-- change role "Pheno:Tier 4 (curator)", 706921
-- change 753702/pheno:change pending/deleted to reserved if owner TO 753701/pheno:change pending/deleted to reserved
-- change 753706/pheno:change reserved to deleted if owner TO 753705/pheno:change reserved to deleted
-- change 753713/pheno:edit nomen data reserved if owner TO 753712/pheno:edit nomen data reserved
update MGI_RoleTask
set _Task_key = 753701
where _Task_key = 753702
go

update MGI_RoleTask
set _Task_key = 753705
where _Task_key = 753706
go

update MGI_RoleTask
set _Task_key = 753712
where _Task_key = 753713
go

-- remove obsolete tasks
-- term = "pheno:change pending/deleted to reserved if owner"
-- term = "pheno:change reserved to deleted if owner"
delete from VOC_Term where _Vocab_key = 34 and _Term_key = 753702
delete from VOC_Term where _Vocab_key = 34 and _Term_key = 753706
delete from VOC_Term where _Vocab_key = 34 and _Term_key = 753713
go

-- insert 753714/pheno:edit nomen data approved TO role "Pheno:Tier 4 (curator)", 706921
-- insert 753708/pheno:change approved to deleted/reserved/pending TO role "Pheno:Tier 4 (curator)", 706921
-- insert 4632568/pheno:create/modify non-mutant cell line
-- insert 4632569/pheno:create/modify derivation
insert into MGI_RoleTask values(1071,706921,753714,1000,1000,getdate(),getdate())
insert into MGI_RoleTask values(1072,706921,753708,1000,1000,getdate(),getdate())
insert into MGI_RoleTask values(1073,706921,4632568,1000,1000,getdate(),getdate())
insert into MGI_RoleTask values(1074,706921,4632569,1000,1000,getdate(),getdate())
insert into MGI_RoleTask values(1075,706922,4632568,1000,1000,getdate(),getdate())
insert into MGI_RoleTask values(1076,706922,4632569,1000,1000,getdate(),getdate())
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

