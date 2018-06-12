

local Cheat = class("Cheat")


function Cheat:ctor(root)
	local csbNode = cc.CSLoader:createNode("gameType/2DDZ/playScene/Cheat.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt6.winCenter)
	root:addChild(csbNode)
	self.rootNode = csbNode

	local bg = gt6.seekNodeByName(self.rootNode, "Node_bg")
	local btnClose = gt6.seekNodeByName(self.rootNode, "Btn_close")
	gt6.addBtnPressedListener(btnClose, function()
		gt6.soundEngine:playEffect("common/SpecOk", false, "2DDZ")
		self:setCheatVisible(false) -- 关闭按钮只是隐藏，目的是通过playscene来删除。方便重复点击。
	end)

	for i=1,4 do
		local nodePlayer = gt6.seekNodeByName(self.rootNode, "Node_player"..i)
		nodePlayer:setVisible(false)
	end
end

function Cheat:delete()
	self.rootNode:removeFromParent()
end

function Cheat:setCheatVisible(visible)
	self.rootNode:setVisible(visible)
end

function Cheat:addPlayer(player,selfPlayer)
	local nodePlayer = gt6.seekNodeByName(self.rootNode, "Node_player"..player.seatIdx)
	nodePlayer:setVisible(true)

	local txName = gt6.seekNodeByName(nodePlayer, "Text_name")
	local nickname = string.gsub(player.nickname," ","")
	nickname = string.gsub(nickname,"　","")
	txName:setString(gt6.checkName(nickname))


	local txIp = gt6.seekNodeByName(nodePlayer, "Text_ip")
	txIp:setString(player.ip)


	local txLocation = gt6.seekNodeByName(nodePlayer, "Text_location")
	if not player.address or player.address == "" then
		txLocation:setString("不能获得玩家的位置的\n信息")
	else
		local address = string.sub(player.address,0,60)
		local line1 = address
		if string.len(line1) > 30 then
			local line2 = nil
			line1= string.sub(address,0,30)
			line2 = string.sub(address,31,-1)
			line1 = line1.."\n"..line2
		end
		txLocation:setString(line1)
	end
	
	local txDistance = gt6.seekNodeByName(nodePlayer, "Text_distance")
	txDistance:setString("")
	if player.seatIdx == selfPlayer.seatIdx then
		txDistance:setString("自己")
	else
		local selfLocation = selfPlayer.location
		if not selfLocation or selfLocation == "" or not player.location or player.location == "" then
		else
			local distance = Utils6.getDistanceByStrs(selfLocation,player.location)
			txDistance:setString(distance)
		end
	end

end




return Cheat