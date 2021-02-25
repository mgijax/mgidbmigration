#!/bin/csh -f

cd `dirname $0` && source ./Configuration

umask 002

setenv LOG ${REPORTLOGSDIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

${PYTHON} GO_gene_association_gocam.py >>& ${LOG}
cd ${REPORTOUTPUTDIR}
foreach i (go_cam_gene_association.mgi go_cam_gene_association_pro.mgi go_cam_mgi.gpad mgi.gpi)
    cp -p $i ${FTPCUSTOM}
end

exit 0
