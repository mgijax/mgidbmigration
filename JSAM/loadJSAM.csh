#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# create the MGI_dbinfo table
createloadMGIdbinfo.csh ${newmgddbschema} ${newmgddbperms} ${PUBLIC_VERSION} ${PRODUCT_NAME} ${SCHEMA_TAG}

date | tee -a  ${LOG}

