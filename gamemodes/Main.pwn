#include <a_samp>
#include <Dini>
#include <a_color>

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
// -- 对话框定义
#define DIALOG_REG 0
#define DIALOG_LOGIN 1
#define DIALOG_TABLE_RESULT 2
// -- 类定义
#define Player:: Player_
#define Robot:: Robot_
#define Table:: Table_
#define Logic:: Logic_

#define CLICK_YES 0
#define CLICK_NO 1

#define SEAT_PREV 0
#define SEAT_NEXT 1
#define SEAT_SELF 2

#define ORDER_NORMAL 0
#define ORDER_DESC 1

#define RESPONSE_NO 1
#define RESPONSE_YES 2
#define RESPONSE_WIN 3

#define DIALOG_NO_RESPONSE 4399

#define MAX_CARD_VALUES 15

#include "Player.pwn"
#include "Table.pwn"
#include "Robot.pwn"
#include "Logic.pwn"

public OnGameModeInit()
{
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(1);
	ShowNameTags(1);
	Table::OnGameModeInit();
	return 1;
}

main(){}



public OnGameModeExit()
{
	return 1;
}



public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid))return 1;
	Player::OnPlayerConnect(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Player::OnPlayerDisconnect(playerid, reason);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(!Player::isLogged(playerid))return Kick(playerid);
	return 1;
}



public OnPlayerText(playerid, text[])
{
	Player::OnPlayerText(playerid, text);

	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!Player::isLogged(playerid))return 1;
	new idx = 0;
	new cmd[32];
	cmd=strtok(cmdtext, idx);


    if(strcmp(cmd, "/help") == 0)
 	{
	 	SendClientMessage(playerid, -1, "{3366CC}[指令]{FFFFFF}“/join”或“H键”[加入/退出游戏] “/fix”[出现鼠标指针]");
	 	SendClientMessage(playerid, -1, "{3366CC}[指令]{FFFFFF}“/status”[个人资料] “/bot”[管理电脑]");
	 	return 1;
	}

	if(!strcmp(cmd, "/bot")){
	    cmd = strtok(cmdtext, idx);
	    if(strlen(cmd) <= 0)return SendClientMessage(playerid, -1, "[Usage]/bot [add / del]");
	    if(!strcmp(cmd, "add")){
			cmd = strtok(cmdtext, idx);
			new seat_string[128];
			seat_string = strtok(cmdtext, idx);
			if(strlen(cmd) <= 0 || strlen(seat_string) <= 0)return SendClientMessage(playerid, -1, "[Usage]/bot add [table] [seat] [name] [gold] [score]");
			new table = strval(cmd) - 1;
			new seat = strval(seat_string) - 1;
			if(table < 0)return SendClientMessage(playerid, -1, "[table] 范围错误");
			if(seat < 0 || seat > 2)return SendClientMessage(playerid, -1, "[seat] 范围错误");
			new name[128];
			name = strtok(cmdtext, idx);

			new gold = strval(strtok(cmdtext, idx));
			new score = strval(strtok(cmdtext, idx));
			if(Robot::create(name, 26, table, seat, gold, score)){
				new string[128];
				format(string, sizeof string, "成功创建%s(%d桌 %d座 %d金币 %d积分)", name, table+1, seat+1, gold, score);
			    SendClientMessage(playerid, -1, string);
			    return 1;
			} else {
			    SendClientMessage(playerid, -1, "[错误] 牌桌不存在或座位已有其他人了");
			}
	    }
	    if(!strcmp(cmd, "del")){
	        cmd = strtok(cmdtext, idx);
            if(strlen(cmd) <= 0)return SendClientMessage(playerid, -1, "[Usage]/bot del [name]");
			for(new i = 0; i < robotid; i++){
			    if(Robot[i][rTable] != -1 && strlen(Robot[i][rName]) > 0 && !strcmp(Robot[i][rName], cmd)){
			        Table::onRobotLeave(Robot[i][rTable], Robot[i][rSeat]);
			        Robot[i][rTable] = -1;
			        format(Robot[i][rName], 32, " ");
			        DestroyActor(Robot[i][rActorID]);
			        SendClientMessage(playerid, -1, "已删除该机器人");
					return 1;
			    }
			}
			return SendClientMessage(playerid, -1, "未找到该机器人");
	    }
	    return 1;
	}
	
	if(!strcmp(cmd, "/join")){
	    Player::OnPlayerKeyStateChange(playerid, KEY_CTRL_BACK, 0);
	    return 1;
	}
	
	if(!strcmp(cmd, "/fix")){
	    if(Player[playerid][pTableID] != -1 && Table[Player[playerid][pTableID]][tStarted] == 1){
	        if(Table[Player[playerid][pTableID]][tStatus] == STATUS_PLAY){
				CancelSelectTextDraw(playerid);
				SelectTextDraw(playerid, -1);
	        }
	    }
	    return 1;
	}
	
	if(!strcmp(cmd, "/status")){
	    SendClientMessage(playerid, -1, "{3366CC}[提示]{FFFFFF}按下“TAB”，双击即可查看信息");
	    return 1;
	}
	SendClientMessage(playerid, COLOR_GREY, "输入“/help”获得帮助");
	return 1;
}


public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	Player::OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	return 1;
}

public OnPlayerDeath(playerid)
{
	SpawnPlayer(playerid);
}



public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	Player::OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	Player::clickTXD(playerid, PlayerText:playertextid);
    return 0;
}


public OnPlayerClickTextDraw(playerid, Text:clickedid)
{

	return 0;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if(Player[clickedplayerid][pLogged] == 0)return 1;
    new msg[128];
    format(msg, sizeof msg,"[%s的信息]", Player[clickedplayerid][pName]);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof msg, "积分: %d   金币: %d", Player[clickedplayerid][pScore], Player[clickedplayerid][pGold]);
    SendClientMessage(playerid, -1, msg);
	return 1;
}




strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offsetx = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offsetx) < (sizeof(result) - 1)))
	{
		result[index - offsetx] = string[index];
		index++;
	}
	result[index - offsetx] = EOS;
	return result;
}


public OnPlayerRequestClass(playerid, classid)
{
	return 0;
}




