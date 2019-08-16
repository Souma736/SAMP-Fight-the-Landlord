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

//API
forward Player::OnPlayerConnect(playerid);
forward Player::OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
forward Player::OnPlayerText(playerid, text[]);
forward Player::OnPlayerDisconnect(playerid, reason);
forward Player::OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
forward Player::kick(playerid, message[]);
forward Player::clickTXD(playerid, PlayerText:playertextid);

public Player::OnPlayerConnect(playerid){
	Player::init(playerid);
	Player::loadTxd(playerid);
	GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
	if(strlen(Player[playerid][pName]) >= 20){
		Player::kick(playerid, "名字太长了,换一个短一点的来吧");
	} else {
		if(Player::isRegistered(playerid)){
			Player::loadData(playerid);
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "登录界面", "  请输入密码登录", "登录", "退出");
		} else {
			ShowPlayerDialog(playerid, DIALOG_REG, DIALOG_STYLE_INPUT, "注册界面", "  请输入密码注册", "注册", "退出");
		}
	}
}

public Player::OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	if(dialogid == DIALOG_REG){
		if(response){
			if(strlen(inputtext) > 5 && strlen(inputtext) < MAX_PLAYER_PASSWORD){
				format(Player[playerid][pPassword], MAX_PLAYER_PASSWORD, inputtext);
				Player::newbieGift(playerid);
				Player::saveData(playerid);
				Player::onSpawn(playerid);
			} else {
				ShowPlayerDialog(playerid, DIALOG_REG, DIALOG_STYLE_INPUT, "注册界面", "  请输入密码注册\n \
				{FF0000}密码太长或太短，请重新输入", "注册", "退出");
			}
		} else {
			Kick(playerid);
		}
	} else if(dialogid == DIALOG_LOGIN){
		if(response){
			if(strlen(inputtext) > 5 && strlen(inputtext) < MAX_PLAYER_PASSWORD){
				if(!strcmp(inputtext, Player[playerid][pPassword])){
					Player::onSpawn(playerid);
				} else {
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "登录界面", "  请输入密码登录\
					\n  {FF0000}密码错误，请重新输入", "登录", "退出");
				}
			} else {
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "登录界面", "  请输入密码登录\
					\n  {FF0000}密码太长或太短，请重新输入与", "登录", "退出");
			}
		} else {
			Kick(playerid);
		}
	}

}

public Player::OnPlayerText(playerid, text[]){
	if(gettime() - Player[playerid][pLastSpeakTime] >= 3){
		new msg[128];
		Player[playerid][pLastSpeakTime] = gettime();
		format(msg, sizeof msg, "%s 说: %s", Player[playerid][pName], text);
		SendClientMessageToAll(-1, msg);
	} else {
		SendClientMessage(playerid, 0xFFFF00, "您说话太快了，慢一点吧~");
	}
}

public Player::OnPlayerDisconnect(playerid, reason){
	if(Player::isLogged(playerid)){
	    if(Player[playerid][pTableID] != -1){
	        Table::onPlayerLeave(playerid, Player[playerid][pTableID], Player[playerid][pSeatID]);
	    }
	    Player::saveData(playerid);
	}
	Player[playerid][pLogged] = 0;
}

public Player::OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	if(Player[playerid][pLogged] == 0)return;
	if(PRESSED(KEY_CTRL_BACK)){
	    if(Player[playerid][pTableID] == -1){
			new table, seat;
			Table::getTableAndSeatByPlayer(playerid, table, seat);
			if(table == -1){
			    SendClientMessage(playerid, -1, "{FF0000}[提示]{FFFFFF}你得在一个座位附近才能准备");
			} else {
			    Player[playerid][pTableID] = table;
			    Player[playerid][pSeatID] = seat;
			    TogglePlayerControllable(playerid, false);
				Table::onPlayerJoin(playerid, table, seat);
			}
	    } else {
	        if(!Table::isStarted(Player[playerid][pTableID])){
	            TogglePlayerControllable(playerid, true);
	        	Table::onPlayerUnjoin(playerid, Player[playerid][pTableID], Player[playerid][pSeatID]);
	        	Player[playerid][pTableID] = -1;
	        } else {
	            //TODO 游戏中不能退出
	        }
	    }
	}
}

