#!/bin/csh -f

#
# Migration for OMIM
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup
#${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}

loadVOC.csh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

declare @annotTypeKey integer
select @annotTypeKey = max(_AnnotType_key) + 1 from VOC_AnnotType

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'OMIM'

declare @evidenceKey integer
select @evidenceKey = _Vocab_key from VOC_Vocab where name = 'OMIM Evidence Codes'

insert into VOC_AnnotType values(@annotTypeKey, 12, @vocabKey, @evidenceKey, 'OMIM/Genotype', getdate(), getdate())
go

end

EOSQL

date | tee -a  ${LOG}
