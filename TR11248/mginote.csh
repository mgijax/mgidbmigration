#!/bin/csh -fx

#
# TR11248
#
#  add new MGI_NoteType:  External Link
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

--insert MGI_NoteType (_NoteType_key, _MGIType_key, noteType, private)
--values (@nextType, 9, "External Link", 0)

insert MGI_NoteType (_NoteType_key, _MGIType_key, noteType, private)
values (@nextType, 9, "Cre-User Note", 0)

go

quit

EOSQL

# this will be picked up by
# private curator note (1025) in image module

${MGD_DBSCHEMADIR}/view/MGI_NoteType_Image_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_Image_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a  ${LOG}

