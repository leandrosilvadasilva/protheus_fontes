#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#Include "rwmake.ch"
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: M460FIM      || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Ponto de Entrada após inclusão do Documento de Saída         ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function M460FIM()

	Local aArea := GETAREA()
	Local existeAtivo := .F.
	Local notaAtivo := ''
	Local _aPreNF := {}

	If FindFunction( 'U_CI_M460F' )
		U_CI_M460F()
	EndIf

	/*
		PROJETO ATIVO x WMS - IATAN EM 23/11/2023
	*/

	//CASO PEDIDO POSSUA OPERAÇÃO 60.:
	//1. CRIAR PRODUTO COM SUFIXO "IMB"
	existeAtivo := validProdAtivo()
	
	IF existeAtivo == .T.

		//2. GERAR DOCUMENTO DE ENTRADA COM TES 175
		notaAtivo := geraEntradaAtivo(@_aPreNF)


		//3. FORÇAR INTEGRAÇÃO PARA WMS (SF1140I)
		//IATAN EM 02/01/2024 -- COMO PODE HAVER MAIS DE UM ITEM, A FUNÇÃO ACIMA DEVE RETORNAR UM ARRAY
		//E ESTE ARRAY DEVE SER UTILIZADO PARA INTEGRAÇÃO DOS ITENS NO WMS
		//IATAN EM 11/01/2024 - PROCESSO DEVE SER EXECUTADO NA ROTINA "GERA_DANFE"
		/*IF !EMPTY(ALLTRIM(notaAtivo))
			integraWMS(notaAtivo, _aPreNF)
		ENDIF*/


	ENDIF

	RESTAREA( aArea )

Return


Static Function validProdAtivo( )

	Local _cQry := ""
	Local existe := .F.

  _cQry := " SELECT *  "
  _cQry += " FROM SD2010 SD2 INNER JOIN SC6010 SC6 ON C6_FILIAL = D2_FILIAL AND C6_NUM = D2_PEDIDO AND C6_CLI = D2_CLIENTE AND C6_LOJA = D2_LOJA AND C6_ITEM = D2_ITEMPV  "
  _cQry += " WHERE SD2.D_E_L_E_T_ <> '*'  AND SC6.D_E_L_E_T_ <> '*' "
  _cQry += "        AND D2_FILIAL = '" + SF2->F2_FILIAL + "' "
  _cQry += "        AND D2_DOC = '" + SF2->F2_DOC + "' "
  _cQry += "        AND D2_SERIE = '" + SF2->F2_SERIE + "' "
  _cQry += "        AND D2_CLIENTE = '" + SF2->F2_CLIENTE + "' "
  _cQry += "        AND D2_LOJA = '" + SF2->F2_LOJA + "' "
  _cQry += "        AND C6_OPER = '60' "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SD2",.T.,.T. )
  
  While (_SD2->(!EOF()))
	
	existe := .T.

	//POSICIONA NA SB1 PARA VERIFICAR SE O PRODUTO COM SUFIXO "IMB" JÁ EXISTE ...
	POSICIONE("SB1", 1, XFILIAL("SB1")+ALLTRIM(_SD2->D2_COD)+"IMB", "B1_COD" )
	IF ALLTRIM(SB1->B1_COD) == ALLTRIM(_SD2->D2_COD)+"IMB"
		//ALERT("PASSO 1.: PRODUTO " + ALLTRIM(SB1->B1_COD) + " JÁ CADASTRADO")
	ELSE 
		//ALERT("PASSO 1.: CADASTRAR PRODUTO " + ALLTRIM(_SD2->D2_COD)+"IMB")
		cadIMB(_SD2->D2_COD)
	ENDIF

    _SD2->(DbSkip())
  End
  _SD2->(DBCloseArea())

return existe


Static Function geraEntradaAtivo(_aPreNF)


	Local aLinha    := {}  
	Local cNum := ''
	Local nota := SF2->F2_DOC
	Local serie := SF2->F2_SERIE
	Local nY
	Local lote
	Local dtFabric
	Local dtValid
	Local 

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

  _cQry := " SELECT *  "
  _cQry += " FROM SD2010 SD2 INNER JOIN SC6010 SC6 ON C6_FILIAL = D2_FILIAL AND C6_NUM = D2_PEDIDO AND C6_CLI = D2_CLIENTE AND C6_LOJA = D2_LOJA AND C6_ITEM = D2_ITEMPV "
  _cQry += " WHERE SD2.D_E_L_E_T_ <> '*' AND SC6.D_E_L_E_T_ <> '*' "
  _cQry += "        AND D2_FILIAL = '" + SF2->F2_FILIAL + "' "
  _cQry += "        AND D2_DOC = '" + SF2->F2_DOC + "' "
  _cQry += "        AND D2_SERIE = '" + SF2->F2_SERIE + "' "
  _cQry += "        AND D2_CLIENTE = '" + SF2->F2_CLIENTE + "' "
  _cQry += "        AND D2_LOJA = '" + SF2->F2_LOJA + "' "
  _cQry += "        AND C6_OPER = '60' "
