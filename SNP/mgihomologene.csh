#!/bin/csh -f

#
# Migration for HomoloGene (TR 7110)
#
#

#cd `dirname $0` && source ./Configuration
cd `dirname $0` && source ./Configuration.lec

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "HomoloGene Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

/* remove all ortholog records for J:87419 and J:90500 */

delete from HMD_Homology where _Refs_key in (88402, 91485)
go

/* delete orphan class records */

delete HMD_Class from HMD_Class c where not exists (select h.* from HMD_Homology h where c._Class_key = h._Class_key)
go

quit

EOSQL

setenv MODE		preview
#setenv MODE		load
setenv	CREATEDBY	tbreddy

setenv DATAFILE	/mgi/all/wts_projects/7100/7110/MouseHuman2Load.txt
setenv	HOMKEYS		n
cd homoloGeneHuman
${ORTHOLOAD}/orthologyload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -R${RADARDB} -M${MODE} -I${DATAFILE} -C${CREATEDBY} -K${HOMKEYS}

#setenv DATAFILE	/mgi/all/wts_projects/7100/7110/MouseRat2Load.txt
#setenv	HOMKEYS		y
#cd ../homoloGeneRat
#${ORTHOLOAD}/orthologyload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -R${RADARDB} -M${MODE} -I${DATAFILE} -C${CREATEDBY} -K${HOMKEYS}

cd ..

date | tee -a $LOG

