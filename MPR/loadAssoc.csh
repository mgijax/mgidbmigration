#!/bin/csh -f

#
# Load VOC associations
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date > ${LOG}
echo "Vocabulary Association Migration..." | tee -a ${LOG}
 
./allele1.csh ${newmgddbschema} allele1.in full >>& ${LOG}

date >> ${LOG}
