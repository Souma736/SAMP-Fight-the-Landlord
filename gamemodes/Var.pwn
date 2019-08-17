#define MAX_TABLES 100
#define MAX_PLAYER_CARDS 20
#define MAX_CARDS 54

#define STATUS_JUST_START 0 	//刚开局
#define STATUS_DEAL 1 		//开始发牌
#define STATUS_SHOW_HIDDEN_CARDS 2 //亮 三张底牌
#define STATUS_CALL_LORD 3 //叫地主阶段
#define STATUS_PLAY 4 //出牌阶段

#define TABLE_ACTOR_SKIN 25

#define TYPE_WRONG      -1//错误的类型
#define TYPE_SOLO 		0 //单张
#define TYPE_PAIR 		1 //对子 (1对，3连对，4连对...)
#define TYPE_TRIPLE     2 //三张 (3带1, 3带一对,  2*3+1+1  2*3+2 3*3+1+1+1, 3*3+2+1 ...
#define TYPE_QUAD       4 //四张 (炸弹， 4带2 (1+1, 2))
#define TYPE_STRAIGHT   5 //顺子 (5, 6, 7 ...)
#define TYPE_BOOM       6 //王炸

#define SEAT_LABEL_DRAW_DISTANCE 5.0
#define TABLE_LABEL_DRAW_DISTANCE 15.0



#define TIME_CALL_LORD 20*10 // 叫地主 20 s
#define TIME_PLAY 30*10 //正常游玩

enum tableinfo{
	// --- 游戏前
	Text3D:tLabels[3],
	Text3D:tMainLabel,
	tSeatPlayerIds[3],
	tStarted,
	Float:tAngle,
	tGuard[3], // 托管
	tGuardTimer[3], // 托管求解的计时器
	tTimer,
	tBasicGold, //基本分
	tTimes, //倍数

	// --- 游戏中
	tStatus, // 状态
	tTimeCount, // Handler计数器
	tCards[MAX_CARDS],
	tCalled, // 轮的次数
	tLordRefreshed, // 地主被目前的玩家叫了
	tLord, // 地主 ID (0, 1, 2)
	tRespond, // 是否有玩家回应
	tLordCallCoolTime, //显示结果等待时间
	tCurrentPlayer, // 当前的操作人

	// --- 当前出牌的变量
	tFirstHand, // 是否为第一个出牌人
	tLastCards[MAX_PLAYER_CARDS], // 记录上一次出牌的数组
	tLastCardSize,
	tLastType, //记录上一次出牌的牌型
	tLastTypeDetail, //上一次出牌牌型的具体分型 如 3带1 3带2
	tLastTypeLevel, //记录上一次出牌牌型对应的等级(高等级压低等级)


	//Cards 值说明
	/*
		红心 	方块 	黑桃 	梅花
	3   1       2       3       4
	4   5       6       7       8
	5   9       10      11      12
	6   13      14      15      16
	7   17      18      19      20
	8   21      22      23      24
	9   25      26      27      28
	10  29      30      31      32
	J   33      34      35      36
	Q   37      38      39      40
	K   41      42      43      44
	A   45      46      47      48
	2   49      50      51      52
    王  53 		54
	*/
}
new Table[MAX_TABLES][tableinfo];
new TablePlayerCards[MAX_TABLES][3][MAX_PLAYER_CARDS];
new TablePlayerCardsSelected[MAX_TABLES][3][MAX_PLAYER_CARDS];
new TablePlayerNames[MAX_TABLES][3][MAX_PLAYER_NAME];
new Float:TableSeatPos[MAX_TABLES][3][3];
new tableid = 0;

// 玩家信息
#define MAX_PLAYER_PASSWORD 128
#define MAX_PLAYER_TEXT_VIEW 124
enum playerinfo{
	pName[MAX_PLAYER_NAME],
	pPassword[MAX_PLAYER_PASSWORD],
	pGold,
	pScore,
	pLogged,
	pLastSpeakTime,
	pTableID,
	pSeatID,
	pIsTxdShowing[MAX_PLAYER_TEXT_VIEW],
	pCardTxdStartID,// 以下边牌的TXD ID 为基准 即 1 ~ 20
	pCardTxdEndID, //  StartID <= x < EndID
}
new Player[MAX_PLAYERS][playerinfo];
new PlayerText:pTextDraw[MAX_PLAYER_TEXT_VIEW];
