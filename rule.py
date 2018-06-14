#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: rule.py
import sys, os, re
from enum import Enum

__author__ = 'ituuz'

"""
转换规则脚本，这里配置各种转换的规则。
"""

ConvertType = Enum('ConvertType', ('replace', 'pattern', 'classFunc'))

convert_rule = [

	# 注释一部分代码
	[ConvertType.pattern, 'local *(\w+) *= *(require|import).*?\n', ''],
	# return 语句
	[ConvertType.pattern, '\nreturn *(\w+)', '\n// return \g<1>'],
	# 原来的对象 local Cheat = { };
	#[ConvertType.pattern, '\nlocal *(\w+) *= *\{', '\n// var \g<1> = {'],


	# 处理函数相关问题
	
	# 处理类函数
	[ConvertType.classFunc, '', ''],
	# 处理匿名函数
	[ConvertType.pattern, '([\s|,]+)function\s*(\((.*?)\))', '\g<1>function\g<2>{'],
	# 局部函数 lua : local function callFunc() . -> js : function clickOkCallback(...) { 
	[ConvertType.pattern, 'local\s*function\s*(\w+?)\(([\s\S]*?)\)', 'function (\g<2>) {'],

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
	[ConvertType.pattern, '(?<=\W)(if|while|until)\(', '\g<1> ('],
	[ConvertType.pattern, '\)(then|do)(?=\W)', ') \g<1>'],
	# lua : if ( condition ) then ... elseif ( condition ) then ... else ...end
	# js  : if (condition 1) { ... } else if (condition 2) { ... } else { ... }
	# 换行的else -> } else {
	[ConvertType.pattern, '( *)else *(?=\n)', '}else{'],
	# 同上,不在开头的else
	[ConvertType.pattern, '(?<=\n)( *)(\w.*?) +else *(?=\n)', '\g<1>\g<2>\n\g<1>}\n\g<1>else\n\g<1>{'],
	# 其他的else,不换行.上面两个替换之后都是(\n *else\n)的形式
	[ConvertType.pattern, '(?<=\W)else(--|//| +)', '} else {\g<1>'],

	# if -> if (
	[ConvertType.pattern, '(?<=\W)if\s+', 'if ('],
	# elseif -> } else if (
	[ConvertType.pattern, '(?<=\n)( *)elseif\s+', '\g<1>}\n\g<1>else if ('],
	[ConvertType.pattern, '(?<=\W)elseif\s+', '} else if ('],
	# then -> ) {
	[ConvertType.pattern, '(?<=\n)( *)(\w.*\S) +then *(?=\n)', '\g<1>\g<2>)\n\g<1>{'],
	[ConvertType.pattern, '(?<=\W)then(?=\W)', ') {'],

	# for 循环
	# lua : for init,max/min value, increment do ... end eg: for i=10,1,-1 do print(i) end
	# lua : for k , v in ipairs( list ) do ... end
	# js  : for (var i=0; i<5; i++) { ... }
	# js  : for (x in list) { txt=txt + x }
	# for i=10,1,-1 do ... end -> for (var i=10; i>=1; i--) { ... }
	[ConvertType.pattern, '(\t*)for\s*([\w]*?)\s*=\s*(.+?)\s*,\s*(.+?)\s*,\s*-(.+?)\s+do',
		'\g<1>'+'\n\g<1>for (var \g<2> = \g<3>; \g<2> >= \g<4>; \g<2> -= \g<5>) {'],
	[ConvertType.pattern, '(\t*)for\s*([\w]*?)\s*=\s*(.+?)\s*,\s*(.+?)\s*,\s*(.+?)\s+do',
		'\g<1>'+'\n\g<1>for (var \g<2> = \g<3>; \g<2> <= \g<4>; \g<2> += \g<5>) {'],
	# for i=1,5 do ... end -> for (var i=0; i<=5; i++) { ... }
	[ConvertType.pattern, '(\t*)for\s*([\w]*?)\s*=\s*(.+?)\s*,\s*(.+?)\s*do', 
		'\g<1>for (var \g<2> = \g<3>; \g<2> <= \g<4>; \g<2>++){'],
	# for k , v in ipairs(...) do ... end -> for (var i=0; i<5; i++) { ... }
	[ConvertType.pattern, '(\t*)for\s*([\w]*?)\s*,\s*([\w]*?)\s*in\s*ipairs\s*\(\s*(.*?)\s*\)\s*do',
		'\g<1>for (var \g<2> = 0; \g<2> < \g<4>.length; \g<2>++) {\n\g<1>\tvar \g<3> = \g<4>[\g<2>]'],
	# for k , v in pairs(...) do ... end -> for (x in ...) { ... }
	[ConvertType.pattern, '(\t*)for\s*([\w]*?)\s*,\s*([\w]*?)\s*in\s*pairs\s*\(\s*(.*?)\s*\)\s*do',
		'\g<1>for (var \g<2> in \g<4>) {\n\g<1>\tvar \g<3> = \g<4>[\g<2>]'],

	# while 循环
	# lua : while (condition) do statement(s) end
	# repeat statement(s) until( condition )
	# js  : while (i<5) { ... }
	# js  : do { ... } while (condition)
	[ConvertType.pattern, 'while\s+', 'while ('],
	# do -> ) {
	[ConvertType.pattern, '(\t*)(\w.*\S)?(?(2) )+do *(?=\n)', '\g<1>\g<2>) {'],
	[ConvertType.pattern, 'do(?=\W)', ') {'],
	# repeat -> do {
	[ConvertType.pattern, '(\t*)repeat *(?=\n)', '\g<1>do {'],
	[ConvertType.pattern, 'repeat(?=\W)', 'do {'],
	# until ... -> } while ( ... )
	[ConvertType.pattern, '(\t*)until +(.+?) *(--|//|\n)', '\g<1>} while (\g<2>)\g<3>'],
	[ConvertType.pattern, '(\t*)(\w.*\S) +until +(.+?) *(--|//|\n)', '\g<1>\g<2> } while (\g<3>)\g<4>'],


	# 常见关键字转换 例如：loacl end 等
	# nil -> undefined
	[ConvertType.pattern, '(?<=\W)nil\s*(==|~=)', 'undefined \g<1>'],
	[ConvertType.pattern, '(==|~=)\s*nil(?=\W)', '\g<1> undefined'],

	# 字符串拼接 .. -> +
	[ConvertType.pattern, '([\w\]\)\'\"])\s*\.\.\s*([\w\(\[\'\"])', '\g<1> + \g<2>'],
	# local -> var
	[ConvertType.pattern, '(?<=\W)local +(\w+) *= *', 'var \g<1> = '],
	[ConvertType.pattern, '(?<=\W)local +(\w+)(?=\W)', 'var \g<1>'],

	# end -> }
	[ConvertType.pattern, '(?<=\n)end *(?=\n)', '}'],
	# 普通的end,可能是函数的,也可能是if,for,while的
	[ConvertType.pattern, '(?<=\W)end(?=\W)', '}'],

	# 多行注释 --[==[ 和 --]==]
	[ConvertType.pattern, '--\[=?\[', '/*'],
	[ConvertType.pattern, '\]=?\]', '*/'],
	# 单行注释
	[ConvertType.replace, '--', '//']

]

# 对类函数进行转换
# function Cheat:delete()  ->  Cheat.prototype.delete = function() {
def convertClassFunction(buf):
	match = re.search('(?<=\n)( *)function\s+([\w]+?)[.:]([\w]+?) *\(([\s\S]*?)\)', buf)
	# 循环递归将类函数逐一处理
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
		match = re.search('(?<=\n)( *)function\s*([\w]+?)[.:]([\w]+?) *\(([\s\S]*?)\)', buf)
	return buf


# 内容替换逻辑
def convert(buf, ruleItem):
	if ruleItem[0] == ConvertType.replace:		# 字符串替换
		buf = buf.replace(ruleItem[1], ruleItem[2])
	elif ruleItem[0] == ConvertType.pattern:	# 正则表达式替换
		buf = re.sub(ruleItem[1], ruleItem[2], buf)
	elif ruleItem[0] == ConvertType.classFunc:	# 特殊处理：类函数转换
		buf = convertClassFunction(buf)
	return buf


