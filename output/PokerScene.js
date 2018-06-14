
var gt6 = cc.exports.gt6
var Utils6 = cc.exports.Utils6

var plus_info = {
	fontPic = "gameType/2POKER/playScene/atlas/ddz_flyscore_num.png",
	font_size = {width = 30,height = 36},
	first_char = ".",
}

var minus_info = {
	fontPic = "gameType/2POKER/playScene/atlas/ddz_scorenum_minus.png",
	font_size = {width = 30,height = 36},
	first_char = ".",
}

require("app/gameType/base/CommonConst")
require("app/gameType/base/GamePlayUtils")
require("app/gameType/base/PlayersManager")
require("app/gameType/2POKER/playScene/FakeCardMgr") //癞子算法
require("app/gameType/base/model/RoomDataMgr")
var GamePlayUtils = gt6.GamePlayUtils
var CommonConst = gt6.CommonConst
var RoomDataMgr = gt6.RoomDataMgr
var DataDef = gt6.RoomDataMgr.DataDef
var PokerScene = PlaySceneBase.extend({
ctor:function(msgTbl){{
	var self = this;
	this.name = "PokerScene";
	var data = {msgTbl = msgTbl}
	gt6.gameType = gt6.gameTypeDefine.POKER

	PokerScene.super.ctor(self,data)


	print("//-> 注册 change_match_difen 消息 。。。。")
	gt6.registerEventListener("change_match_difen", self, self.onChangeMatchDifen)

 	//初始化数据
	self:initData(data.msgTbl)

	//初始化房间
	self:initRoom()

	// 初始化player管理器
	self:initPlayersManager()

	self:initDesk(data.msgTbl)

	// 玩家进入房间
	self:playerEnterRoom(data.msgTbl)

	self:initPokerTouch()

	self:registerScriptHandler(handler(self, self.onNodeEvent))

}

})


//游戏玩法的一些配置
//精灵帧名字
var reload_plists = {
	"poker.plist",
	"pokerOut.plist",
	"play_scene.plist",
	"PlayScene_common.plist",
}

var action_tag = {
	send_poker_tag = 100,
}

var default_csb = "PlayScene_poker3.csb"

var tileWidth = 155
var tileHeight = 216
var other_tileWidth = 96

var laizi_ani_time = 2

 // old ctor of lua has deleted
PokerScene.prototype.initDesBtn=function(msgTbl){
	if (! msgTbl ) { return }
	var id = nil
	var subGameArr = GameStyleConfig.subGameTypeArr
	for i, v in ipairs(subGameArr) do
		var flag = Utils6.checkPlaytypeByid(msgTbl.m_playTypeOptions, v)
		if (flag ) {
			id = v
			break
		}
	}

	if (id ) {
		var idStr = "id_" .. id
		self:createDesBtn(idStr)
	}

}

PokerScene.prototype.createDesBtn=function(idStr){
	var jueCeItem = g_jueCeAction_poker[idStr]
	var actionIdArr = jueCeItem.actionId
	var node = ccui.Widget:create()
	node:setContentSize(cc.size(250 * #actionIdArr, 85 ))
	node:setAnchorPoint(cc.p(0.5, 0.5))

	self.desBtn = node
	for i = 1, #actionIdArr do 
		var id = actionIdArr[i]
		var jueCeId = "id_" .. id
		var jueCeItem = g_jueCeId_poker[jueCeId]
		var pic = jueCeItem.pic
		var picPress = jueCeItem.picPress
		var picDis = jueCeItem.picDis
		var picResType = jueCeItem.picResType
		var name = jueCeItem.name

		var m_difen = jueCeItem.m_difen
		var m_yaobu = jueCeItem.m_yaobu
		var m_playerOper = jueCeItem.m_playerOper
		var m_operType = jueCeItem.m_operType
		if (m_difen === -1 ) { m_difen = nil }
		if (m_yaobu === -1 ) { m_yaobu = nil }
		if (m_playerOper === -1 ) { m_playerOper = nil }
		if (m_operType === -1 ) { m_operType = nil }

		if (picResType === "PLIST" ) {
			picResType = ccui.TextureResType.plistType 
		}else{
			picResType = ccui.TextureResType.localType
		}
		
		var button = ccui.Button:create()
	    function (sender,eventType) {
	        if (eventType === ccui.TouchEventType.ended ) {         
				var msgToSend = {}
				msgToSend.m_msgId = gt6.CG_QIANG_DIZHU
				msgToSend.m_pos = self.playerSeatIdx - 1
				msgToSend.m_difen = m_difen
				msgToSend.m_yaobu = m_yaobu
				msgToSend.m_playerOper = m_playerOper
				msgToSend.m_operType = m_operType
				gt6.socketClient:sendMessage(msgToSend)
				self.decisionBtnNode:setVisible(false)
	        }
	    }

	    var widthX = 250 * i - 120

	    button:setName(name)
		button:loadTextures(pic, picPress, picDis, picResType)	
	    button:setScale9Enabled(true)
	    button:setPosition(widthX, 43) 
	    button:addTouchEventListener(touchEvent)
	    node:addChild(button,9999)
	}
	node:setName("decisionBtn")
	self.decisionBtnNode:addChild(node)
}

PokerScene.prototype.onNodeEvent=function(eventName){
	if ("enter" === eventName ) {
		self:onEnter()
	} else if ("enterTransitionFinish" === eventName ) {
		self:onEnterTransitionFinish()
	} else if ("exit" === eventName ) {
		gt6.isMatch = nil
		self:onExit()
	} else if ("cleanup" === eventName ) {
        gt6.isMatch = nil
	}
}

PokerScene.prototype.onEnter=function(){
	gt6.log("PlayScene enter")
	gt6.ChatLog = {}
	if (gt6.defaultGameType === gt6.gameTypeDefine.POKER ) {
		gt6.soundEngine:playMusic("xlmj_bgm2", true)
	}
	var eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	var customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
								handler(self, self.onEnterBackground))
	eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
	var customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
								handler(self, self.onEnterForeground))
	eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)

		// 逻辑更新定时器
	self:openUpdateSchedule()

}

PokerScene.prototype.onEnterBackground=function(){
	//出游戏 用来计算倒计时 秒为单位
	self:setOutGameTimeStamp()
}

PokerScene.prototype.onEnterForeground=function(){
	// 回来游戏
	if (! self.playTimeCD ) { return }
	var runOffTime = self:countRunOffTime()
	self.playTimeCD = self.playTimeCD - runOffTime
}

PokerScene.prototype.onEnterTransitionFinish=function(){
	gt6.log("PlayScene enterTransitionFinish")
}

PokerScene.prototype.onExit=function(){
	gt6.log("PlayScene exit")
	gt6.gameType = nil

	var eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:removeEventListenersForTarget(self.cards_layer)
	eventDispatcher:removeEventListenersForTarget(self)
	self:closeUpdateSchedule()
	gt6.removeTargetEventListenerByType(self,gt6.EventType.UPDATE_BG_GAME)
	gt6.PlayersManager:clear()

	if (gt6.defaultGameType === gt6.gameTypeDefine.POKER ) {
		gt6.soundEngine:playMusic("xlmj_bgm1", true)
	}

	RoomDataMgr:clear()
	self.register_opt_list = {} //都是临时方案 以后优化
}

//根据配表， 初始化字段值
PokerScene.prototype.initXSLFiled=function(msgTbl){
	self.mMaxFanShu = 0 //初始值， 配表中更新
	self.playMaxNum = 3
	self.haveBomb = 0 //=1带炸弹， =0不带炸弹
	
	dump(self.room_config,"self.room_config")
	var playeType = self.room_config.name
	var desc = ""

	//算一些标识
	for k, v in ipairs(g_PlayType) do
		for kk, vv in ipairs(msgTbl.m_playTypeOptions) do
			if (v && vv && v.id === vv ) {
				if (v.fieldName ) {
					self[v.fieldName] = v.fieldValue
					gt6.log("fieldName " .. v.fieldName .. " : " .. tostring(v.fieldValue))
				}

				if (v.playTypeDes ) {
					desc = desc .. v.playTypeDes .. ","
				}
			} 
		}
	}	


	// 斗地主
	if (self.mGameStyle <= 7 && self.mGameStyle >=0 ) {
		if (self.mGameStyle === gt6.CommonConst.GameType.JINGDIAN ) {
			if (self._gameType && self._gameType === 1 ) { //代表叫分
				playeType = "经典斗地主"
			} else if (self._gameType && self._gameType === 2 ) { // 代表抢地主玩法
				playeType = "欢乐斗地主"
			}
		}	
	}else{
		desc = string.sub(desc,1,-2)
		if (playeType ) {
			playeType = playeType .. "," .. desc
		}else{
			playeType = desc
		}		
	}
	
	gt6.log("玩法类型：" .. playeType)
	self.playTypeDesc = playeType

	cc.UserDefault:getInstance():setStringForKey("playType", playeType)
	cc.UserDefault:getInstance():flush()
}

PokerScene.prototype.initData=function(msgTbl){
	dump(msgTbl, "PokerScene:initData msgTbl")

	//为了兼容其他服务器的一些用法 我知道很sb但也没办法
	if (msgTbl.m_gameStyle ) {
		msgTbl.m_mainGameType = msgTbl.m_gameStyle
		msgTbl.m_subGameType = 0
	}

	if (! msgTbl.m_playTypeOptions ) {
		msgTbl.m_playTypeOptions = {}
	}

	//游戏模式 金币 比赛等
	self.mGameStyle = msgTbl.m_mainGameType + msgTbl.m_subGameType

	
	if (msgTbl.m_gameZone === 1 ) {
		self.mRoomPattern = gt6.CommonConst.RoomPattern.COIN
		self.readyPlayMsg.playType = gt6.coinType.POKER
		self.playType = gt6.coinType.POKER
	}


	gt6.log("self.mGameStyle " .. self.mGameStyle)

	self.room_config = GameStyleConfig[self.mGameStyle] || {}
	self:initXSLFiled(msgTbl)

	self.playTimeCD = 0
	self.is_turn_me = false //是否轮到自己
	
	self.laiTag = 1

	// self.mMaxFanShu = 20 // 炸弹数目没有上限
	self.curBooms = 0 //// 当前炸弹数
	self.curMultiple = 1 //-当前倍数
	//关于游戏倍数有关的//}
   	
   	//存储当前出牌的信息
	self.curShowCardInfo = {cardArr = {}, cardType = 0,cardNum = 0}
	//////////-	
	//二人专有
	self.check_poker_num = 0
	self.win_poker_num = 0
	self.open_poker_index = -1 //对手明牌的具体位置
	self.open_poker_seat = -1//msgTbl.m_firstPos_card[1] + 1//获得明牌的位置
	self.open_poker_value = -1 //msgTbl.m_firstPos_card[2]//明牌值

	//最大翻数(目前最大炸弹数也包括进去了)
	if (msgTbl.m_nMaxFanshu ) {
		self.mMaxFanShu = msgTbl.m_nMaxFanshu
	}

	self.time = 0
	self.optionType = msgTbl.m_eIsMustOut || 0 //必须出 老麻子游戏

	//获取dealer信息 不同游戏dealer的内容不一样 配置驱动
	self.dealer_info_config = nil
	var dealer_type = self.room_config.dealer_type
	if (dealer_type ) {
		self.dealer_info_config = GameStyleConfig.DealerInfo[dealer_type]
	}

	self.SelectCard = {} // 选中的牌
	//特殊字段
	self:checkSpeicals()

	//决策节点
	self.decisionBtnNode = nil

	//玩法类型
	self:initPlayType()
}

PokerScene.prototype.initPlayType=function(){
	// body
	// 玩法类型
	if (self.readyPlayMsg && ! self.readyPlayMsg.playerSeatPos ) {
		self.readyPlayMsg.playerSeatPos = self.readyPlayMsg.m_pos
	} 

	if (self.readyPlayMsg && ! self.readyPlayMsg.roomID ) {
		self.readyPlayMsg.roomID = self.readyPlayMsg.m_deskId 
	}

	if (self.mGameStyle <= 7 && self.mGameStyle >=0 ) {
		self.readyPlayMsg.title_show = "斗地主"
		self.readyPlayMsg.playTypeDesc = "come on baby"

		var newStrType = ""
	    var circleToShow = self.readyPlayMsg.m_maxCircle .. "局"
	    newStrType = "斗地主" .. " "..circleToShow 
		if (self._gameType === 1 ) {
			newStrType = newStrType .. " 叫分"
		} else if (self._gameType === 2 ) {
			newStrType = newStrType .. " 抢地主"
		}
		self.readyPlayMsg.playTypeDesc = newStrType
	}
}


PokerScene.prototype.checkSpeicals=function(){
	//特殊显示处理
	self.close_auto_end_poker_flag = false
	self.re_sort_out_poker_flag  = false 
	self.show_opponent_poker_back_flag = false
	self.show_check_poker_flag = false
	self.fapai_bu_fanpai_flag = false

	self.check_airplane_flag = false //检测飞机标志
	self.show_buyao_btn_flag = false
	self.show_reset_btn_flag = false 
	self.calc_multip_flag = false
	self.auto_calc_card_flag = false //是否自动算牌

	self.have_laizi_flag = false //是否带癞子
	self.have_pizi_flag = false //是否带皮子

	if (g_SpeicalShow &&  next(g_SpeicalShow) ) {
		self.close_auto_end_poker_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.CLOSE_AUTO_SEND_POKER,self.mGameStyle) 
		self.re_sort_out_poker_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.RE_SORT_OUT_POKER,self.mGameStyle) 
		self.show_opponent_poker_back_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.SHOW_OPPONENT_POKER_BACK,self.mGameStyle) 
		self.show_check_poker_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.SHOW_CHECK_POKER,self.mGameStyle) 
		self.fapai_bu_fanpai_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.FAPAI_BU_FANPAI,self.mGameStyle)

		self.check_airplane_flag =  gt6.checkSpecialSetByState(gt6.SpecialSetId.HAVE_PLANE , self.mGameStyle) 
		self.show_buyao_btn_flag =  gt6.checkSpecialSetByState(gt6.SpecialSetId.SHOW_PASS  , self.mGameStyle)
		self.calc_multip_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.CALC_MULTIP  , self.mGameStyle)
		self.auto_calc_card_flag = gt6.checkSpecialSetByState(gt6.SpecialSetId.AUTO_CALC_CARD  , self.mGameStyle)
	}

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

	//目前还没有配进exsl里的
	if (self.mGameStyle === gt6.CommonConst.GameType.LAIZI    //斗地主癞子
		|| self.mGameStyle === gt6.CommonConst.GameType.FAKEPDK ) { //跑得快癞子
		self.have_laizi_flag = true
	}

	if (self.mGameStyle === gt6.CommonConst.GameType.DAIPIZI ) {
		self.have_pizi_flag = true
	}
}

PokerScene.prototype.initRoom=function(){
	//如果开始没有被赋值
	var name = string.format("PlayScene_poker%d.csb",self.playMaxNum)
	var csb_path = "gameType/2POKER/playScene/"..name

	cc.SpriteFrameCache:getInstance():addSpriteFrames("inGame/inGame.plist")
	//加载精灵帧防止被释放掉
	Utils6.loadPlist(reload_plists)
	//加载主ui
	self.rootNode =  Utils6.loadCSB(csb_path,"POKER")

	var custom_ui = self.room_config.custom_ui || "Layer_ZSPK"
	var csb_path = "gameType/2POKER/playScene/"..custom_ui..".csb" //自己额外的csb需要配置
	var node = Utils6.loadCSB(csb_path,custom_ui) 
	print("////> 自己额外的csb需要配置 csb_path , custom_ui = ",csb_path , custom_ui)
	node:setZOrder(gt6.CommonConst.ZOrder.DECISION_BTN)
	self.rootNode:addChild(node)

 	var Sprite_BombTimes = gt6.seekNodeByName(node, "Sprite_BombTimes")
 	self.Sprite_BombTimes = Sprite_BombTimes
 	Sprite_BombTimes:setVisible(false)

	//底分
	self.Txt_Times = gt6.seekNodeByName(self.Sprite_BombTimes , "AtlasLabel_TimesAtlasLabel_Times")
	// 底牌节点
	if (self.room_config.bottomCard ) {
		//添加底牌
		self.bottomCard = require("app/gameType/2POKER/playScene/BottomCardsLayer"):create(self, self.room_config.bottomCard)
		self.bottomCard:setVisible(false)
		self.bottomCard:setName("BottomCardsLayer")
		self.rootNode:addChild(self.bottomCard)
	}

	// 初始化决策按钮
	self:initPlayGameBtn()

	//Zorder重置
   	for i = 1, self.playMaxNum do
   		var player = gt6.seekNodeByName(self.rootNode,"Node_playerMjTiles_"..i)
   		player:setLocalZOrder(gt6.CommonConst.ZOrder.OUTMJTILE_SIGN)
   	}
}

