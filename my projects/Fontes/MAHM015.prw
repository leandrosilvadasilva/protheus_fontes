#Include "Totvs.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHM015 ³ Autor ³ Ednei Silva	      ³ Data ³ 17/08/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Exportador de tabelas do Protheus para CSV                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA01 = Indica se a rotina esta sendo executada via       ³±±
±±³          ³ schedule ou via menu                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico 				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Gregory A  ³18/01/17³ Compactar arquivos por .bat e enviar para https ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MAHM015( aParam )

Local lAuto		:= ( ValType(aParam) = "A" )
Local cCadastro	:= "Exportador de tabelas"
Local cDescRot	:= ""
Local aInfoCustom	:= {}
Local aTabelas	:= {"DA1","SB1"}
Local bProcess 	:= {||}
Local oProcess

Private cPerg := ""

If lAuto// Chamada via Schedule
	
	If RpcSetEnv(aParam[1],aParam[2],,,"FAT","MAHM015",aTabelas,,,,)
		BatchProcess(	cCadastro, cCadastro, "MAHM015", { || M015EXEC(oProcess,lAuto) }, { || .F. }  )
	EndIf
	
	RpcClearEnv()
	
Else
	
	cPerg := PadR( "MAHM015", Len( SX1->X1_GRUPO ), "" )
	
	M010CriaSX1( cPerg )
	
	Pergunte( cPerg, .F. )
	
	aAdd( aInfoCustom, { "Cancelar", { |oPanelCenter| oPanelCenter:oWnd:End() }, 	"CANCEL"	})
	
	bProcess := {|oProcess| M015EXEC(oProcess, lAuto ) }
	
	cDescRot := " Este programa tem o objetivo, exportar para CSV as tabelas de Clientes, Pedidos de Venda, Financeiro"
	cDescRot += " e Nota Fiscal de Saida para um diretório no Protheus_Data"
	
	oProcess := tNewProcess():New("MAHM015",cCadastro,bProcess,cDescRot,cPerg,aInfoCustom, .T.,5, "", .T. )
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M015EXEC ³ Autor ³ Ednei Silva         ³ Data ³  17/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa uma das rotinas selecionadas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M015EXEC( oExp1,lExp1 )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp1 - Propriedades do objeto tNewProcess                 ³±±
±±³          ³ lExp1 - Se esta sendo executado por schedule ou manual     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M015EXEC(oProcess, lAuto )

Local cMsg	:= ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

//Cria o diretorio caso nao exista no Protheus_Data
If !ExistDir( "\ExportaSite" )
	MakeDir( "\ExportaSite" )
EndIf

If !lAuto
	oProcess:SaveLog("Inicio da Execucao")
EndIf

//+------------------------------------------+
//| EXPORTACAO DO CADASTRO DE CLIENTES - SA1 |
//+------------------------------------------+
If lAuto//Via Schedule
	If GetMV("ES_EXPSITE") == 1
			cMsg += M015SITE(oProcess,lAuto)
	EndIf
Else	//Via Menu
	If MV_PAR06 == 1//1-Executa/2-Nao executa
		cMsg += M015SITE(oProcess,lAuto)
	EndIf
EndIf



//+------------------------------------+
//| EXPORTACAO DO ARQUIVO ZIP PARA FTP |
//+------------------------------------+
If lAuto//Se for via schedule
	If GetMV("ES_EXPSITE") == 1
		cMsg +=	M015FTP(oProcess, "produtossite.csv", lAuto )//Envia o arquivo para o FTP
	EndIf
Else//Se for rotina manual
	If MV_PAR01 == 1//Faz o Upload do arquivo para o FTP
		cMsg += M015FTP(oProcess, "produtossite.csv", lAuto )//Envia o arquivo para o FTP
	EndIf
EndIf


//---- Finalização ----
If !lAuto
	Aviso( "Exportação finalizada.", cMsg, {"OK"},3)
	oProcess:SaveLog("Fim da Execucao Total")
EndIf

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M015SITE ³ Autor ³ Ednei Silva      ³ Data ³  17/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do cadastro de clientes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M015SITE(oProcess,lAuto)

Local cAliasT	:= GetNextAlias()
Local cQuery 	:= ""
Local cMsg 		:= ""
Local cDscTip	:= ""
Local cExtracao	:= DtoC( Date() ) + " - " + Time()
Local nCont		:= 0
Local nHandle	:= 0

