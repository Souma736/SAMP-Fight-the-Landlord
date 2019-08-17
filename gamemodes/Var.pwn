#define MAX_TABLES 100
#define MAX_PLAYER_CARDS 20
#define MAX_CARDS 54

#define STATUS_JUST_START 0 	//�տ���
#define STATUS_DEAL 1 		//��ʼ����
#define STATUS_SHOW_HIDDEN_CARDS 2 //�� ���ŵ���
#define STATUS_CALL_LORD 3 //�е����׶�
#define STATUS_PLAY 4 //���ƽ׶�

#define TABLE_ACTOR_SKIN 25

#define TYPE_WRONG      -1//���������
#define TYPE_SOLO 		0 //����
#define TYPE_PAIR 		1 //���� (1�ԣ�3���ԣ�4����...)
#define TYPE_TRIPLE     2 //���� (3��1, 3��һ��,  2*3+1+1  2*3+2 3*3+1+1+1, 3*3+2+1 ...
#define TYPE_QUAD       4 //���� (ը���� 4��2 (1+1, 2))
#define TYPE_STRAIGHT   5 //˳�� (5, 6, 7 ...)
#define TYPE_BOOM       6 //��ը

#define SEAT_LABEL_DRAW_DISTANCE 5.0
#define TABLE_LABEL_DRAW_DISTANCE 15.0



#define TIME_CALL_LORD 20*10 // �е��� 20 s
#define TIME_PLAY 30*10 //��������

enum tableinfo{
	// --- ��Ϸǰ
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

	// --- ��Ϸ��
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

// �����Ϣ
#define MAX_PLAYER_PASSWORD 128
#define MAX_PLAYER_TEXT_VIEW 124
enum playerinfo{
	pName[MAX_PLAYER_NAME],
	pPassword[MAX_PLAYER_PASSWORD],
	pGold,
	pScore,
	pLogged,
	pLastSpeakTime,
	pTableID,
	pSeatID,
	pIsTxdShowing[MAX_PLAYER_TEXT_VIEW],
	pCardTxdStartID,// ���±��Ƶ�TXD ID Ϊ��׼ �� 1 ~ 20
	pCardTxdEndID, //  StartID <= x < EndID
}
new Player[MAX_PLAYERS][playerinfo];
new PlayerText:pTextDraw[MAX_PLAYER_TEXT_VIEW];
