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
 
switch (`uname -n`)
    case bhmgiapp01:
        setenv JFILESUBSET 'J' 
        breaksw
    default:
        setenv JFILESUBSET 'J240'
        breaksw
endsw

date | tee -a ${LOG}
echo 'migrating jfilescanner pdfs only'
./jfilescannerpdf.py | tee -a $LOG || exit 1

