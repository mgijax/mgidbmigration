#!/bin/csh -fx

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

###----------------------###
###--- add new tables ---###
###----------------------###

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/VOC_Evidence_Property_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/VOC_Evidence_Property_create.object | tee -a ${LOG}

# add defaults for new tables

date | tee -a ${LOG}
echo "--- Dropping/Adding defaults" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/default/VOC_Evidence_Property_bind.object | tee -a ${LOG}

# drop/add keys and indexes for new tables

date | tee -a ${LOG}
echo "--- Dropping/Adding keys" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/VOC_Evidence_Property_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Evidence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/VOC_Evidence_Property_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding trigger" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding views" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/VOC_EvidenceProperty_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/VOC_Term_GOProperty_View_create.object | tee -a ${LOG}

# add permissions

date | tee -a ${LOG}
echo "--- Adding perms" | tee -a ${LOG}

${MGD_DBPERMSDIR}/curatorial/table/VOC_Evidence_Property_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/table/VOC_Evidence_Property_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/VOC_EvidenceProperty_View_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/VOC_Term_GOProperty_View_grant.object | tee -a ${LOG}