PokerScene.prototype.initDesk=function(msgTbl){
	dump(msgTbl,"//-> PokerScene:initDesk(msgTbl) : ")
	self:initTurnUiLayer(msgTbl)
	self:createCardLayer(self.rootNode)

	self:changePlayBg(self,2)
	//self:setTable("gameType/2POKER/playScene/playBg/tableb_zhuobu.png")

	var common_ui_layer = self.common_ui_layer
	
	var ready_ui_layer = self.ready_ui_layer
     //移动按钮
	var menuPos = cc.p(common_ui_layer.speakBtn:getPosition())
	common_ui_layer.yuyinBtn:setPosition(gt6.winSize.width-50,menuPos.y -350)
	common_ui_layer.messageBtn:setPosition(gt6.winSize.width-50 ,menuPos.y-250)
	common_ui_layer.speakBtn:setPosition(gt6.winSize.width-50,menuPos.y-450)
	ready_ui_layer._Btn_ready:setPosition(cc.p(gt6.winCenter.x, gt6.winCenter.y - 300))

	if (msgTbl.m_gameType === gt6.playGameZone.match ) {
		common_ui_layer:matchLayerShow(false)
		// common_ui_layer:changeMatchDifen(msgTbl)
	}else{
		common_ui_layer:updateRoomId(msgTbl.m_deskId)
	}

	
	//初始化癞子相关
	if (self.have_laizi_flag ) {
		//初始化癞子算法
		gt6.FakeCardMgr:getInstance():init(self.room_config.fakeCfgName)
		//二意性选择
		var datas = {}
		datas.parent = self
		self.mAmbiguityLayer = require("app/gameType/2POKER/playScene/AmbiguityLayer"):create(datas)
		self.desk_layer:addChild(self.mAmbiguityLayer)
		
		//癞子底牌
		self.mFakeLayer = require("app/gameType/2POKER/playScene/FakeLayer"):create()
		self:addChild(self.mFakeLayer)
	}

	self:initDesBtn(msgTbl)

	//金币场功能
	if (self.mRoomPattern === gt6.CommonConst.RoomPattern.COIN ) {
		
		self.ready_ui_layer:setVisible(false)
		var x,y = self.ready_ui_layer._Btn_ready:getPosition()
		var readyBtnPosition = cc.p(x,y)
		self:createCoinRoomBtn()  //创建后 先隐藏掉 关闭界面后显示出来
		if (! tolua.isnull(self.changeBtn) ) {
			self.changeBtn:setPosition(readyBtnPosition.x - 170,readyBtnPosition.y)
		}
		if (! tolua.isnull( self.continueBtn) ) {
			self.continueBtn:setPosition(readyBtnPosition.x + 140,readyBtnPosition.y)
		}

		//金币场创建 描述信息
		self.common_ui_layer:initCoinLevel(msgTbl)

		self.mAlarmClockLayer = require("app/gameType/base/AlarmClockLayer"):create()
		self:addChild(self.mAlarmClockLayer, gt6.CommonConst.ZOrder.SETTING_LAYER - 1)
	}

	//创建一个闹钟
	self:setClockPosition(1, false)

	
	if (self.mGameStyle >= 0 && self.mGameStyle <= 5 && msgTbl.m_gameType != gt6.playGameZone.match ) {
		//测试用 创建一个记牌器
		self.PokerMemoryLayer = require("app/gameType/2POKER/component/PokerMemoryLayer"):create()
		self:addChild( self.PokerMemoryLayer )
		self.PokerMemoryLayer:init({ have_king = true, playerSeatIdx = self.playerSeatIdx, playMaxNum = self.playMaxNum})
	}
}

PokerScene.prototype.onChangeMatchDifen=function( msgType,mathDifen,gameData ){
	print("//->  斗地主 更改比赛底分 mathDifen= ",mathDifen)
	if (! gameData ) { return }
	if (gameData.gameZone === gt6.playGameZone.match ) {
		var _msg = {}
		_msg.m_gameType = gameData.gameType
		_msg.m_gameZone = gameData.gameZone
		_msg.m_roomDiFen = mathDifen 
		self.common_ui_layer:changeMatchDifen(_msg)
	}
}

PokerScene.prototype.registerMsgs=function(){
	print(" PokerScene:registerMsg()===")
	PokerScene.super.registerMsgs(self)

	gt6.socketClient:registerMsgListener(gt6.GC_SYNC_ROOM_STATE, self, self.onRcvSyncRoomState) //断线重连
	gt6.socketClient:registerMsgListener(gt6.GC_START_GAME, self, self.onRcvStartGame) //开始游戏

	gt6.socketClient:registerMsgListener(gt6.GC_TURN_SHOW_MJTILE, self, self.onRcvTurnShowMjTile) //通知玩家出牌
	gt6.socketClient:registerMsgListener(gt6.GC_SYNC_SHOW_MJTILE, self, self.onRcvSyncShowMjTile) //显示玩家出牌消息
	gt6.socketClient:registerMsgListener(gt6.GC_ROUND_STATE, self, self.onRcvRoundState) //当前局数/最大局数
	gt6.socketClient:registerMsgListener(gt6.GC_GET_SURPLUS, self, self.onSurplusCard) //最后手中剩余牌消息
	gt6.socketClient:registerMsgListener(gt6.GC_ROUND_REPORT, self, self.onRcvRoundReport) //单局游戏结束
	gt6.socketClient:registerMsgListener(gt6.GC_FINAL_REPORT, self, self.onRcvFinalReport) //总结算界面

	//地主 挖坑等游戏
	gt6.socketClient:registerMsgListener(gt6.GC_ASK_DIZHU, self, self.onRcvASKDIZHU) //通知客户端抢地主
	gt6.socketClient:registerMsgListener(gt6.GC_ANS_DIZHU, self, self.onRcvANSDIZHU)//服务器广播客户端操作
	gt6.socketClient:registerMsgListener(gt6.GC_WHO_IS_DIZHU, self, self.onRcvWHOISDIZHU)//服务器广播最终地主位置
	gt6.socketClient:registerMsgListener(gt6.MSG_S_2_C_SHOWCARDS, self, self.onRcvSHOWCARDS)

	//重置翻倍数
	gt6.registerEventListener(gt6.EventType.RESET_MULTIP, self, self.resetMultipFunc)
	//返回大厅，解散房间事件
	gt6.registerEventListener(gt6.EventType.POKER_BACK_DISMISS, self, self.onBackOrDismiss)
	//金币场，结算界面 点关闭 显示出继续和换桌按钮
	gt6.registerEventListener(gt6.EventType.SHOW_GOON_CHANGE, self, self.onShowGoOnAndChange)
	//调整ui层级
	gt6.registerEventListener(gt6.EventType.CHECK_ZORDER, self, self.onCheckZorder)

	gt6.registerEventListener(gt6.EventType.BACK_MAIN_SCENE_FROM_MATCH, self, self.backMainSceneFromMatch)

	//dump(self.register_opt_list,"==register_opt_list==")
}

PokerScene.prototype.onCheckZorder=function(event, data ){
	var tag = data.tag
	var newOrder = data.order
	if (tag === "AlarmClockLayer" ) {
		if (! tolua.isnull(self.mAlarmClockLayer) && newOrder ) {
			self.mAlarmClockLayer:setLocalZOrder(newOrder)
		}
	}
		
}

PokerScene.prototype.onShowGoOnAndChange=function(){
	if (self.mRoomPattern === gt6.CommonConst.RoomPattern.COIN ) {
		if (! tolua.isnull(self.changeBtn) ) { self.changeBtn:setVisible(true) }
		if (! tolua.isnull(self.continueBtn) ) { self.continueBtn:setVisible(true) }
	}
}

PokerScene.prototype.resetMultipFunc=function(){
	self.curBooms = 0 //// 当前炸弹数
	self.curMultiple = 1 //-当前倍数

	gt6.log("resetMultipFunc Txt_Times ".. self.curMultiple)
	self.Txt_Times:setString("" ..  self.curMultiple)
}

PokerScene.prototype.unregisterAllMsgListener=function(){
	print("unregisterAllMsgListener")
	PokerScene.super.unregisterAllMsgListener(self)

	gt6.removeTargetAllEventListener(self)
}

PokerScene.prototype.initPlayGameBtn=function(){
	// 决策按钮位置信息
	// 隐藏玩家决策按钮（提示、出牌、不出的父节点）
	self.decisionBtnNode = gt6.seekNodeByName(self.rootNode, "Node_decisionBtn")
	self.rootNode:reorderChild(self.decisionBtnNode, gt6.CommonConst.ZOrder.DECISION_BTN)
	self.decisionBtnNode:setVisible(false)

	self.play 		= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_1")
	self.prompt 	= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_2")
	self.pass 		= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_3") //不要按钮
	self.restore 	= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_4")
	self.nograb 	= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_5")
	self.grab 		= gt6.seekNodeByName(self.decisionBtnNode, "Btn_decision_6")
	var nodePlay 		= gt6.seekNodeByName(self.decisionBtnNode,"Node_Play")
	var nodePrompt 	= gt6.seekNodeByName(self.decisionBtnNode,"Node_Prompt")
	var nodeReset 	= gt6.seekNodeByName(self.decisionBtnNode,"Node_Reset")

	self.btnPlayPosition 	= cc.p(self.play:getPosition())
	self.btnPlayPosition2 	= cc.p(nodePlay:getPosition())

	self.btnPromptPosition 	= cc.p(self.prompt:getPosition())
	self.btnPromptPosition2 = cc.p(nodePrompt:getPosition())

	self.btnPassPosition 	= cc.p(self.pass:getPosition())

	self.btnResetPosition 	= cc.p(self.restore:getPosition())
	self.btnResetPosition2 	= cc.p(nodeReset:getPosition())

	//提示 和 出牌
	//出牌
	gt6.addBtnPressedListener(self.play, function(){
		gt6.soundEngine:playEffect("common/SpecOk", false, "2POKER")
		if (#self.SelectCard === 0 ) {
			//未选牌时按钮变灰不可点击
			gt6.floatText("未选牌")
			return	
		}

		var temp_card = {}
		var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)

		for key,value in pairs(self.SelectCard) do
			var pkTile = roomPlayer.holdMjTiles[value]
			if (pkTile ) {
				var card_sprite = pkTile.mjTileSpr
				if (card_sprite && ! tolua.isnull(card_sprite) ) {
					table.insert(temp_card, tonumber(card_sprite:getName()))
				} 
			}
		}

		if (self.have_laizi_flag ) {
			if (! tolua.isnull(self.mAmbiguityLayer) ) {
				dump(temp_card, "temp_card////->")
				self.mAmbiguityLayer:laiziPaly(temp_card,roomPlayer)
			}
		}else{
			var msgToSend = {}
			msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
			msgToSend.m_flag = 0
			msgToSend.m_nCardType = 0
			msgToSend.m_card = temp_card
			gt6.socketClient:sendMessage(msgToSend)
			self.decisionBtnNode:setVisible(false)
		}

		if (self.have_pizi_flag ) {
			self.promptIndex = 1
		}

	}, nil, nil)

	//提示
	gt6.addBtnPressedListener(self.prompt, function(){
		gt6.soundEngine:playEffect("common/SpecOk", false, "2POKER")
		var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		self:tipPoker(roomPlayer)
	}, nil, nil)	

	//不要按钮
	gt6.addBtnPressedListener(self.pass, function(){
		gt6.soundEngine:playEffect("common/SpecOk", false, "2POKER")
		var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		//众神归位
		for j=1, #roomPlayer.holdMjTiles do
			self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
		}
		var msgToSend = {}
		msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
		msgToSend.m_flag = 1
		gt6.socketClient:sendMessage(msgToSend)

		self.decisionBtnNode:setVisible(false)
	})

	//self.pass:setVisible(self.show_buyao_btn_flag)
	self.play:setPressedActionEnabled(false)
	self.prompt:setPressedActionEnabled(false)
	self.pass:setPressedActionEnabled(false)
	self.restore:setPressedActionEnabled(false)
}

////-协议解析//////////start//////////-
//最后手中剩余牌消息
PokerScene.prototype.onSurplusCard=function(msgTbl){
	// body
	for i=1,self.playMaxNum do
		var outMjTilesAry = msgTbl["m_cards" .. i - 1]
		if (#outMjTilesAry > 0 ) {
			var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(i)
			roomPlayer:removeAlreadyOutMjTiles()
		}
		if (outMjTilesAry ) {
			for k, v in ipairs(outMjTilesAry) do
				self:addAlreadyOutMjTilesFinally(i,v,k)
			}
		}	
 	}
}

//同步出牌
PokerScene.prototype.onRcvSyncShowMjTile=function(msgTbl){
	self:stopCountDownSound()
	self.is_turn_me = false
	var seatIdx = msgTbl.m_pos + 1
	
	if (! tolua.isnull(self.PokerMemoryLayer) ) {
		self.PokerMemoryLayer:recordStyle(seatIdx, msgTbl.m_card)
	}

	// 座位号（1，2，3）
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	var realSeat = roomPlayer.displaySeatIdx

	var card = msgTbl.m_card

	//记录当前出的牌 类型 以及癞子类型 
	if (#card > 0 && msgTbl.m_type ~=0 ) {
		var number = msgTbl.m_typeNumber || 0
		self:updateCurShowPokerInfo(msgTbl.m_type,card,number)
	}
	print("seatIdx " .. seatIdx .. " playerSeatIdx " .. self.playerSeatIdx )
	// 出牌成功
	if (msgTbl.m_errorCode === 0 ) { 
		//dump(roomPlayer.holdMjTiles,"roomPlayer.holdMjTiles===1111==")
		if (seatIdx === self.playerSeatIdx ) {
			self.SelectCard = {}
		}
		self:setClockPosition(seatIdx, false)
		self:animationPlayerMjTilesReferPos(realSeat)
	}


	var is_error = self:checkPokerError(msgTbl.m_errorCode)
	if (is_error ) {
		self.decisionBtnNode:setVisible(true)

		print("错误 错误 错误")

		var play_self = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)

		if (play_self ) { 
			for j=1, #play_self.holdMjTiles do

			self:setPokerIsUp(play_self.holdMjTiles[j], false, false)
			}
			self.SelectCard = {}
		}
		

		return
	} 

	if (seatIdx === self.playerSeatIdx ) {
		self:resetSelfPokerColor()
	}
	
	if (msgTbl.m_flag === gt6.CommonConst.OutPokerType.BUYAO  ) {
		self:buYaoAction(seatIdx)
	}

	if (self.decisionBtnNode:isVisible() === true ) {
		self.decisionBtnNode:setVisible(false)
	}
   	
   	if (seatIdx != self.playerSeatIdx ) {
   		roomPlayer.leftCardsNum = roomPlayer.leftCardsNum - #card
   		roomPlayer:showLeftCardNum(self.room_config.showHandPokerNum) 
	}else{
		roomPlayer.leftCardsNum = roomPlayer.leftCardsNum - #card
	
   	}

   	var id_name = string.format("id_1_%d",msgTbl.m_type)
   	self:playActionByIdName(id_name ,msgTbl)

	self:refreshOutPokers(seatIdx)
}

