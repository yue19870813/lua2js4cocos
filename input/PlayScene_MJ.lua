
require("app/base/protocols/MessageInit")
require("app/gameType/base/CommonConst")

gt6.GameMsgQueueManager = require("app/gameType/base/utils/GameMsgQueueManager")

local PlaySceneBase = require("app/gameType/base/PlaySceneBase")

local PlaySceneCS = class("PlaySceneCS", PlaySceneBase)


PlaySceneCS.ZOrder = {
	MJTABLE						= 1,
	PLAYER_INFO					= 2,
	COMMONLAYER                 = 3,
	MJTILES						= 6,
	OUTMJTILE_SIGN				= 7,
	DECISION_BTN				= 8,
	DECISION_SHOW				= 9,
	PLAYER_INFO_TIPS			= 10,
	REPORT						= 16,
	DISMISS_ROOM				= 17,
	SETTING						= 18,
	CHAT						= 20,
	MJBAR_ANIMATION				= 21,
	FLIMLAYER           	    = 16,
	HAIDILAOYUE					= 23,
	GANG_AFTER_CHI_PENG			= 15,
	OPENHUPAITIPS   			= 22,
	ROUND_REPORT				= 66 ,-- 单局结算界面显示在总结算界面之上
	DECISION_NEW                = 67,

}
PlaySceneCS.SPMSG = {}

PlaySceneCS.TINGTYPE = {
	TING = 1,
	JIA = 2,
	BIAN = 3,
	DIAO = 4,
	JIAO = 5,
	CHEN = 6,
}
PlaySceneCS.HUTYPE = {
	[3] = 	"qixiaodui",
	[5] =	"dingxiangpiao",
	[9] =	"chongbao",
	[10] =	"mobao",
	[14] =	"mendashan",
	[15] =	"gangshangkaihua",
	[16] =	"haohuaqixiaodui",
	[18] =	"tianhu",
	[19] =	"dihu",
	[20] =	"renhu",
	[21] =	"yaojiuqixiaodui",
	[24] =	"ganghoupao",
	[27] =	"yitiaolong",
	[28] =	"duibao",
	[29] =	"loubao",
	[30] =	"kanduibao",
	[31] =  "shisanyao", 
}

-- 牌花
-- PlaySceneCS.plistPathBig = "gameType/1MJ/playScene/mahjong_tiles.plist"
-- PlaySceneCS.plistPathSmall = "gameType/1MJ/playScene/mahjong_tiles_s.plist"
-- PlaySceneCS.plistGameUI = "gameType/1MJ/playScene/playScene.plist"

local reload_plists = {
	"mahjong_tiles.plist",
	"mahjong_tiles_s.plist",
	"playScene.plist",
	"PlayScene_common.plist",
}

PlaySceneCS.animPath = "gameType/1MJ/animation/"
PlaySceneCS.playScenePath = "gameType/1MJ/playScene/"
PlaySceneCS.PicPath = "gameType/1MJ/playScene/new_image/"

--发牌前决策和显示 EventId
PlaySceneCS.beforeDealEventId = {
	JiaGang = 1,  --加刚
	GuaDang = 2,  --挂挡
	GuaPiao = 3,  --挂漂
	Chen = 4, --抻
	GuaDang_BP = 6, --北票的挂档
}

PlaySceneCS.beforeDealCfg = {}
--TIPS：
--新的发牌前决策在此配置。
--WARNING：IV表，有顺序。
PlaySceneCS.beforeDealCfg[PlaySceneCS.beforeDealEventId.Chen]= {
	btns = {PlaySceneCS.PicPath.."gt6_btn_score_1.png",PlaySceneCS.PicPath.."gt6_btn_score_2.png",PlaySceneCS.PicPath.."gt6_btn_score_3.png",PlaySceneCS.PicPath.."gt6_bt_guo.png"},
	msgToSend = {1,2,3,0}, 
	headIcons = {PlaySceneCS.PicPath.."gt6_icon_score_1.png",PlaySceneCS.PicPath.."gt6_icon_score_2.png",PlaySceneCS.PicPath.."gt6_icon_score_3.png",nil},
	titlePic = PlaySceneCS.PicPath.."gt6_chen_artword.png",
}


PlaySceneCS.fourGang = {
	fixNum = 0.8
}

PlaySceneCS.beforeDealMsgName = {}
PlaySceneCS.beforeDealMsgName[PlaySceneCS.beforeDealEventId.JiaGang] = "m_DoubleState"  --加刚
PlaySceneCS.beforeDealMsgName[PlaySceneCS.beforeDealEventId.GuaDang] = "m_guaDangState"  --挂挡
PlaySceneCS.beforeDealMsgName[PlaySceneCS.beforeDealEventId.GuaPiao] = "m_guaPiaoState"  --挂漂


PlaySceneCS.SPCARDSHOW = {
	BAO = {spBgName = "gt6_baopaibg.png",spBgResType = ccui.TextureResType.plistType},
	BAO_MORE = {spBgName = PlaySceneCS.PicPath.."gt6_bpkuang.png",spBgResType = ccui.TextureResType.localType,spTitle = PlaySceneCS.PicPath.."gt6_baopai_title.png",spTitleResType = ccui.TextureResType.localType},
	HUN = {spBgName = "gt6_hunpi_bd.png",spBgResType = ccui.TextureResType.plistType},
	GANG = {spBgName = "gt6_gangpai_bd.png",spBgResType = ccui.TextureResType.plistType}
}


PlaySceneCS.SPPARAMS = {
	CARD_FLAG_HUI = 0xa1f2,
 	VIDEO_ID = 0x8764,
 	AUTO_PLAY = 0x8766,
 	CARD_FLAG_BAO = 0x8768,
 	CARD_FLAG_RED = 0x8789,
 	MJMAXORDER = 100000,
 	PAIHUISE = cc.c3b(180,180,180),
 	HUANGSE = cc.c3b(243,243,10),
 	KAIPAIDELAY = 0.5,
}

PlaySceneCS.FLAGS = {}
PlaySceneCS.FLAGS.HUN = {
	pic = "gt6_hun_",
	id = PlaySceneCS.SPPARAMS.CARD_FLAG_HUI,
	res = nil ,
}

PlaySceneCS.HU_ANI_TYPE = {
	FLY = 1, --起飞 
	FALL = 2, --落下
}

PlaySceneCS.NODE_NAME = {
	SEND_CARD_ANI_NAME = "SEND_CARD_ANI_NAME",
	BOARD_START_ANI_NAME = "BOARD_START_ANI_NAME",
}

local POP_NAME_LIST = {
	ROUND_REPORT = "ROUND_REPORT",
}

--msg_time = 0 --以后会配置在表里 目前方便调试放到代码里
--opt opt操作类型
--is_add_queue --动画列队queue
local opt_info_lis = {
	[gt6.GC_SYNC_ROOM_STATE] = {
		opt = "onRcvSyncRoomState",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_ROUND_STATE] = {
		opt = "onRcvRoundState",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_START_GAME] = {
		opt = "onRcvStartGame",
		is_add_queue = true,
		msg_time = 5.2,
	},
	[gt6.GC_TURN_SHOW_MJTILE] = {
		opt = "onRcvTurnShowMjTile",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_SYNC_SHOW_MJTILE] = {
		opt = "onRcvSyncShowMjTile",
		is_add_queue = true,
		msg_time = 0.1,
	},
	[gt6.GC_MAKE_DECISION] = {
		opt = "onRcvMakeDecision",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_SYNC_MAKE_DECISION] = {
		opt = "onRcvSyncMakeDecision",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_ROUND_REPORT] = {
		opt = "onRcvRoundReport",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_FINAL_REPORT] = {
		opt = "onRcvFinalReport",
		is_add_queue = true,
		msg_time = 0,
	},

	[gt6.GC_START_DECISION] = {
		opt = "onRcvStartDecision",
		is_add_queue = true,
		msg_time = 0,
	},

	[gt6.GC_SYNC_START_PLAYER_DECISION] = {
		opt = "onRcvSyncStartDecision",
		is_add_queue = true,
		msg_time = 0,
	},

	[gt6.GC_SYNC_BAR_TWOCARD] = {
		opt = "onRcvLastTiles",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.CG_SYNC_HUIPI] = {
		opt = "onRcvHunpi",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.MSG_S_2_C_ASK_EVENT] = {
		opt = "onReciveBeforeDeal",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.MSG_S_2_C_RES_DOUBLE] = {
		opt = "onRcvBeforeDealRadio",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_CANNOTPLAYCARDS] = {
		opt = "onRcvCanNotPlayCards",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.CG_SYNC_GANGPAI] = {
		opt = "onRcvGangPai",
		is_add_queue = true,
		msg_time = 0,
	},
	[gt6.GC_ASPCARD] = {
		opt = "onRcvShowASPCard",
		is_add_queue = true,
		msg_time = 0,
	},
}

local plus_info = {
	fontPic = "gameType/1MJ/playScene/atlas/mj_flyscore_num.png",
	font_size = {width = 30,height = 36},
	first_char = ".",
}

local minus_info = {
	fontPic = "gameType/1MJ/playScene/atlas/mj_scorenum_minus.png",
	font_size = {width = 30,height = 36},
	first_char = ".",
}

function PlaySceneCS:ctor(enterRoomMsgTbl,isReplay)	
	dump(enterRoomMsgTbl,"---->PlaySceneCS  enterRoomMsgTbl@@123 : ")
	print("-------===========NEW CFG PLAYSCENE-------===========")

	local data = {msgTbl = enterRoomMsgTbl}
	gt6.gameType =gt6.gameTypeDefine.MJTYPE

	PlaySceneCS.super.ctor(self,data)

	self:initData(enterRoomMsgTbl,isReplay)

	self:initRoom(enterRoomMsgTbl)

	self:initPlayersManager()
	gt6.PlayersManager:setSeatTable(self.playerSeatTable)

	self:initDisplay(enterRoomMsgTbl,isReplay)

	self:checkSpeicals()

	self:playerEnterRoom(enterRoomMsgTbl)

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	gt6.registerEventListener("change_match_difen", self, self.onChangeMatchDifen)
	-- 设置是否日志记录
	if gt6.bSaveGameLog then
		gt6.socketClient:setMessageLog(true)
	end

	dump(g_actionId,"lijian>>biao")
	dump(gt6.winSize,"gt6.winSize()====") 

	--创建一个队列
	gt6.GameMsgQueueManager:createQueue()
end

function PlaySceneCS:initData(enterRoomMsgTbl,isReplay)
	self.m_headNodeTips = {"TING","ZHUANG"}
	self:setName("playScene")
	self.m_isTingPai = nil
	self.m_tingState = false
	self.soundIdx=1000
	self.isReplay=isReplay or false
	--玩家ip
	self.m_ip = {}
	self.m_roundDelay = 2
	self.playTimeCD=15
	--结算页面所需信息
	self.infoForReport=nil
	-- 是否正在打宝
	self.isDabao = false
	self.m_hui = {}

	self.m_touchedTimes = 0

	-- 屏幕上所有创建的麻将节点
	self.allCardSprites = {}
	self.ai_mjTileSpr = nil
	-- 结算前夕是否有玩家被移除
	gt6.hasRoomPlayerBeRemoved = false

	self.isTouch = true
	self.mIsInTrusteeship = false --是否在托管状态
	self.isStart = false

	--当前玩法玩家总数
	gt6.totalPlayerNum = enterRoomMsgTbl.m_duc or 4
	--已经加入的玩家总数
	gt6.alreadyAddedNum = 0 
	--人数
	self.playerSeatTable = {1,2,3,4}
	--当前玩家显示位置号
	self.currentPlayerDisplaySeat = 4 
	if gt6.totalPlayerNum == 4 then
		self.playMaxNum = 4
		self.playerSeatTable = {1,2,3,4}
	elseif gt6.totalPlayerNum == 2 then
		self.playMaxNum = 2
		self.playerSeatTable = {2,4}
	elseif gt6.totalPlayerNum == 3 then
		self.playMaxNum = 3
		self.playerSeatTable = {1,3,4}
	end
	--回放位置修正
	self.m_FIXREPLAYERPOS =
	{
		cc.p(0,0),cc.p(0,0),cc.p(0,0),cc.p(0,0)

	}
	self.m_FIXPUNGPOS = 
	{
		cc.p(0,0),cc.p(0,0),cc.p(0,0),cc.p(0,0)
	}
	self.m_FIXREPLAYHOLDPOS=
	{
		cc.p(0,0),cc.p(0,0),cc.p(0,0),cc.p(0,0)
	}
	self.m_FIXREPLAYRGROUP =
	{
	 cc.p(0,0),cc.p(0,0),cc.p(0,0),cc.p(0,0)
	}

	self.mRoomPattern = enterRoomMsgTbl.m_gameZone

	self:initPlayType(enterRoomMsgTbl)
end


function PlaySceneCS:initPlayType(enterRoomMsgTbl)
	-- body
	-- 玩法类型
	self.playType = enterRoomMsgTbl.m_state or 9999
	local playTypeDesc = ""
	if g_BigType and g_BigType[self.playType + 1] then
		playTypeDesc = g_BigType[self.playType + 1].name
	end
	print("玩法 ： ", playTypeDesc)
	gt6.playType = self.playType
	gt6.g_playTypeDesc = playTypeDesc
	self.m_gameStyle = enterRoomMsgTbl.m_gameStyle
	--金币场测试
	if enterRoomMsgTbl.isGoldTest then
		print("isGoldTest>>"..self.playType)
		self:checkGoldenId(enterRoomMsgTbl.m_gameStyle)
	end

	local realType = enterRoomMsgTbl.m_playtype or {}
	local playTypeTable ={}
	if g_BigType and g_BigType[self.playType+1] then
		playTypeTable = g_BigType[self.playType+1].type_id
	end
	--遍历取出玩法选项
	for i,v in ipairs(realType) do
		for index, keys  in ipairs(playTypeTable) do
			if g_PlayType[keys] and g_PlayType[keys].id == v  and g_PlayType[keys].type ~=5 and g_PlayType[keys].type ~=4 then --不显示局数(type5)的信息
				playTypeDesc=playTypeDesc.."   "..g_PlayType[keys].name
			end
		end
	end

	local arrStr={}
	for p_str in string.gmatch(playTypeDesc, "%S+") do
	    table.insert(arrStr,p_str)
    end
    local isQuan = enterRoomMsgTbl.m_circleType or 0  --判断是局还是圈
    local circleToShow = enterRoomMsgTbl.m_maxCircle .. "局"
    if isQuan == 0 then --圈数
    	circleToShow = math.floor(enterRoomMsgTbl.m_maxCircle/gt6.totalPlayerNum) .."圈"
    end
    local AACardStr = ""
    if enterRoomMsgTbl.m_SubCardType  and enterRoomMsgTbl.m_SubCardType == 1 then
    	AACardStr = " 均分房卡"
    end
    local newStrType=""
    if g_BigType and g_BigType[self.playType + 1] then
    	newStrType = g_BigType[self.playType + 1].name.."麻将"..AACardStr
    end
    newStrType = newStrType .. " "..circleToShow 
	for i,v in ipairs(arrStr) do
	 	if i==1 then
	    else
			newStrType=newStrType .." "..v
	    end
    end

	--需要给readyplay的值 有待整理
	local readyPlayMsg = self.readyPlayMsg
	readyPlayMsg.roomID = enterRoomMsgTbl.m_deskId
	readyPlayMsg.playerSeatPos = enterRoomMsgTbl.m_pos
    readyPlayMsg.title_show = g_BigType[self.playType + 1] and g_BigType[self.playType + 1].name or ""
	readyPlayMsg.playTypeDesc = string.gsub(newStrType, " ", ",")
	readyPlayMsg.enterRoomMsgTbl = enterRoomMsgTbl

	if enterRoomMsgTbl.m_gameZone and enterRoomMsgTbl.m_gameZone == 1 then
		readyPlayMsg.playType = gt6.coinType.MJ
		--self.isGolden = true
		self:checkGoldenId(enterRoomMsgTbl.m_gameStyle)
	end
end

function PlaySceneCS:initRoom(enterRoomMsgTbl)
	-- 加载界面资源
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistPathBig)
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistPathSmall)
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistGameUI)
	Utils6.loadPlist(reload_plists)

	local csbNode = gt6.createCSAnimation("gameType/1MJ/playScene/playScene_MJ_New.csb")
    self.csbNode=csbNode
	--目前先写死默认值
	enterRoomMsgTbl.m_cardBack = 2
	gt6.checkLoadPaiBei(enterRoomMsgTbl.m_cardBack or cc.UserDefault:getInstance():getIntegerForKey("PlayPaibei" , 2))
	-- gt6.retainMJ(PlaySceneCS.plistPathBig)
	-- gt6.retainMJ(PlaySceneCS.plistPathSmall)
	-- gt6.retainMJ(PlaySceneCS.plistGameUI)
	csbNode:setContentSize(gt6.winSize)
	ccui.Helper:doLayout(csbNode)
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt6.winCenter)
	self.rootNode = csbNode

	-- 麻将层
	local playMjLayer = cc.Layer:create()
	playMjLayer:setSwallowsTouches(false)
	self.rootNode:addChild(playMjLayer, PlaySceneCS.ZOrder.MJTILES)
	playMjLayer:setContentSize(gt6.winSize)
	self.playMjLayer = playMjLayer

	--麻将出牌层
	local playOutMjLayer = cc.Layer:create()
	playOutMjLayer:setSwallowsTouches(false)
	playOutMjLayer:setScale(0.9)
	self.rootNode:addChild(playOutMjLayer,PlaySceneCS.ZOrder.MJTILES-1)
	playOutMjLayer:setContentSize(gt6.winSize)
	self.playOutMjLayer = playOutMjLayer

	--提示层
	self.bigMjTileLayer = cc.Layer:create()
	self.bigMjTileLayer:setSwallowsTouches(false)
	self.rootNode:addChild(self.bigMjTileLayer, PlaySceneCS.ZOrder.MJTILES)
	self.bigMjTileLayer:setContentSize(gt6.winSize)
end

function PlaySceneCS:initDisplay( enterRoomMsgTbl ,isReplay)
	--创建一个牌桌相关的ui控件
	self:initTurnUiLayer(enterRoomMsgTbl)

	self:changePlayBg(self,7)

	local csbNode = self.rootNode
	local turnbg=gt6.seekNodeByName(csbNode,"Spr_turnPosBg")
    turnbg:setVisible(false)
     local baopai_bg = gt6.seekNodeByName(self.rootNode,"Spr_baopai_bg")
    baopai_bg:setVisible(false)

	--对应玩法名字
	local playTypeLabel = gt6.seekNodeByName(self.rootNode, "Label_playType")

	-- 设置不同人数 出牌显示的每行个数
	self.mjTilePerLine = 10 
	if self.playMaxNum == 2 then
		self.mjTilePerLine = 20 --每行20个麻将
		--条条隐藏。。。
		gt6.seekNodeByName(self.csbNode,"sp_tableLine_3"):setVisible(false)
		gt6.seekNodeByName(self.csbNode,"sp_tableLine_1"):setVisible(false)
		gt6.seekNodeByName(self.csbNode,"sp_tableLine_2"):setContentSize(cc.size(46,990))
		gt6.seekNodeByName(self.csbNode,"sp_tableLine_4"):setContentSize(cc.size(46,990))
		--玩法描述拉长
		playTypeLabel:setTextAreaSize(cc.size(700,70))
	elseif self.playMaxNum == 3 then
	else
		self.mjTilePerLine = 10
	end

	local newStrType = self.readyPlayMsg.newStrType
    playTypeLabel:setString(newStrType)
    cc.UserDefault:getInstance():setStringForKey("playType",newStrType)
    enterRoomMsgTbl.newStrType = newStrType
	-- 隐藏玩家麻将参考位置（麻将参考位置父节点，pos(0，0）)
	local playNode = gt6.seekNodeByName(self.rootNode, "Node_play")
	playNode:setVisible(false)   
	-- 隐藏轮换位置标识（东南西北信息）
	local turnPosBgSpr = gt6.seekNodeByName(self.rootNode, "Spr_turnPosBg")
    turnPosBgSpr:setVisible(false)
	for i=1,4 do
		local turnPosSpr = gt6.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. i)
		local fadeOut = cc.FadeOut:create(0.8)
		local fadeIn = cc.FadeIn:create(0.8)
		local seqAction = cc.Sequence:create(fadeOut, fadeIn)
		turnPosSpr:runAction(cc.RepeatForever:create(seqAction))
		turnPosSpr:setVisible(false)
	end
	
	-- 隐藏牌局状态（倒计时，剩余牌局，剩余牌数）
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(false)

	local cardLeftNode = gt6.seekNodeByName(roundStateNode,"Sprite_3")
	cardLeftNode:setVisible(false)

	local roundLeftNode = gt6.seekNodeByName(roundStateNode,"Sprite_4")
	roundLeftNode:setVisible(false)

	gt6.seekNodeByName(roundStateNode,"Label_remainRounds"):setVisible(false)
	gt6.seekNodeByName(roundStateNode,"Label_remainTiles"):setVisible(false)

	-- 倒计时
	self.playTimeCDLabel = gt6.seekNodeByName(roundStateNode, "Label_playTimeCD")
	self.playTimeCDLabel:setString("0")
	-- 隐藏玩家决策按钮（碰，杠，胡，过的父节点）
	local decisionBtnNode = gt6.seekNodeByName(self.rootNode, "Node_decisionBtn")
	self.rootNode:reorderChild(decisionBtnNode, PlaySceneCS.ZOrder.DECISION_BTN)
	decisionBtnNode:setVisible(false)
	-- 隐藏自摸决策暗杠，碰转明杠，自摸胡
	local selfDrawnDcsNode = gt6.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
	self.rootNode:reorderChild(selfDrawnDcsNode, PlaySceneCS.ZOrder.DECISION_BTN)
	selfDrawnDcsNode:setVisible(false)

	-- 隐藏开始胡牌决策按钮
	local decisionBtnNode = gt6.seekNodeByName(self.rootNode, "Node_start_decisionBtn")
	if decisionBtnNode then
		decisionBtnNode:setVisible( false )
	end
	-- 胡牌字隐藏
	local huBtnNode = gt6.seekNodeByName(self.rootNode, "Sprite_for_cshupaitype")
	if huBtnNode then
		huBtnNode:setVisible( false )
	end

	-- 出的牌标识动画
	local outMjtileSignNode, outMjtileSignAnime = gt6.createCSAnimation(PlaySceneCS.animPath.."OutMjtileSign.csb")
	outMjtileSignAnime:play("run", true)
	outMjtileSignNode:setVisible(false)
	self.rootNode:addChild(outMjtileSignNode, PlaySceneCS.ZOrder.OUTMJTILE_SIGN)
	self.outMjtileSignNode = outMjtileSignNode


	local Node_dabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
	Node_dabao:setVisible(false)
	local Node_dabao_bg = gt6.seekNodeByName(self.rootNode, "Spr_hun_bg")
	Node_dabao_bg:setVisible(false)	
	local notBao = gt6.seekNodeByName(self.rootNode, "notBao")
	notBao:setVisible(false)

	-- 更换背景图logo
	local logo = gt6.seekNodeByName(self.rootNode, "mahjong_mjname")
	local logoPos = cc.p(logo:getPosition())
	logo:setPosition(logoPos.x -20 ,logoPos.y - 50)
	local logoName = self.playScenePath.."playBg/logo_"..enterRoomMsgTbl.m_gameStyle..".png"
	local logoExist = cc.FileUtils:getInstance():isFileExist(logoName) 	
	if logoExist and logo then
		logo:setTexture(logoName)
		logo:setVisible(true)
		
	end

	--初始隐藏指示器
	local Node_center = gt6.seekNodeByName(self.rootNode, "Node_center")
	Node_center:setVisible(false)

	-- 读取牌面
	self.paimianNum = cc.UserDefault:getInstance():getIntegerForKey("PlayPaimian" , 1)
	local playPaibei = cc.UserDefault:getInstance():getIntegerForKey("PlayPaibei" , 2)
	self.paibeiNum = enterRoomMsgTbl.m_cardBack or playPaibei
	self.cardBg = enterRoomMsgTbl.m_cardBack or playPaibei
	local  useMine = cc.UserDefault:getInstance():getBoolForKey("CardBgMine", false)
	if useMine then
		self.paibeiNum = playPaibei
	end

	if isReplay then
		self.common_ui_layer:setVisible(false)
		self.ready_ui_layer:setVisible(false)	
	end

	if self:isCoinRoom() then
		print("isCoinRoom=====")
		
		local remainTilesLabel = gt6.seekNodeByName(roundStateNode, "Label_remainRounds")
		remainTilesLabel:setString("1/1")

		self:createSomeText(enterRoomMsgTbl)
		
		self.ready_ui_layer:setVisible(false)
		self:createCoinRoomBtn()  --创建后 先隐藏掉 关闭界面后显示出来
	
		--self.common_ui_layer:initCoinLevel(enterRoomMsgTbl)

		local hide_list = {
			"Label_playType","Label_remainRounds","spr_zhuhao","spr_di","Label_roomID"
		}
		self.common_ui_layer:hideWidget(hide_list)

		local show_list = {
			"Node_roundState"
		}
		self.common_ui_layer:showWidget(show_list)
	else

		local hide_list = {
			"Label_playType","Label_remainRounds","spr_zhuhao","spr_di"
		}
		self.common_ui_layer:hideWidget(hide_list)

		local show_list = {
			"Node_roundState","Label_roomID"
		}
		self.common_ui_layer:showWidget(show_list)
	end
	print("--->    playecene_MJ initDisplay = ")
	if enterRoomMsgTbl.m_gameZone == gt6.playGameZone.match then
		local _pos = self:getTurnPosBgPos()
		if not MTools then
			print("----> MTools 不存在")
			require("app/playMode/4MATCH/tools/MTools")
		end
		local _infoParent = gt6.seekNodeByName(self.rootNode, "Node_center")
		MTools.matchPlaySceneDifenShow( enterRoomMsgTbl , _infoParent , _pos)
	end

	local desk_str = string.format("房号 %d",enterRoomMsgTbl.m_deskId)
	self.common_ui_layer:updateRoomId(desk_str)
	local fix_list = {
		{name="Btn_quit",offest = cc.p(50,0)},
		{name="Btn_setting",offest = cc.p(100,0)},
	}
	self.common_ui_layer:fixPos(fix_list)
end

function PlaySceneCS:getTurnPosBgPos()
	local _pos = {}
	_pos.x = gt6.seekNodeByName(self.rootNode, "Spr_turnPosBg"):getPositionX()
	_pos.y = gt6.seekNodeByName(self.rootNode, "Spr_turnPosBg"):getPositionY()
	return _pos
end

function PlaySceneCS:checkGoldenId( id )
	for i,v in ipairs(g_BigType) do
		if v and v.goldId and (tonumber(v.goldId) == tonumber(id)) then
			self.playType = i - 1
			gt6.playType = self.playType
			print("the gold id is >>>>"..self.playType)
			break
		end
	end
end

function PlaySceneCS:createSomeText(msgTbl)
	--房卡创建标记
	print("--->牌桌底分 ： msgTbl.m_roomDiFen = ",msgTbl.m_roomDiFen)
	if not msgTbl.m_roomDiFen or not msgTbl.m_goldRoomType  or msgTbl.m_roomDiFen == 0  then return end
	local diFenLabel =  gt6.createTTFLabel("底分:"..msgTbl.m_roomDiFen,24)
	diFenLabel:setAnchorPoint(cc.p(0.5,0))
	diFenLabel:setName("diFenLabel")
	diFenLabel:setColor(cc.c3b(35,82,81))
	self.m_roomDiFen = msgTbl.m_roomDiFen
	self.rootNode:addChild(diFenLabel)
	local logoNode = gt6.seekNodeByName(self.rootNode, "mahjong_mjname")
	local timeLabelPos = gt6.getRealWordPosition(logoNode)
	if msgTbl.m_gameZone == gt6.playGameZone.match then
		-- diFenLabel:setPosition(cc.pAdd(timeLabelPos,cc.p(0,65)))
		diFenLabel:setVisible(false)
	else
		diFenLabel:setPosition(cc.pAdd(timeLabelPos,cc.p(0,30)))
	end


	local levelText = {"新手场","初级场","中级场","高级场","顶级场"}
	local levelLabel =  gt6.createTTFLabel("级别:"..levelText[msgTbl.m_goldRoomType-1000],18)
	levelLabel:setAnchorPoint(cc.p(0,0.5))
	self.rootNode:addChild(levelLabel)
	local spr_tableNum = gt6.seekNodeByName(self,"Label_roomID")
	local spr_tableNumPos = gt6.getRealWordPosition(spr_tableNum)
	levelLabel:setPosition(cc.pSub(spr_tableNumPos,cc.p(0,20)))

	levelLabel:setVisible(false)
end


function PlaySceneCS:onChangeMatchDifen( msgType,mathDifen, gameData )
	if not gameData then
		return
	end

	print("---> 更改比赛底分 mathDifen= ",mathDifen)
	if self.rootNode:getChildByName("diFenLabel") then
		self.rootNode:getChildByName("diFenLabel"):setString("底分:"..mathDifen)
	end

 
	dump(gameData , "---->更改比赛底分 gameData : ")
	if gameData.gameZone == gt6.playGameZone.match then
		local _pos = self:getTurnPosBgPos()
		if not MTools then
			print("----> MTools 不存在")
			require("app/playMode/4MATCH/tools/MTools")
		end
		local _infoParent = gt6.seekNodeByName(self.rootNode, "Node_center")
		local _msg = {}
		_msg.m_gameType = gameData.gameType
		_msg.m_gameZone = gameData.gameZone
		_msg.m_roomDiFen = mathDifen
		dump(_msg,"---> 更改比赛底分 : ")
		MTools.matchPlaySceneDifenShow( _msg , _infoParent , _pos)
	end
end

function PlaySceneCS:checkSpeicals( )
	--特殊显示处理
	self.m_rePosHui = false
	self.m_rePosP2 = false
	self.m_noPlayHui = false
	self.m_cancelTing = false
	self.m_fakeChupai = gt6.Jiachupai or false
	self.m_mustHu  = false
	self.m_mustHuZiMo = false
	self.m_tingGang = false
	self.m_noPlayDaBaoAnim = false
	self.m_showGuoHuTips = false -- 过胡有提示
	if g_SpeicalShow and  next(g_SpeicalShow) and not self.isReplay then
		self.m_rePosHui = gt6.checkSpecialSet(gt6.SpecialSetId.HUNZUIZUOBIAN,self.playType + 1) 
		self.m_rePosP2 = gt6.checkSpecialSet(gt6.SpecialSetId.DUIJIAPAIXUANZHUAN,self.playType + 1) 
		self.m_noPlayHui = gt6.checkSpecialSet(gt6.SpecialSetId.HUNBUKEDA,self.playType + 1) 
		self.m_cancelTing = gt6.checkSpecialSet(gt6.SpecialSetId.QUXIAOTING,self.playType + 1) 
		self.m_noChuPaiAnm = gt6.checkSpecialSet(gt6.SpecialSetId.TIAOGUOCHUPAIDONGHUA,self.playType + 1) 
		self.m_mustHu = gt6.checkSpecialSet(gt6.SpecialSetId.BUNENGGUOHU,self.playType + 1)
		self.m_mustHuZiMo = gt6.checkSpecialSet(gt6.SpecialSetId.BUNENGGUOHU_ZIMO,self.playType + 1)
		self.m_tingGang = gt6.checkSpecialSet(gt6.SpecialSetId.TINGGANG,self.playType + 1)
		self.m_noPlayDaBaoAnim = gt6.checkSpecialSet(gt6.SpecialSetId.BUBODABAOZHONG,self.playType + 1)
		self.m_showGuoHuTips = gt6.checkSpecialSet(gt6.SpecialSetId.PASSHUTIPS,self.playType + 1)
	end
end


