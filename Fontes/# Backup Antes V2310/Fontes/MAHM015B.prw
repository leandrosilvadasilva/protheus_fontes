#Include "Totvs.ch"
#Include "Fileio.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MAHM015B    �Autor  �Ednei Silva         � Data �  07/08/20 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa disparado pelo schedule para gerar o arquivo CSV ���
���          �  e envia-lo ao Ftp                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function MAHM015B


Local cCadastro	:= "Exportador de tabelas"
Local cDescRot	:= ""
Local aInfoCustom	:= {}
Local aTabelas	:= {"DA1","SB1"}
Local bProcess 	:= {||}

Private cPerg := ""

If RpcSetEnv(aParam[1],aParam[2],,,"FAT","MAHM015B",aTabelas,,,,)
	BatchProcess(	cCadastro, cCadastro, "MAHM015B", { || M015EXEC() }, { || .F. }  )
EndIf

RpcClearEnv()


Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M015EXEC    �Autor  �Ednei Silva         � Data �  07/08/20 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Processa a criacao do arquivo CSV                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function M015EXEC()

Local cMsg	:= ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

//Cria o diretorio caso nao exista no Protheus_Data
If !ExistDir( "\ExportaSite" )
	MakeDir( "\ExportaSite" )
EndIf


If GetMV("ES_EXPSITE") == 1
	M015SITE()//Cria o Arquivo com os produtos
EndIf



If GetMV("ES_EXPSITE") == 1
	M015FTP("produtossite.csv")//Envia o arquivo para o FTP
EndIf



Return




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M015SITE    �Autor  �Ednei Silva         � Data �  07/08/20 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Consulta e montagem do arquivo CSV                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M015SITE()

Local cAliasT	:= GetNextAlias()
Local cQuery 	:= ""
Local cDscTip	:= ""
Local cExtracao	:= DtoC( Date() ) + " - " + Time()
Local nCont		:= 0
Local nHandle	:= 0


ConOut("Inicio da Exportacao da Tabela de Clientes (SA1) - SCHEDULE")


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
	
	
	
EndIf

( cAliasT )->( dbCloseArea() )

fClose( nHandle )


Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M015FTP     �Autor  �Ednei Silva         � Data �  07/08/20 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Envio do arquivo CSV o FTP                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function M015FTP(cNomArq)

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


ConOut("Inicio da compactacao dos arquivos - SCHEDULE")





cEndFTP		:= AllTrim(getMV("ES_FTPSITE"))
cUserFTP	:= AllTrim(getMV("ES_USESITE"))
cPassFTP	:= AllTrim(getMV("ES_PASSITE"))
cDirFTP		:= AllTrim(getMV("ES_DIRFTP"))
cDirArq     :=AllTrim(getMV("ES_DIRARQ"))



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


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M015FTP     �Autor  �Ednei Silva         � Data �  07/08/20 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Funcao de conexao com o ftp para upload do arquivo        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/


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
