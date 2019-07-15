#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""
create_author : Bilery Zoo(652645572@qq.com)
create_time   : 2019-06-09
program       : *_* MySQL/MariaDB handler utility *_*
"""


import sys
import typing

import baseutil

import log
logger = log.LOG().logger()

c_flag = False
try:
    import _mysql_connector
except ModuleNotFoundError:
    logger.warning('Import "_mysql_connector" failed, fall back to strictly use "mysql.connector"...')
else:
    c_flag = True
finally:
    import mysql.connector

DBException = _mysql_connector.MySQLInterfaceError if c_flag else mysql.connector.errors.Error


def generate_insert(table, items: dict, database='', is_escape_string=False, con=None, charset="utf-8") -> str:
    """
    Generate INSERT statement of SQL DML.
    """
    destination = "`{database}`.`{table}`".format(database=database, table=table) if database else "`{table}`".format(table=table)
    sql_l = "INSERT INTO {destination} ("
    sql_r = ") VALUES ("
    for column in items:
        data = items[column]
        if data == 0 or data:
            if is_escape_string:
                assert c_flag and con
                data = con.escape_string(str(data)).decode(charset)
            sql_l += "`{key}`, ".format(key=column)
            sql_r += "'{value}', ".format(value=data)
    sql = sql_l[0:-2] + sql_r[0:-2] + ");"
    return sql.format(destination=destination)


def generate_where(items: dict, alias: str = '') -> str:
    """
    Generate WHERE statement of SQL.
    """
    alias += '.' if alias else ''
    statement = "WHERE"
    for column in items:
        statement += " {alias}`{column}` {value} AND".format(alias=alias, column=column, value=items[column])
    return statement[:-4]


def generate_group_by(columns, alias: str = '') -> str:
    """
    Generate GROUP BY statement of SQL.
    """
    alias += '.' if alias else ''
    statement = "GROUP BY"
    for column in columns:
        statement += " {alias}`{column}`,".format(alias=alias, column=column)
    return statement[:-1]


def get_con(use_c_api=True, charset="utf8", use_unicode=False, autocommit=False, **kwargs):
    """
    Get MySQL connection.
    """
    if use_c_api and c_flag:
        con = _mysql_connector.MySQL()
        con.connect(**kwargs)
        con.set_character_set(charset)
        con.use_unicode(use_unicode)
        con.autocommit(autocommit)
        con.query("SET NAMES {charset};".format(charset=charset))
        con.query("SET CHARACTER SET {charset};".format(charset=charset))
        con.query("SET character_set_connection={charset};".format(charset=charset))
        con.commit()
        return con
    if use_c_api and not c_flag:
        logger.warning('Get "_mysql_connector" failed, fall back to strictly use "mysql.connector"...')
    return mysql.connector.connect(charset=charset, use_unicode=use_unicode, autocommit=autocommit, **kwargs)


@log.log(logger=logger)
def execute_sql_quiet(con, sql, use_c_api=True, is_commit=True, is_close=True, is_exit=False,
                      is_raise=True, is_info=True):
    """
    Execute SQL(DDL, DML, DCL etc) in quiet mode(with no return).
    """
    cur = con.cursor() if not use_c_api else None
    try:
        if use_c_api:
            con.query(sql)
        else:
            cur.execute(sql)
    except DBException as E:
        con.rollback()
        if is_exit:
            sys.exit(E)
        if is_raise:
            raise
    else:
        if is_commit:
            con.commit()
    finally:
        if is_close:
            if not use_c_api:
                cur.close()
            con.close()
        if is_info:
            logger.info(baseutil.combine_lines_str(sql))


@log.log(logger=logger)
def execute_sql_return(con, sql, use_c_api=True, dictionary=True, is_close=True, is_exit=False, is_raise=True,
                       is_info=True, **kwargs) -> typing.Generator:
    """
    Execute SQL(DQL) in return mode(with return).
    """
    cur = con.cursor(dictionary=dictionary, **kwargs) if not use_c_api else None
    try:
        if use_c_api:
            con.query(sql)
        else:
            cur.execute(sql)
    except DBException as E:
        con.rollback()
        if is_exit:
            sys.exit(E)
        if is_raise:
            raise
    else:
        if use_c_api:
            column_list = []
            if dictionary:
                columns = con.fetch_fields()
                for column in columns:
                    column_list.append(column[4])
            row_tuple = con.fetch_row()
            while row_tuple:
                if dictionary:
                    row_zip = zip(column_list, row_tuple)
                    row = {}
                    for sub in row_zip:
                        row[sub[0]] = sub[1]
                    baseutil.str_dict_value(row)
                    yield baseutil.str_dict_key(row)
                else:
                    yield row_tuple
                row_tuple = con.fetch_row()
        else:
            for row in cur:
                if dictionary:
                    baseutil.str_dict_value(row)
                    yield baseutil.str_dict_key(row)
                else:
                    yield row
    finally:
        if is_close:
            con.free_result()
            if not use_c_api:
                cur.close()
            con.close()
        if is_info:
            logger.info(baseutil.combine_lines_str(sql))


@log.log(logger=logger)
def check_dql_existence(con, sql, use_c_api=True, is_exit=False, is_raise=True, is_close=True, is_info=True) -> bool:
    """
    Check whether SQL(DQL) query has result to return or not.
    """
    cur = con.cursor(raw=True) if not use_c_api else None
    try:
        if use_c_api:
            con.raw(True)
            con.query(sql)
        else:
            cur.execute(sql)
    except DBException as E:
        con.rollback()
        if is_exit:
            sys.exit(E)
        if is_raise:
            raise
    else:
        if use_c_api:
            return True if con.fetch_row() else False
        else:
            return True if cur.fetchone() else False
    finally:
        if is_close:
            con.free_result()
            if not use_c_api:
                cur.close()
            con.close()
        if is_info:
            logger.info(baseutil.combine_lines_str(sql))


if __name__ == "__main__":
    CON = {
        "con": {
            "host": "localhost",
            "port": 3306,
            "user": "root",
            "password": "1024",
            "database": "information_schema",
        },
        "charset": "utf8",
        "use_unicode": True,
        "autocommit": False,
    }
    con_c = get_con(**CON["con"])
    con_p = get_con(use_c_api=False, **CON["con"])
    items = {
        "col1": "= 1",
        "col2": "> 2",
    }
    print(generate_insert(table="tab", database="dbs", items=items))
    print(generate_where(items, "_tmp"))
    print(generate_group_by(items.keys(), "_tmp"))
    # print(execute_sql_quiet(con_c, "CREATE DATABASE `mdbutil`;"))
    # print(execute_sql_quiet(con_p, "DROP DATABASE `mdbutil`;", use_c_api=False))
    # sql_t = 'SELECT `TABLE_NAME`, `CREATE_TIME` FROM `information_schema`.`TABLES` LIMIT 2;'
    sql_f = 'SELECT `TABLE_NAME`, `CREATE_TIME` FROM `information_schema`.`TABLES` WHERE `TABLE_NAME` = "NULL" LIMIT 2;'
    print(check_dql_existence(con_p, sql_f, use_c_api=False))
    # print(check_dql_existence(con_c, sql_t))
    # for r in execute_sql_return(con_p, sql_t, use_c_api=False, is_info=False, dictionary=False):
    #     print(r)
    # for r in execute_sql_return(con_c, sql_t, use_c_api=True, is_info=False, dictionary=False):
    #     print(r)
