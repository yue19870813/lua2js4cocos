#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: rule.py
import sys, os, re
from enum import Enum

__author__ = 'ituuz'

"""
转换规则脚本，这里配置各种转换的规则。
"""

ConvertType = Enum('ConvertType', ('replace', 'pattern', 'function'))

convert_rule = [

	# 注释一部分代码
	[ConvertType.pattern, 'local *(\w+) *= *(require|import).*?\n', ''],
	# return 语句
	[ConvertType.pattern, '\nreturn *(\w+)', '\n// return \g<1>'],
	# 原来的对象 local Cheat = { };
	[ConvertType.pattern, '\nlocal *(\w+) *= *\{', '\n// var \g<1> = {'],

	# 常见关键字转换 例如：loacl end 等
	# local -> var
	[ConvertType.pattern, '(?<=\W)local +(\w+) *= *', 'var \g<1> = '],
	[ConvertType.pattern, '(?<=\W)local +(\w+)(?=\W)', 'var \g<1>'],

	# 处理函数相关问题
	[ConvertType.function, '', ''],
	# 匿名函数 function() ... end -> function() { ... }
	# 用([\w\{\(\:\.])做了限定,避免注释中的funtion()
	# [ConvertType.pattern, '(?<=\n)( *)([\w\{\(\:\.])(.*?)function\s*\((.*?)\)', '\g<1>\g<2>\g<3>function(\g<4>)\n\g<1>{'],
	# 局部函数 lua : local function callFunc() ... end -> js : var clickOkCallback = function() { ... }
	# [ConvertType.pattern, '(?<=\n)( *)local\s*function\s*(\w+?)\(([\s\S]*?)\)', '\g<1>var \g<2> = function(\g<3>)\n\g<1>{'],
	# [ConvertType.pattern, '(?<=\n)( *)function\s+([\w]+?):(ctor) *\(([\s\S]*?)\)',
	# 	'\g<1>\g<3> : function(\g<4>)\n\g<1>{\n    \g<1>this._super(\g<4>)'],
	# # 类函数 function GYPlayJI.PlayChong(pChair) ... end -> PlayChong : function(pChair) { ... }
	# [ConvertType.pattern, '(?<=\n)( *)function\s+([\w]+?)[.:]([\w]+?) *\(([\s\S]*?)\)',
	# 	'\g<1>\g<3> : function(\g<4>)\n\g<1>{'],


	########## 逻辑 ##########
	# 统一先处理下空格更好匹配
	[ConvertType.pattern, '(\]\(\)\'\"])(==|~=|and|or|not)(\s*)(\(\[\'\"])', '\g<1> \g<2>\g<3>\g<4>'],
	[ConvertType.pattern, '(\]\)\'\"])(\s*)(==|~=|and|or|not)(\(\[\'\"])', '\g<1>\g<2>\g<3> \g<4>'],
	# 逻辑 == -> === ; ~= -> != ; and -> && ; or -> || ; not -> ! ;
	[ConvertType.pattern, '(\s+)==(\s+)', '\g<1>===\g<2>'],
	[ConvertType.pattern, '(\s+)~=(\s+)', '\g<1>!=\g<2>'],
	[ConvertType.pattern, '(\s+)and(\s+)', '\g<1>&&\g<2>'],
	[ConvertType.pattern, '(\s+)or(\s+)', '\g<1>||\g<2>'],
	[ConvertType.pattern, '(\s+)not(\s+)', '\g<1>!\g<2>'],

	# 处理 if else  for  while 等


	# end -> }
	# [ConvertType.pattern, '(?<=\n)end *(?=\n)', '}'],
	# 普通的end,可能是函数的,也可能是if,for,while的
	# [ConvertType.pattern, '(?<=\W)end(?=\W)', '}'],

	# 多行注释 --[==[ 和 --]==]
	[ConvertType.pattern, '--\[=?\[', '/*'],
	[ConvertType.pattern, '\]=?\]', '*/'],
	# 单行注释(必须先处理多行注释)
	[ConvertType.replace, '--', '//']

]

# 对函数进行转换
# function Cheat:delete()  ->  Cheat.prototype.delete = function() {
def convertFunction(buf):
	match = re.search('(?<=\n)( *)function\s+([\w]+?)[.:]([\w]+?) *\(([\s\S]*?)\)', buf)

	while match:
		matchStr = match.group(0)
		# 获取类名和函数名
		idx1 = matchStr.find("function ")
		idx2 = matchStr.find(":")
		idx3 = matchStr.find("(")
		className = matchStr[idx1 + 9:idx2]
		functionName = matchStr[idx2 + 1:idx3]
		# 查找参数列表
		paramMatch = re.search('\(([\s\S]*?)\)', matchStr)
		paramStr = paramMatch.group(0)
		# 将lua类函数替换成js类函数格式
		buf = buf.replace(matchStr, className + ".prototype." + functionName + "=function" + paramStr + "{")
		# 递归查找下一个类函数
		match = re.search('(?<=\n)( *)function\s+([\w]+?)[.:]([\w]+?) *\(([\s\S]*?)\)', buf)
	return buf

# 内容替换逻辑
def convert(buf, ruleItem):
	if ruleItem[0] == ConvertType.replace:		# 字符串替换
		buf = buf.replace(ruleItem[1], ruleItem[2])
	elif ruleItem[0] == ConvertType.pattern:	# 正则表达式替换
		buf = re.sub(ruleItem[1], ruleItem[2], buf)
	elif ruleItem[0] == ConvertType.function:	# 特殊处理：函数转换
		buf = convertFunction(buf)
	return buf


