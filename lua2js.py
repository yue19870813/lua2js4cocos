#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: lua2js.py
import sys, os, re
import rule

__author__ = 'ituuz'

"""
处理lua转js脚本
"""

# 源文件目录
src_path = "./input/"
# 目标输出目录
dst_path = "./output/"

# 递归遍历目录获取文件
def getData(path):
	# 获取path目录下所有文件
	fileList = os.listdir(path)
	for filename in fileList:
		pathTemp = os.path.join(path, filename) 
		if os.path.isdir(pathTemp):
			getData(pathTemp)
		else:
			# 非excel文件不做处理
			if os.path.splitext(pathTemp)[1] != ".lua":
				continue
			# 处理数据
			convertLua2Js(path, filename)


# 对字符串进行替换
def stringReplace(str):
	
	tempStr = str.decode(encoding='utf-8', errors='strict')
	# 增加一个换行用于处理正则匹配的兼容性
	tempStr = '\n' + tempStr

	# 查找构造函数部分
	match = re.search('function\s+([\w]+?):ctor *\(([\s\S]*?)\)([\s\S]*?)function\s*([\w]+?):', tempStr)
	ctorStr = ""
	if match:
		# print ("构造函数内容：")
		ctorStr = match.group(0)
		idx = ctorStr.rfind("\n")
		if idx != -1:
			ctorStr = ctorStr[0:idx]
			tempStr = tempStr.replace(ctorStr, " // old ctor of lua has deleted")
			
			# 开始修改构造函数中的内容
			# 获取构造函数中的参数
			ctorParamMatch = re.search('function\s+([\w]+?):ctor *\(([\s\S]*?)\)', ctorStr)
			ctorParam = ctorParamMatch.group(0)

			tempMatch = re.search('\(([\s\S]*?)\)', ctorParam)
			ctorParam = tempMatch.group(0)

			# 获取类名
			classNameMatch = re.search('\nlocal\s+(\w+)\s*=\s*class\s*\(\s*\"(\S+?)\"', tempStr)
			classNameStr = classNameMatch.group(0)
			startIdx = classNameStr.find("local")
			endIdx = classNameStr.find("=")
			classNameStr = classNameStr[startIdx + 6:endIdx].strip()

			# 替换拼接新构造函数内容
			if ctorStr.find(".super(") == -1 and ctorStr.find("._super(") == -1:
				ctorStr = ctorStr.replace(ctorParamMatch.group(0), "ctor:function" + ctorParam + "{\n\tvar self = this;\n\tthis._super();\n\tthis.name = \"" + classNameStr + "\";")
			else:
				# PlayScene.super.ctor(self, xx) -> this._super(self, xx)
				ctorStr = re.sub('([ |\t|\.])+(\w+)\.super\.ctor\s*(\([\s\S]*?\))', '\g<1>this._super\g<3>', ctorStr)
				ctorStr = ctorStr.replace(ctorParamMatch.group(0), "ctor:function" + ctorParam + "{\n\tvar self = this;\n\tthis.name = \"" + classNameStr + "\";")

				


	"""
	# 匹配类的继承1： 
	local FakeLayer = class("FakeLayer", function ( ... )
		return cc.Layer:create()
	end)
	"""
	match = re.search('\nlocal\s+(\w+)\s*=\s*class\s*\(\s*\"(\S+?)\"\s*,\s*function\s*\(([\s\S]*?)end\)', tempStr)
	if match:
		# print ("===== 第一种类型类的声明")
		tempMatch = match.group(0)
		classNameMatch = re.search('return\s*([\s\S]*?):', tempMatch)
		classNameStr = classNameMatch.group(0)
		classNameStr = classNameStr.replace("return", "").replace(":","").strip();

		# 生成最终的构造函数并替换进文件
		tempMatch = re.sub('class\s*\(\s*\"(\S+?)\"\s*,\s*function\s*\(([\s\S]*?)end\)', classNameStr + '.extend({\n' +  ctorStr + '\n})', tempMatch)
		tempStr = tempStr.replace(match.group(0), tempMatch)
	"""
	# 匹配如下类的定义2：
	local PlaySceneWK = class("PlaySceneWK", PokerScene)
	"""
	match = re.search('\nlocal\s+(\w+)\s*=\s*class\s*\(\s*\"(\S+?)\"\s*,\s*([\s\S]*?)\)', tempStr)
	if match:
		# print ("===== 第二种类型类的声明")
		tempMatch = match.group(0)
		# 获取要集成的类名
		classNameMatch = re.search(',\s*([\s\S]*?)\)', tempMatch)
		classNameStr = classNameMatch.group(0)
		classNameStr = classNameStr[1:len(classNameStr) - 1].strip()

		# 生成最终的构造函数并替换进文件
		tempMatch = re.sub('class\s*\(\s*\"(\S+?)\"\s*,\s*([\s\S]*?)\)', classNameStr + '.extend({\n' +  ctorStr + '\n})', tempMatch)
		tempStr = tempStr.replace(match.group(0), tempMatch)

	"""
	# 匹配如下类的定义3：
	local Cheat = class("Cheat")
	"""
	match = re.search('\nlocal\s+(\w+)\s*=\s*class\s*\(\s*\"(\S+?)\"\s*\)', tempStr)
	if match:
		# print ("===== 第三种类型类的声明")
		tempMatch = match.group(0)
		
		# 生成最终的构造函数并替换进文件
		tempMatch = re.sub('class\s*\(\s*\"(\S+?)\"\s*\)', 'cc.Class.extend({\n' +  ctorStr + '\n})', tempMatch)
		tempStr = tempStr.replace(match.group(0), tempMatch)

	# 遍历转换规则
	for k, config in enumerate(rule.convert_rule):
		tempStr = rule.convert(tempStr, config)

	# print (tempStr)s

	return tempStr.encode(encoding='utf-8', errors = 'strict')


# 将lua文件转换成js文件
def convertLua2Js(luaFilePath, luaFileName):
	# 读文件
	fp = open(luaFilePath + "/" + luaFileName, 'rb')
	buf = fp.read()
	fp.close()
	
	# 开始进行内容替换
	resultBuf = stringReplace(buf)

	# 保存文件为js文件
	dpath = luaFilePath.replace(src_path, dst_path)

	file_dst = os.path.join(dpath, os.path.splitext(luaFileName)[0] + '.js')
	print ("写入文件：" + file_dst)

	# 判断文件是否存在，如果存在则删除旧文件
	b = os.path.exists(dpath)
	if b:
		b = os.path.exists(file_dst)
		if b:
			os.remove(file_dst)
	else:
		os.mkdir(dpath)
	
	fp = open(file_dst, 'wb')
	fp.write(resultBuf)
	fp.close()
	


# 入口函数
def main(argv):
	# 程序入口
	getData(src_path)


if __name__ == "__main__":
	main(sys.argv[1:])
else:
	main();

