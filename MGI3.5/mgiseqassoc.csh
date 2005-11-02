#!/bin/csh -fx

#
# TR 6138
#

source ./Configuration

setenv LOG	`basename $0`.log
rm -rf $LOG
touch $LOG

date | tee -a ${LOG}

# create new Assoc table

${newmgddbschema}/table/SEQ_Marker_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Marker_Assoc_bind.object | tee -a ${LOG}
${newmgddbschema}/key/SEQ_Marker_Assoc_create.object | tee -a ${LOG}
${newmgddbperms}/public/table/SEQ_Marker_Assoc_grant.object | tee -a ${LOG}

${newmgddbschema}/trigger/ACC_Accession_drop.object | tee -a ${LOG}

# load marker associations into new table
./mgiseqassoc.py | tee -a ${LOG}
cat ${DBPASSWORDFILE} | bcp ${DBNAME}..SEQ_Marker_Assoc in SEQ_Marker_Assoc.bcp -c -t\| -S${DBSERVER} -U${DBUSER} | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

/*delete ACC_AccessionReference */
/*from tempdb..markers m, ACC_AccessionReference r */
/*where m._Accession_key = r._Accession_key */
/*go */

/*delete ACC_Accession */
/*from tempdb..markers m, ACC_Accession r */
/*where m._Accession_key = r._Accession_key */
/*go */

quit

EOSQL

${newmgddbschema}/index/SEQ_Marker_Assoc_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/ACC_Accession_create.object | tee -a ${LOG}

date | tee -a ${LOG}

