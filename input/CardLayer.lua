--
--癞子 二意选牌
-- 

local gt6 = cc.exports.gt6
local Utils6 = cc.exports.Utils6
local GamePlayUtils = gt6.GamePlayUtils

local CardLayer = class("CardLayer", function ()
	return cc.Layer:create()
end)

function CardLayer:ctor(datas)
	
end

function CardLayer:createPoker()
	-- body
end

--添加牌面给玩家
function CardLayer:addCardToPlayer(msg,name,card_info)
	local value , color = GamePlayUtils.changePk(msg)
	local pkTileName = string.format(name,color, value)
	local pkTileSpr = cc.Sprite:createWithSpriteFrameName(pkTileName)
	--pkTileSpr:setVisible(false)
	pkTileSpr:setName(tostring(msg))
	pkTileSpr:setPosition(cc.p(-1000,-1000))
	self:addChild(pkTileSpr)

	local pkTile = {}
	pkTile.mjTileSpr = pkTileSpr
	pkTile.mjColor = color
	pkTile.mjNumber = value
	pkTile.mjIndex = msg
	pkTile.mjIsUp = false
	pkTile.mjIsTouch  = true
	pkTile.mjIsLaizi = false

	-- if self.mZhuangPos == self.playerSeatIdx then
	-- 	self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD)
	-- end
	local special_icon_name = card_info.special_icon_name
	if special_icon_name then
		local open_icon = cc.Sprite:createWithSpriteFrameName(special_icon_name)
		open_icon:setPosition(cc.p(30, 30))
		pkTile.mjTileSpr:addChild(open_icon)
	end
	
	return pkTile
end

--添加牌背给玩家
function CardLayer:addCardBackToPlayer(card_list)
	local pkTileName = "gt6_sp.png"
	local pkTileSpr = cc.Sprite:createWithSpriteFrameName(pkTileName)
	pkTileSpr:setVisible(false)
	local poker_list = card_list
	
	self:addChild(pkTileSpr)
	
	local pkTile = {}
	pkTile.mjTileSpr = pkTileSpr
	pkTile.mjColor = 4
	pkTile.mjNumber = 0
	pkTile.mjIndex = 0
	pkTile.mjIsUp = false
	table.insert(poker_list, pkTile)

	return pkTile
end

--发牌时候的动画
function CardLayer:sortAniPlayerCard()
end

--发完牌翻牌时候的动画
function CardLayer:sortFinalAniPlayerCard()
end


function CardLayer:addAlreadyOutCard(card_info)
	
	local color = card_info.color
	local value = card_info.value
	local isself = card_info.isself
	local pkTileName = card_info.pkTileName 
	-- 显示已出牌
	local pkTilesReferPos = card_info.pkTilesReferPos
	local mul = card_info.mul
	-- if seatIdx == self.playerSeatIdx then
	local pkTileSpr = cc.Sprite:createWithSpriteFrameName(pkTileName)
	local pkTile = {}
	pkTile.mjTileSpr = pkTileSpr
	pkTile.mjColor = color
	pkTile.mjNumber = value
	
	--出牌动画
	pkTileSpr:setScale(1.3)
	local delayTime = cc.DelayTime:create(0.005)
	local callFunc2 = cc.CallFunc:create(function(sender)
		if gt6.pokerIsReplay then
			pkTileSpr:setScale(0.85)
		else
			pkTileSpr:setScale(1)
		end
	end)
	local seqAction = cc.Sequence:create(delayTime, callFunc2)
	pkTileSpr:runAction(seqAction)
	
	local pkTilePos = pkTilesReferPos.outStart
	local addPos = 0
	if isself then
		addPos = (isself*pkTilesReferPos.outSpaceH.x)/2	- 20
	end
	print("isself==="..tostring(isself))

	pkTilePos = cc.pAdd(pkTilePos, cc.pMul(pkTilesReferPos.outSpaceH, mul))
	pkTileSpr:setPosition(pkTilePos.x-addPos,pkTilePos.y)
	self:addChild(pkTileSpr, pkTilePos.x)

	return pkTile
end


function CardLayer:addOutCardFinally(card_info)
	
	local color = card_info.color
	local value = card_info.value
	local pkTileName = card_info.pkTileName
	local mjTilesReferPos = card_info.pkTilesReferPos
	local outPkCount = card_info.outPkCount
	local move_x = card_info.move_x
	local start_x = card_info.start_x
	local start_offestx = card_info.start_offestx
	local is_change_line = card_info.is_change_line --是否换行
	local num = card_info.num

	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(pkTileName)
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = color
	mjTile.mjNumber = value

	local mjTilePos = mjTilesReferPos.outStart
	mjTileSpr:setScale(0.6)
	mjTileSpr:setVisible(false)

	local lineCount = math.ceil(outPkCount/ 8) - 1
	local lineIdx = outPkCount - lineCount * 8 - 1

	local v_start = mjTilesReferPos.outSpaceV
	local h_start = mjTilesReferPos.outSpaceH
	
	if is_change_line then
		lineCount = 0
		lineIdx = outPkCount
		mjTilePos.x = start_x--self:getPokerTotalWidth(seatIdx)
	end

	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(v_start, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(h_start, lineIdx))

	--dump(mjTilePos,"mjTilePos====")
	mjTileSpr:setPosition(mjTilePos.x, mjTilePos.y)

	self:addChild(mjTileSpr, mjTilePos.x+start_offestx)
	local delayTime = cc.DelayTime:create(0.02 * num * 0.8)
	local move1 = cc.MoveTo:create(0.1,cc.p(mjTileSpr:getPositionX() + move_x,mjTileSpr:getPositionY()))
	local move2 = cc.MoveTo:create(0.4,cc.p(mjTileSpr:getPositionX(),mjTileSpr:getPositionY()))
	local spawn = cc.Spawn:create(cc.Show:create(),cc.Sequence:create(move1,move2))
	-- local callFunc = cc.CallFunc:create(function (sender)
	-- 	mjTileSpr:setVisible(true)
	-- end)
	local seq = cc.Sequence:create(delayTime,spawn)
	mjTileSpr:runAction(seq)

	return mjTile

end
return CardLayer