#!/bin/csh -fx

#
# Migration for HIPPO TR12267
# (part 2 - run loads)
#
# Products:
# fearload
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Load HPO Vocab ---"  | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh HPO.config

date | tee -a ${LOG}
echo "--- Load MP/HPO relationships ---"  | tee -a ${LOG}
${MPHPOLOAD}/bin/mp_hpoload.sh

date | tee -a ${LOG}
echo "--- Load OMIM/HPO annotations ---"  | tee -a ${LOG}
${OMIMHPOLOAD}/bin/omim_hpoload.sh

#
# must have TR12267 branch of htmpload installed to run this
#
date | tee -a ${LOG}
echo "--- Run mgp load  ---"  | tee -a ${LOG}
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/impcmgpload.config  ${HTMPLOAD}/annotload.config

date | tee -a ${LOG}
echo "--- Run europhenome load  ---"  | tee -a ${LOG}
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/impceurompload.config ${HTMPLOAD}/annotload.config

date | tee -a ${LOG}
echo "--- Running HPO Annotation Report  ---"  | tee -a ${LOG}
./omim_mp_hpo_jsb.py
cp omim_mp_hpo_jsb.rpt /mgi/all/wts_projects/12200/12267/reports/omim_mp_hpo_jsb.rpt

echo "--- done running loads ---" | tee -a ${LOG}

date | tee -a ${LOG}
