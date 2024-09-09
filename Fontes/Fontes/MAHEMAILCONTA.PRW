#Include "Totvs.ch"
User  Function  eConta(cCliente,cLoja,cVend,cCodZoho,cCond,cForma,cLimite)

Local _cHTML    := ""

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
_cHTML+=' Novo Cliente '
_cHTML+=' </h1> '

_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Ol&aacute;!</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Um novo cliente deseja realizar um neg&oacute;cio! </h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Precisamos continuar o cadastro com agilidade para elevar a experi&ecirc;ncia do nosso cliente.</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0, 136, 203);"+'">'+"Ap&oacute;s a realiza&ccedil;&atilde;o do cadastro mude o status do cliente para ativo.</h2>"
_cHTML+=' <!-- Cabeçalho do Titulos --> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+='			<td>Codigo do Cliente:</td> '
_cHTML+='			<td>'+cCliente+'</td>'
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+='			<td>Loja:</td> '
_cHTML+='			<td>'+cLoja+'</td>'
_cHTML+='	</tr> '
_cHTML+='	</tr> '
_cHTML+='	<tr>  '
_cHTML+='			<td>Codigo do Vendedor:</td> '
_cHTML+='			<td>'+cVend+'</td>'
_cHTML+='	</tr> '
_cHTML+='		<tr> '
_cHTML+='			<td>Codigo Zoho:</td> '
_cHTML+='			<td>'+cCodZoho+'</td>'
_cHTML+='		</tr> '
_cHTML+='		<tr> '
_cHTML+='			<td>Cond Pag.:</td> '
_cHTML+='			<td>'+cCond+'</td>'
_cHTML+='		</tr> '
_cHTML+='		<tr> '
_cHTML+='			<td>Forma Pag.:</td> '
_cHTML+='			<td>'+cForma+'</td>'
_cHTML+='		</tr> '
_cHTML+='		<tr> '
_cHTML+='			<td>(R$) Limite Max:</td> '
_cHTML+='			<td>'+cLimite+'</td>'
_cHTML+='		</tr> '


_cHTML+='	</table> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0, 136, 203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' </div> '
_cHTML+='	</div> '
_cHTML+='   </body>'
_cHTML+='   </html>'

memowrite("\maEmailBlk\testeAdri.html",_cHTML)


zEnvMail(AllTrim(GETMV("MV_MAILCON")), 'Cadastro de Clientes', _cHTML, {}, .F., .T.)

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


