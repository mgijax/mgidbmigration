#!/bin/csh -fx

#
# TR9784
#
#  add new MGI_NoteType:  Strain-Specific Marker
#  add new MGI_RefAssocType: Strain-Specific Marker
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

/* create new reference type */
declare @nextType integer
select @nextType = max(_RefAssocType_key) + 1 from MGI_RefAssocType

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType, allowOnlyOne)
values (@nextType, 2, "Strain-Specific Marker", 0)

go

quit

EOSQL

${MGD_DBSCHEMADIR}/view/MGI_NoteType_Marker_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_Marker_View_create.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/MGI_NoteType_Marker_View_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}

