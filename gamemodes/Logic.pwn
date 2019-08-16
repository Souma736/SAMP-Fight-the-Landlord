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
	new quads = 0, triples = 0, pairs = 0, solos = 0;
	new quad_values[5]; // 最多5个4张
	new triple_values[7]; // 最多 7个三张
	new pair_values[10]; // 最多10个对子
	new solo_values[20]; // 最多20个单张
	Logic::getElements(poker_values, poker_times, lapsize, quads, triples, pairs, solos, quad_values, triple_values, pair_values, solo_values);
	
	
	
	// 单张
	if(lapsize == 1 && solos == 1){
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
	if(quads == 0 && triples == 0 && pairs >= 3 && solos == 0){
	    new isSuccess = 1;
		for(new i = 0; i < pairs; i++){
			//  如果没连起来 或 比 A 大
		    if((i < pairs-1 && pair_values[i] != pair_values[i+1]+1) || (pair_values[i] > 11)){ // 由于 values是倒序，所以-1
		        isSuccess = 0;
		        break;
		    }
		}
		if(isSuccess == 1){
		    type = TYPE_PAIR;
		    type_detail = pairs;
		    level = pair_values[0]; //记录最大牌为 level
		}
	}
	// 3张，3带1，3带2， 或 飞机
	if(quads == 0 && triples > 0){ //不考虑炸弹拆开
	    if((pairs == 0 && solos == 0) || (pairs == triples && solos == 0) || (solos == triples && pairs == 0)){
	        new isSuccess = 1;
	        if(triples > 1){
	            // 如果是飞机
	            for(new i = 0; i < triples; i++){
	                //如果没连起来 或 比 A 大
	                if((i < triples-1 && triple_values[i] != triple_values[i+1]+1) || (triple_values[i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_TRIPLE;
	        	type_detail = triples * 1000 + solos + pairs * 10; // 为了区分是 带单张 还是 对子
	        	level = triple_values[0];
	        }
	    }
	}
	// 顺子
	if(quads == 0 && triples == 0 && pairs == 0 && solos >= 5){
        new isSuccess = 1;
		for(new i = 0; i < solos; i++){
		    //如果没连起来 或 比 A 大
		    if((i < solos-1 && solo_values[i] != solo_values[i+1]+1) || (solo_values[i] > 11)){
		        isSuccess = 0;
		        break;
		    }
		}
		if(isSuccess == 1){
            type = TYPE_STRAIGHT;
        	type_detail = solos;
        	level = solo_values[0];
        }
	}
	// 炸弹 或 四带2张  或 四带 2对 或 四带一对
	if(quads > 0 && triples == 0){
	    if((pairs == 0 && solos == 0) || (pairs == quads*2 && solos == 0) || (solos == quads*2 && pairs == 0) || (pairs == quads && solos == 0)){
	        new isSuccess = 1;
	        if(quads > 1){
	            // 如果不止 一个 四
	            for(new i = 0; i < quads; i++){
	                //如果没连起来 或 比 A 大
	                if((i < quads-1 && quad_values[i] != quad_values[i+1]+1) || (quad_values[i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_QUAD;
	        	type_detail = quads * 1000 + solos*5 + pairs * 10; // detail为1000为炸弹
	        	level = quad_values[0];
	        }
	    }
	}
	// 王炸
	if(quads == 0 && triples == 0 && pairs == 0 && solos == 2 && solo_values[0] == 14 && solo_values[1] == 13){
	    type = TYPE_BOOM;
    	type_detail = 0;
    	level = 0;
	}
//	if(type == TYPE_WRONG)printf("错误");
	//TODO
	//if(quads != 0 && triples > 0){//考虑炸弹拆开成飞机  如 33334445
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


Logic::getSolution(const cards[], cardSize, requiredSize, targetType, targetDetail, targetLevel, seed, outputArray[]){

	new quads = 0, triples = 0, pairs = 0, solos = 0;
	new quad_values[5]; // 最多5个4张
	new triple_values[7]; // 最多 7个三张
	new pair_values[10]; // 最多10个对子
	new solo_values[20]; // 最多20个单张
	for(new i = 0; i < lapsize; i++){
		if(poker_times[i] == 3){
		    triple_values[triples++] = poker_values[i];
		} else if(poker_times[i] == 4){
		    quad_values[quads++] = poker_values[i];
		} else if(poker_times[i] == 2){
		    pair_values[pairs++] = poker_values[i];
		} else if(poker_times[i] == 1){
		    solo_values[solos++] = poker_values[i];
		}
	}
}
