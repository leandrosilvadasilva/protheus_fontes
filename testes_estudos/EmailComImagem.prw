#include "protheus.ch"
#include "rptdef.ch"
#include "TBICONN.CH"
#include "FwPrintSetup.ch"

user function EmImg()
	Local cUser := "", cPass := "", cSendSrv := ""
	Local cMsg := ""
	Local nSendPort := 0, nSendSec := 2, nTimeout := 0
	Local xRet
	Local oServer, oMessage

	cUser := "" //preencher o e-mail que que irá enviar  
	cPass := "nwtugjjowacpmcnf" //senha do e-mail 
	cSendSrv := "smtp.gmail.com" // server do email 
	nTimeout := 120 // timeout

	oServer := TMailManager():New()

	oServer:SetUseSSL( .F. )
	oServer:SetUseTLS( .F. )

	if nSendSec == 0
		nSendPort := 25 //default port for SMTP protocol
	elseif nSendSec == 1
		nSendPort := 465 //default port for SMTP protocol with SSL
		oServer:SetUseSSL( .T. )
	else
		nSendPort := 587 //default port for SMTPS protocol with TLS
		oServer:SetUseTLS( .T. )
	endif

	// once it will only send messages, the receiver server will be passed as ""
	// and the receive port number won't be passed, once it is optional
	xRet := oServer:Init( "", cSendSrv, cUser, cPass, , nSendPort )
	if xRet != 0
		cMsg := "Could not initialize SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		return
	endif

	// the method set the timout for the SMTP server
	xRet := oServer:SetSMTPTimeout( nTimeout )
	if xRet != 0
		cMsg := "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout )
		conout( cMsg )
	endif

	// estabilish the connection with the SMTP server
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		cMsg := "Could not connect on SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		return
	endif

	// authenticate on the SMTP server (if needed)
	xRet := oServer:SmtpAuth( cUser, cPass )
	if xRet <> 0
		cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		oServer:SMTPDisconnect()
		return
	endif

	// INSERE IMAGEM NO CORPO DA MENSAGEM
	sText := "<h1 style='color: blue;'>Teste de envio de e-mail com a classe TMailManager</h1>"
	sText += "<img src='cid:img'>"

	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom           := "" //email que vai receber

	//Altere
	oMessage:cTo             := "" //email que vai receber

	//Altere
	//oMessage:cCc             := ""
	oMessage:cBcc            := ""
	oMessage:cSubject        := "Teste de envio de e-mail"
	oMessage:cBody           := sText
	oMessage:MsgBodyType( "text/html" )

	// Para solicitar confimação de envio
	//oMessage:SetConfirmRead( .T. )

	// Adiciona um anexo, nesse caso a imagem esta no root
	oMessage:AttachFile("\tst\img.bmp")

	// Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
	//oMessage:AddAttHTag( 'Content-ID: &lt;ID_siga.jpg&gt;' )
	oMessage:AddAttHTag("Content-ID: <img>")

	xRet := oMessage:Send( oServer )
	if xRet <> 0
		cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
		conout( cMsg )
	else
		conout("O e-mail foi enviado")
	endif

	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		cMsg := "Could not disconnect from SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
	else
		conout("Desconectado com sucesso!")
	endif
return
