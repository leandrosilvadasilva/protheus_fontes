/*
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAH010MNU � Autor � Leonir Donatti       � Data �07/06/2016���
�������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de entrada disparado antes da abertura do Browse,    ���
���          �  caso Browse inicial da rotina esteja habilitado, ou antes ���
���          � esteja desabilitado.                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MAHOPITALAR / Faturamento                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

User Function MA410MNU()

	aAdd( aRotina , { OemToAnsi("Alt Dados PV") , "U_MAHA020" , 0, 4, 0, NIL } )
	aAdd( aRotina , { OemToAnsi("Integrar WMS") , "U_WMSSC5" , 0, 4, 0, NIL } )

Return


USER FUNCTION WMSSC5
	
	Local retorno 
	Local mensagem := ""

	IF U_checkOper(SC5->C5_FILIAL, SC5->C5_NUM) == .T.
		alert("PEDIDOS COM OPERACAO 15, 22 OU OPERACAO VAZIA NAO SERAO INTEGRADOS")
	ELSE
		//IATAN EM 20/07/2022 - MANDA O PEDIDO PARA O WMS
		retorno := U_MAPWMS07( SC5->(RECNO()), @mensagem)

		IF retorno == .T. .AND. !EMPTY(ALLTRIM(mensagem))
			RecLock("SC5",.F.)
			SC5->C5_XWMS	:= "S"  
			SC5->C5_XMSGWMS	:= mensagem
			SC5->( MsUnlock() )
			alert("INTEGRADO COM SUCESSO")
		ELSE
			alert("ATENCAO. ERRO NA INTEGRACAOO!")
			ALERT(mensagem)
		END
	ENDIF

RETURN 



User Function checkOper(cFilPed,cPedido)
	Local cAlias		:= GetNextAlias()
	Local cQuery		:= ""
	Local retorno       := .T.

	cQuery += " SELECT 	* " 								
	cQuery += " FROM 		" + RetSqlName("SC6") + " SC6" 			
	cQuery += " WHERE 	SC6.C6_FILIAL	= '" + cFilPed + "'" 	
	cQuery += " AND 	SC6.C6_NUM	= '" + cPedido + "'" 	
	cQuery += " AND 	SC6.C6_OPER 	IN ('15','22', '  ', 'R ', '07' ) " 					
	cQuery += " AND 	SC6.D_E_L_E_T_ 	<> '*' " 					
	
	cQuery := ChangeQuery(cQuery)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	DBUseArea(.T., "TOPCONN", TCGENQRY(NIL, NIL, cQuery), cAlias, .F., .T.)

	retorno :=  !(cAlias)->(Eof())

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

Return( retorno )
