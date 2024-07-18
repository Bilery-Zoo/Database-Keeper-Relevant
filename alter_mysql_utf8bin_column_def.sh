#!/usr/bin/env bash
# creator : Bilery Zoo(bilery.zoo@gmail.com)


_ifs=$IFS
IFS=$'\n'
for catch_res in $(mysql --login-path=dba --ssl-mode=DISABLED --skip-column-names --silent --execute=' \
    SELECT \
        c.`TABLE_SCHEMA`, \
        c.`TABLE_NAME`, \
        c.`COLUMN_NAME` \
    FROM \
        `information_schema`.`COLUMNS` AS c \
    WHERE \
        c.`TABLE_SCHEMA` NOT IN ("mysql", "information_schema", "performance_schema", "sys") \
        AND c.`COLLATION_NAME` LIKE "%bin" \
    ; \
')
do
    TABLE_SCHEMA=$(echo ${catch_res} | cut --fields=1)
    TABLE_NAME=$(echo ${catch_res} | cut --fields=2)
    COLUMN_NAME=$(echo ${catch_res} | cut --fields=3)
    for table_ddl in $(mysql --login-path=dba --ssl-mode=DISABLED --skip-column-names --silent --vertical --execute="SHOW CREATE TABLE \`${TABLE_SCHEMA}\`.\`${TABLE_NAME}\`;")
    do
        if [ $(echo ${table_ddl} | grep -c "^[[:space:]]\{2\}\`${COLUMN_NAME}\`") -eq 1 ]; then
            column_ddl=$(echo ${table_ddl} | grep "^[[:space:]]\{2\}\`${COLUMN_NAME}\`" | sed -e 's/^[[:space:]]\{2\}//; s/ utf8 / utf8mb4 /; s/utf8_bin/utf8mb4_bin/; s/,$//')
            echo "ALTER TABLE \`${TABLE_SCHEMA}\`.\`${TABLE_NAME}\` CHANGE COLUMN \`${COLUMN_NAME}\` ${column_ddl};"
        fi
    done
done
IFS=${_ifs}
