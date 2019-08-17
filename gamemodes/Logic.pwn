Logic::idToValues(const cards[], size, values[]){
    for(new i = 0; i < size; i++){
	    if(cards[i] < 54){
	        //������Ǵ�����������
	        values[i] = (cards[i] - 1) / 4;
	    } else {
	        //�Ǵ�����ֱ����Ϊ14
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
	cards ��ΧΪ 0 - 53 �����¼��ɫ
	values ��ΧΪ 0 - 14 ��������ֵ��С
	poker_values, poker_times, lapsize Ϊ������������
	
    
	
        ����        ����ֵ��С
		3           0
		4           1
		.
		.
		K           10
		A           11
		2           12
		С��        13
		����        14
	*/

	// �ȼ����ⲻ�ǺϷ��ĳ���
	type = TYPE_WRONG;
	// ��ȡ values �� ���������µ� ������ֵ
	// lapsize  Ϊ ��������
	/*���� cards Ϊ {1,2,3,4,6,18,19,20,21,22} ʱ
    ʵ�ʵ���Ϊ 3,3,3,3 4 7,7,7 8,8
	values Ϊ {0,0,0,0, 1, 4,4,4 5,5} ������orderByLaps����֮��
	poker_valuesΪ {0, 4, 5, 1}
	poker_times Ϊ {4, 3, 2, 1}
	�� poker_values��poker_times��
	*/
	new values[MAX_PLAYER_CARDS];
	Logic::idToValues(cards, size, values);
	
	new poker_values[MAX_CARD_VALUES], poker_times[MAX_CARD_VALUES], lapsize;
	Logic::orderByLaps(values, size, poker_values, poker_times, lapsize);
	
	
	new element_times[5], element_values[5][MAX_PLAYER_CARDS];
	Logic::getElements(poker_values, poker_times, lapsize, element_times, element_values);
	
	
	// ����
	if(lapsize == 1 && element_times[1] == 1){
	    type = TYPE_SOLO;
	    type_detail = 0;
	    level = values[0];
	}
	
	// ����
	if(lapsize == 1 && poker_times[0] == 2){
        type = TYPE_PAIR;
		type_detail = 1;
		level = values[0];
	}
	
	//3���Լ�����
	if(element_times[4] == 0 && element_times[3] == 0 && element_times[2] >= 3 && element_times[1] == 0){
	    new isSuccess = 1;
		for(new i = 0; i < element_times[2]; i++){
			//  ���û������ �� �� A ��
		    if((i < element_times[2]-1 && element_values[2][i] != element_values[2][i+1]+1) || (element_values[2][i] > 11)){ // ���� values�ǵ�������-1
		        isSuccess = 0;
		        break;
		    }
		}
		if(isSuccess == 1){
		    type = TYPE_PAIR;
		    type_detail = element_times[2];
		    level = element_values[2][0]; //��¼�����Ϊ level
		}
	}
	// 3�ţ�3��1��3��2�� �� �ɻ�
	if(element_times[4] == 0 && element_times[3] > 0){ //������ը����
	    if((element_times[2] == 0 && element_times[1] == 0) || (element_times[2] == element_times[3] && element_times[1] == 0) || (element_times[1] == element_times[3] && element_times[2] == 0)){
	        new isSuccess = 1;
	        if(element_times[3] > 1){
	            // ����Ƿɻ�
	            for(new i = 0; i < element_times[3]; i++){
	                //���û������ �� �� A ��
	                if((i < element_times[3]-1 && element_values[3][i] != element_values[3][i+1]+1) || (element_values[3][i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_TRIPLE;
	        	type_detail = element_times[3] * 1000 + element_times[1] + element_times[2] * 10; // Ϊ�������� ������ ���� ����
	        	level = element_values[3][0];
	        }
	    }
	}
	// ˳��
	if(element_times[4] == 0 && element_times[3] == 0 && element_times[2] == 0 && element_times[1] >= 5){
        new isSuccess = 1;
		for(new i = 0; i < element_times[1]; i++){
		    //���û������ �� �� A ��
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
	// ը�� �� �Ĵ�2��  �� �Ĵ� 2�� �� �Ĵ�һ��
	if(element_times[4] > 0 && element_times[3] == 0){
	    if((element_times[2] == 0 && element_times[1] == 0) || (element_times[2] == element_times[4]*2 && element_times[1] == 0) || (element_times[1] == element_times[4]*2 && element_times[2] == 0) || (element_times[2] == element_times[4] && element_times[1] == 0)){
	        new isSuccess = 1;
	        if(element_times[4] > 1){
	            // �����ֹ һ�� ��
	            for(new i = 0; i < element_times[4]; i++){
	                //���û������ �� �� A ��
	                if((i < element_times[4]-1 && element_values[4][i] != element_values[4][i+1]+1) || (element_values[4][i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_QUAD;
	        	type_detail = element_times[4] * 1000 + element_times[1]*5 + element_times[2] * 10; // detailΪ1000Ϊը��
	        	level = element_values[4][0];
	        }
	    }
	}
	// ��ը
	if(element_times[4] == 0 && element_times[3] == 0 && element_times[2] == 0 && element_times[1] == 2 && element_values[1][0] == 14 && element_values[1][1] == 13){
	    type = TYPE_BOOM;
    	type_detail = 0;
    	level = 0;
	}
//	if(type == TYPE_WRONG)printf("����");
	//TODO
	//if(element_times[4] != 0 && element_times[3] > 0){//����ը���𿪳ɷɻ�  �� 33334445
}

Logic::orderByLaps(const values[], size, poker_values[], poker_times[], &lapsize){
	//��ʼ��
	for(new i = 0; i < MAX_CARD_VALUES; i++){
	    poker_times[i] = i;
	}
	//���ÿ��������ֵĴ���
	for(new i = 0; i < size; i++){
	    poker_times[values[i]] += 1000;
	}
	//���ݴ�����С���򣬴��������ǰ
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
			// ���һ�γ���
			outputArray[i] = temp_array[0];
		} else {
 			//��������
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
	//��ը
	if(cardSize >= 2){
	    outputSize = 2;
	    Logic::determineCardInfo(temp_cards, 2, type, detail, level);
	    if(Logic::isGreater(type, detail, level, targetType, targetDetail, targetLevel))return true;
	}
	//ը��
	if(cardSize >= 4){
	    outputSize = 4;
	    Logic::determineCardInfo(temp_cards, 4, type, detail, level);
	    if(Logic::isGreater(type, detail, level, targetType, targetDetail, targetLevel))return true;
	}
	return false;
}

//�ж��Ƿ�ǰ�ߴ��ں���
Logic::isGreater(type1, detail1, level1, type2, detail2, level2){
	if(type1 == TYPE_BOOM)return true;
	if(type2 == TYPE_BOOM)return false;
	if(type1 == type2 && detail1 == detail2 && level1 > level2)return true;
	if(!(type2 == TYPE_QUAD && detail2 == 1000)){
	    if(type1 == TYPE_QUAD && detail1 == 1000)return true;
	}
	return false;
}