If !lAuto
	oProcess:SaveLog("Inicio da Exportacao da Tabela de Clientes (SA1)")
	oProcess:SetRegua1( 0 )
Else
	ConOut("Inicio da Exportacao da Tabela de Clientes (SA1) - SCHEDULE")
EndIf

//Analitical   01
//Cardinal     17
//ERB          11
//GE           04
//GMI          21
//HILLROM      05
//MEDITRONIC   06
//MONIT        20
//MIPM         23

cQuery:=" SELECT    "
cQuery+=" B1_COD,     "
cQuery+=" B1_DESC,    "
cQuery+=" B1_GRUPO,   "
cQuery+=" BM_DESC,    "
cQuery+=" B1_MARCA,   "
cQuery+=" B1_DESCMAR, "
cQuery+=" DA1_PRCVEN, "
cQuery+=" B1_TIPO,    "
cQuery+="CASE         "
cQuery+="      WHEN B1_TIPO='M1' THEN 'Equipamentos'   "
cQuery+="      WHEN B1_TIPO='M3' THEN 'Acessorios'     "
cQuery+="	   WHEN B1_TIPO='M4' THEN 'Consumiveis'    "
cQuery+="	   WHEN B1_TIPO='M5' THEN 'Suprimentos'    "
cQuery+="	   WHEN B1_TIPO='M2' THEN 'Partes e Pecas' "
cQuery+="END   AS B1_DESTIP, "
cQuery+=" REPLACE((ISNULL( CONVERT( VARCHAR(8000), CONVERT(VARBINARY(8000), B1_FICHATE)),'')),';',' ') AS MEMO "
cQuery+=" FROM " + RetSQLName("SB1") + " SB1 "
cQuery+=" INNER JOIN " + RetSQLName("DA1") + " DA1 ON (DA1.DA1_CODPRO= SB1.B1_COD) "
cQuery+=" INNER JOIN " + RetSQLName("SBM") + " SBM ON (SB1.B1_GRUPO= SBM.BM_GRUPO) "
cQuery+=" WHERE "

cQuery+=" DA1.DA1_CODTAB     IN("+AllTrim(GetMV("ES_TABSITE"))+" ) "
cQuery+=" AND SB1.B1_TIPO    IN("+AllTrim(GetMV("ES_TIPSITE"))+" ) "
cQuery+=" AND SB1.B1_MARCA   IN("+AllTrim(GetMV("ES_MARSITE"))+" ) "
cQuery+=" AND DA1.D_E_L_E_T_<>'*' "
cQuery+=" AND SB1.B1_GRUPO NOT IN("+AllTrim(GetMV("ES_GRUSITE"))+" ) "
cQuery+=" AND SB1.B1_COD   NOT IN("+AllTrim(GetMV("ES_CODSITE"))+" ) "
cQuery+=" AND SB1.D_E_L_E_T_<>'*' "
cQuery+=" AND SBM.D_E_L_E_T_<>'*' "
cQuery+=" AND SUBSTRING(B1_COD,LEN(B1_COD),1)<>'L' "

cQuery := ChangeQuery(cQuery)
MemoWrite("Produto_Site.SQL",cQuery)
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
TcSetField( cAliasT, "DA1_PRCVEN" , TamSX3("AO4_NVESTN")[3] , TamSX3("AO4_NVESTN")[1] , TamSX3("AO4_NVESTN")[2] )


If ( cAliasT )->( !Eof() )
	
	nHandle := fCreate("\ExportaSite\produtossite.csv", FC_NORMAL)
	
	//Titulo das colunas do arquivo
	FWRITE(	nHandle,"CodigoId"		+ ";" + ;
	"Descricao" 	+ ";" + ;
	"Grupo" 		+ ";" + ;
	"DesGrupo"		+ ";" + ;
	"Marca"			+ ";" + ;
	"DesMarca"		+ ";" + ;
	"Preco"	       	+ ";" + ;
	"DtAtualizacao"	+ ";" + ;
	"Tipo"       	+ ";" + ;
	"DescTipo"    	+ ";" + ;
	"Texto"			+ CRLF )
	
	nCont++
	
	While ( cAliasT )->( !Eof() )
		
		If !lAuto
			oProcess:IncRegua1("Exportando Produtos para o Site..." )
		EndIf
		
		//AllTrim( str(( cAliasT )->DA1_PRCVEN))   		+ ";" + ;
		
		FWRITE(	nHandle,AllTrim( ( cAliasT )->B1_COD ) 	+ ";" + ;
		AllTrim( ( cAliasT )->B1_DESC ) 				+ ";" + ;
		AllTrim( ( cAliasT )->B1_GRUPO)	  				+ ";" + ;
		AllTrim( ( cAliasT )->BM_DESC )	  				+ ";" + ;
		AllTrim( ( cAliasT )->B1_MARCA )	  	    	+ ";" + ;
		AllTrim( ( cAliasT )->B1_DESCMAR )	     		+ ";" + ;
		AllTrim( "" )  	                            	+ ";" + ;
		AllTrim( DtoC( date() )) 	 					+ ";" + ;
		AllTrim( ( cAliasT )->B1_TIPO )	  	        	+ ";" + ;
		AllTrim( ( cAliasT )->B1_DESTIP )	     		+ ";" + ;
		AllTrim( StrTran(( cAliasT )->MEMO,chr(13)+chr(10)," ")) + CRLF )
		nCont++
		
		( cAliasT )->( dbSkip() )
		
	EndDo
	
	cMsg += "Registros exportados da Tabela Preco/Produtos: " + cValToChar( nCont ) + CRLF
	
