#!/bin/csh -f

#
# Migration for: Alleles (TR 5750)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Allele Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename ALL_Type, ALL_Type_Old
go

end

EOSQL

${newmgddbschema}/table/ALL_Type_create.object | tee -a ${LOG}
${newmgddbschema}/key/ALL_Type_create.object | tee -a ${LOG}
${newmgddbschema}/index/ALL_Type_create.object | tee -a ${LOG}
${newmgddbschema}/view/ALL_Type_Summary_View_create.object | tee -a ${LOG}
${newmgddbperms}/public/view/ALL_Type_Summary_View_grant.object | tee -a ${LOG}
${newmgddbschema}/trigger/ALL_Type_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/ALL_Type_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

insert into ALL_Type
select o._Allele_Type_key, o.alleleType, 1, o.creation_date, o.modification_date
from ALL_Type_Old o
go

insert into ACC_MGIType 
values (26, 'Allele Type', 'ALL_Type', '_Allele_Type_key', null, 'ALL_Type_Summary_View', 1000, 1000, getdate(), getdate())
go

/* Chemically induced changes */

declare @chemOther integer
select @chemOther = _Allele_Type_key from ALL_Type where alleleType = 'Chemical induced'

update ALL_Allele
set _Allele_Type_key = @chemOther
from ALL_Allele a, ALL_Type t
where a._Allele_Type_key = t._Allele_Type_key
and t.alleleType in ('Chemical induced (chlorambucil)', 'Chemical Induced (EMS)')

update ALL_Type set alleleType = 'Chemically induced (other)' where _Allele_Type_key = @chemOther
update ALL_Type set alleleType = 'Chemically induced (ENU)' where alleleType = 'Chemical induced (ENU)'
update ALL_Type set alleleType = 'Chemically and radiation induced' where alleleType = 'Chemical and radiation induced'
delete from ALL_Type where alleleType in ('Chemical induced (chlorambucil)', 'Chemical Induced (EMS)')

go

update ALL_Type set alleleType = 'Gene trapped' where alleleType = 'Transgene induced (gene trapped)'
go

declare @alleleKey integer
select @alleleKey = max(_Allele_Type_key) from ALL_Type

insert into ALL_Type values(@alleleKey + 1, 'Targeted (knock-out)', 1, getdate(), getdate())
insert into ALL_Type values(@alleleKey + 2, 'Targeted (knock-in)', 1, getdate(), getdate())
insert into ALL_Type values(@alleleKey + 3, 'Targeted (Floxed/Frt)' , 1, getdate(), getdate())
insert into ALL_Type values(@alleleKey + 4, 'Targeted (Reporter)', 1, getdate(), getdate())
insert into ALL_Type values(@alleleKey + 5, 'Targeted (other)', 1, getdate(), getdate())
insert into ALL_Type values(@alleleKey + 6, 'Transgenic (random, gene disruption)', 1, getdate(), getdate())
insert into ALL_Type values(@alleleKey + 7, 'Transgenic (random, expressed)', 1, getdate(), getdate())
insert into ALL_Type values(@alleleKey + 8, 'Transgenic (Cre/Flp)', 1, getdate(), getdate())
go

update ALL_Type set sequenceNum = 1 where alleleType = 'Spontaneous'
update ALL_Type set sequenceNum = 2 where alleleType = 'Targeted (knock-out)'
update ALL_Type set sequenceNum = 3 where alleleType = 'Targeted (knock-in)'
update ALL_Type set sequenceNum = 4 where alleleType = 'Targeted (Floxed/Frt)'
update ALL_Type set sequenceNum = 5 where alleleType = 'Targeted (Reporter)'
update ALL_Type set sequenceNum = 6 where alleleType = 'Targeted (other)'
update ALL_Type set sequenceNum = 7 where alleleType = 'Gene trapped'
update ALL_Type set sequenceNum = 8 where alleleType = 'Chemically induced (ENU)'
update ALL_Type set sequenceNum = 9 where alleleType = 'Chemically induced (other)'
update ALL_Type set sequenceNum = 10 where alleleType = 'Chemically and radiation induced'
update ALL_Type set sequenceNum = 11 where alleleType = 'Radiation induced'
update ALL_Type set sequenceNum = 12 where alleleType = 'Transgenic (random, gene disruption)'
update ALL_Type set sequenceNum = 13 where alleleType = 'Transgenic (random, expressed)'
update ALL_Type set sequenceNum = 14 where alleleType = 'Transgenic (Cre/Flp)'
update ALL_Type set sequenceNum = 15 where alleleType = 'QTL'
update ALL_Type set sequenceNum = 16 where alleleType = 'Not Applicable'
update ALL_Type set sequenceNum = 17 where alleleType = 'Not Specified'
go

/* report any stragglers */

select a.symbol from ALL_Allele where _Allele_Type_key in (2,3)
go

update ALL_Allele set _Allele_Type_key = -2 where _Allele_Type_key in (2,3)
go

delete from ALL_Type where alleleType = 'Transgene induced (gene targeted)'
delete from ALL_Type where alleleType = 'Transgene induced'
go

end

EOSQL

${SETLOAD}/setload.csh ${newmgddbschema} alleletype.txt load | tee -a ${LOG}

./mgiallele.py | tee -a ${LOG}
cat ${DBPASSWORDFILE} | isql -S${DBSERVER} -D${DBNAME} -U${DBUSER} -imgiallele.sql | tee -a ${LOG}

date >> ${LOG}

