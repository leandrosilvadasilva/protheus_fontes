#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHOPERA � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Saldo por produto.                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico MA Hospitalar                                   ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���															              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

WSRESTFUL MAHSLDPRO DESCRIPTION "Saldo por produto"

	WSDATA SALDO AS STRING
	
	
	WSMETHOD GET DESCRIPTION "Saldo por produto" WSSYNTAX "/MAHSLDPRO" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Procedimentos medicos	    Protheus.     ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE SALDO WSSERVICE MAHSLDPRO

	Local cQuery	:= ""
	Local cArea		:= ""
	Local aCampo	:= {}
	Local nX		:= 0
	Local nCount	:= 0
	Local nReg		:= 0
	Local nCampo	:= 0
	Local lOk		:= .T.	
	// Define o tipo de retorno do metodo
	::SetContentType("application/json")
	aAdd(aCampo, {"B2_COD"     , "B2_COD"})	
	aAdd(aCampo, {"CASE WHEN B1_MSBLQL <> '1' THEN SUM(B2_QATU-B2_RESERVA) ELSE 0 END"  , "B2_SALDO"})
	aAdd(aCampo, {"B1_CODZHO"     , "B1_CODZHO"})
	nCampo := Len(aCampo)


	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " FROM " + RetSQLName("SB2")+ " SB2 " 	
	cQuery +=" INNER JOIN " + RetSQLName("SB1")+ " SB1 ON (SB1.B1_COD = SB2.B2_COD AND SB1.D_E_L_E_T_<>'*') "
	//cQuery +=" INNER JOIN " + RetSQLName("DA1")+ " DA1 ON (SB1.B1_COD=DA1.DA1_CODPRO) "
	cQuery +=" WHERE " 
	cQuery +=" SB2.D_E_L_E_T_<>'*' " 
	//cQuery +=" AND DA1.D_E_L_E_T_<>'*' "
	//cQuery +=" AND (SELECT  MAX(DA1MAX.DA1_ITEM) FROM DA1010 DA1MAX WHERE DA1MAX.DA1_CODPRO=B1_COD AND DA1MAX.D_E_L_E_T_<>'*') <> '' "
	cQuery +=" AND SB2.B2_LOCAL='01' "
	cQuery +=" AND (SB1.B1_TIPO IN ('M1','M2','M3','M4','M5') OR (B1_TIPO = 'AI' AND B1_COD LIKE '%IMB' ) )  "
	//If ::B1_CODZHO='1'
	//	cQuery += "   AND SB1.B1_CODZHO ='' "
	//EndIf
	//If ::B1_CODZHO='2'
	//	cQuery += "   AND SB1.B1_CODZHO <>'' "
	//EndIf
	cQuery +=" GROUP BY B2_COD ,B1_CODZHO,B1_MSBLQL "
	cQuery := ChangeQuery( cQuery )
			
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Nenhuma saldo a ser exibido." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"Saldo": [')

		While (cArea)->( !Eof() )
		
			nCount++

			::SetResponse('{')
			
			nX := 0
			For nX := 1 To nCampo
			
				::SetResponse('"')
				::SetResponse(aCampo[nX][2]) 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				
				
				::SetResponse( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) )
				 
				
				::SetResponse('"')				
				
				If nX < nCampo 
					::SetResponse(',')
				EndIf
							
			Next nX
			
			::SetResponse('}')

			If nCount < nReg
			 	::SetResponse(',')
			EndIf	
	
			(cArea)->( dbSkip() )
	  			
		EndDo
	
		::SetResponse(']}')
		
		(cArea)->( dbCloseArea() )
		
	EndIf
		
Return( lOk )
