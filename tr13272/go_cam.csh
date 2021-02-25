#!/bin/csh -f

cd `dirname $0` && source ../Configuration

umask 002

setenv LOG `basename $0`.log
rm -rf ${LOG}
touch ${LOG}

${PYTHON} go_cam_GO_gene_association.py >>& ${LOG}

foreach i (go_cam_gene_association.mgi go_cam_gene_association_pro.mgi go_cam_mgi.gpad)
    cp -p $i ${FTPCUSTOM}
end

cp -p ${PUBREPORTDIR}/output/mgi.gpi ${FTPCUSTOM}

