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
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

select distinct age, ageMin, ageMax from ALL_Cre_Cache
order by age
go

select c.accID, a.symbol, a.driverNote from ALL_Cre_Cache a, ACC_Accession c
where a.age like 'not specified%'
and a._Allele_key = c._Object_key
and c._MGIType_key = 8
order by a.symbol
go

select c.accID, a.symbol, a.driverNote from ALL_Cre_Cache a, ACC_Accession c
where a.age is null
and a._Allele_key = c._Object_key
and c._MGIType_key = 8
order by a.symbol
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