//  _cQry += "        AND D2_TES = '688' "


	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SD2",.T.,.T. )
  
	aCabec := {}
	aItens := {}
	
	//IATAN EM 07/05/2024 - TRATAMENTO DA LOJA DO FORNECEDOR
	lojaFor   := "00"+RIGHT( CFILANT, 2)
		
	//FORMULARIOS DE EMISSÃO PROPRIA COM SERIE = IMB
	//cNum := NxtSx5Nota("IMB", .T., GetNewPar("MV_TPNRNFS","3"))
	//IATAN EM 11/01/2024 - A PEDIDO DE EDER, UTILIZAR O MESMO NUMERO DA NOTA DE SAÍDA
	aadd(aCabec,{"F1_FILIAL"  , SF2->F2_FILIAL, NIL}) 
	aadd(aCabec,{"F1_TIPO"    ,"N", NIL}) 
	aadd(aCabec,{"F1_FORMUL"  ,"S", NIL}) 
	aadd(aCabec,{"F1_DOC"     ,SF2->F2_DOC, NIL}) 
	aadd(aCabec,{"F1_SERIE"   ,"IMB", NIL}) 
	aadd(aCabec,{"F1_EMISSAO" ,DDATABASE, NIL}) 
	aadd(aCabec,{"F1_FORNECE" ,"000052", NIL}) 
	aadd(aCabec,{"F1_LOJA"    ,lojaFor, NIL}) 
	aadd(aCabec,{"F1_ESPECIE" ,"NFE", NIL}) 

	aadd(aCabec,{"F1_XNUMAT" ,nota, NIL}) 
	aadd(aCabec,{"F1_XSERAT" ,serie, NIL}) 

	While (_SD2->(!EOF()))

		Posicione("SB1",1,xFilial("SB1")+ALLTRIM(_SD2->D2_COD)+"IMB","B1_DESC")

		aadd(aLinha,{"D1_FILIAL"  ,_SD2->D2_FILIAL,  Nil}) 
		aadd(aLinha,{"D1_ITEM"    ,"00"+_SD2->D2_ITEM,    Nil}) 
		aadd(aLinha,{"D1_COD"     ,SB1->B1_COD, Nil}) 
		aadd(aLinha,{"D1_LOCAL"   ,_SD2->D2_LOCAL,Nil}) 
		aadd(aLinha,{"D1_QUANT"   ,_SD2->D2_QUANT,     Nil}) 
		aadd(aLinha,{"D1_VUNIT"   ,_SD2->D2_PRCVEN ,Nil}) 
		aadd(aLinha,{"D1_TOTAL"   ,_SD2->D2_TOTAL ,Nil}) 
		//IATAN EM 09/05/2024 A APEDIDO DE TIAGO
		//aadd(aLinha,{"D1_TES"     ,"175" ,Nil}) 
		aadd(aLinha,{"D1_TES"     ,ALLTRIM( GETMV("MV_XTESATV") ) ,Nil}) 
		aadd(aLinha,{"D1_CF"      ,"1551" ,Nil}) 
		aadd(aLinha,{"D1_DOC"     ,SF2->F2_DOC,Nil}) 
		aadd(aLinha,{"D1_SERIE"   ,"IMB",Nil}) 
		aadd(aLinha,{"D1_EMISSAO" ,DDATABASE,Nil}) 
		aadd(aLinha,{"D1_LOTECTL" ,_SD2->D2_LOTECTL,Nil}) 
		aadd(aLinha,{"D1_DTVALID" ,STOD(_SD2->D2_DTVALID),Nil})  // IATAN EM 08/02/2024
		aadd(aLinha,{"D1_DFABRIC" ,STOD(_SD2->D2_DFABRIC),Nil})  // IATAN EM 08/02/2024
		aadd(aLinha,{"D1_IDENTB6" ,_SD2->D2_IDENTB6,Nil}) 
		aadd(aLinha,{"AUTDELETA" ,"N" ,Nil})

		lote     := _SD2->D2_LOTECTL
		dtFabric := STOD(_SD2->D2_DFABRIC)
		dtValid  := STOD(_SD2->D2_DTVALID)

		//SALVA OS ITENS DE DOCUMENTO DE SAÍDA
        AADD(_aPreNF,{{"FILIAL", CEMPANT+CFILANT},;
                    {"NUMDOC", SF2->F2_DOC},;
                    {"SERIEDOC", "IMB"},;
                    {"EMISSAO" , DDATABASE},;
                    {"NROITEM" , _SD2->D2_ITEM},;
                    {"CODITEM" , SB1->B1_COD},;
                    {"DESCITEM", SB1->B1_DESC},;  
                    {"REFERENCIA", SB1->B1_COD},; //Opcional
                    {"TAMANHO"   , ""},;   // Opcional
                    {"CODFORNEC" , "000052" + lojaFor},;
                    {"NOMEFORNEC", "MAHOSPITALAR"},;  
                    {"CODFABRIC" , ""},;  //Opcional  
                    {"NOMEFABRIC", ""},; //Opcional
                    {"QTDE"      , _SD2->D2_QUANT},;
                    {"DOCSTATUS" , "O"},;  // O: Aberto, C: Fechado 
                    {"TIPO"      , ""},;      //Opcional
                    {"DATAFABRIC", _SD2->D2_DFABRIC},;      //Opcional
                    {"DATAVALID" , _SD2->D2_DTVALID},;      //Opcional
                    {"LOTE"      , _SD2->D2_LOTECTL},;    //Opcional 
                    {"CARDCODESAIDA"  , _SD2->D2_DOC},;    //SOMENTE PARA ATIVO
                    {"SERIALSAIDA"    , _SD2->D2_SERIE},;    //SOMENTE PARA ATIVO
                    {"LINENUMSAIDA"   , _SD2->D2_ITEM},;    //SOMENTE PARA ATIVO
                    {"IMOBILIZADO", .T.};    //Opcional - SOLICITADO POR GABRIEL EM CALL DIA 23/11/2023
        })

		aadd(aItens,aLinha)  
		aLinha := {}

	_SD2->(DbSkip())
	End
	_SD2->(DBCloseArea())

	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3)

	CONOUT("================================")
	VarInfo("aCabec", aCabec)
	VarInfo("aItens", aItens)

	IF lMsErroAuto 
