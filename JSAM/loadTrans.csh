#!/bin/csh -f

#
# Load Translations
#

cd `dirname $0` && source ./Configuration
cd translationload

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "Translation Migration..." | tee -a ${LOG}
 
${TRANSLOAD}/gender.csh $DBSERVER $DBNAME gender.badgood full >>& ${LOG}
${TRANSLOAD}/organism.csh $DBSERVER $DBNAME organism.badgood full >>& ${LOG}
${TRANSLOAD}/provider.csh $DBSERVER $DBNAME provider.badgood full >>& ${LOG}
${TRANSLOAD}/sequencetype.csh $DBSERVER $DBNAME sequencetype.badgood full >>& ${LOG}
${TRANSLOAD}/tissue.csh $DBSERVER $DBNAME tissue.badgood full >>& ${LOG}
${TRANSLOAD}/cellline.csh $DBSERVER $DBNAME cellline.badgood full >>& ${LOG}
${TRANSLOAD}/library.csh $DBSERVER $DBNAME library.badgood full >>& ${LOG}
${TRANSLOAD}/strain.csh $DBSERVER $DBNAME strain.badgood full >>& ${LOG}
${TRANSLOAD}/orgtostrain.csh $DBSERVER $DBNAME orgtostrain.badgood full >>& ${LOG}

date >> ${LOG}
