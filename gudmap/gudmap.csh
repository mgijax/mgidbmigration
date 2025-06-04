#!/bin/csh -f

#
# Template
#
# fewi/src/main/webapp/WEB-INF/properties/externalUrls.properties
# GUDMAP=http://www.gudmap.org/gudmap/pages/ish_submission.html?id=@@@@
# GUDMAP.ldb=GUDMAP
# GUDMAP.name=GUDMAP
#
# gxdload
# gxdimageload
# pwi/static/app/edit/image/image_content.html
# pwi/static/app/edit/image/help.html
# qcreports_db/mgd/GXD_Stats.py
# 

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

(
select a1.accid, a2.accid as gid, n.note
into temp table gudmap
from acc_accession a1, acc_accession a2, img_image i, mgi_note n
where a1._mgitype_key = 9
and a1._logicaldb_key = 1
and a1._object_key = i._image_key
and i._image_key = n._object_key
and n._notetype_key in (1024)
and a1._object_key = a2._object_key
and a2._logicaldb_key = 163
union
select a1.accid, null, n.note
from acc_accession a1, img_image i, mgi_note n
where a1._mgitype_key = 9
and a1._logicaldb_key = 1
and a1._object_key = i._image_key
and i._image_key = n._object_key
and n.note ilike '%gudmap%'
and n._notetype_key in (1024)
and not exists (select 1 from acc_accession a2
	where a1._object_key = a2._object_key
	and a2._logicaldb_key = 163
	)
)
order by accid
;

select * from gudmap;

--select regexp_replace(note, 'Zoom capability for the image(s) can be accessed via the GUDMAP link at the bottom of this page. ', '', 'g') from gudmap;
 
--delete from acc_accession where _logicaldb_key = 163;
--delete from acc_logicaldb where _logicaldb_key = 163;

EOSQL

date |tee -a $LOG

