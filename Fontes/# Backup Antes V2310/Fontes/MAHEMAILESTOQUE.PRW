#Include "Totvs.ch"
User  Function  EmailEst(cCliente,cLoja,cPedidoV,cFilialV)

Local cQuery	:= ""
Local cAliasT	:= GetNextAlias()
Local cAliasL	:= GetNextAlias()
Local cAliasC	:= GetNextAlias()
Local _cHTML    := ""
cQuery := ""
cQuery := " SELECT A1_COD,"
cQuery += "    A1_LOJA, "
cQuery += "    A1_NOME " 
cQuery += " FROM " + RetSQLName("SA1")
cQuery += " WHERE A1_COD='"+cCliente+"' "
cQuery += " AND   A1_LOJA='"+cLoja+"' "
cQuery += " AND D_E_L_E_T_<>'*'"
memowrite("\maEmailBlk\PedidoV.sql",cQuery)
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
_cHTML+=' Estoque '
_cHTML+=' </h1> '

_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Ol&aacute;!</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Novo pedido de venda para o cliente, "+( cAliasC )->A1_NOME+' - '+( cAliasC )->A1_COD+' / '+( cAliasC )->A1_LOJA+ "</h2>"
_cHTML+=' <!-- Cabeçalho do Titulos --> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+='			<td>Data de inclus&atilde;o</td> '
_cHTML+='			<td>'+dToC(dDatabase)+'</td>'
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+='			<td>Hora da inclus&atilde;o </td> '
_cHTML+='			<td>'+time()+'</td>'
_cHTML+='	</tr> '
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+='			<td>Filial do pedido</td> '
_cHTML+='			<td>'+cFilialV+'</td>'
_cHTML+='	</tr> '
_cHTML+='		<tr> '
_cHTML+='			<td>Numero do pedido</td> '
_cHTML+='			<td>'+cPedidoV+'</td>'
_cHTML+='		</tr> '
( cAliasC )->( dbCloseArea() )
_cHTML+='	</table> '
_cHTML+=' </div> '
_cHTML+=' </div> '
_cHTML+=' </body>'
_cHTML+=' </html>'

IF cFilialV $ '0101/0104/0105/0106/0107'
    zEnvMail(GetMV('ES_WFPVRS'), 'Novo Pedido Estoque RS - '+cPedidoV+' - '+cFilialV, _cHTML, {}, .F., .T.)
EndIf

IF cFilialV $ '0102'
    zEnvMail(GetMV('ES_WFPVSC'), 'Novo Pedido Estoque SC - '+cPedidoV+' - '+cFilialV, _cHTML, {}, .F., .T.)
EndIf

IF cFilialV $ '0103'
    zEnvMail(GetMV('ES_WFPVPR'), 'Novo Pedido Estoque PR - '+cPedidoV+' - '+cFilialV, _cHTML, {}, .F., .T.)
EndIf


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


