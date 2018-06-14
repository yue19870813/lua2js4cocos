local gt6 = cc.exports.gt6
local Utils6 = cc.exports.Utils6

local plus_info = {
	fontPic = "gameType/2POKER/playScene/atlas/ddz_flyscore_num.png",
	font_size = {width = 30,height = 36},
	first_char = ".",
}

local minus_info = {
	fontPic = "gameType/2POKER/playScene/atlas/ddz_scorenum_minus.png",
	font_size = {width = 30,height = 36},
	first_char = ".",
}

require("app/gameType/base/CommonConst")
require("app/gameType/base/GamePlayUtils")
require("app/gameType/base/PlayersManager")
require("app/gameType/2POKER/playScene/FakeCardMgr") --癞子算法
require("app/gameType/base/model/RoomDataMgr")
local GamePlayUtils = gt6.GamePlayUtils
local CommonConst = gt6.CommonConst
local RoomDataMgr = gt6.RoomDataMgr
local DataDef = gt6.RoomDataMgr.DataDef
local PlaySceneBase = require("app/gameType/base/PlaySceneBase")
local PokerScene= class("PokerScene", PlaySceneBase)

local CardLayer =  require("app/gameType/2POKER/playScene/CardLayer")

--游戏玩法的一些配置
local GameStyleConfig = require("app/gameType/base/GameStyleConfig")
--精灵帧名字
local reload_plists = {
	"poker.plist",
	"pokerOut.plist",
	"play_scene.plist",
	"PlayScene_common.plist",
}

local action_tag = {
	send_poker_tag = 100,
}

local default_csb = "PlayScene_poker3.csb"

local tileWidth = 155
local tileHeight = 216
local other_tileWidth = 96

local laizi_ani_time = 2

function PokerScene:ctor(msgTbl)
	local data = {msgTbl = msgTbl}
	gt6.gameType = gt6.gameTypeDefine.POKER

	PokerScene.super.ctor(self,data)


	print("---> 注册 change_match_difen 消息 。。。。")
	gt6.registerEventListener("change_match_difen", self, self.onChangeMatchDifen)

 	--初始化数据
	self:initData(data.msgTbl)

	--初始化房间
	self:initRoom()

	-- 初始化player管理器
	self:initPlayersManager()

	self:initDesk(data.msgTbl)

	-- 玩家进入房间
	self:playerEnterRoom(data.msgTbl)

	self:initPokerTouch()

	self:registerScriptHandler(handler(self, self.onNodeEvent))

end

function PokerScene:initDesBtn(msgTbl)
	if not msgTbl then return end
	local id = nil
	local subGameArr =  GameStyleConfig.subGameTypeArr
	for i, v in ipairs(subGameArr) do
		local flag = Utils6.checkPlaytypeByid(msgTbl.m_playTypeOptions, v)
		if flag then
			id = v
			break
		end
	end

	if id then
		local idStr = "id_" .. id
		self:createDesBtn(idStr)
	end

end

function PokerScene:createDesBtn(idStr)
	local jueCeItem = g_jueCeAction_poker[idStr]
	local actionIdArr = jueCeItem.actionId
	local node = ccui.Widget:create()
	node:setContentSize(cc.size(250 * #actionIdArr, 85 ))
	node:setAnchorPoint(cc.p(0.5, 0.5))

	self.desBtn = node
	for i = 1, #actionIdArr do 
		local id = actionIdArr[i]
		local jueCeId = "id_" .. id
		local jueCeItem = g_jueCeId_poker[jueCeId]
		local pic =  jueCeItem.pic
		local picPress = jueCeItem.picPress
		local picDis =  jueCeItem.picDis
		local picResType = jueCeItem.picResType
		local name =  jueCeItem.name

		local m_difen = jueCeItem.m_difen
		local m_yaobu = jueCeItem.m_yaobu
		local m_playerOper = jueCeItem.m_playerOper
		local m_operType = jueCeItem.m_operType
		if m_difen == -1 then m_difen = nil end
		if m_yaobu == -1 then m_yaobu = nil end
		if m_playerOper == -1 then m_playerOper = nil end
		if m_operType == -1 then m_operType = nil end

		if picResType == "PLIST" then
			picResType = ccui.TextureResType.plistType 
		else
			picResType = ccui.TextureResType.localType
		end
		
		local button = ccui.Button:create()
	    local function touchEvent(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then         
				local msgToSend = {}
				msgToSend.m_msgId = gt6.CG_QIANG_DIZHU
				msgToSend.m_pos = self.playerSeatIdx - 1
				msgToSend.m_difen = m_difen
				msgToSend.m_yaobu = m_yaobu
				msgToSend.m_playerOper = m_playerOper
				msgToSend.m_operType = m_operType
				gt6.socketClient:sendMessage(msgToSend)
				self.decisionBtnNode:setVisible(false)
	        end
	    end

	    local widthX = 250 * i - 120

	    button:setName(name)
		button:loadTextures(pic, picPress, picDis, picResType)	
	    button:setScale9Enabled(true)
	    button:setPosition(widthX, 43) 
	    button:addTouchEventListener(touchEvent)
	    node:addChild(button,9999)
	end
	node:setName("decisionBtn")
	self.decisionBtnNode:addChild(node)
end

function PokerScene:onNodeEvent(eventName)
	if "enter" == eventName then
		self:onEnter()
	elseif "enterTransitionFinish" == eventName then
		self:onEnterTransitionFinish()
	elseif "exit" == eventName then
		gt6.isMatch = nil
		self:onExit()
	elseif "cleanup" == eventName then
        gt6.isMatch = nil
	end
end

function PokerScene:onEnter()
	gt6.log("PlayScene enter")
	gt6.ChatLog = {}
	if gt6.defaultGameType == gt6.gameTypeDefine.POKER then
		gt6.soundEngine:playMusic("xlmj_bgm2", true)
	end
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
								handler(self, self.onEnterBackground))
	eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
	local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
								handler(self, self.onEnterForeground))
	eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)

		-- 逻辑更新定时器
	self:openUpdateSchedule()

end

function PokerScene:onEnterBackground()
	--出游戏 用来计算倒计时 秒为单位
	self:setOutGameTimeStamp()
end

function PokerScene:onEnterForeground()
	-- 回来游戏
	if not self.playTimeCD then return end
	local runOffTime = self:countRunOffTime()
	self.playTimeCD = self.playTimeCD - runOffTime
end

function PokerScene:onEnterTransitionFinish()
	gt6.log("PlayScene enterTransitionFinish")
end

function PokerScene:onExit()
	gt6.log("PlayScene exit")
	gt6.gameType = nil

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:removeEventListenersForTarget(self.cards_layer)
	eventDispatcher:removeEventListenersForTarget(self)
	self:closeUpdateSchedule()
	gt6.removeTargetEventListenerByType(self,gt6.EventType.UPDATE_BG_GAME)
	gt6.PlayersManager:clear()

	if gt6.defaultGameType == gt6.gameTypeDefine.POKER then
		gt6.soundEngine:playMusic("xlmj_bgm1", true)
	end

	RoomDataMgr:clear()
	self.register_opt_list = {} --都是临时方案 以后优化
end

--根据配表， 初始化字段值
function PokerScene:initXSLFiled(msgTbl)
	self.mMaxFanShu = 0 --初始值， 配表中更新
	self.playMaxNum = 3
	self.haveBomb = 0 --=1带炸弹， =0不带炸弹
	
	dump(self.room_config,"self.room_config")
	local playeType = self.room_config.name
	local desc = ""

	--算一些标识
	for k, v in ipairs(g_PlayType) do
		for kk, vv in ipairs(msgTbl.m_playTypeOptions) do
			if v and vv and v.id == vv then
				if v.fieldName then
					self[v.fieldName] = v.fieldValue
					gt6.log("fieldName " .. v.fieldName .. " : " .. tostring(v.fieldValue))
				end

				if v.playTypeDes then
					desc = desc .. v.playTypeDes .. ","
				end
			end 
		end
	end	


	-- 斗地主
	if self.mGameStyle <= 7 and self.mGameStyle >=0 then
		if self.mGameStyle == gt6.CommonConst.GameType.JINGDIAN then
			if self._gameType and self._gameType == 1 then --代表叫分
				playeType = "经典斗地主"
			elseif self._gameType and self._gameType == 2 then -- 代表抢地主玩法
				playeType = "欢乐斗地主"
			end
		end	
	else
		desc = string.sub(desc,1,-2)
		if playeType then
			playeType = playeType .. "," .. desc
		else
			playeType = desc
		end		
	end
	
	gt6.log("玩法类型：" .. playeType)
	self.playTypeDesc = playeType

	cc.UserDefault:getInstance():setStringForKey("playType", playeType)
	cc.UserDefault:getInstance():flush()
end

function PokerScene:initData(msgTbl)
	dump(msgTbl, "PokerScene:initData msgTbl")

	--为了兼容其他服务器的一些用法 我知道很sb但也没办法
	if msgTbl.m_gameStyle then
		msgTbl.m_mainGameType = msgTbl.m_gameStyle
		msgTbl.m_subGameType = 0
	end

	if not msgTbl.m_playTypeOptions then
		msgTbl.m_playTypeOptions = {}
	end

	--游戏模式 金币 比赛等
	self.mGameStyle = msgTbl.m_mainGameType + msgTbl.m_subGameType

	
	if msgTbl.m_gameZone == 1 then
		self.mRoomPattern = gt6.CommonConst.RoomPattern.COIN
		self.readyPlayMsg.playType = gt6.coinType.POKER
		self.playType = gt6.coinType.POKER
	end


	gt6.log("self.mGameStyle " .. self.mGameStyle)

	self.room_config = GameStyleConfig[self.mGameStyle] or {}
	self:initXSLFiled(msgTbl)

	self.playTimeCD = 0
	self.is_turn_me = false --是否轮到自己
	
	self.laiTag = 1

	-- self.mMaxFanShu = 20 -- 炸弹数目没有上限
	self.curBooms = 0 ---- 当前炸弹数
	self.curMultiple = 1 ---当前倍数
	--关于游戏倍数有关的--end
   	
   	--存储当前出牌的信息
	self.curShowCardInfo = {cardArr = {}, cardType = 0,cardNum = 0}
	-----------	
	--二人专有
	self.check_poker_num = 0
	self.win_poker_num = 0
	self.open_poker_index = -1 --对手明牌的具体位置
	self.open_poker_seat = -1--msgTbl.m_firstPos_card[1] + 1--获得明牌的位置
	self.open_poker_value = -1 --msgTbl.m_firstPos_card[2]--明牌值

	--最大翻数(目前最大炸弹数也包括进去了)
	if msgTbl.m_nMaxFanshu then
		self.mMaxFanShu = msgTbl.m_nMaxFanshu
	end

	self.time = 0
	self.optionType = msgTbl.m_eIsMustOut or 0 --必须出 老麻子游戏

	--获取dealer信息 不同游戏dealer的内容不一样 配置驱动
	self.dealer_info_config = nil
	local dealer_type = self.room_config.dealer_type
	if dealer_type then
		self.dealer_info_config = GameStyleConfig.DealerInfo[dealer_type]
	end

	self.SelectCard = {} -- 选中的牌
	--特殊字段
	self:checkSpeicals()

	--决策节点
	self.decisionBtnNode = nil

	--玩法类型
	self:initPlayType()
end

function PokerScene:initPlayType()
	-- body
	-- 玩法类型
	if self.readyPlayMsg and not self.readyPlayMsg.playerSeatPos then
		self.readyPlayMsg.playerSeatPos = self.readyPlayMsg.m_pos
	end 

	if self.readyPlayMsg and not self.readyPlayMsg.roomID then
		self.readyPlayMsg.roomID = self.readyPlayMsg.m_deskId 
	end

	if self.mGameStyle <= 7 and self.mGameStyle >=0 then
		self.readyPlayMsg.title_show = "斗地主"
		self.readyPlayMsg.playTypeDesc = "come on baby"

		local newStrType=""
	    local circleToShow = self.readyPlayMsg.m_maxCircle .. "局"
	    newStrType = "斗地主" .. " "..circleToShow 
		if self._gameType == 1 then
			newStrType = newStrType .. " 叫分"
		elseif self._gameType == 2 then
			newStrType = newStrType .. " 抢地主"
		end
		self.readyPlayMsg.playTypeDesc = newStrType
	end
end


function PokerScene:checkSpeicals()
	--特殊显示处理
	self.close_auto_end_poker_flag = false
	self.re_sort_out_poker_flag  = false 
	self.show_opponent_poker_back_flag = false
	self.show_check_poker_flag = false
	self.fapai_bu_fanpai_flag = false

	self.check_airplane_flag = false --检测飞机标志
	self.show_buyao_btn_flag = false
	self.show_reset_btn_flag = false 
	self.calc_multip_flag = false
	self.auto_calc_card_flag = false --是否自动算牌

	self.have_laizi_flag = false --是否带癞子
	self.have_pizi_flag = false --是否带皮子

	if g_SpeicalShow and  next(g_SpeicalShow) then
		self.close_auto_end_poker_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.CLOSE_AUTO_SEND_POKER,self.mGameStyle) 
		self.re_sort_out_poker_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.RE_SORT_OUT_POKER,self.mGameStyle) 
		self.show_opponent_poker_back_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.SHOW_OPPONENT_POKER_BACK,self.mGameStyle) 
		self.show_check_poker_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.SHOW_CHECK_POKER,self.mGameStyle) 
		self.fapai_bu_fanpai_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.FAPAI_BU_FANPAI,self.mGameStyle)

		self.check_airplane_flag =  gt6.checkSpecialSetByState(gt6.SpecialSetId.HAVE_PLANE , self.mGameStyle) 
		self.show_buyao_btn_flag =  gt6.checkSpecialSetByState(gt6.SpecialSetId.SHOW_PASS  , self.mGameStyle)
		self.calc_multip_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.CALC_MULTIP  , self.mGameStyle)
		self.auto_calc_card_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.AUTO_CALC_CARD  , self.mGameStyle)
	end

	dump(gt6.SpecialSetId,"gt6.SpecialSetId====")
	gt6.log("self.auto_calc_card_flag=="..tostring(self.auto_calc_card_flag))
	print("self.auto_end_poker_flag=="..tostring(self.close_auto_end_poker_flag))
	print("self.re_sort_out_poker=="..tostring(self.re_sort_out_poker_flag))
	print("self.show_opponent_poker_back_flag=="..tostring(self.show_opponent_poker_back_flag))
	print("self.show_check_poker=="..tostring(self.show_check_poker_flag))
	print("self.fapai_bu_fanpai=="..tostring(self.fapai_bu_fanpai_flag))
	print("self.calc_multip_flag=="..tostring(self.calc_multip_flag))
	

	self.show_reset_btn_flag = GamePlayUtils.getGameSwitch(self.mGameStyle,"showChongXuan")

	print("self.check_airplane_flag=="..tostring(self.check_airplane_flag))
	print("self.show_buyao_btn_flag=="..tostring(self.show_buyao_btn_flag))
	print("self.show_reset_btn_flag=="..tostring(self.show_reset_btn_flag))

	--目前还没有配进exsl里的
	if self.mGameStyle == gt6.CommonConst.GameType.LAIZI    --斗地主癞子
		or self.mGameStyle == gt6.CommonConst.GameType.FAKEPDK then --跑得快癞子
		self.have_laizi_flag = true
	end

	if self.mGameStyle == gt6.CommonConst.GameType.DAIPIZI then
		self.have_pizi_flag = true
	end
end

