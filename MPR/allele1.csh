#!/bin/csh -f -x

#
# Load Associations
#
# Usage:
# 	allele1.csh schemadir inputfile mode
#
# Example:
#	allele1.csh /usr/local/mgi/live/dbutils/mgd/mgddbschema infile full
#

setenv SCHEMADIR	$1
setenv INPUTFILE	$2
setenv MODE		$3

# definition of the voc association type
setenv ASSOCTYPE	"Allele QF Category"
setenv ASSOCDEF		"Allele QF Categories to Allele Type"
setenv VOCAB1		"Allele Category 1"
setenv VOCAB2		"Allele Type"
setenv CREATEDBY	"mgd_dbo"

source ${SCHEMADIR}/Configuration

setenv LOG	$0.log
rm -rf $LOG
touch $LOG

echo 'Allele QF Category-To-Allele Type Load' > $LOG
date >>& $LOG

# load the File
${ASSOCLOAD}/vocassociationload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} >>& $LOG

date >>& $LOG

