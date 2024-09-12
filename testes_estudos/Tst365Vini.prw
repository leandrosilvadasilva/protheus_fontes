#Include "totvs.ch"
#Include "parmtype.ch"

/*User Function SendJob()
	StartJob("u_SendEmail", getEnvServer(), .T.)
	[mail]
	PROTOCOL=SMTP
	;EXTENDSMTP=1
	TLSVERSION=1
	SSLVERSION=3
	TRYPROTOCOLS=1
	AUTHLOGIN=1
	AUTHPLAIN=1
	AUTHNTLM=1
	
Return */


user function SendEmail()
	Local cUser := "", cPass := "", cSendSrv := ""
	Local cMsg := ""
	Local nSendPort := 0, nTimeout := 0
	Local xRet
	Local aRet 
	Local oServer, oMessage


	cUser := "teste.vinicios@outlook.com" //define the e-mail account username
	cPass := "teste.totvs" //define the e-mail account password
	cSendSrv := "outlook.office365.com" // define the send server
	nTimeout := 120 // define the timout to 60 seconds

	// ESCOLHA O PROTOCOLO DE CONEXÃO
	Local nEsc := 1 //0- POP3 1-SMTP

	oServer := TMailManager():New()
	If nEsc ==0 //POP3
		writePProString( "Mail", "Protocol", "POP3", getsrvininame() )

		oServer:SetUseTLS( .T. )
		oServer:SetUseSSL( .F. )

		xRet := oServer:Init( cSendSrv, "", cUser, cPass, 995, 0 ) //POP3
		if xRet <> 0
			conout( "Could not initialize mail server: " + oServer:GetErrorString( xRet ) )
			return
		endif

		xRet := oServer:POPConnect()
		if xRet <> 0
			conout( "Could not connect on POP3 server: " + oServer:GetErrorString( xRet ) )
			return
		endif

	elseif nEsc == 1 //SMTP
		writePProString( "Mail", "Protocol", "SMTP", getsrvininame() )

		oServer:SetUseTLS( .T. )
		oServer:SetUseSSL( .F. )

		xRet := oServer:Init( cSendSrv, "", cUser, cPass, 587, 0 ) //SMTP
		if xRet <> 0
			conout( "Could not initialize mail server: " + oServer:GetErrorString( xRet ) )
			return
		endif

		// once it will only send messages, the receiver server will be passed as ""
		// and the receive port number won't be passed, once it is optional
		xRet := oServer:Init( "", cSendSrv, cUser, cPass, 0, nSendPort )

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
	endif

	aRet:= oServer:GetMsgBody(1)

	oMessage := TMailMessage():New()
	oMessage:Clear()

	sText := "<h1 style='color: blue;'>Teste de envio de e-mail com a classe TMailManager</h1><br>"
	sText += "<h1 style='color: red;'>Teste de envio de e-mail com a classe TMailManager linha 2</h1>"
	//sText += "<img src='cid:logo_1' alt='logo_totvs' height='4096' width='4096'>"

	oMessage:cDate := cValToChar( Date() )
	oMessage:cFrom := "teste.vinicios@outlook.com"
	oMessage:cTo := "lucas.bonfim@totvs.com.br"
	oMessage:cCc := "teste.vinicios@outlook.com"
	oMessage:cSubject := "TestÉ de Ênvio de e-mail"
	//oMessage:cSubject:=OEMToAnsi("Cobrança Bancária Teste") //função que o converte para "formatação" que o gmail também nao reconhece mas tenta converter
	oMessage:cBody :=  sText //"Este e-mail é um teste de envio."
	//oMessage:AttachFile( 'imp\1.pdf' )

	//oMessage:AttachFile("/imp/exemplo.pdf") //arquivo que será enviado
	//oMessage:AddAttHTag("Content-ID: <logo_1>")

	xRet := oMessage:Send( oServer )
	if xRet <> 0
		cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
		conout( cMsg )
	else
		conout("O e-mail foi enviado")
	endif

return
