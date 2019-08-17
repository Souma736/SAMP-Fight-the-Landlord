#define MAX_TABLES 100
#define MAX_PLAYER_CARDS 20
#define MAX_CARDS 54

#define STATUS_JUST_START 0 	//�տ���
#define STATUS_DEAL 1 		//��ʼ����
#define STATUS_SHOW_HIDDEN_CARDS 2 //�� ���ŵ���
#define STATUS_CALL_LORD 3 //�е����׶�
#define STATUS_PLAY 4 //���ƽ׶�

#define TYPE_WRONG      -1//���������
#define TYPE_SOLO 		0 //����
#define TYPE_PAIR 		1 //���� (1�ԣ�3���ԣ�4����...)
#define TYPE_TRIPLE     2 //���� (3��1, 3��һ��,  2*3+1+1  2*3+2 3*3+1+1+1, 3*3+2+1 ...
#define TYPE_QUAD       4 //���� (ը���� 4��2 (1+1, 2))
#define TYPE_STRAIGHT   5 //˳�� (5, 6, 7 ...)
#define TYPE_BOOM       6 //��ը



#define TIME_CALL_LORD 20*10 // �е��� 20 s
#define TIME_PLAY 30*10 //��������

enum tableinfo{
	Text3D:tLabels[3],
	Text3D:tMainLabel,
	tSeatPlayerIds[3],
	tStarted,
	Float:tAngle,
	tGuard[3], // �й�
	tGuardTimer[3], // �й����ļ�ʱ��
	tTimer,
	tBasicGold, //������
	tTimes, //����
	tStatus, // ״̬
	tTimeCount, // Handler������
	tCards[MAX_CARDS],
	tCalled, // �ֵĴ���
	tLordRefreshed, // ������Ŀǰ����ҽ���
	tLord, // ���� ID (0, 1, 2)  
	tRespond, // �Ƿ�����һ�Ӧ
	tLordCallCoolTime, //��ʾ����ȴ�ʱ��
	tCurrentPlayer, // ��ǰ�Ĳ�����
	
