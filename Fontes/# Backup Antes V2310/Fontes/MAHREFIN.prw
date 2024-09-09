#include 'Totvs.ch'


User Function MAHREFIN()

	Local nLinha		:= 010
	Local lGrava		:= .F.
	Local lEdita		:= .F.
	
	Local cBlob         :=""
	Private cNum		:= "    "
	Private cItem	    := "    "
	



	
		Define MsDialog oDlg01 Title "Teste Email"  From 000,000 To 460, 730 Pixel
	
			@ nLinha + 002, 010 Say OemToAnsi("Cliente") Of oDlg01 Pixel
			@ nLinha, 055 MsGet oNum  Var cNum of oDlg01  Pixel  Size 60, 012
	
			@ nLinha + 002, 110 Say OemToAnsi("Loja") Of oDlg01 Pixel
			@ nLinha, 150 MsGet oItem Var cItem of oDlg01  Pixel   Size 60, 012
		
		@ nLinha, 290 Button 'Ok'		Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .T. )
		@ nLinha, 330 Button 'Todos'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )	
		@ nLinha, 330 Button 'Cancelar'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )
		Activate MsDialog oDlg01 Centered
		
		
		cBlob:='' 
		cBlob:= " OI teste Ednei 1"+ Chr(13) 
		cBlob+= " OI teste Ednei 2"+ Chr(13)
		cBlob+= " OI teste Ednei 3"+ Chr(13) 
		cBlob+= " OI teste Ednei 4"+ Chr(13)
		cBlob+= " OI teste Ednei 5"+ Chr(13) 
		cBlob+= " OI teste Ednei 6"+ Chr(13) 
		cBlob+= " OI teste Ednei 7"+ Chr(13)   
		If	lGrava
		     eOpme02('0101 - 039412',cBlob, '000002 - 0001','faturamento','ednei.silva@mahospitalar.com.br','003322','0003',"'CV-ONB5STF','CV-ONB5STF'")
		     //eOpme02(cPedido,cTexto,cCliLoja,cTipo,cEmail,cCliRet,cLojRet,cProd)
		     //u_eConta(cNum,cItem,'TESTE','Zoho')
		EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010ValProd  ³ Autor ³  Ednei Silva      ³ Data ³27/09/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validação Produto                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A010ValProd()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Produto 				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010ValProd(cProduto)

	lRet := .T.

	If !Empty(cProduto)

		DbSelectArea("SB1")
		DbSetOrder(1)

		If	DbSeek(xFilial("SB1")+cProduto)
			cDescProd  := SB1->B1_DESC
		Else

			Aviso("MAHA030","Produto nao Cadastrado!", { "Sair" }, 2)
			lRet := .F.

		EndIf

	EndIf

Return(lRet)
static  Function  eOpme02(cPedido,cTexto,cCliLoja,cTipo,cEmail,cCliRet,cLojRet,cProd)

Local _cHTML    := ""
Local cAliasT	:= GetNextAlias()
Local cQuery    :=""
_cHTML:=' <html> '
_cHTML+=' <head>
_cHTML+=' <meta charset="windows-1252"> '
_cHTML+=' <meta charset="UTF-8"> '
_cHTML+=' <style> '
_cHTML+=' body{ '
_cHTML+=' width:  			700px; '
_cHTML+="		font:			normal normal normal 14px 'open sans', sans-serif; "
_cHTML+='	} '
_cHTML+='	h1 { '
_cHTML+="		font: 			normal normal normal 22px 'open sans', sans-serif; "
_cHTML+='		color: 			rgb(0, 136, 203); '
_cHTML+='		padding-top: 	3px; '
_cHTML+='		padding-bottom:	3px; '
_cHTML+='	}'

_cHTML+='	h2 {'
_cHTML+="		font: 			normal normal normal 14px 'open sans', sans-serif;"
_cHTML+='	}'

_cHTML+='	table{ "
_cHTML+="		font:			normal normal normal 14px 'open sans', sans-serif;'
_cHTML+='		text-align: 	left '
_cHTML+='		border-width: 	0px; '

_cHTML+='	}'

_cHTML+='	thead{'
_cHTML+="		font:			normal normal normal 14px 'open sans', sans-serif; "
_cHTML+='		background:		Gray;  '
_cHTML+='		color:			White; '
_cHTML+='		text-align: 	left;  '
_cHTML+='		border-width: 	0px;   '
_cHTML+='	}'

_cHTML+='	.grid{ '
_cHTML+='		border-top: 	solid rgb(0, 136, 203) 2px; '
_cHTML+='		padding-top:	10px; '
_cHTML+='		padding-bottom:	5px;  '
_cHTML+='		margin-top:		10px; '
_cHTML+='	} '
_cHTML+='      </style> '
_cHTML+=' </head>  '

_cHTML+=' <body> '
_cHTML+=' <div styele='+'"width:700px;font:normal normal normal 14px '+"'open sans', sans-serif;"+'">'
_cHTML+=' <h1 style='+'"font:normal normal normal 22px'+" 'open sans', sans-serif; color:rgb(0, 136, 203);padding-top: 	3px;padding-bottom:	3px;"+'">'
_cHTML+=' Nova solicita&ccedil;&atilde;o '
_cHTML+=' </h1> '

