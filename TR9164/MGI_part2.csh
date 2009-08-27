#!/bin/csh -fx

#
# Migration for Cre Promoter - TR9164 -- 4.2x Cre Release
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp
setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

# environment variables for related back-end products
setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}


##############################################################################
###               --- Anatomical System vocab ---                          ###
##############################################################################

###----
###--- Insert new Anatomical System vocab ---###
###----
./insertAdSystems.py ${MGD_DBSERVER} ${MGD_DBNAME} ${MGI_DBUSER} ${MGI_DBPASSWORDFILE} ./data/AdSystems.txt | tee -a ${LOG}


###----
###--- Add new _System_key column to GXD_Structure ---###
###----
./modifyGxdStructure.csh

###----
###--- Make Structure->System associations ---###
###----
./assocAdSystems.py ${MGD_DBSERVER} ${MGD_DBNAME} ${MGI_DBUSER} ${MGI_DBPASSWORDFILE} ./data/AdSystems.txt | tee -a ${LOG}



##############################################################################
###             --- New Cre Cache table to bind them all ---               ###
##############################################################################

###----
###--- Make Allele->System CRE Cache Table ---###
###----
./createCreCache.csh





###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "Finished migration" | tee -a ${LOG}