PokerScene.prototype.onRcvTurnShowMjTile=function(msgTbl){
	gt6.log("通知玩家出牌")
	var seatIdx = msgTbl.m_pos + 1 
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)

	// 轮到玩家出牌 m_flag 当前是否第一个出牌 0-是（没有上家） 1-不是
	if (msgTbl.m_flag === 0 ) {
		self.curShowCardInfo = {cardArr = {}, cardType = 0,cardNum = 0} //癞子 皮子等需要本地判断的才有用
	}else{
		self.curShowCardInfo = self.curShowCardInfo || {} //癞子 皮子等需要本地判断的才有用
		self.curShowCardInfo.m_curCardCount = msgTbl.m_curCardCount
		self.curShowCardInfo.m_curCardMode = msgTbl.m_curCardMode
		self.curShowCardInfo.m_curCardType = msgTbl.m_curCardType
	}

	// 玩家需要处理的数据
	self.curShowMjTileInfo = msgTbl
	self.promptIndex = #msgTbl.m_array
	self.maxPromptIndex = #msgTbl.m_array

	//客户端检索提示牌
	self:localShowPokerTip()

	if (self.desBtn && ! tolua.isnull(self.desBtn) ) { //隐藏 挖坑， 斗地主特殊决策
		self.desBtn:setVisible(false)
	}

	roomPlayer:removeAlreadyOutMjTiles()

	if (roomPlayer.seatIdx === self.playerSeatIdx ) {
		self:resetSelfPokerColor()
	}

	//判断倒计时显示
	if (seatIdx === self.playerSeatIdx ) {
		self.is_turn_me = true
		if (self.status === gt6.CommonConst.ROOM_STATUS.SEND_CARD ) {
			print("====xxxx====="..tostring(self.status))
			self.turnShowMsgTbl = msgTbl //第一次进入游戏，缓存下。 发牌动画结束检测禁用牌
			//仅有经典跑得快 别人出牌，检测 不能出的禁牌
			if (self.mGameStyle === gt6.CommonConst.GameType.CLASSICSPDK ) {			
				self:disableCard(msgTbl, roomPlayer)
			}

			// 出牌倒计时
			self.decisionBtnNode:setVisible(false)
			self:playTimeCDStart(false,seatIdx,msgTbl.m_time)
			return
		}else{
			self.decisionBtnNode:setVisible(true)
			self:playTimeCDStart(true,seatIdx,msgTbl.m_time)
		}
	}else{
		self.is_turn_me = false
		self:playTimeCDStart(true,seatIdx,msgTbl.m_time)
	}


	//托管了 后面的逻辑就不要执行了
	if (self.mIsInTrusteeship ) {
		self.decisionBtnNode:setVisible(false)
		return
	}
	
	for i,v in ipairs(roomPlayer.holdMjTiles) do
		v.mjTileSpr:setColor(cc.c3b(255,255,255))
		v.mjIsTouch = true
	}

	if (seatIdx === self.playerSeatIdx ) {
		//禁牌
		self:disableCard(msgTbl,roomPlayer)

		//检测不可点击牌移除
		if (self.SelectCard ) {
			for i = #self.SelectCard, 1, -1 do
				var index = self.SelectCard[i]
				var pokerTile = roomPlayer.holdMjTiles[index]
				if (pokerTile && pokerTile.mjIsTouch === false ) {
					table.remove(self.SelectCard,i)
				}
			}
		}

		// //牌归位
		for j=1, #roomPlayer.holdMjTiles do
			var pokerTile = roomPlayer.holdMjTiles[j]
			if (pokerTile.mjIsTouch === false ) {
				self:setPokerIsUp(pokerTile, false, false)
			}
		}

		// self.SelectCard = {}
		self.tempTouchPoker = {}
	}
	
	//自动提示牌
	// if (#msgTbl.m_array === 1 ) {
	// 	self:tipPoker(roomPlayer)
	// }

	//服务器给的自动不要
	if (msgTbl.m_autoPlay && msgTbl.m_autoPlay === 1 ) {
		if (seatIdx === self.playerSeatIdx ) {
			//自动不要
			self.decisionBtnNode:setVisible(false)
			self:autoBuyao(seatIdx,msgTbl)
			return
		}
	} 

	//不显示不要的直接出牌
	if (! self.show_buyao_btn_flag ) {
		if (#msgTbl.m_array === 0 && msgTbl.m_flag === 1  ) { // 直接到下一家
			if (seatIdx === self.playerSeatIdx ) {
				self:autoBuyao(seatIdx,msgTbl)
				return
			}
		}
	} 

	//手牌打出 //游戏没关闭最后一手自动打牌走这里
	if (! self.close_auto_end_poker_flag ) {
		if (msgTbl.m_last === 1  ) { 
			//赢家座位号
			if (seatIdx === self.playerSeatIdx ) {
				//自动出牌
				self:autoSendPoker()
				return
			}
		}
	} 
	// 轮到玩家决策
	self:turnMeDecision(seatIdx,msgTbl)
}

//- 比赛场显示
PokerScene.prototype.matchInfoShow=function( msgTbl ){
	print("////> PokerScene:matchInfoShow ....")
	dump(msgTbl,"////> PokerScene:matchInfoShow( msgTbl ) : ")
	var _beginPosX = self.Sprite_BombTimes:getPositionX()
	if (! self.Sprite_BombTimes:getParent():getChildByName("MLimitdifen") ) { 
		var _MLimitdifen = ccui.Text:create("",nil,24)
		_MLimitdifen:setColor(cc.c3b(255,255,0))
		_MLimitdifen:setName("MLimitdifen")
		_MLimitdifen:setVisible(false)
		_MLimitdifen:setPosition(  _beginPosX ,self.Sprite_BombTimes:getPositionY() - 33 )
		self.Sprite_BombTimes:getParent():addChild(_MLimitdifen)
	}

	print("//-> m_ruleType = ",msgTbl.m_deskInfo.m_ruleType)
	var _isDjjf = msgTbl.m_deskInfo.m_ruleType === gt6.MatchRuleType.dingju  // 1-定居积分； 0-打立除局 不显示
	
	self.common_ui_layer:matchInfoShow(msgTbl)

	// 低于多少分淘汰
	if (self.Sprite_BombTimes:getParent():getChildByName("MLimitdifen") && ! _isDjjf ) {
		var _a = self.Sprite_BombTimes:getParent():getChildByName("MLimitdifen")
		_a:setString( string.format("低于 %s 分被淘汰",msgTbl.m_deskInfo.m_outScore) )
		_a:setVisible(true)
	}

}

//更新回合数
PokerScene.prototype.onRcvRoundState=function(msgTbl){
	// 是否是比赛场 
	print("////> PokerScene:onRcvRoundState(data) .....")
	dump(msgTbl,"//-> 是否是比赛场 msgTbl = ",msgTbl)

	if (msgTbl.m_deskInfo && ! gt6.isMatch ) {
		gt6.isMatch = true
		print("////> 当前是比赛场 ")
	}
	gt6.isMatch = gt6.isMatch || nil
	print("//-> gt6.isMatch = ",gt6.isMatch)

	if (gt6.isMatch ) {
		Utils6.initMatchProxy()
		if (self:getChildByName("roundReport") ) {
			self:getChildByName("roundReport"):removeFromParent()
		}

		self:matchInfoShow(msgTbl)

		gt6.MCommonMatchManage:SetMatchingStatus(true)
		print("////> jushu : ",msgTbl.m_curCircle,msgTbl.m_curMaxCircle)
		gt6.MCommonMatchManage:SetMatchRoundEnd( (msgTbl.m_curCircle+1) === msgTbl.m_curMaxCircle)
		// 
	}
	// 牌局状态,剩余牌
	var stateNum = string.format("%d/%d",(msgTbl.m_curCircle + 1), msgTbl.m_curMaxCircle)
	gt6.log("onRcvRoundState:"..stateNum)
	self.common_ui_layer:updateRoundUi(stateNum)

}

//单局结算
PokerScene.prototype.onRcvRoundReport=function(msgTbl){
	gt6.log("游戏结束")
	if (self.mRoomPattern === gt6.CommonConst.RoomPattern.COIN ) {
		self:removeTrusteeshipBtn()
		//结束后 弹窗下面的定时器
		if (msgTbl.m_time && ! tolua.isnull(self.mAlarmClockLayer) ) {
			self.mAlarmClockLayer:startCountDown(msgTbl.m_time)
		}			
	}

	if (gt6.isMatch ) {
		if (! tolua.isnull(self.mAlarmClockLayer) ) {
			self.mAlarmClockLayer:startCountDown(10)
		}
	}

	if (gt6.isMatch ) {
		self.common_ui_layer:clearMatchShow()
	}

	//翻倍更新
	self:fanBeiOnRcvRoundReport(msgTbl)

	// gt.agoraUtil:leaveChannel()
	self:setStatus(gt6.CommonConst.ROOM_STATUS.ROUND_END)

	self:stopCDAudio()
	// 清除三张底牌
	self:clearLastHand()

	//发送移除警报
	gt6.PlayersManager:removeAlarm()

	//不通游戏，延迟时间不同，表里配
	var delTime = self.room_config.roundReportDelayTime
	var delayTime = cc.DelayTime:create(delTime)
	var callFunc = cc.CallFunc:create(function(sender){
		self:showWinTip(false)
		self:clearCheckPoker()
		self:roundEnd()

		self.mIsInTrusteeship = false
		self.is_turn_me = false
		self.SelectCard = {}
		// 停止倒计时音效
		self.playTimeCD = nil

		//隐藏闹钟 托管
	   	for i = 1, self.playMaxNum do
			var room_play = gt6.PlayersManager:getRoomPlayersBySeat(i)
			if (room_play ) {
				room_play:removeIdentity()
				room_play:removeTrusteeship() //移除托管机器人
			}
	    }		

		// 隐藏倒计时
		if (! tolua.isnull(self.clock) ) { self.clock:setVisible(false) }
		// 隐藏决策
		self.decisionBtnNode:setVisible(false)
		//
		self:hidePlayDecisionBtn()
		if (! tolua.isnull(self.nograb) ) { self.nograb:setVisible(false) }
		if (! tolua.isnull(self.grab) ) { self.grab:setVisible(false) }

		//清除托管相关
		self:gameEndClearTrusteeship()

		// 弹出局结算界面
		var roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
		var data = {}
		data.roomPlayers = roomPlayers || {} //之前这样可能roomPlayers是nil 效仿一下 final时候的处理
		data.playerSeatIdx = self.playerSeatIdx
		data.rptMsgTbl = msgTbl
		data.dizhuPos = self.mZhuangPos
		data.isCoin = false
		data.gameStyle = self.mGameStyle
		if (self.mRoomPattern === gt6.CommonConst.RoomPattern.COIN ) { 
			data.isCoin = true 
		}
		
		// gt6.log("self.mGameStyle " .. self.mGameStyle)
		// dump(data,"////> create RoundReport_DDZ : ")
		//如果在弹出胜利界面，在胜利上面显示
		gt6.dispatchEvent(gt6.EventType.CHECK_ZORDER, {tag = "AlarmClockLayer", order = gt6.CommonConst.ZOrder.ROUND_REPORT + 1 } )

  //  		  //  		roundReport:setName("roundReport")
		// self:addChild(roundReport, gt6.CommonConst.ZOrder.ROUND_REPORT)
		if (gt6.isMatch ) {
			dump(msgTbl,"//-> 斗地主结算界面 msgTbl = ")
			if (gt6.MCommonMatchManage ) {
				print("====> 斗地主结算 new 111111")
				gt6.MCommonMatchManage:SetMatchRoundReport(false)
			}
			print("//-> 比赛结束 ，是否是最后一局 m_end = ",msgTbl.m_end)
			// msgTbl.m_end = 1
			if (gt6.MCommonMatchManage && tonumber(msgTbl.m_end) === 1 ) {
				print("//-> 斗地主结算 new  222222")
				gt6.MCommonMatchManage:changeShowLayerIndex()
				gt6.MCommonMatchManage:showContinueMatch()
				if (gt6.MCommonMatchManage:GetMatchingStatus() ) { // 已经开始比赛
					gt6.MCommonMatchManage:removeWaitTips()
				}
			}else{
				print("//->斗地主 结算 new  2333333")
				var playerSeatIdx = self.playerSeatIdx
				gt6.dispatchEvent("msg_MatchRewardLayer",playerSeatIdx)
			}
		}else{
				   		roundReport:setName("roundReport")
			self:addChild(roundReport, gt6.CommonConst.ZOrder.ROUND_REPORT)
		}

        self.mZhuangPos = nil
	})
	
	var seqAction = cc.Sequence:create(delayTime, callFunc)
	self:runAction(seqAction)
}

//总结算
PokerScene.prototype.onRcvFinalReport=function(msgTbl){
	// 在这儿输出 得到的是正确的
	gt6.log("总结算界面提示")
	if (gt6.isMatch ) { 
		print("////> 当前在比赛轮间") 
		return 
	}
	self:setStatus(gt6.CommonConst.ROOM_STATUS.FINAL_END)

	var delayTime = cc.DelayTime:create(1.2)
	var callFunc = cc.CallFunc:create(function(sender){
		// 弹出总结算界面
		var roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
				self:addChild(finalReport, gt6.CommonConst.ZOrder.VOICE_NODE)	
	})
	var seqAction = cc.Sequence:create(delayTime, callFunc)
	self:runAction(seqAction)
}

PokerScene.prototype.onRcvStartGame=function(msgTbl){
	if (! tolua.isnull(self.mAlarmClockLayer) ) {
		self.mAlarmClockLayer:stopCountDown()
	}

	self:setStatus(gt6.CommonConst.ROOM_STATUS.SEND_CARD)
	//同步room
	self:syncRoom(msgTbl)

	//清理记牌器
	if (! tolua.isnull(self.PokerMemoryLayer) ) {
		self.PokerMemoryLayer:clear()
	}
	//播放开牌
	self:playSendPoker(msgTbl)
	gt6.PlayersManager:hideAllDecisionOperTips() //隐藏所有决策提示
}


PokerScene.prototype.onRcvSyncRoomState=function(msgTbl){
	//同步room
	self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)

	self:syncRoom(msgTbl)
	if (! tolua.isnull(self.PokerMemoryLayer) ) { //断线，同步上下家牌
		self.PokerMemoryLayer:syncStyle( msgTbl )
	}
}


PokerScene.prototype.onRcvASKDIZHU=function(msgTbl){
	// body
	dump(msgTbl,"onRcvASKDIZHU====")
	self.deciBtnsCtrlInfo = msgTbl

	self.doingAskIndex = msgTbl.m_pos

	if (self.status === gt6.CommonConst.ROOM_STATUS.SEND_CARD
	|| self.mIsInTrusteeship ) {
		return
	}

	self:updateDecisionBtns()
}

//此协议服务器会算好当前倍数 且 difen为倍数
PokerScene.prototype.onRcvANSDIZHU=function(msgTbl){

	if (msgTbl.m_difen <= 0 ) { //这个倍数，起码是1
		self.curMultiple = 1
	}else{
		self.curMultiple = msgTbl.m_difen
	}

	if (self.mGameStyle === gt6.CommonConst.GameType.WUPIZI 
		|| self.mGameStyle === gt6.CommonConst.GameType.DAIPIZI ) {
		self.curMultiple = msgTbl.m_nUserBeishu[self.playerSeatIdx]
	}
	self.Txt_Times:setString(self.curMultiple)
}

PokerScene.prototype.onRcvWHOISDIZHU=function(msgTbl){
	gt6.PlayersManager:hideAllDecisionOperTips() //隐藏所有决策提示
	// dump("onRcvWHOISDIZHU",msgTbl)
	var seatIdx = msgTbl.m_pos + 1
	self.mZhuangPos = seatIdx
	self.doingAskIndex = nil 

	if (msgTbl.m_difen && msgTbl.m_difen~=0 ) {
		self.curMultiple = msgTbl.m_difen
		if (self.Txt_Times ) {
			self.Txt_Times:setString(self.curMultiple)
			gt6.log("PokerScene onRcvASKDIZHU Txt_Times " .. msgTbl.m_difen)
		}
	}
	
	// 插牌
	if (seatIdx === self.playerSeatIdx ) {
		for k, v in ipairs(msgTbl.m_LeftCard) do
			self:addMjTileToPlayer(v)
		}
	}

	// self:showLastHandPoker(msgTbl.m_LeftCard,false)
	if (! tolua.isnull(self.bottomCard ) ) {
		self.bottomCard:showLastHandPoker(msgTbl.m_LeftCard,false)
	}
	
	if (seatIdx === self.playerSeatIdx ) { //自己抢到地主
		self:addLastPokerAni(msgTbl)
	} else { // 别人抢到地主
		self:addLastPokerNum(seatIdx)

		self:refreshRivalPoker(seatIdx)//二人时要刷新对手的牌
	}

	 //确认某人是地主后 要把明牌翻回去
  	self:hideOpponentOpenPoker()

	var room_player = gt6.PlayersManager:getRoomPlayersBySeat(self.mZhuangPos)
	self:showIdentity(room_player)
}

PokerScene.prototype.onRcvSHOWCARDS=function(msgTbl){
	// body
	var seatIdx = msgTbl.m_pos + 1
	if (seatIdx === self.playerSeatIdx ) {
		if (msgTbl.m_MyCard ) {
			for _, v in ipairs(msgTbl.m_MyCard) do
				self:addMjTileToPlayer(v)
			}
		    // 根据花色大小排序并重新放置位置
			self:sortFinalPlayerMjTiles()

			var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
			roomPlayer.removeUselessTiles()
		}	
	}
}
////-协议解析//////////}//////////-

//单局结算翻倍更新
PokerScene.prototype.fanBeiOnRcvRoundReport=function( msgTbl ){
	if (! msgTbl ) { return }
	if (! msgTbl.m_chuntian ) { return }

	if (! self.mMaxFanShu ) { 
		return 
	} 

	for i,v in ipairs(msgTbl.m_chuntian) do
		if (v === gt6.CommonConst.PokerReportType.Spring || v === gt6.CommonConst.PokerReportType.BackSpring ) {
			if (self.mGameStyle === gt6.CommonConst.GameType.DAIPIZI  ) {
				self:countFanMultiple()
			
				// 反春天
				if (self.mZhuangPos != i ) {
					self:countFanMultiple()
				}
			}else{
				self:countNormlMultiple()
			}
			break
		}
	}

	self:updateMultipleUi(self.curMultiple)
}

//清除底牌和癞子
PokerScene.prototype.clearLastHand=function(){
	if (! tolua.isnull(self.bottomCard) ) {
		self.bottomCard:clearLastHand()
		self.bottomCard:setVisible(false)
	}

	if (! tolua.isnull(self.mFakeLayer) ) {
		self.mFakeLayer:setFakeVisible(false)
	}
}


