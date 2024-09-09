#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
 
/*/{Protheus.doc} zGerDanfe
Função que gera a danfe e o xml de uma nota em uma pasta passada por parâmetro
@author Atilio
@since 10/02/2019
@version 1.0
@param cNota, characters, Nota que será buscada
@param cSerie, characters, Série da Nota
@param cPasta, characters, Pasta que terá o XML e o PDF salvos
@type function
@example u_zGerDanfe("000123ABC", "1", "C:\TOTVS\NF")
@obs Para o correto funcionamento dessa rotina, é necessário:
    1. Ter baixado e compilado o rdmake danfeii.prw
    2. Ter baixado e compilado o zSpedXML.prw - https://terminaldeinformacao.com/2017/12/05/funcao-retorna-xml-de-uma-nota-em-advpl/
/*/
User Function zGerDanfe(cNota, cSerie, cPasta,cPedido,cTipo,cEmail,cCliente,cLoja,cEnv,cPvFil,cPv)
    Local aArea     := GetArea()
    Local cIdent    := ""
    Local cArquivo  := ""
    Local oDanfe    := Nil
    Local lEnd      := .F.
    Local nTamNota  := TamSX3('F2_DOC')[1]
    Local nTamSerie := TamSX3('F2_SERIE')[1]
    Local cTemp     := "\anexoArqOpme\"
    Local aAnexo :={}
    Local aAnexo    :={}
    Local cFont     := "DANFEII" 
    Local cFunc     := "u_DanfeProc"
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux

    //Default cNota   := ""
    //Default cSerie  := ""
    //Default cPasta  := GetTempPath()
     
    //Se existir nota
    If ! Empty(cNota)
        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
         
        //Se o último caracter da pasta não for barra, será barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf
         
        //Gera o XML da Nota
        cArquivo := Alltrim(cNota) + "_" + Alltrim(cSerie) + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
        u_zSpedXML(cNota, cSerie, cPasta + cArquivo  + ".xml", .F.)
        aAdd(aAnexo,cTemp + cArquivo + ".xml") 
        aAdd(aAnexo,cTemp + cArquivo + ".pdf")
        
        	 
        //Define as perguntas da DANFE
        Pergunte("NFSIGW",.F.)
        MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
        MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
        MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
        MV_PAR04 := 2                          //NF de Saida
        MV_PAR05 := 1                          //Frente e Verso = Sim
        MV_PAR06 := 2                          //DANFE simplificado = Nao
         
        //Cria a Danfe
        //msgstop("var criar Danfe com "+cArquivo)
        oDanfe := FWMSPrinter():New(cArquivo,6, .F., , .T.)
         
        //Propriedades da DANFE
        oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)
         
        //Força a impressão em PDF
        oDanfe:nDevice  := 6
        oDanfe:cPathPDF := cPasta                
        oDanfe:lServer  := .F.
        oDanfe:lViewPDF := .F.
         
        //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
        
        //Chamando a impressão da danfe no RDMAKE
        //msgstop("vai imprimir danfe "+cPasta)
        RptStatus({|lEnd| &("StaticCall("+cFont+","+cFunc+",@oDanfe, @lEnd, cIdent, , , .F.)")}, "Imprimindo Danfe...")
        //RptStatus({|lEnd| StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
        //RPTStatus( {|lEnd| U_DANFEProc(@oDanfe, @lEnd, cIDEnt, Nil, Nil, .F., .F.,,.F. )}, "Imprimindo DANFE…" )
        //msgstop("vai mostrar")
        oDanfe:Print()
    EndIf
     	If ! Empty(cPasta + cArquivo + ".xml") .and. !Empty(cPasta + cArquivo + ".pdf")
        	//ConOut(GetSrvProfString("RootPath","")+"\anexoArqOpme\")
        	//ConOut(cTemp)
        	CpyT2S(cPasta + cArquivo + ".xml",cTemp , .T. )
        	CpyT2S(cPasta + cArquivo + ".pdf",cTemp , .T. )
        endif
     If cEnv='S' .or. cEnv='O'

        IF  cEnv == 'O'
         	eNFeOPME(cNota,cSerie,cPedido,cTipo,'opme@mahospitalar.com.br;'+cEmail,cCliente,cLoja,aAnexo,cPvFil,cPv)
        Else
         	eNFeOPME(cNota,cSerie,cPedido,cTipo,cEmail,cCliente,cLoja,aAnexo,cPvFil,cPv)
        Endif
     endif 
    RestArea(aArea)
Return




/*/{Protheus.doc} zSpedXML
Função que gera o arquivo xml da nota (normal ou cancelada) através do documento e da série disponibilizados
@author Atilio
@since 25/07/2017
@version 1.0
@param cDocumento, characters, Código do documento (F2_DOC)
@param cSerie, characters, Série do documento (F2_SERIE)
@param cArqXML, characters, Caminho do arquivo que será gerado (por exemplo, C:\TOTVS\arquivo.xml)
@param lMostra, logical, Se será mostrado mensagens com os dados (erros ou a mensagem com o xml na tela)
@type function
@example Segue exemplo abaixo
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo1.xml", .F.) //Não mostra mensagem com o XML
     
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo2.xml", .T.) //Mostra mensagem com o XML
/*/
 
