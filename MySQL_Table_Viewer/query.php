<?php
/*
    * create_author : Bilery Zoo(652645572@qq.com)
    * create_time   : 2018-11-22
    * program       : *_* SQL query *_*
*/


$sql = <<<QUERY

    SELECT
        t.`TABLE_NAME` AS `table_name`,
        t.`TABLE_SCHEMA` AS `table_schema`,
        t.`TABLE_COMMENT` AS `table_comment`,
        GROUP_CONCAT(CONCAT(c.`COLUMN_NAME`, ': ', c.`COLUMN_TYPE`, '; ', c.`COLUMN_COMMENT`, CHAR(13)) SEPARATOR '') AS `table_column`
    FROM `information_schema`.`TABLES` AS t
    INNER JOIN `information_schema`.`COLUMNS` AS c
    USING(`TABLE_NAME`)
    WHERE 1 > 0

QUERY;


?>