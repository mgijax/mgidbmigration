#!/bin/csh

############################################################################
#
#  Author:	R. Palazola
#  Date:	9/15/1999
#  Version: @(#)migrateEST.sh	1.1
#
#  Purpose:
#   Handle the details of performing the EST consolidation migration.
#    
#  Usage:
#
############################################################################




if ( $#argv < 2 || $1 == "-h" || $1 == "--help") then
	echo "Usage: migrateEST.sh <SERVER> <DATABASE> [<BlockSize>]"
	exit (1)
endif

if ( $#argv > 2 ) then
	set blockSize=$3
else
	set blockSize=50000
endif

setenv DSQUERY $1
setenv MGD $2

set log="migrateEST.$DSQUERY.$MGD.log"
set prbTR="PRB.tr"
set chkStatus = 0

# run the check scripts to determine if there are any residual problems
# can use $chkStatus to accummulate results



# would need to pause and review these if cannot determine if there
# are problems that should block the migration.
# 
if ( $chkStatus != 0 ) then
	echo 
	echo "Migration Not Run!"
	exit (-1)
endif

echo "Server: $DSQUERY" | tee $log
echo "Database: $MGD"   | tee -a $log
date | tee -a $log
echo "" | tee -a $log

# replace standard/official trigger with an optimized version
if ( $DSQUERY != "MGD" && -f ./$prbTR ) then
	echo "Replace PRB triggers for optimized PRB_Probe_Delete trigger" | \
	tee -a $log
	./$prbTR $DSQUERY $MGD

	echo "" | tee -a $log
endif

# clean up if table exists:
sqsh -S $DSQUERY -D $MGD -U mgd_dbo -P `cat $SYBASE/admin/.mgd_dbo_password` -e <<EOF
drop table tempdb..startMigration
go
return
EOF

# migrate
# pass in blockSize and database args to script and reset the prompt
# to minimise the "noise".
#sqsh -i migrateEST.sql -a1 -L blockSize=$blockSize -L MGD=$MGD \
#-L prompt='${lineno}> ' -S $DSQUERY  -D $MGD -e |& tee -a $log

# need to run as any user, so use mgd_dbo login
sqsh -i migrateEST.sql -a1 -L blockSize=$blockSize -L MGD=$MGD \
-L prompt='${lineno}> ' -S $DSQUERY -D $MGD \
-U mgd_dbo -P `cat $SYBASE/admin/.mgd_dbo_password` -e |& tee -a $log

set sqlStatus=$status
if ( $sqlStatus ) exit (-1)