//			MOSTRAERRO()

		aLogErr := GetAutoGRLog()
		VarInfo("ERRO_PE_M460FIM", aLogErr)
		//aLogErr	:= TrataErro( aLogErr ) //Trata log a partir do erro do execauto	
		cErro := ""
		For nY := 1 To Len(aLogErr)
			//IF ( 'AJUDA:' $ aLogErr[nY] ) .OR. ( '< -- Invalido' $ aLogErr[nY] )
				//IF '< -- Invalido' $ aLogErr[nY] 
					cErro += "[ " + STRTRAN(aLogErr[nY], "\r\n", " ") + " ]"
				//ELSE
				//	cErro += STRTRAN(aLogErr[nY], "\r\n", " ")
				//ENDIF
			//ENDIF
		Next nY

		CONOUT("ERRO PE_M460FIM.: " + cErro)

	ELSE 
		cNum := SF1->F1_DOC

		//IATAN EM 29/02/2024
		/*RECLOCK("SN1", .F.)
			SN1->N1_XLOTE  := lote
			SN1->N1_XDTFAB  := dtFabric
			SN1->N1_XDTVAL := dtValid
		SN1->(MSUNLOCK())*/

		/*RECLOCK("SF1", .F.)
			SF1->F1_XNUMAT := nota
			SF1->F1_XSERAT := serie
		SF1->(MSUNLOCK())*/
	ENDIF

	//IATAN EM 12/03/2024
	//IATAN EM 25/04/2024 --> TROCADO PARA USER FUNCTION CHAMADA EM INICIALIZADOR PADRÃO
	/*
	IF RECLOCK("SN1", .F.)
		SN1->N1_XLOTE  := lote
		SN1->N1_XDTFAB  := dtFabric
		SN1->N1_XDTVAL := dtValid
		SN1->(MSUNLOCK())
	ELSE
		CONOUT("ERRO_RECLOCK_SN1")
	ENDIF*/


Return cNum