public Player::clickTXD(playerid, PlayerText:playertextid){
    if(Player[playerid][pLogged] == 0)return;
    
	if(playertextid == pTextDraw[117]){
		// NO 按钮
	    Table::onPlayerClick(Player[playerid][pTableID], Player[playerid][pSeatID], CLICK_NO);
	} else if(playertextid == pTextDraw[118]){
		// YES 按钮
		Table::onPlayerClick(Player[playerid][pTableID], Player[playerid][pSeatID], CLICK_YES);
	}
	// 点击了自己的牌
	for(new i = 1; i < 21; i++){
	    if(playertextid == pTextDraw[i] || playertextid == pTextDraw[i+80]){
	        //点击了自己的牌(包括上下面)
	        if(i >= Player[playerid][pCardTxdStartID] && i < Player[playerid][pCardTxdEndID]){
	            // 如果不是空牌
	            Table::onPlayerShiftCard(playerid, Player[playerid][pTableID], Player[playerid][pSeatID], i-Player[playerid][pCardTxdStartID]);
	        } else {
	            SendClientMessage(playerid, -1, "空牌");
	        }
	        break;
	    }
	}
}


//声明
forward Player::init(playerid);
forward Player::loadData(playerid);
forward Player::isRegistered(playerid);
forward Player::onSpawn(playerid);
forward Player::isLogged(playerid);
forward Player::saveData(playerid);
forward Player::newbieGift(playerid);
forward Player::loadTxd(playerid);
forward Player::showBasicTableTxd(playerid, prev_id, next_id, basic_gold, times);
forward Player::updateCardTxd(playerid, const mycards[], const card_selected[], my_cards, prev_cards, next_cards);
forward Player::updateHiddenCardTxd(playerid, const hidden_cards[]);
forward Player::showButton(playerid, time, button_no[], button_yes[]);
forward Player::showTime(playerid, pos, time);
forward Player::hideButton(playerid);
forward Player::hideTime(playerid);
forward Player::showCallResult(playerid, pos, result);
forward Player::textdrawShow(playerid, PlayerText:text);
forward Player::textdrawHide(playerid, PlayerText:text);
forward Player::showLordName(playerid, const name[]);

public Player::init(playerid){
	format(Player[playerid][pName], 1, " ");
	format(Player[playerid][pPassword], 1, " ");
	Player[playerid][pGold] = 0;
	Player[playerid][pScore] = 0;
	Player[playerid][pLogged] = 0;
	Player[playerid][pLastSpeakTime] = 0;
	Player[playerid][pTableID] = -1;
	for(new i = 0; i < MAX_PLAYER_TEXT_VIEW; i++){
	    Player[playerid][pIsTxdShowing][i] = 0;
	}
}

public Player::isRegistered(playerid){
	new filename[64];
	format(filename, sizeof filename, "Accounts/%s.ini", Player[playerid][pName]);
	if(fexist(filename))return true;
	return false;
}

public Player::loadData(playerid){
	new File[64];
	format(File, sizeof File, "Accounts/%s.ini", Player[playerid][pName]);
	strmid(Player[playerid][pPassword], dini_Get(File, "password"), 0, strlen(dini_Get(File,"password")), MAX_PLAYER_PASSWORD);
	Player[playerid][pGold] = dini_Int(File, "gold");
	Player[playerid][pScore] = dini_Int(File, "score");
}

public Player::onSpawn(playerid){
	Player[playerid][pLogged] = 1;
	SetSpawnInfo( playerid, 0, 0, -8.1000, 1510.0000, 12.7758, 269.15, 0, 0, 0, 0, 0, 0 );
	SpawnPlayer(playerid);
}

public Player::isLogged(playerid){
	return (Player[playerid][pLogged]==1);
}

public Player::saveData(playerid){
	new File[64];
	format(File, sizeof File, "Accounts/%s.ini", Player[playerid][pName]);
	if(!fexist(File))dini_Create(File);
	dini_Set(File, "password", Player[playerid][pPassword]);
	dini_IntSet(File, "gold", Player[playerid][pGold]);
	dini_IntSet(File, "score", Player[playerid][pScore]);
}

public Player::newbieGift(playerid){
	Player[playerid][pGold] = 100;
	Player[playerid][pScore] = 0;
}

public Player::kick(playerid, message[]){
	new string[128];
	format(string, sizeof string, "您被请出了服务器，原因：%s", message);
	SendClientMessage(playerid, 0xFF0000FF, string);
	SetTimerEx("Player_delayKick", 100, false, "d", playerid);
}