--收到胡牌提示界面消息
function PlaySceneCS:reciveHuPaiTipsMsg(msgTbl)

	local promptDate = msgTbl.m_promptData
	if promptDate == nil or #promptDate == 0 then 

		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		if not roomPlayer.holdMjTiles or #roomPlayer.holdMjTiles == 0 then return end
		for _,v in ipairs(roomPlayer.holdMjTiles) do
			if  not tolua.isnull(v.mjTileSpr) and v.mjTileSpr ~= nil and v.mjTileSpr:getChildByName("Arrow") ~= nil then
				v.mjTileSpr:getChildByName("Arrow"):removeFromParent(true)
			end
		end
		return 
	end

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if not roomPlayer.holdMjTiles or #roomPlayer.holdMjTiles == 0 then return end

	for _,v in ipairs(roomPlayer.holdMjTiles) do
		if v.mjTileSpr ~= nil and v.mjTileSpr:getChildByName("Arrow") ~= nil then
			v.mjTileSpr:getChildByName("Arrow"):removeFromParent(true)
		end

		for _,value in ipairs(promptDate) do

			if v.mjColor == value[1][1] and v.mjNumber == value[1][2] then
				if v.mjTileSpr ~= nil then
					local arrowImg = ccui.ImageView:create("gt6_tishijiantou.png",ccui.TextureResType.plistType)
					arrowImg:setPosition(v.mjTileSpr:getContentSize().width/2,v.mjTileSpr:getContentSize().height)
					arrowImg:setName("Arrow")
					arrowImg.date = value[2]
					v.mjTileSpr:addChild(arrowImg)
					break
				end
			end
		end
	end

end

function PlaySceneCS:registerMsgs()
	-- 接收消息分发函数
	-- 房卡消息已经挪到commonMsg里了
	PlaySceneCS.super.registerMsgs(self)

	if gt6.msg_queue_switch then
		for message_id, opt_info in pairs(opt_info_lis) do
			self:registerNetMsgs(message_id, opt_info)
		end
	else
		--注册网络消息self:registerNetMsgs()
		gt6.socketClient:registerMsgListener(gt6.GC_SYNC_ROOM_STATE, self, self.onRcvSyncRoomState)
		gt6.socketClient:registerMsgListener(gt6.GC_ROUND_STATE, self, self.onRcvRoundState)
		gt6.socketClient:registerMsgListener(gt6.GC_START_GAME, self, self.onRcvStartGame)
		gt6.socketClient:registerMsgListener(gt6.GC_TURN_SHOW_MJTILE, self, self.onRcvTurnShowMjTile)
		gt6.socketClient:registerMsgListener(gt6.GC_SYNC_SHOW_MJTILE, self, self.onRcvSyncShowMjTile)
		gt6.socketClient:registerMsgListener(gt6.GC_MAKE_DECISION, self, self.onRcvMakeDecision)
		gt6.socketClient:registerMsgListener(gt6.GC_SYNC_MAKE_DECISION, self, self.onRcvSyncMakeDecision)
		gt6.socketClient:registerMsgListener(gt6.GC_ROUND_REPORT, self, self.onRcvRoundReport)
		gt6.socketClient:registerMsgListener(gt6.GC_FINAL_REPORT, self, self.onRcvFinalReport)
		gt6.socketClient:registerMsgListener(gt6.GC_START_DECISION, self, self.onRcvStartDecision)
		gt6.socketClient:registerMsgListener(gt6.GC_SYNC_START_PLAYER_DECISION, self, self.onRcvSyncStartDecision)
		gt6.socketClient:registerMsgListener(gt6.GC_SYNC_BAR_TWOCARD, self, self.onRcvLastTiles)
		gt6.socketClient:registerMsgListener(gt6.CG_SYNC_HUIPI, self, self.onRcvHunpi)  
		gt6.socketClient:registerMsgListener(gt6.MSG_S_2_C_ASK_EVENT, self, self.onReciveBeforeDeal)
		gt6.socketClient:registerMsgListener(gt6.MSG_S_2_C_RES_DOUBLE, self, self.onRcvBeforeDealRadio)
		gt6.socketClient:registerMsgListener(gt6.GC_CANNOTPLAYCARDS,self,self.onRcvCanNotPlayCards)
		gt6.socketClient:registerMsgListener(gt6.CG_SYNC_GANGPAI,self,self.onRcvGangPai)
		gt6.socketClient:registerMsgListener(gt6.GC_ASPCARD, self, self.onRcvShowASPCard)
	end 

	-- gt6.registerEventListener("TUOGUAN", self, self.onTuoGuan)
	-- gt6.registerEventListener("QUXIAOTUOGUAN",self,self.onQuXiaoTuoGuan)

	--返回大厅，解散房间事件
	gt6.registerEventListener(gt6.EventType.POKER_BACK_DISMISS, self, self.onBackOrDismiss)

end

function PlaySceneCS:skipAnimHandle(msg)
	if msg.m_msgId == gt6.GC_START_GAME then
		print("PlaySceneCS:skipAnimHandle=")
		self:stopAllActions()

		if self.common_ui_layer then
			local node = self.common_ui_layer:getChildByName(PlaySceneCS.NODE_NAME.BOARD_START_ANI_NAME)
			if node then
				node:removeFromParent()
			end
		end

		if self.playMjLayer then 
			local children_list = self.playMjLayer:getChildren()
			local list = {}
			for i, node in ipairs(children_list) do
				if node.gaetName and node:getName() == PlaySceneCS.NODE_NAME.SEND_CARD_ANI_NAME then
					table.insert(list,node)
				end 
			end

			for _,node in ipairs(list) do 
				print("delet=skipAnimHandle=")
				node:removeFromParent()
			end 

			list = {}

			self:boardStartAfter()
		end 
	end 
end
-- 更换牌面
function PlaySceneCS:changePaiMianCallBack(node,bgIndex)
	print("更换牌面" .. bgIndex)
	if self.paimianNum ~= bgIndex then
		self.paimianNum = bgIndex

		-- 刷新屏幕上的选项
		for i,v in ipairs(self.allCardSprites) do
			if v[2] and not tolua.isnull(v[2]) then
				print(v[1], v[1])
				local mjName = v[1]
				local splits = string.split(v[1], "|")
				dump(splits)
				if #splits > 1 then
					mjName = splits[2]
				end
				print("mjName", mjName)
				if self.paimianNum == 1 then
					v[1] = "s|" .. mjName
				elseif self.paimianNum == 2 then
					v[1] = "b|" .. mjName
				end
				self:setSpriteFrame(v[3], v[2])
			end
		end			
	end
end

-- 更换牌面
function PlaySceneCS:changePaiBeiCallBack(node,bgIndex)
	print("更换牌背" .. bgIndex)
	bgIndex = self.cardBg
	local  isUseMine = cc.UserDefault:getInstance():getBoolForKey("CardBgMine", false)
	-- 只看自己或者自己是房主时
	if isUseMine or 1 == self.playerSeatIdx then
		bgIndex = cc.UserDefault:getInstance():getIntegerForKey("PlayPaibei", 2)
	end

	if self.paibeiNum ~= bgIndex then
		self.paibeiNum = bgIndex
		gt6.checkLoadPaiBei(bgIndex)

		-- 刷新屏幕上的选项
		for i,v in ipairs(self.allCardSprites) do
			if v[2] and not tolua.isnull(v[2]) then
				self:setSpriteFrame(v[3], v[2])
			end
		end	
	end
end

--不可出的牌
function PlaySceneCS:onRcvCanNotPlayCards(msgTbl)
	self.m_canNotPlay = msgTbl.m_disableCards
	self:sortPlayerMjTiles()
	print("onRcvCanNotPlayCards..")
	dump(self.m_canNotPlay)
end

-- 初始化会
function PlaySceneCS:setHuiPi(data)
	print("function PlaySceneCS:setHuiPi(data)")
	-- 混
	self.m_hui = {}	
	if data.m_huiColor and data.m_huiNum then
		self.m_hui[#self.m_hui + 1] = {data.m_huiColor, data.m_huiNum}
	end
	if data.m_huipiColor and data.m_huipiNum and
	   data.m_huipiColor ~= 0 and data.m_huipiNum ~= 0 then
		local Node_dabao_bg = gt6.seekNodeByName(self.rootNode, "Spr_hun_bg")
		local Node_dabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
		local Spr_mjTile = gt6.seekNodeByName(Node_dabao, "Spr_mjTile")
	    local baoBg = gt6.seekNodeByName(self.rootNode,"Spr_baopai_bg")
	    baoBg:setVisible(false)
		Node_dabao_bg:setVisible(true)
		Node_dabao:setVisible(false)
		Spr_mjTile:setVisible(false)
	
		local color = tonumber(data.m_huipiColor)
		local number = tonumber(data.m_huipiNum)
		local data = {}
		data.showType = "HUN"
		data.mjColor = color
		data.mjNumber = number
		data.otherCards = self.m_hui
		self:showSpecialCards(data)	
	end

	-- 刷新屏幕上的选项
	for i,v in ipairs(self.allCardSprites) do
		if v[2] and not tolua.isnull(v[2]) then
			self:addMJflag(v[3], v[2])
		end
	end
	self:sortPlayerMjTiles()
end

--添加左上位置特殊牌点击tips效果
function PlaySceneCS:addSpecialCardTip(touchSp,cardTable)
	if not cardTable or not next(cardTable) then return end 
	local function onTouchBegan(touch,eventt)
		if not self.m_startGame then return end
		local touchPos = touchSp:getParent():convertToNodeSpace(touch:getLocation())
		local rect = touchSp:getBoundingBox()
		if not cc.rectContainsPoint(rect, touchPos) then
			return false
		end
		local bgNum = #cardTable
		local imageBG = ccui.ImageView:create("gt6_square1_bd.png",ccui.TextureResType.plistType)
		imageBG:setName("SpecialCardTip")
		imageBG:ignoreContentAdaptWithSize(true)
		imageBG:setScale9Enabled(true)
		imageBG:setCapInsets(cc.rect(20,20,92,130))
		imageBG:setAnchorPoint(cc.p(0,0.5))
		imageBG:setContentSize(cc.size((touchSp:getContentSize().width)*(bgNum),touchSp:getContentSize().height-10))
		local wordPos = gt6.getRealWordPosition(touchSp)
		imageBG:setPosition(wordPos.x+touchSp:getContentSize().width/2,wordPos.y + 5)
		self:addChild(imageBG,PlaySceneCS.ZOrder.MJTILES)
		self:specialTipHui(imageBG,cardTable)
		return true
	end
	local function onTouchMoved(touch,eventt)
		
	end
	local function onTouchEnded(touch,eventt)
		local imageBG = self:getChildByName("SpecialCardTip")
		self:removeChildByName("SpecialCardTip")
	end

	local function onTouchCancel(touch,eventt)
		onTouchEnded(onTouchEnded)
	end
	if touchSp ~= nil and touchSp:isVisible() then
		-- 触摸事件
		self.specialListener = cc.EventListenerTouchOneByOne:create()
		self.specialListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		self.specialListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
		self.specialListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
		self.specialListener:registerScriptHandler(onTouchCancel, cc.Handler.EVENT_TOUCH_CANCELLED)
		local eventDispatcher = touchSp:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(self.specialListener,touchSp)
	end
end

--特殊牌”会“tips生成检测
function PlaySceneCS:specialTipHui(imageBG,cardTable)
	print("bao~~~")
	dump(cardTable)
	for i=1,#cardTable  do
		local mjTempName = self:getMJTileResName(4, cardTable[i][1],cardTable[i][2])
		local mjTempSpr = self:createWithSpriteFrameName(mjTempName)
		mjTempSpr:setScale(0.8)
		mjTempSpr:setPosition(imageBG:getContentSize().width/(#cardTable)*(i-1+0.5),imageBG:getContentSize().height/2)
		imageBG:addChild(mjTempSpr)
	end
end


function PlaySceneCS:onRcvGangPai( msgTbl )
	if msgTbl.m_gc ~= 0  and msgTbl.m_gn ~= 0 then
		local Node_dabao_bg = gt6.seekNodeByName(self.rootNode, "Spr_hun_bg")
		local Node_dabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
		local Spr_mjTile = gt6.seekNodeByName(Node_dabao, "Spr_mjTile")
	    local baoBg = gt6.seekNodeByName(self.rootNode,"Spr_baopai_bg")
	    baoBg:setVisible(false)
		Node_dabao_bg:setVisible(true)
		Node_dabao:setVisible(false)
		Spr_mjTile:setVisible(false)
	
		local color = tonumber(msgTbl.m_gc)
		local number = tonumber(msgTbl.m_gn)
		local data = {}
		data.showType = "GANG"
		data.mjColor = color
		data.mjNumber = number
		self:showSpecialCards(data)	
	end
end

--接收混
function PlaySceneCS:onRcvHunpi(msgTbl)
	print("onRcvHunpi")
	local Node_dabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
	local Spr_mjTile = gt6.seekNodeByName(Node_dabao, "Spr_mjTile")
	local notBao = gt6.seekNodeByName(self.rootNode, "notBao")
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(1)
	Node_dabao:setVisible(false)
	-- 播放打宝动画
	local csbNode = nil
	local action = nil
	local actionName = nil
	csbNode, action = gt6.createCSAnimation(PlaySceneCS.animPath.."hunpi2.csb")
	actionName = "hunpi2"
	csbNode:setPosition(gt6.winCenter)
	self:addChild(csbNode,PlaySceneCS.ZOrder.MJTILES)
	action:play(actionName, false)
	action:setFrameEventCallFunc(function(frame)
		csbNode:removeFromParent()
	end) 
	self:setHuiPi(msgTbl)
end

function PlaySceneCS:unregisterAllMsgListener()
	PlaySceneCS.super.unregisterAllMsgListener(self)

	gt6.removeTargetAllEventListener(self)
	print("PlaySceneCS:unregisterAllMsgListener")
	-- 注销监听
	if self.schedulerEntry then
		gt6.scheduler:unscheduleScriptEntry(self.schedulerEntry)
		self.schedulerEntry = nil
	end		
end

function PlaySceneCS:onNodeEvent(eventName)
	if "enter" == eventName then
		
		print("==xxx==onNodeEvent==enter")
		-- 触摸事件
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		listener:registerScriptHandler(handler(self, self.onTouchCancel), cc.Handler.EVENT_TOUCH_CANCELLED)
		local eventDispatcher = self.playMjLayer:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.playMjLayer)

		--大牌提示层
		local listener_big = cc.EventListenerTouchOneByOne:create()
		listener_big:registerScriptHandler(handler(self, self.onTouchBegan_big), cc.Handler.EVENT_TOUCH_BEGAN)
		listener_big:registerScriptHandler(handler(self, self.onTouchMoved_big), cc.Handler.EVENT_TOUCH_MOVED)
		listener_big:registerScriptHandler(handler(self, self.onTouchEnded_big), cc.Handler.EVENT_TOUCH_ENDED)
		listener_big:registerScriptHandler(handler(self, self.onTouchCancel_big), cc.Handler.EVENT_TOUCH_CANCELLED)
		local eventDispatcher_big = self.bigMjTileLayer:getEventDispatcher()
		eventDispatcher_big:addEventListenerWithSceneGraphPriority(listener_big, self.bigMjTileLayer)


		-- 逻辑更新定时器
		self.scheduleHandler = gt6.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)

		gt6.soundEngine:playMusic("bgm2", true)

		local function onEvent1(event)
			self:setOutGameTimeStamp()
	    end
	    self._listener1 = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", onEvent1)
	    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	    eventDispatcher:addEventListenerWithFixedPriority(self._listener1, 1)
	 	local function onEvent2(event)

 			--如果鼠标正在拖动，将牌放回原来的位置 不出牌
			if self.isTouchBegan then
				if self.chooseMjTile and self.chooseMjTile.mjTileSpr and self.playMjLayer then
					self.chooseMjTile.mjTileSpr:setPosition(self.mjTileOriginPos)
					self.playMjLayer:reorderChild(self.chooseMjTile.mjTileSpr, self.mjTileOriginPos.y)
				end

				self.isTouchBegan = false
				self.isTouchMoved = false
			end

			local runOffTime = self:countRunOffTime()
			self.playTimeCD = self.playTimeCD - runOffTime

			if gt6.msg_queue_switch then
				local action = performWithDelay(self, function()
					gt6.GameMsgQueueManager:skipAnimation()
				end, 0.2)
			end
			
			
			print("xxx==xxxx===xxxxss"..tostring(self.playTimeCD))

	    end
	    self.foregroundEvent = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", onEvent2)
	    eventDispatcher:addEventListenerWithFixedPriority(self.foregroundEvent, 1)
	    gt6.ChatLog = {}
	elseif "exit" == eventName then
		self.register_opt_list = {}
		gt6.GameMsgQueueManager:resetQueue()

		gt6.isMatch = nil
		gt6.removeTargetAllEventListener(self)
		local eventDispatcher = self.playMjLayer:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self.playMjLayer)
		local eventDispatcher_big = self.bigMjTileLayer:getEventDispatcher()
		eventDispatcher_big:removeEventListenersForTarget(self.bigMjTileLayer)

		gt6.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		
		if self.lastFourHandler then
			gt6.scheduler:unscheduleScriptEntry(self.lastFourHandler)
			self.lastFourHandler = nil
		end
		if self.schedulerEntry then
			gt6.scheduler:unscheduleScriptEntry(self.schedulerEntry)
				self.schedulerEntry = nil
			end
		gt6.soundEngine:playMusic("bgm1", true)

		if self._listener1 then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(self._listener1)
			self._listener1 = nil
		end
		
		if self.foregroundEvent then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(self.foregroundEvent)				
			self.foregroundEvent = nil
		end
		
		print("====gt6.PlayersManager--clear")
		gt6.PlayersManager:clear()
	end

end


