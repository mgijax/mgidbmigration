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
setenv PYTHONPATH 	/usr/local/mgi/lib/python
setenv VOCLOAD		/usr/local/mgi/dataload/vocload
setenv ANNOTLOAD	/home/lec/loads/annotload
setenv GODATA		/usr/local/mgi/go_data
setenv PSDATA		/mgi/all/wts_projects/2200/2239

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
# Load VOC tables; this order is important!

${VOCLOAD}/phenoslim.load -f  -l output.phenoslim ps.rcd ${PSDATA}/phenoslim.out >>& $LOG
${VOCLOAD}/phenoslim.ec.load -f -l output.phenoslim.ec ps.ec.rcd ${PSDATA}/ps.ecodes >>& $LOG
${VOCLOAD}/go.ec.load -f -l output.go.ec go.ec.rcd ${GODATA}/go.ecodes >>& $LOG

# Create Annotation Type records

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into VOC_AnnotType
values(1000,2,4,3,"GO/Marker", getdate(), getdate())
go

insert into VOC_AnnotType
values(1001,12,1,2,"PhenoSlim/Genotype", getdate(), getdate())
go

/* not needed if we run go.load */
insert into VOC_Vocab
values(4, 73993, 31, 0, 0, "GO", getdate(), getdate())
go

EOSQL

${VOCLOAD}/loadTerms.py -f -l output.terms $DBSERVER $DBNAME mgd_dbo `cat $DBPASSWORDFILE` 4 TermFile >>& $LOG

# Load PhenoSlim Annotations

${ANNOTLOAD}/phenoslimgenotype.csh $DBSERVER $DBNAME pslim.csmith.tab csmith new >>& $LOG
${ANNOTLOAD}/phenoslimgenotype.csh $DBSERVER $DBNAME pslim.cwg.tab cwg append >>& $LOG
${ANNOTLOAD}/phenoslimgenotype.csh $DBSERVER $DBNAME pslim.il.tab il append >>& $LOG

# Load GO Annotations
${ANNOTLOAD}/gomarker.csh $DBSERVER $DBNAME ${GODATA}/ontology.txt new >>& $LOG

./posttr2867.csh $DBSERVER $DBNAME >>& $LOG

date >> $LOG