public Player::showBasicTableTxd(playerid, prev_id, next_id, basic_gold, times){
	for(new i = 1; i < MAX_PLAYER_TEXT_VIEW; i++){
	    Player::textdrawHide(playerid, pTextDraw[i]);
	}
	for(new i = 1; i < 101; i++){
	    PlayerTextDrawSetString(playerid, pTextDraw[i], "none");
	}
	new string[128];
	// -- 顶部ui
	format(string, sizeof string, "%d", basic_gold);
	PlayerTextDrawSetString(playerid, pTextDraw[102], string);
	format(string, sizeof string, "X%d", times);
	PlayerTextDrawSetString(playerid, pTextDraw[103], string);
	// -- 上家UI
	if(Robot::isRobot(prev_id)){
	// 如果是个电脑
	    Robot::getName(prev_id, string);
	    format(string, sizeof string, "%s", string);
	    PlayerTextDrawSetString(playerid, pTextDraw[104], string);
	    format(string, sizeof string, "GOLD: %d", Robot::getGold(prev_id));
	    PlayerTextDrawSetString(playerid, pTextDraw[105], string);
	    format(string, sizeof string, "SCORE: %d", Robot::getScore(prev_id));
	    PlayerTextDrawSetString(playerid, pTextDraw[106], string);
	} else {
	// 如果是个玩家
	    format(string, sizeof string, "%s", Player[prev_id][pName]);
	    PlayerTextDrawSetString(playerid, pTextDraw[104], string);
	    format(string, sizeof string, "GOLD: %d", Player[prev_id][pGold]);
	    PlayerTextDrawSetString(playerid, pTextDraw[105], string);
	    format(string, sizeof string, "SCORE: %d", Player[prev_id][pScore]);
	    PlayerTextDrawSetString(playerid, pTextDraw[106], string);
	}
	// -- 下家UI
	if(Robot::isRobot(next_id)){
	// 如果是个电脑
	    Robot::getName(next_id, string);
	    format(string, sizeof string, "%s", string);
	    PlayerTextDrawSetString(playerid, pTextDraw[107], string);
	    format(string, sizeof string, "GOLD: %d", Robot::getGold(next_id));
	    PlayerTextDrawSetString(playerid, pTextDraw[108], string);
	    format(string, sizeof string, "SCORE: %d", Robot::getScore(next_id));
	    PlayerTextDrawSetString(playerid, pTextDraw[109], string);
	} else {
	// 如果是个玩家
	    format(string, sizeof string, "%s", Player[next_id][pName]);
	    PlayerTextDrawSetString(playerid, pTextDraw[107], string);
	    format(string, sizeof string, "GOLD: %d", Player[next_id][pGold]);
	    PlayerTextDrawSetString(playerid, pTextDraw[108], string);
	    format(string, sizeof string, "SCORE: %d", Player[next_id][pScore]);
	    PlayerTextDrawSetString(playerid, pTextDraw[109], string);
	}
	// -- 自己的情况
	for(new i = 110; i < 114; i++){
	    PlayerTextDrawSetString(playerid, pTextDraw[i], "~n~");
	}
	format(string, sizeof string, "MY GOLD: %d", Player[playerid][pGold]);
	PlayerTextDrawSetString(playerid, pTextDraw[114], string);
	format(string, sizeof string, "MY SCORE: %d", Player[playerid][pScore]);
	PlayerTextDrawSetString(playerid, pTextDraw[115], string);
	PlayerTextDrawSetString(playerid, pTextDraw[116], "~n~");
	PlayerTextDrawSetString(playerid, pTextDraw[120], "~n~");
	// -- 底牌
	for(new i = 121; i < 124; i++){
	    PlayerTextDrawSetString(playerid, pTextDraw[i], "LD_POKE:cdback");
	}
	// -------显示所有的view
	for(new i = 0; i < MAX_PLAYER_TEXT_VIEW; i++){
	    Player::textdrawShow(playerid, pTextDraw[i]);
	}
	//  隐藏两个button
	Player::textdrawHide(playerid, pTextDraw[111]);
	Player::textdrawHide(playerid, pTextDraw[113]);
	Player::textdrawHide(playerid, pTextDraw[116]);
	Player::textdrawHide(playerid, pTextDraw[117]);
	Player::textdrawHide(playerid, pTextDraw[118]);
}

