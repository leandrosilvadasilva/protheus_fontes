#Include "TOTVS.CH"
#INCLUDE "fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHWS010 ³ Autor ³ Ednei R. Silva        ³ Data ³ MAR/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para integracao Protheus X Zoho.       ³±±
±±³          ³ Cadastro de Cliente.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³															              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MAHJSCLI ( cA1_COD, cA1_LOJA, cA1_CGC, cA1_DTHDE, cA1_DTHATE)
    Local cConteudo := ""
	Local cQuery	:= ""
	Local cArea		:= ""
	Local aCampo	:= {}
	Local nX		:= 0
	Local nCount	:= 0
	Local nReg		:= 0
	Local nCampo	:= 0
	Local lOk		:= .T.	
	 
	 
	aAdd(aCampo, {"A1_COD", "COD"})	
	aAdd(aCampo, {"A1_LOJA", "LOJA"})
	aAdd(aCampo, {"A1_PESSOA", "PESSOA"})
	aAdd(aCampo, {"A1_NOME", "NOME"})
	aAdd(aCampo, {"A1_END", "ENDERECO"})	
	aAdd(aCampo, {"A1_NREDUZ", "NREDUZ"})
	aAdd(aCampo, {"A1_BAIRRO", "BAIRRO"})
	//aAdd(aCampo, {"A1_TIPO", "TIPO"})
	aAdd(aCampo, {"A1_EST", "EST"})
	aAdd(aCampo, {"A1_CEP", "CEP"})
	aAdd(aCampo, {"A1_COD_MUN", "COD_MUN"})
	aAdd(aCampo, {"A1_MUN", "MUN"})
	aAdd(aCampo, {"A1_DDD", "DDD"})
	aAdd(aCampo, {"A1_TEL", "TEL"})
	aAdd(aCampo, {"A1_CGC", "CGC"})
	aAdd(aCampo, {"A1_INSCR", "INSCR"})
	aAdd(aCampo, {"A1_PAIS", "PAIS"})
	aAdd(aCampo, {"A1_COND", "COND"})
	aAdd(aCampo, {"A1_MSBLQL", "MSBLQL"})
	aAdd(aCampo, {"A1_SALDUP", "SALDUP"})
	aAdd(aCampo, {"A1_VEND", "VEND"})
	aAdd(aCampo, {"A1_ZOHDTH", "ZOHDTH"})
	aAdd(aCampo, {"D_E_L_E_T_", "DELET"})

	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += "	FROM " + RetSQLName("SA1")
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
    cQuery += "   AND A1_COD IN ('000662','000698','000751') "
	
	If !Empty( cA1_COD ) 

		cQuery += "   AND A1_COD = '"+ Upper(cA1_COD ) +"'"
		
		If !Empty( cA1_LOJA ) 
			cQuery += "   AND A1_LOJA = '"+ Upper( cA1_LOJA ) +"'"
		EndIf
		
	EndIf
		
	If !Empty( cA1_CGC )
		cQuery += "   AND A1_CGC = '"+ cA1_CGC +"'"
	EndIf

	If !Empty( cA1_DTHDE ) .Or. !Empty( cA1_DTHATE )
		cQuery  += "  AND A1_ZOHDTH BETWEEN '" + AllTrim(cA1_DTHDE) + "' AND '" + AllTrim(cA1_DTHATE) + "'"
	EndIf
	
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		Conout("Nenhum cliente a ser exibido." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		//cConteudo :='{"CLIENTE": ['
        //cConteudo :='{"CLIENTE": ['
		While (cArea)->( !Eof() )
		
			nCount++

			cConteudo +='{'
			
			nX := 0
			For nX := 1 To nCampo
			
				cConteudo +='"'
				cConteudo += aCampo[nX][1] 
				cConteudo += '"'
				cConteudo += ':'
				cConteudo += '"'
				
				If aCampo[nX][1] $ "A1_END|A1_NOME|A1_NREDUZ|A1_BAIRRO|A1_CONTATO"
					cConteudo += U_NoCharEsp( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) ) 
				Else
					cConteudo += AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) 
				EndIf 
				
				cConteudo += '"'				
				
				If nX < nCampo 
					cConteudo += ','
				EndIf
							
			Next nX
			
			cConteudo += '}'

			If nCount < nReg
			 	cConteudo += ','
			EndIf	
	
			(cArea)->( dbSkip() )
	  			
		EndDo
	
		//cConteudo +=']}'
		
		(cArea)->( dbCloseArea() )
		

		If u_sToZoho(AllTrim(GetMV("ES_URLZCLI")),cConteudo)
			alert('Cliente exportados com sucesso')
		endif
	EndIf
	         
	
Return( lOk )


