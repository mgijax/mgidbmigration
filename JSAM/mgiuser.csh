#!/bin/csh -f

#
# Migration for MGI User
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "MGI User Migration..." | tee -a $LOG
 
#
# Use new schema product to create new table
#
${newmgddbschema}/table/MGI_User_create.object >>& $LOG
${newmgddbschema}/default/MGI_User_bind.object >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

declare @activeKey  integer
select @activeKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "Active" and t._Vocab_key = v._Vocab_key and v.name = "User Status"

declare @inactiveKey  integer
select @inactiveKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "Inactive" and t._Vocab_key = v._Vocab_key and v.name = "User Status"

declare @seKey  integer
select @seKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "SE" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @baKey  integer
select @baKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "BA" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @dboKey  integer
select @dboKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "DBO" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @curKey  integer
select @curKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "Curator" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @pubKey  integer
select @pubKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "Public" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @supportKey  integer
select @supportKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "User Support" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @piKey  integer
select @piKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "PI" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @loaderKey  integer
select @loaderKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "Data Load" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

declare @mergerKey  integer
select @mergerKey = _Term_key from VOC_Term t, VOC_Vocab v 
where t.term = "Merger" and t._Vocab_key = v._Vocab_key and v.name = "User Type"

/* DBO */

insert into MGI_User values (1000, @dboKey, @activeKey, "dbo", "Database Operator", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1001, @dboKey, @activeKey, "mgd_dbo", "MGD Database Operator", 1000, 1000, getdate(), getdate())

/* Public */

insert into MGI_User values (1002, @pubKey, @activeKey, "mgd_public", "Public MGI", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1003, @pubKey, @activeKey, "mouseblast", "MouseBLAST MGI", 1000, 1000, getdate(), getdate())

/* Software Engineers */

insert into MGI_User values (1010, @seKey, @activeKey, "kub", "Kirk Barsanti", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1011, @seKey, @activeKey, "jsb", "Jon Beal", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1012, @seKey, @activeKey, "jeffc", "Jeff Campbell", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1013, @seKey, @activeKey, "lec", "Lori Corbani", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1014, @seKey, @activeKey, "sc", "Sharon Cousins", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1015, @seKey, @activeKey, "djd", "Diane Dahmen", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1016, @seKey, @activeKey, "jlewis", "Jill Lewis", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1017, @seKey, @activeKey, "mikem", "Mike McCrossin", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1018, @seKey, @activeKey, "dbm", "David Miers", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1020, @seKey, @activeKey, "mbw", "Michael Walker", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1021, @seKey, @activeKey, "mjv", "Matthew Vincent", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1023, @seKey, @activeKey, "jw", "Josh Winslow", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1024, @seKey, @activeKey, "dow", "David O. Walton", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1025, @seKey, @activeKey, "pf", "Peter Frost", 1000, 1000, getdate(), getdate())

/* BioAnalyst */

insert into MGI_User values (1030, @seKey, @activeKey, "blk", "Ben King", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1031, @curKey, @activeKey, "rmb", "Richard Baldarelli", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1032, @curKey, @activeKey, "mdolan", "Mary Dolan", 1000, 1000, getdate(), getdate())

/* PI */

insert into MGI_User values (1040, @curKey, @activeKey, "jblake", "Judy Blake", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1041, @curKey, @activeKey, "cjb", "Carol Bult", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1042, @curKey, @activeKey, "jte", "Janan Eppig", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1043, @piKey, @activeKey, "jak", "Jim Kadin", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1044, @piKey, @activeKey, "ringwald", "Martin Ringwald", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1045, @piKey, @activeKey, "jer", "Joel Richardson", 1000, 1000, getdate(), getdate())

/* User Support */

insert into MGI_User values (1051, @supportKey, @activeKey, "ps", "Paul Szauter", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1052, @curKey, @activeKey, "drs", "David Shaw", 1000, 1000, getdate(), getdate())

/* Curators */

