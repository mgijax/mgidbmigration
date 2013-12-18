#!/bin/csh -fx

#
# Run all vocabulary loads - US 131
#  re-testing of US121, factor out vocload libraries, after scrum-dog release
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

echo 'running MP vocload'
${VOCLOAD}/runOBOIncLoad.sh MP.config 

echo 'running GO vocload'
${VOCLOAD}/runOBOIncLoad.sh GO.config

echo 'running IP vocload'
${VOCLOAD}/runSimpleFullLoad.sh IP.config

echo 'running MA vocload'
${VOCLOAD}/runOBOIncLoad.sh MA.config

echo 'running OMIM vocload'
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config

date | tee -a ${LOG}