Static Function integraWMS( nota, _aPreNF )

	Local nI

	// VOLTA ALTERANDO O NUMERO DA NOTA POIS O NUMERO SÓ É GERADO APÓS O EXECAUTO 
	FOR nI := 1 TO LEN(_aPreNF)
		_aPreNF[nI][2][2] := nota
	Next nI

	sleep(40000)
	//ENVIA DOCUMENTO DE ENTRADA PARA WMS
    U_MAPWMS05(_aPreNF)

  //_SD1->(DBCloseArea())

return


Static Function cadIMB(produto)

	Local aArea     := GetArea()
    Local aEstru    := {}
    Local aConteu   := {}
    Local nPosFil   := 0
    Local cCampoFil := ""
    Local cQryAux   := ""
    Local nAtual    := 0

	Local cTabelaAux := "SB1"
    Local cChaveAux  := "B1_COD"
    Local cFilAtuAux := ""
    Local cCodAtuAux := ""
    Local cFilNovAux := ""
    Local cCodNovAux := ""


	DbSelectArea("SB1")
	//Pega a estrutura da tabela
    aEstru := SB1->(DbStruct())
	//Encontra o campo filial
    nPosFil   := aScan(aEstru, {|x| "FILIAL" $ AllTrim(Upper(x[1]))})
    cCampoFil := aEstru[nPosFil][1]

	POSICIONE("SB1", 1, xFilial("SB1")+produto, "B1_COD")

	//Percorre a estrutura
	For nAtual := 1 To Len(aEstru)
		//Se for campo filial
		/*If Alltrim(aEstru[nAtual][1]) == Alltrim(cCampoFil)
			aAdd(aConteu, cFilNovAux)
			*/	
		//Se for o campo de código
		If Alltrim(aEstru[nAtual][1]) == Alltrim("B1_COD")
			aAdd(aConteu, ALLTRIM(produto)+"IMB" )
		ElseIf Alltrim(aEstru[nAtual][1]) == Alltrim("B1_TIPO")
			aAdd(aConteu, "AI" )
		ElseIf Alltrim(aEstru[nAtual][1]) == Alltrim("B1_CONTA")
			aAdd(aConteu, "12301008" )
		ElseIf Alltrim(aEstru[nAtual][1]) == Alltrim("B1_CC")
			aAdd(aConteu, "101001" )
		Else
			aAdd(aConteu, &("SB1->"+aEstru[nAtual][1]))
		EndIf
	Next

	RecLock("SB1", .T.)
		//Percorre a estrutura
		For nAtual := 1 To Len(aEstru)
			//Grava o novo valor
			&(aEstru[nAtual][1]) := aConteu[nAtual]
		Next
	SB1->(MsUnlock())	

	// PARA INTEGRAÇÃO COM WMS
	_sNomeGrupo := Alltrim(Posicione("SBM", 1, xFilial("SBM")+SB1->B1_GRUPO, "BM_DESC"))
	_sNomeSecao := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"02"+SB1->B1_TIPO, "X5_DESCRI"))
	_sNomeLinha := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"ZX"+SB1->B1_MARCA, "X5_DESCRI"))
	
//	espacos := TamSX3('B1_COD')[1]
//	_aItens := {{"CODITEM",SB1->B1_COD+REPLICATE(" ", espacos-LEN(SB1->B1_COD))},;
	POSICIONE("SB1", 1, XFILIAL("SB1")+SB1->B1_COD, "B1_COD")
	_aItens := {{"CODITEM",SB1->B1_COD},;
				{"NOMEITEM",SB1->B1_DESC},;
				{"TIPO","F"},;
				{"CODBAR",SB1->B1_CODBAR},;
				{"CODGRP",SB1->B1_GRUPO},;
				{"NOMEGRP",_sNomeGrupo},;
				{"UM",SB1->B1_UM},;
				{"ULTCOMPRA", SB1->B1_UPRC},;
				{"NCM",SB1->B1_POSIPI},;
				{"ATIVO",IIF(SB1->B1_MSBLQL <> '1',.T.,.F.)},;                            
				{"CODSEC",SB1->B1_TIPO},;
				{"NOMESEC",_sNomeSecao},;
				{"CODLN",SB1->B1_MARCA},;
				{"RMS",SB1->B1_NRANVIS},;
				{"CARDNAMEFAB",SB1->B1_FABRIC},;
				{"CARDCODADD",SB1->B1_ENDFABR},;
				{"NOMELN",_sNomeLinha},;
				{"IMOBILIZADO",.T.};
				}

	retorno := U_MAPWMS02(_aItens)

	restArea(aArea)

Return