//////////解析动作////////////start////////
PokerScene.prototype.doAction=function(realId,data,action){
	realId = tonumber(realId)

	if (realId === gt6.CommonConst.PlayAction.ADD_TABLE_POKER ) {  //添加出的牌
		self:doAddOutPoker(data)

	} else if (realId === gt6.CommonConst.PlayAction.REMOVE_HOLD_POKER ) {  //移除手里的牌
		self:doRemoveHandPoker(data,action)

	} else if (realId === gt6.CommonConst.PlayAction.PLAY_POKER_SPEAK ) {  //播放出牌语音
		self:doPokerSpeak(data,action)

	} else if (realId === gt6.CommonConst.PlayAction.PLAY_POKER_EFFECT ) {  //播放牌型效果
		self:doPokerEffect(data,action)

	} else if (realId === gt6.CommonConst.PlayAction.PLAY_HEAD_EFFECT ) { //播放头像效果
		self:doOperEffect(data,action)

	} else if (realId === gt6.CommonConst.PlayAction.PLAY_BOMB_EFFECT ) { //炸弹效果
		self:doBombAni(data,action)

	} else if (realId === gt6.CommonConst.PlayAction.PLAY_COUNTMULTIPLE ) { //计算倍数
		self:doCountMul(data,action)
	} else if (realId === gt6.CommonConst.PlayAction.PLAY_GETBOTTOMCARD ) { //地主拿牌 重播使用
		self:doGetBottomCard(data,action)
	} else if (realId === gt6.CommonConst.PlayAction.PLAY_AGAINDEAL ) { //没人抢地主，重新发牌
		self:doAgainDeal(data,action)
	} else if (realId === gt6.CommonConst.PlayAction.PLAY_DEALLAIZI ) { //发癞子牌
		self:doDealLaiZi(data,action)
	}
}

PokerScene.prototype.doAddOutPoker=function(data){
	var card = data.card
	if (! card ) {
		return
	} 

	dump(card,"card====")
	for k,v in ipairs(card) do
		self:addAlreadyOutMjTiles(data.seatIdx, v, #card,data.laiZi)
	}
}

//移除手牌
PokerScene.prototype.doRemoveHandPoker=function(data,action){
	print("chupai...")
	dump(data)
	var seatIdx = data.seatIdx
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)

	var flag = data.flag
	var card = data.card

	card = self:checkLaziPosAndIdx(card, data.type, data.laiZi)//带癞子 重新排序出的牌 子函数实现 

	if (seatIdx === self.playerSeatIdx ) {
		for i,v in ipairs(card) do
			for j=1, #roomPlayer.holdMjTiles do
				if (roomPlayer.holdMjTiles[j].mjIndex === v ) {
					//删除
					roomPlayer.holdMjTiles[j].mjTileSpr:removeFromParent()
					table.remove(roomPlayer.holdMjTiles, j)
					break
				}
			}
		}

		// 根据花色大小排序并重新放置位置x
		if (flag != gt6.CommonConst.OutPokerType.BUYAO ) {
			self:sortPlayerMjTiles(self.playerSeatIdx)
		}

		//二人时要时时刷新自己还有几张获胜
		if (self.playerSeatIdx != self.mZhuangPos ) {
			// var cardNum = #card
			self:updateWinPokerNum(roomPlayer)
		}
	}else{
		if (self.show_opponent_poker_back_flag ) {
			var poker_total = #roomPlayer.holdMjTiles
			print("poker_total==="..tostring(poker_total))

			for i,v in ipairs(card) do
				var pokerTitle = roomPlayer.holdMjTiles[poker_total]
				if (pokerTitle ) {
					pokerTitle.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.holdMjTiles, poker_total)
					poker_total = poker_total - 1
				}
			}

			self:sortPlayerMjTiles(seatIdx)
		}
	}
}

//播放头像效果
PokerScene.prototype.doOperEffect=function(data,action){
	if (data.flag === gt6.CommonConst.OutPokerType.BUYAO ) {
		return
	}
	//逻辑座位号
	var seatIdx = data.seatIdx
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)

	xpcall(function(){
		if (seatIdx != self.playerSeatIdx ) {
			var desArray = { 309, 310, 311, 312, 313,314, 315,316, 317}
			var isShowTips = true
			for key, value in ipairs(desArray) do
				if (value === tonumber( action.id ) ) {
					isShowTips = false
				}
			}

			var res_plist = gt6.getGameTypeRes().."play_scene.plist"
			if (isShowTips ) {
				roomPlayer:showOperTips(action.pic,res_plist)
			}else{
				roomPlayer:showDecisionOperTips(action.pic,res_plist)
			}
	  	}

		var sound = action.sound
		if (sound ) {
			
			var sound_name = (roomPlayer.sex === 1) && string.format("man/%s",sound) || string.format("man/%s",sound)
			gt6.soundEngine:playEffect(sound_name,false,"2POKER")
		}
	},

	function(){
		gt6.log("-playOperEffect//pic error || sound error//")
	})
}

PokerScene.prototype.doPokerSpeak=function(data,action){
	gt6.log("playecard is here ") 
	var seatIdx = data.seatIdx
	var card = data.card 
	var flag = data.flag
	var soundName = action.sound 
	var sound = nil 
	var num = math.random(1,3)

	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	var sound_path = self:getSoundPath(roomPlayer.sex)
	sound = sound_path..soundName

	if (card ) {
		var value , color = GamePlayUtils.changePk(card[1])
		if (self.mLaiziValue ) {
			if (tonumber(data.action) === gt6.CommonConst.CardType.card_style_double ) {
				var value1 , color1 = GamePlayUtils.changePk(card[1])
				var value2 , color2 = GamePlayUtils.changePk(card[2])
				if (self.mLaiziValue === value1 && self.mLaiziValue === value2 ) {
					value = value1
				} else if (self.mLaiziValue === value1 && self.mLaiziValue != value2 ) {
					value = value2
				} else if (self.mLaiziValue != value1 && self.mLaiziValue === value2 ) {
					value = value1
				}else{
					value = value1
				}
			}
		}

		var speak_type = action.poker_sound_type
		var poker_special_sound = action.poker_special_sound

		//是否需要播放大你的开关条件
		if (poker_special_sound === "dani" ) {
			if (flag === gt6.CommonConst.OutPokerType.OUT ) {
				//播放大你
				sound = sound_path..poker_special_sound..num
			} else if (flag === gt6.CommonConst.OutPokerType.FIRST_OUT ) {
				//all 代表全花色
				if (speak_type === "all" ) {
					sound = sound_path..soundName..value
				}
			}
		}else{
			if (speak_type === "all" ) {
				sound = sound_path..soundName..value
			}
		}
	}

	gt6.log("playecard is here===="..tostring(sound))
	gt6.soundEngine:playEffect(sound,false,"2POKER")
	gt6.soundEngine:playEffect("common/Special_give", false, "2POKER")
}

PokerScene.prototype.doPokerEffect=function(data,action){
	xpcall(function(){
		var realSeat = data.realSeat
		
		gt6.log("realSeat//-"..tostring(realSeat))

		var mjTilesReferPos = self:animationPlayerMjTilesReferPos(realSeat)

	  	var sound = action.sound
		if (sound ) {
			var sound_name = string.format("common/%s",sound)
			gt6.soundEngine:playEffect(sound_name,false,"2POKER")
		}

	
	    //动画列表
		var ani_list = action.ani_list
		//动画位置类型列表
		var ani_pos_type_list = action.ani_pos_type_list
		if (ani_list && ani_pos_type_list ) {
			var count = #ani_list
			for i = 1, count do
				var x = mjTilesReferPos.outStart.x
				var y = mjTilesReferPos.outStart.y

				GamePlayUtils.playAnimation(self.rootNode,ani_list[i],ani_pos_type_list[i],x,y)
			}
		}
	},

	function(error){
		gt6.log("-playOperEffect//pic error || sound error//"..error)
	})
}

//执行炸弹效果
PokerScene.prototype.doBombAni=function(data,action){
	gt6.soundEngine:playEffect("common/Special_Bomb_New", false, "2POKER")
	if (data.realSeat === 1 ) {
		var sprite = GamePlayUtils.playAnimation(self.rootNode,"baozharight")
	} else if (data.realSeat === 2 ) {
		var sprite = GamePlayUtils.playAnimation(self.rootNode,"baozhaleft")
	} else if (data.realSeat === 3 ) {
		var sprite = GamePlayUtils.playAnimation(self.rootNode,"baozhafront")
	}
}

//计算倍数
PokerScene.prototype.doCountMul=function(data,action){	
	//目前这个参数代表 不存在算炸弹
	if (! self.mMaxFanShu ) { 
		return 
	} 

	if (! self.isReplay ) {
		var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(data.seatIdx)
		roomPlayer:addBoomCount()

		self:countNormlMultiple()
		self:updateMultipleUi(self.curMultiple)
	}
	
}

PokerScene.prototype.doLoveDays=function(data,action){
	//播放情人节动画
	// var mjTilesReferPos = self:animationPlayerMjTilesReferPos(1)
	// // var sprite = self:playAnimation("valentinesday1",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	// if (msgTbl.m_nLoverDaysType === 0 ) {
	// 	var sprite = self:playAnimation("valentinesday1",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	// } else if (msgTbl.m_nLoverDaysType === 1 ) {
	// 	var sprite = self:playAnimation("valentinesday2",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	// } else if (msgTbl.m_nLoverDaysType === 2 ) {
	// 	var sprite = self:playAnimation("valentinesday3",16,mjTilesReferPos.zhadan.x,mjTilesReferPos.zhadan.y)
	// }
}

//////////解析动作////////////}////////


PokerScene.prototype.initPokerTouch=function(){
	// 触摸事件
	var listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
	var eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.cards_layer)
}

PokerScene.prototype.onTouchBegan=function(touch, event){
	gt6.log("onTouchBegan states " .. self:getStatus())

	if (self.mIsInTrusteeship ) { //托管中 点击屏幕取消托管
		self:sendCancelTrusteeshipMsg()
		return false //如果托管中 不允许提牌等操作
	}

	if (! self:isBoardStart() ) {
		return false
	}

	//获取点击到了那一张牌和牌的位置（如果没有点击到牌就返回nil）
	var touchMjTile, mjTileIdx = self:touchPlayerMjTiles(touch:getLocation())

	if (! touchMjTile ) {
		print("touchMjTile nil ")
		//点击两次牌归原位
		var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		var curTimeStr = os.date("%X", os.time())
		var timeSections = string.split(curTimeStr, ":")
		var time = timeSections[3]
		if (time - self.time < 0.6 ) {
			for j=1, #roomPlayer.holdMjTiles do
				self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, true)
			}
			self.time = 0
			self.SelectCard = {}
		}else{
			self.time = time
			// 重置二义性选牌界面
			if (! tolua.isnull(self.mAmbiguityLayer) ) {
				self.mAmbiguityLayer:resetAmbiguity()
			}
		}
		return false
	}

	self.tempTouchPoker = {}	//本次触摸操作中点击到的牌（存储原因是为了防止二次触碰）
	self.chooseMjTile = touchMjTile //点击的牌
	self.chooseMjTileIdx = mjTileIdx //点击的牌在数组中的位置
	self.preTouchPoint = self.cards_layer:convertTouchToNodeSpace(touch) //点击到的坐标在牌空间内的坐标
	self.tempTouchPoker[#self.tempTouchPoker + 1] = self.chooseMjTileIdx //存储点击处理过的牌
	self.chooseMjTile.mjTileSpr:setColor(cc.c3b(200,200,200)) //改变点击牌的颜色
	return true
}

PokerScene.prototype.onTouchMoved=function(touch, event){
	if (! self:isBoardStart() ) {
		return 
	}

	//print("self.isTouch==="..tostring(self.isTouch))

	var moveTouchPoint = self.cards_layer:convertTouchToNodeSpace(touch)
	if (math.abs(moveTouchPoint.x - self.preTouchPoint.x) > 5 || math.abs(moveTouchPoint.y - self.preTouchPoint.y) > 5 ) {
		
		//获取点击到了那一张牌和牌的位置（如果没有点击到牌就返回nil）
		var touchPokerTile, pokerTileIdx = self:touchPlayerMjTiles(touch:getLocation())
		if (touchPokerTile && touchPokerTile.mjIsTouch ) {
			self.tempTouchPoker = {};
			var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
			var startIndex = 0
			var endIndex = 0
			if (self.chooseMjTileIdx <= pokerTileIdx ) {
				startIndex = self.chooseMjTileIdx
				endIndex = pokerTileIdx
			}else{
				startIndex = pokerTileIdx
				endIndex = self.chooseMjTileIdx
			}

			for i = startIndex,endIndex do
				self.tempTouchPoker[#self.tempTouchPoker + 1] = i
				var hold_poker = roomPlayer.holdMjTiles[i]
				if (hold_poker && hold_poker.mjIsTouch ) {
					hold_poker.mjTileSpr:setColor(cc.c3b(200,200,200))
				}
				
			}

			for i = 1, startIndex-1 do
				var hold_poker = roomPlayer.holdMjTiles[i]
				if (hold_poker && hold_poker.mjIsTouch ) {
					hold_poker.mjTileSpr:setColor(cc.c3b(255,255,255))
				}
				
			}

			for i = endIndex+1, #roomPlayer.holdMjTiles do
				var hold_poker = roomPlayer.holdMjTiles[i]
				if (hold_poker && hold_poker.mjIsTouch ) {
					hold_poker.mjTileSpr:setColor(cc.c3b(255,255,255))
				}
				
			}
		}
	}	
}

