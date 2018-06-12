#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: rule.py
import sys, os, re
from enum import Enum

__author__ = 'ituuz'

"""
转换规则脚本，这里配置各种转换的规则。
"""

ConvertType = Enum('ConvertType', ('replace', 'pattern'))

convert_rule = [
	# 规则1：local -> var
	[ConvertType.pattern, '(?<=\W)local +(\w+) *= *', 'var \g<1> = '],
	[ConvertType.pattern, '(?<=\W)local +(\w+)(?=\W)', 'var \g<1>'],
	# 规则2：xxx
	[ConvertType.pattern, "bb123s", "fds"]
]

# 内容替换逻辑
def convert(buf, ruleItem):
	if ruleItem[0] == ConvertType.replace:		# 字符串替换
		buf = buf.replace(ruleItem[1], ruleItem[2])
	elif ruleItem[0] == ConvertType.pattern:	# 正则表达式替换
		buf = re.sub(ruleItem[1], ruleItem[2], buf)
	return buf


