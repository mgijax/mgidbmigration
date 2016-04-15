#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# full path to mirror log directory
setenv MIRRORLOG        ${DATADOWNLOADS}/mirror_wget_logs

setenv CWD `pwd`        # current working directory

date 
echo "--- Starting in ${CWD}..."

foreach i (\
www.ebi.ac.uk.europhenome \
www.ebi.ac.uk.mgp \
)
echo $i
$i
end

date

