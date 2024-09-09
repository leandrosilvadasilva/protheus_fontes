#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH" 
#include "Protheus.ch"
#include "topconn.ch"
#Include "TOTVS.ch" 

User Function LSSTST()
cChave := "72151"

BeginSql alias 'QRYXML'

    %noparser% 
    
    SELECT  DOC_CHV, DOC_ID, DOC_SERIE, ID_ENT, DATE_NFE, STATUS, AMBIENTE,
           ISNULL(CAST(CAST(XML_ERP AS VARBINARY(MAX)) AS VARCHAR(MAX)),''),
           ISNULL(CAST(CAST(XML_SIG AS VARBINARY(MAX)) AS VARCHAR(MAX)),'') 
      FROM SPED050 
     WHERE 1=1
       AND SPED050.DOC_ID = %exp:cChave%     

EndSql

 _SQL := GetLastQuery()[2]

RETURN

User Function CHKEXEC()
Local cRotina  := PARAMIXB
Local lPEOnOff := SuperGetMV( "MA_CHKEXEC", .F., .T. )

       If lPEOnOff  .and.  cRotina == "SPEDNFE()"

              VerificaAmbienteTSS()
       EndIf

Return NIL

Static Function VerificaAmbienteTSS()
Local lUsaColab := UsaColaboracao("1")
Local oWs
Local cAmbiente := ""
Local cUrl	  := Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local cError    := ""

       If FWIsADmin()  .and.  IsReady(,,,lUsaColab) 

              cIdEnt := GetIdEnt()
              cVersaoTSS	:= getVersaoTSS()

              cIdEnt := GetIdEnt(lUsaColab)       
              // Obtem o ambiente da carta de correcao
              oWS:=WsSpedCfgNfe():New()
              oWS:cUSERTOKEN 	:= "TOTVS"
              oWS:cID_ENT    	:= cIdEnt
              oWS:nAMBIENTECCE	:= 0
              oWS:cVERCCELAYOUT	:= "1.00"
              oWS:cVERCCELAYEVEN	:= "1.00"
              oWS:cVERCCEEVEN	:= "1.00"
              oWS:cVERCCE		:= "1.00"
              oWS:cHORAVERAOCCE	:= "2"
              oWS:cHORARIOCCE	:= "2"
              oWS:_URL       	:= AllTrim(cURL)+"/SpedCfgNfe.apw"
              aCfgCCe               := getCfgCCe(@cError, cIdEnt)
              lOk:= empty(cError)

              If lOk

                     If Valtype(aCfgCCe[1]) <> "U"

                            cAmbiente := aCfgCCe[1]
                     EndIf

                     If cAmbiente <> "1-Producao"

                            cMsgTemp := '<span style="color:#e74c3c"><span style="font-size:16px"><strong>Ambiente de Transmiss&atilde;o est&aacute; em&nbsp; HOMOLOGA&Ccedil;&Atilde;O</strong></span>'
                            FWAlertError( cMsgTemp, "Atenção!!" )

                            EnviaEmailTSS()
                     EndIF
                     VarInfo( "CFG CCe", aCfgCCe )
              EndIf

       EndIf
Return NIL

Static Function IsReady(cURL,nTipo,lHelp,lUsaColab)
Local cHelp    := ""
local cError	:= ""
Local lRetorno := .F.
DEFAULT nTipo := 1
DEFAULT lHelp := .F.
DEFAULT lUsaColab := .F.
if !lUsaColab
   If FunName() <> "LOJA701"
   		If !Empty(cURL)
			PutMV("MV_SPEDURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Else
		If !Empty(cURL)
			PutMV("MV_NFCEURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	EndIf
	//Verifica se o servidor da Totvs esta no ar
	if(isConnTSS(@cError))
		lRetorno := .T.
	Else
		If lHelp

			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"SPED"},3) 
		EndIf
		lRetorno := .F.
	EndIf


	//Verifica se Há Certificado configurado
	If nTipo <> 1 .And. lRetorno

		if( isCfgReady(, @cError) )
			lRetorno := .T.
		else
			If nTipo == 3
				cHelp := cError

				If lHelp .And. !"003" $ cHelp
					Aviso("SPED",cHelp,{"SPED"},3) 
					lRetorno := .F.

				EndIf

			Else
				lRetorno := .F.

			EndIf
		endif

	EndIf

	//Verifica Validade do Certificado
	If nTipo == 2 .And. lRetorno
		isValidCert(, @cError)
	EndIf
