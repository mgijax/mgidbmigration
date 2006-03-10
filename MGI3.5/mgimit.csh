#!/bin/csh -f

#
# TR 4460/MIT Coordinates
#
# Usage:  mgimit.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

quit

EOSQL

declare @noteTypeKey integer
select @noteTypeKey = max(_MGIType_key + 1) from MGI_NoteType
insert into MGI_NoteType values(@noteTypeKey, 2, 'Multiple Location', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

quit

EOSQL

date >> ${LOG}

