#!/bin/csh -f

#
# Migration for 3.4 (SNP)
# Defaults:       
# Procedures:   
# Rules:         
# Triggers:     
# User Tables: 
# Views:        

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}

#
# RADAR database stuff
#

./radar.csh

#
# MGD database stuff
#

echo "turnonbulkcopy" 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

echo "loading backup"
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

# update schema tag
echo "updatePublicVersion"
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
echo "updateSchemaVersion"
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

echo " create mgd table, key, index, default, view"
${newmgddbschema}/table/SNP_create.logical
${newmgddbschema}/key/SNP_create.logical
${newmgddbschema}/index/SNP_create.logical
${newmgddbschema}/default/SNP_bind.logical
${newmgddbschema}/view/SNP_Summary_View_create.object

echo " create mgd perms"
${newmgddbperms}/public/table/SNP_grant.logical
${newmgddbperms}/public/view/SNP_Summary_View_grant.object

echo "load MGITypes, MGI_User"
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

/* ACC_MGIType */
declare @mgiTypeKey integer
select @mgiTypeKey = max(_MGIType_key) + 1 from ACC_MGIType

insert into ACC_MGIType values(@mgiTypeKey, 'Consensus SNP', 'SNP_ConsensusSnp', '_ConsensusSnp_key', null, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @mgiTypeKey integer
select @mgiTypeKey = max(_MGIType_key) + 1 from ACC_MGIType

insert into ACC_MGIType values(@mgiTypeKey, 'Sub SNP', 'SNP_SubSnp', '_SubSnp_key', null, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @mgiTypeKey integer
select @mgiTypeKey = max(_MGIType_key) + 1 from ACC_MGIType

insert into ACC_MGIType values(@mgiTypeKey, 'SNP Marker', 'SNP_ConsensusSnp_Marker', '_ConsensusSnp_Marker_key', null, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

declare @mgiTypeKey integer
select @mgiTypeKey = max(_MGIType_key) + 1 from ACC_MGIType

insert into ACC_MGIType values(@mgiTypeKey, 'SNP Population', 'SNP_Population', '_Population_key', null, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

/* MGI_Set */
declare @setKey integer
select @setKey = max(_Set_key) + 1 from MGI_Set

insert into MGI_Set values(@setKey, 10, 'SNP Strains', 1, 1000, 1000, getdate(), getdate())
go

/* MGI_User */
declare @userKey integer
select @userKey = max(_User_key) + 1 from MGI_User

insert into MGI_User values(@userKey, 316353, 316350, 'dbsnp_load', 'dbSNP Load', 1000, 1000, getdate(), getdate())
go

declare @userKey integer
select @userKey = max(_User_key) + 1 from MGI_User

insert into MGI_User values(@userKey, 316353, 316350, 'snp_load', 'MGI SNP Load', 1000, 1000, getdate(), getdate())
go

declare @userKey integer
select @userKey = max(_User_key) + 1 from MGI_User

insert into MGI_User values(@userKey, 316353, 316350, 'PIRSF_Load', 'PIRSF Load', 1000, 1000, getdate(), getdate())
go

/* PIRSF vocabulary envidence codes */

declare @termkey integer
select @termkey = max(_term_key) + 1 from VOC_Term

declare @vocabkey integer
select @vocabkey = _vocab_key from voc_vocab where name = 'PIR Superfamily Evidence Codes'

insert into voc_term values (@termkey, @vocabkey, 'TAS', 'TAS', 1, 0, 1001, 1001, getdate(), getdate())


quit

EOSQL

echo "Running mgitranslation.csh"
./mgitranslation.csh

echo "Running dbsnpload"
${DBSNPLOAD}

echo "Running pirsfload"
${PIRSFLOAD}

echo "PIRSF: human/rat"
./mgicache.csh | tee -a ${LOG}

echo "HomoloGene"
./mgihomologene.csh | tee -a ${LOG}

#echo "schema reconfig; revoke/grant all"
#${newmgddbschema}/reconfig.csh | tee -a ${LOG}
#${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
#${newmgddbperms}/all_grant.csh | tee -a ${LOG}

#${DBUTILSBINDIR}/updateStatisticsAll.csh ${newmgddbschema} | tee -a ${LOG}

date | tee -a  ${LOG}