--检测触摸放大
function PlaySceneCS:checkTouchToScaleMjTiles(touch)
	if self.bigMjTileLayer then 
		self.bigMjTileLayer:removeAllChildren()
	end

	local touchMjTile, mjTileIdx = self:touchPlayerMjTiles(touch)
	if touchMjTile and mjTileIdx  then
		return true
	end
	local bigMjTileTable  = {}
	local function checkOutMjTiles( )
		local room_players = gt6.PlayersManager:getAllRoomPlayers()
		for _, roomPlayer in pairs(room_players) do 
			if roomPlayer.outMjTiles and next(roomPlayer.outMjTiles) then  
				for k , mjTile in pairs(roomPlayer.outMjTiles)  do --已出牌
					if mjTile and mjTile.mjTileSpr and not tolua.isnull(mjTile.mjTileSpr) then 
						local touchPoint = mjTile.mjTileSpr:convertTouchToNodeSpace(touch)
						local mjTileSize = mjTile.mjTileSpr:getContentSize()
						local mjTileRect = cc.rect(0, 0, mjTileSize.width, mjTileSize.height)
						if cc.rectContainsPoint(mjTileRect, touchPoint) then
							for __, mjTile2 in pairs(roomPlayer.outMjTiles) do 
								table.insert(bigMjTileTable,{mjTile2.mjColor, mjTile2.mjNumber})
							end
							return
						end
					end
				end
			end
		end
	end
	local function checkCPGMjTiles()
		local room_players = gt6.PlayersManager:getAllRoomPlayers()
		for _, roomPlayer in pairs(room_players) do 
			if roomPlayer.mjTileCPG and next(roomPlayer.mjTileCPG) then 
				for k , mjTile in pairs(roomPlayer.mjTileCPG)  do --已出牌
					for key ,v in pairs(mjTile) do 
						if v and v.spr and not tolua.isnull(v.spr) then 
							local touchPoint = v.spr:convertTouchToNodeSpace(touch)
							local mjTileSize = v.spr:getContentSize()
							local mjTileRect = cc.rect(0, 0, mjTileSize.width, mjTileSize.height)
							if cc.rectContainsPoint(mjTileRect, touchPoint) then
									for index , value in pairs(mjTile) do 
										table.insert(bigMjTileTable,{value.mjColor,value.mjNumber})
									end
								return
							end
						end
					end
				end
			end
		end
	end
	--遍历出的牌
	checkOutMjTiles()
	--遍历吃碰杠
	checkCPGMjTiles()
	if #bigMjTileTable ~= 0 then 
		self.m_bigMjTileBg = ccui.ImageView:create("gt6_btmjbg_lzoom.png",ccui.TextureResType.plistType)
		self.m_bigMjTileBg:setScale9Enabled(true)
		self.m_bigMjTileBg:setAnchorPoint(0.5,0.5)
		self.m_bigMjTileBg:setCapInsets(cc.rect(15,15,30,30))
		self.m_bigMjTileBg:setPosition(gt6.winCenter)
		self.bigMjTileLayer:addChild(self.m_bigMjTileBg,PlaySceneCS.ZOrder.SETTING)
		local mjTileName = self:getMJTileResName( 4, 1, 1, 1)
		local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
		local totlaLenght = mjTileSpr:getContentSize().width * (#bigMjTileTable)
		local  lengthBg = ccui.ImageView:create()
		lengthBg:setScale9Enabled(true)
		lengthBg:setAnchorPoint(0.5,0.5)
		self.bigMjTileLayer:addChild(lengthBg,PlaySceneCS.ZOrder.SETTING)
		local mjTilePerRow  = 10 
		local totalRow = math.ceil(#bigMjTileTable/mjTilePerRow)
		if #bigMjTileTable > mjTilePerRow then 
			lengthBg:setContentSize(cc.size(mjTileSpr:getContentSize().width*mjTilePerRow,mjTileSpr:getContentSize().height*totalRow))
		else
			lengthBg:setContentSize(cc.size(totlaLenght,mjTileSpr:getContentSize().height))
		end
		self.m_bigMjTileBg:setContentSize(cc.size(lengthBg:getContentSize().width + 20 , lengthBg:getContentSize().height + 20))
		lengthBg:setPosition(gt6.winCenter)

		local row = 1 --行
		local col = 1 --列
		dump(bigMjTileTable)
		for index, bigmjTile in ipairs(bigMjTileTable) do 
			if bigmjTile then 
				local mjTileName  = nil 
				local mjTileSpr  = nil 
				if bigmjTile[1] == 0 or bigmjTile[2] == 0 then 
					mjTileSpr = ccui.ImageView:create("gt6_1MJ_spBack_y_.png",ccui.TextureResType.plistType)
				else
					mjTileName = self:getMJTileResName( 4, bigmjTile[1], bigmjTile[2], 1)
					mjTileSpr = self:createWithSpriteFrameName(mjTileName)
				end
				mjTileSpr:setAnchorPoint(cc.p(0,1))
				mjTileSpr:setPosition(mjTileSpr:getContentSize().width*(col-1),  mjTileSpr:getContentSize().height*(totalRow - row + 1))
				lengthBg:addChild(mjTileSpr)
				col = col + 1 
				if col == 11 then
					row = row + 1
					col = 1
				end
			end
		end
		return true
	end
	return false	
end

--点击n次发聊天
function PlaySceneCS:checkTouchToSendChat( touch )
	if not self.isPlayerShow and not self.isPlayerDecision  then 
		self.m_touchedTimes = self.m_touchedTimes + 1
		 if self.m_touchedTimes >= gt6.touchTimesSendChat then 
		 	local msgToSend = {}
			msgToSend.m_msgId = gt6.CG_CHAT_MSG
			msgToSend.m_type = 1
			msgToSend.m_id = gt6.touchTosendChatId[math.random(1,#gt6.touchTosendChatId)]
			msgToSend.m_msg = ""
			gt6.socketClient:sendMessage(msgToSend)
			self.m_touchedTimes = 0 
			print("touched nnnnn times >>>> chat sended>>>>>")
		end
	end
end
 
--大牌提示层的触摸@begin
function PlaySceneCS:onTouchBegan_big( touch,event )
	print("onTouchBegan_big>>>>>>>")
	gt6.showBigMjTile = false
	if gt6.showBigMjTile and self.m_startGame then 
		local isTouchMj = self:checkTouchToScaleMjTiles(touch) --是否放大麻将
		if not isTouchMj then 
			self:checkTouchToSendChat(touch) --点击n次后发聊天
		end
	end
	return true
end

function PlaySceneCS:onTouchMoved_big( touch )

end

function PlaySceneCS:onTouchEnded_big( touch )
	if self.bigMjTileLayer then 
		self.bigMjTileLayer:removeAllChildren()
	end
end
function PlaySceneCS:onTouchCancel_big( touch )
	if self.bigMjTileLayer then 
		self.bigMjTileLayer:removeAllChildren()
	end
end
--大牌提示层的触摸@end


--拍桌的touch事件
function PlaySceneCS:onTouchBegan(touch, event)
	print("onTouchBegan>>>>>>>",self.isTouchBegan)

	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	if self.isTouch == false then
		return false
	end

	if self.isOpeningAim then
		return false
	end

	if self.huTipLayout ~= nil then
		self.huTipLayout:setVisible(false)
	end
	if self.isTouchBegan then
		print("PlaySceneCS:onTouchBegan 111111 ")
		return false
	end
	--not self.isPlayerShow 
	if self.isPlayerDecision then
		print("PlaySceneCS:onTouchBegan 222222 isPlayerShow = "..tostring(self.isPlayerShow)..", isPlayerDecision="..tostring(self.isPlayerDecision))
		return false
	end
	if self.isTing and not self.isPlayerShow then
		print("PlaySceneCS:onTouchBegan 333333 ")
		return false
	end
	local touchMjTile, mjTileIdx = self:touchPlayerMjTiles(touch)
	if touchMjTile ==nil then return   end
	if not touchMjTile or (self.isTing and (mjTileIdx ~= #room_players[self.playerSeatIdx].holdMjTiles)) then
		print("PlaySceneCS:onTouchBegan 444444 ")
		return false
	end

	-- 听操作除听得牌其它牌不可点
	local roomPlayer = room_players[self.playerSeatIdx]
	local onTOuchPoint = true
	if roomPlayer.m_ting and #roomPlayer.m_ting > 0 then
		print("听操作除听得牌其它牌不可点")
		local hasCard = false
		for _, tingCard in ipairs(roomPlayer.m_ting) do
			if tingCard[1] == touchMjTile.mjColor and tingCard[2] == touchMjTile.mjNumber then
				print("可听的牌")
				hasCard = true
				break
			end
		end
		if not hasCard then
			print("PlaySceneCS:onTouchBegan 555555 ")
			return false
		end
	end

	if self.m_tingState and self.m_isTingPai == 1 then
		print("ting touch not ........")
		return false
	end	
	-- 记录原始位置
	self.horizontal =nil --触摸点初始化
	self.isShowMjTile=nil  --是否已经进行了第一次点击
	self.isTouchMoved=false 
	self.isDrag=false --是否拖拽过
	self.playMjLayer:reorderChild(touchMjTile.mjTileSpr, gt6.winSize.height + 20000) --order fix 
	self.chooseMjTile = touchMjTile   --点击的麻将数据
	self.chooseMjTileIdx = mjTileIdx  --点击的第x张麻将
	touchMjTile.mjTileSpr.pos = cc.p(touchMjTile.mjTileSpr:getPosition()) 
	self.preTouchPoint = self.playMjLayer:convertTouchToNodeSpace(touch) --点击点的位置
	
	if self.chooseMjTile ~= self.preClickMjTile then --如果选中的不是之前选中的麻将
		self.mjTileOriginPos = cc.p(touchMjTile.mjTileSpr:getPosition())  --记录当前选中麻将的位置
		local mjTilePos = cc.p(self.chooseMjTile.mjTileSpr:getPosition())
		local moveAction = cc.MoveTo:create(0.05, cc.p(mjTilePos.x, self.mjTileOriginPos.y + 26))
		self.chooseMjTile.mjTileSpr:runAction(moveAction)
		self:updateOutCardColor(self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, true)

		-- 上一次点中的复位
		if self.preClickMjTile  and self.preClickMjTile.mjTileSpr and not tolua.isnull( self.preClickMjTile.mjTileSpr ) then
			local mjTilePos2 = cc.p(self.preClickMjTile.mjTileSpr:getPosition())
			self.preClickMjTile.mjTileSpr:setPosition(mjTilePos2.x,self.mjTileOriginPos.y)
		end

		self:openHuTip(self.chooseMjTile)
		if self.chooseMjTile.mjTileSpr:getChildByName("Arrow") ~= nil then
			self.chooseMjTile.mjTileSpr:getChildByName("Arrow"):setVisible(true)
		end
	elseif self.chooseMjTile == self.preClickMjTile  then --如果是双击同一个麻将
		if self.preClickMjTile.autoMove then --是自动上移
			self.preClickMjTile.autoMove = false
		else
			if self:isTurnMe() then
				self.isShowMjTile =true --出牌标记
				self:openHuTip(self.chooseMjTile)
				if self.chooseMjTile.mjTileSpr:getChildByName("Arrow") ~= nil then
					self.chooseMjTile.mjTileSpr:getChildByName("Arrow"):setVisible(true)
				end
			end
			
		end
	end
	self.isTouchBegan=true
	return true
end

function PlaySceneCS:onTouchMoved(touch, event)
	print("PlaySceneCS:onTouchMoved")
	if self.isTouch == false then
		return false
	end
	local touchPoint = self.playMjLayer:convertTouchToNodeSpace(touch)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	local touchMjTile, mjTileIdx = self:touchPlayerMjTiles(touch)
	--听牌屏蔽
	if touchMjTile and (self.isTing and (mjTileIdx ~= #gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx).holdMjTiles)) then 
		print("PlaySceneCS:onTouchMoved 444444 ")
		return 
	end

	self.horizontal=touchPoint.y-self.preTouchPoint.y
	print("self.horizontal", self.horizontal)
	if self.horizontal<40  then  --如果触摸点与初始触摸点的y轴差小于40，则认定非拖拽，是滑动
		if self.isDrag and self.dragPos then --如果这个牌拖拽过，全部复位，从touchbegan开始
			self.isTouchBegan=false
			self.chooseMjTile.mjTileSpr:setPosition(self.dragPos.x ,self.mjTileOriginPos.y) 
			if self.chooseMjTile.mjTileSpr:getChildByName("Arrow") ~= nil then
				self.chooseMjTile.mjTileSpr:getChildByName("Arrow"):setVisible(true)
			end
			self.preClickMjTile=nil
			self.mjTileOriginPos=nil
			self.chooseMjTile=nil
			self.isDrag=false
			self:onTouchBegan(touch,event)
			print("darg>>>>")
			return
		end
		-- 听牌拖动
		if  roomPlayer.m_ting and #roomPlayer.m_ting > 0 then
		print("听操作除听得牌其它牌不可点2222")
			return 
		end
		--直接滑动
		if touchMjTile and touchMjTile  ~= self.chooseMjTile then
			self.preClickMjTile=self.chooseMjTile 
			self.playMjLayer:reorderChild(touchMjTile.mjTileSpr, gt6.winSize.height+20000)
			self.chooseMjTile = touchMjTile   --点击的麻将数据
			self.chooseMjTileIdx = mjTileIdx  --点击的第x张麻将 
			self.mjTileOriginPos = cc.p(touchMjTile.mjTileSpr:getPosition()) --点击的麻将sp的位置
			self.preTouchPoint = self.playMjLayer:convertTouchToNodeSpace(touch) --点击点的位置
			touchMjTile.mjTileSpr.pos = cc.p(touchMjTile.mjTileSpr:getPosition()) 

			local mjTilePos = cc.p(self.chooseMjTile.mjTileSpr:getPosition())
			local moveAction = cc.MoveTo:create(0.05, cc.p(mjTilePos.x, self.mjTileOriginPos.y + 26))
			self.chooseMjTile.mjTileSpr:runAction(moveAction)
			self:updateOutCardColor(self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, true)

			if self.preClickMjTile then
				local mjTilePos2 = cc.p(self.preClickMjTile.mjTileSpr:getPosition())
				local moveAction2 = cc.MoveTo:create(0.05, cc.p(mjTilePos2.x, mjTilePos2.y - 26))
				self.preClickMjTile.mjTileSpr:runAction(moveAction2)
			end
			self:openHuTip(self.chooseMjTile)
			if self.chooseMjTile.mjTileSpr:getChildByName("Arrow") ~= nil then
				self.chooseMjTile.mjTileSpr:getChildByName("Arrow"):setVisible(true)
			end
		end
	else --大于40，认定为拖拽
		if self.chooseMjTile ~= nil  and self.chooseMjTile.mjTileSpr ~= nil and not tolua.isnull(self.chooseMjTile.mjTileSpr) and self.chooseMjTile.mjTileSpr.pos ~= nil and touchPoint ~= nil then
			if self.huTipLayout ~= nil then
				self.huTipLayout:setVisible(false)
			end

			if self.chooseMjTile.mjTileSpr:getChildByName("Arrow") ~= nil then
				self.chooseMjTile.mjTileSpr:getChildByName("Arrow"):setVisible(false)
			end

			if not self.isDrag then --如果是第一次触摸拖拽，记录原始位置
				self.dragPos=cc.p(self.chooseMjTile.mjTileSpr:getPosition())
			end
			self.isDrag=true
			self.playMjLayer:reorderChild(self.chooseMjTile.mjTileSpr, gt6.winSize.height+20000)
			self.chooseMjTile.mjTileSpr:setPosition(touchPoint)
		end
	end
end

function PlaySceneCS:onTouchCancel(touch, event)
	self:onTouchEnded(touch, event);
end

function PlaySceneCS:onTouchEnded(touch, event)
	print("PlaySceneCS:onTouchEnded")

	self.isTouchBegan=false
	self.preClickMjTile=self.chooseMjTile
	if self.horizontal and self.horizontal~=0 and  self.horizontal <40 then --滑动不做出牌操作，直接return
		return

	elseif self.horizontal and  self.horizontal >=40 then --大于40直接出牌
		self.isShowMjTile=true
	else
		
	end
	
	if self.isShowMjTile and self.chooseMjTile  then
		if self.huTipLayout ~= nil then
			self.huTipLayout:setVisible(false)
		end
		self.dragPos=nil
		self.isShowMjTile =false
		-- -- 发送出牌消息
		local msgToSend = {}
		msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
		-- 出牌标识
		msgToSend.m_type = 1
		msgToSend.m_think = {}
		local think_temp = {self.chooseMjTile.mjColor,self.chooseMjTile.mjNumber}
		table.insert(msgToSend.m_think,think_temp)
		gt6.socketClient:sendMessage(msgToSend)	
		local roomPlayer = self:getRoomPlayer(self.playerSeatIdx)	
		-- if self.isTouch == true then 
		-- self:FN_PlayCardAnimation(roomPlayer)
	    -- end
		if roomPlayer.holdMjTiles and #roomPlayer.holdMjTiles ~= 0 then 
			for _,v in ipairs(roomPlayer.holdMjTiles) do
				if v.mjTileSpr ~= nil and v.mjTileSpr:getChildByName("Arrow") ~= nil then
					v.mjTileSpr:getChildByName("Arrow"):removeFromParent(true)
				end
			end
		end

		--删除“取消听”按钮
		if self.rootNode:getChildByName("CANCELTINGBTN") then
			self.rootNode:removeChildByName("CANCELTINGBTN")
		end

		self:updateOutCardColor(self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, false)

		self.isPlayerShow = false
		self.preClickMjTile = nil
		-- 停止倒计时音效
		if self.playCDAudioID and self.playTimeCD > 0.1 then --音乐自动停止和手动打断在同一帧会有问题
			gt6.soundEngine:stopEffect(self.playCDAudioID)
			self.playCDAudioID = nil
		end

		if self.onUnpauseScheduler then
			self:stopActionByTag(PlaySceneCS.SPPARAMS.AUTO_PLAY)
			self.onUnpauseScheduler = nil
		end

		if self.m_isTingPai == 1 then
			self.m_tingState = true
		else
			self.m_tingState = false
		end
	end
end

--打牌动画添加
function PlaySceneCS:FN_PlayCardAnimation(roomPlayer)
   
	local  mjColor = self.chooseMjTile.mjColor
	local  mjNumber = self.chooseMjTile.mjNumber
	local mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber)
	self.ai_mjTileSpr = self:createWithSpriteFrameName(mjTileName)
	self.ai_mjTileSpr:setPosition(self.chooseMjTile.mjTileSpr:getPosition())
    self.chooseMjTile.mjTileSpr:setVisible(false)
	local mjTile = {}
	mjTile.mjTileSpr = self.ai_mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	table.insert(roomPlayer.outMjTiles, mjTile)

	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos,layer = self:countOutMjPoint(roomPlayer,mjTilesReferPos)
	local zOrder = self:countOutMjZorder(roomPlayer.displaySeatIdx,mjTilePos,layer) 
	self.playMjLayer:addChild(self.ai_mjTileSpr,zOrder)
	local callFunc = cc.CallFunc:create(function()
		self.chooseMjTile.mjTileSpr:setScale(1)
		self.chooseMjTile.mjTileSpr:setVisible(true)
		table.remove(roomPlayer.outMjTiles,#roomPlayer.outMjTiles)
		-- if not self:isPlayerSeat(seatIdx) then
		-- 	return
		-- end

		-- 发送出牌消息
		local msgToSend = {}
		msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
		-- 出牌标识
		msgToSend.m_type = 1
		msgToSend.m_think = {}
		local think_temp = {self.chooseMjTile.mjColor,self.chooseMjTile.mjNumber}
		table.insert(msgToSend.m_think,think_temp)
		gt6.socketClient:sendMessage(msgToSend)
	end)

	local sequenceAction = cc.Sequence:create(
		cc.MoveBy:create(0.1,cc.p(0,80)),
		cc.Spawn:create(
			cc.EaseSineIn:create(cc.MoveTo:create(0.1,mjTilesReferPos.showMjTilePos)),
			cc.ScaleTo:create(0.3,1.2)
		),
		cc.DelayTime:create(0.5),
		cc.ScaleTo:create(0,1),
		-- cc.Spawn:create(
		-- 	cc.EaseSineIn:create(cc.MoveTo:create(0.1,mjTilePos)),
		-- 	cc.ScaleTo:create(0.3,0.66)
		-- ),
		callFunc
	)
	-- self.chooseMjTile.mjTileSpr:runAction(sequenceAction)
	self.ai_mjTileSpr:runAction(sequenceAction)
end

--打牌落地动画
function PlaySceneCS:FN_PlayDropCardAnimation(data)
	local seatIdx = data.seatIdx
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	if not roomPlayer then
		return false
	end
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos,layer = self:countOutMjPoint(roomPlayer,mjTilesReferPos)
	local zOrder = self:countOutMjZorder(roomPlayer.displaySeatIdx,mjTilePos,layer) 
	local sequenceAction = cc.Sequence:create(
		cc.Spawn:create(
			cc.EaseSineIn:create(cc.MoveTo:create(0.1,mjTilePos)),
			cc.ScaleTo:create(0.3,0.66)
		)
	)
	self.ai_mjTileSpr:runAction(sequenceAction)
end



function PlaySceneCS:playCardEffect(_spr)
	_spr:setColor(PlaySceneCS.SPPARAMS.HUANGSE)
end

function PlaySceneCS:stopCardEffect(_spr)
	_spr:setColor(cc.WHITE)
end


-- 刷新所有同样的牌颜色
function PlaySceneCS:updateOutCardColor(_color, _number, _isChange)
	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	for i, roomPlayer in ipairs(room_players) do
		table.foreach(roomPlayer.outMjTiles, function(k, mjTile)
			if mjTile and mjTile.mjTileSpr then
				if mjTile.mjColor == _color and mjTile.mjNumber == _number and _isChange then
					self:playCardEffect(mjTile.mjTileSpr)
				else
					self:stopCardEffect(mjTile.mjTileSpr)
				end
			end
		end)
		table.foreach(roomPlayer.mjTileCPG, function(k, mjTiles)
			if mjTiles and next(mjTiles) then
				table.foreach(mjTiles, function(m, mjTile)
					if mjTile.mjColor == _color and mjTile.mjNumber == _number and _isChange then
						self:playCardEffect(mjTile.spr)
					else
						self:stopCardEffect(mjTile.spr)
					end
				end)
			end
		end)
	end

	-- 听后打出相同的牌  另一张置灰
	if self.m_isTingPai == 1 and not _isChange then
		local roomPlayer = room_players[self.playerSeatIdx]
		for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
			mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
		end
	end	
end

function PlaySceneCS:update(delta)
	-- 更新倒计时
	self:playTimeCDUpdate(delta)
	self.common_ui_layer:update(delta)

	if gt6.msg_queue_switch then
		gt6.GameMsgQueueManager:update(delta)
	end 
	
end

function PlaySceneCS:onRcvLastTiles(msgTbl)
	if not msgTbl.m_operates or not next(msgTbl.m_operates) then return end 
	self.m_roundDelay = 5 	
	-- 海底捞动画
	if msgTbl.m_type and msgTbl.m_type == 1 then
		self:playLastFourCards(msgTbl)
	else
		local csbNode, action = gt6.createCSAnimation(PlaySceneCS.animPath.."haidilaoyue.csb")
		csbNode:setPosition(cc.p(display.cx, display.cy))
		gt6.soundEngine:playEffect("common/haidilaoyue")
		action:play("haidilaoyue", false)
		action:setFrameEventCallFunc(function(frame)
			csbNode:removeFromParent()
			self:playLastFourCards(msgTbl)
		end)
		self:addChild(csbNode,PlaySceneCS.ZOrder.HAIDILAOYUE)
	end
end

--TIPS:
--海底捞月
function PlaySceneCS:playLastFourCards(msgTbl)
    local fourTileLayer = cc.Layer:create()
    fourTileLayer:setContentSize(gt6.winSize)
    fourTileLayer:setName("fourTileLayer")
    self.playMjLayer:addChild(fourTileLayer, PlaySceneCS.SPPARAMS.MJMAXORDER*10)

	local lastHuTypes = msgTbl.m_hu
	local lastFourCards = msgTbl.m_operates
	local lastIndex = 1
        
	local playLastFour = function ()
		gt6.log("调用次数" .. lastIndex)
		if lastIndex <= #lastFourCards then
			local oper = lastFourCards[lastIndex]
			local seatId = oper[1] + 1
			local operType = oper[2]
			local operCard = oper[3]
			local leftTileNum = oper[4]

			local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
			local remainTilesLabel = gt6.seekNodeByName(roundStateNode, "Label_remainTiles")
			remainTilesLabel:setString(tostring(leftTileNum))

			local Font_remainCards = gt6.seekNodeByName(self.rootNode,"Font_remainCards")
			Font_remainCards:setString(tostring(leftTileNum))

			-- 显示

			local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatId)
			if not roomPlayer or not next(roomPlayer) then return end
			
			local animPos = gt6.seekNodeByName(self.rootNode,"Node_playerOutMjTiles_" .. roomPlayer.displaySeatIdx)
			-- 创建麻将牌
			local mjTileName = self:getMJTileResName(4, operCard[1], operCard[2],false)
			local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
			local pos = animPos:getParent():convertToWorldSpace(cc.p(animPos:getPosition()))
			mjTileSpr:setPosition(pos)
			mjTileSpr:setScale(1.5)
			fourTileLayer:addChild(mjTileSpr,PlaySceneCS.ZOrder.HAIDILAOYUE)

			if operType == 1 then
				gt6.log("海底胡牌" .. operCard[1] .. operCard[2])
				local data = {}
				data.seatIdx =seatId
				local action = {}
				action.pic = "hu"
				self:playAciontEffect(data,action)
			elseif operType == 2 then
				-- 暗杠
				local data = {}
				data.seatIdx = seatId
				data.mjColor = operCard[1]
				data.mjNumber = operCard[2]
				local cfg = g_playRulesCfg["id_4"]
				if cfg.actionId and  next(cfg.actionId) then 
					for i, id in ipairs(cfg.actionId) do
						local action =  g_actionId["id_"..id] 
						self:doAction(action.realId,data,action)
					end
				end
			elseif operType == 3 then
				local data = {}
				data.seatIdx = seatId
				data.mjColor = operCard[1]
				data.mjNumber = operCard[2]
				local cfg = g_playRulesCfg["id_4"]
				if cfg.actionId and  next(cfg.actionId) then 
					for i, id in ipairs(cfg.actionId) do
						local action =  g_actionId["id_"..id] 
						self:doAction(action.realId,data,action)
					end
				end
			elseif operType == 0 then
				-- 摸牌 过牌
				if self.playerSeatIdx == seatId then
					if operCard[1] >= 4 then
					else
						-- 添加牌放在末尾
						local mjTilesReferPos = roomPlayer.mjTilesReferPos
						local mjTilePos = mjTilesReferPos.holdStart
						mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, #roomPlayer.holdMjTiles))
						mjTilePos = cc.pAdd(mjTilePos, cc.p(36, 0))

						local mjTile = self:addMjTileToPlayer(operCard[1], operCard[2])
						mjTile.mjTileSpr:setPosition(mjTilePos)
						self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt6.winSize.height - mjTilePos.y)+PlaySceneCS.SPPARAMS.MJMAXORDER)
						
					end
				else
					if operCard[1] >= 4 then
					end
				end
			elseif operType == 4 and roomPlayer.displaySeatIdx == 4  then  --决策
				print("haidilaoyue juece ...")
				local DecisionData = oper[5]
				if DecisionData and next(DecisionData) then
					local DecisionType = DecisionData[1]
					local mjColor = 0 
					local mjNumber = 0
					if DecisionData[2] and next(DecisionData[2]) then 
						mjColor = DecisionData[2][1][1]
						mjNumber = DecisionData[2][1][2]
					end
					if DecisionType == 125 then  --海底胡的决策
						local selfDrawnDcsNode = gt6.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
						selfDrawnDcsNode:setVisible(true)
						for _, decisionBtn in ipairs(selfDrawnDcsNode:getChildren()) do
							decisionBtn:setVisible(false)
						end
						local btn_pass = gt6.seekNodeByName(selfDrawnDcsNode, "Btn_decisionPass")
						btn_pass:setVisible(true)
						local btn_hu = gt6.seekNodeByName(selfDrawnDcsNode, "Btn_decisionWin")
						btn_hu:setVisible(true)
						local mjTileSpr = gt6.seekNodeByName(btn_hu, "Spr_mjTile")
						mjTileSpr:setVisible(false)
						if mjNumber ~= 0 and mjColor ~= 0 then
							mjTileSpr:setVisible(true)
							self:setSpriteFrame(self:getMJTileResName(4, mjColor, mjNumber), mjTileSpr)
						end
						gt6.addBtnPressedListener(btn_pass,function (sender)
							local selfDrawnDcsNode = gt6.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
							selfDrawnDcsNode:setVisible(false)
							local msgToSend = {}
							msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
							msgToSend.m_type = 126 --取消胡
							gt6.socketClient:sendMessage(msgToSend)
						end)

						gt6.addBtnPressedListener(btn_hu,function (sender)
							local selfDrawnDcsNode = gt6.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
							selfDrawnDcsNode:setVisible(false)
							local msgToSend = {}
							msgToSend.m_msgId = gt6.CG_SHOW_MJTILE	
							msgToSend.m_type = 125 --胡
							gt6.socketClient:sendMessage(msgToSend)
						end)
					end
				end

			end
			lastIndex = lastIndex + 1
			
		else
			gt6.scheduler:unscheduleScriptEntry(self.lastFourHandler)
			self.lastFourHandler = nil
		 	lastIndex = 1
		end
	end

	self.lastFourHandler = gt6.scheduler:scheduleScriptFunc(playLastFour, 0.4, false)
end


-- start --
--------------------------------
-- @class function
-- @description 接收房卡信息
-- @param msgTbl 消息体
-- end --
function PlaySceneCS:onRcvRoomCard(msgTbl)
	-- 兼容老代码
	if gt6.bag then
		gt6.bag:onRcvProp(gt6.PROP_TYPES.CURRENCY, 1, msgTbl.m_card2)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 同步房间状态
-- end --
function PlaySceneCS:onRcvSyncRoomState(msgTbl)
	if msgTbl.m_state == 1 then
		-- 等待状态
		return
	end
	-- 屏幕上所有创建的麻将节点
	self.allCardSprites = {}

	--开场动画隐藏的节点
	self.toBeShow = {}
	--播放开场动画标记
	self.isOpeningAim = false

	self.m_canNotPlay = {}
	self.m_touchedTimes =  0 
	self.m_roundDelay = 2
	self.isPlayerShow = false
	self.isPlayerDecision = false

	self.isTouch = true
	self.mIsInTrusteeship = false
	self.isStart = true

	--聊天记录
	self.ChatLog={}
	self.m_baoTable = {}
	self.playTimeCD=15
	self.infoForReport = {}
	dump(self.infoForReport, "---> playscene_MJ onRcvSyncRoomState 同步房间状态 self.infoForReport")
	self.m_baoCards = {}
	--检测相同ip
	if msgTbl.m_userIP then
		self.m_ip[4] = msgTbl.m_userIP
	end

	self:checkSameIp()

    if msgTbl.m_state==2 then
    	
    end
  
    self:clearMjLayer()
    --调用公共层的开始游戏
  	self:startGame()
	   --2人头像位置调整
    if self.playMaxNum == 2 then 
  		self:fixTwoPlayersHead()
  	end

 	self.isFixed3 = false

	-- 断线重连后,当前所选牌,索引等需要清理掉
	self.chooseMjTile 		= nil
	self.chooseMjTileIdx 	= nil
	self.preClickMjTile = nil

	-- 显示轮转座位标识
	local nodeCenter = gt6.seekNodeByName(self.rootNode,"Node_center")
	nodeCenter:setVisible(true)
	local turnPosBgSpr = gt6.seekNodeByName(self.rootNode, "Spr_turnPosBg")
    turnPosBgSpr:setVisible(true)
	local Node_dabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
	local notBao = gt6.seekNodeByName(self.rootNode, "notBao")
	notBao:setVisible(false)
	if msgTbl.m_BaoCard then
		local Spr_mjTile = gt6.seekNodeByName(Node_dabao, "Spr_mjTile")
		if Spr_mjTile then
			if #msgTbl.m_BaoCard >= 1 then
				local data = {}
				data.m_pos = self.playerSeatIdx - 1
				data.m_BaoCards = msgTbl.m_BaoCard
				data.m_type = 1
				self:daBaoShow(data)
			else
				Node_dabao:setVisible(false)
				Spr_mjTile:setVisible(false)
			end
		end
	end
	if msgTbl.m_ting == 1 then
		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
		for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
			mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
		end
	end
	
	if msgTbl.m_pos then
		-- 显示当前出牌座位标示
		local seatIdx = msgTbl.m_pos + 1
		self:setTurnSeatSign(seatIdx)
	end
    -- 牌局状态,剩余牌
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(true)
	local remainTilesLabel = gt6.seekNodeByName(roundStateNode, "Label_remainTiles")
	remainTilesLabel:setString(tostring(msgTbl.m_dCount))

	local Font_remainCards = gt6.seekNodeByName(self.rootNode,"Font_remainCards")
	Font_remainCards:setString(tostring(msgTbl.m_dCount))
	
	-- 庄家座位号
	local bankerSeatIdx = msgTbl.m_zhuang + 1
	-- 混/混皮/抢 必须置于sortPlayerMjTiles 之前 
	if msgTbl.m_huiPiCardColor and msgTbl.m_huiPiCardColor~=0 
		and msgTbl.m_huiPiCardNumber and msgTbl.m_huiPiCardNumber ~=0  then
		local isSevenHui = false
		if msgTbl.m_huiType and msgTbl.m_huiType == 2 then --是否是7混
			isSevenHui = true
		end
		self:setHuiPi({
				m_huiColor = msgTbl.m_huiCardColor,
				m_huiNum = msgTbl.m_huiCardNumber,
				m_huipiColor = msgTbl.m_huiPiCardColor,
				m_huipiNum = msgTbl.m_huiPiCardNumber,	
				m_vecQP = msgTbl.m_vecQP,
				m_isSevenHui = isSevenHui,
				m_showHuiPi = msgTbl.m_showHuiPi, --是否给混皮加角标
			})
	end

	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	-- 其他玩家牌
	for seatIdx, roomPlayer in ipairs(room_players) do
		-- 庄家标识
		print("roomPlayer.displaySeatIdx~~~~~~")
		dump(roomPlayer)
		local playerInfoNode = roomPlayer.head
		local bankerSignSpr = gt6.seekNodeByName(playerInfoNode, "ZHUANG")
		local tingSignSpr = gt6.seekNodeByName(playerInfoNode, "TING")
		roomPlayer.isBanker = false
		roomPlayer.headFlag = false
		bankerSignSpr:setVisible(false)
		if bankerSeatIdx == seatIdx then
			roomPlayer.isBanker = true
			bankerSignSpr:setVisible(true)
		end
		tingSignSpr:setVisible(false)
		if msgTbl.m_TingState and next(msgTbl.m_TingState) then
			if msgTbl.m_TingState[seatIdx] ~= 0 then
				local id = msgTbl.m_TingState[seatIdx] + 500 --头像操作500开始
				local tingState = g_actionId["id_"..id]
				if tingState then 
					self:playerHeadAction({seatIdx = seatIdx},tingState)
				end
			else
				tingSignSpr:setVisible(false)
			end
		end
		self:initRoomPlayerTables(roomPlayer)
		-- 麻将放置参考点
		roomPlayer.mjTilesReferPos = self:setPlayerMjTilesReferPos(roomPlayer.displaySeatIdx)
		-- 剩余持有牌数量
		roomPlayer.mjTilesRemainCount = msgTbl.m_CardCount[seatIdx]
		if roomPlayer.seatIdx == self.playerSeatIdx then
			-- 玩家持有牌
			if msgTbl.m_myCard then
				for _, v in ipairs(msgTbl.m_myCard) do
					self:addMjTileToPlayer(v[1], v[2],nil,nil,msgTbl.isNewStart)
				end
				-- 根据花色大小排序并重新放置位置
				self:sortPlayerMjTiles()

				if msgTbl.isNewStart then

					xpcall(function()
						self:playStartBoard()
					end,function()
						self:boardStartAfter()
					end)
				else 
					self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)
				end
				--检查自己是否必须开启发牌前决策
				self:checkIsMustAddBeforeDeal(roomPlayer,msgTbl)
			end
		else
			local mjTilesReferPos = roomPlayer.mjTilesReferPos
			local mjTilePos = mjTilesReferPos.holdStart
			local maxCount = roomPlayer.mjTilesRemainCount + 1
			for i = 1, maxCount do
				local mjTileName = string.format("tbgs_%d.png", roomPlayer.displaySeatIdx)
				local mjTileSpr = self:createWithSpriteFrameName(mjTileName,roomPlayer)
				mjTileSpr:setPosition(mjTilePos)
				self.playMjLayer:addChild(mjTileSpr, (gt6.winSize.height - mjTilePos.y))
				mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
				local mjTile = {}
				mjTile.mjTileSpr = mjTileSpr
				table.insert(roomPlayer.holdMjTiles, mjTile)
				-- 隐藏多产生的牌
				if i > roomPlayer.mjTilesRemainCount then
					mjTileSpr:setVisible(false)
				end
			end
		end

		if msgTbl.m_score and roomPlayer.scoreLabel and not self:isCoinRoom() then
			local score = msgTbl.m_score[seatIdx]
			if score then
				gt6.log("seatIdx = " .. seatIdx .. ", score = " .. score)
				roomPlayer.score = score

				if gt6.isMatch then
					local coinStr = Utils6.formatCoinValue(roomPlayer.score)
					roomPlayer.scoreLabel:setString(coinStr)

				else
					roomPlayer.scoreLabel:setString(tostring(roomPlayer.score))
				end
			end
		end

		-- 服务器座次编号
		local turnPos = seatIdx - 1
		--TIPS:
		--CFGFUNCTION
		--------遍历发来的字段，进行动作----------
		for k , action in pairs(g_actionId) do 
			if action.reConnectKey and msgTbl[action.reConnectKey .. turnPos] and next(msgTbl[action.reConnectKey .. turnPos]) then 
				print("the reConnectKey is .."..action.reConnectKey)
				if  not action.reConnectNum then 
					for _, v in ipairs(msgTbl[action.reConnectKey .. turnPos]) do 
						local data = {}
						data.seatIdx = seatIdx
						data.mjColor = v[1]
						data.mjNumber = v[2]
						data.isReconnect = true
						print("action.realId"..action.realId)
						self:doAction(action.realId,data,action)
						self:sortPlayerMjTiles()
					end
				else
					local kaiDanArray = msgTbl[action.reConnectKey .. turnPos]
					if kaiDanArray and next(kaiDanArray) then
						local kaiDanTable = {}
						local dataTable = {}
						for i, v in ipairs(kaiDanArray) do
							table.insert(dataTable,v)
							if i % action.reConnectNum == 0 then
								table.insert(kaiDanTable,dataTable)
								dataTable = {}
							end
						end
						for j, danData in ipairs(kaiDanTable) do
					 		local data = {}
							data.extra = danData
							data.seatIdx = seatIdx
							if #kaiDanArray % action.reConnectNum ~= 0 and j == #kaiDanTable then 
								table.insert(data.extra,kaiDanArray[#kaiDanArray])
							end
							self:addCPGMJTile(data,{})
						end
					end
				end
			end
		end
		--吃
		local eatArray = msgTbl["m_eCard" .. turnPos]
		if eatArray and next(eatArray) then
			local eatTable = {}
			local dataTable = {}
			for i, v in ipairs(eatArray) do
				table.insert(dataTable,v)
				if i % 3 == 0 then
					table.insert(eatTable,dataTable)
					dataTable = {}
				end
			end
			print("eatData...")
			dump(eatTable)
			for j, eatData in pairs(eatTable) do
				local data = {}
				data.seatIdx = seatIdx
				data.mjColor = eatData[1][1]
				data.mjNumber = eatData[1][2]
				data.extra = eatData
			 	self:addCPGMJTile(data,g_actionId["id_303"])
			end
		end

		--开蛋
		local kaiDanArray = msgTbl["m_beginEgg" .. turnPos]
		if kaiDanArray and next(kaiDanArray) then
			local kaiDanTable = {}
			local dataTable = {}
			for i, v in ipairs(kaiDanArray) do
				table.insert(dataTable,v)
				if i % 3 == 0 then
					table.insert(kaiDanTable,dataTable)
					dataTable = {}
				end
			end
			for j, danData in ipairs(kaiDanTable) do
		 		local data = {}
				data.extra = danData
				data.seatIdx = seatIdx
				data.spKey = "KAIDAN"
				if #kaiDanArray %3 ~= 0 and j == #kaiDanTable then 
					table.insert(data.extra,kaiDanArray[#kaiDanArray])
				end
				self:addCPGMJTile(data,{})
			end
		end

		--补蛋
		local buDanArray = msgTbl["m_addEgg"..turnPos]
		if buDanArray and next(buDanArray) then
			for k ,v in pairs(buDanArray) do 
				local data = {}
				data.seatIdx = seatIdx
				data.extra = {v}
				self:showBuDan(data)
			end
		end

		--检查其他玩家是否必须开启发牌前决策
		self:checkIsMustAddBeforeDeal(roomPlayer,msgTbl)

		--开局前决策的状态
		local bufferState = msgTbl["bufferState_"..turnPos]
		if bufferState and next(bufferState) then 
			for i , stateValue in ipairs(bufferState) do 
				if stateValue > -1 then 
					local cfg = self.beforeDealCfg[i]
					if not cfg or not next(cfg) then break end
					self:onSyncBeforeOptions({m_pos = turnPos ,m_EventID = i, m_bIsDouble = stateValue})
				end
			end
		end

		--托管
		if msgTbl.m_IsTuoguan  and  self:isCoinRoom() then
			if self:isPlayerSeat(seatIdx) then
				self.mIsInTrusteeship = msgTbl.m_IsTuoguan[seatIdx]
				if self.mIsInTrusteeship and #roomPlayer.holdMjTiles  > 0 then
					self.isTouch = false
					for k, pkTile in ipairs(roomPlayer.holdMjTiles) do
						pkTile.mjTileSpr:setColor(cc.c3b(200,200,200))
					end

					self:createTrusteeshipBtn()
				end
			else
				local isIntrusteeship = msgTbl.m_IsTuoguan[roomPlayer.seatIdx]
				if isIntrusteeship then
					-- 显示托管机器人
					roomPlayer:showTrusteeship()
				end	
			end
		end
	end

	 --本场的录像id
    if msgTbl.m_videoID then
    	self.rootNode:removeChildByTag(PlaySceneCS.SPPARAMS.VIDEO_ID)
    	gt6.g_videoID = msgTbl.m_videoID
   	 	local videoIDLabel=gt6.createTTFLabel(msgTbl.m_videoID,19)
   	 	videoIDLabel:setColor(cc.c3b(142,168,122))
   	 	videoIDLabel:setOpacity(100)
   	 	videoIDLabel:setAnchorPoint(ccp(1,0.5))
   	 	self.rootNode:addChild(videoIDLabel)
   	 	videoIDLabel:setTag(PlaySceneCS.SPPARAMS.VIDEO_ID)
   	 	videoIDLabel:setPosition(gt6.winSize.width-40,gt6.winSize.height-10)
   	end

   	if msgTbl.m_usedCards and next(msgTbl.m_usedCards) then --吉林长春换宝时显示角标
		for i = 1,# msgTbl.m_usedCards do 
			table.insert(self.m_baoTable,{msgTbl.m_usedCards[i][1],msgTbl.m_usedCards[i][2]})
		end
		-- 刷新屏幕上的选项
		for i,v in ipairs(self.allCardSprites) do
			if v[2] and not tolua.isnull(v[2]) then
				self:addMJflag(v[3], v[2])
			end
		end
	end	

	--杠牌
	if msgTbl.m_GangCardColor and msgTbl.m_GangCardColor ~=0 and msgTbl.m_GangCardNumber and msgTbl.m_GangCardNumber ~= 0 then
   		local data = {}
   		data.m_gc = msgTbl.m_GangCardColor
   		data.m_gn = msgTbl.m_GangCardNumber
   		self:onRcvGangPai(data)
   	end

end


--发牌前决策
function PlaySceneCS:onReciveBeforeDeal(msgTbl)
	if self.isCurEvent ~= nil then
		self:clearBeforeDealSp()
	end

	if self.ready_ui_layer then
		self.ready_ui_layer:readyBtnsOff()
	end
	
	self.isCurEvent = msgTbl.m_EventID
	local decisionBtnImg = {}
	if msgTbl.m_EventID == 0 then
		print("ERROR:  PlaySceneCS:onReciveBeforeDeal msgTbl.m_EventID == 0")
		return
	elseif msgTbl.m_EventID == self.beforeDealEventId.JiaGang then --加刚
		decisionBtnImg = {"gt6_b2_bt_new.png","gt6_b2_btp_new.png","gt6_b2_bt_new.png","gt6_jiagang_btx.png","gt6_b1_bt_new.png","gt6_b1_btp_new.png","gt6_b1_bt_new.png","gt6_bujiagang_btx.png"}
	elseif msgTbl.m_EventID == self.beforeDealEventId.GuaDang then --挂挡
		decisionBtnImg = {"gt6_b2_bt_new.png","gt6_b2_btp_new.png","gt6_b2_bt_new.png","gt6_guadang_btx.png","gt6_b1_bt_new.png","gt6_b1_btp_new.png","gt6_b1_bt_new.png","gt6_buguadang_btx.png"}
	elseif msgTbl.m_EventID == self.beforeDealEventId.GuaPiao then --挂漂	
		decisionBtnImg = {"gt6_b2_bt_new.png","gt6_b2_btp_new.png","gt6_b2_bt_new.png","gt6_guapiao_btx.png","gt6_b1_bt_new.png","gt6_b1_btp_new.png","gt6_b1_bt_new.png","gt6_buguapiao_btx.png"}
	end

	-- 隐藏牌局状态
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(false)

	self.playTimeCDLabel:setVisible(false)

	local turnbg=gt6.seekNodeByName(self.rootNode,"Spr_turnPosBg")
	turnbg:setVisible(true)

	local beforeDealCdLabel = gt6.seekNodeByName(self.rootNode,"beforeDealCdLabel")
	if beforeDealCdLabel ~= nil then
		beforeDealCdLabel:removeFromParent()
	end
	local beforeDealCdLabel = cc.LabelAtlas:create("15",PlaySceneCS.playScenePath.."time_num.png",22,33,string.byte("0"))
	beforeDealCdLabel:setName("beforeDealCdLabel")
	beforeDealCdLabel:setAnchorPoint(0.5,0.5)
	beforeDealCdLabel:setPosition(self.playTimeCDLabel:getWorldPosition())--gt6.getPosByRealSize(cc.p(640,390)))
	self.rootNode:addChild(beforeDealCdLabel,PlaySceneCS.ZOrder.DECISION_SHOW)
	local function callFunc(sender)
		if tonumber(sender:getString())<= 0 then
			sender:stopAllActions()
			sender:setString("0")
		else
			local str = tonumber(sender:getString())-1
			sender:setString(tostring(str))
		end
	end
	local action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(callFunc)))
	beforeDealCdLabel:runAction(action)
	if self.rootNode:getChildByName("btnBeforeDealYes") ~= nil then
		self.rootNode:removeChildByName("btnBeforeDealYes")
	end
	if self.rootNode:getChildByName("btnBeforeDealNo") ~= nil then
		self.rootNode:removeChildByName("btnBeforeDealNo")
	end
	--添加按钮
	local btnBeforeDealYes = ccui.Button:create(decisionBtnImg[1],decisionBtnImg[2],decisionBtnImg[3],ccui.TextureResType.plistType)
	btnBeforeDealYes:setPosition(gt6.getPosByRealSize(cc.p(500,225)))
	btnBeforeDealYes:setName("btnBeforeDealYes")
	local titleYes = ccui.ImageView:create(decisionBtnImg[4],ccui.TextureResType.plistType)
	titleYes:setPosition(btnBeforeDealYes:getContentSize().width/2,btnBeforeDealYes:getContentSize().height/2)
	btnBeforeDealYes:addChild(titleYes)
	self.rootNode:addChild(btnBeforeDealYes,PlaySceneCS.ZOrder.DECISION_SHOW)
	--添加按钮
	local btnBeforeDealNo = ccui.Button:create(decisionBtnImg[5],decisionBtnImg[6],decisionBtnImg[7],ccui.TextureResType.plistType)
	btnBeforeDealNo:setPosition(gt6.getPosByRealSize(cc.p(780,225)))
	btnBeforeDealNo:setName("btnBeforeDealNo")
	local titleNo = ccui.ImageView:create(decisionBtnImg[8],ccui.TextureResType.plistType)
	titleNo:setPosition(btnBeforeDealNo:getContentSize().width/2,btnBeforeDealNo:getContentSize().height/2)
	btnBeforeDealNo:addChild(titleNo)
	self.rootNode:addChild(btnBeforeDealNo,PlaySceneCS.ZOrder.DECISION_SHOW)

	local function onCallBack(sender)
		local isAdd = 0
		if sender == btnBeforeDealYes then
			isAdd = 1
		end

		local msgToSend = {}
		msgToSend.m_msgId = gt6.MSG_C_2_S_REQ_DOUBLE
		msgToSend.m_pos = self.playerSeatIdx-1
		msgToSend.m_bIsDouble = isAdd
		msgToSend.m_EventID = msgTbl.m_EventID
		gt6.socketClient:sendMessage(msgToSend)

		btnBeforeDealYes:removeFromParent()
		btnBeforeDealNo:removeFromParent()
	end

	gt6.addBtnPressedListener(btnBeforeDealYes,onCallBack)
	gt6.addBtnPressedListener(btnBeforeDealNo,onCallBack)

	self:checkOptions(msgTbl)
end

--根据配置显示按钮
function PlaySceneCS:checkOptions(msgTbl)
	local cfg = self.beforeDealCfg[msgTbl.m_EventID]
	if not cfg or not  next(cfg) then return end
	if  self.playMjLayer:getChildByName("startBtnLayer") then 
		self.playMjLayer:getChildByName("startBtnLayer"):removeFromParent()
	end
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	gt6.seekNodeByName(roomPlayer.head,"Spr_readySign"):setVisible(false)
	local btnLayer = cc.Layer:create()
	btnLayer:setSwallowsTouches(true)
	btnLayer:setName("startBtnLayer")
	self.playMjLayer:addChild(btnLayer, PlaySceneCS.SPPARAMS.MJMAXORDER*10)
	btnLayer:setContentSize(gt6.winSize)

	local btnStartPos = cc.p(gt6.seekNodeByName(self.csbNode,"Node_decisionBtn"):getPosition())
	if cfg.titlePic  then 
		local titleSp = ccui.ImageView:create(cfg.titlePic,ccui.TextureResType.localType)
		btnLayer:addChild(titleSp)
		titleSp:setPosition(gt6.seekNodeByName(self.csbNode,"Node_playType"):getPosition())
	end

	for i, v in ipairs(cfg.btns) do 
		local btn = ccui.Button:create(v,v,v,ccui.TextureResType.localType)
		btn:setPosition(btnStartPos)
		btnStartPos = cc.pAdd(btnStartPos,cc.p(btn:getContentSize().width*1.2,0))
		btn:setTag(i)
		btnLayer:addChild(btn,PlaySceneCS.ZOrder.DECISION_SHOW)

		gt6.addBtnPressedListener(btn,function ( sender )
			local msgToSend = {}
			local toSend = cfg.msgToSend[sender:getTag()]
			msgToSend.m_msgId = gt6.MSG_C_2_S_REQ_DOUBLE
			msgToSend.m_pos = self.playerSeatIdx-1
			msgToSend.m_bIsDouble = toSend
			msgToSend.m_EventID = msgTbl.m_EventID
			gt6.socketClient:sendMessage(msgToSend)
			btnLayer:removeFromParent()
		end)
	end
end


--发牌前显示
function PlaySceneCS:onRcvBeforeDealRadio(msgTbl)
	self.common_ui_layer:readyBtnsOff()
	local beforeDealCdLabel = gt6.seekNodeByName(self.rootNode,"beforeDealCdLabel")
	if beforeDealCdLabel == nil then
		-- 隐藏牌局状态
		local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
		roundStateNode:setVisible(false)
		self.playTimeCDLabel:setVisible(false)
		local beforeDealCdLabel = cc.LabelAtlas:create("15",PlaySceneCS.playScenePath.."time_num.png",22,33,string.byte("0"))
		beforeDealCdLabel:setName("beforeDealCdLabel")
		beforeDealCdLabel:setAnchorPoint(0.5,0.5)
		beforeDealCdLabel:setPosition(self.playTimeCDLabel:getWorldPosition())--gt6.getPosByRealSize(cc.p(640,390)))
		self.rootNode:addChild(beforeDealCdLabel,PlaySceneCS.ZOrder.DECISION_SHOW)
		local function callFunc(sender)
			if tonumber(sender:getString())<= 0 then
				sender:stopAllActions()
				sender:setString("0")
			else
				local str = tonumber(sender:getString())-1
				sender:setString(tostring(str))
			end
		end
		local action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(callFunc)))
		beforeDealCdLabel:runAction(action)
	else
		local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
		roundStateNode:setVisible(false)
		self.playTimeCDLabel:setVisible(false)
	end
	local spriteDecImg = {}
	if msgTbl.m_EventID == 0 then
		print("ERROR:  PlaySceneCS:onRevBeforeDealRadio msgTbl.m_EventID == 0")
		return
	elseif msgTbl.m_EventID == self.beforeDealEventId.JiaGang then --加刚
		spriteDecImg = {"gt6_bujiagang_artword.png","gt6_addgang_tx.png"}
	elseif msgTbl.m_EventID == self.beforeDealEventId.GuaDang then --挂挡
		spriteDecImg = {"gt6_buguadang_artword.png","gt6_guadang_artword.png"}
	elseif msgTbl.m_EventID == self.beforeDealEventId.GuaPiao then --挂漂	
		spriteDecImg = {"gt6_buguapiao_artword.png","gt6_guapiao_artword.png"}
	end

	--统一加广播效果
	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	for _,v in pairs(room_players) do
		if v.seatIdx == msgTbl.m_pos+1 then 

			local playerNode = gt6.seekNodeByName(self,"Node_playerInfo_"..v.displaySeatIdx)
			if playerNode:getChildByName("beforeStateImg"..msgTbl.m_EventID) then
				playerNode:removeChildByName("beforeStateImg"..msgTbl.m_EventID)
			end
			local spriteDecBeforeDeal = nil
			if msgTbl.m_bIsDouble == 0 then
				spriteDecBeforeDeal = ccui.ImageView:create(spriteDecImg[1],ccui.TextureResType.plistType)
			elseif msgTbl.m_bIsDouble == 1 then
				spriteDecBeforeDeal = ccui.ImageView:create(spriteDecImg[2],ccui.TextureResType.plistType)
				self:refreshBeforeState(v.displaySeatIdx,1,msgTbl.m_EventID)
			end
			if spriteDecBeforeDeal ~= nil then
				spriteDecBeforeDeal:setName("spriteDecBeforeDeal_"..v.displaySeatIdx)
				print("显示选择决策座位号",v.displaySeatIdx)
				spriteDecBeforeDeal:setPosition(self:getAddBeforeDealSpPos(v.displaySeatIdx))
				self.rootNode:addChild(spriteDecBeforeDeal)	
			end
		end
	end

	self:onSyncBeforeOptions(msgTbl)
end

function PlaySceneCS:onSyncBeforeOptions( msgTbl )
	local cfg = self.beforeDealCfg[msgTbl.m_EventID]
	print("cfg is ..")
	dump(cfg)
	if not cfg or not  next(cfg) then return end
	--查找配置中的第几个icon
	local iconIndex = nil
	for i , v in ipairs(cfg.msgToSend) do 
		if v == msgTbl.m_bIsDouble  then 
			iconIndex = i
			break
		end
	end
	if not iconIndex then return end 
	self:playerHeadAction({seatIdx = msgTbl.m_pos+1},{pic = cfg.headIcons[iconIndex],picResType = "LOCAL",spKey = "NEW"})
end

--加钢pos
function PlaySceneCS:getAddBeforeDealSpPos(_displaySeatIdx)
	local poslist = {
		gt6.getPosByRealSize(cc.p(918,375)),
		gt6.getPosByRealSize(cc.p(625, 500)),
		gt6.getPosByRealSize(cc.p(350,375)),
		gt6.getPosByRealSize(cc.p(625,250)),
	}
	return poslist[_displaySeatIdx]
end

--检查发牌前是否强制执行决策
function PlaySceneCS:checkIsMustAddBeforeDeal(roomPlayer,msgTbl)
	if type(self.isMustBeforeDeal) == "table" then
		for k,v in pairs(self.beforeDealEventId) do
			if  self.isMustBeforeDeal[v] == 1 then
				self:refreshBeforeState(roomPlayer.displaySeatIdx,1,v)
			else
				local msgName = self.beforeDealMsgName[v]
				local isAddReArray = msgTbl[msgName]

				if isAddReArray ~= nil then
					local isAddRe = isAddReArray[roomPlayer.seatIdx]
					if isAddRe == 1 then
						self:refreshBeforeState(roomPlayer.displaySeatIdx,isAddRe,v)
					end
				end
			end
		end
	end
end

--清除发牌前显示动画
function PlaySceneCS:clearBeforeDealSp()
	--删除发牌前决策动画
	for i=1,4 do
		local spriteDecBeforeDeal = gt6.seekNodeByName(self.rootNode,"spriteDecBeforeDeal_"..i)
		print("删除发牌前决策动画")
		if spriteDecBeforeDeal ~= nil then
			spriteDecBeforeDeal:removeFromParent()
		end
			
	end

	if self.playMjLayer:getChildByName("startBtnLayer") then 
		self.playMjLayer:getChildByName("startBtnLayer"):removeFromParent()
	end
end

--清除发牌前决策状态图标
function PlaySceneCS:clearBeforeStateSp()
	--一删除发牌前决策状态标识
	for i=1,4 do
		for _ ,v in pairs(self.beforeDealEventId) do
			local playerInfoNode = gt6.seekNodeByName(self, "HeadNode" .. i)
			if playerInfoNode and not tolua.isnull(playerInfoNode) and playerInfoNode:getChildByName("beforeStateImg"..v) then
				playerInfoNode:removeChildByName("beforeStateImg"..v)
			end
		end
	end

	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	for k, roomPlayer in pairs(room_players) do
		if roomPlayer.head and not tolua.isnull(roomPlayer.head) then
			if roomPlayer.head:getChildByName("NEWICON") then 
				roomPlayer.head:getChildByName("NEWICON"):removeFromParent()
			end
		end
	end
	self.isCurEvent = nil
end

--------------------发牌前决策 begin----------------
---发牌前状态刷新
function PlaySceneCS:refreshBeforeState(displayIdx,isAdd,eventId)
	print("发牌前",displayIdx,isAdd)
	
 	local playerNode = gt6.seekNodeByName(self,"HeadNode"..displayIdx)
	if playerNode:getChildByName("beforeStateImg"..eventId) then
		playerNode:removeChildByName("beforeStateImg"..eventId)
	end
	local stateImg = ""
	local pos = nil
	local imageBg = gt6.seekNodeByName(playerNode,"Image_bg")

	if eventId == self.beforeDealEventId.JiaGang then
		stateImg = "gt6_gang_icon.png"
		pos = cc.pAdd(cc.p(imageBg:getPosition()),cc.p(imageBg:getContentSize().width/2-10,imageBg:getContentSize().height/2-10))
	elseif eventId == self.beforeDealEventId.GuaDang then
		stateImg = "gt6_dang_icon.png"
		pos = cc.pAdd(cc.p(imageBg:getPosition()),cc.p(imageBg:getContentSize().width/2-10,imageBg:getContentSize().height/2-10))
	elseif eventId == self.beforeDealEventId.GuaPiao then
		stateImg = "gt6_piao_icon.png"
		pos = cc.pSub(cc.p(imageBg:getPosition()),cc.p(imageBg:getContentSize().width/2-10,imageBg:getContentSize().height/2-30))
	else
		return 
	end
	if isAdd == 1 then
		local beforeStateImg = ccui.ImageView:create(stateImg,ccui.TextureResType.plistType)
		beforeStateImg:setName("beforeStateImg"..eventId)
		beforeStateImg:setAnchorPoint(0.5,0.5)
		beforeStateImg:setPosition(pos)
		playerNode:addChild(beforeStateImg)
	end
 end 

function PlaySceneCS:initRoomPlayerTables( roomPlayer )
	if not roomPlayer  then return end 
	-- 玩家持有牌
	roomPlayer.holdMjTiles = {}
	-- 玩家已出牌
	roomPlayer.outMjTiles = {}
	--玩家吃碰杠
    roomPlayer.mjTileCPG = {}
    --玩家补牌
    roomPlayer.mjTileBuDanSmall = {}

    --玩家摆放的特殊牌
    roomPlayer.linedMjTile = {}
    roomPlayer.linedMJPos = nil
	roomPlayer.lineIndex = 0
	
end

-- start --
--------------------------------
-- @class function
-- @description 当前局数/最大局数量
-- @param msgTbl 消息体
-- end --
function PlaySceneCS:onRcvRoundState(msgTbl)
	print("----> PlaySceneCS:onRcvRoundState(data) ..... ,gt6.isMatch  = ",gt6.isMatch)
	dump(msgTbl,"---> 是否是比赛场 msgTbl = ",msgTbl)
	if msgTbl.m_deskInfo and not gt6.isMatch then
		gt6.isMatch = true
		self:updatePlayBg(7,"playMode/4MATCH/")
		print("----> 当前是比赛场 ")
	end
	gt6.isMatch = gt6.isMatch or nil
	if gt6.isMatch then
		self.common_ui_layer:roomIdView(false)
		self.common_ui_layer:updateRightBtnView()
		Utils6.initMatchProxy()
		gt6.MCommonMatchManage:SetMatchingStatus(true)
		print("----> jushu : ",msgTbl.m_curCircle,msgTbl.m_curMaxCircle)
		gt6.MCommonMatchManage:SetMatchRoundEnd( (msgTbl.m_curCircle+1) == msgTbl.m_curMaxCircle)
	end
	print("---> gt6.isMatch = ",gt6.isMatch)
	-- 牌局状态,剩余牌	
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(true)
	local remainTilesLabel = gt6.seekNodeByName(roundStateNode, "Label_remainRounds")
	remainTilesLabel:setString(string.format("%d/%d", (msgTbl.m_curCircle + 1), msgTbl.m_curMaxCircle))
	self.m_numberMark = (msgTbl.m_curCircle + 1)

	if (msgTbl.m_curCircle + 1) == msgTbl.m_curMaxCircle and not self:isCoinRoom()  then
		if not gt6.isMatch then
			gt6.floatText(gt6.getLocationString("LTKey_0247"))
		end
	end

	--发牌前强制执行
	self.isMustBeforeDeal = msgTbl.m_bIsDouble or {}
	self.m_startGame = true

	if gt6.isMatch then
		self:matchInfoShow(msgTbl)
	end
end

function PlaySceneCS:createMatchText( _node,_name , _color , _fontSize )
	_color = _color or cc.c3b(255,255,0)
	_fontSize = _fontSize or 24
	local _MatchText = ccui.Text:create("",nil,_fontSize)
	_MatchText:setColor(_color)
	_MatchText:setName(_name)
	_MatchText:setVisible(false)
	_node:addChild(_MatchText) 
	return _MatchText
end
-- 比赛场相关信息显示
function PlaySceneCS:matchInfoShow( msgTbl )
	dump(msgTbl,"----> 麻将 里 比赛场相关信息显示 ： ")
	local _pos = self:getTurnPosBgPos()
	if not MTools then
		print("----> MTools 不存在")
		require("app/playMode/4MATCH/tools/MTools")
	end
	local _infoParent = gt6.seekNodeByName(self.rootNode, "Node_center")
	MTools.matchInfoShow( msgTbl , _infoParent , _pos)
end

function PlaySceneCS:clearMatchShow()
	local _infoParent = gt6.seekNodeByName(self.rootNode, "Node_center")
	
	if not MTools then
		print("----> MTools 不存在")
		require("app/playMode/4MATCH/tools/MTools")
	end

	MTools.clearMatchShow( _infoParent )
end

--2人头像位置调整
function PlaySceneCS:fixTwoPlayersHead( )
	local headNewPos = cc.p(gt6.seekNodeByName(self.csbNode,"Node_head_2_2"):getPosition())
	self.common_ui_layer.playerBg[2]:setPosition(headNewPos)
	local voiceBtnPos = cc.p(self.common_ui_layer.yuyinBtn:getPosition())
	local soundBtnPos = cc.p(self.common_ui_layer.speakBtn:getPosition())
	self.common_ui_layer.yuyinBtn:setPosition(cc.pSub(voiceBtnPos,cc.p(0,50)))
	self.common_ui_layer.speakBtn:setPosition(cc.pSub(soundBtnPos,cc.p(0,50)))
end



-- start --
--------------------------------
-- @class function
-- @description 游戏开始
-- @param msgTbl 消息体
-- end --
function PlaySceneCS:onRcvStartGame(msgTbl)
	msgTbl.isNewStart = true
	if gt6.onOpenAnim then
		msgTbl.isNewStart = false
	end

	self:removeMatchWaiting()

	self:setStatus(gt6.CommonConst.ROOM_STATUS.SEND_CARD)

	self:onRcvSyncRoomState(msgTbl)
	local room_players = gt6.PlayersManager:getAllRoomPlayers()
    self.isTing = false
    for seatIdx, roomPlayer in ipairs(room_players) do
    	roomPlayer.m_ting = nil
    end
    
    --牌局状态
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(true)
	self.playTimeCDLabel:setVisible(false)
	local beforeDealCdLabel = gt6.seekNodeByName(self.rootNode,"beforeDealCdLabel")
	if beforeDealCdLabel ~= nil then
		beforeDealCdLabel:removeFromParent()
	end
	self:clearBeforeDealSp()
end

function PlaySceneCS:createListView(  )
	if self.m_listView then
		self.m_listView:removeFromParent()
		self.m_listView = nil
	end
	local function onListTouch(sender, eventType )
	 	if self:getChildByName("sp_huaDongTip") then
	 		self:removeChildByName("sp_huaDongTip")
	 	end	 
	end
	self.m_listView = ccui.ListView:create()
	self.m_listView:setItemsMargin(2)
	self.m_listView:setDirection(ccui.ListViewDirection.horizontal)
	self:addChild(self.m_listView,PlaySceneCS.ZOrder.MJTILES)
	self.m_listView:addEventListenerListView(onListTouch)
end

function PlaySceneCS:createMultiBtnTips( )
	local pos = cc.p(gt6.winCenter.x * 1.5,gt6.winCenter.y * 0.6)
	local sp_huaDongTip = ccui.ImageView:create("gt6_multi_btn_tip.png",ccui.TextureResType.plistType)
	sp_huaDongTip:setPosition(pos)
	sp_huaDongTip:setName("sp_huaDongTip")
	self:addChild(sp_huaDongTip,PlaySceneCS.ZOrder.MJTILES)
	print("huadong...")
	dump(sp_huaDongTip)
	local sp_finger = ccui.ImageView:create("gt6_multi_btn_finger.png",ccui.TextureResType.plistType)
	sp_huaDongTip:addChild(sp_finger)
	local originPos = cc.p(sp_huaDongTip:getContentSize().width,0)
	sp_finger:setPosition(originPos)
	local move = cc.MoveTo:create(1,cc.p(10,0))
	local moveBack = cc.MoveTo:create(0,originPos)
	local delayTime = cc.DelayTime:create(0.5)
	local seqAction = cc.Sequence:create(move,delayTime,moveBack)
	sp_finger:runAction(cc.RepeatForever:create(seqAction))

end

function PlaySceneCS:removeVisibleCard(roomPlayer, mjColor, mjNumber, mjTilesCount)
	-- 玩家持有牌中去除打出去的牌
		local isRemove = false
		for i = #roomPlayer.holdMjTiles, 1, -1 do
			local mjTile = roomPlayer.holdMjTiles[i]
			if mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
				mjTile.mjTileSpr:removeFromParent()
				table.remove(roomPlayer.holdMjTiles, i)
				isRemove = true
				print("removeddddd")
				break
			end
		end
		if not isRemove then
			local mjTile = roomPlayer.holdMjTiles[self.chooseMjTileIdx]
			if mjTile and mjTile.mjTileSpr then
			   mjTile.mjTileSpr:removeFromParent()
			   table.remove(roomPlayer.holdMjTiles, self.chooseMjTileIdx)
			end
		end
	
	self:sortPlayerMjTiles()
end



--自动出牌
function PlaySceneCS:onUnpause(msgTbl, roomPlayer)
	print("auto play.....")
	if self.m_tingState and msgTbl.m_ting == 1 then
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			if _ ~= #roomPlayer.holdMjTiles then
				mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
			end
		end				
		self.isPlayerDecision = false
		self.isPlayerShow = false
		self.chooseMjTileIdx = #roomPlayer.holdMjTiles
		self.chooseMjTile = roomPlayer.holdMjTiles[self.chooseMjTileIdx]

		local msgToSend = {}
		msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
		msgToSend.m_type = 1
		msgToSend.m_think = {}
		table.insert(msgToSend.m_think, {msgTbl.m_tingCards[1][1], msgTbl.m_tingCards[1][2]})
		gt6.socketClient:sendMessage(msgToSend)
		return true				
	end	
end


--左上角特殊牌统一显示
function PlaySceneCS:showSpecialCards(data)
	local showType = data.showType
	local mjColor = data.mjColor 
	local mjNumber = data.mjNumber

	if self.playMjLayer:getChildByName("SPBG") then 
		self.playMjLayer:getChildByName("SPBG"):removeFromParent()
	end
	if self.playMjLayer:getChildByName("MORECARD") then 
		self.playMjLayer:getChildByName("MORECARD"):removeFromParent()
	end

	if gt6.showMoreTipCards and #data.allCards>1 then 
		local showCfg = PlaySceneCS.SPCARDSHOW[showType.."_MORE"]
		if not showCfg then return end
		local scaleNum = 0.6
		local spKuang = ccui.ImageView:create(showCfg.spBgName,showCfg.spBgResType)
		spKuang:setScale9Enabled(true)
		spKuang:setCapInsets(cc.rect(15,15,10,10))
		spKuang:setAnchorPoint(cc.p(0,0.5))
		local nodeBao =  gt6.seekNodeByName(self.rootNode, "Node_dabao")
		nodeBao:setVisible(false)
		local sprBaoBg = gt6.seekNodeByName(self.rootNode,"Spr_baopai_bg")
		sprBaoBg:setVisible(false)
		local posY = nodeBao:getPositionY()
		spKuang:setPosition(0,posY+30)
		spKuang:setName("MORECARD")
		self.playMjLayer:addChild(spKuang)
		local cardsTable = data.allCards
		for i = 1 , #cardsTable do 
			local mjColor  =  cardsTable[i][1]
			local mjNumber  =  cardsTable[i][2]
			local mjTileName = self:getMJTileResName(4, mjColor, mjNumber,1)
			local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
			mjTileSpr:setScale(scaleNum)
			local mjTileSize = mjTileSpr:getContentSize()
			mjTileSize.width = mjTileSize.width*scaleNum
			mjTileSize.height = mjTileSize.height*scaleNum
			mjTileSpr:setAnchorPoint(cc.p(0,0.5))
			spKuang:setContentSize(cc.size(mjTileSize.width*#cardsTable + 20,mjTileSize.height*1.2))
			mjTileSpr:setPosition(cc.p(mjTileSize.width * (i-1) + 10, mjTileSize.height*1.2/2))
			spKuang:addChild(mjTileSpr)
		end
		if showCfg.spTitle then 
			local tileSp = ccui.ImageView:create(showCfg.spTitle,showCfg.spTitleResType)
			tileSp:setPosition(spKuang:getContentSize().width/2,10)
			spKuang:addChild(tileSp)
		end
	else
		local showCfg = self.SPCARDSHOW[showType]
		if not showCfg then return end
		local nodeBg = gt6.seekNodeByName(self.rootNode,"Spr_hun_bg")
		nodeBg:setVisible(false)
		local nodePos = cc.p(nodeBg:getPosition())
		local spBg = ccui.ImageView:create(showCfg.spBgName,showCfg.spBgResType)
		spBg:setPosition(nodePos)
		spBg:setName("SPBG")
		self.playMjLayer:addChild(spBg)
		local mjTileName = nil 
		if mjColor == 0 or mjNumber == 0 then 
			mjTileName = string.format("tdbgs_%d.png", 4)
		else
			mjTileName = self:getMJTileResName(4,mjColor, mjNumber,nil,true)
		end
		print("mjTileName in spBgName.."..mjTileName)
		local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
		mjTileSpr:setScale(0.8)
		mjTileSpr:setPosition(spBg:getContentSize().width/2,spBg:getContentSize().height*0.55)
		spBg:addChild(mjTileSpr)

		local spKuang = ccui.ImageView:create("gt6_baolight.png",ccui.TextureResType.plistType)
		spKuang:setPosition(spBg:getContentSize().width/2,spBg:getContentSize().height*0.55)
		spBg:addChild(spKuang)
		self:addSpecialCardTip(spBg,data.otherCards)
	end
end

--打宝显示
function PlaySceneCS:daBaoShow(msgTbl)
	local seatIdx = msgTbl.m_pos + 1

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local color = msgTbl.m_BaoCards[1][1]
	local number = msgTbl.m_BaoCards[1][2]

	local function showBao( color,number,msgTbl )
		local data = {}
		data.showType = "BAO"
		data.mjColor = color
		data.mjNumber = number
		data.otherCards = self:copyTab(msgTbl.m_BaoCards)
		data.allCards = msgTbl.m_BaoCards
		table.remove(data.otherCards,1)
		self:showSpecialCards(data)
	end
   

	if msgTbl.m_type == 1 or msgTbl.m_type == 3 then -- 打宝
		if self.m_noPlayDaBaoAnim then 

		else
			self.isDabao = true
			-- 播放打宝动画
			local csbNode = nil
			local action = nil
			local actionName = nil
			csbNode, action = gt6.createCSAnimation(PlaySceneCS.animPath.."dabao" .. roomPlayer.displaySeatIdx .. ".csb")
			actionName = "dabao"
			csbNode:setPosition(gt6.winCenter)
			self:addChild(csbNode,PlaySceneCS.ZOrder.MJTILES)
			gt6.soundEngine:playEffect("common/dabao")
			action:play(actionName, false)
			action:setFrameEventCallFunc(function(frame)
				csbNode:removeFromParent()
				self.isDabao = false
			end) 
		end
		if seatIdx == self.playerSeatIdx then
			if color and number then
				showBao(color,number,msgTbl)
			end
		else
			showBao(0,0,msgTbl)
		end
		if msgTbl.m_type == 3 then
			self.m_baoTable = {}
			if color  and number  then
			   showBao(color,number,msgTbl)	
			end
			if msgTbl.m_usedCards and next(msgTbl.m_usedCards) then --吉林长春换宝时显示角标
				for i = 1,#msgTbl.m_usedCards do 
					table.insert(self.m_baoTable,{msgTbl.m_usedCards[i][1],msgTbl.m_usedCards[i][2]})
				end
				-- 刷新屏幕上的选项
				for i,v in ipairs(self.allCardSprites) do
					if v[2] and not tolua.isnull(v[2]) then
						self:addMJflag(v[3], v[2])
					end
				end
			end				
		end
	elseif  msgTbl.m_type == 2 then -- 看宝
		gt6.soundEngine:playEffect("common/jiebao")
		if color and  number  then
		   	showBao(color,number,msgTbl)
		end			
		
	end

end

-- start --
--------------------------------
-- @class function
-- @description 游戏开始玩家起始胡牌决策(计算积分而已),发牌前执行
-- end --
function PlaySceneCS:onRcvStartDecision(msgTbl)
	local seatIdx = msgTbl.m_pos + 1
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)

	local Node_dabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
	local Spr_mjTile = gt6.seekNodeByName(Node_dabao, "Spr_mjTile")
	local notBao = gt6.seekNodeByName(self.rootNode, "notBao")

	local sendPass = nil
	if #msgTbl.m_BaoCards > 0 then
		self:daBaoShow(msgTbl)
	
	else
		Node_dabao:setVisible(false)
		Spr_mjTile:setVisible(false)
		notBao:setVisible(true)
	end

	local thinkData =  self:checkThinkDuplicate(msgTbl.m_think)
	if not thinkData or not next(thinkData) then return end 
	thinkData.msgId = gt6.GC_MAKE_DECISION
	thinkData.msgIdToSend = gt6.CG_PLAYER_DECISION
	thinkData.mjColor  = msgTbl.m_think[1][#msgTbl.m_think[1]][1][1]
	thinkData.mjNumber  = msgTbl.m_think[1][#msgTbl.m_think[1]][1][2]
	print("onRcvStartDecision")
	dump(thinkData)
	for _ ,v in ipairs(thinkData) do 
		if v.mjData and next(v.mjData) and v.mjData[1].think_type == 4 then
			v.msgIdToSend = gt6.CG_SHOW_MJTILE
		end
	end
	self:createNewBtns(thinkData) 
end


function PlaySceneCS:onRcvRoundReport(msgTbl)
	if not msgTbl.delayTime and msgTbl.m_showJieSuan ~= 0 then 
		msgTbl.delayTime = true
		--self.infoForReport = self:copyTab(self.common_ui_layer.roomPlayers)
		performWithDelay(self,function ()
			self:onRcvRoundReport(msgTbl)
			for i=1,gt6.totalPlayerNum do
				-- 移除托管机器人
				local trusteeshipNode = self.rootNode:getChildByName("Node_trusteeship_"..i)
				if trusteeshipNode then
					trusteeshipNode:removeFromParent()
				end
			end
		end,self.m_roundDelay)

		self:playStartBoardEnd()
		self:roundEnd()

		return
	end

	self:setStatus(gt6.CommonConst.ROOM_STATUS.ROUND_END)

	self:removeTrusteeshipBtn()

	if self:isCoinRoom() or gt6.isMatch then 
		gt6.seekNodeByName(self,"Btn_ready"):setVisible(false)
	else
		gt6.seekNodeByName(self,"Btn_ready"):setVisible(true)
	end
	
	-- 停止倒计时音效
	self.playTimeCD = 0

	self.mIsInTrusteeship = false
	self.isStart = false

	-- 移除所有麻将
	self.playMjLayer:removeAllChildren()
	-- 隐藏座次标识
	local turnPosBgSpr = gt6.seekNodeByName(self.rootNode, "Spr_turnPosBg")
	turnPosBgSpr:setVisible(false)
	-- for i = 1 ,self.playMaxNum do 
	-- 	local displaySeatIdx = self.playerSeatTable[i]
	-- 	self.common_ui_layer:createWaitingAnim(displaySeatIdx)
	-- end

	self.m_startGame = false
	self:hideSpCardShow(true)
	-- 隐藏牌局状态
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(false)
	-- 隐藏倒计时
	self.playTimeCDLabel:setVisible(false)
	-- 隐藏出牌标识
	self.outMjtileSignNode:setVisible(false)
	-- 隐藏决策
	local decisionBtnNode = gt6.seekNodeByName(self.rootNode, "Node_decisionBtn")
	decisionBtnNode:setVisible(false)
	local selfDrawnDcsNode = gt6.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
	selfDrawnDcsNode:setVisible(false)
	local nodeDabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
	nodeDabao:setVisible(false)
	local notBao = gt6.seekNodeByName(self.rootNode, "notBao")
	notBao:setVisible(false)
	local baopai_bg = gt6.seekNodeByName(self.rootNode,"Spr_baopai_bg")
	baopai_bg:setVisible(false)
	self:clearBeforeStateSp()
	-- 根据玩法判断是否需要发送本局的日志
	if gt6.g_videoID and gt6.g_videoID ~= "" and gt6.bSaveGameLog then
		gt6.socketClient:sendMessageLog(gt6.g_videoID .. "_" .. self.playerSeatIdx)				
	end

	-- 弹出局结算界面
	if msgTbl.m_end == 0 then -- 不是最后一局
		if gt6.hasRoomPlayerBeRemoved == true then
			self:createRounReport("app/gameType/1MJ/playScene/RoundReportMJ",msgTbl,1)
		else
			self:createRounReport("app/gameType/1MJ/playScene/RoundReportMJ",msgTbl,msgTbl.m_end)
		end
	elseif msgTbl.m_showJieSuan == 0 then --直接退出不进入结算页面
		print("-----> playsene_mj 弹出局结算界面 msgTbl.m_showJieSuan = ",msgTbl.m_showJieSuan)
		gt6.dispatchEvent(gt6.EventType.BACK_MAIN_SCENE)
	else

		self:createRounReport("app/gameType/1MJ/playScene/RoundReportMJ",msgTbl,msgTbl.m_end)
	end
	self.playMjLayer:removeAllChildren()

		--手动移除其他人
	-- if self.isGolden  then 
	-- 	for i, v in pairs(self.common_ui_layer.roomPlayers) do
	-- 		if v and next(v) and v.seatIdx ~= self.playerSeatIdx then
	-- 			self.common_ui_layer:onRcvRemovePlayer({m_pos = v.seatIdx - 1})
	-- 		end
	-- 	end
	-- end
end

function PlaySceneCS:hideSpCardShow( isHide )		
	local Node_dabao_bg = gt6.seekNodeByName(self.rootNode, "Spr_hun_bg")
	local Node_dabao = gt6.seekNodeByName(self.rootNode, "Node_dabao")
	local Spr_mjTile = gt6.seekNodeByName(Node_dabao, "Spr_mjTile")
    local baoBg = gt6.seekNodeByName(self.rootNode,"Spr_baopai_bg")
	if isHide then
		Node_dabao_bg:setVisible(false)
		Node_dabao:setVisible(false)
		Spr_mjTile:setVisible(false)
		baoBg:setVisible(false)
	else
		Node_dabao_bg:setVisible(true)
		Node_dabao:setVisible(true)
		Spr_mjTile:setVisible(true)
		baoBg:setVisible(true)
	end
end

function PlaySceneCS:copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
end

function PlaySceneCS:onRcvFinalReport(msgTbl)
	print("---> self.isGolden , isMatch = ",self.isGolden,gt6.isMatch)
	if self:isCoinRoom() and not gt6.isMatch then 
		gt6.dispatchEvent(gt6.EventType.BACK_MAIN_SCENE)
	else
		print("--> 比赛结算")
		if gt6.isMatch then
		 	print("-----> 当前是比赛场。。。。")
		 	return 
		end
		print("---> sure ? ")
		if not msgTbl.delayTime then 
			--self.infoForReport = self:copyTab(self.common_ui_layer.roomPlayers)
			msgTbl.delayTime = self.m_roundDelay + 0.1
			performWithDelay(self,function( )
				self:onRcvFinalReport(msgTbl)
			end,msgTbl.delayTime)
			return 
		end
		 -- 弹出总结算界面
		local room_players = gt6.PlayersManager:getAllRoomPlayers()
		local finalReport = require("app/public/inGame/FinalReport"):create(room_players, msgTbl,nil,self.common_ui_layer,self)
		self:addChild(finalReport, PlaySceneCS.ZOrder.REPORT)
		-- self.playMjLayer:removeAllChildren()
	end

end

-- start --
--------------------------------   
-- @class function
-- @description 设置玩家麻将基础参考位置
-- @param displaySeatIdx 显示座位编号
-- @return 玩家麻将基础参考位置
-- end --
function PlaySceneCS:setPlayerMjTilesReferPos(displaySeatIdx)
	local mjTilesReferPos = {}

	local playNode = gt6.seekNodeByName(self.rootNode, "Node_play")
	local mjTilesReferNode = gt6.seekNodeByName(playNode, "Node_playerMjTiles_" .. displaySeatIdx)

	-- 持有牌数据
	local mjTileHoldSprF = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileHold_1")
	local mjTileHoldSprS = gt6.seekNodeByName(mjTilesReferNode, "Spr_mjTileHold_2")
	mjTilesReferPos.holdStart = gt6.getRealWordPosition(mjTileHoldSprF)
	mjTilesReferPos.holdSpace = cc.pSub(cc.p(mjTileHoldSprS:getPosition()), cc.p(mjTileHoldSprF:getPosition()))

	---回放位置修正
	mjTilesReferPos.holdStart = cc.pAdd(mjTilesReferPos.holdStart,self.m_FIXREPLAYHOLDPOS[displaySeatIdx])
	mjTilesReferPos.holdSpace = cc.pSub(mjTilesReferPos.holdSpace,self.m_FIXREPLAYERPOS[displaySeatIdx])
	
	local mjTilesOutReferNode = gt6.seekNodeByName(playNode,"Node_playerOutMjTiles_"..displaySeatIdx)
	-- 打出牌数据
	local mjTileOutSprF = gt6.seekNodeByName(mjTilesOutReferNode, "Spr_mjTileOut_1")
	local mjTileOutSprS = gt6.seekNodeByName(mjTilesOutReferNode, "Spr_mjTileOut_2")
	local mjTileOutSprT = gt6.seekNodeByName(mjTilesOutReferNode, "Spr_mjTileOut_3")
	mjTilesReferPos.outStart = gt6.getRealWordPosition(mjTileOutSprF)
	mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprS:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	mjTilesReferPos.outSpaceV = cc.pSub(cc.p(mjTileOutSprT:getPosition()), cc.p(mjTileOutSprF:getPosition()))

	--------fix 2人麻将出牌位置----------
	if self.playMaxNum and self.playMaxNum == 2  then 
		mjTilesReferPos.outStart = cc.pSub(mjTilesReferPos.outStart,mjTilesReferPos.outSpaceV)
		mjTilesReferPos.outStart = cc.pSub(mjTilesReferPos.outStart,cc.pMul(mjTilesReferPos.outSpaceH,5))
	end


	-- 碰，杠牌数据
	local mjTileGroupPanel = gt6.seekNodeByName(mjTilesReferNode, "Panel_mjTileGroup")
	local firstCPGCard = gt6.seekNodeByName(mjTileGroupPanel, "Spr_mjTile_1")
	local secondCPGCard = gt6.seekNodeByName(mjTileGroupPanel, "Spr_mjTile_2")
	mjTilesReferPos.firstCPGCardPos = cc.p(firstCPGCard:getPosition())
	mjTilesReferPos.secondCPGCardPos = cc.p(secondCPGCard:getPosition())
	mjTilesReferPos.CPGCardSpace = cc.pSub(mjTilesReferPos.secondCPGCardPos,mjTilesReferPos.firstCPGCardPos)
	local CPGCardScale = {
		1,
		1,
		1,
		1
	}

	mjTilesReferPos.CPGCardSpace = cc.pMul(mjTilesReferPos.CPGCardSpace,CPGCardScale[displaySeatIdx])


	-- local groupMjTilesPos = {}
	-- for _, groupTileSpr in ipairs(mjTileGroupPanel:getChildren()) do
	-- 	table.insert(groupMjTilesPos, cc.p(groupTileSpr:getPosition()))
	-- end
	-- mjTilesReferPos.groupMjTilesPos = groupMjTilesPos
	mjTilesReferPos.groupStartPos = gt6.getRealWordPosition(mjTileGroupPanel)
	-- mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos ,self.m_FIXREPLAYRGROUP[displaySeatIdx])
	-- local groupSize = mjTileGroupPanel:getContentSize()
	-- if displaySeatIdx == 1  then
	-- 		mjTilesReferPos.groupSpace = cc.p(0, groupSize.height + 5)
	-- elseif displaySeatIdx == 3 then
	-- 		mjTilesReferPos.groupSpace = cc.p(0, groupSize.height + 3)
	-- 		mjTilesReferPos.groupSpace.y = -mjTilesReferPos.groupSpace.y
	-- else
	-- 	mjTilesReferPos.groupSpace = cc.p(groupSize.width + 3, 0)
	-- 	if displaySeatIdx == 2 then
	-- 		mjTilesReferPos.groupSpace.x = -mjTilesReferPos.groupSpace.x
	-- 	end
	-- end

	mjTilesReferPos.m_huSpace = mjTilesReferPos.CPGCardSpace
	-- -- 胡牌显示坐标
	-- if displaySeatIdx == 1 then
	-- 	mjTilesReferPos.m_huSpace = cc.p( groupMjTilesPos[2].x-groupMjTilesPos[3].x, groupMjTilesPos[2].y-groupMjTilesPos[3].y)
	-- else
	-- 	mjTilesReferPos.m_huSpace = cc.p( groupMjTilesPos[2].x-groupMjTilesPos[1].x, groupMjTilesPos[2].y-groupMjTilesPos[1].y)
	-- end

	-- 当前出牌展示位置
	local showMjTileNode = gt6.seekNodeByName(mjTilesReferNode, "Node_showMjTile")
	mjTilesReferPos.showMjTilePos = gt6.getRealWordPosition(showMjTileNode)

	--3人位置调整
	if self.playMaxNum == 3 then
		if displaySeatIdx == 4 then
			mjTilesReferPos.outStart.y = mjTilesReferPos.outStart.y + 50
		end
	end

	return mjTilesReferPos
end

-- start --
--------------------------------
-- @class function
-- @description 设置座位编号标识
-- @param seatIdx 座位编号
-- end --
function PlaySceneCS:setTurnSeatSign(seatId)
	print("setTurnSeatSign-----")
	if seatId == 100 then --不指示
		return
	end
	local seatIdx = self:getDisplaySeat(seatId)
	-- 显示轮到的玩家座位标识
	local turnPosBgSpr = gt6.seekNodeByName(self.rootNode, "Spr_turnPosBg")
	turnPosBgSpr:setVisible(true)	
	local turnPosSpr = gt6.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. seatIdx)
	local spr_tri=gt6.seekNodeByName(turnPosBgSpr,"spr_tri_"..seatIdx)
	spr_tri:setVisible(true)
	turnPosSpr:setVisible(true)
	if self.preTurnSeatIdx and self.preTurnSeatIdx ~= seatIdx then
		local turnPosSpr = gt6.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. self.preTurnSeatIdx)
		turnPosSpr:setVisible(false)
		local spr_tri=gt6.seekNodeByName(turnPosBgSpr,"spr_tri_"..self.preTurnSeatIdx)
		spr_tri:setVisible(false)
	end
	self.preTurnSeatIdx = seatIdx
	
end

--临时
function PlaySceneCS:isTurnMe()
	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	local room_player = room_players[self.playerSeatIdx]

	if room_player then 
		if self.preTurnSeatIdx == room_player.displaySeatIdx then
			print("isTurnMe-----")
			return true 
		end
	end 
	
	return false 
end
-- start --
--------------------------------
-- @class function
-- @description 出牌倒计时
-- @param
-- @param
-- @param
-- @return
-- end --
function PlaySceneCS:playTimeCDStart(timeDuration)
	self.playTimeCD = timeDuration

	self.isVibrateAlarm = false
	self.playTimeCDLabel:setVisible(true)
	self.playTimeCDLabel:setString(tostring(timeDuration))
end

-- start --
--------------------------------
-- @class function
-- @description 更新出牌倒计时
-- @param delta 定时器周期
-- end --
function PlaySceneCS:playTimeCDUpdate(delta)
	if not self.playTimeCD then
		return
	end

	self.playTimeCD = self.playTimeCD - delta
	if self.playTimeCD < 0 then
		self.playTimeCD = 0
	end
	if (self.isPlayerShow or self.isPlayerDecision) and self.playTimeCD <= 3 and not self.isVibrateAlarm then
		-- 剩余3s开始播放警报声音+震动一下手机
		self.isVibrateAlarm = true
		-- 播放声音
		self.playCDAudioID = gt6.soundEngine:playEffect("common/timeup_alarm")
		-- 震动提醒
		cc.Device:vibrate(1)
	end
	local timeCD = math.ceil(self.playTimeCD)
	self.playTimeCDLabel:setString(tostring(timeCD))
end

-- start --
--------------------------------
-- @class function
-- @description 给玩家发牌
-- @param mjColor
-- @param mjNumber
-- end --
function PlaySceneCS:addMjTileToPlayer(mjColor, mjNumber,seatIdx,action,newStart)
	local mjTileName = self:getMJTileResName( 4, mjColor, mjNumber, 1)
	local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
	self.playMjLayer:addChild(mjTileSpr)
	if newStart then
		mjTileSpr:setVisible(false)
		table.insert(self.toBeShow,mjTileSpr)
	end

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx) or gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	if not roomPlayer or not next(roomPlayer)  then return mjTile end
	table.insert(roomPlayer.holdMjTiles, mjTile)

	--检查手里只有混时,让其出牌
	if self.m_hui and next(self.m_hui) and self.m_noPlayHui  then
		local holdMjTilesCopy = self:copyTab(roomPlayer.holdMjTiles)
		local huiTable = {}
		for i,v in ipairs(self.m_hui) do
			local  color = v[1]
			local number = v[2]
			for i = #holdMjTilesCopy, 1, -1 do 
				local mjTile = holdMjTilesCopy[i]
				if mjTile  then
					if mjTile.mjColor  == color and mjTile.mjNumber == number then
						table.remove(holdMjTilesCopy,i)
					end
				end
			end
		end
		if #holdMjTilesCopy == 0 then
			self.m_holdMjOnlyHui = true
			print("only hun ...")
		else
			self.m_holdMjOnlyHui = false
		end	
	end
	--混牌是否可以触摸,设灰色
	self:isTouchHui(mjTile,true)
	self:canNotPlay(mjTile,true)
	return mjTile
end

-- start --
--------------------------------
-- @class function
-- @description 玩家麻将牌根据花色，编号重新排序
-- end --
function PlaySceneCS:sortPlayerMjTiles(roomPlayer,isReplay)
	local roomPlayer = roomPlayer or gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if not roomPlayer.holdMjTiles or #roomPlayer.holdMjTiles == 0 then return end
	--重新排序的方法
	local function _sortMj(holdMjTiles)
		if not holdMjTiles or not next(holdMjTiles) then
			return {}
		end
		-- 按照花色分类
		local colorsMjTiles = {}
		table.sort(holdMjTiles, function(a, b)
			return a.mjColor < b.mjColor
		end)

		local colorsMjTiles = {}
		for _, mjTile in ipairs(holdMjTiles) do
			if not colorsMjTiles[mjTile.mjColor] then
				colorsMjTiles[mjTile.mjColor] = {}
			end
			table.insert(colorsMjTiles[mjTile.mjColor], mjTile)
		end
		-- 同花色从小到大排序
		local transMjTiles = {}
		for _, sameColorMjTiles in pairs(colorsMjTiles) do
			table.sort(sameColorMjTiles, function(a, b)
				return a.mjNumber < b.mjNumber
			end)
			for _, mjTile in pairs(sameColorMjTiles) do
				if mjTile.mjColor ~= 4 then
					table.insert(transMjTiles, mjTile)
				end
			end
		end
		for _, sameColorMjTiles in pairs(colorsMjTiles) do
			for _, mjTile in pairs(sameColorMjTiles) do
				if mjTile.mjColor == 4 then
					table.insert(transMjTiles, mjTile)
				end
			end
		end

		return transMjTiles
	end

	if self.m_hui and next(self.m_hui)   then
		local huiTable = {}
		for i,v in ipairs(self.m_hui) do
			local  color = v[1]
			local number = v[2]
			for i = #roomPlayer.holdMjTiles, 1, -1 do 
				local mjTile = roomPlayer.holdMjTiles[i]
				if mjTile  then
					if mjTile.mjColor  == color and mjTile.mjNumber == number then
						--如果rePosHui  那么重新排序混牌
						if  self.m_rePosHui then
							table.insert(huiTable,mjTile) --取出混牌
							table.remove(roomPlayer.holdMjTiles,i) --移除holdMjTiles的混牌
						end
						--混牌是否可以打,不可打置灰
						if  self.m_noPlayHui and not tolua.isnull(mjTile.mjTileSpr)  then
							mjTile.mjTileSpr:setColor(PlaySceneCS.SPPARAMS.PAIHUISE)
						elseif not tolua.isnull(mjTile.mjTileSpr) then
							mjTile.mjTileSpr:setColor(cc.WHITE)
						end
					end
				end
			end
		end
		
		local rePosedHui = _sortMj(huiTable) --排序混牌
		local rePosHold  = _sortMj(roomPlayer.holdMjTiles) --排序其他麻将
		if rePosedHui and next(rePosedHui) then
			for i ,v in ipairs(rePosedHui) do
				table.insert(rePosHold,i,v) --插入混牌
			end
		end
		roomPlayer.holdMjTiles = rePosHold

	else
		roomPlayer.holdMjTiles =  _sortMj(roomPlayer.holdMjTiles)
	end

	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart
	for k, mjTile in ipairs(roomPlayer.holdMjTiles ) do
		if not tolua.isnull(mjTile.mjTileSpr) then 
			mjTile.mjTileSpr:stopAllActions()
			mjTile.mjTileSpr:setPosition(mjTilePos)
			mjTile.mjTileSpr:setOpacity(255)
			self:canNotPlay(mjTile,true)
			self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt6.winSize.height - mjTilePos.y)+PlaySceneCS.SPPARAMS.MJMAXORDER)
			mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
			if k == 13  then -- 如果手里有14张得话，那么说明是庄家  and (not isReplay)
				mjTilePos = cc.pAdd(mjTilePos, cc.p(36, 0)) 
			end
		end
	end
