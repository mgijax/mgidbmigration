#!/bin/csh -f

#
# Migration for MGI Notes
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "MGI Note Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into MGI_NoteType values(1006, 5, 'General', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_NoteType values(1007, 19, 'General', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

checkpoint
go

quit

EOSQL

date >> ${LOG}

