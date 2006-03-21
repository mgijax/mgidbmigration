#!/bin/csh -fx

# for SNP

cd `dirname $0` && source ./Configuration

source ${new2snpdbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${MGIDBUTILSBINDIR}/turnonbulkcopy.csh ${SNP_DBSERVER} ${SNP_DBNAME} | tee -a ${LOG}

# drop existing data structures

${new2snpdbschema}/all_drop.csh | tee -a ${LOG}

# create snp..MGI_dbinfo table...

${new2snpdbschema}/table/MGI_dbinfo_create.object | tee -a ${LOG}
${new2snpdbperms}/public/table/MGI_dbinfo_grant.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${SNP_DBNAME}
go

insert MGI_dbinfo values ("$PUBLIC_VERSION", "$SNP_PRODUCTNAME", "$SNP_SCHEMA_TAG", "$SNP_DATAVERSION",
getdate(), getdate(), getdate())
go

quit

EOSQL

# create new objects in snp
${new2snpdbschema}/all_create.csh | tee -a ${LOG}
${new2snpdbperms}/all_grant.csh | tee -a ${LOG}

foreach i (MGI_Columns)
${MGIDBUTILSBINDIR}/bcpout.csh ${new2mgddbschema} ${i} | tee -a ${LOG}
${new2snpdbschema}/index/${i}_drop.object | tee -a ${LOG}
${MGIDBUTILSBINDIR}/bcpin.csh ${new2snpdbschema} ${i} | tee -a ${LOG}
${new2snpdbschema}/index/${i}_create.object | tee -a ${LOG}
end

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${SNP_DBNAME}
go

exec MGI_Table_Column_Cleanup
go

quit

EOSQL

date | tee -a  ${LOG}