PokerScene.prototype.onTouchEnded=function(touch, event){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	var holdMjTiles = roomPlayer.holdMjTiles
	if (! (holdMjTiles) || #holdMjTiles <= 0 ) {
		return
	}

	//检测临时牌和手牌是否一致
	if (self.tempTouchPoker ) {
		print("==dddd====ddd==")
		for i = #self.tempTouchPoker, 1, -1 do
			var index = self.tempTouchPoker[i]
			var pokerTile = holdMjTiles[index]
			if (! pokerTile || ! pokerTile.mjIsTouch ) {
				table.remove(self.tempTouchPoker,i)
			}
		}
	}	

	if (self.tempTouchPoker && #self.tempTouchPoker === 0 ) { return } //如果没有点击的牌

	if (self.curShowCardInfo && self.curShowCardInfo.m_curCardCount && self.curShowCardInfo.m_curCardCount > 0 ) { //上家出牌了
		require("app/gameType/2POKER/StyleMgr/StyleHelp_DDZ")
		// dump(self.tempTouchPoker, "self.tempTouchPoker 1")

		var is_have_up = false
		for j=1, #holdMjTiles do
			var pokerTile = holdMjTiles[j]
			if (pokerTile.mjIsUp ) {
				is_have_up = true
				break
			}
		}

		if (! is_have_up ) { //没有提起的牌
			var my_index_list = GamePlayUtils.getIndexListBySelect(self.tempTouchPoker, holdMjTiles)
			// dump(my_index_list, "my_index_list")
			var tip_pk_info_array = gt6.StyleHelp_DDZ:getInstance():slideAutoHint(self.curShowCardInfo, my_index_list)
			var need_tip_array = tip_pk_info_array[#tip_pk_info_array] || {}
			if (#need_tip_array > 0 ) { //提示出选中的牌
				self.tempTouchPoker = GamePlayUtils.getPkIdxByInfoArray(need_tip_array,  holdMjTiles)
				// dump(self.tempTouchPoker, "self.tempTouchPoker 2")
			}

			self:lowerAllPoker(holdMjTiles) //压下所有的牌 颜色恢复
			self:upSelectPoker( self.tempTouchPoker, holdMjTiles ) //提起选中牌
			self:addToSelectCard(self.tempTouchPoker) //插入select
		}else{

			if (1 === #self.tempTouchPoker ) { //点击单张牌 提起的压下，压下的提起
				gt6.log("点击单张牌 提起的压下，压下的提起")
				self:oppositeUpDown(self.tempTouchPoker, holdMjTiles )
			}else{
				//1.再次拉选时（拉选范围大于等于上升牌的范围），则上升牌全部落下，其他处于落下的牌保持落下状态不变
				//2.再次拉选时（拉选范围不包括上升牌的范围，即在上升牌的范围之外），则再次拉选的牌全部上升（即之前处于上升的牌和当前拉选牌全部处于上升状态，其他牌处于落下状态）		
				//3.部分包含，下的提上去，提上去的压下来

				var sortHoldIdxArray = function(array ){ //降序
					table.sort(array, function(a, b ){
						return a > b
					})
				}
				sortHoldIdxArray( self.SelectCard )
				sortHoldIdxArray( self.tempTouchPoker )
				dump(self.SelectCard , "self.SelectCard   0000")
				dump(self.tempTouchPoker , "self.tempTouchPoker   0000")
				if (self.tempTouchPoker[1] >= self.SelectCard[1] && 
					self.tempTouchPoker[#self.tempTouchPoker] <= self.SelectCard[#self.SelectCard] ) { //全都压下来
					gt6.log("全都下来")
					self:lowerAllPoker(holdMjTiles) //压下所有的牌 颜色恢复
					self.SelectCard = {}
				} else if (self.tempTouchPoker[1] < self.SelectCard[#self.SelectCard] ||  
					self.tempTouchPoker[#self.tempTouchPoker] > self.SelectCard[1] ) { //提起新选中的

					gt6.log("提起新选中的")
					self:upSelectPoker( self.tempTouchPoker, holdMjTiles ) //提起选中牌
					self:addToSelectCard(self.tempTouchPoker) //插入select

				} else { //提起的压下，压下的提起
					gt6.log("提起的压下，压下的提起")
					self:oppositeUpDown(self.tempTouchPoker, holdMjTiles )
				}
			}
		}

		//颜色恢复
		for j=1, #holdMjTiles do
			if (holdMjTiles[j].mjIsTouch ) {
				holdMjTiles[j].mjTileSpr:setColor(cc.c3b(255,255,255))
			}
		}

	}else{

		//根据开关判断是否算牌
		if (self.auto_calc_card_flag ) {
			function (tempTouchPoker, countValue , cardNum) {
				var tempPokerTiles = {}
				for i,v in ipairs(tempTouchPoker) do
					tempPokerTiles[i] = v
				}
				for i = #tempPokerTiles, 1, -1 do
					var pokerTile = roomPlayer.holdMjTiles[tempPokerTiles[i*/
					if (pokerTile ) {
						var value, color = GamePlayUtils.changePk(pokerTile.mjIndex)
						if (countValue[value] > cardNum ) {
							pokerTile.mjTileSpr:setColor(cc.c3b(255,255,255))
							table.remove(tempTouchPoker,i)
							countValue[value] = countValue[value] - 1
						}
					}
				}
			}
			var isStraight, straightCountValue = GamePlayUtils.isStraight(self.tempTouchPoker,holdMjTiles, self.room_config.shunZiBeginNum ) //单顺 
			var isDoubleStraight, doubleStrCountValue = GamePlayUtils.isDoubleStraight(self.tempTouchPoker,holdMjTiles, self.room_config.lianDuiBeginNum ) //双顺 self.room_config

			//根据开关判断是否有飞机
			if (self.check_airplane_flag ) {
			    //有飞机牌型
				var isAirplane = GamePlayUtils.isAirplane(self.tempTouchPoker,holdMjTiles)
				if (isStraight === true && isDoubleStraight === false && isAirplane === false ) {
					resetNormalCardByType(self.tempTouchPoker, straightCountValue, 1)
				} else if (isStraight === false && isDoubleStraight === true && isAirplane === false ) {
					resetNormalCardByType(self.tempTouchPoker, doubleStrCountValue, 2)
				}
			}else{
				//无飞机牌型
				if (isStraight === true && isDoubleStraight === false ) {
					//单顺，非双顺
					resetNormalCardByType(self.tempTouchPoker, straightCountValue, 1)
				} else if (isStraight === false && isDoubleStraight === true ) {
					//非单顺，双顺，没飞机
					resetNormalCardByType(self.tempTouchPoker, doubleStrCountValue, 2)
				}
			}
		}
		
		self:oppositeUpDown(self.tempTouchPoker, holdMjTiles ) //提牌
	}
	gt6.soundEngine:playEffect("common/SpecSelectCard", false, "2POKER")
}

PokerScene.prototype.oppositeUpDown=function( pokerIdxArray, holdMjTiles ){ //牌，提起的压下，压下的提起
	if (! pokerIdxArray || ! holdMjTiles ) { return }
	for i=1, #pokerIdxArray do
		var hold_poker = holdMjTiles[pokerIdxArray[i*/
		if (hold_poker ) {
			var result = self:touchPoker(hold_poker)
			if (hold_poker.mjIsTouch ) {
				hold_poker.mjTileSpr:setColor(cc.c3b(255,255,255))
			}
			self:updateSelectCard(result, pokerIdxArray[i])
		}
	}
}

PokerScene.prototype.lowerAllPoker=function( holdMjTiles ){ //压下所有的牌 颜色恢复
	if (! holdMjTiles ) { return }
	for j=1, #holdMjTiles do //压下所有的牌 颜色恢复
		var pokerTile = holdMjTiles[j]
		self:setPokerIsUp(pokerTile, false, false)
		if (pokerTile.mjIsTouch ) {
			pokerTile.mjTileSpr:setColor(cc.c3b(255,255,255))
		}
	}
}

PokerScene.prototype.upSelectPoker=function(pokerIdxArray, holdMjTiles ){ //根据手牌下标提起扑克
	if (! pokerIdxArray || ! holdMjTiles ) { return }
	for k, v in ipairs( pokerIdxArray ) do //提起选中牌
		var pkTile = holdMjTiles[v]
		if (pkTile ) {
			self:setPokerIsUp(pkTile, true, true)
		}
	}	
}

PokerScene.prototype.addToSelectCard=function( pokerIdxArray ){ //把手牌下标数组插入SelectCard中
	if (! pokerIdxArray ) { return }
	for k, mjTileIdx in ipairs( pokerIdxArray ) do //插入select
		var isTocuhPoker = false
		for i=1, #self.SelectCard do
			if (mjTileIdx === self.SelectCard[i] ) {
				isTocuhPoker = true
				break;
			}
		}
		if (! isTocuhPoker ) {
			table.insert(self.SelectCard, mjTileIdx)
		}
	}	
}

//执行不要动作
PokerScene.prototype.buYaoAction=function(seatIdx){
	
	//自己不要的时候是要马上回复颜色的 策划需求
	// if (seatIdx === self.playerSeatIdx ) {
	// 	if (roomPlayer && roomPlayer.holdMjTiles ) {
	// 		for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
	// 			pkTile.mjTileSpr:setColor(cc.c3b(255,255,255))
	// 			pkTile.mjIsTouch = true
	// 		}
	// 	}
	// }

	var num = math.random(1,4)
	var sound = "man/buyao" .. num
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	var ispre = ispre || false
	if (roomPlayer.sex === 1 ) {
		sound = "man/buyao" .. num
	}else{
		sound = "woman/buyao" .. num
	}
	
	gt6.soundEngine:playEffect(sound,false,"2POKER")
	
	if (seatIdx != self.playerSeatIdx ) {
	  	roomPlayer:showOperTips("gt6_ddz_play_buchu.png")
	}
}

PokerScene.prototype.refreshOutPokers=function(seatIdx){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	// 重新排列打出去的牌
	if (self.re_sort_out_poker_flag ) {
		gt6.LaiZiUtils.laiziSort(roomPlayer.outMjTiles)
	}

	if (seatIdx === self.playerSeatIdx ) {
		self:singleLineOutPoker(roomPlayer)
	}else{
		if (self.playMaxNum === 2 ) {
			self:singleLineOutPoker(roomPlayer)
		}else{
			self:multiLineOutPoker(roomPlayer)
		}
		
	} 
}

//Single line
PokerScene.prototype.singleLineOutPoker=function(roomPlayer){

	var tileWidth = 102
	var totalWidth = tileWidth + (#roomPlayer.outMjTiles - 1) * 56
	// 计算牌的起始位置
	var startX = (gt6.winSize.width - totalWidth) / 2 + tileWidth / 2
	for k, pkTile in ipairs(roomPlayer.outMjTiles) do
		var posX = startX + (k - 1) * 56
		var mjTilesReferPos = roomPlayer.mjTilesReferPos
		var mjTilePos = mjTilesReferPos.outStart
		pkTile.mjTileSpr:setPosition(cc.p(posX, mjTilePos.y))
		self.cards_layer:reorderChild(pkTile.mjTileSpr, posX + 300)
	}
}

PokerScene.prototype.multiLineOutPoker=function(roomPlayer){
	for k, pkTile in ipairs(roomPlayer.outMjTiles) do
		var mjTilesReferPos = roomPlayer.mjTilesReferPos
		var mjTilePos = mjTilesReferPos.outStart
		var lineCount = math.ceil(k / 8) - 1
		var lineIdx = k - lineCount * 8 - 1
		mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
		mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
		pkTile.mjTileSpr:setPosition(mjTilePos.x,mjTilePos.y)
		var mjZorder = mjTilePos.x
		if (k > 8 ) {
			mjZorder = mjTilePos.x + 200
		}
		self.cards_layer:reorderChild(pkTile.mjTileSpr,mjZorder)
		gt6.log("LineCount:"..lineCount  .. "mjZorder:".. mjZorder..  "k:" .. k)
		// if (roomPlayer.displaySeatIdx === 2 && lineCount === 1 ) {
		// 	pkTile.mjTileSpr:setZOrder(10)
		// }
	}
}

//提牌
PokerScene.prototype.touchPoker=function(poker){
	print("poker.mjIsTouch=="..tostring(poker.mjIsTouch))
	if (poker.mjIsTouch ) {
		if (poker.mjIsUp ) {
			self:setPokerIsUp(poker, false, true)
			return false
		}else{
			self:setPokerIsUp(poker, true, true)
			return true
		}
	}
}

PokerScene.prototype.setPokerIsUp=function( poker, isUp, action){
	poker.mjTileSpr:stopAllActions()
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	var mjTilesReferPos = roomPlayer.mjTilesReferPos
	var _mjTilePos = mjTilesReferPos.holdStart
	var mjTilePos = cc.p(poker.mjTileSpr:getPosition())

	var offest = 0

	print("poker.mjIsUp ==="..tostring(poker.mjIsUp))
	print("poker.mjIsUp ==="..tostring(isUp))
	if (poker.mjIsUp != isUp ) {
		if (! poker.mjIsUp ) {
			offest = 26
		}

		poker.mjTileSpr:setPosition(cc.p(mjTilePos.x, _mjTilePos.y + offest))
		poker.mjIsUp = isUp;
	}
}


PokerScene.prototype.touchPlayerMjTiles=function(touch){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)

	if (! roomPlayer.holdMjTiles ) {
		return nil
	}

	for i=#roomPlayer.holdMjTiles, 1, -1  do
		var mjTile = roomPlayer.holdMjTiles[i];
		var touchPoint = mjTile.mjTileSpr:convertToNodeSpace(touch)
		var mjTileSize = mjTile.mjTileSpr:getContentSize()

		var mjTileRect = cc.rect(0, 0, mjTileSize.width, mjTileSize.height)
		if (cc.rectContainsPoint(mjTileRect, touchPoint) ) {
			return mjTile, i
		}
	}
	return nil
}

//操作牌相关////start//////////////////-
PokerScene.prototype.sortFinalPlayerMjTiles=function(){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	var mjTilesReferPos = roomPlayer.mjTilesReferPos
	// 计算牌开始的位置
	var cardNum = #roomPlayer.holdMjTiles // 当前手牌数量
	var mjTilePos = self:getHoldStartPoint(self.playerSeatIdx,cardNum)

	for k, mjTile in ipairs(roomPlayer.holdMjTiles) do
		mjTile.mjTileSpr:stopAllActions()
		mjTile.mjTileSpr:setVisible(false)
		mjTile.mjTileSpr:setPosition(mjTilePos.x,mjTilePos.y)
		self.cards_layer:reorderChild(mjTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	}

	var k = 1
	for i = #roomPlayer.holdMjTiles, 1 , -1 do	
		var mjTile = roomPlayer.holdMjTiles[i]
		var delayTime = cc.DelayTime:create(0.05*k)
		var callFunc = cc.CallFunc:create(function(sender){
			mjTile.mjTileSpr:setVisible(true)
		})
		var sequence = cc.Sequence:create(delayTime,callFunc)
		mjTile.mjTileSpr:runAction(sequence)
		k = k + 1
	}
}

PokerScene.prototype.sortAninationPlayerMjTiles=function(playerSeatIdx){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	var mjTilesReferPos = roomPlayer.mjTilesReferPos
	// 计算牌开始的位置
	var poker_list = roomPlayer.uselessTiles
	if (playerSeatIdx != self.playerSeatIdx ) {
		poker_list = roomPlayer.holdMjTiles
	}

	var cardNum = #poker_list // 当前手牌数量
	
	var mjTilePos = self:getHoldStartPoint(playerSeatIdx,cardNum)

	for k, mjTile in ipairs(poker_list) do
		mjTile.mjTileSpr:setPosition(2000,mjTilePos.y)
		var delayTime = cc.DelayTime:create(0.08*k)
		var moveTo = cc.MoveTo:create(0.1, cc.p(mjTilePos.x,mjTilePos.y))
		var sequence = cc.Sequence:create(delayTime,moveTo)
		mjTile.mjTileSpr:runAction(sequence)
		mjTile.mjTileSpr:setVisible(true)
		self.cards_layer:reorderChild(mjTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	}
}

PokerScene.prototype.sortPlayerMjTiles=function(playerSeatIdx){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	var mjTilesReferPos = roomPlayer.mjTilesReferPos
	// 计算牌开始的位置
	var cardNum = #roomPlayer.holdMjTiles // 当前手牌数量
	// 计算所有牌总宽度
	var mjTilePos = self:getHoldStartPoint(playerSeatIdx,cardNum)

	dump(mjTilePos,"mjTilePos===")
	for k, mjTile in ipairs(roomPlayer.holdMjTiles) do
		mjTile.mjTileSpr:stopAllActions()
		mjTile.mjTileSpr:setVisible(true)
		mjTile.mjTileSpr:setPosition(mjTilePos.x,mjTilePos.y)
		self.cards_layer:reorderChild(mjTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	}
}

////////////////////////////////
// @class function
// @description 获取手牌的启示位置
// @param playerSeatIdx 座位号
// @param cardNum 牌的数量
// } //

PokerScene.prototype.getHoldStartPoint=function(playerSeatIdx,cardNum){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	var mjTilesReferPos = roomPlayer.mjTilesReferPos

	var totalWidth = self:getPokerTotalWidth(playerSeatIdx)
	var space = (totalWidth - tileWidth) / (cardNum - 1)
	if (space > tileWidth / 2 ) {
		mjTilesReferPos.holdSpace.x = tileWidth / 2 - 3
		totalWidth = tileWidth + (cardNum - 1) * mjTilesReferPos.holdSpace.x
	}else{
		mjTilesReferPos.holdSpace.x = space

	}
	
	var mjTilePos = mjTilesReferPos.holdStart
	var startX = (gt6.winSize.width - totalWidth) / 2 + tileWidth / 2
	mjTilePos.x = startX

	return mjTilePos
}

//操作牌相关////}//////////////////-

//其他人如果要显示手牌宽度不一样 很多地方都在写 所以封装一个函数
PokerScene.prototype.getPokerTotalWidth=function(playerSeatIdx){
	// body
	var totalWidth = 1240
	if (playerSeatIdx != self.playerSeatIdx ) {
		totalWidth = 840
	}
	return totalWidth
}

PokerScene.prototype.getPokerWidth=function(playerSeatIdx){
	// body
	if (playerSeatIdx != self.playerSeatIdx ) {
		return other_tileWidth
	}
	return tileWidth
}

PokerScene.prototype.refreshHoldPokers=function(){
	var laiziValue = self.mLaiziValue
	var diZhuPos = self.mZhuangPos

	//播放插牌动画
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	var mjTilesReferPos = roomPlayer.mjTilesReferPos
	// 癞子牌
	var spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("gt6_splz_".. laiziValue ..".png")
	for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
		if (pkTile.mjIsLaizi ) {
			pkTile.mjTileSpr:setSpriteFrame(spriteFrame)
		}
	}
	// 对玩家手牌重新进行排序，癞子牌放到最前面
	table.sort(roomPlayer.holdMjTiles,function(a, b){
		if (a.mjIsLaizi && b.mjIsLaizi === false ) {
			return true
		} else if (a.mjIsLaizi === false && b.mjIsLaizi === false ) {
			return a.mjIndex > b.mjIndex
		}
		return false
	})
	
	// 计算牌开始的位置
	var cardNum = #roomPlayer.holdMjTiles // 当前手牌数量
	var mjTilePos = self:getHoldStartPoint(roomPlayer.seatIdx,cardNum)

	// 重新设置所有牌位置
	for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
		pkTile.mjTileSpr:stopAllActions()
		// 如果自己是地主，添加地主角标
		if (diZhuPos === self.playerSeatIdx ) {
			var cardIcon = nil
			if (self.dealer_info_config && self.dealer_info_config.cardIcon ) {
				cardIcon = self.dealer_info_config.cardIcon
			}
			
			if (cardIcon ) {
				var landLordIcon = cc.Sprite:createWithSpriteFrameName(cardIcon)
				if (landLordIcon ) {
					landLordIcon:setPosition(cc.p(landLordIcon:getContentSize().width/2, landLordIcon:getContentSize().height/2))
					pkTile.mjTileSpr:addChild(landLordIcon)
				}
			}
		}
		
		pkTile.mjTileSpr:setPosition(mjTilePos.x, mjTilePos.y)
		
		self.cards_layer:reorderChild(pkTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	}
}

