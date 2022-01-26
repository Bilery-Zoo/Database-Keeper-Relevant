#!/usr/bin/env bash
# author    : Bilery Zoo(bilery.zoo@gmail.com)
# create_ts : 2022-02-25
# program   : loop a mysql query result


for db in $(mysql --login-path=mypath -N -e "SELECT \`schema_name\` FROM \`information_schema\`.\`schemata\` LIMIT 4;")
do
    # do something. eg:
	echo ${db}
done
