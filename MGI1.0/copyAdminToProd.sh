#!/bin/csh

#
# Copy $SYBASE/admin database scripts to Production
# By copying the actual SCCS files
#
# This script should be run on titan only!
#

# Development SCCS directories
set fromSCCS = /export/src/mgd/sybase/sybase_dev

# Production SCCS directories
set toSCCS = /export/src/mgd/sybase/sybase_prod

# Production installation directories
set toDir = $SYBASE/admin/

#
# Copy triggers, views, store procedures
# rules, defaults, tables are new
#

cd $toDir
foreach i (rules defaults tables)
mkdir $toDir/$i
mkdir $toSCCS/$i
mkdir $toSCCS/$i/SCCS
cd $toDir/$i
ln -s $toSCCS/$i/SCCS
end

cd $toDir
foreach i (`ls -d schema triggers views procedures permissions rules defaults tables indexes`)
cd $i
rm -rf $toSCCS/$i/SCCS/s.*
cp $fromSCCS/$i/SCCS/s.* $toSCCS/$i/SCCS
sccs get SCCS
chmod +x *
cd ..
end

#
# Copy utility files
#

cd $toDir/utilities
foreach i (RI_Summary.py RI_Summary.sql loadHomology.sh loadHomology.py)
rm -rf $toSCCS/utilities/SCCS/s.$i
cp $fromSCCS/utilities/SCCS/s.$i $toSCCS/utilities/SCCS
sccs get $i
chmod +x $i
end

# New directories

cd $toDir/utilities
foreach i (AccessionLoad EST FREEMAN IDDS MRK SWISS-PROT)
mkdir $toDir/utilities/$i
mkdir $toSCCS/utilities/$i
mkdir $toSCCS/utilities/$i/SCCS
cd $toDir/utilities/$i
ln -s $toSCCS/utilities/$i/SCCS
end

# New MRK subdirectory

foreach i (AccessionLoad EST FREEMAN IDDS MRK SWISS-PROT strains
mkdir $toDir/utilities/$i
mkdir $toSCCS/utilities/$i
mkdir $toSCCS/utilities/$i/SCCS
cd $toDir/utilities/$i
ln -s $toSCCS/utilities/$i/SCCS .
end

cd $toDir/utilities
foreach i (`ls -d AccessionLoad EST FREEMAN MIT MRK SWISS-PROT crossloads rircloads strains`)
cd $i
rm -rf $toSCCS/utilities/$i/SCCS/s.*
cp $fromSCCS/utilities/$i/SCCS/s.* $toSCCS/utilities/$i/SCCS
sccs get SCCS
chmod +x *
cd ..
end

# New MLC subdirectory and MLC/transfer subdirectory 

if ! -d $toDir/utilities/MLC then
mkdir $toDir/utilities/MLC
mkdir $toDir/utilities/MLC/transfer
mkdir $toSCCS/utilities/MLC
mkdir $toSCCS/utilities/MLC/transfer
mkdir $toSCCS/utilities/MLC/transfer/SCCS
cd $toDir/utilities/MLC/transfer
ln -s $toSCCS/utilities/MLC/transfer/SCCS .
endif

cd $toDir/utilities/MLC
foreach i (`ls -d transfer`)
cd $i
cp $fromSCCS/utilities/MLC/$i/SCCS/s.* $toSCCS/utilities/MLC/$i/SCCS
sccs get SCCS
chmod +x *
cd ..
end

#
# Remove any obsolete things
#

rm -rf $toDir/utilities/createMRK_Name.sql
rm -rf $toSCCS/utilities/SCCS/s.createMRK_Name.sql
rm -rf $fromSCCS/utilities/SCCS/s.createMRK_Name.sql
rm -rf $toDir/utilities/createMRK_Reference.sql
rm -rf $toSCCS/utilities/SCCS/s.createMRK_Reference.sql
rm -rf $fromSCCS/utilities/SCCS/s.createMRK_Reference.sql
rm -rf $toDir/utilities/createMRK_Symbol.sql
rm -rf $toSCCS/utilities/SCCS/s.createMRK_Symbol.sql
rm -rf $fromSCCS/utilities/SCCS/s.createMRK_Symbol.sql
rm -rf $toDir/utilities/createoffsets.sql
rm -rf $toSCCS/utilities/SCCS/s.createoffsets.sql
rm -rf $fromSCCS/utilities/SCCS/s.createoffsets.sql
rm -rf $toDir/procedures/PRB.pr
rm -rf $toSCCS/procedures/SCCS/s.PRB.pr
rm -rf $fromSCCS/procedures/SCCS/s.PRB.pr
rm -rf $toDir/procedures/MLC.drop
rm -rf $toSCCS/procedures/SCCS/s.MLC.drop
rm -rf $fromSCCS/procedures/SCCS/s.MLC.drop
rm -rf $toDir/procedures/Proc.drop
rm -rf $fromSCCS/procedures/SCCS/s.Proc.drop

cd $toDir
