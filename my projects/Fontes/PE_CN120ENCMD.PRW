#Include "Protheus.ch"
#Include "Rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao�CN120ENCMD� Autores � Analise Ednei � Data �         21/01/2016 ���
���Funcao�CN120ENCMD� Desenvolvimento: Ednei Silva     � Data �15/12/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de entrada no encerramento da medicao para gravar    ���
���          � dados nas tabelas de pedidos de venda.                     ���
�������������������������������������������������������������������������Ĵ��
�� CN9 (Contratos)
�� CND (Cabecalho das medicoes)
�� SC5 (Cabecalho do pedido de venda)
�����������������������������������������������������������������������������*/

User Function CN120ENCMD()
Local cAreaAnt := alias()

IF !EMPTY(CND->CND_FORNEC) //CONTAS A PAGAR
	
	dbSelectArea("CNE")
	dbSetOrder(4)
	dbSeek(xFilial("CNE")+CND->CND_NUMMED)
	
	cQuery:=" UPDATE "+RETSQLNAME("SE2")+" "
	cQuery+=" SET D_E_L_E_T_='*', "
	cQuery+=" R_E_C_D_E_L_=R_E_C_N_O_ "
	cQuery+=" WHERE E2_FILIAL='"+XfILIAL("SE2")+"'"
	cQuery+=" AND E2_MDCONTR='"+CND->CND_CONTRA+"'"
	cQuery+=" AND E2_MDREVIS='"+CND->CND_REVISA+"'"
	cQuery+=" AND E2_MDPARCE='"+CND->CND_PARCEL+"'"
	cQuery+=" AND E2_TIPO='PR'"
	cQuery+=" AND E2_FORNECE='"+CND->CND_FORNEC+"'"
	cQuery+=" AND E2_LOJA='"+CND->CND_LJFORN+"'"
	cQuery+=" AND D_E_L_E_T_=''"
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	End
	
ELSE
	
	dbSelectArea("SC5")
	RecLock("SC5",.F.)
	SC5->C5_NATUREZ   := CN9->CN9_NATUREZ
	MsUnLock()
	
ENDIF

dbSelectArea(cAreaAnt)
Return NIL
