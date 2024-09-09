#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch"
#Include "RESTFUL.CH"
#include 'shell.ch'



USER FUNCTION WFFISCAL()

    Local _cQry     := ''
    Local xEmail    := ''

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" 

    xEmail := GETMV("MV_XWFFISC")


    _cQry += " SELECT * FROM ( "
    _cQry += " SELECT * FROM ( "
    _cQry += " SELECT INDICE AS NOTA, '4' AS SERIE, 'SAIDA' AS TIPO, DOC_ID, STATUS, STATUSCANC "
    _cQry += " FROM ( "
    _cQry += " SELECT ROW_NUMBER() OVER (ORDER BY sysdatetime()) AS INDICE "
    _cQry += " FROM SD9010 "
    _cQry += " ) AS LISTA LEFT JOIN SPED050 ON D_E_L_E_T_ <> '*' AND DOC_ID = INDICE AND DOC_SERIE = 4  "
    _cQry += " WHERE INDICE >= (SELECT MIN(F2_DOC) FROM SF2010 WHERE D_E_L_E_T_ <> '*' AND F2_EMISSAO >= '20230501' AND F2_SERIE = '4' ) "
    _cQry += "       AND INDICE <= (SELECT MAX(F2_DOC) FROM SF2010 WHERE D_E_L_E_T_ <> '*' AND F2_EMISSAO >= '20230501' AND F2_SERIE = '4' ) "
    _cQry += " ) AS FINAL "
    _cQry += " WHERE DOC_ID IS NULL OR ( STATUS <> 6 AND STATUSCANC <> 2 ) "
    _cQry += "  "
    _cQry += " UNION ALL "
    _cQry += "  "
    _cQry += " SELECT * FROM ( "
    _cQry += " SELECT INDICE AS NOTA, '5' AS SERIE, 'SAIDA' AS TIPO, DOC_ID, STATUS, STATUSCANC "
    _cQry += " FROM ( "
    _cQry += " SELECT ROW_NUMBER() OVER (ORDER BY sysdatetime()) AS INDICE "
    _cQry += " FROM SD9010 "
    _cQry += " ) AS LISTA LEFT JOIN SPED050 ON D_E_L_E_T_ <> '*' AND DOC_ID = INDICE AND DOC_SERIE = 5 "
    _cQry += " WHERE INDICE >= (SELECT MIN(F2_DOC) FROM SF2010 WHERE D_E_L_E_T_ <> '*' AND F2_EMISSAO >= '20230501' AND F2_SERIE = '5' ) "
    _cQry += "       AND INDICE <= (SELECT MAX(F2_DOC) FROM SF2010 WHERE D_E_L_E_T_ <> '*' AND F2_EMISSAO >= '20230501' AND F2_SERIE = '5' ) "
    _cQry += " ) AS FINAL "
    _cQry += " WHERE DOC_ID IS NULL OR ( STATUS <> 6 AND STATUSCANC <> 2 ) "
    _cQry += "  "
    _cQry += " UNION ALL "
    _cQry += "  "
    _cQry += " SELECT * FROM ( "
    _cQry += " SELECT INDICE AS NOTA, '6' AS SERIE, 'SAIDA' AS TIPO, DOC_ID, STATUS, STATUSCANC "
    _cQry += " FROM ( "
    _cQry += " SELECT ROW_NUMBER() OVER (ORDER BY sysdatetime()) AS INDICE "
    _cQry += " FROM SD9010 "
    _cQry += " ) AS LISTA LEFT JOIN SPED050 ON D_E_L_E_T_ <> '*' AND DOC_ID = INDICE AND DOC_SERIE = 6 "
    _cQry += " WHERE INDICE >= (SELECT MIN(F2_DOC) FROM SF2010 WHERE D_E_L_E_T_ <> '*' AND F2_EMISSAO >= '20230501' AND F2_SERIE = '6' ) "
    _cQry += "       AND INDICE <= (SELECT MAX(F2_DOC) FROM SF2010 WHERE D_E_L_E_T_ <> '*' AND F2_EMISSAO >= '20230501' AND F2_SERIE = '6' ) "
    _cQry += " ) AS FINAL "
    _cQry += " WHERE DOC_ID IS NULL OR ( STATUS <> 6 AND STATUSCANC <> 2 ) "
    _cQry += " ) AS FINAL "
    _cQry += " ORDER BY SERIE, NOTA, TIPO "


    dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SFX",.T.,.T. )
    
    _cHTML := ''
    _cHTML += '<table border="1" cellpadding="1" cellspacing="1" style="width:629px">'
    _cHTML += '	<thead>'
    _cHTML += '		<tr>'
    _cHTML += '			<th scope="col" style="width: 75px;">Nota</th>'
    _cHTML += '			<th scope="col" style="width: 50px;">S&eacute;rie</th>'
    _cHTML += '			<th scope="col" style="width: 484px;">Observa&ccedil;&atilde;o</th>'
    _cHTML += '		</tr>'
    _cHTML += '	</thead>'
    _cHTML += '	<tbody>'

    contador := 1

    While (_SFX->(!EOF()))

        contador++

		_cHTML += '<tr>'
		_cHTML += '	<td style="width:75px">' + CVALTOCHAR(_SFX->NOTA) + '</td>'
		_cHTML += '	<td style="width:50px">' + _SFX->SERIE + '</td>'
        IF EMPTY(ALLTRIM(_SFX->DOC_ID))
		    _cHTML += '	<td style="width:484px">' + 'NUMERAÇÃO INEXISTENTE [ Inativar Numeração ]' + '</td>'
        ELSEIF _SFX->STATUS == 3
		    _cHTML += '	<td style="width:484px">' + 'NFE COM FALHA NO SCHEMA XML [ Excluir Nota ou corrigir a falha e retransmitir ]' + '</td>'
        ELSEIF _SFX->STATUS == 5
		    _cHTML += '	<td style="width:484px">' + 'NFE COM PROBLEMAS [ Excluir Nota ou corrigir a falha e retransmitir ]' + '</td>'
        ENDIF
		_cHTML += '</tr>'

        _SFX->(DbSkip())

    End
    _SFX->(DBCloseArea())

	_cHTML += '</tbody>'
    _cHTML += '</table>'

    IF contador > 1
        zEnvMail( xEmail, 'Workflow Validação de Notas Fiscais de Saída', _cHtml, {}, .F., .T.)
    ENDIF

RESET ENVIRONMENT 

RETURN

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