EndIf

( cAliasT )->( dbCloseArea() )

fClose( nHandle )

If !lAuto
	oProcess:SaveLog( "Fim da Exportacao dos produtos para Site" )
EndIf

Return( cMsg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010CriaSX1 ³ Autor ³ Ednei Silva      ³ Data ³ 17/08/2018  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no dicionario                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriaSX1(cExp1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 = Nome da pergunta                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente TOTVS RS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010CriaSX1(cPerg)

Local aArea		:= GetArea()
Local aAreaSX1	:= SX1->( GetArea() )
Local aPerg		:= {}
Local aHelp		:= {}
Local nX       	:= 0

cGrupoPerg := PadR( cPerg, Len(SX1->X1_GRUPO) )

//     Grupo    Ordem Perguntas    			  	  	  	  Variavel  Tipo Tam Dec Variavel   GSC  F3  Def01 Def02 Def03 Def04 Def05 Valid
aAdd( aPerg, { "01", "Envia para FTP?"		 			, "mv_ch0", "C", 01 , 0 ,"MV_PAR01","C" ," ", "Sim","Não"," " ," "	," "  ,"" } )
aAdd( aPerg, { "02", "Endereço do FTP?"					, "mv_ch1", "C", 90 , 0 ,"MV_PAR02","G" ," ",""    ,""   ,""  ,""   ,""   ,"" } )
aAdd( aPerg, { "03", "Usuario do FTP?"     				, "mv_ch2", "C", 50 , 0 ,"MV_PAR03","G" ," ",""    ,""   ,""  ,""	,""   ,"" } )
aAdd( aPerg, { "04", "Senha do FTP?"   					, "mv_ch3", "C", 30 , 0 ,"MV_PAR04","G" ," ",""    ,""   ,""  ,"" 	,""   ,"" } )
aAdd( aPerg, { "05", "Diretorio destino do FTP"			, "mv_ch4", "C", 35 , 0 ,"MV_PAR05","G" ," ",""    ,""   ,""  ,"" 	,""   ,"" } )
aAdd( aPerg, { "06", "Exportar Produtos para Site?"		, "mv_ch5", "N", 01 , 0 ,"MV_PAR06","C" ," ", "Sim","Não"," " ," "	," "  ,"" } )

//     Grupo Help
aAdd(aHelp,{"Informe se o arquivo deve ser enviado ", " ao servidor FTP ", "  os campos abaixo devem ser preenchidos" })
aAdd(aHelp,{"Informar o endereço do ftp sem a porta. ", " Por exemplo:  ", " ftp.totvs.com.br" })
aAdd(aHelp,{"Informar o login para acesso ao FTP"})
aAdd(aHelp,{"Informar a senha para acesso ao FTP"})
aAdd(aHelp,{"Informar o diretorio de destino", " no servidor FTP."})

aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao para o site " })

dbSelectArea("SX1")
dbSetOrder(1)
For nX := 1 to Len( aPerg )
	
	If !dbSeek( cGrupoPerg + aPerg[nX][1] )
		RecLock("SX1",.T.)
		SX1->X1_GRUPO	:= cGrupoPerg
		SX1->X1_ORDEM	:= aPerg[nX][01]
		SX1->X1_PERGUNT := aPerg[nX][02]
		SX1->X1_VARIAVL	:= aPerg[nX][03]
		SX1->X1_TIPO	:= aPerg[nX][04]
		SX1->X1_TAMANHO	:= aPerg[nX][05]
		SX1->X1_DECIMAL	:= aPerg[nX][06]
		SX1->X1_VAR01	:= aPerg[nX][07]
		SX1->X1_GSC		:= aPerg[nX][08]
		SX1->X1_F3		:= aPerg[nX][09]
		SX1->X1_Def01	:= aPerg[nX][10]
		SX1->X1_Def02	:= aPerg[nX][11]
		SX1->X1_Def03	:= aPerg[nX][12]
		SX1->X1_Def04	:= aPerg[nX][13]
		SX1->X1_Def05	:= aPerg[nX][14]
		SX1->X1_Valid	:= aPerg[nX][15]
		MsUnlock()
	EndIf
	
Next nX

RestArea( aAreaSX1 )
RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M015FTP  ³ Autor ³ Ednei Silva         ³ Data ³  15/12/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia os arquivos para o servidor FTP                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M015FTP( oProcess, cNomArq, lAuto )

Local cRetLog	:= ""
Local cEndFTP	:= ""
Local cUserFTP	:= ""
Local cPassFTP	:= ""
Local cDirFTP	:= ""
Local cDirArq	:= ""
Local aFiles	:= {}
Local aFilZip	:= {}
Local aInfo 	:= {}
Local nRet 		:= 0

If !lAuto
	oProcess:SaveLog("Inicio da compactação dos arquivos...")
	oProcess:SetRegua1( 0 )
Else
	ConOut("Inicio da compactacao dos arquivos - SCHEDULE")
EndIf



If !lAuto
	cEndFTP		:= AllTrim( MV_PAR02 )
	cUserFTP	:= AllTrim( MV_PAR03 )
	cPassFTP	:= AllTrim( MV_PAR04 )
	cDirFTP		:= AllTrim( MV_PAR05 )
	cDirArq     :=AllTrim(getMV("ES_DIRARQ"))
Else
	cEndFTP		:= AllTrim(getMV("ES_FTPSITE"))
	cUserFTP	:= AllTrim(getMV("ES_USESITE"))
	cPassFTP	:= AllTrim(getMV("ES_PASSITE"))
	cDirFTP		:= AllTrim(getMV("ES_DIRFTP"))
	cDirArq     :=AllTrim(getMV("ES_DIRARQ"))
EndIf



//Se o Arquivo existir
If File( cDirArq + cNomArq )
	
	nRet:=fUpFile(cDirArq+cNomArq,cEndFTP,21,cUserFTP,cPassFTP,cDirFTP )
	If nRet = 0
		cRetLog += "Upload bem sucedido, verifique no site. Arquivo: " + cNomArq + CRLF
	Else
		cRetLog += "Erro ao enviar o arquivo  " + cNomArq + CRLF
	EndIf
	
	ConOut(cRetLog)
Else
	cRetLog += "Não foi possível realizar o envio."
	ConOut(cRetLog)
EndIf

Return( cRetLog )


Static Function fUpFile(cFileOrig,cServer,nPort,cUser,cPass,cFTPDest)
Local lClose   := .F.
Local cTemp    := "\x_ftp_site\"
Local nRet     :=1

//Se tiver o arquivo e o destino
If ! Empty(cFileOrig) .And. !Empty(cFTPDest)
	
	//Tenta estabelecer a conexão
	If FTPConnect(cServer, nPort, cUser, cPass)
		
		//Pega apenas o nome do arquivo com a extensão
		cNameFile := SubStr(cFileOrig, RAt("\", cFileOrig) + 1, Len(cFileOrig))
		
		//Se não existir a pasta temporária dentro da Protheus Data, cria ela
		If ! ExistDir(cTemp)
			MakeDir(cTemp)
		EndIf
		
		CpyT2S(cFileOrig, cTemp)
		
		If FTPDirChange(cFTPDest)
			If FTPUpload(cTemp + cNameFile, cFTPDest + cNameFile)
				ConOut("Arquivo copiado para o FTP com sucesso!")
				nRet:=0
			Else
				ConOut("Falha ao copiar o arquivo para o FTP!")
			EndIf
			
		Else
			ConOut("Não foi possível mudar o diretório de Upload!")
		EndIf
		
		//Fecha a conexão
		lClose := FTPDisconnect()
		If ! lClose
			ConOut("Falha ao fechar a conexão!")
		EndIf
	Else
		ConOut("Erro de conexão!")
	EndIf
EndIf
Return nRet