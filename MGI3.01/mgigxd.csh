#!/bin/csh -f

#
# Migration for: IMG_ImagePane, IMG_FieldType
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "GXD Migration..." | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename IMG_ImagePane, IMG_ImagePane_Old
go

drop table IMG_FieldType
go

drop view IMG_ImagePane_View
go

end

EOSQL

#
# create new tables
#
${newmgddbschema}/table/IMG_ImagePane_create.object >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into IMG_ImagePane
select _ImagePane_key, _Image_key, paneLabel, creation_date, modification_date
from IMG_ImagePane_Old
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/IMG_ImagePane_create.object >> ${LOG}

date >> ${LOG}