public Player::updateCardTxd(playerid, const mycards[], const card_selected[], my_cards, prev_cards, next_cards){
	// 先更新我的牌
 	new card_size = my_cards;
	new text_draw_start_id = 10 - card_size/2 + 1;
	Player[playerid][pCardTxdStartID] = text_draw_start_id;
	Player[playerid][pCardTxdEndID] = text_draw_start_id + card_size;
	for(new i = 1; i < 21; i++){
	    if(i < text_draw_start_id || i >= text_draw_start_id + card_size){
	        PlayerTextDrawSetString(playerid, pTextDraw[i], "none");
	        PlayerTextDrawSetString(playerid, pTextDraw[i+80], "none");
	    } else {
	        new font_name[32];
	        Table::getCardFontNameByValue(mycards[i-text_draw_start_id], font_name);
	        if(card_selected[i-text_draw_start_id] == 1){
	            PlayerTextDrawSetString(playerid, pTextDraw[i+80], font_name);
	            PlayerTextDrawSetString(playerid, pTextDraw[i], "none");
	        } else {
	            PlayerTextDrawSetString(playerid, pTextDraw[i], font_name);
	            PlayerTextDrawSetString(playerid, pTextDraw[i+80], "none");
	        }
	        
	    }
	}
	// 再更新上家的牌
	text_draw_start_id = 10 - prev_cards/2 + 21;
	for(new i = 21; i < 41; i++){
	    if(i < text_draw_start_id || i >= text_draw_start_id + prev_cards){
	        PlayerTextDrawSetString(playerid, pTextDraw[i], "none");
	    } else {
	        PlayerTextDrawSetString(playerid, pTextDraw[i], "LD_CARD:cdback");
	    }
	}
	new cards_left[16];
	format(cards_left, sizeof cards_left, "(%d)", prev_cards);
	PlayerTextDrawSetString(playerid, pTextDraw[110], cards_left);
	// 再更新下家的牌
	text_draw_start_id = 10 - next_cards/2 + 41;
	for(new i = 41; i < 61; i++){
	    if(i < text_draw_start_id || i >= text_draw_start_id + next_cards){
	        PlayerTextDrawSetString(playerid, pTextDraw[i], "none");
	    } else {
	        PlayerTextDrawSetString(playerid, pTextDraw[i], "LD_CARD:cdback");
	    }
	}
	format(cards_left, sizeof cards_left, "(%d)", next_cards);
	PlayerTextDrawSetString(playerid, pTextDraw[112], cards_left);
}

public Player::updateHiddenCardTxd(playerid, const hidden_cards[]){
	new textdraw_start_id = 121;
	for(new i = 0; i < 3; i++){
	    new font_name[16];
		Table::getCardFontNameByValue(hidden_cards[i], font_name);
		PlayerTextDrawSetString(playerid, pTextDraw[textdraw_start_id+i], font_name);
	}
}

public Player::showButton(playerid, time, button_no[], button_yes[]){
	new msg[16];
	format(msg, sizeof msg, "%d", time);
    PlayerTextDrawSetString(playerid, pTextDraw[116], msg);
	PlayerTextDrawSetString(playerid, pTextDraw[117], button_no);
	PlayerTextDrawSetString(playerid, pTextDraw[118], button_yes);
	for(new i = 116; i < 119; i++){
	    Player::textdrawShow(playerid, pTextDraw[i]);
	}
}

public Player::showTime(playerid, pos, time){
	new msg[16];
	format(msg, sizeof msg, "%d", time);
	if(pos == SEAT_PREV){
	    PlayerTextDrawSetString(playerid, pTextDraw[111], msg);
	    Player::textdrawShow(playerid, pTextDraw[111]);
	} else {
	    PlayerTextDrawSetString(playerid, pTextDraw[113], msg);
	    Player::textdrawShow(playerid, pTextDraw[113]);
	}
}

public Player::showCallResult(playerid, pos, result){
	new msg[16];
	if(result == 1){
	    format(msg, sizeof msg, "CALL");
	} else {
	    format(msg, sizeof msg, "NO");
	}
	
	if(pos == SEAT_PREV){
	    PlayerTextDrawSetString(playerid, pTextDraw[111], msg);
	    Player::textdrawShow(playerid, pTextDraw[111]);
	} else if(pos == SEAT_NEXT){
	    PlayerTextDrawSetString(playerid, pTextDraw[113], msg);
	    Player::textdrawShow(playerid, pTextDraw[113]);
	} else {
	    PlayerTextDrawSetString(playerid, pTextDraw[116], msg);
	    Player::textdrawShow(playerid, pTextDraw[116]);
	}
}

public Player::hideButton(playerid){
	for(new i = 116; i < 119; i++){
	    Player::textdrawHide(playerid, pTextDraw[i]);
	}
}

public Player::hideTime(playerid){
	Player::textdrawHide(playerid, pTextDraw[111]);
	Player::textdrawHide(playerid, pTextDraw[113]);
}

public Player::showLordName(playerid, const name[]){
	new name2[MAX_PLAYER_NAME];
	format(name2, sizeof name2, name);
	PlayerTextDrawSetString(playerid, pTextDraw[120], name2);
}

forward Player::delayKick(playerid);
public Player::delayKick(playerid){
	if(IsPlayerConnected(playerid)){
	    Kick(playerid);
	}
}