end

--混牌不可打
function PlaySceneCS:isTouchHui(mjTile,setColor)
	if self.m_hui and next(self.m_hui) and self.m_noPlayHui then
		for k,v in pairs(self.m_hui) do
			local color = v[1]
			local number = v[2]
			if mjTile.mjColor == color and mjTile.mjNumber == number then
				if setColor then 
					mjTile.mjTileSpr:setColor(PlaySceneCS.SPPARAMS.PAIHUISE)
				end
				return true 
			else
				if setColor then 
					mjTile.mjTileSpr:setColor(cc.WHITE)
				end
			end
		end
	end
	return  false

end

function PlaySceneCS:canNotPlay(mjTile,setColor)
	if self.m_canNotPlay and next(self.m_canNotPlay) then
		
		for k,v in pairs(self.m_canNotPlay) do
			local color = v[1]
			-- print("color.."..color)
			local number = v[2]
			if mjTile.mjColor == color and mjTile.mjNumber == number then
				if setColor then 
					print("canNotPlay...")
					mjTile.mjTileSpr:setColor(PlaySceneCS.SPPARAMS.PAIHUISE)
				end
				return true 
			else
				if setColor then 
					mjTile.mjTileSpr:setColor(cc.WHITE)
				end
			end
		end
	end
	return  false