_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Ol&aacute;!</h2>"
If cTipo='retorno' 
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Uma nova solicita&ccedil;&atilde;o de retorno acaba de chegar! </h2>"
else
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Uma nova solicita&ccedil;&atilde;o de faturamento acaba de chegar! </h2>"
endif
_cHTML+=' <!-- Cabeçalho do Titulos --> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+=' 		<td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Filial - Pedido</h2> </td>"	
_cHTML+='	</tr> '
_cHTML+='	<tr> '
_cHTML+='			<td>'+AllTrim(cPedido)+'</td>'
_cHTML+='	</tr> '
_cHTML+='	<tr> '
_cHTML+=' 		<td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Cliente - Loja</h2> </td>"	
_cHTML+='	</tr> '
_cHTML+='	<tr> '
_cHTML+='			<td>'+cCliLoja+'</td>'
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+=' 		<td><h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Outras Informa&ccedil;&otilde;es</h2></td>"
_cHTML+='	</tr> '
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+='			<td>'+cTexto+'</td>'
_cHTML+='	</tr> '
_cHTML+='	</table> '
_cHTML+=' </div> '

_cHTML+=' <!-- Itens do Pedido -->
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <h1 style='+'"font:normal normal normal 18px'+" 'open sans', sans-serif; color:rgb(0, 136, 203);padding-top: 	3px;padding-bottom:	3px;"+'">'
_cHTML+=' T&iacute;tulos '
_cHTML+=' </h1>'
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px'+" 'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+=' <thead style='+'"font:normal normal normal 14px '+" 'open sans', sans-serif;background:Gray;color:White;text-align:left;border-width:0px;"+'">'
_cHTML+='			<tr> '
_cHTML+='				<td style="width:150px;">Nota</td> '
_cHTML+='				<td style="width:150px;">Serie</td> '
_cHTML+='				<td style="width:150px;">Produto</td> '
_cHTML+='				<td style="width:150px;">Lote</td> '
_cHTML+='				<td style="width:150px;">Saldo</td> '
_cHTML+='			</tr> '
_cHTML+='		</thead> '
_cHTML+='		<tbody> '

	cQuery := " SELECT "
	cQuery += " B6_DOC, " 
	cQuery += " B6_SERIE, "
	cQuery += " B6_PRODUTO, "
	cQuery += " D2_LOTECTL, "
	cQuery += " B6_SALDO "
	
	cQuery += " FROM " + RetSQLName("SB6")+ " SB6 " 	
	cQuery += " INNER JOIN  " + RetSQLName("SD2") + " SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_IDENTB6=SB6.B6_IDENT AND SD2.D_E_L_E_T_<>'*')  "  
	cQuery += " INNER JOIN  " + RetSQLName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "   
	cQuery += " INNER JOIN  " + RetSQLName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')    JOIN SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
	cQuery += " WHERE SB6.D_E_L_E_T_ <> '*'"
	cQuery += " AND SB6.B6_SALDO>0  "
	cQuery += " AND SB6.B6_TES IN ('697','722')  "
	cQuery += " AND SB6.B6_CLIFOR ='" +cCliRet+ "'  "
	cQuery += " AND SB6.B6_LOJA   ='" +cLojRet+ "'  "
	cQuery += " AND SB6.B6_PRODUTO IN (" +cProd+ " ) "
	
	cQuery := ChangeQuery(cQuery)			
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )

While ( cAliasT )->( !Eof() )
	
	_cHTML+='			<tr> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->B6_DOC)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->B6_SERIE)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->B6_PRODUTO)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->D2_LOTECTL)+'</td> '
	_cHTML+='	<td style="width:150px;">'+cValToChar(( cAliasT )->B6_SALDO)+'</td> '
	_cHTML+='			</tr> '
	( cAliasT )->( dbSkip() )
	
EndDo

( cAliasT )->( dbCloseArea() )


_cHTML+='		</tbody>  '
_cHTML+='	</table>      '
_cHTML+='	</div>        '

_cHTML+='	</div> '
_cHTML+='   </body>'
_cHTML+='   </html>'
//memowrite("\maEmailBlk\testeAdri.html",_cHTML)


//zEnvMail('ednei.silva@mahospitalar.com.br;barbara.monardes@mahospitalar.com.br', 'Workflow OPME', _cHTML, {}, .F., .T.)
zEnvMail(cEmail, 'Workflow OPME', _cHTML, {}, .F., .T.)
Return

static Function zEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := Nil
    Local oSrv         := Nil
    Local nRet         := 0
    Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
    Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
    Local cPass        := Alltrim(GetMV("MV_RELPSW"))
    Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
    Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
    Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
    Local nTimeOut     := GetMV("MV_RELTIME")
    Local cLog         := ""
    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .F.
    Default lUsaTLS    := .F.
 
    //Se tiver em branco o destinatário, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
 
    If lRet
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
 
        //Define os atributos da mensagem
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo
 
        //Percorre os anexos
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo existir
            If File(aAnexos[nAtual])
 
                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
                EndIf
 
            //Senao, acrescenta no log
            Else
                cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
            EndIf
        Next
 
        //Cria servidor para disparo do e-Mail
        oSrv := tMailManager():New()
 
        //Define se irá utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
 
        //Inicializa conexão
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
 
        If lRet
            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            If nRet != 0
                cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
            EndIf
 
            //Conecta no servidor
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
 
            If lRet
                //Realiza a autenticação do usuário e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
 
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
 
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
 
    //Se tiver log de avisos/erros
    If !Empty(cLog)
        cLog := "zEnvMail - "+dToC(Date())+ " " + Time() + CRLF + ;
            "Funcao - " + FunName() + CRLF + CRLF +;
            "Existem mensagens de aviso: "+ CRLF +;
            cLog
        ConOut(cLog)
 
        //Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
        If lMostraLog .And. ! IsBlind()
            Aviso("Log", cLog, {"Ok"}, 2)
        EndIf
    EndIf
 
    RestArea(aArea)
Return lRet

