#!/bin/csh -fx

#
# TR12963/DADT project TR112934 Sanger SNPS 
# Add strains to SNP_Strain
# Add population to SNP_Population
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting ' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#${PG_DBUTILS}/bin/loadDB.csh bhmgidb03lt sc mgd /bhmgidb01/dump/mgd.postdaily.dump
#${PG_DBUTILS}/bin/loadDBdb.csh bhmgidb03lt sc radar /bhmgidb01/dump/radar.postdaily.dump

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 28319, '129P2/OlaHsd', 1)
;
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 39224, '129S5/SvEvBrd', 1)
;
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 11, 'C3H/HeH', 1)
;
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 39344, 'C57BL/6NJ', 1)
;
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 29001, 'LEWES/EiJ', 1)
;
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 32915, 'NZO/HlLtJ', 1)
;
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 1368, 'PWK/PhJ', 1)
;
insert into snp_strain values((select max(_snpstrain_key) + 1 from snp_strain), 18, 'RF/J1', 1)
;

insert into snp_population values((select max(_population_key) + 1 from snp_population), 'SC_MOUSE_GENOMES', 10125533, 'EVA_MGPV3')
;
EOSQL

echo '--- finished ' | tee -a ${LOG}

