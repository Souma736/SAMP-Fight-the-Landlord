#define MAX_ROBOTS 100
enum robotinfo{
	rName[MAX_PLAYER_NAME],
	rGold,
	rScore,
	rActorID,
	rTable,
	rSeat
}
new Robot[MAX_ROBOTS][robotinfo];
new robotid = 0;

forward Robot::create(name[], skin, table, seat, gold, score);
forward Robot::isRobot(playerid);
forward Robot::getName(playerid, name[]);
forward Robot::getGold(playerid);
forward Robot::getScore(playerid);

public Robot::create(name[], skin, table, seat, gold, score){
	if(Table::onNpcJoin(robotid, name, table, seat)){
	    Robot[robotid][rGold] = gold;
	    Robot[robotid][rScore] = score;
	    Robot[robotid][rTable] = table;
	    Robot[robotid][rSeat] = seat;
	    format(Robot[robotid][rName], MAX_PLAYER_NAME, name);
	    new Float:pos[3], Float:angle;
	    Table::getSeatPosAndAngle(table, seat, pos, angle);
	    Robot[robotid][rActorID] = CreateActor(skin, pos[0], pos[1], pos[2], angle+90.0);
	    robotid++;
	    return true;
	}
	return false;
}

public Robot::isRobot(playerid){
	return (playerid >= MAX_PLAYERS);
}

public Robot::getName(playerid, name[]){
		new npcid = playerid - MAX_PLAYERS;
		format(name, MAX_PLAYER_NAME, Robot[npcid][rName]);
}

public Robot::getGold(playerid){
		new npcid = playerid - MAX_PLAYERS;
		return Robot[npcid][rGold];
}

public Robot::getScore(playerid){
		new npcid = playerid - MAX_PLAYERS;
		return Robot[npcid][rScore];
}


