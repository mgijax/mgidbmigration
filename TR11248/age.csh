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

select distinct c.accID, aa.accID, a.symbol, a.hasImage, a.expressed, a.age, a.ageMin, a.ageMax, 
substring(a.system,1,50) as system, 
a._Allele_key, a._Assay_key
from ALL_Cre_Cache a, ACC_Accession c, ACC_Accession aa
where a._Allele_key = c._Object_key
and c._MGIType_key = 11
and a._Assay_key = aa._Object_key
and aa._MGIType_key = 8
order by a.symbol, a.system, a.ageMin
go

select distinct c.accID, aa.accID, a.symbol, a.hasImage, a.expressed, a.age, a.ageMin, a.ageMax, 
substring(a.structure,1,50) as structure, 
substring(a.system,1,50) as system, 
a._Allele_key, a._Assay_key
from ALL_Cre_Cache a, ACC_Accession c, ACC_Accession aa
where a._Allele_key = c._Object_key
and c._MGIType_key = 11
and a._Assay_key = aa._Object_key
and aa._MGIType_key = 8
order by a.symbol, a.system, a.ageMin
go

select c.accID, a.symbol, a._Allele_key, a._Assay_key
from ALL_Cre_Cache a, ACC_Accession c
where a.age is null
and a._Allele_key = c._Object_key
and c._MGIType_key = 11
order by a.symbol
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

