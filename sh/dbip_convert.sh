#!/bin/bash
#
# build sqlite ip database from db-ip.com csv file
# Usage:
#	./dbip_convert.sh database_filename csv_filename
#

[ -z "$1" -o -z "$2" ] && echo "Usage: $0 /path/to/database /path/to/csv" && exit 1
[ -z `which sqlite3` ] && echo "sqlite3 cmd not found!!!" && exit 1

orig_tbl='CREATE TABLE `ip_tmp` ( 
  `ip_start` varbinary(16) NOT NULL,
  `ip_end` varbinary(16) NOT NULL,
  `country` char(2) NOT NULL,
  `stateprov` varchar(80) NOT NULL,
  `city` varchar(80) NOT NULL,
  PRIMARY KEY (`ip_start`)
);'

final_tbl='CREATE TABLE `ip` (
  `is_ipv6` integer(1) NOT NULL DEFAULT 0,
  `ip_start` varbinary(16) NOT NULL,
  `ip_end` varbinary(16) NOT NULL,
  `country` char(2) NOT NULL,
  `stateprov` varchar(80) NOT NULL,
  `city` varchar(80) NOT NULL,
  PRIMARY KEY (`ip_start`)
);'

db_file="$1"
csv_data="$2"

[ ! -f "$csv_data" ] && echo "$csv_data csv file not exist..." && exit 1

sqlite3 "$db_file" "$orig_tbl" &&
sqlite3 "$db_file" "$final_tbl" &&
sqlite3 -csv "$db_file" ".import $csv_data ip_tmp" &&
sqlite3 "$db_file" "insert into ip (ip_start, ip_end, country, stateprov, city) select * from ip_tmp;" &&
sqlite3 "$db_file" "update ip set is_ipv6=1 where ip_start like '_%:_%'" &&
sqlite3 "$db_file" "drop table ip_tmp;" &&
sqlite3 "$db_file" "vacuum;"

[ $? -ne 0 ] && echo "Building database failed" && exit 1

cnt=`sqlite3 "$db_file" 'select count(ip_start) from ip'`
ipv6_cnt=`sqlite3 "$db_file" 'select count(ip_start) from ip where is_ipv6=1'`

echo Building database successfully
echo Finding $ipv6_cnt ipv6 in $cnt ip

