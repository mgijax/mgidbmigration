#!/bin/csh -f

#
# Migration for MGI Fantom2
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename MGI_Fantom2, MGI_Fantom2_Old
go

end

EOSQL

#
# drop indexes, create new table
#
${newmgddbschema}/table/MGI_Fantom2_create.object >>& ${LOG}
${newmgddbschema}/default/MGI_Fantom2_bind.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MGI_Fantom2
select * from MGI_Fantom2_Old
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MGI_Fantom2_create.object >>& ${LOG}
${newmgddbperms}/curatorial/table/MGI_grant.logical >>& ${LOG}

date >> $LOG

