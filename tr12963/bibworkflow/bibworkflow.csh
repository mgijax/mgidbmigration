#!/bin/csh -f

#
# has tr12963 branch:
# littriageload
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
 
#
# BIB_Workflow_Data : add new field extractedTextWithRef
#
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Data_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Workflow_Data_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/ACC_assignJ_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.BIB_Workflow_Data DROP CONSTRAINT BIB_Workflow_Data__Refs_key_fkey CASCADE;
ALTER TABLE mgd.BIB_Workflow_Data DROP CONSTRAINT BIB_Workflow_Data_pkey CASCADE;
ALTER TABLE mgd.BIB_Workflow_Data DROP CONSTRAINT BIB_Workflow_Data__Supplemental_key_fkey CASCADE;
ALTER TABLE BIB_Workflow_Data RENAME TO BIB_Workflow_Data_old;
ALTER TABLE mgd.BIB_Workflow_Data_old DROP CONSTRAINT BIB_Workflow_Data_pkey CASCADE;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into BIB_Workflow_Data
select (nextval('bib_workflow_data_seq')),
d._refs_key, 
d.hasPDF, 
d._supplemental_key, 
d.linkSupplemental, 
48804490,
d.extractedText,
d._createdBy_key, d._modifiedBy_key, d.creation_date, d.modification_date
from BIB_Workflow_Data_old d
;

--ALTER TABLE mgd.BIB_Workflow_Data ADD PRIMARY KEY (_Assoc_key);
ALTER TABLE mgd.BIB_Workflow_Data ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Data ADD FOREIGN KEY (_Supplemental_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Data ADD FOREIGN KEY (_ExtractedText_key) REFERENCES mgd.VOC_Term DEFERRABLE;

ALTER TABLE mgd.BIB_Workflow_Data ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Data ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Status ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Status ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Tag ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Tag ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE; 

delete from VOC_Term where _vocab_key = 134 and sequenceNum > 1;
update VOC_Vocab set name = 'Lit Triage Journal : ignore splitter' where _vocab_key = 134;
update VOC_Term set term = 'Nature' where _Term_key = 37583021;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/ACC_assignJ_create.object | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from BIB_Workflow_Data_old;
select count(*) from BIB_Workflow_Data;
drop table mgd.BIB_Workflow_Data_old;

-- update pwi_reports

update PWI_Report 
set 
description = 
'Search Extracted Text : body + start methods + supplemental data + autor manuscript fig legands.
Exclude references.
Note:  extracted text is pre-supplementary data

<A HREF="http://www.theasciicode.com.ar/extended-ascii-code/degree-symbol-ascii-code-248.html">http://www.theasciicode.com.ar/extended-ascii-code/degree-symbol-ascii-code-248.html</A>
',
sql_text =
'select r.pubmedID
from BIB_Citation_Cache r, BIB_Workflow_Data d
where r._Refs_key = d._Refs_key
and d._ExtractedText_key not in (48804491) 
and lower(d.extractedText) like lower(''%###Extracted Text###%'')
'
where id = 14
;

update PWI_Report
set
description =
'
References where:
. is not Discard
. group = Tumor
. status = Not Routed
. tag is not Tumor:NotSelected
. extracted text (body, supplemental) like
%tumo%
%inoma%
%adenoma%
%sarcoma%
%lymphoma%
%neoplas%
%gioma%
%papilloma%
%leukemia%
%leukaemia%
%ocytoma%
%thelioma%
%blastoma%
%hepatoma%
%melanoma%
%lipoma%
%myoma%
%acanthoma%
%fibroma%
%teratoma%
%glioma%
%thymoma%
',
sql_text = 
'
WITH ref_results AS (
select r.mgiID, d.extractedText
from BIB_Citation_Cache r, BIB_Workflow_Status s, BIB_Workflow_Data d
where r.isDiscard = 0
and r.jnumID is not null
and r._Refs_key = s._Refs_key
and s.isCurrent = 1
and s._Group_key = 31576667
and s._Status_key = 31576669
and r._Refs_key = d._Refs_key
and d._ExtractedText_key in (48804490, 48804492)
and not exists (select 1 from BIB_Workflow_Tag tt
     where r._Refs_key = tt._Refs_key
     and tt._Tag_key in (32970313))
)
(
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%tumo%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%inoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%adenoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%sarcoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%lymphoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%neoplas%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%gioma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%papilloma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%leukemia%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%leukaemia%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%ocytoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%thelioma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%blastoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%hepatoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%melanoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%lipoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%myoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%acanthoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%fibroma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%teratoma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%glioma%'')
 union
 select r.mgiID from ref_results r where lower(r.extractedText) like lower(''%thymoma%'')
)
order by mgiID
'
where id = 17
;

EOSQL

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#update BIB_Workflow_Data
#set extractedText = extractedText + referenceSection, referenceSection = null
#where referenceSection is not null
#;
#EOSQL

#./bibworkflow.py | tee -a $LOG

#
# not all pdfs wind up with reference sections
#

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#
#-- those that do not have referenceSection
#-- after running the refsection-resolver
#select count(d._refs_key) as counter
#from BIB_Refs r, BIB_Workflow_Data d
#where r._referencetype_key = 31576687
#and r._refs_key = d._refs_key
#and d.extractedText is not null
#and d.referenceSection is null
#;
#
#-- those that do have referenceSection
#-- after running the refsection-resolver
#select count(d._refs_key) as counter
#from BIB_Refs r, BIB_Workflow_Data d
#where r._referencetype_key = 31576687
#and r._refs_key = d._refs_key
#and d.extractedText is not null
#and d.referenceSection is not null
#;
#
#EOSQL

date |tee -a $LOG