//-出牌相关 start
PokerScene.prototype.addOppositeMjTileToPlayer=function(playerSeatIdx){
	var poker_list = {}
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(playerSeatIdx)
	if (playerSeatIdx != self.playerSeatIdx ) {
		poker_list = roomPlayer.holdMjTiles  
	}else{
		poker_list = roomPlayer.uselessTiles
	} 
	var pkTile = self.cards_layer:addCardBackToPlayer(poker_list)

	if (playerSeatIdx ~=self.playerSeatIdx ) {
		//不是自己的 这里的数组就是自己手牌了 现阶段来说 是改动最少的策略
		pkTile.mjTileSpr:setScale(0.63)
	} 

	return pkTile
}

////////////////////////////////
// @class function
// @description 给玩家发牌
// @param mjColor
// @param mjNumber
// } //
PokerScene.prototype.addMjTileToPlayer=function(msg){

	var card_info = {}
	//判断明牌
	if (self.open_poker_seat ~=-1 && self.open_poker_seat === self.playerSeatIdx ) {
		if (msg === self.open_poker_value ) {
			card_info.special_icon_name = "gt6_ddz_icon_ming.png"
			print("special_icon_name=="..tostring(special_icon_name))
		}
	}

	var pkTile = self.cards_layer:addCardToPlayer(msg,"gt6_sp%d_%d.png",card_info)

	//判断地主
	if (self.mZhuangPos === self.playerSeatIdx ) {
		self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD)
	}

	if (self.mIsInTrusteeship === true ) {
		pkTile.mjTileSpr:setColor(cc.c3b(200,200,200))
	}

	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	table.insert(roomPlayer.holdMjTiles, pkTile)
	return pkTile
}

////////////////////////////////
// @class function
// @description 显示已出牌
// @param seatIdx 座位号
// @param msg 协议给的牌型值(客户端会解析成花色和值)
// @param isself 计算位置用的
// } //

PokerScene.prototype.addAlreadyOutMjTiles=function(seatIdx, msg, isself,laizi){
	var value , color = GamePlayUtils.changePk(msg)
	var isLaizi = false
	
	//计算癞子
	var laiziCard = laizi
	self.laiTag = 1
	if (self.mLaiziValue === value ) {
		if (laiziCard && self.laiTag <= #laiziCard ) {
			var laiziValue = 0
			var v = laiziCard[self.laiTag]
			if (v <= 11 ) {
				laiziValue = v + 2
			}else{
				laiziValue = v - 11
			}
			value = laiziValue
			isLaizi = true
		}
		self.laiTag = self.laiTag+ 1
	}
	
	dump(laiziCard,"laiziCard====")

	var pkTileName = string.format("gt6_cp%d_%d.png",color, value)
	if (isLaizi ) {
		pkTileName = string.format("gt6_cplz_%d.png", value)
	}

	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	var card_info = {}
	card_info.color = color
	card_info.value = value
	card_info.isself = isself
	card_info.pkTileName  = pkTileName
	card_info.pkTilesReferPos = roomPlayer.mjTilesReferPos
	card_info.mul = #roomPlayer.outMjTiles

	var pkTile = self.cards_layer:addAlreadyOutCard(card_info)

	table.insert(roomPlayer.outMjTiles, pkTile)

	// 如果自己是地主，添加地主角标
	if (self.mZhuangPos === seatIdx ) {
		self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.OUT_CARD)
	}
	
}

PokerScene.prototype.addAlreadyOutMjTilesFinally=function(seatIdx, msg, num){
	//只显示别人的
	if (seatIdx === self.playerSeatIdx ) { 
		return
	}

	var value , color = GamePlayUtils.changePk(msg)
	var isLaizi = false
	if (self.mLaiziValue === value ) {
		isLaizi = true
	}
	// var pkTileName = string.format("sp%d_%d.png",color, value)
	var pkTileName = string.format("gt6_sp%d_%d.png",color, value)
	if (isLaizi ) {
		pkTileName = string.format("gt6_splz_%d.png", value)
	}

	// 添加到已出牌列表zy
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	var card_info = {}
	card_info.color = color
	card_info.value = value
	card_info.pkTileName  = pkTileName
	card_info.pkTilesReferPos = roomPlayer.mjTilesReferPos
	card_info.outPkCount = #roomPlayer.outMjTiles + 1
	card_info.num = num 
	if (roomPlayer.displaySeatIdx > 1 ) {
		card_info.move_x = 10
	}else{
		card_info.move_x = -10
	}

	card_info.start_x = 0
	card_info.start_offestx = 0

	//根据出牌数量决定其实位置偏移
	if (seatIdx != self.playerSeatIdx ) { 
		//二人位置有变化 之后应该把相关算法进行封装
		if (self.playMaxNum != 2  ) {
			if (num > 8 && num <= 16 ) {
				card_info.start_offestx = 100
			} else if (num > 16 ) {
				card_info.start_offestx = 200
			}				
		}
	}

	if (self.playMaxNum === 2 ) {
		card_info.is_change_line = true 
		card_info.start_x = self:getPokerTotalWidth(seatIdx)
	}

	var pkTile = self.cards_layer:addOutCardFinally(card_info)
	table.insert(roomPlayer.outMjTiles, pkTile)

	// 如果自己是地主，添加地主角标
	if (self.mZhuangPos === seatIdx ) {
		self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD)
	}
}

////////////////////////////////
// @class function

// @param msgTbl 是否断线重连
// @param roomPlayer 地主位置
// } //
PokerScene.prototype.createOpponentPokers=function(is_reccent,msgTbl,roomPlayer){
	if (! self.show_opponent_poker_back_flag ) {
		return				
	}

	self.open_poker_index = 0
	var num = roomPlayer.leftCardsNum
	if (self.open_poker_seat ~=-1 && self.open_poker_seat != self.playerSeatIdx ) {
		math.randomseed(os.time())
		self.open_poker_index = math.random(1,num)
	}

	var value, color = GamePlayUtils.changePk(self.open_poker_value)
	
	for i = 1, num do
		var pkTileName = "gt6_sp.png"
		if (self.open_poker_index === i ) {
			pkTileName = string.format("gt6_sp%d_%d.png",color, value)
		}
		
		var pkTileSpr = cc.Sprite:createWithSpriteFrameName(pkTileName)
		pkTileSpr:setScale(0.63)
		pkTileSpr:setName(string.format("OpponentHandPoker_%d",i))
		self.cards_layer:addChild(pkTileSpr)
		
		var pkTile = {}
		pkTile.mjTileSpr = pkTileSpr
		pkTile.mjColor = 4
		pkTile.mjNumber = 0
		pkTile.mjIndex = 0
		pkTile.mjIsUp = false
		table.insert(roomPlayer.holdMjTiles, pkTile)
	}

	//不是断线重连有动画
	if (! is_reccent ) {
		self:sortAninationPlayerMjTiles(roomPlayer.seatIdx)
	}else{
		//self:sortPlayerMjTiles(roomPlayer.seatIdx) 
		self:sortPlayerMjTiles(roomPlayer.seatIdx)
	} 
}

//出牌占位点 start//////////////////////////////////
PokerScene.prototype.animationPlayerMjTilesReferPos=function(displaySeatIdx){
	var mjTilesReferPos = {}
	var mjTilesReferNode = gt6.seekNodeByName(self.rootNode, "Node_playerMjTiles_" .. displaySeatIdx)
	// 打出牌数据
	var mjTileOutSprF = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_1")
	var mjTileOutSprS = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_2")
	mjTilesReferPos.outStart = cc.p(mjTileOutSprF:getParent():convertToWorldSpace(cc.p(mjTileOutSprS:getPosition())))
	mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprS:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	return mjTilesReferPos
}

////////////////////////////////
// @class function
// @description 设置玩家麻将基础参考位置
// @param displaySeatIdx 显示座位编号
// @return 玩家麻将基础参考位置
// } //
PokerScene.prototype.setPlayerMjTilesReferPos=function(displaySeatIdx){
	var mjTilesReferPos = {}
	print("displaySeatIdx==="..tostring(displaySeatIdx))
	var mjTilesReferNode = gt6.seekNodeByName(self.rootNode, "Node_playerMjTiles_" .. displaySeatIdx)
	if (displaySeatIdx === self.playMaxNum ) {
		var holdReferNode = gt6.seekNodeByName(self.rootNode,"Node_playerHold")
		// 持有牌数据
		var mjTileHoldSprF = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_1")
		var mjTileHoldSprS = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_2")
		mjTilesReferPos.holdStart = cc.p(mjTileHoldSprF:getParent():convertToWorldSpace(cc.p(mjTileHoldSprF:getPosition())))
		mjTilesReferPos.holdSpace = cc.pSub(cc.p(mjTileHoldSprS:getPosition()), cc.p(mjTileHoldSprF:getPosition()))
	}else{
		var holdReferNode = gt6.seekNodeByName(self.rootNode,"Node_playerHold_other")
		//有则为二人玩法 这里不做过多类型判断 尽量隐藏
		if (holdReferNode ) {
			var mjTileHoldSprF = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_1")
			var mjTileHoldSprS = gt6.seekNodeByName(holdReferNode, "Spr_mjTileHold_2")
			mjTilesReferPos.holdStart = cc.p(mjTileHoldSprF:getParent():convertToWorldSpace(cc.p(mjTileHoldSprF:getPosition())))
			mjTilesReferPos.holdSpace = cc.pSub(cc.p(mjTileHoldSprS:getPosition()), cc.p(mjTileHoldSprF:getPosition()))
		}
	}

	// 打出牌数据
	var mjTileOutSprF = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_1")
	var mjTileOutSprS = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_2")
	var mjTileOutSprT = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileShow_3")
	mjTilesReferPos.outStart = cc.p(mjTileOutSprF:getParent():convertToWorldSpace(cc.p(mjTileOutSprF:getPosition())))
	mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprS:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	mjTilesReferPos.outSpaceV = cc.pSub(cc.p(mjTileOutSprT:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	return mjTilesReferPos
}
//出牌占位点 }//////////////////////////////////

//处理癞子
PokerScene.prototype.processFake=function( msgTbl ){
	self.mLaiziValue = msgTbl.m_playerOper
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) //self.roomPlayers[self.playerSeatIdx]

	for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
		if (pkTile.mjNumber === self.mLaiziValue ) {
			pkTile.mjIsLaizi = true
		}
	}
	// 播放癞子展现动画
	// gt6.LaiZiUtils.playLaiziAppearAnim(self.mLaiziValue,true, self.mLaiziValue, self.rootNode, self.LaiHandsNode)

	if (! tolua.isnull(self.mFakeLayer) ) {
		self.mFakeLayer:playLaiziAppearAnim(self.mLaiziValue,true, self.mLaiziValue)
	}

	print("self.mZhuangPos=="..tostring(self.mZhuangPos).."==self.playerSeatIdx=="..tostring(self.playerSeatIdx))
	if (self.mZhuangPos === self.playerSeatIdx ) {
		//延迟显示插牌动画
		var action = cc.Sequence:create(cc.DelayTime:create(laizi_ani_time),cc.CallFunc:create(function(){
			self:refreshHoldPokers()
		}))
		self:runAction(action)
	}else{
		self:refreshHoldPokers()
		
	}
}


//////////////////关于剩余牌的操作////////////////-start//////////
PokerScene.prototype.initLeftCardNum=function(msgTbl,roomPlayer){
	if (msgTbl.m_cardNum ) {
		roomPlayer.leftCardsNum = msgTbl.m_cardNum[roomPlayer.seatIdx]
	}else{
		if (self.room_config ) {
			roomPlayer.leftCardsNum = self.room_config.max_hand_num || 17
		}else{
			roomPlayer.leftCardsNum = 17
		}
	}
}

//手牌加上数量底牌
PokerScene.prototype.addLastPokerNum=function(seatIdx){
	var last_hand = 0
	if (self.room_config.last_hand ) {
		last_hand = self.room_config.last_hand
	}
	gt6.PlayersManager:addLastPokerNumBySeat(seatIdx, last_hand)
}

//添加几张底牌动作
PokerScene.prototype.addLastPokerAni=function(msgTbl){
	
	// GamePlayUtils.stopActionByTag(self,action_tag.send_poker_tag)
	// self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)

	//播放插牌动画
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	roomPlayer:removeUselessTiles()

	var mjTilesReferPos = roomPlayer.mjTilesReferPos

	// 对玩家手牌重新进行排序
	if (self.room_config && self.room_config.sortType === "3max" ) {
		GamePlayUtils.sortHoldPoker3Max(roomPlayer.holdMjTiles)
	}else{
		GamePlayUtils.sortHoldPoker(roomPlayer.holdMjTiles)
	}
	
	var mjTilePos = self:getHoldStartPoint(self.playerSeatIdx,#roomPlayer.holdMjTiles)

	// 重新设置所有牌位置
	for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
		pkTile.mjTileSpr:stopAllActions()
		pkTile.mjTileSpr:setVisible(true)
		// 如果自己是地主，添加地主角标
		//self:checkLandlordFlag(pkTile,self.playerSeatIdx)
		if (self.playerSeatIdx === self.mZhuangPos ) {
			self:showCardFlag(pkTile.mjTileSpr,gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD)
		} 
		pkTile.mjTileSpr:setPosition(mjTilePos.x, mjTilePos.y)
		
		for i,v in ipairs(msgTbl.m_LeftCard) do
			if (pkTile.mjIndex === v ) {
				pkTile.mjTileSpr:setPositionY(mjTilePos.y + 80)
				pkTile.mjIsUp = true
				pkTile.mjTileSpr:runAction(cc.MoveBy:create(0.3, cc.p(0, -80)))
			}
		}
		self.cards_layer:reorderChild(pkTile.mjTileSpr, mjTilePos.x)
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	}
	var delayTime = cc.DelayTime:create(1)
	var callFunc = cc.CallFunc:create(function(sender){
		//众神归位
		for j=1, #roomPlayer.holdMjTiles do
			self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
		}
		self.SelectCard = {}
	})
	var sequence = cc.Sequence:create(delayTime,callFunc)
	self:runAction(sequence)

	self:showOpponentCheckPokers(true)//子类众实现
}
//////////////////关于剩余牌的操作////////////////-}//////////

//更新选择的牌
PokerScene.prototype.updateSelectCard=function( result, mjTileIdx ){
	var isTocuhPoker = false
	var index = 1
	for i=1, #self.SelectCard do
		if (mjTileIdx === self.SelectCard[i] ) {
			isTocuhPoker = true
			break;
		}
		index = index + 1
	}

	if (result ) {
		if (! isTocuhPoker ) {
			table.insert(self.SelectCard, mjTileIdx)
		}
	}else{
		if (isTocuhPoker ) {
			table.remove(self.SelectCard, index)
		}
	}
}

////////-出牌倒计时相关 start //////////////////////

//开启更新定时器
PokerScene.prototype.openUpdateSchedule=function(){
	if (! self.update_schedule  ) {
		self.update_schedule = gt6.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	}
}

//关闭更新定时器
PokerScene.prototype.closeUpdateSchedule=function(){
	if (self.update_schedule ) {
		gt6.scheduler:unscheduleScriptEntry(self.update_schedule)
		self.update_schedule = nil
	}
}

PokerScene.prototype.update=function(delta){
	// 更新倒计时
	self:playTimeCDUpdate(delta)
	self.common_ui_layer:update(delta)
}

////////-出牌倒计时相关 } //////////////////////
//计算delaer位置
PokerScene.prototype.setDelarPos=function(msgTbl){
		//////////////////////////////
	// ####### 由于修改协议后的恢复
	if (! msgTbl.m_zhuangPos ) {
		msgTbl.m_zhuangPos = msgTbl.m_hpos
	}

	//跑得快
	if (self.mGameStyle === gt6.CommonConst.GameType.FAKEPDK ||
		self.mGameStyle === gt6.CommonConst.GameType.CLASSICSPDK ) {
		msgTbl.m_zhuangPos = msgTbl.m_zhuang
	}
	//////////////////////////////

	// 庄家座位号
	var bankerSeatIdx = msgTbl.m_zhuangPos + 1
	self.mZhuangPos = bankerSeatIdx
}

PokerScene.prototype.stopCDAudio=function(){
	// 停止播放倒计时警告音效
	if (self.playCDAudioID ) {
		gt6.soundEngine:stopEffect(self.playCDAudioID)
		self.playCDAudioID = nil
	}
}

//自定义消息回掉//-start
PokerScene.prototype.sendReadyFunc=function(){
	var msgToSend = {}
	msgToSend.m_msgId = gt6.CG_READY
	// msgToSend.m_pos = self.playerSeatIdx - 1
	msgToSend.m_nReadyState = 1
	gt6.socketClient:sendMessage(msgToSend)
}
//自定义消息回掉//-}