else
	lRetorno := ColCheckUpd()
	if lHelp .And. !lRetorno .And. !lAuto

		MsgInfo("UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0") 
	endif
endif

Return(lRetorno)

Static Function GetIdEnt(lUsaColab)

local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab

	cIdEnt := getCfgEntidade(@cError)

	if(empty(cIdEnt))

		Aviso("SPED", cError, {"SPED"}, 3) 
	endif

else
	if !( ColCheckUpd() )

		Aviso("SPED", "UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{"SPED"},3) 
	else

		cIdEnt := "000000"
	endif
endIf

Return(cIdEnt)


Static Function EnviaEmailTSS() AS BOOLEAN
Local lRetorno  AS BOOLEAN 
Local cMensagem AS CHAR
Local cComCopia AS CHAR 
Local cSubject  AS CHAR
Local cToEmail  AS CHAR
Local cDetalhes AS CHAR
Local lBaseTST  AS BOOLEAN

	lBaseTST  := Upper(Alltrim(FWGetTopInfo()[5]))  == "PROTHEUS_HML"
	lRetorno  := .T.
	cComCopia := SuperGetMV( "AC_EMAILCC", .F., "luciano.souza@dwtti.com.br" )
	cSubject  := SuperGetMV( "AC_SUBJECT", .F., "[MA HOSPITALAR] - Ambiente TSS em HOMOLOGAÇÃO" )
	cToEmail  := "luciano.souza@dwtti.com.br"

	// -- Para testes quando do uso do ambiente DESENV  ou  base  TESTE
	If (AllTrim( GetEnvServer() ) == "PRODUCAO")  .or.  lBaseTST  .or.  (AllTrim( GetEnvServer() ) == "COMPILA")

		cToEmail := "luciano.souza@dwtti.com.br"
		cSubject := cSubject + " - Email enviado como  TESTE - Desconsiderar"
	EndIf

	// TSendMail(_cDest, _cCC, _cAssunto,_cMens,_nPorta, _cAnexo) 
	lRetorno := TSendMail( cToEmail, ;
	                         cComCopia, ;
				    cSubject,  ;
	                         cMensagem, ;
				    NIL,       ;
				    NIL )

	cDetalhes := "TO: " + cToEmail + " Com Copia: " + cComCopia + " Assunto: " + cSubject 

Return lRetorno

Static Function TSendMail (_sTo, _sSubject, _sBody, _aArq, _sReplyTo, _cCCO)
local _lContinua := .T.
local _oHtml     := NIL
local _oProcess  := NIL
local _sArqHTM   := "\workflow\email_generico.htm" 

_aArq     := iif (_aArq     == NIL, {}, _aArq)
_sSubject := iif (_sSubject == NIL, "", _sSubject)
_sBody    := iif (_sBody    == NIL, "", _sBody)
if empty (_sTo) .AND. empty (_cCCO)
	_lContinua = .F.
endif

if _lContinua .and. ! file (_sArqHTM)
	u_help ("Arquivo '" + _sArqHTM + "' necessario para o envio de e-mail nao foi encontrado.")
	_lContinua = .F.
endif


if _lContinua
	procregua (2)
	incproc ("Aguarde, enviando e-mail...")
	
	// Se o texto recebido tem quebras de linha, troca-as por tags de nova linha em HTML.
	_sBody = '<p><font face="Courier New" size="2">' + _sBody
	_sBody = strtran (_sBody, chr(10), "")
	_sBody = strtran (_sBody, chr(13), "<br>")
	_sBody = _sBody + "</p>"
	
	_oProcess := Nil
	_oProcess := TWFProcess():New("SendMail", "Envio de e-mail generico" )
	_oProcess:NewTask ("TSendMail", "\workflow\email_generico.htm")
	

	_oProcess:AttachFile(_aArq)


	_oProcess:cSubject := _sSubject
	_oHtml :=_oProcess:oHTML
	if valtype (_oHtml) == "O"
		_oHtml:ValByName ("TITULO", _sSubject)
		_oHtml:ValByName ("TEXTO", _sBody)

		_oProcess:cTo = _sTo
		_oProcess:cBCC := _cCCO
		if valtype (_sReplyTo) == "C" .and. ! empty (_sReplyTo)
			_oProcess:cFromAddr = _sReplyTo
		endif
		conout("antes start")
		_oProcess:Start()
	endif
	_oProcess:Free()

endif
Return




