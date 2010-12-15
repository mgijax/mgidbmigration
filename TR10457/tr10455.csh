#!/bin/csh -f

#
# TR10455/remove "#"
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} GXD_Structure
#bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} GXD_StructureName

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

select sn.*
from GXD_StructureName sn
where sn.mgiAdded = 1
and sn.structure like "%#%"
order by sn.structure
go

checkpoint
go

end

EOSQL

${MGD_DBSCHEMADIR}/trigger/GXD_StructureName_drop.object
./tr10455.py
${MGD_DBSCHEMADIR}/trigger/GXD_StructureName_create.object

date |tee -a $LOG

