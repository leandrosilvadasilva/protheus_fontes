#Include "Totvs.ch"
#Include "Fileio.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHM015 � Autor � Ednei Silva	      � Data � 17/08/2018 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �  Exportador de tabelas do Protheus para CSV                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � 					                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA01 = Indica se a rotina esta sendo executada via       ���
���          � schedule ou via menu                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico 				                                  ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
��� Gregory A  �18/01/17� Compactar arquivos por .bat e enviar para https ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
	cDescRot += " e Nota Fiscal de Saida para um diret�rio no Protheus_Data"
	
	oProcess := tNewProcess():New("MAHM015",cCadastro,bProcess,cDescRot,cPerg,aInfoCustom, .T.,5, "", .T. )
	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � M015EXEC � Autor � Ednei Silva         � Data �  17/08/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao � Processa uma das rotinas selecionadas                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M015EXEC( oExp1,lExp1 )                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oExp1 - Propriedades do objeto tNewProcess                 ���
���          � lExp1 - Se esta sendo executado por schedule ou manual     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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


//---- Finaliza��o ----
If !lAuto
	Aviso( "Exporta��o finalizada.", cMsg, {"OK"},3)
	oProcess:SaveLog("Fim da Execucao Total")
EndIf

Return




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � M015SITE � Autor � Ednei Silva      � Data �  17/08/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao � Processa a exportacao do cadastro de clientes              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � M010CriaSX1 � Autor � Ednei Silva      � Data � 17/08/2018  ��
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria as perguntas no dicionario                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CriaSX1(cExp1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cExp1 = Nome da pergunta                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente TOTVS RS                                ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function M010CriaSX1(cPerg)

Local aArea		:= GetArea()
Local aAreaSX1	:= SX1->( GetArea() )
Local aPerg		:= {}
Local aHelp		:= {}
Local nX       	:= 0

cGrupoPerg := PadR( cPerg, Len(SX1->X1_GRUPO) )

//     Grupo    Ordem Perguntas    			  	  	  	  Variavel  Tipo Tam Dec Variavel   GSC  F3  Def01 Def02 Def03 Def04 Def05 Valid
aAdd( aPerg, { "01", "Envia para FTP?"		 			, "mv_ch0", "C", 01 , 0 ,"MV_PAR01","C" ," ", "Sim","N�o"," " ," "	," "  ,"" } )
aAdd( aPerg, { "02", "Endere�o do FTP?"					, "mv_ch1", "C", 90 , 0 ,"MV_PAR02","G" ," ",""    ,""   ,""  ,""   ,""   ,"" } )
aAdd( aPerg, { "03", "Usuario do FTP?"     				, "mv_ch2", "C", 50 , 0 ,"MV_PAR03","G" ," ",""    ,""   ,""  ,""	,""   ,"" } )
aAdd( aPerg, { "04", "Senha do FTP?"   					, "mv_ch3", "C", 30 , 0 ,"MV_PAR04","G" ," ",""    ,""   ,""  ,"" 	,""   ,"" } )
aAdd( aPerg, { "05", "Diretorio destino do FTP"			, "mv_ch4", "C", 35 , 0 ,"MV_PAR05","G" ," ",""    ,""   ,""  ,"" 	,""   ,"" } )
aAdd( aPerg, { "06", "Exportar Produtos para Site?"		, "mv_ch5", "N", 01 , 0 ,"MV_PAR06","C" ," ", "Sim","N�o"," " ," "	," "  ,"" } )

//     Grupo Help
aAdd(aHelp,{"Informe se o arquivo deve ser enviado ", " ao servidor FTP ", "  os campos abaixo devem ser preenchidos" })
aAdd(aHelp,{"Informar o endere�o do ftp sem a porta. ", " Por exemplo:  ", " ftp.totvs.com.br" })
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � M015FTP  � Autor � Ednei Silva         � Data �  15/12/2016���
�������������������������������������������������������������������������Ĵ��
���Descricao � Envia os arquivos para o servidor FTP                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
	oProcess:SaveLog("Inicio da compacta��o dos arquivos...")
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
	cRetLog += "N�o foi poss�vel realizar o envio."
	ConOut(cRetLog)
EndIf

Return( cRetLog )


Static Function fUpFile(cFileOrig,cServer,nPort,cUser,cPass,cFTPDest)
Local lClose   := .F.
Local cTemp    := "\x_ftp_site\"
Local nRet     :=1

//Se tiver o arquivo e o destino
If ! Empty(cFileOrig) .And. !Empty(cFTPDest)
	
	//Tenta estabelecer a conex�o
	If FTPConnect(cServer, nPort, cUser, cPass)
		
		//Pega apenas o nome do arquivo com a extens�o
		cNameFile := SubStr(cFileOrig, RAt("\", cFileOrig) + 1, Len(cFileOrig))
		
		//Se n�o existir a pasta tempor�ria dentro da Protheus Data, cria ela
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
			ConOut("N�o foi poss�vel mudar o diret�rio de Upload!")
		EndIf
		
		//Fecha a conex�o
		lClose := FTPDisconnect()
		If ! lClose
			ConOut("Falha ao fechar a conex�o!")
		EndIf
	Else
		ConOut("Erro de conex�o!")
	EndIf
EndIf
Return nRet