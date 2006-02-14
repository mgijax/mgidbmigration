#!/bin/csh -fx

#
# Migration for 3.44 (TR 7379)
#
# Defaults:       6
# Procedures:   122
# Rules:          5
# Triggers:     159
# User Tables:  192
# Views:        230
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${MGIDBUTILSDIR}/bin/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

# MGI_Tables...save data

./mgisnp.csh | tee -a ${LOG}
./mgimgd.csh | tee -a ${LOG}

# bcp the snp data out of mgd
${MGIDBUTILSDIR}/bin/bcpout.csh ${newmgddbschema} SNP_Consensus_Snp

# bcp the snp data into the new snp database

date | tee -a  ${LOG}

########################################

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* copy MGI_Columns and MGI_Tables information from mgd to snp */

exec MGI_Table_Column_Cleanup
go

use ${SNP_DBNAME}
go

exec MGI_Table_Column_Cleanup
go

quit

EOSQL

date | tee -a  ${LOG}

