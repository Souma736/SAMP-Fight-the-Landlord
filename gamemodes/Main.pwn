#include <a_samp>
#include <Dini>
#include <a_color>

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
// -- �Ի�����
#define DIALOG_REG 0
#define DIALOG_LOGIN 1
// -- �ඨ��
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





#include "Player.pwn"
#include "Table.pwn"
#include "Robot.pwn"
#include "Logic.pwn"

new test_timer;
new current_value = -1;
new type_counts[7];


public OnGameModeInit()
{
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(1);
	ShowNameTags(1);
	Table::OnGameModeInit();
	//for(new i = 0; i < 13200000; i++){
	for(new i = 0; i < 20; i++){
	    test_timer = SetTimer("Test2", 1, 1);
	}
	return 1;
}

main(){}

forward Test2();
public Test2(){
	new cards[20],cardSize, requiredSize, targetType, targetDetail, targetLevel, seed, outputArray[20];
	// 10����
	cardSize = 10;
	
	cards[0] = 5;
	cards[1] = 6;
	cards[2] = 7;
	cards[3] = 14;
	cards[4] = 15;
	cards[5] = 18;
	cards[6] = 22;
	cards[7] = 26;
	cards[8] = 30;
	cards[9] = 34;
	// �ϼ��ѳ� 444 5
	requiredSize = 4;
	targetType = TYPE_TRIPLE;
	targetDetail = 1001;
	targetLevel = 1;
	seed = 0;
    if(Logic::getSolution(cards, cardSize, requiredSize, targetType, targetDetail, targetLevel, seed, outputArray)){
        new msg[128];
        for(new i = 0; i < requiredSize; i++){
            format(msg, sizeof msg, "%s %d, ", msg, outputArray[i]);
        }
        printf("%s", msg);
    }
}

forward Test();
public Test(){
 	new values[20];
	new string[128];
	new card_size = 6;
	new value_counts[55];
	for(new i = 0; i < card_size; i++){
	    new rand = 1 + random(54);
	    if(value_counts[rand] >= 1){
	        i--;
	        continue;
	    } else {
	        values[i] = rand;
	        value_counts[rand]++;
	    }
	    new name[16];
	    Table::getCardRealName(values[i], name);
	    format(string, sizeof string, "%s%s, ", string, name);
	}
	new type, detail, level;
	Logic::determineCardInfo(values, 20, type, detail, level);
	if(current_value >= 55){
	    KillTimer(test_timer);
	}
	if(type == TYPE_WRONG)return ;
	
	if(type_counts[type] >= 2)return ;
	type_counts[type]++;
	

	print("----------------------------------");
 	printf(" �������%d����", card_size);
 	printf("%s", string);
	if(type == TYPE_SOLO)printf("���Ϊ��\t���ţ�ֵ��%d", level+3);
	if(type == TYPE_PAIR){
		if(detail == 1){
		    printf("���Ϊ��\t1�ԣ�ֵ: %d", level+3);
		} else {
		    printf("���Ϊ��\t%d���ԣ�ֵ: %d", detail, level+3);
		}
	}
	if(type == TYPE_TRIPLE){
	    new times = detail / 1000;
	    new left = detail - times*1000;
		if(times == 1){
		    if(left == 1){
		        printf("���Ϊ��\t����һ��ֵ: %d", level+3);
		    } else if(left == 0){
		        printf("���Ϊ��\t���ţ�ֵ: %d", level+3);
		    } else if(left == 10){
		        printf("���Ϊ��\t����һ�ԣ�ֵ: %d", level+3);
		    }
		} else {
		    printf("���Ϊ��\t�ɻ�(%d��)��ֵ: %d", detail/ 1000, level+3);
		}
	}
	if(type == TYPE_QUAD){
		if(detail == 1000){
		    printf("���Ϊ��\tը����ֵ: %d", level+3);
		} else if(detail < 2000) {
		    printf("���Ϊ��\t�Ĵ�����ֵ: %d", level+3);
		} else {
		    printf("���Ϊ��\t����(%d��)��ֵ: %d", detail/1000, level+3);
		}
	}
	if(type == TYPE_STRAIGHT){
        printf("���Ϊ��\t˳�ӣ�ֵ: %d~%d", level+3-detail+1, level+3);
	}
	if(type == TYPE_BOOM){
		printf("���Ϊ��\t��ը", level+3, level+3+detail-1);
	}
	return ;
}

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
	 	SendClientMessage(playerid, -1, "{3366CC}[ָ��]{FFFFFF}��/join��[������Ϸ] ��/spec��[���й۲�] ��/specoff��[�����۲�] ��/kill��[��ɱ]");
	 	SendClientMessage(playerid, -1, "{3366CC}[ָ��]{FFFFFF}��/pm��[��ĳ��˽��] ��/tpm��[��/�� ˽��] ��/changeskin��[����Ƥ��]");
	 	SendClientMessage(playerid, -1, "{3366CC}[ָ��]{FFFFFF}��/stats��[��������] ��/rank��[��������] ��/tips��[��������] ��/o��[��������]((����1����))");
	 	return 1;
	}

	if(!strcmp(cmd, "/bot")){
	    cmd = strtok(cmdtext, idx);
	    if(strlen(cmd) <= 0)return SendClientMessage(playerid, -1, "[Usage]/bot [add / del]");
	    if(!strcmp(cmd, "add")){
			cmd = strtok(cmdtext, idx);
			new seat_string[128];
			seat_string = strtok(cmdtext, idx);
			if(strlen(cmd) <= 0 || strlen(seat_string) <= 0)return SendClientMessage(playerid, -1, "[Usage]/bot [add] [table] [seat] [name] [gold] [score]");
			new table = strval(cmd) - 1;
			new seat = strval(seat_string) - 1;
			if(table < 0)return SendClientMessage(playerid, -1, "[table] ��Χ����");
			if(seat < 0 || seat > 3)return SendClientMessage(playerid, -1, "[seat] ��Χ����");
			new name[128];
			name = strtok(cmdtext, idx);

			new gold = strval(strtok(cmdtext, idx));
			new score = strval(strtok(cmdtext, idx));
			if(Robot::create(name, 25, table, seat, gold, score)){
				new string[128];
				format(string, sizeof string, "�ɹ�����%s(%d�� %d�� %d��� %d����)", name, table+1, seat+1, gold, score);
			    SendClientMessage(playerid, -1, string);
			    return 1;
			} else {
			    SendClientMessage(playerid, -1, "[����] ���������ڻ���λ������������");
			}
	    }
	    return 1;
	}
	


	SendClientMessage(playerid, COLOR_GREY, "���롰/help����ð���");
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
	new msg[128];
	format(msg, sizeof msg, "������ %d", playertextid);
	SendClientMessage(playerid, -1, msg);
	Player::clickTXD(playerid, PlayerText:playertextid);
    return 0;
}


public OnPlayerClickTextDraw(playerid, Text:clickedid)
{

	return 0;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
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

strtokp(const string[],	&index)//��ȡ������������/ָ������������ȡ����
{
	new	length = strlen(string);
	while ((index <	length)	&& (string[index] <= ' '))
	{
		index++;
	}
	new	offsetx = index;
	new	result[128];
	while ((index <	length)	 &&	((index	- offsetx) <	(sizeof(result)	-1)))
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