function PokerScene:initRoom()
	--如果开始没有被赋值
	local name = string.format("PlayScene_poker%d.csb",self.playMaxNum)
	local csb_path = "gameType/2POKER/playScene/"..name

	cc.SpriteFrameCache:getInstance():addSpriteFrames("inGame/inGame.plist")
	--加载精灵帧防止被释放掉
	Utils6.loadPlist(reload_plists)
	--加载主ui
	self.rootNode =  Utils6.loadCSB(csb_path,"POKER")

	local custom_ui = self.room_config.custom_ui or "Layer_ZSPK"
	local csb_path = "gameType/2POKER/playScene/"..custom_ui..".csb" --自己额外的csb需要配置
	local node = Utils6.loadCSB(csb_path,custom_ui) 
	print("----> 自己额外的csb需要配置 csb_path , custom_ui = ",csb_path , custom_ui)
	node:setZOrder(gt6.CommonConst.ZOrder.DECISION_BTN)
	self.rootNode:addChild(node)

 	local Sprite_BombTimes = gt6.seekNodeByName(node, "Sprite_BombTimes")
 	self.Sprite_BombTimes = Sprite_BombTimes
 	Sprite_BombTimes:setVisible(false)

	--底分
	self.Txt_Times = gt6.seekNodeByName(self.Sprite_BombTimes , "AtlasLabel_TimesAtlasLabel_Times")
	-- 底牌节点
	if self.room_config.bottomCard then
		--添加底牌
		self.bottomCard = require("app/gameType/2POKER/playScene/BottomCardsLayer"):create(self, self.room_config.bottomCard)
		self.bottomCard:setVisible(false)
		self.bottomCard:setName("BottomCardsLayer")
		self.rootNode:addChild(self.bottomCard)
	end

	-- 初始化决策按钮
	self:initPlayGameBtn()

	--Zorder重置
   	for i = 1, self.playMaxNum do
   		local player = gt6.seekNodeByName(self.rootNode,"Node_playerMjTiles_"..i)
   		player:setLocalZOrder(gt6.CommonConst.ZOrder.OUTMJTILE_SIGN)
   	end
end

function PokerScene:initDesk(msgTbl)
	dump(msgTbl,"---> PokerScene:initDesk(msgTbl) : ")
	self:initTurnUiLayer(msgTbl)
	self:createCardLayer(self.rootNode)

	self:changePlayBg(self,2)
	--self:setTable("gameType/2POKER/playScene/playBg/tableb_zhuobu.png")

	local common_ui_layer = self.common_ui_layer
	
	local ready_ui_layer = self.ready_ui_layer
     --移动按钮
	local menuPos = cc.p(common_ui_layer.speakBtn:getPosition())
	common_ui_layer.yuyinBtn:setPosition(gt6.winSize.width-50,menuPos.y -350)
	common_ui_layer.messageBtn:setPosition(gt6.winSize.width-50 ,menuPos.y-250)
	common_ui_layer.speakBtn:setPosition(gt6.winSize.width-50,menuPos.y-450)
	ready_ui_layer._Btn_ready:setPosition(cc.p(gt6.winCenter.x, gt6.winCenter.y - 300))

	if msgTbl.m_gameType == gt6.playGameZone.match then
		common_ui_layer:matchLayerShow(false)
		-- common_ui_layer:changeMatchDifen(msgTbl)
	else
		common_ui_layer:updateRoomId(msgTbl.m_deskId)
	end

	
	--初始化癞子相关
	if self.have_laizi_flag then
		--初始化癞子算法
		gt6.FakeCardMgr:getInstance():init(self.room_config.fakeCfgName)
		--二意性选择
		local datas = {}
		datas.parent = self
		self.mAmbiguityLayer = require("app/gameType/2POKER/playScene/AmbiguityLayer"):create(datas)
		self.desk_layer:addChild(self.mAmbiguityLayer)
		
		--癞子底牌
		self.mFakeLayer = require("app/gameType/2POKER/playScene/FakeLayer"):create()
		self:addChild(self.mFakeLayer)
	end

	self:initDesBtn(msgTbl)

	--金币场功能
	if self.mRoomPattern == gt6.CommonConst.RoomPattern.COIN then
		
		self.ready_ui_layer:setVisible(false)
		local x,y = self.ready_ui_layer._Btn_ready:getPosition()
		local readyBtnPosition = cc.p(x,y)
		self:createCoinRoomBtn()  --创建后 先隐藏掉 关闭界面后显示出来
		if not tolua.isnull(self.changeBtn) then
			self.changeBtn:setPosition(readyBtnPosition.x - 170,readyBtnPosition.y)
		end
		if not tolua.isnull( self.continueBtn) then
			self.continueBtn:setPosition(readyBtnPosition.x + 140,readyBtnPosition.y)
		end

		--金币场创建 描述信息
		self.common_ui_layer:initCoinLevel(msgTbl)

		self.mAlarmClockLayer = require("app/gameType/base/AlarmClockLayer"):create()
		self:addChild(self.mAlarmClockLayer, gt6.CommonConst.ZOrder.SETTING_LAYER - 1)
	end

	--创建一个闹钟
	self:setClockPosition(1, false)

	
	if self.mGameStyle >= 0 and self.mGameStyle <= 5 and msgTbl.m_gameType ~= gt6.playGameZone.match then
		--测试用 创建一个记牌器
		self.PokerMemoryLayer = require("app/gameType/2POKER/component/PokerMemoryLayer"):create()
		self:addChild( self.PokerMemoryLayer )
		self.PokerMemoryLayer:init({ have_king = true, playerSeatIdx = self.playerSeatIdx, playMaxNum = self.playMaxNum})
	end
end

function PokerScene:onChangeMatchDifen( msgType,mathDifen,gameData )
	print("--->  斗地主 更改比赛底分 mathDifen= ",mathDifen)
	if not gameData then return end
	if gameData.gameZone == gt6.playGameZone.match then
		local _msg = {}
		_msg.m_gameType = gameData.gameType
		_msg.m_gameZone = gameData.gameZone
		_msg.m_roomDiFen = mathDifen 
		self.common_ui_layer:changeMatchDifen(_msg)
	end
end

function PokerScene:registerMsgs()
	print(" PokerScene:registerMsg()===")
	PokerScene.super.registerMsgs(self)

	gt6.socketClient:registerMsgListener(gt6.GC_SYNC_ROOM_STATE, self, self.onRcvSyncRoomState) --断线重连
	gt6.socketClient:registerMsgListener(gt6.GC_START_GAME, self, self.onRcvStartGame) --开始游戏

	gt6.socketClient:registerMsgListener(gt6.GC_TURN_SHOW_MJTILE, self, self.onRcvTurnShowMjTile) --通知玩家出牌
	gt6.socketClient:registerMsgListener(gt6.GC_SYNC_SHOW_MJTILE, self, self.onRcvSyncShowMjTile) --显示玩家出牌消息
	gt6.socketClient:registerMsgListener(gt6.GC_ROUND_STATE, self, self.onRcvRoundState) --当前局数/最大局数
	gt6.socketClient:registerMsgListener(gt6.GC_GET_SURPLUS, self, self.onSurplusCard) --最后手中剩余牌消息
	gt6.socketClient:registerMsgListener(gt6.GC_ROUND_REPORT, self, self.onRcvRoundReport) --单局游戏结束
	gt6.socketClient:registerMsgListener(gt6.GC_FINAL_REPORT, self, self.onRcvFinalReport) --总结算界面

	--地主 挖坑等游戏
	gt6.socketClient:registerMsgListener(gt6.GC_ASK_DIZHU, self, self.onRcvASKDIZHU) --通知客户端抢地主
	gt6.socketClient:registerMsgListener(gt6.GC_ANS_DIZHU, self, self.onRcvANSDIZHU)--服务器广播客户端操作
	gt6.socketClient:registerMsgListener(gt6.GC_WHO_IS_DIZHU, self, self.onRcvWHOISDIZHU)--服务器广播最终地主位置
	gt6.socketClient:registerMsgListener(gt6.MSG_S_2_C_SHOWCARDS, self, self.onRcvSHOWCARDS)

	--重置翻倍数
	gt6.registerEventListener(gt6.EventType.RESET_MULTIP, self, self.resetMultipFunc)
	--返回大厅，解散房间事件
	gt6.registerEventListener(gt6.EventType.POKER_BACK_DISMISS, self, self.onBackOrDismiss)
	--金币场，结算界面 点关闭 显示出继续和换桌按钮
	gt6.registerEventListener(gt6.EventType.SHOW_GOON_CHANGE, self, self.onShowGoOnAndChange)
	--调整ui层级
	gt6.registerEventListener(gt6.EventType.CHECK_ZORDER, self, self.onCheckZorder)

	gt6.registerEventListener(gt6.EventType.BACK_MAIN_SCENE_FROM_MATCH, self, self.backMainSceneFromMatch)

	--dump(self.register_opt_list,"==register_opt_list==")
end

function PokerScene:onCheckZorder(event, data )
	local tag = data.tag
	local newOrder = data.order
	if tag == "AlarmClockLayer" then
		if not tolua.isnull(self.mAlarmClockLayer) and newOrder then
			self.mAlarmClockLayer:setLocalZOrder(newOrder)
		end
	end
		
end

function PokerScene:onShowGoOnAndChange()
	if self.mRoomPattern == gt6.CommonConst.RoomPattern.COIN then
		if not tolua.isnull(self.changeBtn) then self.changeBtn:setVisible(true) end
		if not tolua.isnull(self.continueBtn) then self.continueBtn:setVisible(true) end
	end
end

function PokerScene:resetMultipFunc()
	self.curBooms = 0 ---- 当前炸弹数
	self.curMultiple = 1 ---当前倍数

	gt6.log("resetMultipFunc Txt_Times ".. self.curMultiple)
	self.Txt_Times:setString("" ..  self.curMultiple)
end

function PokerScene:unregisterAllMsgListener()
	print("unregisterAllMsgListener")
	PokerScene.super.unregisterAllMsgListener(self)

	gt6.removeTargetAllEventListener(self)
end

function PokerScene:initPlayGameBtn()
	-- 决策按钮位置信息
	-- 隐藏玩家决策按钮（提示、出牌、不出的父节点）
	self.decisionBtnNode = gt6.seekNodeByName(self.rootNode, "Node_decisionBtn")
	self.rootNode:reorderChild(self.decisionBtnNode, gt6.CommonConst.ZOrder.DECISION_BTN)
	self.decisionBtnNode:setVisible(false)

	self.play 		= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_1")
	self.prompt 	= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_2")
	self.pass 		= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_3") --不要按钮
	self.restore 	= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_4")
	self.nograb 	= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_5")
	self.grab 		= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_6")
	local nodePlay 		= gt6.seekNodeByName(self.decisionBtnNode,"Node_Play")
	local nodePrompt 	= gt6.seekNodeByName(self.decisionBtnNode,"Node_Prompt")
	local nodeReset 	= gt6.seekNodeByName(self.decisionBtnNode,"Node_Reset")

	self.btnPlayPosition 	= cc.p(self.play:getPosition())
	self.btnPlayPosition2 	= cc.p(nodePlay:getPosition())

	self.btnPromptPosition 	= cc.p(self.prompt:getPosition())
	self.btnPromptPosition2 = cc.p(nodePrompt:getPosition())

	self.btnPassPosition 	= cc.p(self.pass:getPosition())

	self.btnResetPosition 	= cc.p(self.restore:getPosition())
	self.btnResetPosition2 	= cc.p(nodeReset:getPosition())

	--提示 和 出牌
	--出牌
	gt6.addBtnPressedListener(self.play, function()
		gt6.soundEngine:playEffect("common/SpecOk", false, "2POKER")
		if #self.SelectCard == 0 then
			--未选牌时按钮变灰不可点击
			gt6.floatText("未选牌")
			return	
		end

		local temp_card = {}
		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)

		for key,value in pairs(self.SelectCard) do
			local pkTile = roomPlayer.holdMjTiles[value]
			if pkTile then
				local card_sprite = pkTile.mjTileSpr
				if card_sprite and not tolua.isnull(card_sprite) then
					table.insert(temp_card, tonumber(card_sprite:getName()))
				end 
			end
		end

		if self.have_laizi_flag then
			if not tolua.isnull(self.mAmbiguityLayer) then
				dump(temp_card, "temp_card----->")
				self.mAmbiguityLayer:laiziPaly(temp_card,roomPlayer)
			end
		else
			local msgToSend = {}
			msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
			msgToSend.m_flag = 0
			msgToSend.m_nCardType = 0
			msgToSend.m_card = temp_card
			gt6.socketClient:sendMessage(msgToSend)
			self.decisionBtnNode:setVisible(false)
		end

		if  self.have_pizi_flag then
			self.promptIndex = 1
		end

	end, nil, nil)

	--提示
	gt6.addBtnPressedListener(self.prompt, function()
		gt6.soundEngine:playEffect("common/SpecOk", false, "2POKER")
		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		self:tipPoker(roomPlayer)
	end, nil, nil)	

	--不要按钮
	gt6.addBtnPressedListener(self.pass, function()
		gt6.soundEngine:playEffect("common/SpecOk", false, "2POKER")
		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		--众神归位
		for j=1, #roomPlayer.holdMjTiles do
			self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
		end
		local msgToSend = {}
		msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
		msgToSend.m_flag = 1
		gt6.socketClient:sendMessage(msgToSend)

		self.decisionBtnNode:setVisible(false)
	end)

	--self.pass:setVisible(self.show_buyao_btn_flag)
	self.play:setPressedActionEnabled(false)
	self.prompt:setPressedActionEnabled(false)
	self.pass:setPressedActionEnabled(false)
	self.restore:setPressedActionEnabled(false)
end

-----协议解析----------start-----------
--最后手中剩余牌消息
function PokerScene:onSurplusCard(msgTbl)
	-- body
	for i=1,self.playMaxNum do
		local outMjTilesAry = msgTbl["m_cards" .. i - 1]
		if #outMjTilesAry > 0 then
			local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(i)
			roomPlayer:removeAlreadyOutMjTiles()
		end
		if outMjTilesAry then
			for k, v in ipairs(outMjTilesAry) do
				self:addAlreadyOutMjTilesFinally(i,v,k)
			end
		end	
 	end
end

--同步出牌
function PokerScene:onRcvSyncShowMjTile(msgTbl)
	self:stopCountDownSound()
	self.is_turn_me = false
	local seatIdx = msgTbl.m_pos + 1
	
	if not tolua.isnull(self.PokerMemoryLayer) then
		self.PokerMemoryLayer:recordStyle(seatIdx, msgTbl.m_card)
	end

	-- 座位号（1，2，3）
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local realSeat = roomPlayer.displaySeatIdx

	local card = msgTbl.m_card

	--记录当前出的牌 类型 以及癞子类型 
	if #card > 0 and msgTbl.m_type ~=0 then
		local number = msgTbl.m_typeNumber or 0
		self:updateCurShowPokerInfo(msgTbl.m_type,card,number)
	end
	print("seatIdx " .. seatIdx .. " playerSeatIdx " .. self.playerSeatIdx )
	-- 出牌成功
	if msgTbl.m_errorCode == 0 then 
		--dump(roomPlayer.holdMjTiles,"roomPlayer.holdMjTiles===1111==")
		if seatIdx == self.playerSeatIdx then
			self.SelectCard = {}
		end
		self:setClockPosition(seatIdx, false)
		self:animationPlayerMjTilesReferPos(realSeat)
	end


	local is_error = self:checkPokerError(msgTbl.m_errorCode)
	if is_error then
		self.decisionBtnNode:setVisible(true)

		print("错误 错误 错误")

		local play_self = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)

		if play_self then 
			for j=1, #play_self.holdMjTiles do

			self:setPokerIsUp(play_self.holdMjTiles[j], false, false)
			end
			self.SelectCard = {}
		end
		

		return
	end 

	if seatIdx == self.playerSeatIdx then
		self:resetSelfPokerColor()
	end
	
	if msgTbl.m_flag == gt6.CommonConst.OutPokerType.BUYAO  then
		self:buYaoAction(seatIdx)
	end

	if self.decisionBtnNode:isVisible() == true then
		self.decisionBtnNode:setVisible(false)
	end
   	
   	if seatIdx ~= self.playerSeatIdx then
   		roomPlayer.leftCardsNum = roomPlayer.leftCardsNum - #card
   		roomPlayer:showLeftCardNum(self.room_config.showHandPokerNum) 
	else
		roomPlayer.leftCardsNum = roomPlayer.leftCardsNum - #card
	
   	end

   	local id_name = string.format("id_1_%d",msgTbl.m_type)
   	self:playActionByIdName(id_name ,msgTbl)

	self:refreshOutPokers(seatIdx)
end

