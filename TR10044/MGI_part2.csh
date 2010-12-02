#!/bin/csh -fx

#
# Migration part 2 for TR10044
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

#date | tee -a ${LOG}
#echo 'UniProt Load/GO part only' | tee -a ${LOG}
#${UNIPROTLOAD}/bin/makeGOAnnot.sh

#date | tee -a ${LOG}
#echo 'Load GOA annotations' | tee -a ${LOG}
#${GOALOAD}/bin/goa.csh

#date | tee -a ${LOG}
#echo 'GO/Rat Load' | tee -a ${LOG}
#${GORATLOAD}/bin/gorat.sh

#date | tee -a ${LOG}
#echo 'GO/RefGenome Load' | tee -a ${LOG}
#${GOREFGENLOAD}/bin/gorefgen.sh

#date | tee -a ${LOG}
#echo 'Load GOA/Human annotations' | tee -a ${LOG}
#${GOAHUMANLOAD}/bin/goahuman.sh

#date | tee -a ${LOG}
#echo 'GOCFP Load' | tee -a ${LOG}
#${GOCFPLOAD}/bin/gocfp.sh

#date | tee -a ${LOG}
#echo 'Save MGI_Note/MGI_NoteChunk before we migrate' | tee -a ${LOG}
#./savenotes.csh

date | tee -a ${LOG}
echo 'Migrate Notes' | tee -a ${LOG}
./migratenotes.py > migratenotes.log.$$

date | tee -a ${LOG}
echo 'Generate report of what-is-left after migration' | tee -a ${LOG}
./cleanup-whatisleft.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