end

-- start --
--------------------------------
-- @class function
-- @description 选中玩家麻将牌
-- @return 选中的麻将牌
-- end --
function PlaySceneCS:touchPlayerMjTiles(touch)
	local isSound=isSound or true
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	if not roomPlayer or not next(roomPlayer) or not roomPlayer.holdMjTiles or not next(roomPlayer.holdMjTiles) then return end
	for idx, mjTile in ipairs(roomPlayer.holdMjTiles) do
		if mjTile and mjTile.mjTileSpr and not tolua.isnull(mjTile.mjTileSpr) then
			local touchPoint = mjTile.mjTileSpr:convertTouchToNodeSpace(touch)
			local mjTileSize = mjTile.mjTileSpr:getContentSize()
			local mjTileRect = cc.rect(0, 0, mjTileSize.width, mjTileSize.height)
			if cc.rectContainsPoint(mjTileRect, touchPoint) then
				if roomPlayer.m_ting and #roomPlayer.m_ting > 0 then
					print("听操作除听得牌其它牌不可点")
					local hasCard = false
					for _, tingCard in ipairs(roomPlayer.m_ting) do
						if tingCard[1] == mjTile.mjColor and tingCard[2] == mjTile.mjNumber then
							print("touchPlayerMjTiles")
							isSound = true
							break
						else
							isSound=false
						end
					end
					
				end
				--是否触摸的是混
				local isHui = self:isTouchHui(mjTile)
				local isNotCanPlay = self:canNotPlay(mjTile)
				if  (isHui and not self.m_holdMjOnlyHui and  self.m_isTingPai ~= 1) or isNotCanPlay then return nil end
			
				if idx ~=self.soundIdx and isSound then 
					gt6.soundEngine:playEffect("common/audio_card_click")
				end
				self.soundIdx=idx
			
				return mjTile, idx
			end
		end
	end

	return nil
end

function PlaySceneCS:updateOutMjTilesPosition(seatIdx)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart
	for k, v in pairs(roomPlayer.outMjTiles) do
		-- 显示已出牌
		local lineCount = math.ceil(k / self.mjTilePerLine) - 1
		local lineIdx = k - lineCount * self.mjTilePerLine - 1
		local tilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
		tilePos = cc.pAdd(tilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
		v.mjTileSpr:setPosition(tilePos)
		--zroder
		if roomPlayer.displaySeatIdx == 1 then
			v.mjTileSpr:setLocalZOrder(gt6.winSize.height - tilePos.y + tilePos.x )
		elseif roomPlayer.displaySeatIdx == 2 then
			v.mjTileSpr:setLocalZOrder(gt6.winSize.height - tilePos.y - tilePos.x )
		elseif roomPlayer.displaySeatIdx == 3 then
			v.mjTileSpr:setLocalZOrder(gt6.winSize.height - tilePos.y - tilePos.x)
		elseif roomPlayer.displaySeatIdx == 4 then
			v.mjTileSpr:setLocalZOrder(10000 + gt6.winSize.height - tilePos.y - tilePos.x)
			
		end
	end
end

function PlaySceneCS:getHuPosition(_displaySeatIdx)
	local linePos = gt6.seekNodeByName(self,"sp_tableLine_".._displaySeatIdx)
	if linePos then
		if _displaySeatIdx == 4 then
			local px,py = cc.pAdd(cc.p(linePos:getPosition()),cc.p(0,50))
			return  cc.p(px,py)
		else
			return  cc.p(linePos:getPosition()) 
		end
	else
		return gt6.winCenter
	end
end

--点炮胡的那种牌的位置
function PlaySceneCS:getHuCardPosition(outMjTiles,color,num)
	local hu_pos = nil 
	for _,value in ipairs(outMjTiles) do
		if value.mjColor == color and value.mjNumber == num then
			hu_pos = cc.p(value.mjTileSpr:getPosition())
		end 
	end 

	return hu_pos
end

function PlaySceneCS:playEffect(_name, pos, loop, callBack)
	if cc.FileUtils:getInstance():isFileExist(PlaySceneCS.animPath .. _name .. ".csb") then
		loop = loop or false
		local decisionSignSpr, action = gt6.createCSAnimation(PlaySceneCS.animPath .. _name .. ".csb")
		action:play(_name, loop)
		decisionSignSpr:setPosition(pos)
		local delayTime = cc.DelayTime:create(action:getEndFrame() / 60)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:removeFromParent()
			if callBack then
				callBack()
			end
		end)
		if loop then 

		else
			local seqAction = cc.Sequence:create(delayTime, callFunc)
			decisionSignSpr:runAction(seqAction)
		end
		
		return decisionSignSpr
	else
		return nil
	end
	
end

--创建
function PlaySceneCS:createMultiChioceBtns(Data)
	print("createmulti")
	dump(Data)
	local btnData = Data.cardList
	local btnFlag = Data.flag
	local image_bg = ccui.ImageView:create("gt6_btmjbg_lzoom.png",ccui.TextureResType.plistType)
	image_bg:setScale9Enabled(true)
	image_bg:setCapInsets(cc.rect(19,19,21,21))
	image_bg:setAnchorPoint(cc.p(0,0))
	
	local mjTileName = self:getMJTileResName(4, 2, 2, 1)
	local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
	image_bg :setContentSize(cc.size((mjTileSpr:getContentSize().width ) * (#btnData) + 20 ,mjTileSpr:getContentSize().height*1.2))
	for i = 1, #btnData do
		local mjColor = btnData[i].mjColor
		local mjNumber = btnData[i].mjNumber
		if mjColor == 0 or mjNumber == 0 then return end
		local mjSprName = self:getMJTileResName(4, mjColor, mjNumber,1)
		local button = self:createWithSpriteFrameName(mjSprName)
		button:setAnchorPoint(cc.p(0,0.5))
		button:setLocalZOrder(100-i)
		button:setPosition(cc.p((mjTileSpr:getContentSize().width)*(i-1) + 10 , mjTileSpr:getContentSize().height*0.6))
		image_bg:addChild(button)
	end
	return image_bg
end
-- seatIdx: 1~4 的数值　
function PlaySceneCS:getDisplaySeat(seatIdx)
	local displaySeatIdx = 1
	-- 当前出牌座位
	if self.playMaxNum == 2 then
		if self.playerSeatIdx == 1 then
			if seatIdx == 2 then
				displaySeatIdx = 2
			else
				displaySeatIdx = 4
			end
		elseif self.playerSeatIdx == 2 then
			if seatIdx == 1 then
				displaySeatIdx = 2
			else
				displaySeatIdx = 4
			end
		end
	elseif self.playMaxNum == 3 then
		if self.playerSeatIdx == 1 then
			if seatIdx == 2 then
				displaySeatIdx = 1
			elseif seatIdx == 3 then
				displaySeatIdx = 3
			else
				displaySeatIdx = 4
			end
		elseif self.playerSeatIdx == 2 then
			if seatIdx == 3 then
				displaySeatIdx = 1
			elseif seatIdx == 1 then
				displaySeatIdx = 3
			else
				displaySeatIdx = 4
			end
		elseif self.playerSeatIdx == 3 then
			if seatIdx == 1 then
				displaySeatIdx = 1
			elseif seatIdx == 2 then
				displaySeatIdx = 3
			else
				displaySeatIdx = 4
			end
		end
	else
		local seat_offset = gt6.PlayersManager:getSeatOffset()
		local realSeat = (seatIdx+seat_offset)%4
	  	if realSeat == 0 then
	  		realSeat = 4
	  	end
	  	displaySeatIdx = realSeat
	end
	return displaySeatIdx
end

function PlaySceneCS:getMJTileResName(displaySeatIdx, color, num, isBig,isChuPai)
	isBig = isBig or 0
	isChuPai = isChuPai and 1 or 0
	return displaySeatIdx.."_"..color.."_"..num.."_"..isBig.."_"..isChuPai
end

function PlaySceneCS:getRealMJTileResName(mjTileInfoStr)
	-- gt6.log("======getRealMJTileResName======"..mjTileInfoStr)
	if string.find(mjTileInfoStr, "tbgs") or string.find(mjTileInfoStr, "tdbgs") then
		return mjTileInfoStr
	else
		local subStrs = string.split(mjTileInfoStr, "_")
		local displaySeatIdx = tonumber(subStrs[1])
		local color = tonumber(subStrs[2])
		local num = tonumber(subStrs[3])
		local isBig = tonumber(subStrs[4])
		local isChuPai = tonumber(subStrs[5])

		local mjTileName = ""
		if isBig == 1 then
			mjTileName = string.format("p%db%d_%d.png", displaySeatIdx, color, num)
		else
			if isChuPai == 1 then --出牌单独资源
				mjTileName = string.format("p%ds%d_%d_chupai.png", displaySeatIdx, color, num)
			elseif isChuPai == 0 then
				mjTileName = string.format("p%ds%d_%d.png", displaySeatIdx, color, num)
			else
				mjTileName = mjTileInfoStr -- 更换牌面时
			end
		end

		mjTileName = gt6.getExternMjTileName(self.paimianNum, mjTileName)
		return mjTileName
	end
end

-- 给麻将增加角标
function PlaySceneCS:addMJflag(mjTileName, mjTileSpr)
	mjTileName = gt6.getBaseMjTileName(self.paimianNum, mjTileName)
	local pos  =string.find(mjTileName,"%tbgs")
	if pos then
		return
	end
	pos  =string.find(mjTileName,"%tdbgs")
	if pos then
		return
	end
	-- local playerNum=string.sub(mjTileName,2,2)
	-- local mjColor=string.sub(mjTileName,4,4)
	-- local mjNumber=string.sub(mjTileName,6,6)
	-- local bigOrSmall=string.sub(mjTileName,3,3)

	local subStrs = string.split(mjTileName, "_")
	local playerNum = tonumber(subStrs[1])
	local mjColor = tonumber(subStrs[2])
	local mjNumber = tonumber(subStrs[3])
	local bigOrSmall = tonumber(subStrs[4])

	if playerNum==nil or mjColor==nil or mjNumber==nil or bigOrSmall ==nil then
		return
	end
	-- 添加单个角标
	local function _addMJflag(data, pngName, flagTag, plistType)
		plistType = plistType or ccui.TextureResType.plistType
		mjTileSpr:removeChildByTag(flagTag)
		for i,v in pairs(data) do
			if tonumber(v[1])== mjColor and tonumber(v[2])==mjNumber then
				local scale = 1
				local imgFlagHui =ccui.ImageView:create()
				if bigOrSmall==1  and playerNum == 4  then
					 imgFlagHui:loadTexture(pngName.."4_big.png",plistType) --自己的牌
				elseif bigOrSmall==0   then  --打出的或者杠碰吃的牌
					--[[
						图片方向参见 hun_small_1 hun_small_2 hun_small_3 hun_small_4
					]]
					if  self.paimianNum and self.paimianNum == 1 and playerNum == 2  then
						playerNum = 4
						scale = 0.66
					end
					imgFlagHui:loadTexture(pngName.."small_"..playerNum..".png",plistType) 
				end
				if imgFlagHui then
					imgFlagHui:setScale(scale)
					imgFlagHui:setAnchorPoint(cc.p(0.5,0.5))
					mjTileSpr:addChild(imgFlagHui)
					local size=mjTileSpr:getContentSize()
					imgFlagHui:setPosition(size.width/2,size.height/2)
					imgFlagHui:setTag(flagTag)
				end
			end
		end	
	end
	-- "混儿"
	if self.m_hui and next(self.m_hui) then
		-- local pngName="gt6_hun_"
		_addMJflag(self.m_hui, self.FLAGS.HUN.pic, self.FLAGS.HUN.id,self.FLAGS.HUN.res)
	end		

	--宝牌显示
	if self.m_baoTable and next(self.m_baoTable) then
		local pngName="gt6_bao_"
		_addMJflag(self.m_baoTable, pngName, PlaySceneCS.SPPARAMS.CARD_FLAG_BAO)
	end
end
-- 封装
function PlaySceneCS:setSpriteFrame(mjTileName, mjTileSpr)
	-- gt6.log("==========setSpriteFrame========"..mjTileName)
	local mjTile_Name = mjTileName
	local paibeiName = self:getPaibeiSpriteFrameName(mjTileName)
	mjTileName = self:getRealMJTileResName(mjTileName)
	mjTileName = gt6.getExternMjTileName(self.paimianNum, mjTileName)
	local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(paibeiName)
	-- 进入异常状态
	if sp == nil then
		if saveLogOnWeb then
			saveLogOnWeb("setSpriteFrame Error " .. paibeiName)
		end

		-- cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistPathBig)
		-- cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistPathSmall)
		-- cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistGameUI)
		Utils6.loadPlist(reload_plists)
		gt6.checkLoadPaiBei(self.paibeiNum)
		mjTileSpr = cc.Sprite:createWithSpriteFrameName(paibeiName)
	else
		mjTileSpr:setSpriteFrame(paibeiName)
	end	

	if mjTileSpr.spTitle then
		mjTileSpr.spTitle:loadTexture(mjTileName,ccui.TextureResType.plistType)
	else
		local spTitle = ccui.ImageView:create()
		spTitle:loadTexture(mjTileName,ccui.TextureResType.plistType)
		mjTileSpr:addChild(spTitle)
		spTitle:setPosition(ccp(spTitle:getContentSize().width/2, spTitle:getContentSize().height/2))
		mjTileSpr.spTitle = spTitle		
	end

	self:addMJflag(mjTile_Name, mjTileSpr)
