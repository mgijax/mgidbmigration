#!/bin/csh -f

#
# Migration for imsr bug TR7949
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
########################################

# load a backup
load_db.csh ${IMSR_DBSERVER} ${IMSR_DBNAME} /shire/sybase/imsr.backup | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${IMSR_DBSERVER} ${IMSR_DBNAME} $0 | tee -a ${LOG}


use ${IMSR_DBNAME}
go

/* rename Allele to save it for now */
sp_rename Allele, Allele_Old
go


/* create new Allele table without _Gene_key */
create table Allele (
        _Allele_key                    int             not null,
        creation_date                  datetime        not null,
        modification_date              datetime        not null,
        release_date                   datetime        null
)
go

/* insert from old to new */
insert into Allele
select _Allele_key, creation_date, modification_date, release_date
from Allele_Old
go

/* create Allele keys */
sp_primarykey Allele, _Allele_key
go

sp_foreignkey AlleleMutationAssoc, Allele, _Allele_key
go

sp_foreignkey SGAAssoc, Allele, _Allele_key
go

/* create Allele indexes */
create unique clustered index idx_Allele_key on Allele (_Allele_key)
go

/* drop Gene foreign key to Allele - don't need to do this, must get */
/* dropped automatically */

/* set public permissions on Allele */
grant select on Allele  to public
go

/* now run orphan strains SP */
exec IMSR_cleanupOrphanStrains
go

EOSQL

date | tee -a  ${LOG}