	// --- ��ǰ���Ƶı���
	tFirstHand, // �Ƿ�Ϊ��һ��������
	tLastCards[MAX_PLAYER_CARDS], // ��¼��һ�γ��Ƶ�����
	tLastCardSize,
	tLastType, //��¼��һ�γ��Ƶ�����
	tLastTypeDetail, //��һ�γ������͵ľ������ �� 3��1 3��2
	tLastTypeLevel, //��¼��һ�γ������Ͷ�Ӧ�ĵȼ�(�ߵȼ�ѹ�͵ȼ�)

	
	//Cards ֵ˵��
	/*
		���� 	���� 	���� 	÷��
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
    ��  53 		54
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
forward Table::gameHandler(table); // 0.1s һ��
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
			//����Ϊ1.1
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
	    format(seat_name, sizeof seat_name, "%d����", i+1);
	    Table[tableid][tSeatPlayerIds][i] = -1;
	    Table[tableid][tStarted] = 0;
	    Table[tableid][tTimer] = -1;
	    Table[tableid][tAngle] = angle + 90.0;
	    Table[tableid][tLabels][i] = Create3DTextLabel(seat_name, -1, seatpos[i][0], seatpos[i][1], seatpos[i][2], 5.0, 0);
	}
	new table_name[16];
	format(table_name, sizeof table_name, "%d����", tableid+1);
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
	//TODO �Ժ����ÿɱ���
	Table[table][tBasicGold] = 10;
	Table[table][tTimes] = 1;
	Table[table][tStatus] = STATUS_JUST_START;
	Table[table][tTimeCount] = 10;// 1���Ӻ󿪾�
	Table::updateTableLabel(table);
	for(new i = 0; i < 3; i++){
	    // ��������������, ���й�
	    if(Table[table][tSeatPlayerIds][i] == -1){
	        Table[table][tGuard][i] = 1;
	    } else {
	        // �������˲��ǵ��ԣ���ʾ txd, ����ʼ���й�
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
	        // �ǻ����˾� �й�
	            Table[table][tGuard][i] = 1;
	        }
	    }
	}
	Table[table][tTimer] = SetTimerEx("Table_gameHandler", 100, true, "d", table);
}

public Table::onPlayerLeave(playerid, table, seat){
	if(Table[table][tStarted] == 1){
	    // TODO ��ҡ��йܡ��һ�
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
        format(string, sizeof string, "%d����", seat+1);
    } else {
        format(string, sizeof string, "%d����\n((%s))", seat+1, name);
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
	    format(string, sizeof string, "%d����", table+1);
	} else {
	    format(string, sizeof string, "%d����\n((�ѿ�ʼ))", table+1);
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
	    //�����������
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
        //�Ǵ�С��
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
	        format(name, 16, "С��");
	    } else {
	        format(name, 16, "����");
	    }
	}
}

// ��������
public Table::gameHandler(table){
	if(Table[table][tTimeCount] > 0){
	    Table[table][tTimeCount]--;
	} 
    switch(Table[table][tStatus]){
    	case STATUS_JUST_START:{
    	    if(Table[table][tTimeCount] == 0){
	    	    // -- ���������ҵ���, ѡ�е���,���ѡ��״̬,�Լ�ϴ����
	    	    Table::initCards(table);
				// -- ��ʼ����
				Table[table][tTimeCount] = 17; //ÿ��17����
				Table[table][tStatus] = STATUS_DEAL;
    	    }
	 	}
	 	case STATUS_DEAL:{
	 	    // ���ƽ׶�  timecount �� 16 ~ 0
	 	    new slotid = 16 - Table[table][tTimeCount]; // ��Χ 0 - 16
	 	    // ����ҷ���
			for(new i = 0; i < 3; i++){
			    TablePlayerCards[table][i][slotid] = Table[table][tCards][slotid*3+i];
                // �����������ң���ʱ����UI
				new player = Table[table][tSeatPlayerIds][i];
				if(player != -1 && !Robot::isRobot(player)){
				    Player::updateCardTxd(player, TablePlayerCards[table][i], TablePlayerCardsSelected[table][i], {0}, 0, slotid+1, slotid+1, slotid+1);
				}
			}
			// ������
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
	                // �������˵��ƽ�������
					Table::sort(TablePlayerCards[table][i], 17, ORDER_NORMAL);
	                // �����������ң���ʱ����UI �� ������ѡ��
					new player = Table[table][tSeatPlayerIds][i];
					if(player != -1 && !Robot::isRobot(player)){
					    Player::updateCardTxd(player, TablePlayerCards[table][i], TablePlayerCardsSelected[table][i], {0}, 0, 17, 17, 17);
					    Player::updateHiddenCardTxd(player, hidden_cards);
					    SelectTextDraw(player, -1);
					}
				}
				// ���ѡȡĳ���˿�ʼ�е���
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
	            // ����������ѡ�������������ʾ��ť��ʱ��
	 	    	new player = Table[table][tSeatPlayerIds][Table[table][tCurrentPlayer]];

				if(player != -1 && !Robot::isRobot(player)){
				    Player::showButton(player, Table[table][tTimeCount]/10, "NO", "CALL");
				} else {
				// �����������һ������ѡ �� 3s ���Զ��������
				    if(Table[table][tTimeCount] == TIME_CALL_LORD - 30){
	                    Table[table][tRespond] = 1;
	                    Table[table][tLordRefreshed] = random(2);//TODO �޸�
	                    if(Table[table][tLordRefreshed] == 1){
	                        Table[table][tLord] = Table[table][tCurrentPlayer];
	                    }
				    }
				}
				// �����������ʾ����ʣ��ʱ��
				Table::showTimeLeftToOthers(table);
				// �Ѿ���Ӧ�е��� �� ʱ�䵽�� �Զ���Ӧ
				if(Table[table][tTimeCount] == 0){
	                Table[table][tLordRefreshed] = 0;
	                Table[table][tRespond] = 1;
				}
			}
			// �Ѿ���Ӧ�е���
			else if(Table[table][tRespond] == 1){
			    if(Table[table][tLordCallCoolTime] == 0){
			        // �����ʾ����������
			        Table[table][tLordCallCoolTime] = 15;
			        Table[table][tRespond] = 0;
				    Table[table][tCalled]++;
				    if(Table[table][tCalled] >= 3){
				        // ������������һ��
				        if(Table[table][tLord] == -1){
				            //�����û�˽е��� �����¿�ʼ
				            KillTimer(Table[table][tTimer]);
				            Table::startGame(table);
				        } else {
					        // ����������
					        for(new i = 0; i < 3; i++){
					            TablePlayerCards[table][Table[table][tLord]][i+17] = Table[table][tCards][i+51];
					        }
					        // �ź�˳��
					        Table::sort(TablePlayerCards[table][Table[table][tLord]], 20, ORDER_NORMAL);
					        // (STATUS_PLAY ��������ҵ����)
					        // ��ʾ�������ƣ�����������, ������ʱ��
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
							// ��ʼ����
							Table[table][tCurrentPlayer] = Table[table][tLord];
							Table[table][tTimeCount] = TIME_PLAY;
							Table[table][tStatus] = STATUS_PLAY;
				        }
				    } else {
				        // ȡ����һ���˵İ�ť������ʱ�䣬������һ���˽е���
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
	            // ����������ѡ��
	 	    	new player = Table[table][tSeatPlayerIds][Table[table][tCurrentPlayer]];
				if(Table[table][tGuard][Table[table][tCurrentPlayer]] == 0){
				    // ���δ�й�
				    Player::showButton(player, Table[table][tTimeCount]/10, "NO", "GO");
				} else {
					// �����������һ���������й�״̬
					new seat = Table[table][tCurrentPlayer];
					if(Table[table][tFirstHand] == 0){
					    //����ǽ�����,5����Ѱ�ҽ�
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
					    //������Լ������
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
				// �����������ʾ����ʣ��ʱ��
				Table::showTimeLeftToOthers(table);
				
				// ʱ�䵽�� �Զ���Ӧ
				if(Table[table][tTimeCount] == 0){
	                Table[table][tRespond] = 1;
				}
			} else {
			    // ���¼��õ���Ӧ
			    
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
	    //��������ѡ����ʱ�����˵��
	    if(Table[table][tCurrentPlayer] != seat)return printf("����!Table OnPlayerClick (seat != currentSeat)");
	    if(which == CLICK_YES){
	        //��ҽ��˵���
	        Table[table][tLord] = seat;
	        Table[table][tLordRefreshed] = 1;
	    } else {
	        Table[table][tLordRefreshed] = 0;
	    }
	    // ��Ӧ Handler
     	Table[table][tRespond] = 1;
	} else if(Table[table][tStatus] == STATUS_PLAY){
		//����ڳ��ƽ׶�
		new temp_card_ids[MAX_PLAYER_CARDS];
		new temp_cards[MAX_PLAYER_CARDS];
		new temp_card_size = 0;
		for(new i = 0; i < MAX_PLAYER_CARDS; i++){
		    if(TablePlayerCardsSelected[table][seat][i] == 1){
		        //������Ʊ�ѡ����������
		        temp_card_ids[temp_card_size] = i;
		        temp_cards[temp_card_size] = TablePlayerCards[table][seat][i];
		    }
		}
		if(temp_card_size > 0){
		    new type, detail, level;
			Logic::determineCardInfo(temp_cards, temp_card_size, type, detail, level);
			if(Table[table][tFirstHand] == 1){
			    //������Լ���һ�ֳ���
			    if(type != TYPE_WRONG){
			        //���ƿ��Գ�
			        Table::onPlayerPlayCards(table, seat, temp_card_ids, temp_cards, temp_card_size);
			    } else {
			        ShowPlayerDialog(playerid, DIALOG_NO_RESPONSE, DIALOG_STYLE_MSGBOX, "����, "�ó��Ʒ�ʽ����", "�ر�", "");
			    }
			} else {
			    //�����ѹ��
			    if(Logic::isGreater(type, detail, level, Table[table][tLastType], Table[table][tLastTypeDetail], Table[table][tLastTypeLevel])){
			        //���ƿ��Գ�
			        Table::onPlayerPlayCards(table, seat, temp_card_ids, temp_cards, temp_card_size);
			    }
			}
		}
	}
	return 1;
}

public Table::onPlayerShiftCard(playerid, table, seat, card_id){
	if(Table[table][tStatus] != STATUS_PLAY)return ; // �ǳ��ƽ׶ν�ֹ�����
    if(TablePlayerCardsSelected[table][seat][card_id] == 1){
     	//��������棬�������������Լ�����
        TablePlayerCardsSelected[table][seat][card_id] = 0;
    } else {
        //��������棬�������������Լ�����
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
	// -- ���������ҵ���
	for(new i = 0; i < 3; i++){
 		for(new u = 0; u < MAX_PLAYER_CARDS; u++){
 			TablePlayerCardsSelected[table][i][u] = 0;
 		}
	}
	// -- ȡ�����ѡ��״̬
	for(new i = 0; i < 3; i++){
		new player = Table[table][tSeatPlayerIds][i];
		if(player != -1 && !Robot::isRobot(player)){
	    	CancelSelectTextDraw(player);
		}
	}
	// -- ����һ����˳����ƣ����ҳ�ʼ����������
	new temp_cards[MAX_CARDS];
	for(new i = 0; i < MAX_CARDS; i++){
		temp_cards[i] = i+1;
		Table[table][tLastCards][i] = 0;
	}
	Table[table][tLastCardSize] = 0;
	// -- �����ȡ���Ƶ�������
	for(new i = 0; i < MAX_CARDS; i++){
 		if(i == MAX_CARDS - 1){
			// ���һ�γ���
			Table[table][tCards][i] = temp_cards[0];
		} else {
 			//��������
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
	    // ��ɾ��������е��ƣ�����ӵ� ���ȥ������
	    for(new i = 0; i < card_size; i++){
	        TablePlayerCards[table][seat][card_ids[i]] = 0;
	        TablePlayerCardsSelected[table][seat][card_ids[i]] = 0;
	        Table[tLastCards][i] = cards[i];
	    }
	    Table[table][tLastCardSize] = card_size;
	    // ����������ҵ���UI
	    for(new i = 0; i < 3; i++){
	        new player = Table[table][tSeatPlayerIds][i];
	        if(player != -1 && !Robot::isRobot(player)){
	            //����UI���������button
	            Player::hideButton(player);
				Player::hideTime(player);'
	        }
	    }
	    Table::updateAllPlayerCardTxd(table);
	    Table[table][tRespond] = 1;
	}
}
