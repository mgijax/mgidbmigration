#!/bin/csh -f

#
# Load VOC structures
#	- Vocabluaries
#	- DAGs
#	- Annotations
#

cd `dirname $0`

setenv DBSERVER $1
setenv DBNAME $2
setenv DBUSER		mgd_dbo
setenv DBPASSWORDFILE	/usr/local/mgi/dbutils/mgidbutilities/.mgd_dbo_password
setenv SYBASE		/opt/sybase
setenv PYTHONPATH 	/usr/local/mgi/lib/python
setenv VOCLOAD		/usr/local/mgi/dataload/vocload
setenv ANNOTLOAD	/usr/local/mgi/dataload/annotload
setenv GODATA		/usr/local/mgi/go_data
setenv PSDATA		/mgi/all/wts_projects/2200/2239
set path = (/usr/local/mgi/dbutils/mgidbutilities/bin $path $SYBASE/bin)

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
# Load GO Annotations
echo "GO Annotation Load" >> $LOG
# get the latest spreadsheet from titan 
rcp titan:/usr/local/mgi/go_data/ontology.txt ${GODATA}
${ANNOTLOAD}/gomarker.csh $DBSERVER $DBNAME ${GODATA}/ontology.txt new >>& $LOG

./posttr2867.csh $DBSERVER $DBNAME >>& $LOG

date >> $LOG

