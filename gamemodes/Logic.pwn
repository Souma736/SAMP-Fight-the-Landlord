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
	new quads = 0, triples = 0, pairs = 0, solos = 0;
	new quad_values[5]; // ���5��4��
	new triple_values[7]; // ��� 7������
	new pair_values[10]; // ���10������
	new solo_values[20]; // ���20������
	Logic::getElements(poker_values, poker_times, lapsize, quads, triples, pairs, solos, quad_values, triple_values, pair_values, solo_values);
	
	
	
	// ����
	if(lapsize == 1 && solos == 1){
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
	if(quads == 0 && triples == 0 && pairs >= 3 && solos == 0){
	    new isSuccess = 1;
		for(new i = 0; i < pairs; i++){
			//  ���û������ �� �� A ��
		    if((i < pairs-1 && pair_values[i] != pair_values[i+1]+1) || (pair_values[i] > 11)){ // ���� values�ǵ�������-1
		        isSuccess = 0;
		        break;
		    }
		}
		if(isSuccess == 1){
		    type = TYPE_PAIR;
		    type_detail = pairs;
		    level = pair_values[0]; //��¼�����Ϊ level
		}
	}
	// 3�ţ�3��1��3��2�� �� �ɻ�
	if(quads == 0 && triples > 0){ //������ը����
	    if((pairs == 0 && solos == 0) || (pairs == triples && solos == 0) || (solos == triples && pairs == 0)){
	        new isSuccess = 1;
	        if(triples > 1){
	            // ����Ƿɻ�
	            for(new i = 0; i < triples; i++){
	                //���û������ �� �� A ��
	                if((i < triples-1 && triple_values[i] != triple_values[i+1]+1) || (triple_values[i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_TRIPLE;
	        	type_detail = triples * 1000 + solos + pairs * 10; // Ϊ�������� ������ ���� ����
	        	level = triple_values[0];
	        }
	    }
	}
	// ˳��
	if(quads == 0 && triples == 0 && pairs == 0 && solos >= 5){
        new isSuccess = 1;
		for(new i = 0; i < solos; i++){
		    //���û������ �� �� A ��
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
	// ը�� �� �Ĵ�2��  �� �Ĵ� 2�� �� �Ĵ�һ��
	if(quads > 0 && triples == 0){
	    if((pairs == 0 && solos == 0) || (pairs == quads*2 && solos == 0) || (solos == quads*2 && pairs == 0) || (pairs == quads && solos == 0)){
	        new isSuccess = 1;
	        if(quads > 1){
	            // �����ֹ һ�� ��
	            for(new i = 0; i < quads; i++){
	                //���û������ �� �� A ��
	                if((i < quads-1 && quad_values[i] != quad_values[i+1]+1) || (quad_values[i] > 11)){
	                    isSuccess = 0;
	                    break;
	                }
	            }
	        }
	        if(isSuccess == 1){
	            type = TYPE_QUAD;
	        	type_detail = quads * 1000 + solos*5 + pairs * 10; // detailΪ1000Ϊը��
	        	level = quad_values[0];
	        }
	    }
	}
	// ��ը
	if(quads == 0 && triples == 0 && pairs == 0 && solos == 2 && solo_values[0] == 14 && solo_values[1] == 13){
	    type = TYPE_BOOM;
    	type_detail = 0;
    	level = 0;
	}
//	if(type == TYPE_WRONG)printf("����");
	//TODO
	//if(quads != 0 && triples > 0){//����ը���𿪳ɷɻ�  �� 33334445
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


Logic::getSolution(const cards[], cardSize, requiredSize, targetType, targetDetail, targetLevel, seed, outputArray[]){

	new quads = 0, triples = 0, pairs = 0, solos = 0;
	new quad_values[5]; // ���5��4��
	new triple_values[7]; // ��� 7������
	new pair_values[10]; // ���10������
	new solo_values[20]; // ���20������
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
