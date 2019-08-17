Logic::idToValues(const cards[], size, values[]){
    for(new i = 0; i < size; i++){
	    if(cards[i] < 54){
	        //如果不是大王，做运算
	        values[i] = (cards[i] - 1) / 4;
	    } else {
	        //是大王，直接设为14
	        values[i] = 14;
	    }
	}
}

Logic::getElements(const poker_values[], const poker_times[], lapsize, element_times[], element_values[][]){
    for(new i = 0; i < lapsize; i++){
        element_values[poker_times[i]][element_times[poker_times[i]]++] = poker_values[i];
	}
}


Logic::determineCardInfo(const cards[], size, &type, &type_detail, &level){
	/*
	cards 范围为 0 - 53 方便记录花色
	values 范围为 0 - 14 即牌面数值大小
	poker_values, poker_times, lapsize 为给整个牌排序
	
    
	
        牌面        牌面值大小
		3           0
		4           1
		.
		.
		K           10
		A           11
		2           12
		小王        13
		大王        14
	*/

	// 先假设这不是合法的出牌
	type = TYPE_WRONG;
	// 获取 values 即 正常排序下的 牌面数值
	// lapsize  为 种类数量
	/*例如 cards 为 {1,2,3,4,6,18,19,20,21,22} 时
    实际的牌为 3,3,3,3 4 7,7,7 8,8
	values 为 {0,0,0,0, 1, 4,4,4 5,5} ，经过orderByLaps处理之后
	poker_values为 {0, 4, 5, 1}
	poker_times 为 {4, 3, 2, 1}
	即 poker_values有poker_times张
	*/
	new values[MAX_PLAYER_CARDS];
	Logic::idToValues(cards, size, values);
	
	new poker_values[MAX_CARD_VALUES], poker_times[MAX_CARD_VALUES], lapsize;
	Logic::orderByLaps(values, size, poker_values, poker_times, lapsize);
	
	
	new element_times[5], element_values[5][MAX_PLAYER_CARDS];
	Logic::getElements(poker_values, poker_times, lapsize, element_times, element_values);
	
	
	// 单张
	if(lapsize == 1 && element_times[1] == 1){
	    type = TYPE_SOLO;
	    type_detail = 0;
	    level = values[0];
	}
	
	// 对子
	if(lapsize == 1 && poker_times[0] == 2){
        type = TYPE_PAIR;
		type_detail = 1;
		level = values[0];
	}
	
	//3连对及以上
	if(element_times[4] == 0 && element_times[3] == 0 && element_times[2] >= 3 && element_times[1] == 0){
	    new isSuccess = 1;
		for(new i = 0; i < element_times[2]; i++){
			//  如果没连起来 或 比 A 大
		    if((i < element_times[2]-1 && element_values[2][i] != element_values[2][i+1]+1) || (element_values[2][i] > 11)){ // 由于 values是倒序，所以-1
		        isSuccess = 0;
		        break;
		    }
		}
		if(isSuccess == 1){
		    type = TYPE_PAIR;
		    type_detail = element_times[2];
		    level = element_values[2][0]; //记录最大牌为 level
		}
	}
	// 3张，3带1，3带2， 或 飞机
	if(element_times[4] == 0 && element_times[3] > 0){ //不考虑炸弹拆开
	    if((element_times[2] == 0 && element_times[1] == 0) || (element_times[2] == element_times[3] && element_times[1] == 0) || (element_times[1] == element_times[3] && element_times[2] == 0)){
	        new isSuccess = 1;
	        if(element_times[3] > 1){
	            // 如果是飞机
	            for(new i = 0; i < element_times[3]; i++){
	                //如果没连起来 或 比 A 大
	                if((i < element_times[3]-1 && element_values[3][i] != element_values[3][i+1]+1) || (element_values[3][i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_TRIPLE;
	        	type_detail = element_times[3] * 1000 + element_times[1] + element_times[2] * 10; // 为了区分是 带单张 还是 对子
	        	level = element_values[3][0];
	        }
	    }
	}
	// 顺子
	if(element_times[4] == 0 && element_times[3] == 0 && element_times[2] == 0 && element_times[1] >= 5){
        new isSuccess = 1;
		for(new i = 0; i < element_times[1]; i++){
		    //如果没连起来 或 比 A 大
		    if((i < element_times[1]-1 && element_values[1][i] != element_values[1][i+1]+1) || (element_values[1][i] > 11)){
		        isSuccess = 0;
		        break;
		    }
		}
		if(isSuccess == 1){
            type = TYPE_STRAIGHT;
        	type_detail = element_times[1];
        	level = element_values[1][0];
        }
	}
	// 炸弹 或 四带2张  或 四带 2对 或 四带一对
	if(element_times[4] > 0 && element_times[3] == 0){
	    if((element_times[2] == 0 && element_times[1] == 0) || (element_times[2] == element_times[4]*2 && element_times[1] == 0) || (element_times[1] == element_times[4]*2 && element_times[2] == 0) || (element_times[2] == element_times[4] && element_times[1] == 0)){
	        new isSuccess = 1;
	        if(element_times[4] > 1){
	            // 如果不止 一个 四
	            for(new i = 0; i < element_times[4]; i++){
	                //如果没连起来 或 比 A 大
	                if((i < element_times[4]-1 && element_values[4][i] != element_values[4][i+1]+1) || (element_values[4][i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_QUAD;
	        	type_detail = element_times[4] * 1000 + element_times[1]*5 + element_times[2] * 10; // detail为1000为炸弹
	        	level = element_values[4][0];
	        }
	    }
	}
	// 王炸
	if(element_times[4] == 0 && element_times[3] == 0 && element_times[2] == 0 && element_times[1] == 2 && element_values[1][0] == 14 && element_values[1][1] == 13){
	    type = TYPE_BOOM;
    	type_detail = 0;
    	level = 0;
	}
//	if(type == TYPE_WRONG)printf("错误");
	//TODO
	//if(element_times[4] != 0 && element_times[3] > 0){//考虑炸弹拆开成飞机  如 33334445
}

Logic::orderByLaps(const values[], size, poker_values[], poker_times[], &lapsize){
	//初始化
	for(new i = 0; i < MAX_CARD_VALUES; i++){
	    poker_times[i] = i;
	}
	//算出每个牌面出现的次数
	for(new i = 0; i < size; i++){
	    poker_times[values[i]] += 1000;
	}
	//根据次数大小排序，次数多的在前
	Table::sort(poker_times, MAX_CARD_VALUES, ORDER_DESC);
	for(new i = 0; i < MAX_CARD_VALUES; i++){
	    poker_values[i] = poker_times[i] % 1000;
	    poker_times[i] = poker_times[i] / 1000;
	    if(poker_times[i] == 0){
	        lapsize = i;
	        break;
	    }
	}
}


Logic::getSolution(const cards[], cardSize, requiredSize, targetType, targetDetail, targetLevel, seed, outputArray[], &outputSize){
	new temp_array[MAX_PLAYER_CARDS];
	for(new i = 0; i < cardSize; i++){
	    temp_array[i] = i;
	}
	for(new i = 0; i < cardSize; i++){
	    if(i == cardSize - 1){
			// 最后一次抽牌
			outputArray[i] = temp_array[0];
		} else {
 			//正常抽牌
			new random_id = random(cardSize-i);
			outputArray[i] = temp_array[random_id];
			if(random_id != cardSize-i-1)
				temp_array[random_id] = temp_array[cardSize-i-1];
		}
	}
	new temp_cards[MAX_PLAYER_CARDS];
	for(new i = 0; i < requiredSize; i++){
	    temp_cards[i] = cards[outputArray[i]];
	}
	new type, detail, level;
	Logic::determineCardInfo(temp_cards, requiredSize, type, detail, level);
	outputSize = requiredSize;
	if(Logic::isGreater(type, detail, level, targetType, targetDetail, targetLevel))return true;
	//王炸
	if(cardSize >= 2){
	    outputSize = 2;
	    Logic::determineCardInfo(temp_cards, 2, type, detail, level);
	    if(Logic::isGreater(type, detail, level, targetType, targetDetail, targetLevel))return true;
	}
	//炸弹
	if(cardSize >= 4){
	    outputSize = 4;
	    Logic::determineCardInfo(temp_cards, 4, type, detail, level);
	    if(Logic::isGreater(type, detail, level, targetType, targetDetail, targetLevel))return true;
	}
	return false;
}

//判断是否前者大于后者
Logic::isGreater(type1, detail1, level1, type2, detail2, level2){
	if(type1 == TYPE_BOOM)return true;
	if(type2 == TYPE_BOOM)return false;
	if(type1 == type2 && detail1 == detail2 && level1 > level2)return true;
	if(!(type2 == TYPE_QUAD && detail2 == 1000)){
	    if(type1 == TYPE_QUAD && detail1 == 1000)return true;
	}
	return false;
}
