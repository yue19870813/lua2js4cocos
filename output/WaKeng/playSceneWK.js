
--
-- 陕西挖坑
--
local gt6 = cc.exports.gt6
local Utils6 = cc.exports.Utils6
gt6.GC_ASK_DIZHU					= 117 --通知客户端抢地主
gt6.CG_QIANG_DIZHU				= 118 --客户端返回抢地主结果	
gt6.GC_ANS_DIZHU					= 119 --服务器广播客户端操作
gt6.GC_WHO_IS_DIZHU				= 120 --服务器广播最终地主位置
gt6.MSG_S_2_C_SHOWCARDS 			= 1118	--展示玩家自己的手牌;

local PokerScene = require("app/gameType/2POKER/playScene/PokerScene")
local PlaySceneWK = PokerScene.extend({
function PlaySceneWK:ctor(msgTbl,isReplay)

	PlaySceneWK.super.ctor(self,msgTbl,isReplay)

	self.Sprite_BombTimes:setVisible(true)
end

--执行炸弹效果
})
local Utils6 = cc.exports.Utils6
local GamePlayUtils = gt6.GamePlayUtils

 // old ctor of lua has delete
function PlaySceneWK:doBombAni(data,action)
	local msgTbl = data.msgTbl
	local seatIdx = msgTbl.m_pos + 1
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx) --self.roomPlayers[seatIdx]

	if self.mMaxFanShu == 3 or self.mMaxFanShu == 20  then
		--炸弹特效比较特殊
		gt6.soundEngine:playEffect("common/Special_Bomb_New", false, "2POKER")
		if data.realSeat == 1 then
			local sprite = GamePlayUtils.playAnimation(self.rootNode,"baozharight")
		elseif data.realSeat == 2 then
			local sprite = GamePlayUtils.playAnimation(self.rootNode,"baozhaleft")
		elseif data.realSeat == 3 then
			local sprite = GamePlayUtils.playAnimation(self.rootNode,"baozhafront")
		end
	else
		local sound = nil
		if roomPlayer.sex == 1 then
			sound = "man/Sound_Card_Four_M"
		else
			sound = "woman/Sound_Card_Four_W"
		end
		gt6.soundEngine:playEffect(sound, false, "2POKER")
	end

end

function PlaySceneWK:onRcvSHOWCARDS(msgTbl) --展示玩家自己的手牌;
	--更新各个玩家牌数量
	self:setStatus(gt6.CommonConst.ROOM_STATUS.SEND_CARD)

	self:initPokerPlay(msgTbl)
	-- 显示底牌牌背
	if not tolua.isnull(self.bottomCard ) then
		self.bottomCard:showLastHandPokerBg()
	end	
	
	local seatIdx = msgTbl.m_pos + 1 
	-- 插牌
	if seatIdx == self.playerSeatIdx then
		for k, v in ipairs(msgTbl.m_MyCard) do
			self:addMjTileToPlayer(v)
		end
	end

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) --self.roomPlayers[self.playerSeatIdx]
	GamePlayUtils.sortHoldPoker3Max(roomPlayer.holdMjTiles)
    -- 根据花色大小排序并重新放置位置
	self:sortFinalPlayerMjTiles()

	local callFunc = cc.CallFunc:create(function(sender)
		self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)
		self:checkPlayBtnShow(self.playerSeatIdx,msgTbl.m_time)
 	end)

	local delayTime = cc.DelayTime:create(0.12*16)
	local sequence = cc.Sequence:create(delayTime,callFunc)
	self:runAction(sequence)
 	gt6.log("onRcvSHOWCARDS Txt_Times " .. self.curMultiple)
 	self.Txt_Times:setString(self.curMultiple)
end


--------------------------------
-- @class function
-- @description 断线重连
-- end --
function PlaySceneWK:onRcvStartGame(msgTbl)
	self:resetRoomUi()
end

