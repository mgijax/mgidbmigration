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


###----
###--- load knock-in allele notes; derived buy substring matching nomenclature
###--- to identify the allele, and using it's marker's symbol as the promoter
###----
./insertCreKnockInNotes.py ${MGD_DBSERVER} ${MGD_DBNAME} ${MGI_DBUSER} ${MGI_DBPASSWORDFILE} | tee -a ${LOG}

###----
###--- load transgenic allele notes from file
###----
./insertCreTransgenicNotes.py ${MGD_DBSERVER} ${MGD_DBNAME} ${MGI_DBUSER} ${MGI_DBPASSWORDFILE} ./data/TransgenicPromoters.txt | tee -a ${LOG}


###----
###--- Insert new Anatomical System vocab 
###----
./insertAdSystems.py ${MGD_DBSERVER} ${MGD_DBNAME} ${MGI_DBUSER} ${MGI_DBPASSWORDFILE} ./data/AdSystems.txt | tee -a ${LOG}


###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "Finished migration" | tee -a ${LOG}

