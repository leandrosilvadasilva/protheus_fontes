#include "Protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"
#include "FWMVCDEF.ch"
#Include "TOTVS.ch" 
#INCLUDE "rwmake.ch"


//IATAN EM 12/12/2023
User Function M110STTS()
 
Local cNumSol   := Paramixb[1]
Local nOpt      := Paramixb[2]
Local lCopia    := Paramixb[3]
Local aArea     := GETAREA()
Local sql       := ""
Local contador  := 1
Local alcada    := GETMV("MV_XALCSC")
Local codAprov  := ""
Local codUser   := ""
Local mensagem  := ""
 
sql += "  SELECT C1_FILIAL, C1_NUM, C1_ITEM, C1_CC, SC1.R_E_C_N_O_ , ZA9_APROV, USR_EMAIL, USR_NOME, AK_USER, AK_COD "
sql += "  FROM SC1010 SC1 LEFT JOIN ZA9010 ZA9 ON ZA9.D_E_L_E_T_ <> '*' AND ZA9_FILIAL = C1_FILIAL AND ZA9_CC = C1_CC "
sql += "                  LEFT JOIN SAK010 SAK ON SAK.D_E_L_E_T_ <> '*' AND AK_FILIAL = C1_FILIAL AND AK_COD = ZA9_APROV  "
sql += "                  LEFT JOIN SYS_USR USR ON USR.D_E_L_E_T_ <> '*' AND USR_ID = AK_USER "
sql += "  WHERE SC1.D_E_L_E_T_ <> '*' AND C1_NUM = '" + SC1->C1_NUM + "' AND C1_FILIAL = '" + SC1->C1_FILIAL + "' "

    IF nOpt == 1     
    //INCLUSÃO

        IF !EMPTY(ALLTRIM(alcada))

            TCQuery sql New Alias "QRY_SC1"
            
            QRY_SC1->(DbGoTop())

            While ! QRY_SC1->(Eof())

                //VALIDO SOMENTE NO PRIMEIRO ITEM
                IF contador == 1
                    IF EMPTY(ALLTRIM(QRY_SC1->C1_CC))
                        ALERT("SC SEM CENTRO DE CUSTO NÃO SERÁ BLOQUEADA")
                        EXIT
                    ENDIF
                    IF EMPTY(ALLTRIM(QRY_SC1->ZA9_APROV))
                        ALERT("SC SEM APROVADOR PARA O CENTRO DE CUSTO " + ALLTRIM(QRY_SC1->C1_CC) + " NA FILIAL " + QRY_SC1->C1_FILIAL )
                        EXIT
                    ENDIF
                    IF EMPTY(ALLTRIM(QRY_SC1->USR_EMAIL))
                        ALERT("EMAIL DO APROVADOR " + ALLTRIM(QRY_SC1->USR_NOME) + " NÃO CONFIGURADO")
                        //EXIT
                    ELSE
                        mensagem := GeraHtm(QRY_SC1->C1_NUM, QRY_SC1->C1_FILIAL)
                        ENVMAIL(ALLTRIM(QRY_SC1->USR_EMAIL), mensagem, "APROVAÇÃO DE SOLICITAÇÃO DE COMPRA", NIL)
                    ENDIF
                    
                ENDIF

                SC1->( DBGOTO( QRY_SC1->R_E_C_N_O_ ) )

                RECLOCK("SC1", .F.)
                    SC1->C1_APROV := 'B'
                SC1->( MSUNLOCK() )

                IF contador == 1
                    RECLOCK("SCR", .T.)
                        SCR->CR_FILIAL  := QRY_SC1->C1_FILIAL
                        SCR->CR_NUM     := QRY_SC1->C1_NUM
                        SCR->CR_TIPO    := 'SC'
                        SCR->CR_USER    := QRY_SC1->AK_USER
                        SCR->CR_APROV   := QRY_SC1->AK_COD
                        SCR->CR_NIVEL   := '01'
                        SCR->CR_STATUS  := '02'
                        SCR->CR_EMISSAO := DDATABASE
                    SCR->( MSUNLOCK() )
                ENDIF

                contador++

                RECLOCK("DBM", .T.)
                    DBM->DBM_FILIAL := QRY_SC1->C1_FILIAL
                    DBM->DBM_TIPO   := 'SC'
                    DBM->DBM_NUM    := QRY_SC1->C1_NUM
                    DBM->DBM_ITEM   := QRY_SC1->C1_ITEM
                    DBM->DBM_USER   := QRY_SC1->AK_USER
                    DBM->DBM_APROV  := '2'
                    DBM->DBM_USAPRO := QRY_SC1->AK_USER
                DBM->( MSUNLOCK() )

                

                QRY_SC1->(DbSkip())
            EndDo

            QRY_SC1->(DbCloseArea())

            IF CONTADOR > 1
                // MANDA WORKFLOW
            ENDIF
        
        ENDIF

    ENDIF
     
