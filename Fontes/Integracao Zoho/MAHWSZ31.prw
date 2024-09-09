#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Tabela de preco    .                                       ���
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

WSRESTFUL MAHTABPREA DESCRIPTION "Tabela de Preco"

	WSDATA DA1_CODTAB AS STRING
    WSDATA DA1_JOB    AS STRING
    WSDATA DA1_CODPRO AS STRING
	WSDATA DA1_DATADE  AS STRING
	WSDATA DA1_DATAAT  AS STRING
	WSMETHOD GET DESCRIPTION "Listar Tabela de Preco" WSSYNTAX "/MAHTABPREA" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Tabela de Preco Protheus.               ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE DA1_CODTAB,DA1_JOB,DA1_CODPRO,DA1_DATADE,DA1_DATAAT WSSERVICE MAHTABPREA
	
	Local cQuery	:= ""
	Local cArea		:= ""
	Local aCampo	:= {}
	Local nX		:= 0
	Local nCount	:= 0
	Local nReg		:= 0
	Local nCampo	:= 0
	Local lOk		:= .T.	
	Local cFilEmp	:= '01'
	Local cFilPed	:= 	'0101'
	Local cDataDe 	:= ""
	Local cDataAt 	:= ""
	
	Conout('MAHTABPREA - Integracao Lista de Preco')
	 
	//RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cFilEmp,cFilPed,,,,GetEnvServer(),{"SB1","DA1"} ) 

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
	aAdd(aCampo, {"DA1_CODTAB","CODTAB"})	
	aAdd(aCampo, {"DA1_CODPRO","DESCRI"})
	aAdd(aCampo, {"DA1_PRCVEN","DATDE"})
	aAdd(aCampo, {"MAX(DA1_ITEM)","ITEM"})
	aAdd(aCampo, {"B1_CODZHO",  "ID_ZOHO"})
	aAdd(aCampo, {"MAX(DA1.R_E_C_N_O_)", "ID"})	
	aAdd(aCampo, {"DA1_CODTIP", "TIPCOD"})
	aAdd(aCampo, {"DA0_DESCRI", "DESCRITAB"})
	
	Conout('MAHTABPREA - Ambiente')
	Conout(cEmpAnt)
	Conout(cFilAnt)
	if empty(::DA1_DATADE)
		cDataDe := dtos(dDataBase-1)
		cDataDe := substr(cDataDe,1,4)+"-"+substr(cDataDe,5,2)+"-"+substr(cDataDe,7,2)
	else
		cDataDe := substr(::DA1_DATADE,1,4)+"-"+substr(::DA1_DATADE,5,2)+"-"+substr(::DA1_DATADE,7,2)
	endif
	if empty(::DA1_DATAAT)
		cDataAt := dtos(dDataBase-1)
		cDataAt := substr(cDataAt,1,4)+"-"+substr(cDataAt,5,2)+"-"+substr(cDataAt,7,2)
	else
		cDataAt := substr(::DA1_DATAAT,1,4)+"-"+substr(::DA1_DATAAT,5,2)+"-"+substr(::DA1_DATAAT,7,2)
	endif
	
	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " 	FROM DA1010 DA1  "
	cQuery += " INNER JOIN SB1010 SB1 ON (SB1.B1_FILIAL = DA1.DA1_FILIAL AND SB1.B1_COD = DA1.DA1_CODPRO AND SB1.B1_MSBLQL<>'1' AND (SB1.B1_TIPO IN ('M1','M2','M3','M4','M5') OR (B1_TIPO = 'AI' AND B1_COD LIKE '%IMB' ) ) AND SB1.D_E_L_E_T_ <> '*') "
	cQuery += " INNER JOIN DA0010 DA0 ON (DA0.DA0_FILIAL = DA1.DA1_FILIAL AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA0.D_E_L_E_T_<>'*' )  "
	cQuery += " WHERE "
	cQuery += " 	DA1.DA1_FILIAL = '" + xFilial( 'DA1' ) + "'"
	cQuery += " AND DA1.D_E_L_E_T_<>'*'   "
	cQuery += " AND DA1.DA1_ITEM=(SELECT  MAX(DA1MAX.DA1_ITEM) FROM DA1010 DA1MAX WHERE DA1MAX.DA1_FILIAL = '" + xFilial( 'DA1' ) + "'" + " AND DA1MAX.DA1_FILIAL=DA1.DA1_FILIAL AND DA1MAX.DA1_CODTAB=DA1.DA1_CODTAB AND DA1.DA1_CODPRO=DA1MAX.DA1_CODPRO AND DA1MAX.D_E_L_E_T_<>'*')  "
	If !Empty( ::DA1_CODTAB )
		cQuery += " AND DA1_CODTAB = '"+ Upper( ::DA1_CODTAB ) +"'"
	EndIf
	If !Empty( ::DA1_CODPRO )
		cQuery += " AND DA1_CODPRO = '"+ Upper( ::DA1_CODPRO ) +"'"
	EndIf
	cQuery += " AND ((CONVERT(DATE,DA1.S_T_A_M_P_) >=  '"+cDataDe+"' )) AND ((CONVERT(DATE,DA1.S_T_A_M_P_) <=  '"+cDataAt+"' )) "
	cQuery += " GROUP BY  "
	cQuery += " DA1_CODTAB, "
	cQuery += " DA1_CODPRO,  "
	cQuery += " DA1_PRCVEN,  "
	cQuery += " B1_CODZHO,  "
	cQuery += " DA1_CODTIP, "
	cQuery += " DA0_DESCRI "
	CONOUT("MAHTABPREA - "+cQuery)
  /*
	If ::DA1_JOB='1'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 0 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='2'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 2500 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='3'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 5000 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='4'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 7500 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='5'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 10000 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='6'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 12500 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='7'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 15000 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='8'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 17500 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='9'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 20000 ROWS FETCH NEXT 2500 ROWS ONLY " 
	End
	*/
	If ::DA1_JOB='1'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 0 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='2'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 3500 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='3'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 7000 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='4'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 10500 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='5'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 14000 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='6'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 17500 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='7'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 21000 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='8'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 24500 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End
	
	If ::DA1_JOB='9'
		cQuery += " order by  Max(DA1.R_E_C_N_O_) asc OFFSET 28000 ROWS FETCH NEXT 3500 ROWS ONLY " 
	End

		
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Verifique o parametro ou nenhum Item da Tabela a ser exibido." )
	
	Conout('MAHTABPREA - Verifique o parametro ou nenhum Item da Tabela a ser exibido.')
	 
	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"PRECO": [')

		While (cArea)->( !Eof() )
		
			nCount++

			::SetResponse('{')
			
			nX := 0
			For nX := 1 To nCampo
			
				::SetResponse('"')
				::SetResponse(aCampo[nX][1]) 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				
				If aCampo[nX][1] $ "B1_DESC"
					::SetResponse( U_NoCharEsp( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) ) )
				Else
					::SetResponse( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) )
				EndIf 
				
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
		
	Conout('MAHTABPREA - Finalizacao Ok')
	EndIf
		
Return( lOk )