PokerScene.prototype.disableCard=function(msgTbl,roomPlayer){
	if (! msgTbl.m_cardUnusable ) {
		return
	}

	if (self.have_laizi_flag ) {
		return
	}

	for i=1,#msgTbl.m_cardUnusable do
		for j=1,#roomPlayer.holdMjTiles do
			if (msgTbl.m_cardUnusable[i] === roomPlayer.holdMjTiles[j].mjIndex ) {
				roomPlayer.holdMjTiles[j].mjTileSpr:setColor(cc.c3b(200,200,200))
				roomPlayer.holdMjTiles[j].mjIsTouch = false
			}
		}
	}
}

PokerScene.prototype.tipPoker=function(roomPlayer){
	//该玩家出牌时自动提示玩家出牌
	var seatIdx = roomPlayer.seatIdx
	if (seatIdx === self.playerSeatIdx ) {
		self.SelectCard = {}
		var showCard = self.curShowMjTileInfo.m_array[self.promptIndex]
		if (showCard ) {
			for i,v in ipairs(showCard) do
				for j=1, #roomPlayer.holdMjTiles do
					if (roomPlayer.holdMjTiles[j].mjIndex === v ) {
						self.SelectCard[#self.SelectCard+1] = j
					}
				}
			}

			//众神归位
			for j=1, #roomPlayer.holdMjTiles do
				self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
			}
			//提起
			for j=1, #self.SelectCard do
				self:setPokerIsUp(roomPlayer.holdMjTiles[self.SelectCard[j*/, true, true)
			}

			self.promptIndex = self.promptIndex-1
			if (self.promptIndex === 0 ) {
				self.promptIndex = self.maxPromptIndex
			}
		}else{
			//众神归位
			for j=1, #roomPlayer.holdMjTiles do
				self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
			}
		}
	}
}

PokerScene.prototype.autoSendPoker=function(msgTbl,roomPlayer){
	var delayTime = cc.DelayTime:create(0.3)
 	var msgToSend = {}
	msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
	msgToSend.m_flag = 0
	msgToSend.m_card = {}
	msgToSend.m_card = self.curShowMjTileInfo.m_array[1]
 	var callFunc = cc.CallFunc:create(function(sender){
		gt6.socketClient:sendMessage(msgToSend)
		})
	var sequence = cc.Sequence:create(delayTime, callFunc)
	self:runAction(sequence)
}

//有的棋牌玩法 要不起自动过
PokerScene.prototype.autoBuyao=function(seatIdx,msgTbl){
	//self.pass:stopAllActions()
	// self.pass:setVisible(false)
	// self.decisionBtnNode:setVisible(true)
	// self.prompt:setVisible(false)
	// self.play:setVisible(false)
	// self.restore:setVisible(false)

	
	var callFunc1 = cc.CallFunc:create(function(sender){
		//飘个字
		gt6.floatText("您没有牌能大过上家")
		self:playTimeCDStart(false,seatIdx,msgTbl.m_time)
 	})
 	var delayTime = cc.DelayTime:create(1)
 	var callFunc2 = cc.CallFunc:create(function(sender){

 		print("autoBuyao")
 		self.decisionBtnNode:setVisible(false)
 		var msgToSend = {}
		msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
		msgToSend.m_flag = 1
		//msgToSend.m_card = {}
		gt6.socketClient:sendMessage(msgToSend)
 	})
	var sequence = cc.Sequence:create(callFunc1, delayTime, callFunc2)
	self.pass:runAction(sequence)
}

//轮到自己要进行的一些决策按钮展示
PokerScene.prototype.turnMeDecision=function(seatIdx,msgTbl){
	if (! msgTbl ) {
		return
	} 

	if (seatIdx === self.playerSeatIdx ) {
		//self.decisionBtnNode:setVisible(true)

		//没提示的牌//但有牌出
		if (#msgTbl.m_array === 0 && msgTbl.m_flag === 0 ) {
			self.play:setVisible(true)
			self.play:setPosition(self.btnPromptPosition)
			self.prompt:setVisible(false)
			self.pass:setVisible(false)
			self.pass:setPosition(self.btnPassPosition)

		//没可出的牌		
		} else if (#msgTbl.m_array === 0 && msgTbl.m_flag === 1 ) {
			self.pass:setVisible(self.show_buyao_btn_flag)
			self.pass:setPosition(self.btnPromptPosition)

			self.play:setVisible(false)
			self.prompt:setVisible(false)
			self.restore:setVisible(false)
		}else{
			self.prompt:setVisible(true)
			self.prompt:setPosition(self.btnPromptPosition)
			self.play:setVisible(true)
			self.play:setPosition(self.btnPlayPosition)

			//针对不出按钮开关的一些规则
			if (! self.show_buyao_btn_flag ) {
				print("turnMeDecision")
				self.pass:setVisible(false)
				self.prompt:setPosition(self.btnResetPosition2)
				self.play:setPosition(self.btnPlayPosition2)
			}else{
				self.pass:setVisible(true)
				self.pass:setPosition(self.btnPassPosition)
			} 
		}

		//必出一定要隐藏不要
		if (self.optionType === 1 ) {
			self.pass:setVisible(false)
		}

		if (! self.show_buyao_btn_flag ) {
			self.pass:setVisible(false)
		}

	}
}

// 初始化poker类用户信息
PokerScene.prototype.initPokerPlay=function(msgTbl){
	var roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
	for seatIndex, roomPlayer in ipairs(roomPlayers || {}) do
		self:initLeftCardNum(msgTbl,roomPlayer)
		if (roomPlayer.displaySeatIdx != self.playMaxNum ) {
			roomPlayer:showLeftCardNum(self.room_config.showHandPokerNum)
		}

		roomPlayer.holdMjTiles = {}
		roomPlayer.uselessTiles = {}
		// 玩家已出牌
		roomPlayer.outMjTiles = {}
		roomPlayer.bombTimes = 0
		// 麻将放置参考点
		roomPlayer.mjTilesReferPos = self:setPlayerMjTilesReferPos(roomPlayer.displaySeatIdx)
	}
}

PokerScene.prototype.resetRoomUi=function(){
	if (self.cards_layer ) { 
		self.cards_layer:removeAllChildren()
	}

	// 隐藏手牌
	if (self.bottomCard ) {
		self.bottomCard:setVisible(false)
	}

	self:startGame()

	gt6.PlayersManager:removeAlarm()
}

PokerScene.prototype.syncRoom=function(msgTbl){
	self:resetRoomUi()

	//计算delaer位置
	self:setDelarPos(msgTbl)

    //初始化牌局用户
	self:initPokerPlay(msgTbl)

	self:initMultipleByMsg(msgTbl)

	self:syncGameRoom(msgTbl)

	var roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
	for seatIdx, roomPlayer in ipairs(roomPlayers) do

		self:showIdentity(roomPlayer)
		//同步手牌
		self:syncHoldPoker(msgTbl,roomPlayer)
		//同步出牌
		self:syncOutPoker(msgTbl,seatIdx)
		//托管
		if (msgTbl.m_IsTuoguan ) {
			//print("self.playerSeatIdx===="..tostring(self.playerSeatIdx))
			if (self.playerSeatIdx === roomPlayer.seatIdx ) {
				self.mIsInTrusteeship = msgTbl.m_IsTuoguan[self.playerSeatIdx]
				//print("self.mIsInTrusteeship===="..tostring(self.mIsInTrusteeship))
				if (self.mIsInTrusteeship ) {
					for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
						pkTile.mjTileSpr:setColor(cc.c3b(200,200,200))
					}
				}			
			}

			var isIntrusteeship = msgTbl.m_IsTuoguan[roomPlayer.seatIdx]
			if (isIntrusteeship ) {
				// 显示托管机器人
				roomPlayer:showTrusteeship()
			}	
		}

		if (msgTbl.m_CurBomb ) {
			var bomb_count = msgTbl.m_CurBomb[seatIdx]
			self:countNormlMultiple(bomb_count)
		} 
	}

	if (self.mIsInTrusteeship ) {
		// 添加取消托管按钮
		self:createTrusteeshipBtn()
	    // 隐藏操作按钮
	    self.decisionBtnNode:setVisible(false)
	}
	
	// 断线重连，公共元素的操作
	//刷新底牌
	self:refreshLashHand(msgTbl)

	//刷新倍数
	self:updateMultipleUi(self.curMultiple)

}

//-发牌阶段
PokerScene.prototype.playSendPoker=function(msgTbl){
	var roomPlayers = gt6.PlayersManager:getAllRoomPlayers()
	for seatIdx, roomPlayer in ipairs(roomPlayers) do

		self:showIdentity(roomPlayer)

		if (roomPlayer.seatIdx === self.playerSeatIdx ) {
			self:playSelfSendPoker(msgTbl,roomPlayer)
		}	
	}
}

//播放自己发牌
PokerScene.prototype.playSelfSendPoker=function(msgTbl,roomPlayer){
	var seatIdx = roomPlayer.seatIdx
	roomPlayer:removeUselessTiles()
	roomPlayer:removeHoldTiles()

	GamePlayUtils.stopActionByTag(self,action_tag.send_poker_tag)

	if (self.fapai_bu_fanpai_flag ) {
		for i=1,17 do
			self:addOppositeMjTileToPlayer(seatIdx)
		}
		self:sortAninationPlayerMjTiles(seatIdx)
		self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)
		return
	}else{
		//应该先创建好才对
		if (msgTbl.m_card ) {
			for _, v in ipairs(msgTbl.m_card) do
				self:addOppositeMjTileToPlayer(roomPlayer.seatIdx) //创建牌背
				self:addMjTileToPlayer(v) //添加牌面
			}
		}	
	}

	var callFunc1 = cc.CallFunc:create(function(sender){
		self:sortAninationPlayerMjTiles(roomPlayer.seatIdx) //播放牌背移动动画
 	})

 	var delayTime1 = cc.DelayTime:create(0.08*16)
 	var delayTime2 = cc.DelayTime:create(0.12*16)

	var callFunc2 = cc.CallFunc:create(function(sender){
		//roomPlayer:removeHoldTiles()		
		self:sortFinalPlayerMjTiles() //排面显示动画
 	})

 	var callFunc3 = cc.CallFunc:create(function(sender){
		//隐藏扣费提示
		if (! tolua.isnull(self.common_ui_layer) ) {
			self.common_ui_layer:hideNonsume()
		}

		roomPlayer:removeUselessTiles()

		//轮到我出牌
		self:checkPlayBtnShow(seatIdx,msgTbl.m_time)

		//如果是我出牌前，上家已经出牌 检测是否需要禁牌
		self:checkDisableCard(seatIdx,roomPlayer)

		//检测是否需要显示抢地主等决策
		self:checkDecision(seatIdx,msgTbl)

		self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)
 	})

 	
 	var callFunc4 = cc.CallFunc:create(function( sender ){
 		msgTbl.m_playerOper = msgTbl.m_nLaiziType
 		self:processFake(msgTbl)
 	})

	var sequence = nil
 	if (msgTbl.m_nLaiziType && msgTbl.m_nLaiziType > 0 ) { //癞子跑得快
 		sequence = cc.Sequence:create(callFunc1,delayTime1,callFunc2,delayTime2,callFunc4, cc.DelayTime:create(laizi_ani_time), callFunc3)
 	}else{
 		sequence = cc.Sequence:create(callFunc1,delayTime1,callFunc2,delayTime2,callFunc3)
 	}
 	
 	sequence:setTag(action_tag.send_poker_tag)
 	self:runAction(sequence)
}

PokerScene.prototype.refreshLashHand=function(msgTbl){
	if (msgTbl.m_dipai && #msgTbl.m_dipai != 0 && self.m_zhuangPos != -1 ) {
		if (! tolua.isnull(self.bottomCard ) ) {
			self.bottomCard:setVisible(true)
			self.bottomCard:showLastHandPoker(msgTbl.m_dipai,true)
		}		
	} else if (msgTbl.m_dipai && #msgTbl.m_dipai === 0 && self.m_zhuangPos != -1 ) {
		if (! tolua.isnull(self.bottomCard ) ) {
			self.bottomCard:setVisible(true)
			self.bottomCard:showLastHandPokerBg()
		}	
	}
}

PokerScene.prototype.checkShowDecisionBtn=function(){
	if (self.mIsInTrusteeship ) {
		self.decisionBtnNode:setVisible(false)
	}else{
		self.decisionBtnNode:setVisible(true)
	}
}

PokerScene.prototype.hidePlayDecisionBtn=function(){
	self.prompt:setVisible(false)
	self.play:setVisible(false)
	self.pass:setVisible(false)
	self.restore:setVisible(false)
}

// 处理叫分时的 1 2 3 分情况，
PokerScene.prototype.processScorePlayType=function(msgTbl){
	var curScore = msgTbl.m_difen
	if (self.desBtn ) {
		self.desBtn:setVisible(true)

		// 根据分数屏蔽按钮
		var scoreOne = gt6.seekNodeByName(self.desBtn, "yifen")
		var scoreTwo = gt6.seekNodeByName(self.desBtn, "liangfen")

		if (scoreOne && scoreTwo ) {
			if (curScore === 1 ) {
				scoreOne:setEnabled(false)
				scoreTwo:setEnabled(true)
			} else if (curScore === 2 ) {
				scoreOne:setEnabled(false)
				scoreTwo:setEnabled(false)
			}else{
				scoreOne:setEnabled(true)
				scoreTwo:setEnabled(true)
			}	
		}			
	}
}

////播完发牌以后需要检测的////////-start
//最开始两端就没有约定好这种事情 每个阶段的状态和阶段的时间间隔
//没有考虑动画播放时间 
//发牌结束以后的处理
PokerScene.prototype.checkPlayBtnShow=function(seatIdx){
	print("self.checkPlayBtnShow=="..tostring(self.is_turn_me))
	if (self.is_turn_me ) {
		self.decisionBtnNode:setVisible(true)
		self:turnMeDecision(seatIdx,self.curShowMjTileInfo)

	}
}

PokerScene.prototype.checkDisableCard=function(seatIdx,roomPlayer){
	if (self.turnShowMsgTbl ) {
		if (self.turnShowMsgTbl.m_flag === 0 ) { //没有上家 显示出来倒计时
			var cutdown_time = self.room_config.firstCountDown || 12
			self:playTimeCDStart(true,seatIdx,cutdown_time)
		} else { //有上家 别人出牌，检测 不能出的禁牌
			self:disableCard(self.turnShowMsgTbl, roomPlayer)
			self:playTimeCDStart(true,self._prePointSeatindex ,self.playTimeCD)
		}
		self.turnShowMsgTbl = nil
	}
}

PokerScene.prototype.checkDecision=function(seatIdx,msgTbl){
	//轮到我决策
	if (msgTbl.mZhuangPos === nil && self.doingAskIndex != nil  ) {
		var seatIdx = self.doingAskIndex + 1
		if (seatIdx === self.playerSeatIdx ) {
			self.doingAskIndex = nil 
			//隐藏决策node下的按钮
			self:hidePlayDecisionBtn()
			self:playTimeCDStart(true,seatIdx,12)
			self:updateDecisionBtns()
		}
		self:showBottomCardBg()
	}
	
}

//////////////-翻倍 Begin////////////////-
//常规计算倍数 //倍数计算规则为低分*倍数的公式
PokerScene.prototype.countNormlMultiple=function(num){
	if (! self.mMaxFanShu ) {
		return
	}
	num = num || 1

	self.curBooms = self.curBooms + num
	if (self.mRoomPattern != gt6.CommonConst.RoomPattern.COIN ) {
		if (self.curBooms <= self.mMaxFanShu ) {
			self.curMultiple = self.curMultiple * (2^num)
		}
	}else{
		self.curMultiple = self.curMultiple * (2^num)
	}

}

//滚翻 加底一类的 倍数计算规则
//此算法很久以前就存在 可能有问题
PokerScene.prototype.countFanMultiple=function(num){
	if (! self.mMaxFanShu ) {
		return
	}

	if (self.curBooms < self.mMaxFanShu ) { //and self.fanBeiLeiXing === 2 ) {
		self.curMultiple = self.curMultiple * 2
	}else{
		self.curMultiple = self.curMultiple + 1

		if (self.playerSeatIdx === self.mZhuangPos ) {
			self.curMultiple = self.curMultiple + 1
		}
	}
	
	self.curBooms = self.curBooms + 1
}


PokerScene.prototype.initMultipleByMsg=function(msgTbl){
	self.curBooms = 0
	self.curMultiple = msgTbl.m_difen || 1
}

