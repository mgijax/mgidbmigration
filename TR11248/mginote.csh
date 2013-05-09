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

delete from MGI_Note where _Note_key = 272534326;
insert into MGI_Note (_Note_key, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key,creation_date, modification_date)
values(272534327,573275,11,1040,1001,1001,'05/05/2013','05/05/2013');

insert into MGI_NoteChunk (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key,creation_date, modification_date)
values(272534327,1,'Agile software development is a group of software development methods based on iterative and incremental development, where requirements and solutions evolve through collaboration between self-organizing, cross-fu',1001,1001,'05/05/2013','05/05/2013');

insert into MGI_NoteChunk (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key,creation_date, modification_date)
values(272534327,2,'nctional teams. It promotes adaptive planning, evolutionary development and delivery, a time-boxed iterative approach,and encourages rapid and flexible response to change. It is a conceptual framework that promotes foreseen interactions throughout the de',1001,1001,'05/05/2013','05/05/2013');

insert into MGI_NoteChunk (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key,creation_date, modification_date)
values(272534327,3,'velopment cycle. The Agile Manifesto[1] introduced the term in 2001.',1001,1001,'05/05/2013','05/05/2013');

quit

EOSQL

# this will be picked up by
# private curator note (1025) in image module

${MGD_DBSCHEMADIR}/view/MGI_NoteType_Image_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_Image_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a  ${LOG}

