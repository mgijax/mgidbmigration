#!/bin/csh -f

#
# lib_py_vocabbrowser : retire
# vocload
# mgidbmigration
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
 
# CGI.py is still used by webshare, mgihome, wksilver
# at some point, DAG.py, Node.py can be removed from this product
rm -rf ${LIBDIRS/CGI.py ${LIBDIRS}/DAG.py ${LIBDIRS}/Node.py
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
${VOCLOAD}/runOBOIncLoad.sh MP.config

date |tee -a $LOG

