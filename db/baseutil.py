#!/usr/bin/env python
# -*- coding: utf-8 -*-


def str_dict_key(_dict):
    """
    Convert dict keys in Python's built-in Bytes data type to formatted str type.
    """
    dict_ = {}
    for subs in _dict:
        dict_[subs.decode("utf-8")] = _dict[subs]
    return dict_


def str_dict_value(_dict):
    """
    Convert dict values in Python's built-in Bytes and / or other data types to formatted str type.
    """
    for subs in _dict:
        if _dict[subs]:
            try:
                _dict[subs] = _dict[subs].decode("utf-8")
            except AttributeError:
                _dict[subs] = str(_dict[subs])


def wild_ref_key(_dict, key):
    """
    Wild do key call.
    """
    try:
        return _dict[key]
    except (KeyError, TypeError,):
        return None


def get_file_path():
    """
    Get father package's OS path of current module file.
    """
    path = ""
    path_list = __file__.split("/")[0:-3]
    for path_sets in path_list:
        path = path + path_sets + "/"
    return path


def strict_builtin_zip(*args):
    """
    Rewritten built-in zip() to strictly check length of inputted iterator args.
    """
    col = set()
    for arg in args:
        col.add(len(arg))
    if len(col) == 1:
        return zip(*args)
    else:
        return None


def lines_str_aggregation(multi_line_str: str) -> str:
    single_line_str = ''
    for line in multi_line_str.split('\n'):
        if line:
            single_line_str += line.lstrip() + ' '
    return single_line_str


if __name__ == "__main__":
    MariaDB_Table_Company = {
        "database": "database",
        "table": "table",
        "items": [],
    }
    print(wild_ref_key(MariaDB_Table_Company, "database"))
