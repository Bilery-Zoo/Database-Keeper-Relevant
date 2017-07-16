# !/usr/bin/python
# -*- coding: utf-8 -*-


"""
author      : Bilery Zoo(652645572@qq.com)
create_time : 2017-03-19
program     : *_* Read table from MySQL and Write to MongoDB collection *_*
"""


import re
import time
import pymongo
import MySQLdb


class MySQLtoMongo:
    """
    Self test successfully under Python2.7.12
    """
    def __init__(self, ms_con, ms_db, ms_tb, mg_con, mg_db, mg_cl, default_key=True, ids_=None, add_tag=False):
        """
        Arguments set for data transformation job.
        Of main are database of MySQL and MongoDB.
        Default parameters are free for choosing.
        :param ms_con: string
            connection of MySQL
        :param ms_db: string
            database of MySQL data reads from
        :param ms_tb: string
            table of MySQL data reads from
        :param mg_con: string
            connection of MongoDB
        :param mg_db: string
            database of MongoDB data write to
        :param mg_cl: string
            collection of MongoDB data write to
        :param default_key: bool, default : True
            whether to add and use MongoDB default "_id" (it is very necessary if not MySQL table owns an unique column)
        :param ids_: string, default : None
            an MySQL table column uses to substitute as MongoDB collection "_id"(if not "default_key" an "ids_" is needed)
        :param add_tag: bool, default : False
            whether to add an timestamp column named "ts" as tag for each MongoDB collection documents when write
        """
        self.ms_con      = ms_con
        self.ms_db       = ms_db
        self.ms_tb       = ms_tb
        self.mg_con      = mg_con
        self.mg_db       = mg_db
        self.mg_cl       = mg_cl
        self.default_key = default_key
        self.ids_        = ids_
        self.add_tag     = add_tag

    def __repr__(self):
        return "<...{0} ^^^ {1}...>".format(self.ms_con, self.mg_con)

    def intnull(self, values):
        """
        ……\(^o^)/ Avoid TypeError of built_in int() used for None \(^o^)/……
        :param values: any which can transfer to built_in int() and None for a plus
        :return: int values
        """
        if values:
            values = int(values)
            return values

    def getkeys(self, column):
        """
        ……o(>﹏<)o Just do a friendly check whether MySQL column "ids_" can be as the role of MongoDB "_id" or not o(>﹏<)o……
        :param column: MySQL table column
        :return: key of the column
        """
        sql = """SELECT c.COLUMN_KEY
                FROM information_schema.`COLUMNS` c
                WHERE c.COLUMN_NAME = '{0}'
                AND c.TABLE_NAME = '{1}'
                AND c.TABLE_SCHEMA = '{2}';""".format(column, self.ms_tb, self.ms_db)
        cur_ = self.ms_con.cursor()
        cur_.execute(sql)
        data = cur_.fetchone()
        return data[0]

    def gettype(self, column):
        """
        ……o(>﹏<)o Just do a friendly check whether a MySQL column is needed to int() or not o(>﹏<)o……
        :param column: MySQL table column
        :return: type of the column
        """
        sql = """SELECT c.COLUMN_TYPE
                FROM information_schema.`COLUMNS` c
                WHERE c.COLUMN_NAME = '{0}'
                AND c.TABLE_NAME = '{1}'
                AND c.TABLE_SCHEMA = '{2}';""".format(column, self.ms_tb, self.ms_db)
        cur_ = self.ms_con.cursor()
        cur_.execute(sql)
        data = cur_.fetchone()
        return data[0]

    def getitem(self):
        """
        Do some judgement and get an original "key : value" relationship of MySQL table
        :return: an stored dict {column : record} of MySQL table
        """
        sql = """
                SELECT c.COLUMN_NAME, c.ORDINAL_POSITION - 1 AS ORDINAL_POSITION
                FROM information_schema.`COLUMNS` c
                WHERE c.TABLE_NAME = '{0}'
                AND c.TABLE_SCHEMA = '{1}';""".format(self.ms_tb, self.ms_db)
        cur_ = self.ms_con.cursor()
        cur_.execute(sql)
        res = cur_.fetchall()
        DIC = {}
        if   self.default_key == True:
            if self.ids_:
                print "Notice: argument set for \"ids_\"", "\033[1;31;40m", self.ids_, "\033[0m", "will be ignored"
            for row in res:
                typ = self.gettype(column=row[0])
                if re.findall(r"\Dt\(\d", typ):
                    DIC[row[0]] = "self.intnull(row[{0}])".format(int(row[1]))
                else:DIC[row[0]] = "row[{0}]".format(int(row[1]))
        elif self.default_key == False:
            if   self.ids_ == None:
                raise TypeError, "Argument \"ids_\" is not Given"
            elif self.ids_ != None:
                try:
                    key = self.getkeys(column=self.ids_)
                    if   key != "PRI" and key != "UNI":
                        print "Warning: ununique MySQL column", "\033[1;31;40m", self.ids_, "\033[0m", "may not use for MongoDB \"_id\""
                    elif key == "PRI" or  key == "UNI":
                        print "Get unique MySQL column", "\033[1;31;40m", self.ids_, "\033[0m", "use for MongoDB \"_id\""
                except Exception, e:
                    print(e)
            for row in res:
                typ = self.gettype(column=row[0])
                if re.findall(r"\Dt\(\d", typ):
                    if row[0] == self.ids_:
                        DIC["_id"] = "self.intnull(row[{0}])".format(int(row[1]))
                    else:
                        DIC[row[0]] = "self.intnull(row[{0}])".format(int(row[1]))
                else:
                    if row[0] == self.ids_:
                        DIC["_id"] = "row[{0}]".format(int(row[1]))
                    else:
                        DIC[row[0]] = "row[{0}]".format(int(row[1]))
        return DIC

    def getdata(self):
        """
        Read MySQL table data
        :return: tuples of MySQL table columns data
        """
        sql = "SELECT * FROM {0}.{1};".format(self.ms_db, self.ms_tb)
        cur_ = self.ms_con.cursor()
        cur_.execute(sql)
        data = cur_.fetchall()
        return data

    def wridata(self):
        """
        Write MongoDB collection data
        :return: None
        """
        if self.getdata():
            dire = "self.mg_con.{0}.{1}.insert(DATA)".format(self.mg_db, self.mg_cl)
            ITEM = self.getitem()
            for row in self.getdata():
                DATA = ITEM.copy()
                for i, j in DATA.items():
                    DATA[(i)] = eval(j)
                if self.add_tag:
                    DATA["ts"] = time.strftime("%Y-%m-%d %X")
                exec dire
        self.ms_con.close()
        self.mg_con.close()


# self test
if __name__ == "__main__":

    MySQLDB = {"host": "localhost",
               "user": "root",
               "passwd": "520",
               "port": 3306,
               "db": "information_schema",
               "charset": "UTF8"}
    con_mysql = MySQLdb.connect(**MySQLDB)

    MongoDB = {"host": "localhost",
               "port": 27017}
    con_mongo = pymongo.MongoClient(**MongoDB)

    STT = MySQLtoMongo(ms_con=con_mysql, ms_db="information_schema", ms_tb="TABLES",
                      mg_con=con_mongo, mg_db="information_schema", mg_cl="TABLES")
    print(STT)
    STT.wridata()