//更新翻倍数
PokerScene.prototype.updateMultipleUi=function(multiple){
	if (! self.Txt_Times ) {
		return
	} 

	self.Txt_Times:stopAllActions()
	self.Txt_Times:setScale(1)
	gt6.log(" PokerScene:updateFanBei " .. multiple)
	self.Txt_Times:setString("" .. multiple)
	self.Txt_Times:setVisible(true)
	var action = cc.Sequence:create(cc.ScaleTo:create(0.2,2),cc.ScaleTo:create(0.2,1.0))
	self.Txt_Times:runAction(action)
}
//////////////-翻倍 End////////////////-


//显示身份 如 地主 坑主
PokerScene.prototype.showIdentity=function(roomPlayer){
	if (! roomPlayer ) {
		return
	} 
	gt6.log("创建地主头像")
	if (self.mZhuangPos && self.mZhuangPos === roomPlayer.seatIdx ) { //是庄家
		if (self.dealer_info_config && self.dealer_info_config.headIcon ) {
			self.dealer_info_config.dealer_type = self.room_config.dealer_type 
			roomPlayer:createIdentity(self.dealer_info_config)
		}
	}
}

//显示card的一些标志
PokerScene.prototype.showCardFlag=function(mjTileSpr,card_icon_type){
	if (! self.dealer_info_config ) {
		return
	}  

	var name = ""
	if (card_icon_type === gt6.CommonConst.CARD_ICON_TYPE.HAND_CARD ) {
		name = "cardIcon"
	}else{
		name = "outCardIcon"
	} 

	var card_icon = self.dealer_info_config[name]
	if (! card_icon ) {
		return
	}  

	var identity_icon = cc.Sprite:createWithSpriteFrameName(card_icon)
	// landLordIcon:setAnchorPoint(cc.p(1,1))
	identity_icon:setPosition(cc.p(identity_icon:getContentSize().width/2, identity_icon:getContentSize().height/2))
	// landLordIcon:setPosition(cc.p(155, 216))
	mjTileSpr:addChild(identity_icon)
}

PokerScene.prototype.getSelectCard=function(){
	var unSelectArr = {}
	var selectArr = {}
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) //self.roomPlayers[self.playerSeatIdx]
	var mjTilesReferPos = roomPlayer.mjTilesReferPos
	var _mjTilePos = mjTilesReferPos.holdStart
	// table.foreach(self.playMjLayer:getChildren(), function(i, v){
	table.foreach(roomPlayer.holdMjTiles, function(i, card){
		var v = card.mjTileSpr
		if (v:getPositionY() === _mjTilePos.y ) {
			table.insert(unSelectArr, tonumber(v:getName()))
		} else if (v:getPositionY() === _mjTilePos.y+gt6.CommonConst.ConstValue.SELECT_CARD_HIGHT ) {
			table.insert(selectArr, tonumber(v:getName()))
		}
	})
	return selectArr,unSelectArr
}

//出牌的特殊错误
PokerScene.prototype.checkPokerError=function(error_code){
	//牌型错误 提起的牌归位 清空选中的牌
	var is_error = false
	if (error_code != 0 ) {
		is_error = true
		self:resetAllPokerPos()
		self.SelectCard = {}
	}
	
	var error_msg = gt6.CommonConst.error_list[error_code]
	if (error_msg ) {
		gt6.floatText(error_msg)
	}

	return is_error
}

PokerScene.prototype.resetAllPokerPos=function(){
	//众神归位
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if (roomPlayer ) {
		var count = #roomPlayer.holdMjTiles
		for j=1, count do
			self:setPokerIsUp(roomPlayer.holdMjTiles[j], false, false)
		}
	}
}

PokerScene.prototype.updateCurShowPokerInfo=function(poker_type,card,number){
	self.curShowCardInfo.cardType = poker_type || 0
	self.curShowCardInfo.cardNum = number || 0
	self.curShowCardInfo.cardArr = card || {}
}

//同步手牌
PokerScene.prototype.syncHoldPoker=function(msgTbl,roomPlayer){
	//开局一后直接添加牌
	if (self.status === gt6.CommonConst.ROOM_STATUS.BOARD_START ) {
		if (roomPlayer.seatIdx === self.playerSeatIdx ) {
			if (msgTbl.m_card && #msgTbl.m_card > 0 ) {
				for _, v in ipairs(msgTbl.m_card) do
					self:addMjTileToPlayer(v)
				}

				// 根据花色大小排序并重新放置位置
				if (self.mLaiziValue && self.mLaiziValue > 0 ) {
					for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
						if (pkTile.mjNumber === self.mLaiziValue ) {
							pkTile.mjIsLaizi = true
						}
					}
					self:refreshHoldPokers()
				}else{
					self:sortPlayerMjTiles(self.playerSeatIdx)
				}	

			}
		}

	}
}

//同步出牌
PokerScene.prototype.syncOutPoker=function(msgTbl,seatIdx){
	// 玩家已出牌
	if (self.have_laizi_flag ) {
 		self:LaiFunction(msgTbl,seatIdx)
 	} else if (self.have_pizi_flag ) {
 		self:PiziFunction(msgTbl,seatIdx)
 	}else{
		// 服务器座次编号
		var turnPos = seatIdx - 1
		// 已出牌
		var outMjTilesAry = msgTbl["m_out" .. turnPos]
		if (outMjTilesAry ) {
			for _, v in ipairs(outMjTilesAry) do
				self:addAlreadyOutMjTiles(seatIdx,v)
			}
			self:refreshOutPokers(seatIdx)
		}
 	}	
}

PokerScene.prototype.LaiFunction=function(msgTbl,seatIdx){
	var key_out = string.format("m_out%d",seatIdx-1)
	var key_laizichange = string.format("m_laiziChange%d",seatIdx-1)
	var card = msgTbl[key_out]
	var laiziChange = msgTbl[key_laizichange]

	var cur_card = {}
	
	// 找出最后出的牌型,从自己开始往上一家遍历
	var outIdx = self.playerSeatIdx - 1
	var max_player_num = self.playMaxNum
	for i=1,max_player_num do
		outIdx = outIdx - 1
		outIdx = outIdx < 0 && max_player_num || outIdx			
		var card = msgTbl["m_out"..outIdx]
		if (card && #card > 0 ) {
			cur_card = card
			break
		}
	}

	self:updateCurShowPokerInfo(msgTbl.m_pokerStyle,cur_card,msgTbl.m_typeNumber)

	if (card ) {
		for i,v in ipairs(card) do
			var value , color = GamePlayUtils.changePk(v)
			gt6.log("SeatIdx:"..seatIdx .. "  Value:"..value .. "  selfPlayerSeat:" .. self.playerSeatIdx)
			self:addAlreadyOutMjTiles(seatIdx, v, #card, aiziChange)
		}
		self:refreshOutPokers(seatIdx)		
	}
}

PokerScene.prototype.PiziFunction=function(msgTbl,seatIdx){
	var cardArrIdx = seatIdx - 1
	var card = msgTbl["m_out"..cardArrIdx]
	if (card ) {
		card = gt6.LaiZiUtils.checkLaziPosAndIdx(card, msgTbl.m_pokerStyle, msgTbl.m_laiziNumber)
		for i,v in ipairs(card) do
			self:addAlreadyOutMjTiles(seatIdx, v,#card,msgTbl.m_laiziNumber)
		}
	}

	// 找出最后出的牌型,从自己开始往上一家遍历
	var outIdx = self.playerSeatIdx - 1
	var max_player_num = self.playMaxNum
	for i=1,max_player_num do
		outIdx = outIdx - 1
		outIdx = outIdx < 0 && max_player_num || outIdx			
		var card = msgTbl["m_out"..outIdx]
		if (card && #card > 0 ) {
			self:updateCurShowPokerInfo(msgTbl.m_pokerStyle,card,#card)
			break
		}
	}
}

// 根据牌的类型，计算癞子牌显示位置和大小
PokerScene.prototype.checkLaziPosAndIdx=function(arr,_type,laiziNumberArr){
	return arr
}

PokerScene.prototype.getSoundPath=function(sex){
	if (sex === 1 ) {
		return "man/"
	}else{
		return "woman/"
	}
}

PokerScene.prototype.showBottomCardBg=function(){
	if (! tolua.isnull(self.bottomCard ) ) {
		self.bottomCard:setVisible(true)
		self.bottomCard:showCardBg()
	}		
}

PokerScene.prototype.localShowPokerTip=function(){
	//可提示牌型有多组 
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if (self.have_laizi_flag ) {
		// 出牌提示
		gt6.FakeCardMgr:getInstance():helpMe(self.curShowCardInfo, roomPlayer, self.curShowMjTileInfo.m_array)
	}

	if (self.have_pizi_flag ) {
		table.sort(self.curShowCardInfo.cardArr, function(a,b){
			return a > b
		})
		helpArr = self._gameRule:helpByShowType(self.curShowCardInfo,roomPlayer.holdMjTiles,self.laziCardArr[1])
		self.curShowMjTileInfo.m_array = helpArr || {}
	}
}

PokerScene.prototype.playActionByIdName=function( id_name , msgTbl){
	if (! id_name ) { gt6.log("playActionByIdName error -> id_name is nil") return } 
	var data = {}
	data.seatIdx = msgTbl.m_pos + 1
	data.flag = msgTbl.m_flag
	data.realSeat = gt6.PlayersManager:getDisplaySeat(data.seatIdx)
	data.laiZi = msgTbl.m_laiziNumber
	data.card = msgTbl.m_card
	data.msgTbl = msgTbl
	
	var cfgs = g_playRulesCfg_poker[id_name]
	if (g_playRulesCfg_poker[id_name .. ("style" .. self.mGameStyle)] ) {
		cfgs = g_playRulesCfg_poker[id_name .. ("style" .. self.mGameStyle)]
	}

	gt6.log("id_name " .. id_name)
	dump(cfgs, "cfgs ")

	if (cfgs && next(cfgs) && cfgs.actionId && next(cfgs.actionId) ) { 
		for i, id in ipairs(cfgs.actionId) do
			gt6.log("onRcvSyncShowMjTile id_"..id)
			var action = g_actionId_poker["id_"..id] 
			self:doAction(action.realId,data,action)
		}
	}
}

////////////-倒计时////////////Begin////////////////-
//timeDuration,appear
PokerScene.prototype.playTimeCDStart=function(isshow,seatindex,time){
	gt6.log("playTimeCDStart " .. tostring(isshow) .. " " .. tostring(seatindex) .. " " .. tostring(time))
	if (time != self.playTimeCD ) {
		self.playTimeCD = time
		self.isVibrateAlarm = false
		if (self.clock && ! tolua.isnull(self.clock) ) {
			self.clock:setTimeCD( tostring(time) )
		}
	}
	self:setClockPosition(seatindex , isshow)
	self._prePointSeatindex = seatindex
}

PokerScene.prototype.setClockPosition=function( seatindex , is_show){
	var realSeat = gt6.PlayersManager:getDisplaySeat(seatindex)
	var player = gt6.seekNodeByName(self.rootNode,"Node_playerMjTiles_" .. realSeat)
	var Node_Clock = gt6.seekNodeByName(player, "Node_Clock")
	var pos = Node_Clock:getParent():convertToWorldSpace(cc.p(Node_Clock:getPosition()))
	if (! self.clock || tolua.isnull(self.clock) ) { //创建 
		self.clock = require("app/gameType/base/ClockNode"):create()
		self.rootNode:addChild(self.clock, gt6.CommonConst.ZOrder.SETTING_LAYER - 1)
		self.clock:setPosition(pos)
	}

	if (self.clock && ! tolua.isnull(self.clock) ) {
		self.clock:setPosition(pos)
		self.clock:setVisible(is_show)
	}
}

PokerScene.prototype.playTimeCDUpdate=function(delta){
	if (! self.playTimeCD ) {
		return
	}

	self.playTimeCD = self.playTimeCD - delta
	if (self.playTimeCD < 0 ) {
		self.playTimeCD = 0
		self.playCDAudioID = nil
	}
	
	if (self.playTimeCD <= 3 && ! self.isVibrateAlarm && self.is_turn_me ) {
		// 剩余3s开始播放警报声音+震动一下手机
		self.isVibrateAlarm = true
		// 播放声音
		self.playCDAudioID = gt6.soundEngine:playEffect("common/timeup_alarm",false,"2POKER")
		// 震动提醒
		cc.Device:vibrate(1)
	}
	var timeCD = math.ceil(self.playTimeCD)
	if (! tolua.isnull(self.clock) ) {
		self.clock:setTimeCD(timeCD)
	}
}
////////////-倒计时////////////End  ////////////////-

PokerScene.prototype.createCardLayer=function(parent){
	//创建牌层
	if (! parent ) {
		parent = self
	} 
	var cardsLayer = CardLayer:create()
	parent:addChild(cardsLayer, gt6.CommonConst.ZOrder.MJTILES)
	self.cards_layer = cardsLayer
}

//需要子类自己实现的////////start////////

//钩子方法
PokerScene.prototype.updateDecisionBtns=function(){

}

PokerScene.prototype.clearCheckPoker=function(){
//清除让牌数 子类实现
}

PokerScene.prototype.showWinTip=function( is_show ){
	//子类实现用来控制还剩多少赢
}

//显示对手让牌效果
PokerScene.prototype.showOpponentCheckPokers=function( is_show ){

}

PokerScene.prototype.doDealLaiZi=function(data,action){
}

PokerScene.prototype.doAgainDeal=function(data,action){
}

//重播中用
PokerScene.prototype.doGetBottomCard=function(data,action){
}

PokerScene.prototype.syncGameRoom=function(msgTbl){

}

//更新剩余几张胜利
PokerScene.prototype.updateWinPokerNum=function(roomPlayer){

}

//刷新对手牌
PokerScene.prototype.refreshRivalPoker=function(seatIdx){//二人时要刷新对手的牌
}

//隐藏明牌
PokerScene.prototype.hideOpponentOpenPoker=function(){

}

//需要子类自己实现的////////}////////

PokerScene.prototype.stopCountDownSound=function( ... ){
	if (self.playCDAudioID && self.playTimeCD > 0.02 ) { //音乐自动停止和手动打断在同一帧会有问题
		gt6.soundEngine:stopEffect(self.playCDAudioID)
		self.playCDAudioID = nil
	}	
}

PokerScene.prototype.resetSelfPokerColor=function(){
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if (roomPlayer && roomPlayer.holdMjTiles ) {
		for i,pkTile in ipairs(roomPlayer.holdMjTiles) do
			if (self.mIsInTrusteeship != true ) {
				pkTile.mjTileSpr:setColor(cc.c3b(255,255,255))
				pkTile.mjIsTouch = true
			}
		}
	}
}

PokerScene.prototype.onTuoGuan=function(){
	if (self.is_turn_me ) {
	    // 显示
		self:handleTrusteeship(false,self.playerSeatIdx)
	}
	
	//退出托管颜色恢复
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) //self.roomPlayers[self.playerSeatIdx]
	for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
		pkTile.mjTileSpr:setColor(cc.c3b(255,255,255))
	}
}


//取消托管
PokerScene.prototype.onQuXiaoTuoGuan=function(){
	//玩家手牌置灰
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx) //self.roomPlayers[self.playerSeatIdx]
	if (roomPlayer.holdMjTiles ) {				
		for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
			self:setPokerIsUp(pkTile, false, false)
			pkTile.mjTileSpr:setColor(cc.c3b(200,200,200))
		}
	}

	self:handleTrusteeship(true,self.playerSeatIdx)
}

//分数加减效果
PokerScene.prototype.socreChangeEffect=function(data){
	var changeReason = {
		Ticket = 6, //报名费
	}

	var changeNum = data.changeNum
	var roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(data.m_pos + 1)

	if (data.reason === changeReason.Ticket ) { //报名费
		changeNum = math.abs(changeNum) * -1
	 // 	if (! tolua.isnull(self.common_ui_layer) ) { //服务费提示
		// 	self.common_ui_layer:initPayCoin( changeNum )
		// }	
	} else { //加金币
		var numFont = roomPlayer:createCoinEffect(changeNum,  plus_info, minus_info)
		numFont:setScale(0.6)

		//roomPlayer:createEffect()
	}
}

//实现自己托管或取消托管的处理
PokerScene.prototype.handleTrusteeship=function(isVis,seatIdx){
	self:playTimeCDStart(isVis, seatIdx, self.playTimeCD)
    
    self.decisionBtnNode:setVisible(isVis)
}

PokerScene.prototype.backMainSceneFromMatch=function(){
	// 事件回调
	gt6.removeTargetAllEventListener(self)
	// 消息回调
	self:unregisterAllMsgListener()

	
	Utils6.cleanMWAction()

	if (gt6.runningModule ) { 
		// print("gt6.dispatchEvent(gt6.EventType.EXIT_MODULE_INNER)")
		// gt6.dispatchEvent(gt6.EventType.EXIT_MODULE_INNER, gt6.runningModule)
		print("////> gt6.module_projectView = ",gt6.module_projectView)
		var coinScenePath = "app/projectView/" .. gt6.module_projectView .. "/CoinMainScene"
				cc.Director:getInstance():replaceScene(newScene)
	}
}

// return PokerScene