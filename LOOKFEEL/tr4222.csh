#!/bin/csh -f

#
# TR 4222
#

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

update GXD_Specimen
set ageMin = 17.0, ageMax = 22.0
where age = "perinatal"
go

update GXD_Specimen
set ageMin = 21.01, ageMax = 1846.0
where age = "postnatal"
go

update GXD_Specimen
set ageMin = 21.01, ageMax = 25.0
where age = "postnatal newborn"
go

update GXD_Specimen
set ageMin = 25.01, ageMax = 42.0
where age = "postnatal immature"
go

update GXD_Specimen
set ageMin = 42.01, ageMax = 1846.0
where age = "postnatal adult"
go

update GXD_GelLane
set ageMin = 17.0, ageMax = 22.0
where age = "perinatal"
go

update GXD_GelLane
set ageMin = 21.01, ageMax = 1846.0
where age = "postnatal"
go

update GXD_GelLane
set ageMin = 21.01, ageMax = 25.0
where age = "postnatal newborn"
go

update GXD_GelLane
set ageMin = 25.01, ageMax = 42.0
where age = "postnatal immature"
go

update GXD_GelLane
set ageMin = 42.01, ageMax = 1846.0
where age = "postnatal adult"
go

update GXD_Expression
set ageMin = 17.0, ageMax = 22.0
where age = "perinatal"
go

update GXD_Expression
set ageMin = 21.01, ageMax = 1846.0
where age = "postnatal"
go

update GXD_Expression
set ageMin = 21.01, ageMax = 25.0
where age = "postnatal newborn"
go

update GXD_Expression
set ageMin = 25.01, ageMax = 42.0
where age = "postnatal immature"
go

update GXD_Expression
set ageMin = 42.01, ageMax = 1846.0
where age = "postnatal adult"
go

end

EOSQL

date >> $LOG