RESTAREA(aArea)

Return Nil


Static Function ENVMAIL(cDestinat,cMsg,cTitulo,cArquivos)

	Local cMensagem := ""

	Local cServer   := getmv('MV_RELSERV')
	Local cAccount  := getmv('MV_RELACNT')
	Local cPassword := getmv('MV_RELPSW')
	Local cMailFrom := getmv('MV_RELFROM')
	Local lAutent   := getmv('MV_RELAUTH')

	cDestinat := Alltrim(cDestinat)

	//Inicia Conexao com o Servidor de e-mails
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou

	If lConectou
		cMsgAux := ("Conectado com servidor de E-Mail - " + cServer)
	Else
		cMsgAux := ("Erro Envio e-mail: " + __cUserID +" "+ FunName() +" ("+cDestinat+")")
	Endif

	//Realiza a autenticação com o servidor de email
	If lAutent
		MailAuth(cAccount, cPassword)
	EndIf


	If Empty(cArquivos)
		Send Mail From cMailFrom To cDestinat Subject cTitulo Body cMsg Result lEnviado
	Else
		Send Mail From cMailFrom To cDestinat Subject cTitulo Body cMsg ATTACHMENT cArquivos Result lEnviado
	Endif

	Get Mail Error cMensagem

	If !Empty(cMensagem)
		cMsgAux := ("Mensagem de erro: "+ cMensagem)
	Else
		cMsgAux := ("E-mail enviado para "+Alltrim(cDestinat))
	Endif

	DISCONNECT SMTP SERVER Result lDisConectou

	If lDisConectou
		cMsgAux := ("Desconectado com servidor de E-Mail - " + cServer)
	Endif

Return



Static Function GeraHtm(numero, filial)
	Local cHtm    := ''

	cHtm += '<html>'
	cHtm += '<head>'
	cHtm += '<meta http-equiv="Content-Type"'
	cHtm += 'content="text/html; charset=iso-8859-1">'
	cHtm += '<title>Aprovação de Solicitação de Compra</title>'
	cHtm += '<style type="text/css">'
	cHtm += '<!--'
	cHtm += '.style12 {font-family: Arial, Helvetica, sans-serif;'
	cHtm += '  font-weight: bold;'
	cHtm += '  font-size: 12px;'
	cHtm += '}'
	cHtm += '.style7 {font-size: 12px;'
	cHtm += '  color: #000066;'
	cHtm += '  font-weight: bold;'
	cHtm += '  font-family: Arial, Helvetica, sans-serif;'
	cHtm += '}'
	cHtm += '.style8 {color: #FFFFFF;'
	cHtm += '  font-size: 14px;'
	cHtm += '  font-family: Arial, Helvetica, sans-serif;'
	cHtm += '  font-weight: bold;'
	cHtm += '}'
	cHtm += '.style9 {font-size: 12px; font-family: Arial, Helvetica, sans-serif; }'
	cHtm += '.style13 {'
	cHtm += '  font-size: 14px;'
	cHtm += '  font-weight: bold;'
	cHtm += '  color: #000000;'
	cHtm += '}'
	cHtm += '.style19 {font-size: 12px; font-family: Arial, Helvetica, sans-serif; color: #f3f3f3; }'
	cHtm += '-->'
	cHtm += '</style>'
	cHtm += '</head>'
	cHtm += '<body bgcolor="#FFFFFF">'
	cHtm += '<br>'
	cHtm += '<b>Favor aprovar a SC número ' + numero + ' da Filial ' + filial + '</b>'
	cHtm += '<br>'
	cHtm += '</body>'
	cHtm += '</html>'

Return cHtm
