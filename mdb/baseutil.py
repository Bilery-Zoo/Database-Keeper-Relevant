#!/usr/bin/env python
# -*- coding: utf-8 -*-


"""
create_author : 蛙鳜鸡鹳狸猿
create_time   : 2019-06-06
program       : *_* base function utility *_*
"""


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


def lines_str_aggregation(multi_line_str: str) -> str:
    single_line_str = ''
    for line in multi_line_str.split('\n'):
        if line:
            single_line_str += line.lstrip() + ' '
    return single_line_str
