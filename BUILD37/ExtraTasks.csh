#!/bin/csh -f

#
# This script runs extra tasks that are unrelated to Build 37, but will
# be bundled with the Build 37 release.
#

cd `dirname $0` && source ../Configuration

date
echo "$0"

#
# Load copyright notes for journals (TR 8962).
#
date
${DBUTILS}/mgidbmigration/BUILD37/journal.csh