function PlaySceneWK:onRcvASKDIZHU(msgTbl) --通知客户端抢地主

	local m_state = msgTbl.m_state
	local curScore = msgTbl.m_difen

	local seatIdx = msgTbl.m_pos + 1
	if seatIdx == self.playerSeatIdx  then

		-- 断线重连情况下，显示抢地主阶段按钮
		self.decisionBtnNode:setVisible(true)
		self:hidePlayDecisionBtn()

		if m_state == 0 then 
			--黑坑
			if self.desBtn then
				self.desBtn:setVisible(true)
			end
			
		else
			self:processScorePlayType(msgTbl)
		end

		if self.bottomCard then
			self.bottomCard:setVisible(true)
		end					
		-- --显示玩家剩余牌数
		local roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
		for seatIdx, roomPlayer in ipairs(roomPlayers) do
			if roomPlayer.seatIdx ~= self.playerSeatIdx then
				-- 更新别人剩余牌数量显示
				roomPlayer:showLeftCardNum(self.room_config.showHandPokerNum)
			end
		end
	end

	self:playTimeCDStart(true,seatIdx,12)
end

function PlaySceneWK:onRcvANSDIZHU(msgTbl) -- 服务器广播客户端操作

	--隐藏叫分 等 按钮
	if self.desBtn then
		self.desBtn:setVisible(false)
	end

	if msgTbl.m_state == 0 then
		--黑坑
		self:showHeiKeng(msgTbl)
	else
		self:showScore(msgTbl)
	end

	self.curBooms = 0
	self.curMultiple = msgTbl.m_difen
	self.Txt_Times:setString(self.curMultiple)
	gt6.log("onRcvANSDIZHU Txt_Times" .. self.curMultiple)
end

-- 叫分处理
function PlaySceneWK:showScore(msgTbl)
	local seatIdx = msgTbl.m_pos + 1
  	local tipImg = nil
  	-- 声音
  	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx) --self.roomPlayers[seatIdx]
  	if msgTbl.m_yaobu == 0 then 

  		local sound = roomPlayer.sex == 1 and "man/NoOrder" or "woman/NoOrder"
		gt6.soundEngine:playEffect(sound,false,"2POKER")
		tipImg = "gt6_zspk_nograb.png"
	else
		if msgTbl.m_difen == 1 then
			tipImg = "gt6_ddz_play_one_score.png"
		elseif msgTbl.m_difen == 2 then
			tipImg = "gt6_ddz_play_two_score.png"
		elseif msgTbl.m_difen == 3 then
			tipImg = "gt6_ddz_play_three_score.png"
		end
  	end

  	-- 只有不是自己才显示提示
  	if tipImg and seatIdx ~= self.playerSeatIdx then
  		roomPlayer:showOperTips( tipImg)
  	end

	self:playTimeCDStart(false,seatIdx,12)
end

--显示玩家是否选择黑坑操作
function PlaySceneWK:showHeiKeng(msgTbl)

	local seatIdx = msgTbl.m_pos + 1

  	local tipImg = nil
  	
  	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx) --self.roomPlayers[seatIdx]
  	local sound 
  	if msgTbl.m_yaobu == 0 then 
		tipImg = "gt6_zspk_nograb.png" --不挖
	else
		tipImg = "gt6_zspk_grab.png" --黑挖
  	end

  	-- 只有不是自己才显示提示
  	if tipImg and seatIdx ~= self.playerSeatIdx then
  		roomPlayer:showOperTips( tipImg)
  	end

	self:playTimeCDStart(false,seatIdx,12)
end

function PlaySceneWK:setDelarPos(msgTbl)
	-- ####### 由于修改协议后的恢复
	if not msgTbl.m_zhuangPos then
		msgTbl.m_zhuangPos = msgTbl.m_diZhuPos
	end

	-- 庄家座位号
	if msgTbl.m_zhuangPos  then
		local bankerSeatIdx = msgTbl.m_zhuangPos + 1
		self.mZhuangPos = bankerSeatIdx
	end
end
return PlaySceneWK