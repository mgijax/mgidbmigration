#!/bin/csh -f

#
# Migration for MGI 3.12
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

declare @noteTypeKey integer
select @noteTypeKey = max(_NoteType_key) + 1 from MGI_NoteType
insert into MGI_NoteType values(@noteTypeKey, 2, 'GO Text', 0, 1000, 1000, getdate(), getdate())
go

end

EOSQL

./gotextload.csh

date | tee -a  ${LOG}