end

--打开胡牌tips界面
function PlaySceneCS:openHuTip(chooseMj)
	--这里如果出现崩溃会影响牌局流程 不合适
	xpcall(function()
		if chooseMj == nil or chooseMj.mjTileSpr == nil or chooseMj.mjTileSpr:getChildByName("Arrow") == nil then
			if self.huTipLayout ~= nil then
				 self.huTipLayout:setVisible(false)
			end
			return
		end

		local imgArrow = chooseMj.mjTileSpr:getChildByName("Arrow")

		if self.huTipLayout == nil then
			self.huTipLayout = require("app/gameType/1MJ/playScene/HuPaiTips"):create(imgArrow.date,self)
			self.huTipLayout:setLocalZOrder(PlaySceneCS.ZOrder.OPENHUPAITIPS)
			self.common_ui_layer:addChild(self.huTipLayout)

		else
			self.huTipLayout:setInfo(imgArrow.date,self)
		end

		local pos = gt6.getPosByRealSize(cc.p(chooseMj.mjTileSpr:getPositionX(),150))
		
		if pos.x+self.huTipLayout:getContentSize().width/2 +10 > gt6.winSize.width then
			pos.x = gt6.winSize.width - self.huTipLayout:getContentSize().width/2 - 10
		elseif pos.x-self.huTipLayout:getContentSize().width/2 -10 < 0 then
			pos.x = self.huTipLayout:getContentSize().width/2 + 10
		end


		self.huTipLayout:setPosition(pos)
		self.huTipLayout:setVisible(true)
	end,function( )
		print("openHu error")
	end)

	
end

--取消听牌按钮
function PlaySceneCS:cancelTing( )
	if self.m_cancelTing then 
		self.isPlayerDecision = false
		local cancelPic = "gt6_bt_quxiao.png"
		local cancelTingBtn = ccui.Button:create(cancelPic,cancelPic,cancelPic,ccui.TextureResType.plistType)
		cancelTingBtn:setPosition(gt6.winSize.width*0.8,gt6.winSize.height*0.3)
		self.rootNode:addChild(cancelTingBtn,PlaySceneCS.ZOrder.DECISION_BTN)
		cancelTingBtn:setName("CANCELTINGBTN")
		gt6.addBtnPressedListener(cancelTingBtn,function (sender)
			print("cacnel ting ....")
			local msgToSend = {}
			msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
			msgToSend.m_type = 120
			gt6.socketClient:sendMessage(msgToSend)
			sender:removeFromParent()
			local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
			for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
				mjTile.mjTileSpr:setColor(cc.WHITE)
			end
			roomPlayer.m_ting = {} 
			-- 选取了麻将的话复位
			if self.preClickMjTile  and self.preClickMjTile.mjTileSpr and not tolua.isnull( self.preClickMjTile.mjTileSpr ) then
				local mjTilePos2 = cc.p(self.preClickMjTile.mjTileSpr:getPosition())
				self.preClickMjTile.mjTileSpr:setPosition(mjTilePos2.x,self.mjTileOriginPos.y)
				self.preClickMjTile = nil 
			end

		end)
	end
end

function PlaySceneCS:createPaiMian(displaySeatIdx, color, num, isBig,isChuPai)
	local mjTileName = self:getMJTileResName(displaySeatIdx, color, num, isBig,isChuPai)
	mjTileName = self:getRealMJTileResName(mjTileName)
	mjTileName = gt6.getExternMjTileName(self.paimianNum, mjTileName)

	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	
	return mjTileSpr

end

function PlaySceneCS:createWithSpriteFrameName(mjTileName)
	local mjTile_Name = mjTileName
	local paibeiName = self:getPaibeiSpriteFrameName(mjTileName)
	mjTileName = self:getRealMJTileResName(mjTileName)
	
	mjTileName = gt6.getExternMjTileName(self.paimianNum, mjTileName)
	print("createWithSpriteFrameName....."..mjTileName)
	local mjTileSpr = nil
	local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(paibeiName)
	-- 进入异常状态 重连
	if sp == nil then
		cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistPathBig)
		cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistPathSmall)
		cc.SpriteFrameCache:getInstance():addSpriteFrames(PlaySceneCS.plistGameUI)
		gt6.checkLoadPaiBei(self.paibeiNum)
		if saveLogOnWeb then
			saveLogOnWeb("createWithSpriteFrameName Error " .. paibeiName)
		end
		mjTileSpr = cc.Sprite:createWithSpriteFrameName(paibeiName)
	else
		mjTileSpr = cc.Sprite:createWithSpriteFrameName(paibeiName)
	end

	if not string.find(mjTileName, "tbgs") and not string.find(mjTileName, "tdbgs") then
		-- 添加牌面
		print("mjTileName=="..tostring(mjTileName))
		
		local spTitle = ccui.ImageView:create()--ccui.ImageView:create(mjTileName,ccui.TextureResType.plistType)
		spTitle:loadTexture(mjTileName,ccui.TextureResType.plistType)
		mjTileSpr:addChild(spTitle)
		spTitle:setPosition(ccp(spTitle:getContentSize().width/2, spTitle:getContentSize().height/2))
		mjTileSpr.spTitle = spTitle
	end

	self:addMJflag(mjTile_Name, mjTileSpr)
	self.allCardSprites[#self.allCardSprites + 1] = {mjTileName, mjTileSpr, mjTile_Name}
	return mjTileSpr
end

function PlaySceneCS:getPaibeiSpriteFrameName(mjTileInfoStr)
	-- gt6.log("======getPaibeiSpriteFrameName===="..mjTileInfoStr)
	local paiBeiName = ""
	local paibeiNum = self.paibeiNum

	if string.find(mjTileInfoStr, "tbgs") then
		paiBeiName = "pb"..self.paibeiNum.."_tbgs_"..string.sub(mjTileInfoStr, -5)
	elseif string.find(mjTileInfoStr, "tdbgs") then
		paiBeiName = "pb"..self.paibeiNum.."_tdbgs_"..string.sub(mjTileInfoStr, -5)
	else
		local subStrs = string.split(mjTileInfoStr, "_")
		local displaySeatIdx = tonumber(subStrs[1])
		local isBig = tonumber(subStrs[4])
		local isChuPai = tonumber(subStrs[5])
		if displaySeatIdx == nil or isBig == nil or isChuPai == nil then
			-- paiBeiName = "pb"..self.paibeiNum.."_"..mjTileInfoStr	-- 设置牌面时
		else
			if isBig == 1 then
				paiBeiName = "pb"..self.paibeiNum..string.format("_p%db.png", displaySeatIdx)
			else
				if isChuPai == 1 then
					paiBeiName = "pb"..self.paibeiNum..string.format("_p%ds_chupai.png", displaySeatIdx)
				else
					paiBeiName = "pb"..self.paibeiNum..string.format("_p%ds.png", displaySeatIdx)
				end
			end
		end
	end
	-- gt6.log("======getPaibeiSpriteName===="..paiBeiName)
	return paiBeiName
end

-- 隐藏听的
function PlaySceneCS:showTingSprite(seatIdx,Tingtype)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local setPos = roomPlayer.displaySeatIdx
	for i=1,4 do
		local spr_ting = gt6.seekNodeByName(roomPlayer.head, "TING")
		if setPos == i then
			spr_ting:loadTexture("gt6_icon_ting.png",2)
			spr_ting:setVisible(true)
		end
	end	
end
----------------------CFGFunctions-------------------
--TIPS:
--CFGFunction
function PlaySceneCS:checkThinkDuplicate(m_think)
	if m_think and next(m_think) then 
		local thinkData = {}
		for k , think in ipairs(m_think) do 
			local data = {}
			if not g_jueCeId["id_"..think[1]] then
			 	g_jueCeId["id_"..think[1]] = {pic = "Defualt" , picResType = "LOCAL"}
			end 
			local withRegionName = "id_"..think[1].."_"..gt6.regionGroup .. "_".. (self.playType+1)
			local withGoldRegion = "id_"..think[1].."_"..self.m_gameStyle
			local jueCeData = g_jueCeId[withRegionName] or g_jueCeId[withGoldRegion] or  g_jueCeId["id_"..think[1]]
			data.pic = jueCeData.pic
			data.picResType = jueCeData.picResType
			data.mjData = {{think_type = think[1],think_data = think[2]}}
			local hasType = false
			for _ , value in pairs(thinkData) do 
				if value and value.pic == data.pic then 
					table.insert(value.mjData,{think_type = think[1],think_data = think[2]})
					hasType = true
					break
				end
			end
			if not hasType then  
				table.insert(thinkData,data)
			end
		end
		return thinkData
	else
		return {}
	end
end


--TIPS:
--CFGFunction
--设置报听可出的牌
function PlaySceneCS:setTingCards( roomPlayer,msgTbl )
	local HUISE = cc.c3b(180,180,180)
	if next(msgTbl.m_tingCards) then 
		print("设置听牌")
		roomPlayer.m_ting = {}
		for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
			local hasCard = false
			for _, tingCard in ipairs(msgTbl.m_tingCards) do
				if tingCard[1] == mjTile.mjColor and tingCard[2] == mjTile.mjNumber then
					if msgTbl.m_flag == 0 then

					else
						hasCard = true
					end
					break
				end
			end
			if hasCard then
				mjTile.mjTileSpr:setColor(cc.WHITE)
			else
				mjTile.mjTileSpr:setColor(HUISE)
			end
		end
		for _, tingCard in ipairs(msgTbl.m_tingCards) do
			table.insert(roomPlayer.m_ting, {tingCard[1], tingCard[2]})
		end
	else
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			mjTile.mjTileSpr:setColor(HUISE)
		end

	end
end

--TIPS:
--CFGFunction
function PlaySceneCS:onRcvTurnShowMjTile( msgTbl )
	-- 牌局状态,剩余牌
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	local remainTilesLabel = gt6.seekNodeByName(roundStateNode, "Label_remainTiles")
	remainTilesLabel:setString(tostring(msgTbl.m_dCount))

	local Font_remainCards = gt6.seekNodeByName(self.rootNode,"Font_remainCards")
	Font_remainCards:setString(tostring(msgTbl.m_dCount))

	local seatIdx = msgTbl.m_pos + 1
	-- 当前出牌座位
	self:setTurnSeatSign(seatIdx)
	-- 出牌倒计时
	self:playTimeCDStart(msgTbl.m_time)

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	if not roomPlayer or not next(roomPlayer) then return end

	if self:isPlayerSeat(seatIdx) then 
		if self.mIsInTrusteeship then
			self.isPlayerShow = false
		else
			self.isPlayerShow = true
		end
		self.m_isTingPai = msgTbl.m_ting
		if msgTbl.m_ting == 1 then 
			self:setTingCards(roomPlayer,msgTbl)
			if #msgTbl.m_think == 0 and #msgTbl.m_tingCards == 1 then
				local time = 0.2
				if self.isDabao then
					time = 1
				else
					time = 0.2
				end
				self.onUnpauseScheduler = performWithDelay(self, function()  
				    self:onUnpause(msgTbl, roomPlayer)
				    self.onUnpauseScheduler = nil
				end, time) 
				self.onUnpauseScheduler:setTag(PlaySceneCS.SPPARAMS.AUTO_PLAY)
			else
				self.m_tingState = false
			end
		end
		if msgTbl.m_flag == 0 then
			self:addMjToPlayer(roomPlayer,msgTbl)
		end
		--取消听/听牌状态／没打过牌／出牌状态／没有决策
		if self.m_cancelTing and not self.m_tingState and msgTbl.m_flag == 1 and msgTbl.m_ting == 1 and not next(msgTbl.m_think)  then
			self:cancelTing()
		end

		--和牌提示
		self:reciveHuPaiTipsMsg(msgTbl)

		local thinkData =  self:checkThinkDuplicate(msgTbl.m_think)
		print("thinkData...")
		dump(thinkData)
		if not thinkData or not next(thinkData) then return end 
		thinkData.msgId = gt6.GC_TURN_SHOW_MJTILE
		thinkData.msgIdToSend = gt6.CG_SHOW_MJTILE
		thinkData.mjColor = msgTbl.m_color
		thinkData.mjNumber = msgTbl.m_number
		self:createNewBtns(thinkData) 

	else
		if msgTbl.m_flag == 0 then
			local mjTilesReferPos = roomPlayer.mjTilesReferPos
			local mjTilePos = mjTilesReferPos.holdStart
			mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, roomPlayer.mjTilesRemainCount))
			roomPlayer.mjTilesRemainCount = roomPlayer.mjTilesRemainCount + 1
			local unVisibleMJ = roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount].mjTileSpr
			unVisibleMJ:setVisible(true)
			local addMJPosFix = {
			cc.p(0,20),
			cc.p(-10,0),
			cc.p(0,-30),
			} 
	
			unVisibleMJ:setPosition(cc.pAdd(mjTilePos,addMJPosFix[roomPlayer.displaySeatIdx]) )
		end
	end

end

--TIPS:
--CFGFUNCTION
function PlaySceneCS:showMultiChoice(mjData,msgId)
	local function onListTouch(sender,event)
		if self:getChildByName("sp_huaDongTip") then
	 		self:removeChildByName("sp_huaDongTip")
	 	end	
	end
	local listView = ccui.ListView:create()
	listView:setName("ButtonsList")
	listView:setItemsMargin(2)
	listView:setDirection(ccui.ListViewDirection.horizontal)
	listView:addEventListenerListView(onListTouch)
	self.playMjLayer:addChild(listView,PlaySceneCS.SPPARAMS.MJMAXORDER*10)
	if #mjData >2 then 
		self:createMultiBtnTips()
		listView:setPosition(gt6.winCenter.x * 0.15  ,gt6.winCenter.y*0.3)
		listView:setContentSize(cc.size(gt6.winSize.width*0.92 ,200))
	else
		listView:setPosition(gt6.winCenter.x * 0.5 ,gt6.winCenter.y*0.3)
		listView:setContentSize(cc.size(gt6.winSize.width*0.8 ,200))
	end

	for i = 1, #mjData do 
		local multiChioceData = {}
		multiChioceData.flag = mjData[i].think_type
		multiChioceData.cardList = {}
		local cfgs = g_jueCeId["id_"..mjData[i].think_type]
		local num = cfgs.multiNum or #mjData[i].think_data
		num = tonumber(num)
		for j = 1, num do
			if cfgs.multiSame and cfgs.multiSame == "Same" then  --几张牌都是相同的
				multiChioceData.cardList[j] = {}
				multiChioceData.cardList[j].mjColor  = mjData[i].think_data[1][1] 
				multiChioceData.cardList[j].mjNumber  = mjData[i].think_data[1][2]
			elseif cfgs.multiSame and cfgs.multiSame == "Add" then --根据消息的牌显示
				multiChioceData.cardList[j] = {}
				multiChioceData.cardList[j].mjColor  = mjData[i].think_data[1][1] 
				multiChioceData.cardList[j].mjNumber  = mjData[i].think_data[1][2] + j - 1
			else
				multiChioceData.cardList[j] = {}
				multiChioceData.cardList[j].mjColor  = mjData[i].think_data[j][1] 
				multiChioceData.cardList[j].mjNumber  = mjData[i].think_data[j][2]
			end
		end
		
		--吃单独处理一下
		if mjData[i].think_type == 6 then
			local newTable = {{mjColor = mjData[i].think_data[1][1],mjNumber = mjData[i].think_data[1][2]},
			{mjColor = mjData[i].think_data[3][1],mjNumber = mjData[i].think_data[3][2]},
			{mjColor = mjData[i].think_data[2][1],mjNumber = mjData[i].think_data[2][2]},
		}
			multiChioceData.cardList = newTable
		end
		local choiceBtn = self:createMultiChioceBtns(multiChioceData)
		local function clickChoiceBtn( sender )
		 	self.isPlayerDecision = false
		 	self.isPlayerShow = false
		 	listView:removeFromParent()
			-- 发送消息
			local msgToSend = {}
			msgToSend.m_msgId = msgId
			msgToSend.m_type = multiChioceData.flag
			msgToSend.m_think = {}
			for j = 1, #mjData[i].think_data do 
				table.insert(msgToSend.m_think,{mjData[i].think_data[j][1],mjData[i].think_data[j][2]})
			end

			gt6.socketClient:sendMessage(msgToSend)
		end 
		choiceBtn:setAnchorPoint(0.5,0.5)
		choiceBtn:setPosition(choiceBtn:getContentSize().width/2,choiceBtn:getContentSize().height/2)
		local fixMsgItem = ccui.Widget:create()
		fixMsgItem:setContentSize(choiceBtn:getContentSize().width*1.2,choiceBtn:getContentSize().height*1.2)
		fixMsgItem:addChild(choiceBtn)
		fixMsgItem:setTag(i)
		fixMsgItem:setTouchEnabled(true)
		fixMsgItem:setSwallowTouches(true)
		fixMsgItem:setAnchorPoint(cc.p(0.5,0.5))
		fixMsgItem:addClickEventListener(clickChoiceBtn)
		listView:pushBackCustomItem(fixMsgItem)
	end			
end

--TIPS:
--CFGFunction
function PlaySceneCS:onRcvSyncShowMjTile( msgTbl )
	self.isPlayerDecision = false
	local think_m_type = msgTbl.m_type
	local cfgs = g_playRulesCfg["id_"..think_m_type.."_"..gt6.regionGroup .. "_".. (self.playType+1)] or  g_playRulesCfg["id_"..think_m_type]
	if cfgs and next(cfgs) then 
		print("id_..think_m_type".."id_"..think_m_type)
		dump(cfgs)
		local data = {}
		data.seatIdx = msgTbl.m_pos + 1
		if msgTbl.m_think and next(msgTbl.m_think) then 
			data.mjColor = msgTbl.m_think[1][1]
			data.mjNumber = msgTbl.m_think[1][2]
		end
		data.extra = msgTbl.m_think
		data.msgTbl = msgTbl
		for i, id in ipairs(cfgs.actionId) do
			local action = g_actionId["id_"..id] 
			self:doAction(action.realId,data,action)
		end
	end
end

function PlaySceneCS:buDan( data )
	local msgTbl = data.msgTbl
	local data = {}
	data.extra = {msgTbl.m_think[1]}
	data.seatIdx = msgTbl.m_pos + 1
	self:showBuDan(data)
	self:removeMjTilesFromPlayer(data,{})
end

function PlaySceneCS:showKaiDan( data )
	local msgTbl = data.msgTbl
	local danData = self:copyTab(msgTbl.m_think)
	-- if #danData == 3 then
	-- --如果是4风蛋，那摸取前3个开蛋，第4个显示为补蛋
	-- elseif #danData == 4 then
	-- 	table.remove(danData,4)
	-- 	local data = {}
	-- 	data.extra = {msgTbl.m_think[4]}
	-- 	data.seatIdx = msgTbl.m_pos + 1
	-- 	self:showBuDan(data)
	-- end
	local data = {}
	data.extra = danData
	data.seatIdx = msgTbl.m_pos + 1
	data.spKey = "KAIDAN"
	self:addCPGMJTile(data,{})
	data.extra = msgTbl.m_think
	self:removeMjTilesFromPlayer(data,{})
end

--TIPS:
--CFGFunction
--删除已有的吃/碰／杠牌
function PlaySceneCS:deleteCPGMJTiles( data,action )
	local seatIdx = data.seatIdx
	local mjColor = data.mjColor
	local mjNumber = data.mjNumber
	local roomPlayer = self:getRoomPlayer(seatIdx)
	if not roomPlayer or not next(roomPlayer) then return end
	local mjThinkData = data.extra
	local spKey = action.spKey

	local toBeDeleted = {}
	if spKey == "Peng" then
		toBeDeleted = {{mjColor = mjColor,mjNumber = mjNumber},{mjColor = mjColor,mjNumber = mjNumber},{mjColor = mjColor,mjNumber = mjNumber}}
	elseif spKey == "Chi" then

	elseif spKey == "Gang" then 

	elseif spKey == "F3" then
		toBeDeleted = {{mjColor = mjThinkData[1][1],mjNumber = mjThinkData[1][2]},{mjColor = mjThinkData[2][1],mjNumber = mjThinkData[2][2]},{mjColor = mjThinkData[3][1],mjNumber = mjThinkData[3][2]}}
	end  

	for i, pungData in ipairs(roomPlayer.mjTileCPG) do
		if #pungData == #toBeDeleted then 
			for j = 1, #pungData do 
				local color =  pungData[j].mjColor 
				local number = pungData[j].mjNumber 
				for k = #toBeDeleted,1,-1 do 
					if toBeDeleted[k].mjColor == color and toBeDeleted[k].mjNumber == number then 
						table.remove(toBeDeleted,k)
						break
					end
				end
			end
			if #toBeDeleted == 0 then 
				--移动位置
				local mjTilesReferPos = roomPlayer.mjTilesReferPos   
				for n = i+1 , #roomPlayer.mjTileCPG do 
					local groupNode = roomPlayer.mjTileCPG[n][1].groupNode
					local groupPos = cc.pSub(cc.p(groupNode:getPosition()),pungData[1].groupNode.groupSize)
					groupNode:setPosition(groupPos)
				end
				mjTilesReferPos.groupStartPos = cc.pSub(mjTilesReferPos.groupStartPos, pungData[1].groupNode.groupSize)
				mjTilesReferPos.holdStart = cc.pSub(mjTilesReferPos.holdStart, pungData[1].groupNode.groupSize)
				table.remove(roomPlayer.mjTileCPG, i)
				pungData[1].groupNode:removeFromParent()
				break
			end
		end
	end

end

--TIPS:
--CFGFunction
function PlaySceneCS:deltePrePlayerOutMJ(data,action)
	-- 移除上家打出的牌
	local mjColor = data.mjColor
	local mjNumber = data.mjNumber
	if self.preShowSeatIdx then
		print("deltePrePlayerOutMJ.."..self.preShowSeatIdx)
		
		local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.preShowSeatIdx)
		for i = #roomPlayer.outMjTiles, 1, -1 do
			local outMjTile = roomPlayer.outMjTiles[i]

			print("mjColor--"..tostring(mjColor).."=="..tostring(outMjTile.mjColor))
			print("mjNumber--"..tostring(mjNumber).."=="..tostring(outMjTile.mjNumber))
			if outMjTile.mjColor == mjColor and outMjTile.mjNumber == mjNumber then
				outMjTile.mjTileSpr:removeFromParent()
				table.remove(roomPlayer.outMjTiles, i)
				self:updateOutMjTilesPosition(self.preShowSeatIdx)
				break
			end
		end
		-- 隐藏出牌标识箭头
		self.outMjtileSignNode:setVisible(false)
		if self.outMjtileSignNodeAction then
			self.outMjtileSignNode:stopAction(self.outMjtileSignNodeAction)
		end
	end
end

--TIPS:
--CFGFunction
function PlaySceneCS:doAction(realId,data,action)
	realId = tonumber(realId)
	
	if realId == 1 then  --添加出的牌
		self:addAlreadyOutMjTiles(data,action)
	elseif realId == 2 then  --移除手里的牌
		self:removeMjTilesFromPlayer(data,action)
	elseif realId == 3 then  --吃碰杠
		self:addCPGMJTile(data,action)
	elseif realId == 4 then --播特效
		self:playAciontEffect(data,action)
	elseif realId == 5 then --头像操作
		self:playerHeadAction(data,action)
	elseif realId == 6 then --删除已有的吃/碰／杠牌
		self:deleteCPGMJTiles(data,action)
	elseif realId == 7 then --删除上家的出牌
		self:deltePrePlayerOutMJ(data,action)
	elseif realId == 8 then --胡牌的推倒
		self:showAllMjTilesWhenWin(data,action)
	elseif realId == 10 then --开蛋
		self:showKaiDan(data)
	elseif realId == 11 then --补蛋
		self:buDan(data)
	elseif realId == 12 then --特殊摆在中间的牌
		self:setHuPai(data)
	elseif realId == 13 then
		-- self:FN_PlayDropCardAnimation(data)
	end
end

--TIPS:
--CFGFunction
function PlaySceneCS:playerHeadAction( data,action )
	if not data or not action then return end
	if not next(data) or not next(action) then return end
	local seatIdx = data.seatIdx
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local setPos = roomPlayer.displaySeatIdx
	for i=1,4 do
		local spr_ting = gt6.seekNodeByName(roomPlayer.head, "TING")
		local tingPos = cc.p(spr_ting:getPosition())
		roomPlayer.headFlag = "TING"
		if setPos == i then
			if action.spKey and action.spKey == "NEW" then 
				-- local iconSp = ccui.ImageView:create(action.pic,self:getResType(action))
				-- iconSp:setPosition(cc.pAdd(tingPos,cc.p(0,20)))
				-- iconSp:setName("NEWICON")
				-- roomPlayer.head:addChild(iconSp)
				roomPlayer:addNewIcon(action.pic,self:getResType(action))
			else
				spr_ting:loadTexture(action.pic,self:getResType(action))
				spr_ting:setVisible(true)
			end
		end
	end	
end

--TIPS:
--CFGFunction
--配置表里的资源类型
function PlaySceneCS:getResType(action)
	if action and action.picResType then 
		if action.picResType == "PLIST" then 
			return ccui.TextureResType.plistType
		else
			return ccui.TextureResType.localType
		end

	end
end

--TIPS:
--CFGFunction
function PlaySceneCS:playAciontEffect(data,action)
	local seatIdx = data.seatIdx
	local roomPlayer = self:getRoomPlayer(seatIdx)
	if not roomPlayer or not next(roomPlayer) then return end
	local  mjColor = data.mjColor
	local  mjNumber = data.mjNumber
	local effectName = nil

	--胡特效
	if data.msgTbl and data.msgTbl.m_hu and next(data.msgTbl.m_hu) then 
		if PlaySceneCS.HUTYPE[data.msgTbl.m_hu[1]] then 
			effectName = PlaySceneCS.HUTYPE[data.msgTbl.m_hu[1]]
		end
	end

	effectName = effectName or action.pic

	if effectName then
		local animNode = self:playEffect(effectName, self:getHuPosition(roomPlayer.displaySeatIdx))
		if animNode then
			self.rootNode:addChild(animNode, PlaySceneCS.ZOrder.DECISION_SHOW)
		end
	end
	if action.sound then 
		gt6.soundManager:PlaySpeakSound(roomPlayer.sex, action.sound)
	end
end


function PlaySceneCS:getRoomPlayer( seatIdx )
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	-- if not roomPlayer or not next(roomPlayer) then
	-- 	roomPlayer = self.common_ui_layer.copyRoomPlayerData[seatIdx]
	-- end
	-- if not roomPlayer or not next(roomPlayer) then
	-- 	return {}
	-- end
	return roomPlayer
end