function PokerScene:onRcvTurnShowMjTile(msgTbl)
	gt6.log("通知玩家出牌")
	local seatIdx = msgTbl.m_pos + 1 
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)

	-- 轮到玩家出牌 m_flag 当前是否第一个出牌 0-是（没有上家） 1-不是
	if msgTbl.m_flag == 0 then
		self.curShowCardInfo = {cardArr = {}, cardType = 0,cardNum = 0} --癞子 皮子等需要本地判断的才有用
	else
		self.curShowCardInfo = self.curShowCardInfo or {} --癞子 皮子等需要本地判断的才有用
		self.curShowCardInfo.m_curCardCount = msgTbl.m_curCardCount
		self.curShowCardInfo.m_curCardMode = msgTbl.m_curCardMode
		self.curShowCardInfo.m_curCardType = msgTbl.m_curCardType
	end

	-- 玩家需要处理的数据
	self.curShowMjTileInfo = msgTbl
	self.promptIndex = #msgTbl.m_array
	self.maxPromptIndex = #msgTbl.m_array

	--客户端检索提示牌
	self:localShowPokerTip()

	if self.desBtn and not tolua.isnull(self.desBtn) then --隐藏 挖坑， 斗地主特殊决策
		self.desBtn:setVisible(false)
	end

	roomPlayer:removeAlreadyOutMjTiles()

	if roomPlayer.seatIdx == self.playerSeatIdx then
		self:resetSelfPokerColor()
	end

	--判断倒计时显示
	if seatIdx == self.playerSeatIdx then
		self.is_turn_me = true
		if self.status == gt6.CommonConst.ROOM_STATUS.SEND_CARD then
			print("====xxxx====="..tostring(self.status))
			self.turnShowMsgTbl = msgTbl --第一次进入游戏，缓存下。 发牌动画结束检测禁用牌
			--仅有经典跑得快 别人出牌，检测 不能出的禁牌
			if self.mGameStyle == gt6.CommonConst.GameType.CLASSICSPDK then			
				self:disableCard(msgTbl, roomPlayer)
			end

			-- 出牌倒计时
			self.decisionBtnNode:setVisible(false)
			self:playTimeCDStart(false,seatIdx,msgTbl.m_time)
			return
		else
			self.decisionBtnNode:setVisible(true)
			self:playTimeCDStart(true,seatIdx,msgTbl.m_time)
		end
	else
		self.is_turn_me = false
		self:playTimeCDStart(true,seatIdx,msgTbl.m_time)
	end


	--托管了 后面的逻辑就不要执行了
	if self.mIsInTrusteeship then
		self.decisionBtnNode:setVisible(false)
		return
	end
	
	for i,v in ipairs(roomPlayer.holdMjTiles) do
		v.mjTileSpr:setColor(cc.c3b(255,255,255))
		v.mjIsTouch = true
	end

	if seatIdx == self.playerSeatIdx then
		--禁牌
		self:disableCard(msgTbl,roomPlayer)

		--检测不可点击牌移除
		if self.SelectCard then
			for i = #self.SelectCard, 1, -1 do
				local index = self.SelectCard[i]
				local pokerTile = roomPlayer.holdMjTiles[index]
				if pokerTile and pokerTile.mjIsTouch == false then
					table.remove(self.SelectCard,i)
				end
			end
		end

		-- --牌归位
		for j=1, #roomPlayer.holdMjTiles do
			local pokerTile = roomPlayer.holdMjTiles[j]
			if pokerTile.mjIsTouch == false then
				self:setPokerIsUp(pokerTile, false, false)
			end
		end

		-- self.SelectCard = {}
		self.tempTouchPoker = {}
	end
	
	--自动提示牌
	-- if #msgTbl.m_array == 1 then
	-- 	self:tipPoker(roomPlayer)
	-- end

	--服务器给的自动不要
	if msgTbl.m_autoPlay and msgTbl.m_autoPlay == 1 then
		if seatIdx == self.playerSeatIdx then
			--自动不要
			self.decisionBtnNode:setVisible(false)
			self:autoBuyao(seatIdx,msgTbl)
			return
		end
	end 

	--不显示不要的直接出牌
	if not self.show_buyao_btn_flag then
		if #msgTbl.m_array == 0 and msgTbl.m_flag == 1  then -- 直接到下一家
			if seatIdx == self.playerSeatIdx then
				self:autoBuyao(seatIdx,msgTbl)
				return
			end
		end
	end 

	--手牌打出 --游戏没关闭最后一手自动打牌走这里
	if not self.close_auto_end_poker_flag then
		if msgTbl.m_last == 1  then 
			--赢家座位号
			if seatIdx == self.playerSeatIdx then
				--自动出牌
				self:autoSendPoker()
				return
			end
		end
	end 
	-- 轮到玩家决策
	self:turnMeDecision(seatIdx,msgTbl)
end

--- 比赛场显示
function PokerScene:matchInfoShow( msgTbl )
	print("----> PokerScene:matchInfoShow ....")
	dump(msgTbl,"----> PokerScene:matchInfoShow( msgTbl ) : ")
	local _beginPosX = self.Sprite_BombTimes:getPositionX()
	if not self.Sprite_BombTimes:getParent():getChildByName("MLimitdifen") then 
		local _MLimitdifen = ccui.Text:create("",nil,24)
		_MLimitdifen:setColor(cc.c3b(255,255,0))
		_MLimitdifen:setName("MLimitdifen")
		_MLimitdifen:setVisible(false)
		_MLimitdifen:setPosition(  _beginPosX ,self.Sprite_BombTimes:getPositionY() - 33 )
		self.Sprite_BombTimes:getParent():addChild(_MLimitdifen)
	end

	print("---> m_ruleType = ",msgTbl.m_deskInfo.m_ruleType)
	local _isDjjf = msgTbl.m_deskInfo.m_ruleType == gt6.MatchRuleType.dingju  -- 1-定居积分； 0-打立除局 不显示
	
	self.common_ui_layer:matchInfoShow(msgTbl)

	-- 低于多少分淘汰
	if self.Sprite_BombTimes:getParent():getChildByName("MLimitdifen") and not _isDjjf then
		local _a = self.Sprite_BombTimes:getParent():getChildByName("MLimitdifen")
		_a:setString( string.format("低于 %s 分被淘汰",msgTbl.m_deskInfo.m_outScore) )
		_a:setVisible(true)
	end

end

--更新回合数
function PokerScene:onRcvRoundState(msgTbl)
	-- 是否是比赛场 
	print("----> PokerScene:onRcvRoundState(data) .....")
	dump(msgTbl,"---> 是否是比赛场 msgTbl = ",msgTbl)

	if msgTbl.m_deskInfo and not gt6.isMatch then
		gt6.isMatch = true
		print("----> 当前是比赛场 ")
	end
	gt6.isMatch = gt6.isMatch or nil
	print("---> gt6.isMatch = ",gt6.isMatch)

	if gt6.isMatch then
		Utils6.initMatchProxy()
		if self:getChildByName("roundReport") then
			self:getChildByName("roundReport"):removeFromParent()
		end

		self:matchInfoShow(msgTbl)

		gt6.MCommonMatchManage:SetMatchingStatus(true)
		print("----> jushu : ",msgTbl.m_curCircle,msgTbl.m_curMaxCircle)
		gt6.MCommonMatchManage:SetMatchRoundEnd( (msgTbl.m_curCircle+1) == msgTbl.m_curMaxCircle)
		-- 
	end
	-- 牌局状态,剩余牌
	local stateNum = string.format("%d/%d",(msgTbl.m_curCircle + 1), msgTbl.m_curMaxCircle)
	gt6.log("onRcvRoundState:"..stateNum)
	self.common_ui_layer:updateRoundUi(stateNum)

end

--单局结算
function PokerScene:onRcvRoundReport(msgTbl)
	gt6.log("游戏结束")
	if self.mRoomPattern == gt6.CommonConst.RoomPattern.COIN then
		self:removeTrusteeshipBtn()
		--结束后 弹窗下面的定时器
		if msgTbl.m_time and not tolua.isnull(self.mAlarmClockLayer) then
			self.mAlarmClockLayer:startCountDown(msgTbl.m_time)
		end			
	end

	if gt6.isMatch then
		if not tolua.isnull(self.mAlarmClockLayer) then
			self.mAlarmClockLayer:startCountDown(10)
		end
	end

	if gt6.isMatch then
		self.common_ui_layer:clearMatchShow()
	end

	--翻倍更新
	self:fanBeiOnRcvRoundReport(msgTbl)

	-- gt.agoraUtil:leaveChannel()
	self:setStatus(gt6.CommonConst.ROOM_STATUS.ROUND_END)

	self:stopCDAudio()
	-- 清除三张底牌
	self:clearLastHand()

	--发送移除警报
	gt6.PlayersManager:removeAlarm()

	--不通游戏，延迟时间不同，表里配
	local delTime = self.room_config.roundReportDelayTime
	local delayTime = cc.DelayTime:create(delTime)
	local callFunc = cc.CallFunc:create(function(sender)
		self:showWinTip(false)
		self:clearCheckPoker()
		self:roundEnd()

		self.mIsInTrusteeship = false
		self.is_turn_me = false
		self.SelectCard = {}
		-- 停止倒计时音效
		self.playTimeCD = nil

		--隐藏闹钟 托管
	   	for i = 1, self.playMaxNum do
			local room_play = gt6.PlayersManager:getRoomPlayersBySeat(i)
			if room_play then
				room_play:removeIdentity()
				room_play:removeTrusteeship() --移除托管机器人
			end
	    end		

		-- 隐藏倒计时
		if not tolua.isnull(self.clock) then self.clock:setVisible(false) end
		-- 隐藏决策
		self.decisionBtnNode:setVisible(false)
		--
		self:hidePlayDecisionBtn()
		if not tolua.isnull(self.nograb) then self.nograb:setVisible(false) end
		if not tolua.isnull(self.grab) then self.grab:setVisible(false) end

		--清除托管相关
		self:gameEndClearTrusteeship()

		-- 弹出局结算界面
		local roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
		local data = {}
		data.roomPlayers = roomPlayers or {} --之前这样可能roomPlayers是nil 效仿一下 final时候的处理
		data.playerSeatIdx = self.playerSeatIdx
		data.rptMsgTbl = msgTbl
		data.dizhuPos = self.mZhuangPos
		data.isCoin = false
		data.gameStyle = self.mGameStyle
		if self.mRoomPattern == gt6.CommonConst.RoomPattern.COIN then 
			data.isCoin = true 
		end
		
		-- gt6.log("self.mGameStyle " .. self.mGameStyle)
		-- dump(data,"----> create RoundReport_DDZ : ")
		--如果在弹出胜利界面，在胜利上面显示
		gt6.dispatchEvent(gt6.EventType.CHECK_ZORDER, {tag = "AlarmClockLayer", order = gt6.CommonConst.ZOrder.ROUND_REPORT + 1 } )

  --  		local roundReport = require("app/gameType/2POKER/playScene/RoundReport_DDZ"):create(data)
  --  		roundReport:setName("roundReport")
		-- self:addChild(roundReport, gt6.CommonConst.ZOrder.ROUND_REPORT)
		if gt6.isMatch then
			dump(msgTbl,"---> 斗地主结算界面 msgTbl = ")
			if gt6.MCommonMatchManage then
				print("====> 斗地主结算 new 111111")
				gt6.MCommonMatchManage:SetMatchRoundReport(false)
			end
			print("---> 比赛结束 ，是否是最后一局 m_end = ",msgTbl.m_end)
			-- msgTbl.m_end = 1
			if gt6.MCommonMatchManage and tonumber(msgTbl.m_end) == 1 then
				print("---> 斗地主结算 new  222222")
				gt6.MCommonMatchManage:changeShowLayerIndex()
				gt6.MCommonMatchManage:showContinueMatch()
				if gt6.MCommonMatchManage:GetMatchingStatus() then -- 已经开始比赛
					gt6.MCommonMatchManage:removeWaitTips()
				end
			else
				print("--->斗地主 结算 new  2333333")
				local playerSeatIdx = self.playerSeatIdx
				gt6.dispatchEvent("msg_MatchRewardLayer",playerSeatIdx)
			end
		else
			local roundReport = require("app/gameType/2POKER/playScene/RoundReport_DDZ"):create(data)
	   		roundReport:setName("roundReport")
			self:addChild(roundReport, gt6.CommonConst.ZOrder.ROUND_REPORT)
		end

        self.mZhuangPos = nil
	end)
	
	local seqAction = cc.Sequence:create(delayTime, callFunc)
	self:runAction(seqAction)
end

--总结算
function PokerScene:onRcvFinalReport(msgTbl)
	-- 在这儿输出 得到的是正确的
	gt6.log("总结算界面提示")
	if gt6.isMatch then 
		print("----> 当前在比赛轮间") 
		return 
	end
	self:setStatus(gt6.CommonConst.ROOM_STATUS.FINAL_END)

	local delayTime = cc.DelayTime:create(1.2)
	local callFunc = cc.CallFunc:create(function(sender)
		-- 弹出总结算界面
		local roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
		local finalReport = require("app/public/inGame/FinalReport"):create(roomPlayers, msgTbl,true,self.common_ui_layer)
		self:addChild(finalReport, gt6.CommonConst.ZOrder.VOICE_NODE)	
	end)
	local seqAction = cc.Sequence:create(delayTime, callFunc)
	self:runAction(seqAction)
end

function PokerScene:onRcvStartGame(msgTbl)
	if not tolua.isnull(self.mAlarmClockLayer) then
		self.mAlarmClockLayer:stopCountDown()
	end

	self:setStatus(gt6.CommonConst.ROOM_STATUS.SEND_CARD)
	--同步room
	self:syncRoom(msgTbl)

	--清理记牌器
	if not tolua.isnull(self.PokerMemoryLayer) then
		self.PokerMemoryLayer:clear()
	end
	--播放开牌
	self:playSendPoker(msgTbl)
	gt6.PlayersManager:hideAllDecisionOperTips() --隐藏所有决策提示
end


function PokerScene:onRcvSyncRoomState(msgTbl)
	--同步room
	self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)

	self:syncRoom(msgTbl)
	if not tolua.isnull(self.PokerMemoryLayer) then --断线，同步上下家牌
		self.PokerMemoryLayer:syncStyle( msgTbl )
	end
end


function PokerScene:onRcvASKDIZHU(msgTbl)
	-- body
	dump(msgTbl,"onRcvASKDIZHU====")
	self.deciBtnsCtrlInfo = msgTbl

	self.doingAskIndex = msgTbl.m_pos

	if self.status == gt6.CommonConst.ROOM_STATUS.SEND_CARD
	or self.mIsInTrusteeship then
		return
	end

	self:updateDecisionBtns()
end

--此协议服务器会算好当前倍数 且 difen为倍数
function PokerScene:onRcvANSDIZHU(msgTbl)

	if msgTbl.m_difen <= 0 then --这个倍数，起码是1
		self.curMultiple = 1
	else
		self.curMultiple = msgTbl.m_difen
	end

	if self.mGameStyle == gt6.CommonConst.GameType.WUPIZI 
		or self.mGameStyle == gt6.CommonConst.GameType.DAIPIZI then
		self.curMultiple = msgTbl.m_nUserBeishu[self.playerSeatIdx]
	end
	self.Txt_Times:setString(self.curMultiple)
end

function PokerScene:onRcvWHOISDIZHU(msgTbl)
	gt6.PlayersManager:hideAllDecisionOperTips() --隐藏所有决策提示
	-- dump("onRcvWHOISDIZHU",msgTbl)
	local seatIdx = msgTbl.m_pos + 1
	self.mZhuangPos = seatIdx
	self.doingAskIndex = nil 

	if msgTbl.m_difen and msgTbl.m_difen~=0 then
		self.curMultiple = msgTbl.m_difen
		if self.Txt_Times then
			self.Txt_Times:setString(self.curMultiple)
			gt6.log("PokerScene onRcvASKDIZHU Txt_Times " .. msgTbl.m_difen)
		end
	end
	
	-- 插牌
	if seatIdx == self.playerSeatIdx then
		for k, v in ipairs(msgTbl.m_LeftCard) do
			self:addMjTileToPlayer(v)
		end
	end

	-- self:showLastHandPoker(msgTbl.m_LeftCard,false)
	if not tolua.isnull(self.bottomCard ) then
		self.bottomCard:showLastHandPoker(msgTbl.m_LeftCard,false)
	end
	
	if seatIdx == self.playerSeatIdx then --自己抢到地主
		self:addLastPokerAni(msgTbl)
	else -- 别人抢到地主
		self:addLastPokerNum(seatIdx)

		self:refreshRivalPoker(seatIdx)--二人时要刷新对手的牌
	end

	 --确认某人是地主后 要把明牌翻回去
  	self:hideOpponentOpenPoker()

	local room_player = gt6.PlayersManager:getRoomPlayersBySeat(self.mZhuangPos)
	self:showIdentity(room_player)
