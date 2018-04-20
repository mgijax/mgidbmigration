#!/bin/csh -fx

#
# add isMusCanonical to MRK_Chromosome
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

${PG_MGD_DBSCHEMADIR}/key/MRK_Chromsosome_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MRK_Chromosome_drop.object | tee -a $LOG || exit 1
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
ALTER TABLE MRK_Chromosome RENAME TO MRK_Chromosome_old;
EOSQL

${PG_MGD_DBSCHEMADIR}/table/MRK_Chromosome_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

INSERT INTO MRK_Chromosome
SELECT _Chromosome_key, _Organism_key, chromosome, 0, sequenceNum, _CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
FROM MRK_Chromosome_old
;

UPDATE MRK_Chromosome SET isMusCanonical = 1 where _Organism_key = 1
;

select count(*) from MRK_Chromosome;
select count(*) from MRK_Chromosome_old;

insert into MRK_Chromosome values ((select max(_Chromosome_key) + 1 from MRK_Chromosome), 1, 20, 1, 25, 1001, 1001, now(), now());
insert into MRK_Chromosome values ((select max(_Chromosome_key) + 1 from MRK_Chromosome), 1, 21, 1, 26, 1001, 1001, now(), now());
insert into MRK_Chromosome values ((select max(_Chromosome_key) + 1 from MRK_Chromosome), 1, 22, 1, 27, 1001, 1001, now(), now());
insert into MRK_Chromosome values ((select max(_Chromosome_key) + 1 from MRK_Chromosome), 1, 23, 1, 28, 1001, 1001, now(), now());

select count(*) from MRK_Chromosome
select * from MRK_Chromosome
where _Organism_key = 1
;
EOSQL

${PG_MGD_DBSCHEMADIR}/key/MRK_Chromosome_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MRK_Chromosome_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MRK_Chromosome_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
DROP TABLE MRK_Chromosome_old;
EOSQL

date | tee -a ${LOG}