insert into MGI_User values (1060, @curKey, @activeKey, "not specified", "Not Specified", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1061, @curKey, @activeKey, "bat", "Ben Taylor", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1062, @curKey, @activeKey, "bobs", "Bob Sinclair", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1063, @curKey, @activeKey, "cml", "Cathy Lutz", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1064, @curKey, @activeKey, "cms", "Connie Smith", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1065, @curKey, @activeKey, "csmith", "Cindy Smith", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1066, @curKey, @activeKey, "cwg", "Carroll Goldsmith", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1067, @curKey, @activeKey, "dab", "Dale Begley", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1068, @curKey, @activeKey, "dbradt", "Dirck Bradt", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1069, @curKey, @activeKey, "djr", "Debbie Reed", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1070, @curKey, @activeKey, "dlb", "Donna Burkart", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1071, @curKey, @activeKey, "dmk", "Debbie Krupke", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1072, @curKey, @activeKey, "dph", "David Hill", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1073, @curKey, @activeKey, "dq", "Donnie Qi", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1074, @curKey, @activeKey, "fantom2", "Fantom2", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1075, @curKey, @activeKey, "hdene", "Howard Dene", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1076, @curKey, @activeKey, "hjd", "Harold Drabkin", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1077, @curKey, @activeKey, "ijm", "Ingeborg McCright", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1078, @curKey, @activeKey, "il", "Ira Lu", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1079, @curKey, @activeKey, "jeo", "Janice Ornsby", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1080, @curKey, @activeKey, "jfinger", "Jacqueline Finger", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1081, @curKey, @activeKey, "ksf", "Ken Frazer", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1082, @curKey, @activeKey, "lhg", "Lucette Glass", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1083, @curKey, @activeKey, "ljm", "Lois Maltais", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1084, @curKey, @activeKey, "llw2", "Linda Washburn", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1085, @curKey, @activeKey, "ln", "Li Ni", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1086, @curKey, @activeKey, "mlp", "Moyha Lennon-Pierce", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1087, @curKey, @activeKey, "neb", "Nancy Butler", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1088, @curKey, @activeKey, "plg", "Patricia Grant", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1089, @curKey, @activeKey, "pvb", "Pierre Vanden Borre", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1090, @curKey, @activeKey, "rjc", "Rebecca Corey", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1091, @curKey, @activeKey, "terryh", "Terry Hayamizu", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1092, @curKey, @activeKey, "wjb", "John Boddy", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1093, @curKey, @activeKey, "yz", "Yunixa Sophia Zhu", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1094, @curKey, @activeKey, "adiehl", "Alex Diehl", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1095, @curKey, @activeKey, "tbreddy", "TBK Reddy", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1096, @curKey, @activeKey, "tca", "Theresa Allio", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1097, @curKey, @activeKey, "furuno", "Masaaki Furuno", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1098, @curKey, @activeKey, "smb", "Sue Bello", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1099, @curKey, @activeKey, "anna", "Anna Anagnostopoulos", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1100, @curKey, @activeKey, "brs", "Beverly Richards-Smith", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1101, @curKey, @activeKey, "mac", "Megan Cassell", 1000, 1000, getdate(), getdate())

/* Inactive */

insert into MGI_User values (1200, @curKey, @inactiveKey, "ajp", "Antonio J. Planchart", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1204, @curKey, @inactiveKey, "srp", "Stephanie Pretel", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1205, @curKey, @inactiveKey, "tc", "Teresa Chu", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1206, @curKey, @inactiveKey, "lly", "Longlong Yang", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1207, @piKey, @inactiveKey, "mtd", "Muriel Davisson", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1208, @curKey, @inactiveKey, "gxd editor", "Anonymous GXD Editor", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1209, @curKey, @inactiveKey, "apd", "Alan Davis", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1210, @curKey, @inactiveKey, "retired_editors", "Retired Editors", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1211, @curKey, @inactiveKey, "unknown editor", "Unknown Editor", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1213, @curKey, @inactiveKey, "sr", "Sridhar Ramachandran", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1214, @curKey, @inactiveKey, "lmm", "Louise McKenzie", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1215, @curKey, @inactiveKey, "dnaf", "Dieter Naf", 1000, 1000, getdate(), getdate())

/* Loaders */
insert into MGI_User values (1300, @loaderKey, @activeKey, "jsam_load", "JSAM Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1301, @loaderKey, @activeKey, "RPCI_Load", "RPCI Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1302, @loaderKey, @activeKey, "fantom2_autoload", "Fantom2 (RIKEN) Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1303, @loaderKey, @activeKey, "swissload", "SwissPROT Association Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1304, @loaderKey, @activeKey, "riken_autoload", "Fantom1 (RIKEN) Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1305, @loaderKey, @activeKey, "rh_mapped_est_autoload", "RH Mapped EST Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1306, @loaderKey, @activeKey, "MGI_2.97", "GXD Release (MGI 2.97)", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1307, @loaderKey, @activeKey, "MGI_2.98", "MGI 2.98", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1308, @loaderKey, @activeKey, "genbank_load", "GenBank Sequence Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1309, @loaderKey, @activeKey, "refseq_load", "RefSeq Sequence Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1310, @loaderKey, @activeKey, "swissprot_seqload", "SwissPROT Sequence Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1311, @loaderKey, @activeKey, "trembl_load", "TrEMBL Sequence Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1312, @loaderKey, @activeKey, "dots_load", "DoTS Sequence Load", 1000, 1000, getdate(), getdate())
insert into MGI_User values (1313, @loaderKey, @activeKey, "tigr_load", "TIGR Sequence Load", 1000, 1000, getdate(), getdate())

/* Mergers */
insert into MGI_User values (1400, @mergerKey, @activeKey, "strainmerge", "Strain Merge", 1000, 1000, getdate(), getdate())

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MGI_User_create.object >> $LOG

date >> $LOG