end

function PokerScene:onRcvSHOWCARDS(msgTbl)
	-- body
	local seatIdx = msgTbl.m_pos + 1
	if seatIdx == self.playerSeatIdx then
		if msgTbl.m_MyCard then
			for _, v in ipairs(msgTbl.m_MyCard) do
				self:addMjTileToPlayer(v)
			end
		    -- 根据花色大小排序并重新放置位置
			self:sortFinalPlayerMjTiles()

			local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
			roomPlayer.removeUselessTiles()
		end	
	end
end
-----协议解析----------end-----------

--单局结算翻倍更新
function PokerScene:fanBeiOnRcvRoundReport( msgTbl )
	if not msgTbl then return end
	if not msgTbl.m_chuntian then return end

	if not self.mMaxFanShu then 
		return 
	end 

	for i,v in ipairs(msgTbl.m_chuntian) do
		if v == gt6.CommonConst.PokerReportType.Spring or v == gt6.CommonConst.PokerReportType.BackSpring then
			if self.mGameStyle == gt6.CommonConst.GameType.DAIPIZI  then
				self:countFanMultiple()
			
				-- 反春天
				if self.mZhuangPos ~= i then
					self:countFanMultiple()
				end
			else
				self:countNormlMultiple()
			end
			break
		end
	end

	self:updateMultipleUi(self.curMultiple)
end

--清除底牌和癞子
function PokerScene:clearLastHand()
	if not tolua.isnull(self.bottomCard) then
		self.bottomCard:clearLastHand()
		self.bottomCard:setVisible(false)
	end

	if not tolua.isnull(self.mFakeLayer) then
		self.mFakeLayer:setFakeVisible(false)
	end
end


----------解析动作------------start--------
function PokerScene:doAction(realId,data,action)
	realId = tonumber(realId)

	if realId == gt6.CommonConst.PlayAction.ADD_TABLE_POKER then  --添加出的牌
		self:doAddOutPoker(data)

	elseif realId == gt6.CommonConst.PlayAction.REMOVE_HOLD_POKER then  --移除手里的牌
		self:doRemoveHandPoker(data,action)

	elseif realId == gt6.CommonConst.PlayAction.PLAY_POKER_SPEAK then  --播放出牌语音
		self:doPokerSpeak(data,action)

	elseif realId == gt6.CommonConst.PlayAction.PLAY_POKER_EFFECT then  --播放牌型效果
		self:doPokerEffect(data,action)

	elseif realId == gt6.CommonConst.PlayAction.PLAY_HEAD_EFFECT then --播放头像效果
		self:doOperEffect(data,action)

	elseif realId == gt6.CommonConst.PlayAction.PLAY_BOMB_EFFECT then --炸弹效果
		self:doBombAni(data,action)

	elseif realId == gt6.CommonConst.PlayAction.PLAY_COUNTMULTIPLE then --计算倍数
		self:doCountMul(data,action)
	elseif realId == gt6.CommonConst.PlayAction.PLAY_GETBOTTOMCARD then --地主拿牌 重播使用
		self:doGetBottomCard(data,action)
	elseif realId == gt6.CommonConst.PlayAction.PLAY_AGAINDEAL then --没人抢地主，重新发牌
		self:doAgainDeal(data,action)
	elseif realId == gt6.CommonConst.PlayAction.PLAY_DEALLAIZI then --发癞子牌
		self:doDealLaiZi(data,action)
	end
end

function PokerScene:doAddOutPoker(data)
	local card = data.card
	if not card then
		return
	end 

	dump(card,"card====")
	for k,v in ipairs(card) do
		self:addAlreadyOutMjTiles(data.seatIdx, v, #card,data.laiZi)
	end
end

--移除手牌
function PokerScene:doRemoveHandPoker(data,action)
	print("chupai...")
	dump(data)
	local seatIdx = data.seatIdx
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)

	local flag = data.flag
	local card = data.card

	card = self:checkLaziPosAndIdx(card, data.type, data.laiZi)--带癞子 重新排序出的牌 子函数实现 

	if seatIdx == self.playerSeatIdx then
		for i,v in ipairs(card) do
			for j=1, #roomPlayer.holdMjTiles do
				if roomPlayer.holdMjTiles[j].mjIndex == v then
					--删除
					roomPlayer.holdMjTiles[j].mjTileSpr:removeFromParent()
					table.remove(roomPlayer.holdMjTiles, j)
					break
				end
			end
		end

		-- 根据花色大小排序并重新放置位置x
		if  flag ~= gt6.CommonConst.OutPokerType.BUYAO then
			self:sortPlayerMjTiles(self.playerSeatIdx)
		end

		--二人时要时时刷新自己还有几张获胜
		if self.playerSeatIdx ~= self.mZhuangPos then
			-- local cardNum = #card
			self:updateWinPokerNum(roomPlayer)
		end
	else
		if self.show_opponent_poker_back_flag then
			local poker_total = #roomPlayer.holdMjTiles
			print("poker_total==="..tostring(poker_total))

			for i,v in ipairs(card) do
				local pokerTitle = roomPlayer.holdMjTiles[poker_total]
				if pokerTitle then
					pokerTitle.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.holdMjTiles, poker_total)
					poker_total = poker_total - 1
				end
			end

			self:sortPlayerMjTiles(seatIdx)
		end
	end
end

--播放头像效果
function PokerScene:doOperEffect(data,action)
	if data.flag == gt6.CommonConst.OutPokerType.BUYAO then
		return
	end
	--逻辑座位号
	local seatIdx = data.seatIdx
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)

	xpcall(function ()
		if seatIdx ~= self.playerSeatIdx then
			local desArray = { 309, 310, 311, 312, 313,314, 315,316, 317}
			local isShowTips = true
			for key, value in ipairs(desArray) do
				if value == tonumber( action.id ) then
					isShowTips = false
				end
			end

			local res_plist = gt6.getGameTypeRes().."play_scene.plist"
			if isShowTips then
				roomPlayer:showOperTips(action.pic,res_plist)
			else
				roomPlayer:showDecisionOperTips(action.pic,res_plist)
			end
	  	end

		local sound = action.sound
		if sound then
			
			local sound_name = (roomPlayer.sex == 1) and string.format("man/%s",sound) or string.format("man/%s",sound)
			gt6.soundEngine:playEffect(sound_name,false,"2POKER")
		end
	end,

	function ()
		gt6.log("-playOperEffect--pic error or sound error--")
	end)
end

function PokerScene:doPokerSpeak(data,action)
	gt6.log("playecard is here ") 
	local seatIdx = data.seatIdx
	local card = data.card 
	local flag = data.flag
	local soundName  = action.sound 
	local sound = nil 
	local num = math.random(1,3)

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local sound_path = self:getSoundPath(roomPlayer.sex)
	sound = sound_path..soundName

	if card then
		local value , color = GamePlayUtils.changePk(card[1])
		if self.mLaiziValue then
			if tonumber(data.action) == gt6.CommonConst.CardType.card_style_double then
				local value1 , color1 = GamePlayUtils.changePk(card[1])
				local value2 , color2 = GamePlayUtils.changePk(card[2])
				if self.mLaiziValue == value1 and self.mLaiziValue == value2 then
					value = value1
				elseif self.mLaiziValue == value1 and self.mLaiziValue ~= value2 then
					value = value2
				elseif self.mLaiziValue ~= value1 and self.mLaiziValue == value2 then
					value = value1
				else
					value = value1
				end
			end
		end

		local speak_type = action.poker_sound_type
		local poker_special_sound = action.poker_special_sound

		--是否需要播放大你的开关条件
		if poker_special_sound == "dani" then
			if flag == gt6.CommonConst.OutPokerType.OUT then
				--播放大你
				sound = sound_path..poker_special_sound..num
			elseif flag == gt6.CommonConst.OutPokerType.FIRST_OUT then
				--all 代表全花色
				if speak_type == "all" then
					sound = sound_path..soundName..value
				end
			end
		else
			if speak_type == "all" then
				sound = sound_path..soundName..value
			end
		end
	end

	gt6.log("playecard is here===="..tostring(sound))
	gt6.soundEngine:playEffect(sound,false,"2POKER")
	gt6.soundEngine:playEffect("common/Special_give", false, "2POKER")
end

function PokerScene:doPokerEffect(data,action)
	xpcall(function ()
		local realSeat = data.realSeat
		
		gt6.log("realSeat---"..tostring(realSeat))

		local mjTilesReferPos = self:animationPlayerMjTilesReferPos(realSeat)

	  	local sound = action.sound
		if sound then
			local sound_name = string.format("common/%s",sound)
			gt6.soundEngine:playEffect(sound_name,false,"2POKER")
		end

	
	    --动画列表
		local ani_list = action.ani_list
		--动画位置类型列表
		local ani_pos_type_list = action.ani_pos_type_list
		if ani_list and ani_pos_type_list then
			local count = #ani_list
			for i = 1, count do
				local x = mjTilesReferPos.outStart.x
				local y = mjTilesReferPos.outStart.y

				GamePlayUtils.playAnimation(self.rootNode,ani_list[i],ani_pos_type_list[i],x,y)
			end
		end
	end,

	function (error)
		gt6.log("-playOperEffect--pic error or sound error--"..error)
	end)
end

--执行炸弹效果
function PokerScene:doBombAni(data,action)
	gt6.soundEngine:playEffect("common/Special_Bomb_New", false, "2POKER")
	if data.realSeat == 1 then
		local sprite = GamePlayUtils.playAnimation(self.rootNode,"baozharight")
	elseif data.realSeat == 2 then
		local sprite = GamePlayUtils.playAnimation(self.rootNode,"baozhaleft")
	elseif data.realSeat == 3 then
		local sprite = GamePlayUtils.playAnimation(self.rootNode,"baozhafront")
	end
end

--计算倍数
function PokerScene:doCountMul(data,action)	
	--目前这个参数代表 不存在算炸弹
	if not self.mMaxFanShu then 
		return 
	end 

	if not self.isReplay then
		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(data.seatIdx)
		roomPlayer:addBoomCount()

		self:countNormlMultiple()
		self:updateMultipleUi(self.curMultiple)
	end
	
end

