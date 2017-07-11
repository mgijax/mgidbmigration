#!/bin/csh -f

#
# migration of jfilescanner
# pdfs only
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

#setenv MASTERTRIAGEDIR '/data/littriage'
#rm -rf ${MASTERTRIAGEDIR}/[0-9]*

date | tee -a ${LOG}
echo 'migrating jfilescanner pdfs only'
./jfilescannerpdf.py | tee -a $LOG || exit 1