User Function zSpedXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       
    Local cTextoXML    := ""
    Local cFont        := "SPEDNFE" 
    Local cFunc        := "GetIdEnt"
    //Default cDocumento := ""
    //Default cSerie     := ""
    //Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    //Default lMostra    := .F.
     
    
    
    
    cIdEnt := &("StaticCall("+cFont+","+cFunc+")")
    
    
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
         
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"   
         
        //Se tiver notas
        If oWebServ:RetornaNotas()
         
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
             
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                     
                //Senão, pega o xml normal
                Else
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                EndIf
                 
                //Gera o arquivo
                MemoWrite(cArqXML, cTextoXML)
                 
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                 
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                 
                If lMostra
                    Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
         
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
             
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return

static  Function  eNFeOPME(cNota,cSerie,cPedido,cTipo,cEmail,cCliente,cLoja,aAnexo,cPvFilial,cPvend)

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
_cHTML+=' <h1 style='+'"font:normal normal normal 22px'+" 'open sans', sans-serif; color:rgb(0,136,203);padding-top: 	3px;padding-bottom:	3px;"+'">'
_cHTML+=' Nota Fiscal '
_cHTML+=' </h1> '

_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(54,54,54);"+'">'+"Ol&aacute;!</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(79,79,79);"+'">'+"Segue em anexo a NF de " +AllTrim(cTipo)+" de consignado! </h2>"
_cHTML+=' <!-- Cabeçalho do Titulos --> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0,136,203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+=' 		<td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0,136,203);"+'">'+"Documento - Serie</h2> </td>"	
_cHTML+='	</tr> '
_cHTML+='	<tr> '
_cHTML+='       <td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(79,79,79);"+'">'+AllTrim(cNota)+' - '+AllTrim(cSerie)+" </h2> </td>"
_cHTML+='	</tr> '
_cHTML+='	</table> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0,136,203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' </div> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+=' 		<td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0,136,203);"+'">'+"Dados adicionais</h2> </td>"	
_cHTML+='	</tr> '
_cHTML+='	<tr> '
_cHTML+='  <td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(79,79,79);"+'">'+U_cInfOPME(cPvFilial,cPvend)+" </h2> </td>"
_cHTML+='	</tr> '
_cHTML+='	</table> ' 
_cHTML+=' <div class="grid" style="border-top:solid rgb(0,136,203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' </div> '
_cHTML+='   </body>'
_cHTML+='   </html>'
memowrite("C:\relato\EmailClienteOPME.html",_cHTML)


//zEnvMail('ednei.silva@mahospitalar.com.br;barbara.monardes@mahospitalar.com.br', 'Workflow OPME', _cHTML, {}, .F., .T.)
zEnvMail(cEmail, 'Workflow OPME', _cHTML, aAnexo, .F., .T.)
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


User Function cInfOPME(cFilPv,cPedido)
Local cMensCli	:= ''
Local cAliasX	:= GetNextAlias()

BeginSql  Alias cAliasX
SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_CODMED,C5_NOMMED,C5_PACIENT,C5_DPROCED,C5_ZDESPRC,C5_ZCODPRC 
FROM %Table:SC5% SC5
WHERE C5_FILIAL  = %Exp:cFilPv% AND	
	  C5_NUM 	  = %Exp:cPedido% AND 
	  SC5.%notdel%
EndSql

cMensCli		:= ''	

If !EMPTY((cAliasX)->C5_NUM) 
	cMensCli += '  Pedido de Venda: '+ (cAliasX)->C5_NUM+' - '+ Chr(13)
Endif

If !EMPTY((cAliasX)->C5_NOMMED) 
	cMensCli += '  Medico: '   		 + capital((cAliasX)->C5_NOMMED)+' - '+ Chr(13) 
Endif 
		
If !EMPTY((cAliasX)->C5_PACIENT)      
	cMensCli += '  Paciente: ' 	 	 + capital((cAliasX)->C5_PACIENT)+' - '+ Chr(13)
Endif
    
If !EMPTY((cAliasX)->C5_DPROCED)      
	cMensCli += '  Dt. Procedimento: ' + dToC(sToD((cAliasX)->C5_DPROCED))+' - '+ Chr(13) 
Endif
    
If !EMPTY((cAliasX)->C5_ZDESPRC) 
	cMensCli += '  Procedimento: ' 	   + AllTrim((cAliasX)->C5_ZCODPRC)+' / '+capital(AllTrim((cAliasX)->C5_ZDESPRC))+ Chr(13)
Endif
	  
return cMensCli 