function PlaySceneCS:showBuDan(data)
	gt6.soundEngine:playEffect("common/chipenggang")
	local seatIdx = data.seatIdx 
	local mjColor = data.extra[1][1] or 0
	local mjNumber = data.extra[1][2]  or 0
	local roomPlayer = self:getRoomPlayer(seatIdx)
	
	for k, CPGData in pairs(roomPlayer.mjTileCPG) do 
		if CPGData[1].spKey and CPGData[1].spKey == "KAIDAN" then
			for i = 1 ,#CPGData do 
				if CPGData[i].mjColor == mjColor and CPGData[i].mjNumber == mjNumber then 
					local numText = CPGData[i].spr:getChildByName("NumText")
					if not numText then 
						local numText = gt6.createTTFLabel("X2",24)
						numText:enableOutline(cc.c3b(40,0,0))
						numText:setName("NumText")
						numText.num = 2
						numText:setColor(cc.c3b(255,210,0))
						CPGData[i].spr:addChild(numText)
						local textPos  = cc.p(0,0)
						if roomPlayer.displaySeatIdx == 1 then
							numText:setAnchorPoint(cc.p(1,0.5))
							textPos = cc.p (25,CPGData[i].spr:getContentSize().height/2)
						elseif roomPlayer.displaySeatIdx == 2 then
							numText:setAnchorPoint(cc.p(0.5,1))
							textPos = cc.p (CPGData[i].spr:getContentSize().width/2 - 2 ,80)
						elseif roomPlayer.displaySeatIdx == 3 then
							numText:setAnchorPoint(cc.p(0,0.5))
							textPos = cc.p (CPGData[i].spr:getContentSize().width - 25 ,CPGData[i].spr:getContentSize().height/2)
						elseif 	roomPlayer.displaySeatIdx == 4 then
							numText:setAnchorPoint(cc.p(0.5,1))
							textPos = cc.p (CPGData[i].spr:getContentSize().width/2,25)
						end
						numText:setPosition(textPos)
					else
						numText.num = numText.num +1 
						numText:setString("X"..numText.num)
					end
					return 
				end
			end
		end
	end
	for i,v in pairs(roomPlayer.mjTileBuDanSmall) do
		if v and  tonumber(v.mjColor) == tonumber(mjColor)  and tonumber(v.mjNumber) == tonumber(mjNumber) then
			v.textNum = v.textNum + 1
			v.textLabel:setString("X"..v.textNum)
			return
		end
	end

	local path = "gt6_mini_"
	local mjTileSpr = ccui.ImageView:create(path..mjColor.."_"..mjNumber..".png",ccui.TextureResType.plistType)
	if not mjTileSpr then return end
	local textLabel = gt6.createTTFLabel("X1",20)
	textLabel:enableOutline(cc.c3b(40,0,0))
	textLabel:setPosition(mjTileSpr:getContentSize().width + 10,mjTileSpr:getContentSize().height/2)
	textLabel:setColor(cc.c3b(255,210,0))
	mjTileSpr:addChild(textLabel)
	self.playMjLayer:addChild(mjTileSpr)
	local displaySeatIdx = roomPlayer.displaySeatIdx
	local headNode = gt6.seekNodeByName(self,"HeadNode"..displaySeatIdx)
	local headPos = headNode:getParent():convertToWorldSpace(cc.p(headNode:getPosition()))
	headPos = self.playMjLayer:convertToNodeSpace(headPos)

	local sprPos = cc.p(0,0)
	if roomPlayer.displaySeatIdx == 1 then
		mjTileSpr:setAnchorPoint(cc.p(0.5,0.5))
		sprPos = cc.p(headPos.x -10 ,headPos.y - 80 - #roomPlayer.mjTileBuDanSmall*25)
	elseif roomPlayer.displaySeatIdx == 2 then
		mjTileSpr:setAnchorPoint(cc.p(0.5,0.5))
		sprPos = cc.p(headPos.x + 60 + #roomPlayer.mjTileBuDanSmall*50 ,headPos.y - 50)
	elseif roomPlayer.displaySeatIdx == 3 then
		mjTileSpr:setAnchorPoint(cc.p(0.5,0.5))
		sprPos = cc.p(headPos.x - 10 ,headPos.y - 80 - #roomPlayer.mjTileBuDanSmall*25)
	elseif roomPlayer.displaySeatIdx == 4 then
		sprPos = cc.p(headPos.x + 60 + #roomPlayer.mjTileBuDanSmall*50 ,headPos.y - 50)
	end
	print("is here..")
	mjTileSpr:setPosition(sprPos)
	
	local dataToInsert = {}
	dataToInsert.mjTileSpr = mjTileSpr
	dataToInsert.textLabel = textLabel
	dataToInsert.mjColor = mjColor
	dataToInsert.mjNumber = mjNumber
	dataToInsert.textNum = 1
	table.insert(roomPlayer.mjTileBuDanSmall,dataToInsert)
		
end

--TIPS:
--CFGFunction
function PlaySceneCS:addCPGMJTile(data,action)	
	local num = action.num 
	if num then 
		num = tonumber(num)
	end
	local spKey = action.spKey or false
	local seatIdx = data.seatIdx
	local roomPlayer = self:getRoomPlayer(seatIdx)
	local dataSpKey = data.spKey or nil
	local spExtra = data.spExtra or nil 
	if not roomPlayer or not next(roomPlayer) then return end

	local  mjColor = data.mjColor
	local  mjNumber = data.mjNumber

	local mjTilesReferPos = roomPlayer.mjTilesReferPos   
	-- local groupMjTilesPos = mjTilesReferPos.groupMjTilesPos
	local groupNode = cc.Node:create()
	groupNode:setPosition(mjTilesReferPos.groupStartPos)
	local groupOrder = (gt6.winSize.height + mjTilesReferPos.groupStartPos.x)
	self.playMjLayer:addChild(groupNode,groupOrder)

	--TIPS:
	--如果配置里没有num，则按照消息里的数量操作
	if not num then 
		num = #data.extra
	end

	--数据table
	local CPGData = {}
	for i = 1, num do
		--TIPS:
		--如果配置里没有num，则按照消息里的数量操作
		if not action.num then 
			mjColor = data.extra[i][1]
			mjNumber = data.extra[i][2]
		end
			--吃单独处理一下
		if data.msgTbl and data.msgTbl.m_think and data.msgTbl.m_think[1] and data.msgTbl.m_think[1] == 6 then 
			if i == 2 then 
				mjColor = data.extra[3][1]
				mjNumber = data.extra[3][2]
			elseif i == 3 then 
				mjColor = data.extra[2][1]
				mjNumber = data.extra[2][2]
			end
		end

		local mjTileName = nil 
		if spKey == "Dark" and i ~= num then 
			mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
			spExtra = {mjColor = mjColor , mjNumber = mjNumber}
			dataSpKey = "Dark"
		elseif spKey == "Dark" and i == num then 
			-- if self:isPlayerSeat(seatIdx) then 
			-- 	mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber)
			-- else
			-- 	mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
			-- end
			mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber)
		else
			mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber)
		end

		local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
		local posi = cc.pAdd(mjTilesReferPos.firstCPGCardPos,cc.pMul(mjTilesReferPos.CPGCardSpace,i-1))
		mjTileSpr:setPosition(posi)
		mjTileSpr:setScale(0.8)
		mjTileSpr:setTag(i)

		groupNode:addChild(mjTileSpr)

		if string.find(mjTileName,"tdbgs") then 
			table.insert(CPGData,{spr = mjTileSpr,mjColor = 0,mjNumber = 0 , groupNode = groupNode ,spKey = dataSpKey,extra = spExtra})
		else
			table.insert(CPGData,{spr = mjTileSpr,mjColor = mjColor,mjNumber = mjNumber , groupNode = groupNode ,spKey = dataSpKey,extra = spExtra})
		end

		--TIPS:
		--spKey == "add" 牌的number加1
		if spKey  and spKey == "Add" then 
			mjNumber = mjNumber + 1
			print("mjNumber~~~~.."..mjNumber)
		end

		--TIPS:
		--DISPLAY FIX 
		-- zorder
		if roomPlayer.displaySeatIdx == 4 or  roomPlayer.displaySeatIdx == 1 then
			mjTileSpr:setLocalZOrder(-i)
		end

		--目前先这样判定 4的时候落起来
		if i == 4 then 
			local temp_str = groupNode:getChildByTag(2)
			if temp_str then
				local temp_x = temp_str:getPositionX()
				local temp_y = temp_str:getPositionY() + 7
				mjTileSpr:setPosition(cc.p(temp_x,temp_y))
				mjTileSpr:setLocalZOrder(1)
			end
		end

	end

	table.insert(roomPlayer.mjTileCPG,CPGData)
	print("mjTileCPG~~~~")
	dump(roomPlayer.mjTileCPG)

	local spaceTable = {
		1.2,
		1.1,
		1.1,
		1.1
	}
	local spaceNum = spaceTable[roomPlayer.displaySeatIdx]
	local cellNum = #CPGData

	--长度超过4按宽度3处理 因为会落起来 以后会加入配置
	if cellNum >= 4 then
		cellNum = 3 
	end 
	local groupSize = cc.p(spaceNum*cellNum*mjTilesReferPos.CPGCardSpace.x,spaceNum*cellNum*mjTilesReferPos.CPGCardSpace.y)
	groupNode.groupSize = groupSize
	mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos, groupSize)
	mjTilesReferPos.holdStart = cc.pAdd(mjTilesReferPos.holdStart, groupSize)

	--录像位置修正
	mjTilesReferPos.holdStart = cc.pAdd(mjTilesReferPos.holdStart,self.m_FIXPUNGPOS[roomPlayer.displaySeatIdx])
	if self:isPlayerSeat(seatIdx) then
		self:sortPlayerMjTiles()
	else
		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		local mjTilePos = mjTilesReferPos.holdStart
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			mjTile.mjTileSpr:setPosition(mjTilePos)
			self.playMjLayer:reorderChild(mjTile.mjTileSpr, gt6.winSize.height - mjTilePos.y)
			mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
		end
	end
end

--TIPS:
--CFGFunction
function PlaySceneCS:removeMjTilesFromPlayer( data,action )
	local seatIdx = data.seatIdx
	local spKey = action.spKey
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local  mjColor = data.mjColor
	local  mjNumber = data.mjNumber
	print("removeMjTilesFromPlayer")
	dump(action)
	local num = action.num
	
	--TIPS:
	--如果配置里没有num，则按照消息里的数量操作
	if not num then 
		num = #data.extra
	end

	--删除消息数据的前n张
	if spKey and string.find(spKey,"F") then 
		num = string.sub(spKey,-1,-1)
	end

	--删除消息数据后n张
	if spKey and string.find(spKey,"L") then 
		num = string.sub(spKey,-1,-1)
		data.extra = Utils6.reverseTable(data.extra)
	end
	for i = 1 , num do
		if self:isPlayerSeat(seatIdx) then
			if not action.num then 
				mjColor = data.extra[i][1]
				mjNumber = data.extra[i][2]
			end
			-- 玩家持有牌中去除打出去的牌
			for i = #roomPlayer.holdMjTiles, 1, -1 do
				local mjTile = roomPlayer.holdMjTiles[i]
				if mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
					mjTile.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.holdMjTiles, i)
					break
				end
			end

			--TIPS:
			--spKey == "add" 牌的number加1
			if spKey  and spKey == "Add" then 
				mjNumber = mjNumber + 1
			end
			self:sortPlayerMjTiles()
		else
			if roomPlayer ~= nil 
			and roomPlayer.mjTilesRemainCount ~= nil
			and roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount] ~= nil
			and roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount].mjTileSpr then
				roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount].mjTileSpr:setVisible(false)
				roomPlayer.mjTilesRemainCount = roomPlayer.mjTilesRemainCount - 1
			end
		end
	end
end


--托管
function PlaySceneCS:onTuoGuan()
	if self.playMjLayer:getChildByName("btnLayer") then 
		self.playMjLayer:getChildByName("btnLayer"):removeFromParent()
	end

	if self.playMjLayer:getChildByName("ButtonsList") then 
		self.playMjLayer:getChildByName("ButtonsList"):removeFromParent()
	end
	self.isPlayerShow = false
	self.isPlayerDecision = false
	if self.huTipLayout and not tolua.isnull(self.huTipLayout) then
		self.huTipLayout:setVisible(false)
	end

	gt6.PlayersManager:maskHoldCard(self.playerSeatIdx)
end


--取消托管
function PlaySceneCS:onQuXiaoTuoGuan()
	self.isTouch = true 
	gt6.PlayersManager:hidMaskHoldCard(self.playerSeatIdx)
	self:sortPlayerMjTiles()
end

--TIPS:
--CFGFunction
--别人打牌，自己决策
function PlaySceneCS:onRcvMakeDecision( msgTbl )
	if msgTbl.m_flag ~= 1 then return end 

	self.isPlayerDecision = true
	self:playTimeCDStart(msgTbl.m_time)
	local thinkData =  self:checkThinkDuplicate(msgTbl.m_think)
	print("thinkData in makeDecision...")
	dump(thinkData)
	if not thinkData or not next(thinkData) then return end 
	thinkData.msgId = gt6.GC_MAKE_DECISION
	thinkData.msgIdToSend = gt6.CG_PLAYER_DECISION
	thinkData.mjColor = msgTbl.m_color
	thinkData.mjNumber = msgTbl.m_number
	
	self:createNewBtns(thinkData)
end

--TIPS:
--CFGFunction
function PlaySceneCS:addMjToPlayer(roomPlayer,msgTbl)
	print("----> PlayScene_MJ.lua addMjToPlayer ......")
	dump(roomPlayer,"----> roomPlayer : ")
	if msgTbl.m_color == 0 or msgTbl.m_number == 0 then return end 
	-- 添加牌放在末尾
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, #roomPlayer.holdMjTiles))
	mjTilePos = cc.pAdd(mjTilePos, cc.p(26, 0))
	--3号位位置修正
	if roomPlayer.displaySeatIdx == 3 then
		mjTilePos = cc.pAdd(mjTilePos,cc.p(-10,0))
	end
	local mjTile = self:addMjTileToPlayer(msgTbl.m_color, msgTbl.m_number)
	mjTile.mjTileSpr:setPosition(mjTilePos)
	self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt6.winSize.height - mjTilePos.y)+PlaySceneCS.SPPARAMS.MJMAXORDER)
	mjTile.mjTileSpr:setOpacity(0.0)
	local action = cc.FadeIn:create(0.3)
	mjTile.mjTileSpr:runAction(action)

	if self.isOpeningAim then
		mjTile.mjTileSpr:setVisible(false)
		table.insert(self.toBeShow,mjTile.mjTileSpr)
	end
end

--TIPS:
--CFGFunction
function PlaySceneCS:onRcvSyncMakeDecision( msgTbl )
	if msgTbl.m_errorCode ~= 0 then
		return
	end
	self.isPlayerDecision = false
	if self.playMjLayer:getChildByName("btnLayer") then 
		self.playMjLayer:getChildByName("btnLayer"):removeFromParent()
	end
	if self.playMjLayer:getChildByName("ButtonsList") then 
		self.playMjLayer:getChildByName("ButtonsList"):removeFromParent()
	end
	local think_m_type = msgTbl.m_think[1]
	local cfgs = g_playRulesCfg["id_"..think_m_type.."_M"] or  g_playRulesCfg["id_"..think_m_type]


	if cfgs and next(cfgs) then 
		print("id_..think_m_type".."id_"..think_m_type)
		dump(cfgs)
		local data = {}
		data.seatIdx = msgTbl.m_pos + 1
		data.mjColor = msgTbl.m_color
		data.mjNumber = msgTbl.m_number
		data.extra = msgTbl.m_think[2]
		data.msgTbl = msgTbl
		for i, id in ipairs(cfgs.actionId) do
			local action =  g_actionId["id_"..id] 
			self:doAction(action.realId,data,action)
		end
	end
end

--TIPS:
--CFGFunction
function PlaySceneCS:createNewBtns(thinkData)
	print("createNewBtns..")
	dump(thinkData)
	if self.mIsInTrusteeship then
		return
	end
	local msgId = thinkData.msgId
	if thinkData and next(thinkData) then
		--if msgId == gt6.GC_TURN_SHOW_MJTILE then 
			self.isPlayerDecision = true
		-- elseif msgId == gt6.GC_MAKE_DECISION then 
		-- 	self.isPlayerDecision = true
		-- end
		
		--新建按钮层
		local btnLayer = cc.Layer:create()
		btnLayer:setSwallowsTouches(true)
		btnLayer:setName("btnLayer")
		self.playMjLayer:addChild(btnLayer, PlaySceneCS.SPPARAMS.MJMAXORDER*10)
		btnLayer:setContentSize(gt6.winSize)

		if self.isOpeningAim then
			btnLayer:setVisible(false)
			table.insert(self.toBeShow,btnLayer)
		end

		local passBtnShow = true
		if self.m_mustHu then 
			for key , value in ipairs(thinkData) do
				if value and value.mjData then
					for _, mjData in pairs(value.mjData) do 
						if mjData.think_type == 2 then 
							passBtnShow = false
						end
					end
				end
			end
		end
		local btnNode = gt6.seekNodeByName(self.rootNode, "Node_DecisionBtnPos")
		local beginPos = cc.p(btnNode:getPosition())
		--pass
		local passPic = "gt6_bt_guo.png"
		local passBtn = ccui.Button:create(passPic,passPic,passPic,ccui.TextureResType.plistType)
		passBtn:setPosition(beginPos)
		passBtn:setVisible(passBtnShow)
		gt6.addBtnPressedListener(passBtn,function(sender)
			local function passDecision( ... )
				btnLayer:removeFromParent()
				if msgId == gt6.GC_TURN_SHOW_MJTILE then 
					self.isPlayerDecision = false
					self:checkGuoAutoPlay()
				elseif msgId == gt6.GC_MAKE_DECISION then 
					self.isPlayerDecision = false
					local msgToSend = {}
					msgToSend.m_msgId = gt6.CG_PLAYER_DECISION
					msgToSend.m_type = decisionType
					msgToSend.m_think = {}
					gt6.socketClient:sendMessage(msgToSend)
				end
			end
			--过胡提示
			if self.m_showGuoHuTips then
				local canHu = false
				for key , value in ipairs(thinkData) do
					if value and value.mjData then
						for _, mjData in pairs(value.mjData) do 
							if mjData.think_type == 2 then 
								canHu = true
							end
						end
					end
				end

				if canHu then
					require("app/public/base/NoticeTips"):create(gt6.getLocationString("LTKey_0007"),
									gt6.getLocationString("LTKey_0043"), passDecision)
				else
					passDecision()
				end
			else
				passDecision()
			end
		end)
		btnLayer:addChild(passBtn)

		local btnSpace = passBtn:getContentSize().width * 2 
		local newLineIndex = 1
		for index ,think in ipairs(thinkData) do 
			local picPath = nil 
			local picResType = ccui.TextureResType.plistType
			if think.picResType == "PLIST" then 
			 	picPath = think.pic
			else
				picPath = PlaySceneCS.PicPath..think.pic
				picResType = ccui.TextureResType.localType
			end
			local newBtn = ccui.Button:create(picPath,picPath,picPath,picResType)

			if beginPos.x - btnSpace*index <= gt6.winSize.width*0.2 then 
				beginPos.y = beginPos.y + passBtn:getContentSize().height + 30
				newBtn:setPosition(beginPos.x - btnSpace*newLineIndex,beginPos.y)
				newLineIndex = newLineIndex + 1
			else
				newBtn:setPosition(beginPos.x - btnSpace*index,beginPos.y)
			end
			btnLayer:addChild(newBtn)

			local function createMJTileSp( mjColor,mjNumber,newBtn )
				local mjTileName = self:getMJTileResName( 4, mjColor, mjNumber)
				local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
				mjTileSpr:setAnchorPoint(cc.p(0,0.5))
				newBtn:addChild(mjTileSpr)
				mjTileSpr:setPosition(newBtn:getContentSize().width - 30,newBtn:getContentSize().height/2)
			end
			if msgId == gt6.GC_MAKE_DECISION and thinkData.mjColor and thinkData.mjNumber and thinkData.mjColor ~= 0 and thinkData.mjNumber ~= 0 then 
				createMJTileSp(thinkData.mjColor,thinkData.mjNumber,newBtn)
			end

			if #think.mjData == 1 then 
				if msgId == gt6.GC_TURN_SHOW_MJTILE then 
					if think.mjData[1].think_data and next(think.mjData[1].think_data) then 
						createMJTileSp(think.mjData[1].think_data[1][1],think.mjData[1].think_data[1][2],newBtn)
					end
				end
				gt6.addBtnPressedListener(newBtn,function (sender)
					self.isPlayerDecision = false
					self.isPlayerShow = false
					btnLayer:removeFromParent()
					local msgToSend = {}
					msgToSend.m_msgId = think.msgIdToSend or thinkData.msgIdToSend
					msgToSend.m_type = think.mjData[1].think_type
					msgToSend.m_think = think.mjData[1].think_data
					gt6.socketClient:sendMessage(msgToSend)
				end)
			else
				gt6.addBtnPressedListener(newBtn,function (sender)
					btnLayer:removeFromParent()
					self:showMultiChoice(think.mjData,thinkData.msgIdToSend)
				end)
			end
		end
	end 
end

--TIPS:
--CFGFunction
function PlaySceneCS:addAlreadyOutMjTiles(data,action)
	print("addAlreadyOutMjTiles...")
	dump(data,"---> PlayScene_MJ.lua addAlreadyOutMjTiles : data = ")
	dump(action,"---> PlayScene_MJ.lua addAlreadyOutMjTiles : action = ")
	-- 添加到已出牌列表
	local seatIdx = data.seatIdx
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	if not roomPlayer then
		return false
	end
	-- 记录出牌的上家
	self.preShowSeatIdx = seatIdx
	local  mjColor = data.mjColor
	local  mjNumber = data.mjNumber
	local mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber)
	local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	table.insert(roomPlayer.outMjTiles, mjTile)
	if not data.isReconnect then 
		gt6.soundManager:PlayCardSound(roomPlayer.sex, mjColor, mjNumber)
	end
	-- 玩家已出牌缩小
	if self.playerSeatIdx == seatIdx then
		mjTileSpr:setScale(0.66)
	end

	-- 显示已出牌
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	--local mjTilePos = mjTilesReferPos.outStart
	--计算打出麻将的位置
	local mjTilePos,layer = self:countOutMjPoint(roomPlayer,mjTilesReferPos)

	mjTileSpr:setPosition(mjTilePos)
	
	-- zroder
	local zOrder = self:countOutMjZorder(roomPlayer.displaySeatIdx,mjTilePos,layer) 
	self.playOutMjLayer:addChild(mjTileSpr,zOrder)
	self:showOutMjtileSign(seatIdx)
	return mjTileSpr
end

--TIPS:
--CFGFunction
function PlaySceneCS:showOutMjtileSign(seatIdx)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	local endIdx = #roomPlayer.outMjTiles
	local outMjTile = roomPlayer.outMjTiles[endIdx]
	print("self.outMjtileSignNode..")
	self.outMjtileSignNode:setVisible(true)
	self.outMjtileSignNode:setPosition(outMjTile.mjTileSpr:getParent():convertToWorldSpace(cc.p(outMjTile.mjTileSpr:getPosition())))
	self.outMjtileSignNodeAction = cc.RepeatForever:create(
		cc.Sequence:create(
			cc.CallFunc:create(function()
				self.outMjtileSignNode:setOpacity(255)
			end),
			cc.FadeTo:create(0.5, 180),
			cc.FadeTo:create(0.5, 255)
		)
	)
	self.outMjtileSignNode:runAction(self.outMjtileSignNodeAction)
end

--TIPS:
--CFGFunction
function PlaySceneCS:showAllMjTilesWhenWin(data)
	if not data.msgTbl or not next(data.msgTbl) then return end 
	local hu_ani_list = {}
	local seatIdx = data.seatIdx
	local m_cardCount = data.msgTbl.m_cardCount
	local m_cardValue = data.msgTbl.m_cardValue
	local m_color  = data.mjColor
	local m_number = data.mjNumber
	if data.msgTbl.m_dianPaoPos and data.msgTbl.m_dianPaoPos >= 0 then 
		print("self.preShowSeatIdx.."..(data.msgTbl.m_dianPaoPos+1))
		print("seatIdx.."..seatIdx )


		local player = gt6.PlayersManager:getRoomPlayersBySeat(data.msgTbl.m_dianPaoPos+1)
		-- if gt6.hasRoomPlayerBeRemoved then
		-- 	player = self.infoForReport[(data.msgTbl.m_dianPaoPos+1)]
		-- end
		-- if not player or not next(player) then
		-- 	player = self.common_ui_layer.copyRoomPlayerData[(data.msgTbl.m_dianPaoPos +1)]
		-- end
		if not player or not next(player) then return end 
		local dianPaoPos=self:getHuPosition(player.displaySeatIdx)
		local dianPaoNode = self:playEffect("dianpao",dianPaoPos)
		self.rootNode:addChild(dianPaoNode,PlaySceneCS.ZOrder.DECISION_NEW)

		
		local hu_pos = self:getHuCardPosition(player.outMjTiles,m_color,m_number)
		if hu_pos then 
			-- local ani_type = PlaySceneCS.HU_ANI_TYPE.FLY
			-- local anim_data = self:createHuAnim(player.displaySeatIdx,m_color,m_number,0,nil,hu_pos,ani_type)
			-- table.insert(hu_ani_list,anim_data)
		end 
		
	end

	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(seatIdx)
	-- if not roomPlayer or not next(roomPlayer) then
	-- 	roomPlayer = self.infoForReport[seatIdx]
	-- end
	-- if not roomPlayer or not next(roomPlayer) then
	-- 	roomPlayer = self.common_ui_layer.copyRoomPlayerData[seatIdx]
	-- end
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	
	--local groupNode = cc.Node:create()

	-- --位置修正
	-- if roomPlayer.displaySeatIdx == 1 then
	-- 	mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos,cc.p(0,-20))
	-- elseif roomPlayer.displaySeatIdx == 3 then
	-- 	mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos,cc.p(0,-20))
	-- end

	-- groupNode:setPosition(mjTilesReferPos.groupStartPos)
	-- self.playMjLayer:addChild(groupNode)
	local finalList = {}
	for i, mjTile in ipairs(m_cardValue) do
		table.insert(finalList, mjTile)
	end

	-- 所有手牌
	local setPos = mjTilesReferPos.holdStart
	local scale = 1

	for i,mjTile in ipairs(finalList) do
		--胡牌zorder
		local zOrder = 0 
		if roomPlayer.displaySeatIdx == 1 then
			zOrder = -setPos.y
			scale = 0.8
		elseif roomPlayer.displaySeatIdx == 2 then
	 		zOrder = -setPos.x
	 		scale = 0.8
		elseif roomPlayer.displaySeatIdx == 3 then
			zOrder = -setPos.y
			scale = 0.8
		elseif roomPlayer.displaySeatIdx == 4 then
			zOrder = -setPos.x
		end

		local mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, mjTile[1], mjTile[2])
		local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
		 self.playMjLayer:addChild(mjTileSpr, zOrder)

		-- 自己推倒牌时,牌放大
		if self:isPlayerSeat(seatIdx) then
			local scalePos = cc.p(roomPlayer.mjTilesReferPos.m_huSpace.x * 1.3, roomPlayer.mjTilesReferPos.m_huSpace.y)
			mjTileSpr:setScale(scale)
			mjTileSpr:setPosition(cc.p(setPos.x + 20, setPos.y ))
			setPos = cc.pAdd(setPos, scalePos)
		else
			mjTileSpr:setScale(scale)
			mjTileSpr:setPosition(setPos)
			setPos = cc.pAdd(setPos, roomPlayer.mjTilesReferPos.m_huSpace)
		end
	end

	local cards = {}
	if m_color and m_color ~= 0 and m_number and m_number ~= 0 then
		table.insert(cards, {m_color, m_number})
	end

	local offsetPos = cc.p(0, 0)
	if roomPlayer.displaySeatIdx == 1 then
		offsetPos = cc.p(0, 35)
	elseif roomPlayer.displaySeatIdx == 2 then
		offsetPos = cc.p(-10, 0)
	elseif roomPlayer.displaySeatIdx == 3 then
		offsetPos = cc.p(0, -35)
	elseif roomPlayer.displaySeatIdx == 4 then
		offsetPos = cc.p(15, 0)
	end
	if seatIdx == self.playerSeatIdx then
		offsetPos = cc.p(35, 0)
	end
	setPos = cc.pAdd(setPos, offsetPos)

	local index = 0
	for k, v in pairs(cards) do
		if v[1] > 0 and v[1] < 5 then
			local mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, v[1], v[2])
			local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
			mjTileSpr:setScale(scale)
			local offsetSize = cc.p(0, 0)
			if roomPlayer.displaySeatIdx == 1 then
				offsetSize.y = mjTileSpr:getContentSize().height * mjTileSpr:getScaleY()
			elseif roomPlayer.displaySeatIdx == 2 then
				offsetSize.x = -mjTileSpr:getContentSize().width * mjTileSpr:getScaleX()
			elseif roomPlayer.displaySeatIdx == 3 then
				offsetSize.y = -mjTileSpr:getContentSize().height * mjTileSpr:getScaleY()
			elseif roomPlayer.displaySeatIdx == 4 then
				offsetSize.x = mjTileSpr:getContentSize().width * mjTileSpr:getScaleX()
			end
			setPos = cc.pAdd(setPos, cc.p(offsetSize.x*index,offsetSize.y*index))
			mjTileSpr:setPosition(setPos)
			self.playMjLayer:addChild(mjTileSpr, -setPos.x)
			index = index + 1

			local ani_type = PlaySceneCS.HU_ANI_TYPE.FALL
			local anim_data = self:createHuAnim(roomPlayer.displaySeatIdx,v[1],v[2],0,nil,setPos,ani_type)
			table.insert(hu_ani_list,anim_data)
		end
	end

	self:playHuAnim(hu_ani_list)
	hu_ani_list = {}

	-- 更新持有牌显示位置
	for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
		mjTile.mjTileSpr:removeFromParent()
	end
end

--显示所有手牌
function PlaySceneCS:showAllHoldCard(msgTbl)
	local total_num = gt6.totalPlayerNum
	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	for i = 1, total_num do
		local roomPlayer = room_players[i]
		print("self.playerSeatIdx=="..tostring(self.playerSeatIdx))
		if roomPlayer and i ~= self.playerSeatIdx then
			local mjTilesReferPos = roomPlayer.mjTilesReferPos
			
			-- 所有手牌
			local setPos = mjTilesReferPos.holdStart
			local scale = 1

			--显示手牌的数组
			local hold_array = msgTbl["array"..tostring(i-1)]
			if hold_array then
				print("==roomPlayer---"..tostring(roomPlayer.displaySeatIdx))
				for i,mjTile in ipairs(hold_array) do
					--胡牌zorder
					local zOrder = 0 
					if roomPlayer.displaySeatIdx == 1 then
						zOrder = -setPos.y
						scale = 0.8
					elseif roomPlayer.displaySeatIdx == 2 then
				 		zOrder = -setPos.x
				 		scale = 0.8
					elseif roomPlayer.displaySeatIdx == 3 then
						zOrder = -setPos.y
						scale = 0.8
					elseif roomPlayer.displaySeatIdx == 4 then
						zOrder = -setPos.x
					end

					local mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, mjTile[1], mjTile[2])
					local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
					self.playMjLayer:addChild(mjTileSpr, zOrder)

					-- 自己推倒牌时,牌放大
					mjTileSpr:setScale(scale)
					mjTileSpr:setPosition(setPos)
					setPos = cc.pAdd(setPos, roomPlayer.mjTilesReferPos.m_huSpace)
				end

				-- 更新持有牌显示位置
				for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
					if mjTile.mjTileSpr and not tolua.isnull(mjTile.mjTileSpr) then
						mjTile.mjTileSpr:removeFromParent()
					end
				end  
			end 
		end
	end
end

--一张特殊牌展示的不记录展示
function PlaySceneCS:onRcvShowASPCard(msgTbl)
	local mjColor = msgTbl.m_card[1]
	local mjNumber = msgTbl.m_card[2]
	if mjColor ~= 0 and mjNumber ~= 0 then
		local csbNode = nil
		local action = nil
		local actionName = nil
		csbNode, action = gt6.createCSAnimation(PlaySceneCS.animPath.."jiebao.csb")
		actionName = "jiebao"
		local mjTileSpr = gt6.seekNodeByName(csbNode,"majiangpai")
		self:setSpriteFrame(self:getMJTileResName(4, mjColor, mjNumber, false),mjTileSpr)
		local pos = self:getHuPosition(self:getDisplaySeat(msgTbl.m_pos+1))
		csbNode:setPosition(pos)
		self:addChild(csbNode,PlaySceneCS.ZOrder.MJTILES)
		action:play(actionName, false)
		action:setFrameEventCallFunc(function(frame)
			csbNode:removeFromParent()
		end) 

	end
end


--特殊牌在中间摆放的位置
function PlaySceneCS:getHuPaiPos(data)
	local roomPlayer = self:getRoomPlayer(data.seatIdx)
	if roomPlayer.linedMJPos then return end 
	--背景框的大小
	local kuangSize = {
	cc.size(70,215),
	cc.size(250,70),
	cc.size(70,215),
	cc.size(260,70)
	}
	--第一个麻将在框里的位置
	local nodePos = {
	cc.p(35,7),
	cc.p(-2,35),
	cc.p(35,205),
	cc.p(-4,35),
	} 

	local playNode = gt6.seekNodeByName(self.rootNode, "Node_play")
	local mjTilesOutReferNode = gt6.seekNodeByName(playNode,"Node_playerOutMjTiles_"..roomPlayer.displaySeatIdx)
	local huPaiBg = gt6.seekNodeByName(mjTilesOutReferNode,"Image_HuBg")
	local spKuangPos = gt6.getRealWordPosition(huPaiBg)

	local spKuang = ccui.ImageView:create(self.PicPath.."gt6_bpkuang.png")
	spKuang:setScale9Enabled(true)
	spKuang:setCapInsets(cc.rect(15,15,10,10))
	spKuang:setAnchorPoint(cc.p(0.5,0.5))
	spKuang:setPosition(spKuangPos)
	self.playMjLayer:addChild(spKuang)
	spKuang:setContentSize(kuangSize[roomPlayer.displaySeatIdx])

	local nodeHuPai = cc.Node:create()
	spKuang:addChild(nodeHuPai)
	nodeHuPai:setPosition(nodePos[roomPlayer.displaySeatIdx])
	local linedMJPos = gt6.getRealWordPosition(nodeHuPai)
	roomPlayer.linedMJPos = linedMJPos
	 
