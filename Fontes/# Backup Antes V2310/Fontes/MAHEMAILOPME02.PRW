#Include "Totvs.ch"
User  Function  EmailFin(cCliente,cLoja,cPercent)

Local cQuery	:= ""
Local cAliasT	:= GetNextAlias()
Local cAliasL	:= GetNextAlias()
Local cAliasC	:= GetNextAlias()
Local _cHTML    := ""
cQuery := ""
cQuery := " SELECT A1_COD,"
cQuery += "    A1_SALPEDL,
cQuery += "    A1_NOME,
cQuery += "    A1_LC,
cQuery += "    A1_ZLCREM,
cQuery += "    A1_ZSALREM,
cQuery += "    A1_SALDUP,
cQuery += "    A1_NOME,
cQuery += "    A1_COD,
cQuery += "    A1_LOJA,
cQuery += "    A1_SALPEDB,
cQuery += "    A1_SALPED
cQuery += " FROM " + RetSQLName("SA1")
cQuery += " WHERE A1_COD='"+cCliente+"' "
cQuery += " AND   A1_LOJA='"+cLoja+"' "
cQuery += " AND D_E_L_E_T_<>'*'"
memowrite("\maEmailBlk\limiteA1.sql",cQuery)
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery),cAliasC,.F.,.T. )



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
_cHTML+=' Financeiro '
_cHTML+=' </h1> '

_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Ol&aacute;!</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Nosso cliente, "+( cAliasC )->A1_NOME+' - '+( cAliasC )->A1_COD+' / '+( cAliasC )->A1_LOJA+ "</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"acaba de atingir, "+cPercent+'%'+"do seu limite de crédito.</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Vamos analisar os n&uacute;meros e evitrar poss&iacute;veis transtornos futuros?</h2>"
_cHTML+=' <!-- Cabeçalho do Titulos --> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+='			<td>Limite Total</td> '
_cHTML+='			<td>'+Transform(( cAliasC )->A1_LC+( cAliasC )->A1_ZLCREM , PesqPict("SA1","A1_LC"))+'</td>'
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+='			<td>Limite Financeiro</td> '
_cHTML+='			<td>'+Transform(( cAliasC )->A1_LC , PesqPict("SA1","A1_LC"))+'</td>'
_cHTML+='	</tr> '
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+='			<td>Limite Consignado</td> '
_cHTML+='			<td>'+Transform(( cAliasC )->A1_ZLCREM , PesqPict("SA1","A1_LC"))+'</td>'
_cHTML+='	</tr> '
_cHTML+='		<tr> '
_cHTML+='			<td>Saldo Consignado</td> '
_cHTML+='			<td>'+Transform(( cAliasC )->A1_ZSALREM , PesqPict("SA1","A1_LC"))+'</td>'
_cHTML+='		</tr> '
_cHTML+='		<tr>  '
_cHTML+='			<td>Saldo Titulos</td> '
_cHTML+='			<td>'+Transform(( cAliasC )->A1_SALDUP , PesqPict("SA1","A1_LC"))+'</td>'
_cHTML+='		</tr>'
_cHTML+='		<tr> '
_cHTML+='			<td>% Comprometido</td> '
_cHTML+='			<td>'+cPercent+'</td>'
_cHTML+='		</tr> '
( cAliasC )->( dbCloseArea() )
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
_cHTML+='				<td style="width:150px;">T&iacute;tulo</td> '
_cHTML+='				<td style="width:150px;">Prefixo</td> '
_cHTML+='				<td style="width:150px;">Tipo</td> '
_cHTML+='				<td style="width:150px;">Parcela</td> '
_cHTML+='				<td style="width:150px;">Venc.</td> '
_cHTML+='				<td style="width:150px;">Venc. Real</td> '
_cHTML+='				<td style="width:150px;">Valor</td> '
_cHTML+='				<td style="width:150px;">Saldo</td> '
_cHTML+='			</tr> '
_cHTML+='		</thead> '
_cHTML+='		<tbody> '


cQuery :=""
cQuery := "SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_RISCO,E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_TIPO,E1_VENCREA, "
cQuery += " E1_NUM,E1_PARCELA,E1_PREFIXO,E1_VENCTO, E1_VENCREA, E1_VALOR, E1_SALDO "
cQuery += " FROM "+RetSqlName("SA1")+" SA1, "
cQuery += RetSqlName("SE1")+" SE1 "
cQuery += " WHERE "
cQuery += " A1_FILIAL ='"+xFilial("SA1")+"' AND "
cQuery += " A1_COD = '"+cCliente+"' AND "
cQuery += " A1_LOJA = '"+cLoja+"' AND "
cQuery += " SA1.D_E_L_E_T_ = ' ' AND "
cQuery += " E1_FILIAL = '"+xFilial("SE1")+"' AND "
cQuery += " E1_CLIENTE = A1_COD AND "
cQuery += " E1_LOJA = A1_LOJA AND "
cQuery += " E1_STATUS = 'A' AND "
cQuery += " SE1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY E1_NUM  "
memowrite("\maEmailBlk\limiteE1.sql",cQuery)
cQuery := ChangeQuery(cQuery)
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )

