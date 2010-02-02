#!/bin/csh -fx

#
# TR9784
#
#  add new MGI_NoteType:  Strain-Specific Marker
#
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* create new note type */

declare @nextType integer
select @nextType = max(_NoteType_key) + 1 from MGI_NoteType

insert MGI_NoteType (_NoteType_key, _MGIType_key, noteType, private)
values (@nextType, 2, "Strain-Specific Marker", 1)

go

quit

EOSQL

${MGD_DBSCHEMADIR}/view/MGI_NoteType_StrainMarker_View_create.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/MGI_NoteType_StrainMarker_Vieww_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}

