#!/bin/csh -f -x

#
# Annotation Load Wrapper
#
#

source ./Configuration

setenv MODE		append
setenv ANNOTTYPE		"Mammalian Phenotype/Genotype"
setenv ANNOTATIONFILE		mpannotations.rpt
setenv DELETEREFERENCE		"J:0"

echo 'Annotation Load'
date

set annotdir = `dirname $0`

./mpannotations.py

# load the Annotation File
${ANNOTLOAD}/annotload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -M${MODE} -I${ANNOTATIONFILE} -A"${ANNOTTYPE}" -R${DELETEREFERENCE}

date

