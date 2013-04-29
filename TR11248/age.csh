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

select distinct c.accID, aa.accID, 
substring(a.symbol,1,25), 
a.expressed, 
substring(a.age,1,25), a.ageMin, a.ageMax, 
substring(a.structure,1,25) as structure, a.hasImage,
substring(a.system,1,25) as system, 
a._Allele_key, a._Assay_key
from ALL_Cre_Cache a, ACC_Accession c, ACC_Accession aa
where a._Allele_key = c._Object_key
and c._MGIType_key = 11
and a._Assay_key = aa._Object_key
and aa._MGIType_key = 8
order by a.symbol, a.system, a.ageMin
go

select distinct  a.accID,
substring(a.symbol,1,25), 
a.expressed, 
substring(a.age,1,25), a.ageMin, a.ageMax, 
substring(a.structure,1,25) as structure, a.hasImage,
substring(a.system,1,25) as system, 
a._Allele_key, a._Assay_key
from ALL_Cre_Cache a, ALL_Cre_Cache cc
where a.system is not null
and a.age like 'postnatal [a-z]%'
and a._Allele_key = cc._Allele_key
and a._system_key = cc._system_key
and a._structure_key = cc._structure_key
and cc.age = 'postnatal'
order by a._Allele_key, a.system, a.structure, a.expressed desc, a.hasImage desc
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

