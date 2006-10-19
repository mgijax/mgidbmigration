#!/bin/csh -f

#
# TR 7533/GO
#
# Usage:  go.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${MGD_DBSCHEMADIR}/table/GO_Tracking_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/GO_Tracking_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GO_Tracking_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/GO_Tracking_bind.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* for every gene that has GO annotations, insert a record into GO tracking */

select distinct a._Object_key
into #go
from VOC_Annot a
where a._AnnotType_key = 1000
go

insert into GO_Tracking
select _Object_key, 0, null, 1000, 1000, null, getdate(), getdate()
from #go
go

/* set the completion date by looking in the notes */

update GO_Tracking
set completion_date = substring(n.note, charindex("<d>", n.note) + 3, charindex("</d>", n.note) - charindex("<d>", n.note) - 3),
_CompletedBy_key = 1000
from GO_Tracking g, MGI_Note_MRKGO_View n
where g._Marker_key = n._Object_key
and n.note like "%<d>%</d>%"
go

/* set the reference gene bit by looking in the notes */

update GO_Tracking
set isReferenceGene = 1
from GO_Tracking g, MGI_Note_MRKGO_View n
where g._Marker_key = n._Object_key
and n.note like "%<rg>%"
go

/* remove the notes? */

quit

EOSQL

#
# add indexes;permissions;etc.
#

${MGD_DBSCHEMADIR}/index/GO_Tracking_create.object | tee -a ${LOG}

date >> ${LOG}