end


--特殊牌在中间摆放
function PlaySceneCS:setHuPai(dataTable)
	local data = {}
	data.seatIdx = dataTable.seatIdx
	data.huTable = {{dataTable.mjColor,dataTable.mjNumber}}

	self:getHuPaiPos(data)
	local mjTileSpace = {
	cc.p(0,30),
	cc.p(38,0),
	cc.p(0,-30),
	cc.p(40,0),
	}

	local mjTileScale = {
	0.8,
	0.8,
	0.8,
	0.55
	}

	local mjTileAnchor = {
	cc.p(0.5,0),
	cc.p(0,0.5),
	cc.p(0.5,1),
	cc.p(0,0.5)
	}



	local roomPlayer = self:getRoomPlayer(data.seatIdx)
	local huTable = data.huTable
	local lineMjNum = 6 
	local lineIndex = roomPlayer.lineIndex  or 0 
	local upValue = cc.p(0,10)
	for i = 1, #huTable do 
		local mjTileAll = i + #roomPlayer.linedMjTile
		if (mjTileAll-1)%lineMjNum == 0 then
			lineIndex = lineIndex + 1
			roomPlayer.lineIndex = lineIndex
		end
		local mjTileName = self:getMJTileResName(roomPlayer.displaySeatIdx, huTable[i][1], huTable[i][2])
		local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
		mjTileSpr:setScale(mjTileScale[roomPlayer.displaySeatIdx])
		mjTileSpr:setAnchorPoint(mjTileAnchor[roomPlayer.displaySeatIdx])
		if roomPlayer.displaySeatIdx == 3 then 

		else
			mjTileSpr:setLocalZOrder((lineMjNum - mjTileAll + (lineIndex-1)*100))
		end

		self.playMjLayer:addChild(mjTileSpr)

		local upPos = cc.pMul(upValue,lineIndex-1)
		upPos = cc.pAdd(roomPlayer.linedMJPos,upPos)
		mjTileSpr.pos = cc.pAdd(upPos,cc.pMul(mjTileSpace[roomPlayer.displaySeatIdx], (mjTileAll-1)%lineMjNum))
		mjTileSpr:setPosition(mjTileSpr.pos)
	end

	for k , v in ipairs(huTable) do 
		table.insert(roomPlayer.linedMjTile,v)
		print("all linedMjTile cards..")
		dump(roomPlayer.linedMjTile)
	end
	if data.seatIdx == self.playerSeatIdx and not data.isReplay then
		self:sortPlayerMjTiles()
	end
end

-- function PlaySceneCS:showTrusteeship(seat_idx)
-- 	-- 显示托管机器人
-- 	if seat_idx == self.currentPlayerDisplaySeat then return end 
-- 	local trusteeshipNode = self.rootNode:getChildByName("Node_trusteeship_"..seat_idx)
-- 	if trusteeshipNode == nil then
-- 		local play_titles = gt6.seekNodeByName(self,"Node_playerMjTiles_"..seat_idx) 
-- 		local trusteeshipNode = gt6.seekNodeByName(self,"Node_trusteeshipmj_"..seat_idx)
-- 		local parent = trusteeshipNode:getParent()
-- 		local trusteeshipPosition = parent:convertToWorldSpace(cc.p(trusteeshipNode:getPosition()))

-- 		local trusteeshipAnimateNode, trusteeshipAnimate = gt6.createCSAnimation("gameType/base/animation/tuoguanzhong.csb")
-- 		trusteeshipAnimateNode:setPosition(trusteeshipPosition)
-- 		trusteeshipAnimateNode:setName("Node_trusteeship_"..seat_idx)
-- 		self.rootNode:addChild(trusteeshipAnimateNode)
-- 		trusteeshipAnimate:play("tuoguanzhong",true)
-- 	end
-- end

function PlaySceneCS:shuffle(t)
    if type(t)~="table" then
        return
    end
    local l=#t
    local tab={}
    local index=1
    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end

--创建胡牌效果
--displaySeatIdx, ui座位号
--color, 花色
--num,  值
--isBig, 不太清楚
--isChuPai, --是否是出的牌(但貌似只有自己有)
--point, --坐标
--ani_type --胡牌效果类型 1飞起效果 2落下效果
function PlaySceneCS:createHuAnim(displaySeatIdx, color, num, isBig,isChuPai,point,ani_type)
	local ani_name = string.format("RL_hupai_%d_fx.csb",ani_type) --"RL_hupai_1_fx.csb"
	local play_name = string.format("RL_hupai_%d_fx",ani_type)
	if displaySeatIdx == 2 or  displaySeatIdx == 4 then 
		ani_name = string.format("FB_hupai_%d_fx.csb",ani_type)
		play_name = string.format("FB_hupai_%d_fx",ani_type)
	end

	local mjTileSpr = self:createPaiMian(displaySeatIdx, color, num, isBig,isChuPai)
	local decisionSignSpr, action = gt6.createCSAnimation(PlaySceneCS.animPath .. ani_name)
	--action:setTimeSpeed(0.7)
	local pb2_p4s_1  = decisionSignSpr:getChildByName("pb2_p4s_1")
	pb2_p4s_1:addChild(mjTileSpr)
	--action:play(play_name, false)
	decisionSignSpr:setPosition(point)
	decisionSignSpr:setLocalZOrder(100)
	mjTileSpr:setPosition(cc.p(pb2_p4s_1:getContentSize().width/2,pb2_p4s_1:getContentSize().height/2))
	self.playMjLayer:addChild(decisionSignSpr)

	if displaySeatIdx == 2 then
		mjTileSpr:setScale(1.4)
	end

	if displaySeatIdx == 4 then 
		if ani_type == 2 then
			decisionSignSpr:setScale(1.5)
		end 
	end
	--mjTileSpr:setPosition(cc.p(mjTileSpr:getPositionX(),mjTileSpr:getPositionY() - 20))

	local hu_anim_data = {}
	hu_anim_data.spr = decisionSignSpr
	hu_anim_data.action = action
	hu_anim_data.play_name = play_name

	return hu_anim_data

end

function PlaySceneCS:playHuAnim(ani_list)
	local delay_time = 0
	for _,value in pairs(ani_list) do 
		local action = value.action
		local decisionSignSpr  = value.spr
		action:play(value.play_name, false)

		delay_time = delay_time + action:getEndFrame()/60
		print("--delay_time---"..tostring(delay_time))

		local delayTime = cc.DelayTime:create(delay_time)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:removeFromParent()
			local hu_sprite = value.hu_sprite
			if hu_sprite and not tolua.isnull(hu_sprite) then 
				hu_sprite:setVisible(true)
			end
		end)


		local seqAction = cc.Sequence:create(delayTime, callFunc)
		decisionSignSpr:runAction(seqAction)
	end
end

function PlaySceneCS:createKaiPaiAnim(i,mjTile)
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	local mjTileSpr = roomPlayer.holdMjTiles[i].mjTileSpr
	local decisionSignSpr, action = gt6.createCSAnimation(PlaySceneCS.animPath .. "mjkaipai_2.csb")
	decisionSignSpr:setName(PlaySceneCS.NODE_NAME.SEND_CARD_ANI_NAME)
	local cardColorPic = gt6.seekNodeByName(decisionSignSpr,"Sprite_3")

	local mjTileName = self:getMJTileResName( 4, mjTile[1], mjTile[2], 1)
	mjTileName = self:getRealMJTileResName(mjTileName)
	mjTileName = gt6.getExternMjTileName(self.paimianNum, mjTileName)
	cardColorPic:setSpriteFrame(mjTileName)
	action:play("mjkaipai_2", false)

	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart

	decisionSignSpr:setPosition(mjTileSpr:getPositionX(),mjTilePos.y)
	local delayTime = cc.DelayTime:create(action:getEndFrame() / 60)
	local index = math.ceil(i/4)
	local maxIndex = math.ceil(#roomPlayer.holdMjTiles/4) or 4
	delayTime = cc.DelayTime:create(2 - (index-1)*self.SPPARAMS.KAIPAIDELAY)
	local callFunc = cc.CallFunc:create(function(sender)
		sender:removeFromParent()
		if index == maxIndex then
			xpcall(function( )
				self:createSceondKaiPaiAnim()
			end,function( )
				self:boardStartAfter()
			end)
		end
	end)
	local seqAction = cc.Sequence:create(delayTime, callFunc)
	decisionSignSpr:runAction(seqAction)
	self.playMjLayer:addChild(decisionSignSpr,self.SPPARAMS.MJMAXORDER*100)
end

function PlaySceneCS:createFirstKaiPaiAnim()
	for i,v in ipairs(self.randomColor) do
		local index = math.ceil(i/4)
		performWithDelay(self,function ()
			xpcall(function()
				self:createKaiPaiAnim(i,v)
			end,function( )
				self:boardStartAfter()
			end)
			
		end,(index - 1)*self.SPPARAMS.KAIPAIDELAY)
	end
end


function PlaySceneCS:createSceondKaiPaiAnim()
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	for i,v in ipairs(self.randomColor) do
		local mjTileSpr = roomPlayer.holdMjTiles[i].mjTileSpr
		local decisionSignSpr, action = gt6.createCSAnimation(PlaySceneCS.animPath .. "mjkaipai_1.csb")
		decisionSignSpr:setTag(i)
		decisionSignSpr:setName(PlaySceneCS.NODE_NAME.SEND_CARD_ANI_NAME)
		
		local cardColorPic = gt6.seekNodeByName(decisionSignSpr,"Sprite_3")
		local mjTileName = self:getMJTileResName( 4, v[1], v[2], 1)
		mjTileName = self:getRealMJTileResName(mjTileName)
		mjTileName = gt6.getExternMjTileName(self.paimianNum, mjTileName)
		cardColorPic:setSpriteFrame(mjTileName)
		action:play("mjkaipai_1", false)

		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		local mjTilePos = mjTilesReferPos.holdStart

		decisionSignSpr:setPosition(mjTileSpr:getPositionX(),mjTilePos.y)

		local delayTime_sort = cc.DelayTime:create(action:getEndFrame() / 120)
		local callFunc_sort = cc.CallFunc:create(function(sender)
			local tag = sender:getTag()
			local mjTile = roomPlayer.holdMjTiles[tag]
			local cardColorPic = gt6.seekNodeByName(sender,"Sprite_3")
			local mjTileName = self:getMJTileResName( 4,mjTile.mjColor , mjTile.mjNumber, 1)
			mjTileName = self:getRealMJTileResName(mjTileName)
			mjTileName = gt6.getExternMjTileName(self.paimianNum, mjTileName)
			cardColorPic:setSpriteFrame(mjTileName)
		end)

		local delayTime = cc.DelayTime:create(action:getEndFrame() / 60)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:removeFromParent()
			self:boardStartAfter()

		end)

		local seqAction = cc.Sequence:create(delayTime_sort,callFunc_sort,delayTime, callFunc)
		decisionSignSpr:runAction(seqAction)
		self.playMjLayer:addChild(decisionSignSpr,self.SPPARAMS.MJMAXORDER*100)
	end


end

function PlaySceneCS:playMoPaiEffect()
	self.isOpeningAim = true
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(self.playerSeatIdx)
	self.randomColor = {}
	local randomData = {}
	table.merge(randomData,roomPlayer.holdMjTiles)
	for _,mjTile in ipairs(randomData) do
		if  not tolua.isnull(mjTile.mjTileSpr) and mjTile.mjTileSpr ~= nil then
			table.insert(self.randomColor,{mjTile.mjColor,mjTile.mjNumber})
		end
	end
	self.randomColor = self:shuffle(self.randomColor)

	self:createFirstKaiPaiAnim()
end

function PlaySceneCS:removeCenterMJTiles(  )
	if self.playMjLayer:getChildByName("centerMJTiles") then
		self.playMjLayer:removeChildByName("centerMJTiles")
	end
	if self.playMjLayer:getChildByName("centerMJBG") then
		self.playMjLayer:removeChildByName("centerMJBG")
	end
end

function PlaySceneCS:createShowCenterMJTiles(data)
	local m_bigMjTileBg = ccui.ImageView:create("gt6_btmjbg_lzoom.png",ccui.TextureResType.plistType)
	m_bigMjTileBg:setScale9Enabled(true)
	m_bigMjTileBg:setAnchorPoint(0.5,0.5)
	m_bigMjTileBg:setCapInsets(cc.rect(15,15,30,30))
	m_bigMjTileBg:setPosition(gt6.winCenter)
	m_bigMjTileBg:setName("centerMJTiles")
	self.playMjLayer:addChild(m_bigMjTileBg,self.SPPARAMS.MJMAXORDER*10)
	local mjTileName = self:getMJTileResName( 4, 1, 1, 1)
	local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
	local totlaLenght = mjTileSpr:getContentSize().width * (#data)
	local  lengthBg = ccui.ImageView:create()
	lengthBg:setScale9Enabled(true)
	lengthBg:setAnchorPoint(0.5,0.5)
	lengthBg:setName("centerMJBG")
	self.playMjLayer:addChild(lengthBg,self.SPPARAMS.MJMAXORDER*10)
	local mjTilePerRow  = 10 
	local totalRow = math.ceil(#data/mjTilePerRow)
	if #data > mjTilePerRow then 
		lengthBg:setContentSize(cc.size(mjTileSpr:getContentSize().width*mjTilePerRow,mjTileSpr:getContentSize().height*totalRow))
	else
		lengthBg:setContentSize(cc.size(totlaLenght,mjTileSpr:getContentSize().height))
	end
	m_bigMjTileBg:setContentSize(cc.size(lengthBg:getContentSize().width + 20 , lengthBg:getContentSize().height + 20))
	lengthBg:setPosition(gt6.winCenter)

	local row = 1 --行
	local col = 1 --列
	for index, bigmjTile in ipairs(data) do 
		if bigmjTile then 
			local mjTileName  = nil 
			local mjTileSpr  = nil 
			if bigmjTile[1] == 0 or bigmjTile[2] == 0 then
				mjTileSpr = ccui.ImageView:create("gt6_1MJ_spBack_y_.png",ccui.TextureResType.plistType) 
			else
				mjTileName = self:getMJTileResName( 4, bigmjTile[1], bigmjTile[2], 1)
				mjTileSpr = self:createWithSpriteFrameName(mjTileName)
			end
			mjTileSpr:setAnchorPoint(cc.p(0,1))
			mjTileSpr:setPosition(mjTileSpr:getContentSize().width*(col-1),  mjTileSpr:getContentSize().height*(totalRow - row + 1))
			lengthBg:addChild(mjTileSpr)
			col = col + 1 
			if col == 11 then
				row = row + 1
				col = 1
			end
		end
	end
end

function PlaySceneCS:setCanNotPlay( )
	local roomPlayer = self:getRoomPlayer(self.playerSeatIdx)
	if not roomPlayer or not next(roomPlayer) then return end
	self.m_canNotPlay = {}
	for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
		table.insert(self.m_canNotPlay,{mjTile.mjColor,mjTile.mjNumber})
	end
end

function PlaySceneCS:boardStartAfter()
	self.isOpeningAim = false
	for key,obj in pairs(self.toBeShow) do
		if obj and not tolua.isnull(obj)then
			obj:setVisible(true)
		end
	end
	self.toBeShow = {}

	self:setStatus(gt6.CommonConst.ROOM_STATUS.BOARD_START)
end

function PlaySceneCS:createZhuaNiao(bigMjTileTable,getNiaolist,brid_title)
	brid_title = brid_title or ""
	--重新组织一下方便后面的判断
	local bird_list = {}
	for index, bigmjTile in ipairs(bigMjTileTable) do 
		local bird_item = {}
		bird_item.color = bigmjTile[1]
		bird_item.num = bigmjTile[2]
		bird_item.is_brid = false
		for k,j in ipairs(getNiaolist) do
			if bigmjTile[1] == j[1] and bigmjTile[2] == j[2] then
				bird_item.is_brid = true 
				break
			end
		end

		table.insert(bird_list,bird_item)
	end

	print("====createZhuaNiao====")
	local m_bigMjTileBg = ccui.ImageView:create("gt6_btmjbg_lzoom.png",ccui.TextureResType.plistType)
	m_bigMjTileBg:setScale9Enabled(true)
	m_bigMjTileBg:setAnchorPoint(0.5,0.5)
	m_bigMjTileBg:setCapInsets(cc.rect(15,15,30,30))
	m_bigMjTileBg:setPosition(gt6.winCenter)
	self.playMjLayer:addChild(m_bigMjTileBg,self.SPPARAMS.MJMAXORDER*10)
	local mjTileName = self:getMJTileResName( 4, 1, 1, 1)
	local mjTileSpr = self:createWithSpriteFrameName(mjTileName)
	local totlaLenght = mjTileSpr:getContentSize().width * (#bigMjTileTable)
	local  lengthBg = ccui.ImageView:create()
	lengthBg:setScale9Enabled(true)
	lengthBg:setAnchorPoint(0.5,0.5)
	self.playMjLayer:addChild(lengthBg,self.SPPARAMS.MJMAXORDER*10)
	local mjTilePerRow  = 10 
	local totalRow = math.ceil(#bigMjTileTable/mjTilePerRow)
	if #bigMjTileTable > mjTilePerRow then 
		lengthBg:setContentSize(cc.size(mjTileSpr:getContentSize().width*mjTilePerRow,mjTileSpr:getContentSize().height*totalRow))
	else
		lengthBg:setContentSize(cc.size(totlaLenght,mjTileSpr:getContentSize().height))
	end
	m_bigMjTileBg:setContentSize(cc.size(lengthBg:getContentSize().width + 20 , lengthBg:getContentSize().height + 20))
	lengthBg:setPosition(gt6.winCenter)

	local title_node = cc.Node:create()
	title_node:setAnchorPoint(cc.p(0.5,0.5))
	local brid_icon = ccui.ImageView:create(brid_title)
	brid_icon:setAnchorPoint(cc.p(0,0.5))
	brid_icon:setPosition(cc.p(0,0))
	title_node:addChild(brid_icon)

	--zhuaniao_number.png
	local label = cc.LabelAtlas:create("/0",PlaySceneCS.playScenePath.."zhuaniao_number.png",55,65,string.byte("/"))
	label:setAnchorPoint(cc.p(0,0.5))
	label:setPosition(cc.p(brid_icon:getContentSize().width,0))
	title_node:addChild(label)
	title_node:setContentSize(brid_icon:getContentSize().width+label:getContentSize().width,0)

	title_node:setPosition(cc.p(lengthBg:getContentSize().width/2,lengthBg:getContentSize().height+40))
	title_node:setLocalZOrder(2)
	lengthBg:addChild(title_node)

	local brid_num = 0 

	local row = 1 --行
	local col = 1 --列
	local delay_time= 0
	local pos_x = mjTileSpr:getContentSize().width/2
	local pos_y = mjTileSpr:getContentSize().height/2
	for index, bigmjTile in ipairs(bird_list) do 
		local mjTileName  = nil 
		local mjTileSpr  = nil 

		mjTileSpr = self:createPaiMian( 4, bigmjTile.color, bigmjTile.num, 1)

		local decisionSignSpr, action = gt6.createCSAnimation(PlaySceneCS.animPath .. "zhuaniao.csb")
		decisionSignSpr:addChild(mjTileSpr)
		decisionSignSpr:setVisible(false)
		decisionSignSpr:setPosition(pos_x,pos_y)
		pos_x = pos_x + mjTileSpr:getContentSize().width
	
		lengthBg:addChild(decisionSignSpr)
		col = col + 1 
		if col == 11 then
			row = row + 1
			pos_y = pos_y +mjTileSpr:getContentSize().height
			col = 1
		end

		local delayTime = cc.DelayTime:create(delay_time)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:setVisible(true)
			action:play("zhuaniao", false)
			action:setTimeSpeed(0.8)

			if not bigmjTile.is_brid then
				--print("action:getEndFrame()==="..tostring(action:getEndFrame()))
				action:gotoFrameAndPlay(action:getEndFrame())
				sender:setColor(cc.c3b(180, 180, 180))

				local card_scale = cc.ScaleTo:create(0.5,1)
				local easeOut1 = cc.EaseExponentialOut:create(card_scale)
				sender:runAction(easeOut1)

			else

				label:stopAllActions()
				local scale1 = cc.ScaleTo:create(0.3,2)
				local scale2 = cc.ScaleTo:create(0.3,1)
				local easeOut1 = cc.EaseExponentialOut:create(scale1)
				local easeOut2 = cc.EaseExponentialOut:create(scale2)
				local action = cc.Sequence:create(easeOut1,easeOut2)
				label:runAction(action)
				brid_num = brid_num + 1
				label:setString("/"..brid_num)
			end 
		end)

	
		if bigmjTile.is_brid then
			delay_time = 0.5 + delay_time
		else
			decisionSignSpr:setScale(2)
			delay_time = delay_time + 0.3
		end

	
		local seqAction = cc.Sequence:create(delayTime, callFunc)
		decisionSignSpr:runAction(seqAction)
	end
end

--检测过牌后的自动出
function PlaySceneCS:checkGuoAutoPlay()

end

--修正麻将出牌点(目前只针对血流,血战)
function PlaySceneCS:reviseOutMjPoint(revise_out_point)
	-- body
	for i = 1, 4 do
		local revise_item = revise_out_point[i]
		if revise_item then
			local node = gt6.seekNodeByName(self.rootNode,"Node_playerOutMjTiles_"..tostring(i))
			local x = node:getPositionX() + revise_item.x
			local y = node:getPositionY() + revise_item.y * cc.Director:getInstance():getVisibleSize().height/720
			node:setPosition(cc.p(x,y))
		end
	end 
end

--修正胡的位置
function PlaySceneCS:reviseHuPoint(revise_hu_point)
	--Image_HuBg
	-- body
	for i = 1, 4 do
		local revise_item = revise_hu_point[i]
		if revise_item then
			local node = gt6.seekNodeByName(self.rootNode,"Node_playerOutMjTiles_"..tostring(i))
			local Image_HuBg = gt6.seekNodeByName(node,"Image_HuBg")
			local x = Image_HuBg:getPositionX() + revise_item.x
			local y = Image_HuBg:getPositionY() + revise_item.y-- * cc.Director:getInstance():getVisibleSize().height/720
			Image_HuBg:setPosition(cc.p(x,y))
		end
	end 
end

function PlaySceneCS:countOutMjPoint(roomPlayer,mjTilesReferPos)
	local mjTilePos = mjTilesReferPos.outStart

	local lineCount = math.ceil(#roomPlayer.outMjTiles / self.mjTilePerLine) - 1
	local lineIdx = #roomPlayer.outMjTiles - lineCount * self.mjTilePerLine - 1

	--1,4位置的玩家出牌第二行12张 4人
	if (roomPlayer.displaySeatIdx == 2  or roomPlayer.displaySeatIdx == 4) and self.playMaxNum == 4 then
		if roomPlayer.outMjTiles and  #roomPlayer.outMjTiles > 20 then
			lineCount = 1
			lineIdx = #roomPlayer.outMjTiles - 11
		end
	end

	--3人调整
	if self.playMaxNum == 3   then
		if roomPlayer.outMjTiles and #roomPlayer.outMjTiles > 30  then
			lineCount = 2
			lineIdx = #roomPlayer.outMjTiles - 21
		end
	end
		
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
	return mjTilePos,0
end

function PlaySceneCS:countOutMjZorder(displaySeatIdx,mjTilePos,layer)
	if not layer then
		layer = 0 
	end
	local zOrder = 0 
	if displaySeatIdx == 1 then
		zOrder = (gt6.winSize.height - mjTilePos.y + mjTilePos.x )
	elseif displaySeatIdx == 2 then
		zOrder = (gt6.winSize.height - mjTilePos.y - mjTilePos.x )
	elseif displaySeatIdx == 3 then
		zOrder = (gt6.winSize.height - mjTilePos.y - mjTilePos.x)
	elseif displaySeatIdx == 4 then
		zOrder = (10000 + gt6.winSize.height - mjTilePos.y - mjTilePos.x)
	end

	--策划要求落起来 所以加入一个层的概念
	zOrder = layer*1000 + zOrder
	--print("countOutMjPoint==="..tostring(zOrder))

	return zOrder
end


--打出最后一张牌
function PlaySceneCS:showFinalCard(roomPlayer)
	-- body
	self.chooseMjTileIdx = #roomPlayer.holdMjTiles
	self.chooseMjTile = roomPlayer.holdMjTiles[self.chooseMjTileIdx]

	local msgToSend = {}
	msgToSend.m_msgId = gt6.CG_SHOW_MJTILE
	msgToSend.m_type = 1
	msgToSend.m_think = {}
	table.insert(msgToSend.m_think, {self.chooseMjTile.mjColor , self.chooseMjTile.mjNumber})
	gt6.socketClient:sendMessage(msgToSend)
end


function PlaySceneCS:playStartBoard()
	local start_board, action = gt6.createCSAnimation(PlaySceneCS.animPath.."Xjbc_kaiju.csb")
	action:play("Xjbc_kaiju", false)
	dump(gt6.winCenter,"gt6.winCenter====")
	start_board:setPosition(gt6.winCenter)
	start_board:setLocalZOrder(10)
	start_board:setName(PlaySceneCS.NODE_NAME.BOARD_START_ANI_NAME)
	self.common_ui_layer:addChild(start_board)

	
	local callFunc = cc.CallFunc:create(function(sender)
		self:playMoPaiEffect()
	end)

	start_board:runAction(cc.Sequence:create(cc.DelayTime:create(action:getEndFrame()/60),callFunc))

    
    --牌局状态
	local roundStateNode = gt6.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(true)
	self.playTimeCDLabel:setVisible(false)
	local beforeDealCdLabel = gt6.seekNodeByName(self.rootNode,"beforeDealCdLabel")
	if beforeDealCdLabel ~= nil then
		beforeDealCdLabel:removeFromParent()
	end
	self:clearBeforeDealSp()

	print("xxxx")
end

function PlaySceneCS:playStartBoardEnd()

	local function remove(sender,tb)
        --cclog("inActionCallFunc")
        sender:removeFromParent()
    end
   
	local board_end_sprite = ccui.ImageView:create(PlaySceneCS.PicPath.."gt6_mj_end.png")
	local scale1 = cc.ScaleTo:create(0.3,2)
	local scale2 = cc.ScaleTo:create(0.3,1)
	local easeOut1 = cc.EaseExponentialOut:create(scale1)
	local easeOut2 = cc.EaseExponentialOut:create(scale2)
	local action = cc.Sequence:create(easeOut1,easeOut2,cc.DelayTime:create(0.5),cc.CallFunc:create(remove))
	board_end_sprite:runAction(action)
	board_end_sprite:setLocalZOrder(10)
	board_end_sprite:setPosition(gt6.winCenter)
	self.common_ui_layer:addChild(board_end_sprite)

	print("onRcvRoundReport==onRcvRoundReport===")
end

function PlaySceneCS:clearMjLayer()
	if self.playMjLayer then
		self.playMjLayer:removeAllChildren()
	end 

	if self.playOutMjLayer then
		self.playOutMjLayer:removeAllChildren()
	end 
end


function PlaySceneCS:createRounReport(report_path,msgTbl,isLast)
	local room_players = gt6.PlayersManager:getAllRoomPlayers()
	local roundReport = self:getChildByName(POP_NAME_LIST.ROUND_REPORT)
	if not roundReport then
		roundReport = require(report_path):create({
				playGame = self,			
				roomPlayers = room_players,
				playerSeatIdx = self.playerSeatIdx,
				rptMsgTbl = msgTbl,
				isLast = isLast					
		})
		roundReport:setName(POP_NAME_LIST.ROUND_REPORT)
		self:addChild(roundReport, self.ZOrder.ROUND_REPORT)
	end 
end

function PlaySceneCS:createCoinChangeEffect(seatIdx, content, plus_info, minus_info)
	if not plus_info or not minus_info then
		return
	end

	print("createCoinChangeEffect==1"..tostring(content))
	local str =Utils6.formatSymbolAtlasValue(content,true)
	print("createCoinChangeEffect==2"..tostring(str))

	local fontPic = plus_info.fontPic
	local font_size = plus_info.font_size 
	local first_char = plus_info.first_char

	if content<=0 then
		fontPic = minus_info.fontPic
		font_size = minus_info.font_size 
		first_char = minus_info.first_char
	end
	
	local numFont = cc.LabelAtlas:create(str,fontPic,font_size.width,font_size.height,string.byte(first_char))
	numFont:setAnchorPoint(cc.p(0.5,0.5))
	if not numFont then return end 

	local playNode = gt6.seekNodeByName(self.rootNode, "Node_play")
	local mjTilesOutReferNode = gt6.seekNodeByName(playNode,"Node_playerOutMjTiles_"..seatIdx)
	local huPaiBg = gt6.seekNodeByName(mjTilesOutReferNode,"Image_HuBg")
	local pos = gt6.getRealWordPosition(huPaiBg)

	numFont:setPosition(pos)

    local callback = cc.CallFunc:create(function(sender,table)
        sender:removeFromParent()
    end)

    local moveBy = cc.MoveBy:create(1.3, cc.p(0,60))
  
    local deal_dt = 0
    local action = cc.Sequence:create(cc.DelayTime:create(deal_dt),moveBy,callback)
    numFont:runAction(action)

    playNode:getParent():addChild(numFont,100)

    return numFont
end

--分数加减效果
function PlaySceneCS:socreChangeEffect(data)

	local changeReason  = {
	unkonwn_1 = 1,
	unkonwn_1 = 2,
	unkonwn_3 = 3,
	Add = 4, --加
	Minus = 5, --减
	Ticket = 6, --报名费
	ChaJiao = 134, --血流 查叫
	ChaHuaZhu = 133, --血流 查花猪
	HuJiaoZhuanYi = 135, --血流，呼叫转移
	TuiShui = 132, --血流 退税

	}

	local show_emun = {
		positive = 1, --正值显示
		negative = 2,--负值显示
	}

	local resTable = {}
	resTable[changeReason.ChaJiao] = {title = nil,csb = PlaySceneCS.animPath.."mj_chajiao",show_type = show_emun.negative}
	resTable[changeReason.ChaHuaZhu]= {title = nil, csb = PlaySceneCS.animPath.."mj_chahuazhu",show_type =show_emun.negative }
	resTable[changeReason.HuJiaoZhuanYi]= {title = nil,csb = PlaySceneCS.animPath.."mj_hujiaozhuanyi",show_type = show_emun.negative}
	resTable[changeReason.TuiShui]= {title = nil,csb = PlaySceneCS.animPath.."mj_tuishui",show_type = show_emun.negative}

	local changeNum = data.changeNum
	local roomPlayer = gt6.PlayersManager:getRoomPlayersBySeat(data.m_pos + 1)

	if data.reason == changeReason.Ticket then
		return --不显示报名费的扣分
	end

	local numFont = self:createCoinChangeEffect(roomPlayer.displaySeatIdx or 4, changeNum, plus_info, minus_info)
	numFont:setScale(0.9)

	print("---socreChangeEffect----"..tostring(data.reason))
	local res = resTable[data.reason] or {}
	if res.csb then
		print("---socreChangeEffect--res.csb--"..tostring(res.csb))
		local is_show = false 
		if show_emun.negative == res.show_type then
			if changeNum < 0 then 
				is_show = true
			end 
		else 
			if changeNum > 0 then
				is_show = true 
			end 
		end

		print("---socreChangeEffect--is_show--"..tostring(is_show))
		if is_show then
			roomPlayer:createEffect(res.csb..".csb","LN_chi_3")
		end	
	end
end

return PlaySceneCS