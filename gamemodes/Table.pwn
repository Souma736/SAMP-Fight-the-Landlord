#define MAX_TABLES 100
#define MAX_PLAYER_CARDS 20
#define MAX_CARDS 54

#define STATUS_JUST_START 0 	//刚开局
#define STATUS_DEAL 1 		//开始发牌
#define STATUS_SHOW_HIDDEN_CARDS 2 //亮 三张底牌
#define STATUS_CALL_LORD 3 //叫地主阶段
#define STATUS_PLAY 4 //出牌阶段

#define TYPE_WRONG      -1//错误的类型
#define TYPE_SOLO 		0 //单张
#define TYPE_PAIR 		1 //对子 (1对，3连对，4连对...)
#define TYPE_TRIPLE     2 //三张 (3带1, 3带一对,  2*3+1+1  2*3+2 3*3+1+1+1, 3*3+2+1 ...
#define TYPE_QUAD       4 //四张 (炸弹， 4带2 (1+1, 2))
#define TYPE_STRAIGHT   5 //顺子 (5, 6, 7 ...)
#define TYPE_BOOM       6 //王炸



#define TIME_CALL_LORD 20*10 // 叫地主 20 s
#define TIME_PLAY 30*10 //正常游玩

enum tableinfo{
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

// -- API
forward Table::OnGameModeInit();

public Table::OnGameModeInit(){
	Table::loadObjects();

}

forward Table::loadObjects();
forward Table::create(Float:org_pos[3], Float:actor_pos[3], Float:seatpos[3][3], Float:angle);
forward Table::getTableAndSeatByPlayer(playerid, &table, &seat);
forward Table::onPlayerJoin(playerid, table, seat);
forward Table::onPlayerUnjoin(playerid, table, seat);
forward Table::onStartCheck(table);
forward Table::startGame(table);
forward Table::isStarted(table);
forward Table::onPlayerLeave(playerid, table, seat);
forward Table::onNpcJoin(robot, name[], table, seat);
forward Table::updateSeatLabel(table, seat, color, name[]);
forward Table::updateTableLabel(table);
forward Table::getSeatPosAndAngle(table, seat, Float:pos[], &Float:angle);
forward Table::gameHandler(table); // 0.1s 一次
forward Table::getCardFontNameByValue(value, name[]);
forward Table::sort(cards[], size, order);
forward Table::getCards(const cards[]);
forward Table::getPrevSeatID(seat);
forward Table::getNextSeatID(seat);
forward Table::onPlayerClick(table, seat, which);
forward Table::onPlayerShiftCard(playerid, table, seat, card_id);
forward Table::showTimeLeftToOthers(table);
forward Table::initCards(table);
forward Table::updateAllPlayerCardTxd(table);

public Table::loadObjects(){
	CreateObject(11690, -3.70, 1517.29, 11.70,   0.00, 0.00, 30.00);
	CreateObject(11690, -3.12, 1506.11, 11.70,   0.00, 0.00, 45.00);
	CreateObject(11690, -0.40, 1512.39, 11.70,   0.00, 0.00, -60.00);
	for(new i= 0; i < MAX_OBJECTS; i++){
	    if(GetObjectModel(i) == 11690){
			//距离为1.1
			new Float:dis = 1.1;
	        new Float:pos[3], Float:angle, Float:ver_angle, Float:actor_pos[3], Float:seat_pos[3][3], Float:none;
			GetObjectPos(i, pos[0], pos[1], pos[2]);
			GetObjectRot(i, none, none, angle);
			ver_angle = angle + 90.0;
			actor_pos[0] = pos[0] + dis * floatcos(angle, degrees);
			actor_pos[1] = pos[1] + dis * floatsin(angle, degrees);
			actor_pos[2] = pos[2] + dis;
			seat_pos[0][0] = pos[0] + dis * floatcos(ver_angle, degrees);
			seat_pos[0][1] = pos[1] + dis * floatsin(ver_angle, degrees);
			seat_pos[0][2] = pos[2] + 0.5;
			seat_pos[1][0] = pos[0] - dis * floatcos(angle, degrees);
			seat_pos[1][1] = pos[1] - dis * floatsin(angle, degrees);
			seat_pos[1][2] = pos[2] + 0.5;
			seat_pos[2][0] = pos[0] - dis * floatcos(ver_angle, degrees);
			seat_pos[2][1] = pos[1] - dis * floatsin(ver_angle, degrees);
			seat_pos[2][2] = pos[2] + 0.5;
			Table::create(pos, actor_pos, seat_pos, angle);
	    }
	}
}

public Table::create(Float:org_pos[3], Float:actor_pos[3], Float:seatpos[3][3], Float:angle){

	CreateActor(26, actor_pos[0], actor_pos[1], actor_pos[2], angle+90.0);
	for(new i = 0; i < 3; i++){
	    for(new u = 0; u < 3; u++){
	        TableSeatPos[tableid][i][u] = seatpos[i][u];
	    }
	    new seat_name[32];
	    format(seat_name, sizeof seat_name, "%d号座", i+1);
	    Table[tableid][tSeatPlayerIds][i] = -1;
	    Table[tableid][tStarted] = 0;
	    Table[tableid][tTimer] = -1;
	    Table[tableid][tAngle] = angle + 90.0;
	    Table[tableid][tLabels][i] = Create3DTextLabel(seat_name, -1, seatpos[i][0], seatpos[i][1], seatpos[i][2], 5.0, 0);
	}
	new table_name[16];
	format(table_name, sizeof table_name, "%d号桌", tableid+1);
	Table[tableid][tMainLabel] =  Create3DTextLabel(table_name, -1, org_pos[0], org_pos[1], org_pos[2]+0.5, 10.0, 0);
	tableid++;
}

public Table::getTableAndSeatByPlayer(playerid, &table, &seat){
	for(new i = 0; i < tableid; i++){
		for(new u = 0; u < 3; u++){
		    if(Table[i][tStarted] == 0 && IsPlayerInRangeOfPoint(playerid, 1.0, TableSeatPos[i][u][0], TableSeatPos[i][u][1], TableSeatPos[i][u][2])){
		        table = i;
		        seat = u;
		        return;
		    }
		}
	}
	table = -1;
	seat = 0;
}

public Table::onPlayerJoin(playerid, table, seat){
	Table::updateSeatLabel(table, seat, -1, Player[playerid][pName]);
	Table[table][tSeatPlayerIds][seat] = playerid;
	format(TablePlayerNames[table][seat], MAX_PLAYER_NAME, Player[playerid][pName]);
	Table::onStartCheck(table);
}

public Table::onPlayerUnjoin(playerid, table, seat){
    Table::updateSeatLabel(table, seat, -1, " ");
  	Table[table][tSeatPlayerIds][seat] = -1;
  	format(TablePlayerNames[table][seat], 1, " ");
}

public Table::onStartCheck(table){
	new counts = 0;
	for(new i = 0; i < 3; i++){
	    if(Table[table][tSeatPlayerIds][i] != -1)
	        counts++;
	}
	if(counts == 3){
	    Table::startGame(table);
	}
}

public Table::startGame(table){
	Table[table][tStarted] = 1;
	//TODO 以后设置可变金额
	Table[table][tBasicGold] = 10;
	Table[table][tTimes] = 1;
	Table[table][tStatus] = STATUS_JUST_START;
	Table[table][tTimeCount] = 10;// 1秒钟后开局
	Table::updateTableLabel(table);
	for(new i = 0; i < 3; i++){
	    // 如果这个人离线了, 就托管
	    if(Table[table][tSeatPlayerIds][i] == -1){
	        Table[table][tGuard][i] = 1;
	    } else {
	        // 如果这个人不是电脑，显示 txd, 并初始化托管
	        if(!Robot::isRobot(Table[table][tSeatPlayerIds][i])){
	            Table[table][tGuard][i] = 0;
	            new prev = Table::getPrevSeatID(i);
	            new next = Table::getNextSeatID(i);
	            Player::showBasicTableTxd(Table[table][tSeatPlayerIds][i], Table[table][tSeatPlayerIds][prev], Table[table][tSeatPlayerIds][next], Table[table][tBasicGold], Table[table][tTimes]);
				new Float:pos[3];
				GetPlayerPos(Table[table][tSeatPlayerIds][i], pos[0], pos[1], pos[2]);
				SetPlayerCameraPos(Table[table][tSeatPlayerIds][i], pos[0], pos[1], pos[2] + 5.0);
				SetPlayerCameraLookAt(Table[table][tSeatPlayerIds][i], pos[0], pos[1], pos[2] + 6.0, CAMERA_MOVE);
	        } else {
	        // 是机器人就 托管
	            Table[table][tGuard][i] = 1;
	        }
	    }
	}
	Table[table][tTimer] = SetTimerEx("Table_gameHandler", 100, true, "d", table);
}

public Table::onPlayerLeave(playerid, table, seat){
	if(Table[table][tStarted] == 1){
	    // TODO 玩家、托管、挂机
	    Table[table][tSeatPlayerIds][seat] = -1;
	    Table[table][tGuard][seat] = 1;
	} else {
		Table::onPlayerUnjoin(playerid, table, seat);
	}
}

public Table::onNpcJoin(robot, name[], table, seat){
	if(table >= 0 && table < tableid){
	    if(Table[table][tSeatPlayerIds][seat] == -1){
	        Table[table][tSeatPlayerIds][seat] = MAX_PLAYERS + robot;
	        format(TablePlayerNames[table][seat], MAX_PLAYER_NAME, name);
	        Table::updateSeatLabel(table, seat, -1, name);
	        Table::onStartCheck(table);
	        return true;
	    }
	}
	return false;
}

public Table::updateSeatLabel(table, seat, color, name[]){
    new string[128];
    if(strlen(name) <= 1){
        format(string, sizeof string, "%d号座", seat+1);
    } else {
        format(string, sizeof string, "%d号座\n((%s))", seat+1, name);
    }
 	Update3DTextLabelText(Table[table][tLabels][seat], -1, string);
}

public Table::getSeatPosAndAngle(table, seat, Float:pos[], &Float:angle){
	for(new i = 0; i < 3; i++){
	    pos[i] = TableSeatPos[table][seat][i];
	}
	angle = Table[table][tAngle] + seat * 90.0;
}

public Table::updateTableLabel(table){
	new string[128];
	if(Table[table][tStarted] == 0){
	    format(string, sizeof string, "%d号桌", table+1);
	} else {
	    format(string, sizeof string, "%d号桌\n((已开始))", table+1);
	}
	Update3DTextLabelText(Table[table][tMainLabel], -1, string);
}

public Table::isStarted(table){
	return(Table[table][tStarted] == 1);
}

public Table::getCardFontNameByValue(value, name[]){
	new level = (value-1) / 4;
	new type = (value-1) % 4;
	if(level < 13){
	    //不是王的情况
	    new fixed_value = (level < 11) ? level+3 : level-10;
	    new type_char;
	    switch(type){
	        case 0:type_char = 'h';
	        case 1:type_char = 'd';
	        case 2:type_char = 's';
	        case 3:type_char = 'c';
	    }
	    format(name, 32, "LD_CARD:cd%d%c", fixed_value, type_char);
	} else {
        //是大小王
	    if(type == 0){
	        format(name, 32, "LD_DUAL:power");
	    } else {
	        format(name, 32, "LD_DUAL:health");
	    }
	    
	}
}

Table::getCardRealName(value, name[]){
	new level = (value-1) / 4;
	new type = (value-1) % 4;
	if(level < 13){
	    level = (level < 11) ? level+3 : level-10; // A - K
	    if(level < 11){
	    	format(name, 16, "%d", level);
		} else if(level == 11){
		    format(name, 16, "J");
		} else if(level == 12){
		    format(name, 16, "Q");
		} else if(level == 13){
		    format(name, 16, "K");
		}
	} else {
	    if(type == 0){
	        format(name, 16, "小王");
	    } else {
	        format(name, 16, "大王");
	    }
	}
}

// 核心流程
public Table::gameHandler(table){
	if(Table[table][tTimeCount] > 0){
	    Table[table][tTimeCount]--;
	} 
    switch(Table[table][tStatus]){
    	case STATUS_JUST_START:{
    	    if(Table[table][tTimeCount] == 0){
	    	    // -- 清空所有玩家的牌, 选中的牌,玩家选择状态,以及洗好牌
	    	    Table::initCards(table);
				// -- 开始发牌
				Table[table][tTimeCount] = 17; //每人17张牌
				Table[table][tStatus] = STATUS_DEAL;
    	    }
	 	}
	 	case STATUS_DEAL:{
	 	    // 发牌阶段  timecount 从 16 ~ 0
	 	    new slotid = 16 - Table[table][tTimeCount]; // 范围 0 - 16
	 	    // 给玩家发牌
			for(new i = 0; i < 3; i++){
			    TablePlayerCards[table][i][slotid] = Table[table][tCards][slotid*3+i];
                // 如果对象是玩家，则及时更新UI
				new player = Table[table][tSeatPlayerIds][i];
				if(player != -1 && !Robot::isRobot(player)){
				    Player::updateCardTxd(player, TablePlayerCards[table][i], TablePlayerCardsSelected[table][i], {0}, 0, slotid+1, slotid+1, slotid+1);
				}
			}
			// 亮底牌
			if(Table[table][tTimeCount] == 0){
			    Table[table][tTimeCount] = 5;
			    Table[table][tStatus] = STATUS_SHOW_HIDDEN_CARDS;
			}
	 	}
	 	case STATUS_SHOW_HIDDEN_CARDS:{
	 	    if(Table[table][tTimeCount] == 0){
	 	        new hidden_cards[3];
		 	    for(new i = 0; i < 3; i++){
		 	        hidden_cards[i] = Table[table][tCards][MAX_CARDS+i-3];
		 	    }
		 	    Table::sort(hidden_cards, 3, ORDER_NORMAL);
	            for(new i = 0; i < 3; i++){
	                // 对所有人的牌进行排序
					Table::sort(TablePlayerCards[table][i], 17, ORDER_NORMAL);
	                // 如果对象是玩家，则及时更新UI ， 并允许选择
					new player = Table[table][tSeatPlayerIds][i];
					if(player != -1 && !Robot::isRobot(player)){
					    Player::updateCardTxd(player, TablePlayerCards[table][i], TablePlayerCardsSelected[table][i], {0}, 0, 17, 17, 17);
					    Player::updateHiddenCardTxd(player, hidden_cards);
					    SelectTextDraw(player, -1);
					}
				}
				// 随机选取某个人开始叫地主
				Table[table][tCalled] = 0;
				Table[table][tLord] = -1;
				Table[table][tRespond] = 0;
				Table[table][tCurrentPlayer] = random(3);
				Table[table][tTimeCount] = TIME_CALL_LORD;
				Table[table][tLordCallCoolTime] = 15;
				Table[table][tStatus] = STATUS_CALL_LORD;
	 	    }
	 	}
	 	case STATUS_CALL_LORD:{
	 	    if(Table[table][tRespond] == 0){
	            // 如果是玩家在选地主，则给他显示按钮和时间
	 	    	new player = Table[table][tSeatPlayerIds][Table[table][tCurrentPlayer]];

				if(player != -1 && !Robot::isRobot(player)){
				    Player::showButton(player, Table[table][tTimeCount]/10, "NO", "CALL");
				} else {
				// 如果是离线玩家或机器在选 则 3s 后自动不随机叫
				    if(Table[table][tTimeCount] == TIME_CALL_LORD - 30){
	                    Table[table][tRespond] = 1;
	                    Table[table][tLordRefreshed] = random(2);//TODO 修改
	                    if(Table[table][tLordRefreshed] == 1){
	                        Table[table][tLord] = Table[table][tCurrentPlayer];
	                    }
				    }
				}
				// 给其他玩家显示他的剩余时间
				Table::showTimeLeftToOthers(table);
				// 已经回应叫地主 或 时间到了 自动回应
				if(Table[table][tTimeCount] == 0){
	                Table[table][tLordRefreshed] = 0;
	                Table[table][tRespond] = 1;
				}
			}
			// 已经回应叫地主
			else if(Table[table][tRespond] == 1){
			    if(Table[table][tLordCallCoolTime] == 0){
			        // 结果显示完了跳回来
			        Table[table][tLordCallCoolTime] = 15;
			        Table[table][tRespond] = 0;
				    Table[table][tCalled]++;
				    if(Table[table][tCalled] >= 3){
				        // 当地主叫完了一轮
				        if(Table[table][tLord] == -1){
				            //如果还没人叫地主 就重新开始
				            KillTimer(Table[table][tTimer]);
				            Table::startGame(table);
				        } else {
					        // 给地主发牌
					        for(new i = 0; i < 3; i++){
					            TablePlayerCards[table][Table[table][tLord]][i+17] = Table[table][tCards][i+51];
					        }
					        // 排好顺序
					        Table::sort(TablePlayerCards[table][Table[table][tLord]], 20, ORDER_NORMAL);
					        // (STATUS_PLAY 才允许玩家点击牌)
					        // 显示地主名称，并更新牌数, 并隐藏时间
                			Table::updateAllPlayerCardTxd(table);
                			for(new i = 0; i < 3; i++){
								new player = Table[table][tSeatPlayerIds][i];
								if(player != -1 && !Robot::isRobot(player)){
								    Player::hideTime(player);
								    Player::showLordName(player, TablePlayerNames[table][Table[table][tLord]]);
								}
							}
							Table[table][tLastType] = 0;
							Table[table][tLastTypeDetail] = 0;
							Table[table][tLastTypeLevel] = 0;
							Table[table][tCalled] = 0;
							Table[table][tFirstHand] = 1;
							Table[table][tRespond] = 0;
							// 开始出牌
							Table[table][tCurrentPlayer] = Table[table][tLord];
							Table[table][tTimeCount] = TIME_PLAY;
							Table[table][tStatus] = STATUS_PLAY;
				        }
				    } else {
				        // 取消上一个人的按钮，隐藏时间，并让下一个人叫地主
				        Table[table][tTimeCount] = TIME_CALL_LORD;
				        for(new i = 0; i < 3; i++){
							new player = Table[table][tSeatPlayerIds][i];
							if(player != -1 && !Robot::isRobot(player)){
							    Player::hideButton(player);
							    Player::hideTime(player);
							}
				        }
				        Table[table][tCurrentPlayer] = Table::getNextSeatID(Table[table][tCurrentPlayer]);
				    }
			    } else {
			        Table[table][tLordCallCoolTime]--;
			        for(new i = 0; i < 3; i++){
						new player = Table[table][tSeatPlayerIds][i];
						if(player != -1 && !Robot::isRobot(player)){
						    Player::hideButton(player);
						    Player::hideTime(player);
						    if(Table[table][tCurrentPlayer] == Table::getPrevSeatID(i)){
						    	Player::showCallResult(player, SEAT_PREV, Table[table][tLordRefreshed]);
							} else if(Table[table][tCurrentPlayer] == Table::getNextSeatID(i)){
						        Player::showCallResult(player, SEAT_NEXT, Table[table][tLordRefreshed]);
						    } else {
						        Player::showCallResult(player, SEAT_SELF, Table[table][tLordRefreshed]);
						    }
						}
					}
			    }
			}
	 	}
	 	case STATUS_PLAY:{
	 	    if(Table[table][tRespond] == 0){
	            // 如果是玩家在选牌
	 	    	new player = Table[table][tSeatPlayerIds][Table[table][tCurrentPlayer]];
				if(Table[table][tGuard][Table[table][tCurrentPlayer]] == 0){
				    // 如果未托管
				    Player::showButton(player, Table[table][tTimeCount]/10, "NO", "GO");
				} else {
					// 如果是离线玩家或机器，在托管状态
					new seat = Table[table][tCurrentPlayer];
					if(Table[table][tFirstHand] == 0){
					    //如果是接牌侠,5秒钟寻找解
					    if(Table[table][tTimeCount] == TIME_PLAY - 50){
					    
					    } else {
					        for(new i = 0; i < 100; i++){
						        new outputArray[MAX_PLAYER_CARDS];
						        new outputSize = 0;
						        //
							    if(Logic::getSolution(TablePlayerCards[table][seat], Table::getCards(TablePlayerCards[table][seat]), Table[table][tLastCardSize],
								Table[table][tLastType], Table[table][tLastTypeDetail], Table[table][tLastLevel], 0, outputArray, outputSize){

								    Table::onPlayerPlayCards(table, seat, temp_card_ids, temp_cards, endid);
									break;
								}
						    }
					    }
					} else {
					    //如果是自己随意出
					    new endid = 0;
					    new temp_card_ids[4], temp_cards[4];
					    for(new i = 0; i < 3; i++){
					        if(TablePlayerCards[table][seat][i] != TablePlayerCards[table][seat][i+1]){
					            endid = i;
					            break;
							}
					    }
					    for(new i = 0; i < endid; i++){
					        temp_card_ids[i] = i;
					        temp_cards[i] = TablePlayerCards[table][seat][i];
					    }
                        Table::onPlayerPlayCards(table, seat, temp_card_ids, temp_cards, endid);
					}
				    
				}
				// 给其他玩家显示他的剩余时间
				Table::showTimeLeftToOthers(table);
				
				// 时间到了 自动回应
				if(Table[table][tTimeCount] == 0){
	                Table[table][tRespond] = 1;
				}
			} else {
			    // 当事件得到回应
			    
			}
	 	}
 	}
}

public Table::sort(cards[], size, order){
	for(new i = 0; i < size-1; i++){
        for(new j = 0; j < size-1-i; j++) {
            if ( (order == ORDER_NORMAL && cards[j] > cards[j+1]) || (order == ORDER_DESC && cards[j] < cards[j+1]) ) {
                new temp = cards[j];
                cards[j] = cards[j+1];
                cards[j+1] = temp;
            } 
        }
	}
}

public Table::getCards(const cards[]){
	new counts = 0;
	for(new i = 0; i < MAX_PLAYER_CARDS; i++){
	    if(cards[i] > 0)
	        counts++;
	}
	return counts;
}

public Table::getPrevSeatID(seat){
	return (seat-1) >= 0 ? (seat-1) : 2;
}

public Table::getNextSeatID(seat){
	return ((seat+1) <= 2) ? seat+1 : 0;
}

public Table::onPlayerClick(table, seat, which){
	if(Table[table][tStarted] == 0)return 1;
	if(Table[table][tStatus] == STATUS_CALL_LORD){
	    //如果玩家在选地主时进行了点击
	    if(Table[table][tCurrentPlayer] != seat)return printf("错误!Table OnPlayerClick (seat != currentSeat)");
	    if(which == CLICK_YES){
	        //玩家叫了地主
	        Table[table][tLord] = seat;
	        Table[table][tLordRefreshed] = 1;
	    } else {
	        Table[table][tLordRefreshed] = 0;
	    }
	    // 回应 Handler
     	Table[table][tRespond] = 1;
	} else if(Table[table][tStatus] == STATUS_PLAY){
		//玩家在出牌阶段
		new temp_card_ids[MAX_PLAYER_CARDS];
		new temp_cards[MAX_PLAYER_CARDS];
		new temp_card_size = 0;
		for(new i = 0; i < MAX_PLAYER_CARDS; i++){
		    if(TablePlayerCardsSelected[table][seat][i] == 1){
		        //如果该牌被选中则，跳出来
		        temp_card_ids[temp_card_size] = i;
		        temp_cards[temp_card_size] = TablePlayerCards[table][seat][i];
		    }
		}
		if(temp_card_size > 0){
		    new type, detail, level;
			Logic::determineCardInfo(temp_cards, temp_card_size, type, detail, level);
			if(Table[table][tFirstHand] == 1){
			    //如果是自己第一手出牌
			    if(type != TYPE_WRONG){
			        //该牌可以出
			        Table::onPlayerPlayCards(table, seat, temp_card_ids, temp_cards, temp_card_size);
			    } else {
			        ShowPlayerDialog(playerid, DIALOG_NO_RESPONSE, DIALOG_STYLE_MSGBOX, "错误”, "该出牌方式错误", "关闭", "");
			    }
			} else {
			    //如果是压牌
			    if(Logic::isGreater(type, detail, level, Table[table][tLastType], Table[table][tLastTypeDetail], Table[table][tLastTypeLevel])){
			        //该牌可以出
			        Table::onPlayerPlayCards(table, seat, temp_card_ids, temp_cards, temp_card_size);
			    }
			}
		}
	}
	return 1;
}

public Table::onPlayerShiftCard(playerid, table, seat, card_id){
	if(Table[table][tStatus] != STATUS_PLAY)return ; // 非出牌阶段禁止点击牌
    if(TablePlayerCardsSelected[table][seat][card_id] == 1){
     	//如果在上面，移下来，更新自己的牌
        TablePlayerCardsSelected[table][seat][card_id] = 0;
    } else {
        //如果在下面，移上来，更新自己的牌
        TablePlayerCardsSelected[table][seat][card_id] = 1;
    }
	
    Player::updateCardTxd(playerid, TablePlayerCards[table][seat], TablePlayerCardsSelected[table][seat],
    Table::getCards(TablePlayerCards[table][seat]), Table[table][tLastCards], Table[table][tLastCardSize],
    Table::getCards(TablePlayerCards[table][Table::getPrevSeatID(seat)]),
	Table::getCards(TablePlayerCards[table][Table::getNextSeatID(seat)]));
	return ;
}

public Table::showTimeLeftToOthers(table){
    for(new i = 0; i < 3; i++){
	    if(i != Table[table][tCurrentPlayer]){
		    new other_player = Table[table][tSeatPlayerIds][i];
			if(other_player != -1 && !Robot::isRobot(other_player)){
			    if(Table[table][tCurrentPlayer] == Table::getPrevSeatID(i)){
			        Player::showTime(other_player, SEAT_PREV, Table[table][tTimeCount]/10);
			    } else {
			        Player::showTime(other_player, SEAT_NEXT, Table[table][tTimeCount]/10);
			    }
			}
	    }
	}
}

public Table::initCards(table){
    for(new i = 0; i < 3; i++){
 		for(new u = 0; u < MAX_PLAYER_CARDS; u++){
 			TablePlayerCards[table][i][u] = 0;
 		}
	}
	// -- 清空所有玩家的牌
	for(new i = 0; i < 3; i++){
 		for(new u = 0; u < MAX_PLAYER_CARDS; u++){
 			TablePlayerCardsSelected[table][i][u] = 0;
 		}
	}
	// -- 取消玩家选择状态
	for(new i = 0; i < 3; i++){
		new player = Table[table][tSeatPlayerIds][i];
		if(player != -1 && !Robot::isRobot(player)){
	    	CancelSelectTextDraw(player);
		}
	}
	// -- 创建一副有顺序的牌，并且初始化出过的牌
	new temp_cards[MAX_CARDS];
	for(new i = 0; i < MAX_CARDS; i++){
		temp_cards[i] = i+1;
		Table[table][tLastCards][i] = 0;
	}
	Table[table][tLastCardSize] = 0;
	// -- 随机抽取此牌到桌牌中
	for(new i = 0; i < MAX_CARDS; i++){
 		if(i == MAX_CARDS - 1){
			// 最后一次抽牌
			Table[table][tCards][i] = temp_cards[0];
		} else {
 			//正常抽牌
			new random_id = random(MAX_CARDS-i);
			Table[table][tCards][i] = temp_cards[random_id];
			if(random_id != MAX_CARDS-i-1)
				temp_cards[random_id] = temp_cards[MAX_CARDS-i-1];
		}
	}
}

public Table::updateAllPlayerCardTxd(table){
	for(new i = 0; i < 3; i++){
		new player = Table[table][tSeatPlayerIds][i];
		if(player != -1 && !Robot::isRobot(player)){
		    Player::updateCardTxd(player, TablePlayerCards[table][i],
			TablePlayerCardsSelected[table][i], Table::getCards(TablePlayerCards[table][i]),
			Table[table][tLastCards], Table[table][tLastCardSize],
			Table::getCards(TablePlayerCards[table][Table::getPrevSeatID(i)]),
			Table::getCards(TablePlayerCards[table][Table::getNextSeatID(i)]));
		}
	}
}

public Table::onPlayerPlayCards(table, seat, const card_ids[], const cards[], card_size){
	if(seat == Table[table][tCurrentPlayer]){
	    // 先删除玩家手中的牌，并添加到 打出去的牌中
	    for(new i = 0; i < card_size; i++){
	        TablePlayerCards[table][seat][card_ids[i]] = 0;
	        TablePlayerCardsSelected[table][seat][card_ids[i]] = 0;
	        Table[tLastCards][i] = cards[i];
	    }
	    Table[table][tLastCardSize] = card_size;
	    // 更新所有玩家的牌UI
	    for(new i = 0; i < 3; i++){
	        new player = Table[table][tSeatPlayerIds][i];
	        if(player != -1 && !Robot::isRobot(player)){
	            //更新UI，隐藏玩家button
	            Player::hideButton(player);
				Player::hideTime(player);'
	        }
	    }
	    Table::updateAllPlayerCardTxd(table);
	    Table[table][tRespond] = 1;
	}
}
