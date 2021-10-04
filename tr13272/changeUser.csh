#!/bin/csh -f

#
# Template
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
 
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select login, _user_key from mgi_user where login in ('hjd', 'dmitrys', 'dph', 'ln', 'sr');

--dbo                    dbo             hjd     hjd     
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate1
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'dbo'
and e._modifiedby_key = u2._user_key and u2.login = 'dbo'
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1076, _modifiedby_key = 1076
from toUpdate1
where toUpdate1._annotevidence_key = VOC_Evidence._annotevidence_key
;

--dmitrys                mgd_dbo         dmitrys dmitrys 
--dmitrys                dbo             dmitrys dmitrys 
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate13
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'dmitrys'
and e._modifiedby_key = u2._user_key and u2.login in ('mgd_dbo', 'dbo')
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1452, _modifiedby_key = 1452
from toUpdate13
where toUpdate13._annotevidence_key = VOC_Evidence._annotevidence_key
;

--dph                    mgd_dbo         dph     dph     
--dph                    dbo             dph     dph     
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate4
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'dph'
and e._modifiedby_key = u2._user_key and u2.login in ('mgd_dbo', 'dbo')
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1072, _modifiedby_key = 1072
from toUpdate4
where toUpdate4._annotevidence_key = VOC_Evidence._annotevidence_key
;

--hjd                    mgd_dbo         hjd     hjd     
--hjd                    dbo             hjd     hjd     
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate6
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'hjd'
and e._modifiedby_key = u2._user_key and u2.login in ('mgd_dbo', 'dbo')
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1076, _modifiedby_key = 1076
from toUpdate6
where toUpdate6._annotevidence_key = VOC_Evidence._annotevidence_key
;


--ln                     mgd_dbo         ln      ln      
--ln                     dbo             ln      ln      
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate8
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'ln'
and e._modifiedby_key = u2._user_key and u2.login in ('mgd_dbo', 'dbo')
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1085, _modifiedby_key = 1085
from toUpdate8
where toUpdate8._annotevidence_key = VOC_Evidence._annotevidence_key
;

--sr                     dbo             sr      sr      
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate10
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'sr'
and e._modifiedby_key = u2._user_key and u2.login = 'dbo'
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1213, _modifiedby_key = 1213
from toUpdate10
where toUpdate10._annotevidence_key = VOC_Evidence._annotevidence_key
;

--tr11029_annotload      tr11029_annotload       hjd     hjd     
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate11
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'tr11029_annotload'
and e._modifiedby_key = u2._user_key and u2.login = 'tr11029_annotload'
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1076, _modifiedby_key = 1076
from toUpdate11
where toUpdate11._annotevidence_key = VOC_Evidence._annotevidence_key
;

--tr9612_annotload       tr9612_annotload        dmitrys dmitrys 
select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
into temp table toUpdate12
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login = 'tr9612_annotload'
and e._modifiedby_key = u2._user_key and u2.login = 'tr9612_annotload'
and v._object_key = m._Marker_key
;

update VOC_Evidence
set _createdby_key = 1452, _modifiedby_key = 1452
from toUpdate12
where toUpdate12._annotevidence_key = VOC_Evidence._annotevidence_key
;

--- final check

select m.symbol, e.*, u1.login as createdBy, u2.login as modifiedBy
from VOC_Annot v, VOC_Evidence e, MGI_User u1, MGI_User u2, MRK_Marker m
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u1._user_key and u1.login in ('mgd_dbo', 'dbo', 'tr11029_annotload', 'tr9612_annotload')
and e._modifiedby_key = u2._user_key
and v._object_key = m._Marker_key
;

EOSQL

./orcid1.csh | tee -a $LOG
./orcid2.csh | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a $LOG

date |tee -a $LOG
