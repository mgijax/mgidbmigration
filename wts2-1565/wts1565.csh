#!/bin/sh

#
# Template
#

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi
. ${MGICONFIG}/master.config.sh

cd `dirname $0`

export LOG=$0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#--insert into mgi_user values(1667,316353,316350,'littriage_gxdht','littriage_gxdht',null,null,1000,1000,now(),now());
#--delete from bib_refs where _createdby_key = 1667;
#select distinct p.value
#from GXD_HTExperiment e, ACC_Accession a, MGI_Property p
#where e._curationstate_key = 20475421 /* Done */
#and e._experiment_key = a._object_key
#and a._mgitype_key = 42 /* ht experiment type */
#and a.preferred = 1
#and e._experiment_key = p._object_key 
#and p._mgitype_key = 42
#and p._propertyterm_key = 20475430
#and not exists (select 1 from BIB_Citation_Cache c where p.value = c.pubmedid)
#order by p.value
#;
#
#EOSQL
#

#$PYTHON getpdfs.py | tee -a $LOG

cd littriage_gxdht
for i in *tar.gz
do
bfile=`basename $i .tar.gz`
pid=$(echo `basename $i .tar.gz` | cut -d"_" -f1)
pmc=$(echo `basename $i .tar.gz` | cut -d"_" -f2)
echo $pid
gunzip -f $i
tar -xvf $bfile.tar
rm -rf 'PMID_'$pid.pdf
for p in $pmc/*pdf
do
pmid=PMID_$pid.pdf
cat $p >> $pmid
break
done
rm -rf $pmc
done
cd ..

date | tee -a $LOG

