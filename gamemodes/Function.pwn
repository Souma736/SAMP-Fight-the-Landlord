



Fun::importTableObjects(){
    CreateObject(11690, -3.70, 1517.29, 11.70,   0.00, 0.00, 30.00);
	CreateObject(11690, -3.12, 1506.11, 11.70,   0.00, 0.00, 45.00);
	CreateObject(11690, -0.40, 1512.39, 11.70,   0.00, 0.00, -60.00);
}

Fun::createTablesByObjects(){
    for(new i= 0; i < MAX_OBJECTS; i++){
	    if(GetObjectModel(i) == 11690){
			//¾àÀëÎª1.1
			new Float:dis = 1.1;
	        new Float:pos[3], Float:angle, Float:ver_angle, Float:actor_pos[3], Float:none;
			GetObjectPos(i, pos[0], pos[1], pos[2]);
			GetObjectRot(i, none, none, angle);
			actor_pos[0] = pos[0] + dis * floatcos(angle, degrees);
			actor_pos[1] = pos[1] + dis * floatsin(angle, degrees);
			actor_pos[2] = pos[2] + dis;
			
			Table[tableid][tStarted] = 0;
			Table[tableid][tAngle] = angle + 90.0;
			
			for(new i = 0; i < 3; i++){
			    new Float:fixed_angle = (i == 1) ? angle : angle + 90.0,
				for(new u = 0; u < 3; u++){
					switch(u){
					    case 0:{
					        TableSeatPos[tableid][i][u] = pos[u] + dis * floatcos(fixed_angle, degrees);
					    }
					    case 1:{
					        TableSeatPos[tableid][i][u] = pos[u] + dis * floatsin(fixed_angle, degrees);
					    }
					    case 2:{
					        TableSeatPos[tableid][i][u] = pos[u] + 0.5;
					    }
				    }
				}
				// ³õÊ¼»¯
				Table[table][tSeatPlayerIds][i] = -1;
	    		Table[table][tGuard][i] = 0;
				// ´´½¨×ùÎ»±êÇ©
				new seat_name[32];
			    format(seat_name, sizeof seat_name, "%dºÅ×ù", i+1);
			    Table[tableid][tLabels][i] = Create3DTextLabel(seat_name, -1, TableSeatPos[tableid][i][0], TableSeatPos[tableid][i][1], TableSeatPos[tableid][i][2], SEAT_LABEL_DRAW_DISTANCE, 0);
			}
			// ´´½¨¿´³¡×ÓNPC
			CreateActor(TABLE_ACTOR_SKIN, actor_pos[0], actor_pos[1], actor_pos[2], angle+90.0);
			// ´´½¨×À×Ó±êÇ©
			new table_name[16];
			format(table_name, sizeof table_name, "%dºÅ×À", tableid+1);
			Table[tableid][tMainLabel] =  Create3DTextLabel(table_name, -1, org_pos[0], org_pos[1], org_pos[2]+0.5, TABLE_LABEL_DRAW_DISTANCE, 0);
			
			tableid++;
	    }
	}
}

Fun::initPlayerData(playerid){
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

Fun::onPlayerLogin(playerid){
	GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
	new filename[64];
	format(filename, sizeof filename, "Accounts/%s.ini", Player[playerid][pName]);
	if(fexist(filename)){
	    Fun::loadPlayerData(playerid);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "µÇÂ¼½çÃæ", "  ÇëÊäÈëÃÜÂëµÇÂ¼", "µÇÂ¼", "ÍË³ö");
	} else {
		ShowPlayerDialog(playerid, DIALOG_REG, DIALOG_STYLE_INPUT, "×¢²á½çÃæ", "  ÇëÊäÈëÃÜÂë×¢²á", "×¢²á", "ÍË³ö");
	}
}

Fun::loadPlayerData(playerid){
    new File[64];
	format(File, sizeof File, "Accounts/%s.ini", Player[playerid][pName]);
	strmid(Player[playerid][pPassword], dini_Get(File, "password"), 0, strlen(dini_Get(File,"password")), MAX_PLAYER_PASSWORD);
	Player[playerid][pGold] = dini_Int(File, "gold");
	Player[playerid][pScore] = dini_Int(File, "score");
}

Fun::savePlayerData(playerid){
	new File[64];
	format(File, sizeof File, "Accounts/%s.ini", Player[playerid][pName]);
	if(!fexist(File))dini_Create(File);
	dini_Set(File, "password", Player[playerid][pPassword]);
	dini_IntSet(File, "gold", Player[playerid][pGold]);
	dini_IntSet(File, "score", Player[playerid][pScore]);
}

Fun::onPlayerRegister(playerid, const password[]){
    if(strlen(password) > 5 && strlen(password) < MAX_PLAYER_PASSWORD){
		format(Player[playerid][pPassword], MAX_PLAYER_PASSWORD, password);
		Player[playerid][pGold] = 100;
		Player[playerid][pScore] = 0;
		Fun::savePlayerData(playerid);
		Fun::spawnPlayer(playerid);
	} else {
		ShowPlayerDialog(playerid, DIALOG_REG, DIALOG_STYLE_INPUT, "×¢²á½çÃæ", "  ÇëÊäÈëÃÜÂë×¢²á\n \
		{FF0000}ÃÜÂëÌ«³¤»òÌ«¶Ì£¬ÇëÖØÐÂÊäÈë", "×¢²á", "ÍË³ö");
	}
}

Fun::onPlayerLogin(playerid, const password[]){
    if(strlen(password) > 5 && strlen(password) < MAX_PLAYER_PASSWORD){
		if(!strcmp(password, Player[playerid][pPassword])){
			Fun::spawnPlayer(playerid);
		} else {
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "µÇÂ¼½çÃæ", "  ÇëÊäÈëÃÜÂëµÇÂ¼\
			\n  {FF0000}ÃÜÂë´íÎó£¬ÇëÖØÐÂÊäÈë", "µÇÂ¼", "ÍË³ö");
		}
	} else {
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "µÇÂ¼½çÃæ", "  ÇëÊäÈëÃÜÂëµÇÂ¼\
			\n  {FF0000}ÃÜÂëÌ«³¤»òÌ«¶Ì£¬ÇëÖØÐÂÊäÈëÓë", "µÇÂ¼", "ÍË³ö");
	}
}

Fun::spawnPlayer(playerid){
    Player[playerid][pLogged] = 1;
	SetSpawnInfo( playerid, 0, 0, -8.1000, 1510.0000, 12.7758, 269.15, 0, 0, 0, 0, 0, 0 );
	SpawnPlayer(playerid);
}
