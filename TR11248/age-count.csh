#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
echo $PG_DBSERVER
echo $PG_FE_DBNAME

psql -h ${PG_DBSERVER} -d ${PG_FE_DBNAME} -U ${PG_DBUSER} <<EOSQL | tee -a ${LOG}

select age_e1, count(age_e1) as "E0-8.9/system" 
from recombinase_allele_system
where age_e1 is not null
group by age_e1;

select age_e1, count(age_e1) as "E0-8.9/structure" 
from recombinase_system_structure
where age_e1 is not null
group by age_e1;

select age_e2, count(age_e2) as "E9.0-13.9/system" 
from recombinase_allele_system
where age_e2 is not null
group by age_e2;

select age_e2, count(age_e2) as "E9.0-13.9/structure" 
from recombinase_system_structure
where age_e2 is not null
group by age_e2;

select age_e3, count(age_e3) as "E14-19.5/system" 
from recombinase_allele_system
where age_e3 is not null
group by age_e3;

select age_e3, count(age_e3) as "E14-19.5/structure" 
from recombinase_system_structure
where age_e3 is not null
group by age_e3;

select age_p1, count(age_p1) as "P0-21/system" 
from recombinase_allele_system
where age_p1 is not null
group by age_p1;

select age_p1, count(age_p1) as "P0-21/structure" 
from recombinase_system_structure
where age_p1 is not null
group by age_p1;

select age_p2, count(age_p2) as "Post-weaning/system" 
from recombinase_allele_system
where age_p2 is not null
group by age_p2;

select age_p2, count(age_p2) as "Post-weaning/structure" 
from recombinase_system_structure
where age_p2 is not null
group by age_p2;

select age_p3, count(age_p3) as "Adult/system" 
from recombinase_allele_system
where age_p3 is not null
group by age_p3;

select age_p3, count(age_p3) as "Adult/structure" 
from recombinase_system_structure
where age_p3 is not null
group by age_p3;

select age_p4, count(age_p4) as "Postnatal-not specified/system" 
from recombinase_allele_system
where age_p4 is not null
group by age_p4;

select age_p4, count(age_p4) as "Postnatal-not specified/structure" 
from recombinase_system_structure
where age_p4 is not null
group by age_p4;

EOSQL

date |tee -a $LOG