While ( cAliasT )->( !Eof() )
	
	_cHTML+='			<tr> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->E1_NUM)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->E1_PREFIXO)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->E1_TIPO)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasT )->E1_PARCELA)+'</td> '
	_cHTML+='	<td style="width:150px;">'+DtoC( StoD(( cAliasT )->E1_VENCTO ))+'</td> '
	_cHTML+='	<td style="width:150px;">'+DtoC( StoD(( cAliasT )->E1_VENCREA ))+'</td> '
	_cHTML+='	<td style="width:150px;">'+Transform(( cAliasT )->E1_VALOR , PesqPict("SE1","E1_VALOR"))+'</td> '
	_cHTML+='	<td style="width:150px;">'+Transform(( cAliasT )->E1_SALDO , PesqPict("SE1","E1_SALDO"))+'</td> '
	_cHTML+='			</tr> '
	
	( cAliasT )->( dbSkip() )
	
EndDo

( cAliasT )->( dbCloseArea() )



_cHTML+='		</tbody>  '
_cHTML+='	</table>      '
_cHTML+='	</div>        '


_cHTML+=' <!-- Itens do Pedido -->
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <h1 style='+'"font:normal normal normal 18px'+" 'open sans', sans-serif; color:rgb(0, 136, 203);padding-top: 	3px;padding-bottom:	3px;"+'">'
_cHTML+=' Consignado '
_cHTML+=' </h1>'
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px'+" 'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+=' <thead style='+'"font:normal normal normal 14px '+" 'open sans', sans-serif;background:Gray;color:White;text-align:left;border-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+='		<td style="width:150px;">Nota</td> '
_cHTML+='		<td style="width:150px;">Serie</td> '
_cHTML+='		<td style="width:150px;">Produto</td>  '
_cHTML+='		<td style="width:150px;">Lote</td>  '
_cHTML+='		<td style="width:400px;">Vendedor</td> '
_cHTML+='		<td style="width:150px;">Qtd</td> '
_cHTML+='		<td style="width:150px;">Saldo</td> '
_cHTML+='		<td style="width:150px;">Vl. Unit</td> '
_cHTML+='		<td style="width:150px;">Total</td> '
_cHTML+='		<td style="width:150px;">Dta Rem.</td> '
_cHTML+='	</tr> '
_cHTML+='	</thead> '
_cHTML+='  <tbody> '


cQuery :=""
cQuery := " SELECT B6_FILIAL,"
cQuery += "        B6_CLIFOR,"
cQuery += "        B6_LOJA,"
cQuery += "        B6_PRODUTO,"
cQuery += "        B6_DOC,"
cQuery += "        B6_SERIE,"
cQuery += "        B6_EMISSAO,"
cQuery += "        B6_QUANT,"
cQuery += "        B6_PRUNIT,"
cQuery += "        B6_SALDO,"
cQuery += "        A3_COD,  "
cQuery += "        A3_NOME, "
cQuery += "        D2_LOTECTL, "
cQuery += "        D2_DTVALID "
cQuery += " FROM " + RetSQLName("SB6")+ " SB6 "
cQuery += " INNER JOIN  " + RetSQLName("SD2") + " SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_IDENTB6=SB6.B6_IDENT AND SD2.D_E_L_E_T_<>'*')  "
cQuery += " INNER JOIN  " + RetSQLName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*') "
cQuery += " INNER JOIN  " + RetSQLName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "
cQuery += " INNER JOIN  " + RetSQLName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')    JOIN SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "
cQuery += " INNER JOIN  " + RetSQLName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
cQuery += " WHERE SB6.D_E_L_E_T_ <> '*'"
cQuery += " AND SB6.B6_SALDO>0  "
cQuery += " AND SB6.B6_TIPO = 'E' "
cQuery += " AND F4_CODIGO IN ('722','697') "
cQuery += " AND B6_CLIFOR  = '"+cCliente+"' "
cQuery += " AND B6_LOJA = '"+cLoja+"'"
memowrite("\maEmailBlk\limiteB6.sql",cQuery)
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasL,.F.,.T. )

While ( cAliasL )->( !Eof() )
	_cHTML+=' <tr> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasL )->B6_DOC)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasL )->B6_SERIE)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasL )->B6_PRODUTO)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasL )->D2_LOTECTL)+'</td> '
	_cHTML+='	<td style="width:150px;">'+AllTrim(( cAliasL )->A3_NOME)+'</td> '
	_cHTML+='	<td style="width:150px;">'+Transform(( cAliasL )->B6_QUANT , PesqPict("SD2","D2_QUANT"))+'</td> '
	_cHTML+='	<td style="width:150px;">'+Transform(( cAliasL )->B6_SALDO , PesqPict("SD2","D2_QUANT"))+'</td> '
	_cHTML+='	<td style="width:150px;">'+Transform(( cAliasL )->B6_PRUNIT, PesqPict("SD2","D2_PRCVEN"))+'</td> '
	_cHTML+='	<td style="width:150px;">'+Transform(( cAliasL )->B6_SALDO*( cAliasL )->B6_PRUNIT , PesqPict("SB6","B6_PRUNIT"))+'</td> '
	_cHTML+='	<td style="width:150px;">'+DtoC( StoD(( cAliasL )->B6_EMISSAO))+'</td> '
	_cHTML+='			</tr> '
	( cAliasL )->( dbSkip() )
	
EndDo


( cAliasL )->( dbCloseArea() )



_cHTML+='		</tbody>  '
_cHTML+='	</table>      '
_cHTML+='	</div>        '

_cHTML+='	</div> '
_cHTML+='   </body>'
_cHTML+='   </html>'

//memowrite("\maEmailBlk\limite.html",_cHTML)


zEnvMail(AllTrim(GETMV("MV_MAILFIN")), 'Limites Financeiros', _cHTML, {}, .F., .T.)

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


