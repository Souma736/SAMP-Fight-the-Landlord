Souma::OnGameModeInit(){
	Fun::importTableObjects();
	Fun::createTablesByObjects();
}

Souma::OnPlayerConnect(playerid){
	Fun::initPlayerData(playerid);
	Fun::onPlayerLogin(playerid);
}

Souma::OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	if(dialogid == DIALOG_REG){
		if(response){
		    Fun::onPlayerRegister(playerid, inputtext);
		} else {
			Kick(playerid);
		}
	} else if(dialogid == DIALOG_LOGIN){
		if(response){
		    Fun::onPlayerLogin(playerid, inputtext);
		} else {
			Kick(playerid);
		}
	}
