#!/bin/csh -f

#
# Migration for MGI 3.12
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

declare @noteTypeKey integer
select @noteTypeKey = max(_NoteType_key) + 1 from MGI_NoteType
insert into MGI_NoteType values(@noteTypeKey, 2, 'GO Text', 0, 1000, 1000, getdate(), getdate())
go

update IMG_Image
set copyrightNote = 'Reprinted with permission from Elsevier from \DXDOI(10.1006/dbio.1993.1129||) \Elsevier(J:4754||).'
from ACC_Accession a, IMG_Image i
where a.accID = "MGI:1339627"
and a._Object_key = i._Image_key
go

update IMG_Image
set copyrightNote = 'Reprinted with permission from Elsevier from \DXDOI(10.1006/dbio.1993.1129||) \Elsevier(J:4754||).'
from ACC_Accession a, IMG_Image i
where a.accID = "MGI:1339628"
and a._Object_key = i._Image_key
go

update IMG_Image
set copyrightNote = 'Reprinted with permission from Elsevier from \DXDOI(10.1006/dbio.1993.1129||) \Elsevier(J:4754||).'
from ACC_Accession a, IMG_Image i
where a.accID = "MGI:1339629"
and a._Object_key = i._Image_key
go

update IMG_Image
set copyrightNote = 'Reprinted with permission from Elsevier from \DXDOI(10.1006/dbio.1993.1118||) \Elsevier(J:12155||).'
from ACC_Accession a, IMG_Image i
where a.accID = "MGI:1340225"
and a._Object_key = i._Image_key
go

update IMG_Image
set copyrightNote = 'Reprinted with permission from Elsevier from \DXDOI(10.1006/dbio.1993.1145||) \Elsevier(J:13029||).'
from ACC_Accession a, IMG_Image i
where a.accID = "MGI:1344706"
and a._Object_key = i._Image_key
go

update IMG_Image
set copyrightNote = 'Reprinted with permission from Elsevier from \DXDOI(10.1006/dbio.1993.1018||) \Elsevier(J:16971||).'
from ACC_Accession a, IMG_Image i
where a.accID = "MGI:1350598"
and a._Object_key = i._Image_key
go

update IMG_Image
set copyrightNote = 'Reprinted with permission from Elsevier from \DXDOI(10.1006/dbio.1993.1206||) \Elsevier(J:19551||).'
from ACC_Accession a, IMG_Image i
where a.accID = "MGI:1341320"
and a._Object_key = i._Image_key
go

end

EOSQL

date | tee -a  ${LOG}