public Player::loadTxd(playerid){
	// -- 大黑色背景
    pTextDraw[0] = CreatePlayerTextDraw(playerid, 640.000000, 110.000000, "~n~");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[0], 255);
	PlayerTextDrawFont(playerid, pTextDraw[0], 1);
	PlayerTextDrawLetterSize(playerid, pTextDraw[0], 0.500000, 37.199981);
	PlayerTextDrawColor(playerid, pTextDraw[0], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[0], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[0], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[0], 1);
	PlayerTextDrawUseBox(playerid, pTextDraw[0], 1);
	PlayerTextDrawBoxColor(playerid, pTextDraw[0], 235);
	PlayerTextDrawTextSize(playerid, pTextDraw[0], 0.000000, 40.000000);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[0], 0);
	
	// -- 自己的牌(下面) 可选  以及 上面的牌 (交替生成)
    for(new j = 1; j < 21; j++){
        for(new k = 0; k < 2; k++){
            new i;
            if(k == 0){
                i = j;
                pTextDraw[i] = CreatePlayerTextDraw(playerid, 150.000000 + 15.0 * (i-1), 360.000000, "LD_POKE:cd1s");
            } else {
                i = j + 80;
                pTextDraw[i] = CreatePlayerTextDraw(playerid, 150.000000 + 15.0 * (i-81), 350.000000, "LD_POKE:cd1s");
            }
			PlayerTextDrawBackgroundColor(playerid, pTextDraw[i], 0);
			PlayerTextDrawFont(playerid, pTextDraw[i], 4);
			PlayerTextDrawLetterSize(playerid, pTextDraw[i], 0.500000, 1.000000);
			PlayerTextDrawColor(playerid, pTextDraw[i], -1);
			PlayerTextDrawSetOutline(playerid, pTextDraw[i], 0);
			PlayerTextDrawSetProportional(playerid, pTextDraw[i], 1);
			PlayerTextDrawSetShadow(playerid, pTextDraw[i], 1);
			PlayerTextDrawUseBox(playerid, pTextDraw[i], 1);
			PlayerTextDrawBoxColor(playerid, pTextDraw[i], 255);
			PlayerTextDrawTextSize(playerid, pTextDraw[i], 50.000000, 78.000000);
			PlayerTextDrawSetSelectable(playerid, pTextDraw[i], 1);
        }
    }
	// -- 上家的牌
	for(new i = 21; i < 41; i++){
	    pTextDraw[i]= CreatePlayerTextDraw(playerid, 25.000000, 160.000000 + 5.0 * (i-21), "LD_POKE:cdback");
		PlayerTextDrawBackgroundColor(playerid, pTextDraw[i], 0);
		PlayerTextDrawFont(playerid, pTextDraw[i], 4);
		PlayerTextDrawLetterSize(playerid, pTextDraw[i], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid, pTextDraw[i], -1);
		PlayerTextDrawSetOutline(playerid, pTextDraw[i], 0);
		PlayerTextDrawSetProportional(playerid, pTextDraw[i], 1);
		PlayerTextDrawSetShadow(playerid, pTextDraw[i], 1);
		PlayerTextDrawUseBox(playerid, pTextDraw[i], 1);
		PlayerTextDrawBoxColor(playerid, pTextDraw[i], 255);
		PlayerTextDrawTextSize(playerid, pTextDraw[i], 43.000000, 65.000000);
		PlayerTextDrawSetSelectable(playerid, pTextDraw[i], 0);
	}
	// -- 下家的牌
	for(new i = 41; i < 61; i++){
		pTextDraw[i] = CreatePlayerTextDraw(playerid, 573.000000, 160.000000 + 5.0 * (i-41), "LD_POKE:cdback");
		PlayerTextDrawBackgroundColor(playerid, pTextDraw[i], 0);
		PlayerTextDrawFont(playerid, pTextDraw[i], 4);
		PlayerTextDrawLetterSize(playerid, pTextDraw[i], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid, pTextDraw[i], -1);
		PlayerTextDrawSetOutline(playerid, pTextDraw[i], 0);
		PlayerTextDrawSetProportional(playerid, pTextDraw[i], 1);
		PlayerTextDrawSetShadow(playerid, pTextDraw[i], 1);
		PlayerTextDrawUseBox(playerid, pTextDraw[i], 1);
		PlayerTextDrawBoxColor(playerid, pTextDraw[i], 255);
		PlayerTextDrawTextSize(playerid, pTextDraw[i], 43.000000, 65.000000);
		PlayerTextDrawSetSelectable(playerid, pTextDraw[i], 0);
	}
	// -- 打出去的牌
	for(new i = 61; i < 81; i++){
		pTextDraw[i] = CreatePlayerTextDraw(playerid, 150.000000 + 15.0 * (i-61), 210.000000, "LD_POKE:cd1s");
		PlayerTextDrawBackgroundColor(playerid, pTextDraw[i], 0);
		PlayerTextDrawFont(playerid, pTextDraw[i], 4);
		PlayerTextDrawLetterSize(playerid, pTextDraw[i], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid, pTextDraw[i], -1);
		PlayerTextDrawSetOutline(playerid, pTextDraw[i], 0);
		PlayerTextDrawSetProportional(playerid, pTextDraw[i], 1);
		PlayerTextDrawSetShadow(playerid, pTextDraw[i], 1);
		PlayerTextDrawUseBox(playerid, pTextDraw[i], 1);
		PlayerTextDrawBoxColor(playerid, pTextDraw[i], 255);
		PlayerTextDrawTextSize(playerid, pTextDraw[i], 43.000000, 65.000000);
		PlayerTextDrawSetSelectable(playerid, pTextDraw[i], 0);
    }
    // -- 我的牌 (上面) 可选  81 ~ 100
    // -- 顶部赌注
	pTextDraw[101] = CreatePlayerTextDraw(playerid, 227.000000, 113.000000, "basic");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[101], 255);
	PlayerTextDrawFont(playerid, pTextDraw[101], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[101], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[101], -65281);
	PlayerTextDrawSetOutline(playerid, pTextDraw[101], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[101], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[101], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[101], 0);
	
	pTextDraw[102] = CreatePlayerTextDraw(playerid, 240.000000, 125.000000, "10000");
	PlayerTextDrawAlignment(playerid, pTextDraw[102], 2);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[102], 255);
	PlayerTextDrawFont(playerid, pTextDraw[102], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[102], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[102], -65281);
	PlayerTextDrawSetOutline(playerid, pTextDraw[102], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[102], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[102], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[102], 0);
	// -- 顶部倍数
	pTextDraw[103] = CreatePlayerTextDraw(playerid, 370.000000, 113.000000, "X3");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[103], 255);
	PlayerTextDrawFont(playerid, pTextDraw[103], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[103], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[103], -65281);
	PlayerTextDrawSetOutline(playerid, pTextDraw[103], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[103], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[103], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[103], 0);
	// -- 上家名称，金币和积分
	pTextDraw[104] = CreatePlayerTextDraw(playerid, 13.000000, 110.000000, "youkihira_souma");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[104], 255);
	PlayerTextDrawFont(playerid, pTextDraw[104], 1);
	PlayerTextDrawLetterSize(playerid, pTextDraw[104], 0.430000, 1.600000);
	PlayerTextDrawColor(playerid, pTextDraw[104], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[104], 1);
	PlayerTextDrawSetProportional(playerid, pTextDraw[104], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[104], 0);

	pTextDraw[105] = CreatePlayerTextDraw(playerid, 13.000000, 127.000000, "GOLD: 100");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[105], 255);
	PlayerTextDrawFont(playerid, pTextDraw[105], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[105], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[105], -65281);
	PlayerTextDrawSetOutline(playerid, pTextDraw[105], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[105], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[105], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[105], 0);

	pTextDraw[106] = CreatePlayerTextDraw(playerid, 13.000000, 137.000000, "score: 100");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[106], 255);
	PlayerTextDrawFont(playerid, pTextDraw[106], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[106], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[106], 16711935);
	PlayerTextDrawSetOutline(playerid, pTextDraw[106], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[106], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[106], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[106], 0);
	// -- 下家名称，金币和积分
	pTextDraw[107] = CreatePlayerTextDraw(playerid, 624.000000, 110.000000, "youkihira_souma");
	PlayerTextDrawAlignment(playerid, pTextDraw[107], 3);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[107], 255);
	PlayerTextDrawFont(playerid, pTextDraw[107], 1);
	PlayerTextDrawLetterSize(playerid, pTextDraw[107], 0.430000, 1.600000);
	PlayerTextDrawColor(playerid, pTextDraw[107], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[107], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[107], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[107], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[107], 0);

	pTextDraw[108] = CreatePlayerTextDraw(playerid, 623.000000, 127.000000, "GOLD: 100");
	PlayerTextDrawAlignment(playerid, pTextDraw[108], 3);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[108], 255);
	PlayerTextDrawFont(playerid, pTextDraw[108], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[108], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[108], -65281);
	PlayerTextDrawSetOutline(playerid, pTextDraw[108], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[108], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[108], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[108], 0);

	pTextDraw[109] = CreatePlayerTextDraw(playerid, 623.000000, 137.000000, "Score: 100");
	PlayerTextDrawAlignment(playerid, pTextDraw[109], 3);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[109], 255);
	PlayerTextDrawFont(playerid, pTextDraw[109], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[109], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[109], 16711935);
	PlayerTextDrawSetOutline(playerid, pTextDraw[109], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[109], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[109], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[109], 0);
	// -- 上家的 剩余牌数量 和 计时器
	pTextDraw[110] = CreatePlayerTextDraw(playerid, 6.000000, 227.000000, "(17)");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[110], 255);
	PlayerTextDrawFont(playerid, pTextDraw[110], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[110], 0.190000, 1.299999);
	PlayerTextDrawColor(playerid, pTextDraw[110], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[110], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[110], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[110], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[110], 0);

	pTextDraw[111] = CreatePlayerTextDraw(playerid, 85.000000, 223.000000, "32");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[111], 255);
	PlayerTextDrawFont(playerid, pTextDraw[111], 3);
	PlayerTextDrawLetterSize(playerid, pTextDraw[111], 0.430000, 2.099999);
	PlayerTextDrawColor(playerid, pTextDraw[111], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[111], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[111], 0);
	PlayerTextDrawSetShadow(playerid, pTextDraw[111], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[111], 0);
	// -- 下家的 剩余牌数量 和 计时器
	pTextDraw[112] = CreatePlayerTextDraw(playerid, 621.000000, 227.000000, "(17)");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[112], 255);
	PlayerTextDrawFont(playerid, pTextDraw[112], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[112], 0.190000, 1.299999);
	PlayerTextDrawColor(playerid, pTextDraw[112], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[112], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[112], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[112], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[112], 0);

	pTextDraw[113] = CreatePlayerTextDraw(playerid, 563.000000, 223.000000, "32");
	PlayerTextDrawAlignment(playerid, pTextDraw[113], 3);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[113], 255);
	PlayerTextDrawFont(playerid, pTextDraw[113], 3);
	PlayerTextDrawLetterSize(playerid, pTextDraw[113], 0.430000, 2.099999);
	PlayerTextDrawColor(playerid, pTextDraw[113], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[113], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[113], 0);
	PlayerTextDrawSetShadow(playerid, pTextDraw[113], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[113], 0);
	// -- 自己的金币和积分情况
	pTextDraw[114] = CreatePlayerTextDraw(playerid, 633.000000, 417.000000, "MY GOLD: 100");
	PlayerTextDrawAlignment(playerid, pTextDraw[114], 3);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[114], 255);
	PlayerTextDrawFont(playerid, pTextDraw[114], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[114], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[114], -65281);
	PlayerTextDrawSetOutline(playerid, pTextDraw[114], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[114], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[114], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[114], 0);

	pTextDraw[115] = CreatePlayerTextDraw(playerid, 633.000000, 428.000000, "MY SCORE: 100");
	PlayerTextDrawAlignment(playerid, pTextDraw[115], 3);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[115], 255);
	PlayerTextDrawFont(playerid, pTextDraw[115], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[115], 0.230000, 1.100000);
	PlayerTextDrawColor(playerid, pTextDraw[115], 16711935);
	PlayerTextDrawSetOutline(playerid, pTextDraw[115], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[115], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[115], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[115], 0);
	
	// -- 自己的 计时器
	pTextDraw[116] = CreatePlayerTextDraw(playerid, 307.000000, 293.000000, "22");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[116], 255);
	PlayerTextDrawFont(playerid, pTextDraw[116], 3);
	PlayerTextDrawLetterSize(playerid, pTextDraw[116], 0.430000, 2.099999);
	PlayerTextDrawColor(playerid, pTextDraw[116], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[116], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[116], 0);
	PlayerTextDrawSetShadow(playerid, pTextDraw[116], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[116], 0);
	// -- 自己的选项(可选)  (No - YES) 和 (No - Call)
	pTextDraw[117] = CreatePlayerTextDraw(playerid, 264.000000, 295.000000, "NO");
	PlayerTextDrawAlignment(playerid, pTextDraw[117], 2);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[117], 255);
	PlayerTextDrawFont(playerid, pTextDraw[117], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[117], 0.400000, 2.000000);
	PlayerTextDrawColor(playerid, pTextDraw[117], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[117], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[117], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[117], 1);
	PlayerTextDrawUseBox(playerid, pTextDraw[117], 1);
	PlayerTextDrawBoxColor(playerid, pTextDraw[117], -16776961);
	PlayerTextDrawTextSize(playerid, pTextDraw[117], 25.000000, 43.000000);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[117], 1);

	pTextDraw[118] = CreatePlayerTextDraw(playerid, 372.000000, 295.000000, "call");
	PlayerTextDrawAlignment(playerid, pTextDraw[118], 2);
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[118], 255);
	PlayerTextDrawFont(playerid, pTextDraw[118], 2);
	PlayerTextDrawLetterSize(playerid, pTextDraw[118], 0.400000, 2.000000);
	PlayerTextDrawColor(playerid, pTextDraw[118], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[118], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[118], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[118], 1);
	PlayerTextDrawUseBox(playerid, pTextDraw[118], 1);
	PlayerTextDrawBoxColor(playerid, pTextDraw[118], 16711935);
	PlayerTextDrawTextSize(playerid, pTextDraw[118], 16.000000, 53.000000);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[118], 1);
	// -- 地主的名字
	pTextDraw[119] = CreatePlayerTextDraw(playerid, 7.000000, 404.000000, "LandLord:");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[119], 255);
	PlayerTextDrawFont(playerid, pTextDraw[119], 1);
	PlayerTextDrawLetterSize(playerid, pTextDraw[119], 0.430000, 1.600000);
	PlayerTextDrawColor(playerid, pTextDraw[119], -16776961);
	PlayerTextDrawSetOutline(playerid, pTextDraw[119], 1);
	PlayerTextDrawSetProportional(playerid, pTextDraw[119], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[119], 0);

	pTextDraw[120] = CreatePlayerTextDraw(playerid, 7.000000, 421.000000, "Souma");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[120], 255);
	PlayerTextDrawFont(playerid, pTextDraw[120], 1);
	PlayerTextDrawLetterSize(playerid, pTextDraw[120], 0.280000, 1.399999);
	PlayerTextDrawColor(playerid, pTextDraw[120], -16776961);
	PlayerTextDrawSetOutline(playerid, pTextDraw[120], 1);
	PlayerTextDrawSetProportional(playerid, pTextDraw[120], 1);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[120], 0);
	
	// -- 顶上 三张底牌
	pTextDraw[121] = CreatePlayerTextDraw(playerid, 269.000000, 112.000000, "LD_POKE:cd3s");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[121], 0);
	PlayerTextDrawFont(playerid, pTextDraw[121], 4);
	PlayerTextDrawLetterSize(playerid, pTextDraw[121], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, pTextDraw[121], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[121], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[121], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[121], 1);
	PlayerTextDrawUseBox(playerid, pTextDraw[121], 1);
	PlayerTextDrawBoxColor(playerid, pTextDraw[121], 255);
	PlayerTextDrawTextSize(playerid, pTextDraw[121], 29.000000, 43.000000);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[121], 0);

	pTextDraw[122] = CreatePlayerTextDraw(playerid, 300.000000, 112.000000, "LD_POKE:cd4s");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[122], 0);
	PlayerTextDrawFont(playerid, pTextDraw[122], 4);
	PlayerTextDrawLetterSize(playerid, pTextDraw[122], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, pTextDraw[122], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[122], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[122], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[122], 1);
	PlayerTextDrawUseBox(playerid, pTextDraw[122], 1);
	PlayerTextDrawBoxColor(playerid, pTextDraw[122], 255);
	PlayerTextDrawTextSize(playerid, pTextDraw[122], 29.000000, 43.000000);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[122], 0);

	pTextDraw[123] = CreatePlayerTextDraw(playerid, 331.000000, 112.000000, "LD_POKE:cd5s");
	PlayerTextDrawBackgroundColor(playerid, pTextDraw[123], 0);
	PlayerTextDrawFont(playerid, pTextDraw[123], 4);
	PlayerTextDrawLetterSize(playerid, pTextDraw[123], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, pTextDraw[123], -1);
	PlayerTextDrawSetOutline(playerid, pTextDraw[123], 0);
	PlayerTextDrawSetProportional(playerid, pTextDraw[123], 1);
	PlayerTextDrawSetShadow(playerid, pTextDraw[123], 1);
	PlayerTextDrawUseBox(playerid, pTextDraw[123], 1);
	PlayerTextDrawBoxColor(playerid, pTextDraw[123], 255);
	PlayerTextDrawTextSize(playerid, pTextDraw[123], 29.000000, 43.000000);
	PlayerTextDrawSetSelectable(playerid, pTextDraw[123], 0);
}

public Player::textdrawShow(playerid, PlayerText:text){
	for(new i = 0; i < MAX_PLAYER_TEXT_VIEW; i++){
	    if(pTextDraw[i] == text){
	        if(Player[playerid][pIsTxdShowing][i] == 0){
	            PlayerTextDrawShow(playerid, text);
	            Player[playerid][pIsTxdShowing][i] = 1;
	        }
	        break;
	    }
	}
}

public Player::textdrawHide(playerid, PlayerText:text){
    for(new i = 0; i < MAX_PLAYER_TEXT_VIEW; i++){
	    if(pTextDraw[i] == text){
	        if(Player[playerid][pIsTxdShowing][i] == 1){
	            PlayerTextDrawHide(playerid, text);
	            Player[playerid][pIsTxdShowing][i] = 0;
	        }
	        break;
	    }
	}
}