function PokerScene:doLoveDays(data,action)
	--播放情人节动画
	-- local mjTilesReferPos = self:animationPlayerMjTilesReferPos(1)
	-- -- local sprite = self:playAnimation("valentinesday1",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	-- if msgTbl.m_nLoverDaysType == 0 then
	-- 	local sprite = self:playAnimation("valentinesday1",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	-- elseif msgTbl.m_nLoverDaysType == 1 then
	-- 	local sprite = self:playAnimation("valentinesday2",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	-- elseif msgTbl.m_nLoverDaysType == 2 then
	-- 	local sprite = self:playAnimation("valentinesday3",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	-- end
end

----------解析动作------------end--------


function PokerScene:initPokerTouch()
	-- 触摸事件
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.cards_layer)
end

function PokerScene:onTouchBegan(touch, event)
	gt6.log("onTouchBegan states " .. self:getStatus())

	if self.mIsInTrusteeship then --托管中 点击屏幕取消托管
		self:sendCancelTrusteeshipMsg()
		return false --如果托管中 不允许提牌等操作
	end

	if not self:isBoardStart() then
		return false
	end

	--获取点击到了那一张牌和牌的位置（如果没有点击到牌就返回nil）
	local touchMjTile, mjTileIdx = self:touchPlayerMjTiles(touch:getLocation())

	if not touchMjTile then
		print("touchMjTile nil ")
		--点击两次牌归原位
		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		local curTimeStr = os.date("%X", os.time())
		local timeSections = string.split(curTimeStr, ":")
		local time = timeSections[3]
		if time - self.time < 0.6 then
			for j=1, #roomPlayer.holdMjTiles do
				self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, true)
			end
			self.time = 0
			self.SelectCard = {}
		else
			self.time = time
			-- 重置二义性选牌界面
			if not tolua.isnull(self.mAmbiguityLayer) then
				self.mAmbiguityLayer:resetAmbiguity()
			end
		end
		return false
	end

	self.tempTouchPoker = {}	--本次触摸操作中点击到的牌（存储原因是为了防止二次触碰）
	self.chooseMjTile = touchMjTile --点击的牌
	self.chooseMjTileIdx = mjTileIdx --点击的牌在数组中的位置
	self.preTouchPoint = self.cards_layer:convertTouchToNodeSpace(touch) --点击到的坐标在牌空间内的坐标
	self.tempTouchPoker[#self.tempTouchPoker + 1] = self.chooseMjTileIdx --存储点击处理过的牌
	self.chooseMjTile.mjTileSpr:setColor(cc.c3b(200,200,200)) --改变点击牌的颜色
	return true
end

function PokerScene:onTouchMoved(touch, event)
	if not self:isBoardStart() then
		return 
	end

	--print("self.isTouch==="..tostring(self.isTouch))

	local moveTouchPoint = self.cards_layer:convertTouchToNodeSpace(touch)
	if math.abs(moveTouchPoint.x - self.preTouchPoint.x) > 5 or math.abs(moveTouchPoint.y - self.preTouchPoint.y) > 5 then
		
		--获取点击到了那一张牌和牌的位置（如果没有点击到牌就返回nil）
		local touchPokerTile, pokerTileIdx = self:touchPlayerMjTiles(touch:getLocation())
		if touchPokerTile and touchPokerTile.mjIsTouch then
			self.tempTouchPoker = {};
			local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
			local startIndex = 0
			local endIndex = 0
			if self.chooseMjTileIdx <= pokerTileIdx then
				startIndex = self.chooseMjTileIdx
				endIndex = pokerTileIdx
			else
				startIndex = pokerTileIdx
				endIndex = self.chooseMjTileIdx
			end

			for i = startIndex,endIndex do
				self.tempTouchPoker[#self.tempTouchPoker + 1] = i
				local hold_poker = roomPlayer.holdMjTiles[i]
				if hold_poker and hold_poker.mjIsTouch then
					hold_poker.mjTileSpr:setColor(cc.c3b(200,200,200))
				end
				
			end

			for i = 1, startIndex-1 do
				local hold_poker = roomPlayer.holdMjTiles[i]
				if hold_poker and hold_poker.mjIsTouch then
					hold_poker.mjTileSpr:setColor(cc.c3b(255,255,255))
				end
				
			end

			for i = endIndex+1, #roomPlayer.holdMjTiles do
				local hold_poker = roomPlayer.holdMjTiles[i]
				if hold_poker and hold_poker.mjIsTouch then
					hold_poker.mjTileSpr:setColor(cc.c3b(255,255,255))
				end
				
			end
		end
	end	
end

function PokerScene:onTouchEnded(touch, event)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	local holdMjTiles = roomPlayer.holdMjTiles
	if not (holdMjTiles) or #holdMjTiles <= 0 then
		return
	end

	--检测临时牌和手牌是否一致
	if self.tempTouchPoker then
		print("==dddd====ddd==")
		for i = #self.tempTouchPoker, 1, -1 do
			local index = self.tempTouchPoker[i]
			local pokerTile = holdMjTiles[index]
			if not pokerTile or not pokerTile.mjIsTouch then
				table.remove(self.tempTouchPoker,i)
			end
		end
	end	

	if self.tempTouchPoker and #self.tempTouchPoker == 0 then return end --如果没有点击的牌

	if self.curShowCardInfo and self.curShowCardInfo.m_curCardCount and self.curShowCardInfo.m_curCardCount > 0 then --上家出牌了
		require("app/gameType/2POKER/StyleMgr/StyleHelp_DDZ")
		-- dump(self.tempTouchPoker, "self.tempTouchPoker 1")

		local is_have_up = false
		for j=1, #holdMjTiles do
			local pokerTile = holdMjTiles[j]
			if pokerTile.mjIsUp then
				is_have_up = true
				break
			end
		end

		if not is_have_up then --没有提起的牌
			local my_index_list = GamePlayUtils.getIndexListBySelect(self.tempTouchPoker, holdMjTiles)
			-- dump(my_index_list, "my_index_list")
			local tip_pk_info_array = gt6.StyleHelp_DDZ:getInstance():slideAutoHint(self.curShowCardInfo, my_index_list)
			local need_tip_array = tip_pk_info_array[#tip_pk_info_array] or {}
			if #need_tip_array > 0 then --提示出选中的牌
				self.tempTouchPoker = GamePlayUtils.getPkIdxByInfoArray(need_tip_array,  holdMjTiles)
				-- dump(self.tempTouchPoker, "self.tempTouchPoker 2")
			end

			self:lowerAllPoker(holdMjTiles) --压下所有的牌 颜色恢复
			self:upSelectPoker( self.tempTouchPoker, holdMjTiles ) --提起选中牌
			self:addToSelectCard(self.tempTouchPoker) --插入select
		else

			if 1 == #self.tempTouchPoker then --点击单张牌 提起的压下，压下的提起
				gt6.log("点击单张牌 提起的压下，压下的提起")
				self:oppositeUpDown(self.tempTouchPoker, holdMjTiles )
			else
				--1.再次拉选时（拉选范围大于等于上升牌的范围），则上升牌全部落下，其他处于落下的牌保持落下状态不变
				--2.再次拉选时（拉选范围不包括上升牌的范围，即在上升牌的范围之外），则再次拉选的牌全部上升（即之前处于上升的牌和当前拉选牌全部处于上升状态，其他牌处于落下状态）		
				--3.部分包含，下的提上去，提上去的压下来

				local sortHoldIdxArray = function (array ) --降序
					table.sort(array, function (a, b )
						return a > b
					end)
				end
				sortHoldIdxArray( self.SelectCard )
				sortHoldIdxArray( self.tempTouchPoker )
				dump(self.SelectCard , "self.SelectCard   0000")
				dump(self.tempTouchPoker , "self.tempTouchPoker   0000")
				if self.tempTouchPoker[1] >= self.SelectCard[1] and 
					self.tempTouchPoker[#self.tempTouchPoker] <= self.SelectCard[#self.SelectCard] then --全都压下来
					gt6.log("全都下来")
					self:lowerAllPoker(holdMjTiles) --压下所有的牌 颜色恢复
					self.SelectCard = {}
				elseif self.tempTouchPoker[1] < self.SelectCard[#self.SelectCard] or  
					self.tempTouchPoker[#self.tempTouchPoker] > self.SelectCard[1] then --提起新选中的

					gt6.log("提起新选中的")
					self:upSelectPoker( self.tempTouchPoker, holdMjTiles ) --提起选中牌
					self:addToSelectCard(self.tempTouchPoker) --插入select

				else --提起的压下，压下的提起
					gt6.log("提起的压下，压下的提起")
					self:oppositeUpDown(self.tempTouchPoker, holdMjTiles )
				end
			end
		end

		--颜色恢复
		for j=1, #holdMjTiles do
			if holdMjTiles[j].mjIsTouch then
				holdMjTiles[j].mjTileSpr:setColor(cc.c3b(255,255,255))
			end
		end

	else

		--根据开关判断是否算牌
		if self.auto_calc_card_flag then
			local function resetNormalCardByType(tempTouchPoker, countValue , cardNum)
				local tempPokerTiles = {}
				for i,v in ipairs(tempTouchPoker) do
					tempPokerTiles[i] = v
				end
				for i = #tempPokerTiles, 1, -1 do
					local pokerTile = roomPlayer.holdMjTiles[tempPokerTiles[i]]
					if pokerTile then
						local value, color = GamePlayUtils.changePk(pokerTile.mjIndex)
						if countValue[value] > cardNum then
							pokerTile.mjTileSpr:setColor(cc.c3b(255,255,255))
							table.remove(tempTouchPoker,i)
							countValue[value] = countValue[value] - 1
						end
					end
				end
			end
			local isStraight, straightCountValue = GamePlayUtils.isStraight(self.tempTouchPoker,holdMjTiles, self.room_config.shunZiBeginNum ) --单顺 
			local isDoubleStraight, doubleStrCountValue = GamePlayUtils.isDoubleStraight(self.tempTouchPoker,holdMjTiles, self.room_config.lianDuiBeginNum ) --双顺 self.room_config

			--根据开关判断是否有飞机
			if self.check_airplane_flag then
			    --有飞机牌型
				local isAirplane = GamePlayUtils.isAirplane(self.tempTouchPoker,holdMjTiles)
				if isStraight == true and isDoubleStraight == false and isAirplane == false then
					resetNormalCardByType(self.tempTouchPoker, straightCountValue, 1)
				elseif isStraight == false and isDoubleStraight == true and isAirplane == false then
					resetNormalCardByType(self.tempTouchPoker, doubleStrCountValue, 2)
				end
			else
				--无飞机牌型
				if isStraight == true and isDoubleStraight == false then
					--单顺，非双顺
					resetNormalCardByType(self.tempTouchPoker, straightCountValue, 1)
				elseif isStraight == false and isDoubleStraight == true then
					--非单顺，双顺，没飞机
					resetNormalCardByType(self.tempTouchPoker, doubleStrCountValue, 2)
				end
			end
		end
		
		self:oppositeUpDown(self.tempTouchPoker, holdMjTiles ) --提牌
	end
	gt6.soundEngine:playEffect("common/SpecSelectCard", false, "2POKER")
end

function PokerScene:oppositeUpDown( pokerIdxArray, holdMjTiles ) --牌，提起的压下，压下的提起
	if not pokerIdxArray or not holdMjTiles then return end
	for i=1, #pokerIdxArray do
		local hold_poker = holdMjTiles[pokerIdxArray[i]]
		if hold_poker then
			local result = self:touchPoker(hold_poker)
			if hold_poker.mjIsTouch then
				hold_poker.mjTileSpr:setColor(cc.c3b(255,255,255))
			end
			self:updateSelectCard(result, pokerIdxArray[i])
		end
	end
end

function PokerScene:lowerAllPoker( holdMjTiles ) --压下所有的牌 颜色恢复
	if not holdMjTiles then return end
	for j=1, #holdMjTiles do --压下所有的牌 颜色恢复
		local pokerTile = holdMjTiles[j]
		self:setPokerIsUp(pokerTile, false, false)
		if pokerTile.mjIsTouch then
			pokerTile.mjTileSpr:setColor(cc.c3b(255,255,255))
		end
	end
end

function PokerScene:upSelectPoker(pokerIdxArray, holdMjTiles ) --根据手牌下标提起扑克
	if not pokerIdxArray or not holdMjTiles then return end
	for k, v in ipairs( pokerIdxArray ) do --提起选中牌
		local pkTile = holdMjTiles[v]
		if pkTile then
			self:setPokerIsUp(pkTile, true, true)
		end
	end	
end

function PokerScene:addToSelectCard( pokerIdxArray ) --把手牌下标数组插入SelectCard中
	if not pokerIdxArray then return end
	for k, mjTileIdx in ipairs( pokerIdxArray ) do --插入select
		local isTocuhPoker = false
		for i=1, #self.SelectCard do
			if mjTileIdx == self.SelectCard[i] then
				isTocuhPoker = true
				break;
			end
		end
		if not isTocuhPoker then
			table.insert(self.SelectCard, mjTileIdx)
		end
	end	
end

--执行不要动作
function PokerScene:buYaoAction(seatIdx)
	
	--自己不要的时候是要马上回复颜色的 策划需求
	-- if seatIdx == self.playerSeatIdx then
	-- 	if roomPlayer and roomPlayer.holdMjTiles then
	-- 		for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
	-- 			pkTile.mjTileSpr:setColor(cc.c3b(255,255,255))
	-- 			pkTile.mjIsTouch = true
	-- 		end
	-- 	end
	-- end

	local num = math.random(1,4)
	local sound = "man/buyao" .. num
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local ispre = ispre or false
	if roomPlayer.sex == 1 then
		sound = "man/buyao" .. num
	else
		sound = "woman/buyao" .. num
	end
	
	gt6.soundEngine:playEffect(sound,false,"2POKER")
	
	if seatIdx ~= self.playerSeatIdx then
	  	roomPlayer:showOperTips("gt6_ddz_play_buchu.png")
	end
end

function PokerScene:refreshOutPokers(seatIdx)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	-- 重新排列打出去的牌
	if self.re_sort_out_poker_flag then
		gt6.LaiZiUtils.laiziSort(roomPlayer.outMjTiles)
	end

	if seatIdx == self.playerSeatIdx then
		self:singleLineOutPoker(roomPlayer)
	else
		if self.playMaxNum == 2 then
			self:singleLineOutPoker(roomPlayer)
		else
			self:multiLineOutPoker(roomPlayer)
		end
		
	end 
end

--Single line
function PokerScene:singleLineOutPoker(roomPlayer)

	local tileWidth = 102
	local totalWidth = tileWidth + (#roomPlayer.outMjTiles - 1) * 56
	-- 计算牌的起始位置
	local startX = (gt6.winSize.width - totalWidth) / 2 + tileWidth / 2
	for k, pkTile in ipairs(roomPlayer.outMjTiles) do
		local posX = startX + (k - 1) * 56
		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		local mjTilePos = mjTilesReferPos.outStart
		pkTile.mjTileSpr:setPosition(cc.p(posX, mjTilePos.y))
		self.cards_layer:reorderChild(pkTile.mjTileSpr, posX + 300)
	end
end

function PokerScene:multiLineOutPoker(roomPlayer)
	for k, pkTile in ipairs(roomPlayer.outMjTiles) do
		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		local mjTilePos = mjTilesReferPos.outStart
		local lineCount = math.ceil(k / 8) - 1
		local lineIdx = k - lineCount * 8 - 1
		mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
		mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
		pkTile.mjTileSpr:setPosition(mjTilePos.x,mjTilePos.y)
		local mjZorder =  mjTilePos.x
		if k > 8 then
			mjZorder = mjTilePos.x + 200
		end
		self.cards_layer:reorderChild(pkTile.mjTileSpr,mjZorder)
		gt6.log("LineCount:"..lineCount  .. "mjZorder:".. mjZorder..  "k:" .. k)
		-- if roomPlayer.displaySeatIdx == 2 and lineCount == 1 then
		-- 	pkTile.mjTileSpr:setZOrder(10)
		-- end
	end
end

--提牌
function PokerScene:touchPoker(poker)
	print("poker.mjIsTouch=="..tostring(poker.mjIsTouch))
	if poker.mjIsTouch then
		if poker.mjIsUp then
			self:setPokerIsUp(poker, false, true)
			return false
		else
			self:setPokerIsUp(poker, true, true)
			return true
		end
	end
end

function PokerScene:setPokerIsUp( poker, isUp, action)
	poker.mjTileSpr:stopAllActions()
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local _mjTilePos = mjTilesReferPos.holdStart
	local mjTilePos = cc.p(poker.mjTileSpr:getPosition())

	local offest = 0

	print("poker.mjIsUp ==="..tostring(poker.mjIsUp))
	print("poker.mjIsUp ==="..tostring(isUp))
	if poker.mjIsUp ~= isUp then
		if not poker.mjIsUp then
			offest = 26
		end

		poker.mjTileSpr:setPosition(cc.p(mjTilePos.x, _mjTilePos.y + offest))
		poker.mjIsUp = isUp;
	end
end


function PokerScene:touchPlayerMjTiles(touch)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)

	if not roomPlayer.holdMjTiles then
		return nil
	end

	for i=#roomPlayer.holdMjTiles, 1, -1  do
		local mjTile = roomPlayer.holdMjTiles[i];
		local touchPoint = mjTile.mjTileSpr:convertToNodeSpace(touch)
		local mjTileSize = mjTile.mjTileSpr:getContentSize()

		local mjTileRect = cc.rect(0, 0, mjTileSize.width, mjTileSize.height)
		if cc.rectContainsPoint(mjTileRect, touchPoint) then
			return mjTile, i
		end
	end
	return nil
end

--操作牌相关----start-------------------
function PokerScene:sortFinalPlayerMjTiles()
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- 计算牌开始的位置
	local cardNum = #roomPlayer.holdMjTiles -- 当前手牌数量
	local mjTilePos = self:getHoldStartPoint(self.playerSeatIdx,cardNum)

	for k, mjTile in ipairs(roomPlayer.holdMjTiles) do
		mjTile.mjTileSpr:stopAllActions()
		mjTile.mjTileSpr:setVisible(false)
		mjTile.mjTileSpr:setPosition(mjTilePos.x,mjTilePos.y)
		self.cards_layer:reorderChild(mjTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	end

	local k = 1
	for i = #roomPlayer.holdMjTiles, 1 , -1 do	
		local mjTile = roomPlayer.holdMjTiles[i]
		local delayTime = cc.DelayTime:create(0.05*k)
		local callFunc = cc.CallFunc:create(function(sender)
			mjTile.mjTileSpr:setVisible(true)
		end)
		local sequence = cc.Sequence:create(delayTime,callFunc)
		mjTile.mjTileSpr:runAction(sequence)
		k = k + 1
	end
end

function PokerScene:sortAninationPlayerMjTiles(playerSeatIdx)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- 计算牌开始的位置
	local poker_list = roomPlayer.uselessTiles
	if playerSeatIdx ~= self.playerSeatIdx then
		poker_list = roomPlayer.holdMjTiles
	end

	local cardNum = #poker_list -- 当前手牌数量
	
	local mjTilePos = self:getHoldStartPoint(playerSeatIdx,cardNum)

	for k, mjTile in ipairs(poker_list) do
		mjTile.mjTileSpr:setPosition(2000,mjTilePos.y)
		local delayTime = cc.DelayTime:create(0.08*k)
		local moveTo = cc.MoveTo:create(0.1, cc.p(mjTilePos.x,mjTilePos.y))
		local sequence = cc.Sequence:create(delayTime,moveTo)
		mjTile.mjTileSpr:runAction(sequence)
		mjTile.mjTileSpr:setVisible(true)
		self.cards_layer:reorderChild(mjTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	end
end

function PokerScene:sortPlayerMjTiles(playerSeatIdx)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- 计算牌开始的位置
	local cardNum = #roomPlayer.holdMjTiles -- 当前手牌数量
	-- 计算所有牌总宽度
	local mjTilePos = self:getHoldStartPoint(playerSeatIdx,cardNum)

	dump(mjTilePos,"mjTilePos===")
	for k, mjTile in ipairs(roomPlayer.holdMjTiles) do
		mjTile.mjTileSpr:stopAllActions()
		mjTile.mjTileSpr:setVisible(true)
		mjTile.mjTileSpr:setPosition(mjTilePos.x,mjTilePos.y)
		self.cards_layer:reorderChild(mjTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	end
end

--------------------------------
-- @class function
-- @description 获取手牌的启示位置
-- @param playerSeatIdx 座位号
-- @param cardNum 牌的数量
-- end --

function PokerScene:getHoldStartPoint(playerSeatIdx,cardNum)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	local mjTilesReferPos = roomPlayer.mjTilesReferPos

	local totalWidth = self:getPokerTotalWidth(playerSeatIdx)
	local space = (totalWidth - tileWidth) / (cardNum - 1)
	if space > tileWidth / 2 then
		mjTilesReferPos.holdSpace.x = tileWidth / 2 - 3
		totalWidth = tileWidth + (cardNum - 1) * mjTilesReferPos.holdSpace.x
	else 
		mjTilesReferPos.holdSpace.x = space

	end
	
	local mjTilePos = mjTilesReferPos.holdStart
	local startX = (gt6.winSize.width - totalWidth) / 2 + tileWidth / 2
	mjTilePos.x = startX

	return mjTilePos
end

--操作牌相关----end-------------------

--其他人如果要显示手牌宽度不一样 很多地方都在写 所以封装一个函数
function PokerScene:getPokerTotalWidth(playerSeatIdx)
	-- body
	local totalWidth = 1240
	if playerSeatIdx ~= self.playerSeatIdx then
		totalWidth = 840
	end
	return totalWidth
end

function PokerScene:getPokerWidth(playerSeatIdx)
	-- body
	if playerSeatIdx ~= self.playerSeatIdx then
		return other_tileWidth
	end
	return tileWidth
end

function PokerScene:refreshHoldPokers()
	local laiziValue = self.mLaiziValue
	local diZhuPos = self.mZhuangPos

	--播放插牌动画
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- 癞子牌
	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("gt6_splz_".. laiziValue ..".png")
	for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
		if pkTile.mjIsLaizi then
			pkTile.mjTileSpr:setSpriteFrame(spriteFrame)
		end
	end
	-- 对玩家手牌重新进行排序，癞子牌放到最前面
	table.sort(roomPlayer.holdMjTiles,function(a, b)
		if a.mjIsLaizi and b.mjIsLaizi == false then
			return true
		elseif a.mjIsLaizi == false and b.mjIsLaizi == false then
			return a.mjIndex > b.mjIndex
		end
		return false
	end)
	
	-- 计算牌开始的位置
	local cardNum = #roomPlayer.holdMjTiles -- 当前手牌数量
	local mjTilePos = self:getHoldStartPoint(roomPlayer.seatIdx,cardNum)

	-- 重新设置所有牌位置
	for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
		pkTile.mjTileSpr:stopAllActions()
		-- 如果自己是地主，添加地主角标
		if diZhuPos == self.playerSeatIdx then
			local cardIcon = nil
			if self.dealer_info_config and self.dealer_info_config.cardIcon then
				cardIcon = self.dealer_info_config.cardIcon
			end
			
			if cardIcon then
				local landLordIcon = cc.Sprite:createWithSpriteFrameName(cardIcon)
				if landLordIcon then
					landLordIcon:setPosition(cc.p(landLordIcon:getContentSize().width/2, landLordIcon:getContentSize().height/2))
					pkTile.mjTileSpr:addChild(landLordIcon)
				end
			end
		end
		
		pkTile.mjTileSpr:setPosition(mjTilePos.x, mjTilePos.y)
		
		self.cards_layer:reorderChild(pkTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	end
end

---出牌相关 start
function PokerScene:addOppositeMjTileToPlayer(playerSeatIdx)
	local poker_list = {}
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	if playerSeatIdx ~= self.playerSeatIdx then
		poker_list = roomPlayer.holdMjTiles  
	else
		poker_list = roomPlayer.uselessTiles
	end 
	local pkTile = self.cards_layer:addCardBackToPlayer(poker_list)

	if playerSeatIdx ~=self.playerSeatIdx then
		--不是自己的 这里的数组就是自己手牌了 现阶段来说 是改动最少的策略
		pkTile.mjTileSpr:setScale(0.63)
	end 

	return pkTile
end

--------------------------------
-- @class function
-- @description 给玩家发牌
-- @param mjColor
-- @param mjNumber
-- end --
function PokerScene:addMjTileToPlayer(msg)

	local card_info = {}
	--判断明牌
	if self.open_poker_seat ~=-1 and self.open_poker_seat == self.playerSeatIdx then
		if msg == self.open_poker_value then
			card_info.special_icon_name = "gt6_ddz_icon_ming.png"
			print("special_icon_name=="..tostring(special_icon_name))
		end
	end

	local pkTile = self.cards_layer:addCardToPlayer(msg,"gt6_sp%d_%d.png",card_info)

	--判断地主
	if self.mZhuangPos == self.playerSeatIdx then
		self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD)
	end

	if self.mIsInTrusteeship == true then
		pkTile.mjTileSpr:setColor(cc.c3b(200,200,200))
	end

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	table.insert(roomPlayer.holdMjTiles, pkTile)
	return pkTile
end

--------------------------------
-- @class function
-- @description 显示已出牌
-- @param seatIdx 座位号
-- @param msg 协议给的牌型值(客户端会解析成花色和值)
-- @param isself 计算位置用的
-- end --

function PokerScene:addAlreadyOutMjTiles(seatIdx, msg, isself,laizi)
	local value , color = GamePlayUtils.changePk(msg)
	local isLaizi = false
	
	--计算癞子
	local laiziCard = laizi
	self.laiTag = 1
	if self.mLaiziValue == value then
		if laiziCard and self.laiTag <= #laiziCard then
			local laiziValue = 0
			local v = laiziCard[self.laiTag]
			if v <= 11 then
				laiziValue = v + 2
			else
				laiziValue = v - 11
			end
			value = laiziValue
			isLaizi = true
		end
		self.laiTag = self.laiTag+ 1
	end
	
	dump(laiziCard,"laiziCard====")

	local pkTileName = string.format("gt6_cp%d_%d.png",color, value)
	if isLaizi then
		pkTileName = string.format("gt6_cplz_%d.png", value)
	end

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local card_info = {}
	card_info.color = color
	card_info.value = value
	card_info.isself = isself
	card_info.pkTileName  = pkTileName
	card_info.pkTilesReferPos = roomPlayer.mjTilesReferPos
	card_info.mul = #roomPlayer.outMjTiles

	local pkTile = self.cards_layer:addAlreadyOutCard(card_info)

	table.insert(roomPlayer.outMjTiles, pkTile)

	-- 如果自己是地主，添加地主角标
	if self.mZhuangPos == seatIdx then
		self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.OUT_CARD)
	end
	
end

function PokerScene:addAlreadyOutMjTilesFinally(seatIdx, msg, num)
	--只显示别人的
	if seatIdx == self.playerSeatIdx then 
		return
	end

	local value , color = GamePlayUtils.changePk(msg)
	local isLaizi = false
	if self.mLaiziValue == value then
		isLaizi = true
	end
	-- local pkTileName = string.format("sp%d_%d.png",color, value)
	local pkTileName = string.format("gt6_sp%d_%d.png",color, value)
	if isLaizi then
		pkTileName = string.format("gt6_splz_%d.png", value)
	end

	-- 添加到已出牌列表zy
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local card_info = {}
	card_info.color = color
	card_info.value = value
	card_info.pkTileName  = pkTileName
	card_info.pkTilesReferPos = roomPlayer.mjTilesReferPos
	card_info.outPkCount = #roomPlayer.outMjTiles + 1
	card_info.num = num 
	if roomPlayer.displaySeatIdx > 1 then
		card_info.move_x = 10
	else
		card_info.move_x = -10
	end

	card_info.start_x = 0
	card_info.start_offestx = 0

	--根据出牌数量决定其实位置偏移
	if seatIdx ~= self.playerSeatIdx then 
		--二人位置有变化 之后应该把相关算法进行封装
		if self.playMaxNum ~= 2  then
			if num > 8 and num <= 16 then
				card_info.start_offestx = 100
			elseif num > 16 then
				card_info.start_offestx = 200
			end				
		end
	end

	if self.playMaxNum == 2 then
		card_info.is_change_line = true 
		card_info.start_x = self:getPokerTotalWidth(seatIdx)
	end

	local pkTile = self.cards_layer:addOutCardFinally(card_info)
	table.insert(roomPlayer.outMjTiles, pkTile)

	-- 如果自己是地主，添加地主角标
	if self.mZhuangPos == seatIdx then
		self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD)
	end
end

--------------------------------
-- @class function

-- @param msgTbl 是否断线重连
-- @param roomPlayer 地主位置
-- end --
function PokerScene:createOpponentPokers(is_reccent,msgTbl,roomPlayer)
	if not self.show_opponent_poker_back_flag then
		return				
	end

	self.open_poker_index = 0
	local num = roomPlayer.leftCardsNum
	if self.open_poker_seat ~=-1 and self.open_poker_seat ~= self.playerSeatIdx then
		math.randomseed(os.time())
		self.open_poker_index = math.random(1,num)
	end

	local value, color = GamePlayUtils.changePk(self.open_poker_value)
	
	for i = 1, num do
		local pkTileName = "gt6_sp.png"
		if self.open_poker_index == i then
			pkTileName = string.format("gt6_sp%d_%d.png",color, value)
		end
		
		local pkTileSpr = cc.Sprite:createWithSpriteFrameName(pkTileName)
		pkTileSpr:setScale(0.63)
		pkTileSpr:setName(string.format("OpponentHandPoker_%d",i))
		self.cards_layer:addChild(pkTileSpr)
		
		local pkTile = {}
		pkTile.mjTileSpr = pkTileSpr
		pkTile.mjColor = 4
		pkTile.mjNumber = 0
		pkTile.mjIndex = 0
		pkTile.mjIsUp = false
		table.insert(roomPlayer.holdMjTiles, pkTile)
	end

	--不是断线重连有动画
	if not is_reccent then
		self:sortAninationPlayerMjTiles(roomPlayer.seatIdx)
	else
		--self:sortPlayerMjTiles(roomPlayer.seatIdx) 
		self:sortPlayerMjTiles(roomPlayer.seatIdx)
	end 
end

--出牌占位点 start----------------------------------
function PokerScene:animationPlayerMjTilesReferPos(displaySeatIdx)
	local mjTilesReferPos = {}
	local mjTilesReferNode = gt6.seekNodeByName(self.rootNode, "Node_playerMjTiles_" .. displaySeatIdx)
	-- 打出牌数据
	local mjTileOutSprF = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_1")
	local mjTileOutSprS = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_2")
	mjTilesReferPos.outStart = cc.p(mjTileOutSprF:getParent():convertToWorldSpace(cc.p(mjTileOutSprS:getPosition())))
	mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprS:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	return mjTilesReferPos
end

--------------------------------
-- @class function
-- @description 设置玩家麻将基础参考位置
-- @param displaySeatIdx 显示座位编号
-- @return 玩家麻将基础参考位置
-- end --
function PokerScene:setPlayerMjTilesReferPos(displaySeatIdx)
	local mjTilesReferPos = {}
	print("displaySeatIdx==="..tostring(displaySeatIdx))
	local mjTilesReferNode = gt6.seekNodeByName(self.rootNode, "Node_playerMjTiles_" .. displaySeatIdx)
	if displaySeatIdx == self.playMaxNum then
		local holdReferNode = gt6.seekNodeByName(self.rootNode,"Node_playerHold")
		-- 持有牌数据
		local mjTileHoldSprF = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_1")
		local mjTileHoldSprS = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_2")
		mjTilesReferPos.holdStart = cc.p(mjTileHoldSprF:getParent():convertToWorldSpace(cc.p(mjTileHoldSprF:getPosition())))
		mjTilesReferPos.holdSpace = cc.pSub(cc.p(mjTileHoldSprS:getPosition()), cc.p(mjTileHoldSprF:getPosition()))
	else
		local holdReferNode = gt6.seekNodeByName(self.rootNode,"Node_playerHold_other")
		--有则为二人玩法 这里不做过多类型判断 尽量隐藏
		if holdReferNode then
			local mjTileHoldSprF = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_1")
			local mjTileHoldSprS = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_2")
			mjTilesReferPos.holdStart = cc.p(mjTileHoldSprF:getParent():convertToWorldSpace(cc.p(mjTileHoldSprF:getPosition())))
			mjTilesReferPos.holdSpace = cc.pSub(cc.p(mjTileHoldSprS:getPosition()), cc.p(mjTileHoldSprF:getPosition()))
		end
	end

	-- 打出牌数据
	local mjTileOutSprF = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_1")
	local mjTileOutSprS = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_2")
	local mjTileOutSprT = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_3")
	mjTilesReferPos.outStart = cc.p(mjTileOutSprF:getParent():convertToWorldSpace(cc.p(mjTileOutSprF:getPosition())))
	mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprS:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	mjTilesReferPos.outSpaceV = cc.pSub(cc.p(mjTileOutSprT:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	return mjTilesReferPos
end
--出牌占位点 end----------------------------------

--处理癞子
function PokerScene:processFake( msgTbl )
	self.mLaiziValue = msgTbl.m_playerOper
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) --self.roomPlayers[self.playerSeatIdx]

	for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
		if pkTile.mjNumber == self.mLaiziValue then
			pkTile.mjIsLaizi = true
		end
	end
	-- 播放癞子展现动画
	-- gt6.LaiZiUtils.playLaiziAppearAnim(self.mLaiziValue,true, self.mLaiziValue, self.rootNode, self.LaiHandsNode)

	if not tolua.isnull(self.mFakeLayer) then
		self.mFakeLayer:playLaiziAppearAnim(self.mLaiziValue,true, self.mLaiziValue)
	end

	print("self.mZhuangPos=="..tostring(self.mZhuangPos).."==self.playerSeatIdx=="..tostring(self.playerSeatIdx))
	if self.mZhuangPos == self.playerSeatIdx then
		--延迟显示插牌动画
		local action = cc.Sequence:create(cc.DelayTime:create(laizi_ani_time),cc.CallFunc:create(function ()
			self:refreshHoldPokers()
		end))
		self:runAction(action)
	else
		self:refreshHoldPokers()
		
	end
end


------------------关于剩余牌的操作-----------------start----------
function PokerScene:initLeftCardNum(msgTbl,roomPlayer)
	if msgTbl.m_cardNum then
		roomPlayer.leftCardsNum = msgTbl.m_cardNum[roomPlayer.seatIdx]
	else
		if self.room_config then
			roomPlayer.leftCardsNum = self.room_config.max_hand_num or 17
		else
			roomPlayer.leftCardsNum = 17
		end
	end
end

--手牌加上数量底牌
function PokerScene:addLastPokerNum(seatIdx)
	local last_hand = 0
	if self.room_config.last_hand then
		last_hand = self.room_config.last_hand
	end
	gt6.PlayersManager:addLastPokerNumBySeat(seatIdx, last_hand)
end

--添加几张底牌动作
function PokerScene:addLastPokerAni(msgTbl)
	
	-- GamePlayUtils.stopActionByTag(self,action_tag.send_poker_tag)
	-- self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)

	--播放插牌动画
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	roomPlayer:removeUselessTiles()

	local mjTilesReferPos = roomPlayer.mjTilesReferPos

	-- 对玩家手牌重新进行排序
	if self.room_config and self.room_config.sortType == "3max" then
		GamePlayUtils.sortHoldPoker3Max(roomPlayer.holdMjTiles)
	else
		GamePlayUtils.sortHoldPoker(roomPlayer.holdMjTiles)
	end
	
	local mjTilePos = self:getHoldStartPoint(self.playerSeatIdx,#roomPlayer.holdMjTiles)

	-- 重新设置所有牌位置
	for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
		pkTile.mjTileSpr:stopAllActions()
		pkTile.mjTileSpr:setVisible(true)
		-- 如果自己是地主，添加地主角标
		--self:checkLandlordFlag(pkTile,self.playerSeatIdx)
		if self.playerSeatIdx == self.mZhuangPos then
			self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD)
		end 
		pkTile.mjTileSpr:setPosition(mjTilePos.x, mjTilePos.y)
		
		for i,v in ipairs(msgTbl.m_LeftCard) do
			if pkTile.mjIndex == v then
				pkTile.mjTileSpr:setPositionY(mjTilePos.y + 80)
				pkTile.mjIsUp = true
				pkTile.mjTileSpr:runAction(cc.MoveBy:create(0.3, cc.p(0, -80)))
			end
		end
		self.cards_layer:reorderChild(pkTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	end
	local delayTime = cc.DelayTime:create(1)
	local callFunc = cc.CallFunc:create(function(sender)
		--众神归位
		for j=1, #roomPlayer.holdMjTiles do
			self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
		end
		self.SelectCard = {}
	end)
	local sequence = cc.Sequence:create(delayTime,callFunc)
	self:runAction(sequence)

	self:showOpponentCheckPokers(true)--子类众实现
end
------------------关于剩余牌的操作-----------------end----------

--更新选择的牌
function PokerScene:updateSelectCard( result, mjTileIdx )
	local isTocuhPoker = false
	local index = 1
	for i=1, #self.SelectCard do
		if mjTileIdx == self.SelectCard[i] then
			isTocuhPoker = true
			break;
		end
		index = index + 1
	end

	if result then
		if not isTocuhPoker then
			table.insert(self.SelectCard, mjTileIdx)
		end
	else
		if isTocuhPoker then
			table.remove(self.SelectCard, index)
		end
	end
end

---------出牌倒计时相关 start ----------------------

--开启更新定时器
function PokerScene:openUpdateSchedule()
	if not self.update_schedule  then
		self.update_schedule = gt6.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	end
end

--关闭更新定时器
function PokerScene:closeUpdateSchedule()
	if self.update_schedule then
		gt6.scheduler:unscheduleScriptEntry(self.update_schedule)
		self.update_schedule = nil
	end
end

function PokerScene:update(delta)
	-- 更新倒计时
	self:playTimeCDUpdate(delta)
	self.common_ui_layer:update(delta)
end

---------出牌倒计时相关 end ----------------------
--计算delaer位置
function PokerScene:setDelarPos(msgTbl)
		------------------------------
	-- ####### 由于修改协议后的恢复
	if not msgTbl.m_zhuangPos then
		msgTbl.m_zhuangPos = msgTbl.m_hpos
	end

	--跑得快
	if self.mGameStyle == gt6.CommonConst.GameType.FAKEPDK or
		self.mGameStyle == gt6.CommonConst.GameType.CLASSICSPDK then
		msgTbl.m_zhuangPos = msgTbl.m_zhuang
	end
	------------------------------

	-- 庄家座位号
	local bankerSeatIdx = msgTbl.m_zhuangPos + 1
	self.mZhuangPos = bankerSeatIdx
end

function PokerScene:stopCDAudio()
	-- 停止播放倒计时警告音效
	if self.playCDAudioID then
		gt6.soundEngine:stopEffect(self.playCDAudioID)
		self.playCDAudioID = nil
	end
end

--自定义消息回掉---start
function PokerScene:sendReadyFunc()
	local msgToSend = {}
	msgToSend.m_msgId = gt6.CG_READY
	-- msgToSend.m_pos = self.playerSeatIdx - 1
	msgToSend.m_nReadyState = 1
	gt6.socketClient:sendMessage(msgToSend)
end
--自定义消息回掉---end

function PokerScene:disableCard(msgTbl,roomPlayer)
	if not msgTbl.m_cardUnusable then
		return
	end

	if self.have_laizi_flag then
		return
	end

	for i=1,#msgTbl.m_cardUnusable do
		for j=1,#roomPlayer.holdMjTiles do
			if msgTbl.m_cardUnusable[i] == roomPlayer.holdMjTiles[j].mjIndex then
				roomPlayer.holdMjTiles[j].mjTileSpr:setColor(cc.c3b(200,200,200))
				roomPlayer.holdMjTiles[j].mjIsTouch = false
			end
		end
	end
end

function PokerScene:tipPoker(roomPlayer)
	--该玩家出牌时自动提示玩家出牌
	local seatIdx = roomPlayer.seatIdx
	if seatIdx == self.playerSeatIdx then
		self.SelectCard = {}
		local showCard = self.curShowMjTileInfo.m_array[self.promptIndex]
		if showCard then
			for i,v in ipairs(showCard) do
				for j=1, #roomPlayer.holdMjTiles do
					if roomPlayer.holdMjTiles[j].mjIndex == v then
						self.SelectCard[#self.SelectCard+1] = j
					end
				end
			end

			--众神归位
			for j=1, #roomPlayer.holdMjTiles do
				self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
			end
			--提起
			for j=1, #self.SelectCard do
				self:setPokerIsUp(roomPlayer.holdMjTiles[self.SelectCard[j]], true, true)
			end

			self.promptIndex = self.promptIndex-1
			if self.promptIndex == 0 then
				self.promptIndex = self.maxPromptIndex
			end
		else
			--众神归位
			for j=1, #roomPlayer.holdMjTiles do
				self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
			end
		end
	end
end

function PokerScene:autoSendPoker(msgTbl,roomPlayer)
	local delayTime = cc.DelayTime:create(0.3)
 	local msgToSend = {}
	msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
	msgToSend.m_flag = 0
	msgToSend.m_card = {}
	msgToSend.m_card = self.curShowMjTileInfo.m_array[1]
 	local callFunc = cc.CallFunc:create(function(sender)
		gt6.socketClient:sendMessage(msgToSend)
		end)
	local sequence = cc.Sequence:create(delayTime, callFunc)
	self:runAction(sequence)
end

--有的棋牌玩法 要不起自动过
function PokerScene:autoBuyao(seatIdx,msgTbl)
	--self.pass:stopAllActions()
	-- self.pass:setVisible(false)
	-- self.decisionBtnNode:setVisible(true)
	-- self.prompt:setVisible(false)
	-- self.play:setVisible(false)
	-- self.restore:setVisible(false)

	
	local callFunc1 = cc.CallFunc:create(function(sender)
		--飘个字
		gt6.floatText("您没有牌能大过上家")
		self:playTimeCDStart(false,seatIdx,msgTbl.m_time)
 	end)
 	local delayTime = cc.DelayTime:create(1)
 	local callFunc2 = cc.CallFunc:create(function(sender)

 		print("autoBuyao")
 		self.decisionBtnNode:setVisible(false)
 		local msgToSend = {}
		msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
		msgToSend.m_flag = 1
		--msgToSend.m_card = {}
		gt6.socketClient:sendMessage(msgToSend)
 	end)
	local sequence = cc.Sequence:create(callFunc1, delayTime, callFunc2)
	self.pass:runAction(sequence)
end

--轮到自己要进行的一些决策按钮展示
function PokerScene:turnMeDecision(seatIdx,msgTbl)
	if not msgTbl then
		return
	end 

	if seatIdx == self.playerSeatIdx then
		--self.decisionBtnNode:setVisible(true)

		--没提示的牌--但有牌出
		if #msgTbl.m_array == 0 and msgTbl.m_flag == 0 then
			self.play:setVisible(true)
			self.play:setPosition(self.btnPromptPosition)
			self.prompt:setVisible(false)
			self.pass:setVisible(false)
			self.pass:setPosition(self.btnPassPosition)

		--没可出的牌		
		elseif #msgTbl.m_array == 0 and msgTbl.m_flag == 1 then
			self.pass:setVisible(self.show_buyao_btn_flag)
			self.pass:setPosition(self.btnPromptPosition)

			self.play:setVisible(false)
			self.prompt:setVisible(false)
			self.restore:setVisible(false)
		else
			self.prompt:setVisible(true)
			self.prompt:setPosition(self.btnPromptPosition)
			self.play:setVisible(true)
			self.play:setPosition(self.btnPlayPosition)

			--针对不出按钮开关的一些规则
			if not self.show_buyao_btn_flag then
				print("turnMeDecision")
				self.pass:setVisible(false)
				self.prompt:setPosition(self.btnResetPosition2)
				self.play:setPosition(self.btnPlayPosition2)
			else
				self.pass:setVisible(true)
				self.pass:setPosition(self.btnPassPosition)
			end 
		end

		--必出一定要隐藏不要
		if self.optionType == 1 then
			self.pass:setVisible(false)
		end

		if not self.show_buyao_btn_flag then
			self.pass:setVisible(false)
		end

	end
end

-- 初始化poker类用户信息
function PokerScene:initPokerPlay(msgTbl)
	local roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
	for seatIndex, roomPlayer in ipairs(roomPlayers or {}) do
		self:initLeftCardNum(msgTbl,roomPlayer)
		if roomPlayer.displaySeatIdx ~= self.playMaxNum then
			roomPlayer:showLeftCardNum(self.room_config.showHandPokerNum)
		end

		roomPlayer.holdMjTiles = {}
		roomPlayer.uselessTiles = {}
		-- 玩家已出牌
		roomPlayer.outMjTiles = {}
		roomPlayer.bombTimes = 0
		-- 麻将放置参考点
		roomPlayer.mjTilesReferPos = self:setPlayerMjTilesReferPos(roomPlayer.displaySeatIdx)
	end
end

function PokerScene:resetRoomUi()
	if self.cards_layer then 
		self.cards_layer:removeAllChildren()
	end

	-- 隐藏手牌
	if self.bottomCard then
		self.bottomCard:setVisible(false)
	end

	self:startGame()

	gt6.PlayersManager:removeAlarm()
end

function PokerScene:syncRoom(msgTbl)
	self:resetRoomUi()

	--计算delaer位置
	self:setDelarPos(msgTbl)

    --初始化牌局用户
	self:initPokerPlay(msgTbl)

	self:initMultipleByMsg(msgTbl)

	self:syncGameRoom(msgTbl)

	local roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
	for seatIdx, roomPlayer in ipairs(roomPlayers) do

		self:showIdentity(roomPlayer)
		--同步手牌
		self:syncHoldPoker(msgTbl,roomPlayer)
		--同步出牌
		self:syncOutPoker(msgTbl,seatIdx)
		--托管
		if msgTbl.m_IsTuoguan then
			--print("self.playerSeatIdx===="..tostring(self.playerSeatIdx))
			if self.playerSeatIdx == roomPlayer.seatIdx then
				self.mIsInTrusteeship = msgTbl.m_IsTuoguan[self.playerSeatIdx]
				--print("self.mIsInTrusteeship===="..tostring(self.mIsInTrusteeship))
				if self.mIsInTrusteeship then
					for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
						pkTile.mjTileSpr:setColor(cc.c3b(200,200,200))
					end
				end			
			end

			local isIntrusteeship = msgTbl.m_IsTuoguan[roomPlayer.seatIdx]
			if isIntrusteeship then
				-- 显示托管机器人
				roomPlayer:showTrusteeship()
			end	
		end

		if msgTbl.m_CurBomb then
			local bomb_count = msgTbl.m_CurBomb[seatIdx]
			self:countNormlMultiple(bomb_count)
		end 
	end

	if self.mIsInTrusteeship then
		-- 添加取消托管按钮
		self:createTrusteeshipBtn()
	    -- 隐藏操作按钮
	    self.decisionBtnNode:setVisible(false)
	end
	
	-- 断线重连，公共元素的操作
	--刷新底牌
	self:refreshLashHand(msgTbl)

	--刷新倍数
	self:updateMultipleUi(self.curMultiple)

end

---发牌阶段
function PokerScene:playSendPoker(msgTbl)
	local roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
	for seatIdx, roomPlayer in ipairs(roomPlayers) do

		self:showIdentity(roomPlayer)

		if roomPlayer.seatIdx == self.playerSeatIdx then
			self:playSelfSendPoker(msgTbl,roomPlayer)
		end	
	end
end

--播放自己发牌
function PokerScene:playSelfSendPoker(msgTbl,roomPlayer)
	local seatIdx = roomPlayer.seatIdx
	roomPlayer:removeUselessTiles()
	roomPlayer:removeHoldTiles()

	GamePlayUtils.stopActionByTag(self,action_tag.send_poker_tag)

	if self.fapai_bu_fanpai_flag then
		for i=1,17 do
			self:addOppositeMjTileToPlayer(seatIdx)
		end
		self:sortAninationPlayerMjTiles(seatIdx)
		self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)
		return
	else
		--应该先创建好才对
		if msgTbl.m_card then
			for _, v in ipairs(msgTbl.m_card) do
				self:addOppositeMjTileToPlayer(roomPlayer.seatIdx) --创建牌背
				self:addMjTileToPlayer(v) --添加牌面
			end
		end	
	end

	local callFunc1 = cc.CallFunc:create(function(sender)
		self:sortAninationPlayerMjTiles(roomPlayer.seatIdx) --播放牌背移动动画
 	end)

 	local delayTime1 = cc.DelayTime:create(0.08*16)
 	local delayTime2 = cc.DelayTime:create(0.12*16)

	local callFunc2 = cc.CallFunc:create(function(sender)
		--roomPlayer:removeHoldTiles()		
		self:sortFinalPlayerMjTiles() --排面显示动画
 	end)

 	local callFunc3 = cc.CallFunc:create(function(sender)
		--隐藏扣费提示
		if not tolua.isnull(self.common_ui_layer) then
			self.common_ui_layer:hideNonsume()
		end

		roomPlayer:removeUselessTiles()

		--轮到我出牌
		self:checkPlayBtnShow(seatIdx,msgTbl.m_time)

		--如果是我出牌前，上家已经出牌 检测是否需要禁牌
		self:checkDisableCard(seatIdx,roomPlayer)

		--检测是否需要显示抢地主等决策
		self:checkDecision(seatIdx,msgTbl)

		self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)
 	end)

 	
 	local callFunc4 = cc.CallFunc:create(function( sender )
 		msgTbl.m_playerOper = msgTbl.m_nLaiziType
 		self:processFake(msgTbl)
 	end)

	local sequence = nil
 	if msgTbl.m_nLaiziType and msgTbl.m_nLaiziType > 0 then --癞子跑得快
 		sequence = cc.Sequence:create(callFunc1,delayTime1,callFunc2,delayTime2,callFunc4, cc.DelayTime:create(laizi_ani_time), callFunc3)
 	else 
 		sequence = cc.Sequence:create(callFunc1,delayTime1,callFunc2,delayTime2,callFunc3)
 	end
 	
 	sequence:setTag(action_tag.send_poker_tag)
 	self:runAction(sequence)
end

function PokerScene:refreshLashHand(msgTbl)
	if msgTbl.m_dipai and #msgTbl.m_dipai ~= 0 and self.m_zhuangPos ~= -1 then
		if not tolua.isnull(self.bottomCard ) then
			self.bottomCard:setVisible(true)
			self.bottomCard:showLastHandPoker(msgTbl.m_dipai,true)
		end		
	elseif msgTbl.m_dipai and #msgTbl.m_dipai == 0 and self.m_zhuangPos ~= -1 then
		if not tolua.isnull(self.bottomCard ) then
			self.bottomCard:setVisible(true)
			self.bottomCard:showLastHandPokerBg()
		end	
	end
end

function PokerScene:checkShowDecisionBtn()
	if self.mIsInTrusteeship then
		self.decisionBtnNode:setVisible(false)
	else
		self.decisionBtnNode:setVisible(true)
	end
end

function PokerScene:hidePlayDecisionBtn()
	self.prompt:setVisible(false)
	self.play:setVisible(false)
	self.pass:setVisible(false)
	self.restore:setVisible(false)
end

-- 处理叫分时的 1 2 3 分情况，
function PokerScene:processScorePlayType(msgTbl)
	local curScore = msgTbl.m_difen
	if self.desBtn then
		self.desBtn:setVisible(true)

		-- 根据分数屏蔽按钮
		local scoreOne = gt6.seekNodeByName(self.desBtn, "yifen")
		local scoreTwo = gt6.seekNodeByName(self.desBtn, "liangfen")

		if scoreOne and scoreTwo then
			if curScore == 1 then
				scoreOne:setEnabled(false)
				scoreTwo:setEnabled(true)
			elseif curScore == 2 then
				scoreOne:setEnabled(false)
				scoreTwo:setEnabled(false)
			else
				scoreOne:setEnabled(true)
				scoreTwo:setEnabled(true)
			end	
		end			
	end
end

--//播完发牌以后需要检测的---------start
--最开始两端就没有约定好这种事情 每个阶段的状态和阶段的时间间隔
--没有考虑动画播放时间 
--发牌结束以后的处理
function PokerScene:checkPlayBtnShow(seatIdx)
	print("self.checkPlayBtnShow=="..tostring(self.is_turn_me))
	if self.is_turn_me then
		self.decisionBtnNode:setVisible(true)
		self:turnMeDecision(seatIdx,self.curShowMjTileInfo)

	end
end

function PokerScene:checkDisableCard(seatIdx,roomPlayer)
	if self.turnShowMsgTbl then
		if self.turnShowMsgTbl.m_flag == 0 then --没有上家 显示出来倒计时
			local cutdown_time = self.room_config.firstCountDown or 12
			self:playTimeCDStart(true,seatIdx,cutdown_time)
		else --有上家 别人出牌，检测 不能出的禁牌
			self:disableCard(self.turnShowMsgTbl, roomPlayer)
			self:playTimeCDStart(true,self._prePointSeatindex ,self.playTimeCD)
		end
		self.turnShowMsgTbl = nil
	end
end

function PokerScene:checkDecision(seatIdx,msgTbl)
	--轮到我决策
	if msgTbl.mZhuangPos == nil and self.doingAskIndex ~= nil  then
		local seatIdx = self.doingAskIndex + 1
		if seatIdx == self.playerSeatIdx then
			self.doingAskIndex = nil 
			--隐藏决策node下的按钮
			self:hidePlayDecisionBtn()
			self:playTimeCDStart(true,seatIdx,12)
			self:updateDecisionBtns()
		end
		self:showBottomCardBg()
	end
	
end

---------------翻倍 Begin-----------------
--常规计算倍数 --倍数计算规则为低分*倍数的公式
function PokerScene:countNormlMultiple(num)
	if not self.mMaxFanShu then
		return
	end
	num = num or 1

	self.curBooms = self.curBooms + num
	if self.mRoomPattern ~= gt6.CommonConst.RoomPattern.COIN then
		if self.curBooms <= self.mMaxFanShu then
			self.curMultiple = self.curMultiple * (2^num)
		end
	else
		self.curMultiple = self.curMultiple * (2^num)
	end

end

--滚翻 加底一类的 倍数计算规则
--此算法很久以前就存在 可能有问题
function PokerScene:countFanMultiple(num)
	if not self.mMaxFanShu then
		return
	end

	if self.curBooms < self.mMaxFanShu then --and self.fanBeiLeiXing == 2 then
		self.curMultiple = self.curMultiple * 2
	else
		self.curMultiple = self.curMultiple + 1

		if self.playerSeatIdx == self.mZhuangPos then
			self.curMultiple = self.curMultiple + 1
		end
	end
	
	self.curBooms = self.curBooms + 1
end


function PokerScene:initMultipleByMsg(msgTbl)
	self.curBooms = 0
	self.curMultiple = msgTbl.m_difen or 1
end

--更新翻倍数
function PokerScene:updateMultipleUi(multiple)
	if not self.Txt_Times then
		return
	end 

	self.Txt_Times:stopAllActions()
	self.Txt_Times:setScale(1)
	gt6.log(" PokerScene:updateFanBei " .. multiple)
	self.Txt_Times:setString("" .. multiple)
	self.Txt_Times:setVisible(true)
	local action = cc.Sequence:create(cc.ScaleTo:create(0.2,2),cc.ScaleTo:create(0.2,1.0))
	self.Txt_Times:runAction(action)
end
---------------翻倍 End-----------------


--显示身份 如 地主 坑主
function PokerScene:showIdentity(roomPlayer)
	if not roomPlayer then
		return
	end 
	gt6.log("创建地主头像")
	if self.mZhuangPos and self.mZhuangPos == roomPlayer.seatIdx then --是庄家
		if self.dealer_info_config and self.dealer_info_config.headIcon then
			self.dealer_info_config.dealer_type = self.room_config.dealer_type 
			roomPlayer:createIdentity(self.dealer_info_config)
		end
	end
end

--显示card的一些标志
function PokerScene:showCardFlag(mjTileSpr,card_icon_type)
	if not self.dealer_info_config then
		return
	end  

	local name =""
	if card_icon_type == gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD then
		name = "cardIcon"
	else
		name = "outCardIcon"
	end 

	local card_icon = self.dealer_info_config[name]
	if not card_icon then
		return
	end  

	local identity_icon = cc.Sprite:createWithSpriteFrameName(card_icon)
	-- landLordIcon:setAnchorPoint(cc.p(1,1))
	identity_icon:setPosition(cc.p(identity_icon:getContentSize().width/2, identity_icon:getContentSize().height/2))
	-- landLordIcon:setPosition(cc.p(155, 216))
	mjTileSpr:addChild(identity_icon)
end

function PokerScene:getSelectCard()
	local unSelectArr = {}
	local selectArr= {}
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) --self.roomPlayers[self.playerSeatIdx]
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local _mjTilePos = mjTilesReferPos.holdStart
	-- table.foreach(self.playMjLayer:getChildren(), function(i, v)
	table.foreach(roomPlayer.holdMjTiles, function(i, card)
		local v = card.mjTileSpr
		if v:getPositionY() == _mjTilePos.y then
			table.insert(unSelectArr, tonumber(v:getName()))
		elseif v:getPositionY() == _mjTilePos.y+gt6.CommonConst.ConstValue.SELECT_CARD_HIGHT then
			table.insert(selectArr, tonumber(v:getName()))
		end
	end)
	return selectArr,unSelectArr
end

--出牌的特殊错误
function PokerScene:checkPokerError(error_code)
	--牌型错误 提起的牌归位 清空选中的牌
	local is_error = false
	if error_code ~= 0 then
		is_error = true
		self:resetAllPokerPos()
		self.SelectCard = {}
	end
	
	local error_msg = gt6.CommonConst.error_list[error_code]
	if error_msg then
		gt6.floatText(error_msg)
	end

	return is_error
end

function PokerScene:resetAllPokerPos()
	--众神归位
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if roomPlayer then
		local count = #roomPlayer.holdMjTiles
		for j=1, count do
			self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
		end
	end
end

function PokerScene:updateCurShowPokerInfo(poker_type,card,number)
	self.curShowCardInfo.cardType = poker_type or 0
	self.curShowCardInfo.cardNum = number or 0
	self.curShowCardInfo.cardArr = card or {}
end

--同步手牌
function PokerScene:syncHoldPoker(msgTbl,roomPlayer)
	--开局一后直接添加牌
	if self.status == gt6.CommonConst.ROOM_STATUS.BOARD_START then
		if roomPlayer.seatIdx == self.playerSeatIdx then
			if msgTbl.m_card and #msgTbl.m_card > 0 then
				for _, v in ipairs(msgTbl.m_card) do
					self:addMjTileToPlayer(v)
				end

				-- 根据花色大小排序并重新放置位置
				if self.mLaiziValue and self.mLaiziValue > 0 then
					for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
						if pkTile.mjNumber == self.mLaiziValue then
							pkTile.mjIsLaizi = true
						end
					end
					self:refreshHoldPokers()
				else
					self:sortPlayerMjTiles(self.playerSeatIdx)
				end	

			end
		end

	end
end

--同步出牌
function PokerScene:syncOutPoker(msgTbl,seatIdx)
	-- 玩家已出牌
	if self.have_laizi_flag then
 		self:LaiFunction(msgTbl,seatIdx)
 	elseif self.have_pizi_flag then
 		self:PiziFunction(msgTbl,seatIdx)
 	else
		-- 服务器座次编号
		local turnPos = seatIdx - 1
		-- 已出牌
		local outMjTilesAry = msgTbl["m_out" .. turnPos]
		if outMjTilesAry then
			for _, v in ipairs(outMjTilesAry) do
				self:addAlreadyOutMjTiles(seatIdx,v)
			end
			self:refreshOutPokers(seatIdx)
		end
 	end	
end

function PokerScene:LaiFunction(msgTbl,seatIdx)
	local key_out = string.format("m_out%d",seatIdx-1)
	local key_laizichange = string.format("m_laiziChange%d",seatIdx-1)
	local card = msgTbl[key_out]
	local laiziChange = msgTbl[key_laizichange]

	local cur_card = {}
	
	-- 找出最后出的牌型,从自己开始往上一家遍历
	local outIdx = self.playerSeatIdx - 1
	local max_player_num = self.playMaxNum
	for i=1,max_player_num do
		outIdx = outIdx - 1
		outIdx = outIdx < 0 and max_player_num or outIdx			
		local card = msgTbl["m_out"..outIdx]
		if card and #card > 0 then
			cur_card = card
			break
		end
	end

	self:updateCurShowPokerInfo(msgTbl.m_pokerStyle,cur_card,msgTbl.m_typeNumber)

	if card then
		for i,v in ipairs(card) do
			local value , color = GamePlayUtils.changePk(v)
			gt6.log("SeatIdx:"..seatIdx .. "  Value:"..value .. "  selfPlayerSeat:" .. self.playerSeatIdx)
			self:addAlreadyOutMjTiles(seatIdx, v, #card, aiziChange)
		end
		self:refreshOutPokers(seatIdx)		
	end
end

function PokerScene:PiziFunction(msgTbl,seatIdx)
	local cardArrIdx = seatIdx - 1
	local card = msgTbl["m_out"..cardArrIdx]
	if card then
		card = gt6.LaiZiUtils.checkLaziPosAndIdx(card, msgTbl.m_pokerStyle, msgTbl.m_laiziNumber)
		for i,v in ipairs(card) do
			self:addAlreadyOutMjTiles(seatIdx, v,#card,msgTbl.m_laiziNumber)
		end
	end

	-- 找出最后出的牌型,从自己开始往上一家遍历
	local outIdx = self.playerSeatIdx - 1
	local max_player_num = self.playMaxNum
	for i=1,max_player_num do
		outIdx = outIdx - 1
		outIdx = outIdx < 0 and max_player_num or outIdx			
		local card = msgTbl["m_out"..outIdx]
		if card and #card > 0 then
			self:updateCurShowPokerInfo(msgTbl.m_pokerStyle,card,#card)
			break
		end
	end
end

-- 根据牌的类型，计算癞子牌显示位置和大小
function PokerScene:checkLaziPosAndIdx(arr,_type,laiziNumberArr)
	return arr
end

function PokerScene:getSoundPath(sex)
	if sex == 1 then
		return "man/"
	else
		return "woman/"
	end
end

function PokerScene:showBottomCardBg()
	if not tolua.isnull(self.bottomCard ) then
		self.bottomCard:setVisible(true)
		self.bottomCard:showCardBg()
	end		
end

function PokerScene:localShowPokerTip()
	--可提示牌型有多组 
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if self.have_laizi_flag then
		-- 出牌提示
		gt6.FakeCardMgr:getInstance():helpMe(self.curShowCardInfo, roomPlayer, self.curShowMjTileInfo.m_array)
	end

	if self.have_pizi_flag then
		table.sort(self.curShowCardInfo.cardArr, function(a,b)
			return a > b
		end)
		helpArr = self._gameRule:helpByShowType(self.curShowCardInfo,roomPlayer.holdMjTiles,self.laziCardArr[1])
		self.curShowMjTileInfo.m_array = helpArr or {}
	end
end

function PokerScene:playActionByIdName( id_name , msgTbl)
	if not id_name then gt6.log("playActionByIdName error -> id_name is nil") return end 
	local data = {}
	data.seatIdx = msgTbl.m_pos + 1
	data.flag = msgTbl.m_flag
	data.realSeat = gt6.PlayersManager:getDisplaySeat(data.seatIdx)
	data.laiZi = msgTbl.m_laiziNumber
	data.card = msgTbl.m_card
	data.msgTbl = msgTbl
	
	local cfgs = g_playRulesCfg_poker[id_name]
	if g_playRulesCfg_poker[id_name .. ("style" .. self.mGameStyle)] then
		cfgs = g_playRulesCfg_poker[id_name .. ("style" .. self.mGameStyle)]
	end

	gt6.log("id_name " .. id_name)
	dump(cfgs, "cfgs ")

	if cfgs and next(cfgs) and cfgs.actionId and next(cfgs.actionId) then 
		for i, id in ipairs(cfgs.actionId) do
			gt6.log("onRcvSyncShowMjTile id_"..id)
			local action = g_actionId_poker["id_"..id] 
			self:doAction(action.realId,data,action)
		end
	end
end

-------------倒计时------------Begin-----------------
--timeDuration,appear
function PokerScene:playTimeCDStart(isshow,seatindex,time)
	gt6.log("playTimeCDStart " .. tostring(isshow) .. " " .. tostring(seatindex) .. " " .. tostring(time))
	if time ~= self.playTimeCD then
		self.playTimeCD = time
		self.isVibrateAlarm = false
		if self.clock and not tolua.isnull(self.clock) then
			self.clock:setTimeCD( tostring(time) )
		end
	end
	self:setClockPosition(seatindex , isshow)
	self._prePointSeatindex = seatindex
end

function PokerScene:setClockPosition( seatindex , is_show)
	local realSeat = gt6.PlayersManager:getDisplaySeat(seatindex)
	local player = gt6.seekNodeByName(self.rootNode,"Node_playerMjTiles_" .. realSeat)
	local Node_Clock = gt6.seekNodeByName(player, "Node_Clock")
	local pos = Node_Clock:getParent():convertToWorldSpace(cc.p(Node_Clock:getPosition()))
	if not self.clock or tolua.isnull(self.clock) then --创建 
		self.clock = require("app/gameType/base/ClockNode"):create()
		self.rootNode:addChild(self.clock, gt6.CommonConst.ZOrder.SETTING_LAYER - 1)
		self.clock:setPosition(pos)
	end

	if self.clock and not tolua.isnull(self.clock) then
		self.clock:setPosition(pos)
		self.clock:setVisible(is_show)
	end
end

function PokerScene:playTimeCDUpdate(delta)
	if not self.playTimeCD then
		return
	end

	self.playTimeCD = self.playTimeCD - delta
	if self.playTimeCD < 0 then
		self.playTimeCD = 0
		self.playCDAudioID = nil
	end
	
	if self.playTimeCD <= 3 and not self.isVibrateAlarm and self.is_turn_me then
		-- 剩余3s开始播放警报声音+震动一下手机
		self.isVibrateAlarm = true
		-- 播放声音
		self.playCDAudioID = gt6.soundEngine:playEffect("common/timeup_alarm",false,"2POKER")
		-- 震动提醒
		cc.Device:vibrate(1)
	end
	local timeCD = math.ceil(self.playTimeCD)
	if not tolua.isnull(self.clock) then
		self.clock:setTimeCD(timeCD)
	end
end
-------------倒计时------------End  -----------------

function PokerScene:createCardLayer(parent)
	--创建牌层
	if not parent then
		parent = self
	end 
	local cardsLayer = CardLayer:create()
	parent:addChild(cardsLayer, gt6.CommonConst.ZOrder.MJTILES)
	self.cards_layer = cardsLayer
end

--需要子类自己实现的--------start--------

--钩子方法
function PokerScene:updateDecisionBtns()

end

function PokerScene:clearCheckPoker()
--清除让牌数 子类实现
end

function PokerScene:showWinTip( is_show )
	--子类实现用来控制还剩多少赢
end

--显示对手让牌效果
function PokerScene:showOpponentCheckPokers( is_show )

end

function PokerScene:doDealLaiZi(data,action)
end

function PokerScene:doAgainDeal(data,action)
end

--重播中用
function PokerScene:doGetBottomCard(data,action)
end

function PokerScene:syncGameRoom(msgTbl)

end

--更新剩余几张胜利
function PokerScene:updateWinPokerNum(roomPlayer)

end

--刷新对手牌
function PokerScene:refreshRivalPoker(seatIdx)--二人时要刷新对手的牌
end

--隐藏明牌
function PokerScene:hideOpponentOpenPoker()

end

--需要子类自己实现的--------end--------

function PokerScene:stopCountDownSound( ... )
	if self.playCDAudioID and self.playTimeCD > 0.02 then --音乐自动停止和手动打断在同一帧会有问题
		gt6.soundEngine:stopEffect(self.playCDAudioID)
		self.playCDAudioID = nil
	end	
end

function PokerScene:resetSelfPokerColor()
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if roomPlayer and roomPlayer.holdMjTiles then
		for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
			if self.mIsInTrusteeship ~= true then
				pkTile.mjTileSpr:setColor(cc.c3b(255,255,255))
				pkTile.mjIsTouch = true
			end
		end
	end
end

function PokerScene:onTuoGuan()
	if self.is_turn_me then
	    -- 显示
		self:handleTrusteeship(false,self.playerSeatIdx)
	end
	
	--退出托管颜色恢复
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) --self.roomPlayers[self.playerSeatIdx]
	for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
		pkTile.mjTileSpr:setColor(cc.c3b(255,255,255))
	end
end


--取消托管
function PokerScene:onQuXiaoTuoGuan()
	--玩家手牌置灰
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) --self.roomPlayers[self.playerSeatIdx]
	if roomPlayer.holdMjTiles then				
		for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
			self:setPokerIsUp(pkTile, false, false)
			pkTile.mjTileSpr:setColor(cc.c3b(200,200,200))
		end
	end

	self:handleTrusteeship(true,self.playerSeatIdx)
end

--分数加减效果
function PokerScene:socreChangeEffect(data)
	local changeReason  = {
		Ticket = 6, --报名费
	}

	local changeNum = data.changeNum
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(data.m_pos + 1)

	if data.reason == changeReason.Ticket then --报名费
		changeNum = math.abs(changeNum) * -1
	 -- 	if not tolua.isnull(self.common_ui_layer) then --服务费提示
		-- 	self.common_ui_layer:initPayCoin( changeNum )
		-- end	
	else --加金币
		local numFont = roomPlayer:createCoinEffect(changeNum,  plus_info, minus_info)
		numFont:setScale(0.6)

		--roomPlayer:createEffect()
	end
end

--实现自己托管或取消托管的处理
function PokerScene:handleTrusteeship(isVis,seatIdx)
	self:playTimeCDStart(isVis, seatIdx, self.playTimeCD)
    
    self.decisionBtnNode:setVisible(isVis)
end

function PokerScene:backMainSceneFromMatch()
	-- 事件回调
	gt6.removeTargetAllEventListener(self)
	-- 消息回调
	self:unregisterAllMsgListener()

	
	Utils6.cleanMWAction()

	if gt6.runningModule then 
		-- print("gt6.dispatchEvent(gt6.EventType.EXIT_MODULE_INNER)")
		-- gt6.dispatchEvent(gt6.EventType.EXIT_MODULE_INNER, gt6.runningModule)
		print("----> gt6.module_projectView = ",gt6.module_projectView)
		local coinScenePath = "app/projectView/" .. gt6.module_projectView .. "/CoinMainScene"
		local newScene = require(coinScenePath):create()
		cc.Director:getInstance():replaceScene(newScene)
	end
end

return PokerScene