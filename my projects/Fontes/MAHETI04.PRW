#Include "Totvs.ch"
#Include "RptDef.CH"
#Include "FwPrintSetup.ch"
#Include "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMAHETI02    บAutor  ณEdnei Silva      บ Data ณ  27/04/20    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Impressao de Etiquetas de Consignado					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


#define CRLF Chr(13)+Chr(10)
User Function MAHETI04( cAlias, nReg, nOpc )

Local cPerg			:= PadR("MAHETI04",10)
Local cFilePrint	:= "etiqueta_recebimento_"+ DtoS( dDataBase ) + StrTran(Time(),":","")
Local cPathInServer	:= "\spool\"
Local cSession		:= GetPrinterSession()
Local aDevice		:= {}
Local lOk			:= .F.
Local lExec			:= .F.
Local cMsgTxt       := ""
Local nOpc          :=0
Private oPrint  := Nil
Private oSetup  := Nil
Private oFont05N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont10N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont11N:= TFont():New('Arial',,05,.T.,.F.)
Private oFont10B:= TFont():New('Arial',,04,.T.,.F.)
Private oFont12N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont14N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont16N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont24N:= TFont():New('Arial',,24,.T.,.F.)

/*Private oFont05N:= TFont():New('Arial',,05,.T.,.F.)
Private oFont10N:= TFont():New('Arial',,05,.T.,.T.)
Private oFont10B:= TFont():New('Arial',,05,.T.,.T.)
Private oFont12N:= TFont():New('Arial',,08,.T.,.T.)
Private oFont14N:= TFont():New('Arial',,10,.T.,.T.)
Private oFont16N:= TFont():New('Arial',,12,.T.,.T.)
Private oFont24N:= TFont():New('Arial',,24,.T.,.T.)
*/

Private nLin    	:= 0
Private nLinBar 	:= 0

Private lRefresh := .T.
Private aHeader  := {}
Private aCols 	 := {}
Private aRotina  := {}

Private cICnpj  :="04.078.043/0001-40"
Private cIEnd   :="FRANSICO SILVEIRA BITENCOURT"
Private cINumEnd:="1369"
Private cIBairro:="SARANDI"
Private cIEst   :="RS"
Private cICid   :="PORTO ALEGRE"
Private cITel   :="+55(51)3364.5038"






oFont10B:Bold := .T.

CriaSX1( cPerg )

If Pergunte(cPerg,.T.)
	
	Private cProduto  	:= MV_PAR01
	Private cLote		:= MV_PAR02
	Private dValid		:= MV_PAR03
	Private nFracao		:= MV_PAR04
	lOk := R001List()
	
EndIf

If nFracao=2
	cMsgTxt:=" Voce selecionou o parametro de quantidades fracionadas (itens avulsos). "+CRLF
	cMsgTxt+=" Esta opao fara com que todas as etiquetas sejam "+CRLF
	cMsgTxt+=" impressas com quantidade 1(UM), ate mesmo caixas de filtros. "+CRLF
	cMsgTxt+=" Deseja continuar mesmo assim? "
 
	nOpc := Aviso( "Etiquetas MA", cMsgTxt, { "Sim", "Nใo" }, ;
				3, "Impressao Itens Avulsos?",, 'ENGRENAGEM', .F., 0)
	If nOpc == 2
 		return
	endif
 
Endif



If lOk
	
	
	aAdd(aDevice,"DISCO") // 1
	aAdd(aDevice,"SPOOL") // 2
	aAdd(aDevice,"EMAIL") // 3
	aAdd(aDevice,"EXCEL") // 4
	aAdd(aDevice,"HTML" ) // 5
	aAdd(aDevice,"PDF"  ) // 6
	
	nLocal       	:= If( GetProfString( cSession,"LOCAL"			,"SERVER"		,.T. ) == "SERVER"	,1,2 )
	nOrientation	:= If( GetProfString( cSession,"ORIENTATION"	,"PORTRAIT"	,.T. ) == "PORTRAIT"	,1,2 )
	cDevice     	:= 		GetProfString( cSession,"PRINTTYPE"	,"SPOOL"		,.T. )
	nPrintType		:= aScan( aDevice,{|x| x == cDevice } )
	
	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	oSetup := FWPrintSetup():New( nFlags , cFilePrint )
	
	oSetup:SetPropert(PD_PRINTTYPE   , IMP_SPOOL)
	oSetup:SetPropert(PD_ORIENTATION , nOrientation)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	oSetup:SetPropert(PD_PAPERSIZE   , 6)
	
	lAdjustToLegacy := .F.
	lDisableSetup   := .T.
	lViewPDF        := .T.
	lPdfAsPng       := .T.
	
	oPrint := FWMSPrinter():New( cFilePrint ,IMP_SPOOL , lAdjustToLegacy , cPathInServer , lDisableSetup , , oSetup , , , lPdfAsPng , , lViewPDF )
	
	If oSetup:Activate() == PD_OK // PD_OK =1
		
		// ----------------------------------------------
		// Salva os Parametros no Profile
		// ----------------------------------------------
		WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION) == 1 ,"SERVER"    ,"CLIENT"    ), .T. )
		WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)   == 1 ,"SPOOL"     ,"PDF"       ), .T. )
		WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION) == 1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
		
		// ----------------------------------------------
		// Define saida de impresso
		// ----------------------------------------------
		oPrint:SetPortrait()
		oPrint:SetMargin( 0,0,0,0 ) //nEsquerda, nSuperior, nDireita, nInferior
		
		If	oSetup:GetProperty(PD_PRINTTYPE) = IMP_SPOOL
			
			//oPrint:SetPaperSize(27)
			oPrint:nDevice := IMP_SPOOL
			// ----------------------------------------------
			// Salva impressora selecionada
			// ----------------------------------------------
			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]
			
		ElseIf oSetup:GetProperty(PD_PRINTTYPE) = IMP_PDF
			
			//oPrint:SetPaperSize(0,80,50)
			oPrint:nDevice := IMP_PDF
			// ----------------------------------------------
			// Define para salvar o PDF
			// ----------------------------------------------
			oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			
		EndIf
		
		Processa( {|| lExec := R001Exec() }, "Imprimindo etiquetas" ,"Aguarde...." )
		
		If lExec
			oPrint:Preview() // Abre preview do PDF
		EndIf
		
	EndIf
	
	FreeObj( oPrint )
	FreeObj( oSetup )
	oPrint   := Nil
	oSetup   := Nil
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR001Exec     บAutor  ณEdnei Silva      บ Data ณ  01/06/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Executa a rotina de impressao       					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function R001Exec()

Local nEtq		:= 0
Local nPrd		:= 0

ProcRegua( Len( aCols ) )

For nPrd := 1 To Len( aCols )
	
	For nEtq := 1 To aCols[nPrd][13]
		
		IncProc()
		
		nLin 	:= 018
		nCol	:= 012
		nLinBar := 4.11
		nColBar := 2.20
		
		oPrint:StartPage()
		
		R001Imp( aCols[nPrd][1], aCols[nPrd][2], aCols[nPrd][3], aCols[nPrd][4],aCols[nPrd][5],aCols[nPrd][6],aCols[nPrd][7],aCols[nPrd][8],aCols[nPrd][9],aCols[nPrd][10],aCols[nPrd][11],aCols[nPrd][12])
		
		
		oPrint:EndPage()
		
	Next nEtq
	
Next nPrd

Return( Len( aCols ) > 0 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR001List     บAutor  ณEdnei Silva      บ Data ณ  01/06/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Lista os produtos da nota fiscal informada nos parametros บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function R001List()

Local oDlg
Local oGetDados
Local lRet		:= .T.
Local nI		:= 0
Local cQuery	:= ""
Local cAliasTmp	:= GetNextAlias()
Local aCampos	:= {"B8_PRODUTO","B1_DESC","B8_LOTECTL","B1_CODBAR","B8_DTVALID","B1_NRANVIS","B1_PROCEDE","B8_DFABRIC","B1_RESPTEC","B1_FABRIC","B1_ENDFABR","B1_POSIPI"}
Local aButtons	:= {}
Local bOk		:= {||}
Local bCancel	:= {||}


For nI := 1 To Len( aCampos )
	
	
	aAdd(aHeader,{AllTrim(GetSx3Cache(aCampos[nI], 'X3_TITULO')),;
	AllTrim(GetSx3Cache(aCampos[nI], 'X3_CAMPO')),;
	GetSx3Cache(aCampos[nI], 'X3_PICTURE'),;
	GetSx3Cache(aCampos[nI], 'X3_TAMANHO'),;
	GetSx3Cache(aCampos[nI], 'X3_DECIMAL'),;
	GetSx3Cache(aCampos[nI], 'X3_VALID'),;
	"",;
	GetSx3Cache(aCampos[nI], 'X3_TIPO'),;
	"",;
	"" })
	
Next nI

aAdd( aHeader, { "Qdte. Etiquetas","QTDE_ETQ","999",3,0, ,"","N","","" } )

cQuery := " SELECT SB8.B8_PRODUTO, SB8.B8_LOTECTL, "
cQuery += " SUBSTRING(B8_DTVALID,7,2)+'/'+SUBSTRING(B8_DTVALID,5,2)+'/'+SUBSTRING(B8_DTVALID,1,4) B8_DTVALID, "
cQuery += " SUBSTRING(B8_DFABRIC,7,2)+'/'+SUBSTRING(B8_DFABRIC,5,2)+'/'+SUBSTRING(B8_DFABRIC,1,4) B8_DFABRIC, "
cQuery += " SB1.B1_MARCA, SB1.B1_NRANVIS, SB1.B1_PROCEDE, SB1.B1_RESPTEC, SB1.B1_FABRIC, SB1.B1_ENDFABR, SB1.B1_POSIPI FROM  "
cQuery +=   		   RetSqlName("SB1") + " SB1, "
cQuery +=			   RetSqlName("SB8") + " SB8  "	
cQuery += "  WHERE SB8.B8_PRODUTO  = SB1.B1_COD "
cQuery += "    AND SB8.B8_PRODUTO  = '" + cProduto    + "'"
cQuery += "    AND SB8.B8_LOTECTL  = '" + cLote   + "'"
cQuery += "    AND SB8.B8_FILIAL   = '" + xFilial("SB8") + "'"
cQuery += "    AND SB8.D_E_L_E_T_ <> '*'"
cQuery += "    AND SB1.D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T. )

dbSelectArea( cAliasTmp )
( cAliasTmp )->( dbGoTop() )

If ( cAliasTmp )->( !EoF() )
	
	While ( cAliasTmp )->( !EoF() )
		
		SB1->( dbSeek( xFilial("SB1") + ( cAliasTmp )->B8_PRODUTO ) )
		
		aAdd( aCols, { ( cAliasTmp )->B8_PRODUTO,;
		SB1->B1_DESC,;
		( cAliasTmp )->B8_LOTECTL,;
		SB1->B1_CODBAR,;
		( cAliasTmp )->B8_DTVALID,;
		( cAliasTmp )->B1_NRANVIS,;
		( cAliasTmp )->B1_PROCEDE,;
		( cAliasTmp )->B8_DFABRIC,;
		( cAliasTmp )->B1_RESPTEC,;
		( cAliasTmp )->B1_FABRIC,;
		( cAliasTmp )->B1_ENDFABR,;
		( cAliasTmp )->B1_POSIPI,1, .F.} )
		
		
		( cAliasTmp )->( dbSkip() )
		
	EndDo
	
	bOk     := {|| Iif( R001TdOk(oGetDados:aCols), oDlg:End(), MsgAlert("Existem produtos sem quantidade informada","Atenมo") ), lOk := .T. }
	bCancel := {|| oDlg:End(), lRet := .F. }
	
	DEFINE MSDIALOG oDlg TITLE "Listagem de Produtos" FROM 000,000 TO 400,745 PIXEL
	
    oGetDados := MsNewGetDados():New(050, 000, 188, 375, GD_UPDATE, "AllwaysTrue", "AllwaysTrue","",{"QTDE_ETQ"}, 0,99 , "AllwaysTrue", "AllwaysTrue", "AllwaysFalse", oDlg, aHeader, aCols)
	
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, bOk, bCancel, ,aButtons ) ) CENTERED
	
	aCols := oGetDados:aCols
	
Else
	
	lRet := .F.
	
EndIf

( cAliasTmp )->( dbCloseArea() )

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR001TdOk     บAutor  ณEdnei Silva      บ Data ณ  01/06/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Verifica se todos os produtos possuem qtd de etiquetas    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function R001TdOk( aCols )

Local lRet	:= .T.
Local nP	:=	0

For nP := 1 To Len( aCols )
	
	If aCols[nP][13] <= 0
		lRet := .F.
	EndIf
	
Next nP

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR001Imp      บAutor  ณEdnei Silva      บ Data ณ  01/06/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Imprime as informacoes a serem impressas na etiqueta      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function R001Imp( cCodProd, cDescProd, cLoteProd, cCodBar,cDtValid,cNrAnvi,cProced,cDFabric,cRespTec,cFabric,cEndFabr,cNCM)

Local nColAdd := 0
Local nLinAdd := 0
Local aSM0    := FWLoadSM0()
Local nPosSM0 :=1
Local nLinNac :=20
Local cQtdPro :='' 
Local cQcode  :=''
Local cID     :=''
Local aAlfa     := {'a','b','c','d','e','f','g','h','i','j','l','m','n','o','p','q','w','k','u','v','y','x','z'}
Local aChar     := {'*','@','!','$','#'}
Local nAlfa:= 0
Local nChar:= 0
Local nID  := 0
//nPosSM0 := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == xFilial("SD1")}) 
nCol 	+= 100
nLin 	+= 0
nLinBar += 0
nColBar += 0

//alert('CodSM0 '+aSM0[nPosSM0,SM0_CODFIL]+' Cod Filial'+xFilial("SD1"))

nAlfa:= Randomic(1,23)
nChar:= Randomic(1,5)
nID  :=Randomic(1,99)
cQtdPro :=''                                           
cID     :=allTrim(aAlfa[nAlfa])+Alltrim(str(nID))+Alltrim(aChar[nChar])






cQtdPro :='1'

IF (AllTrim(cCodProd) $ '352/5855;351/5878;350/5422;355/5427;353/19004;331/5661;331/5389;355/5814;352/5877') .And. nFracao=1
   cQtdPro :='25'
Endif

IF (AllTrim(cCodProd) $ '775659;775100;674655') .And. nFracao=1
   		cQtdPro :='30'
Endif
  






cQcode  :=AllTrim(cCodProd) +Char(13)   //" COD. PRODUTO: " 
cQcode  +=AllTrim(cDFabric) +Char(13)   //" DT. FAB.: 	 "    
cQcode  +=AllTrim(cDtValid) +Char(13)  //" VALIDADE: 	 "    
cQcode  +=AllTrim(cLoteProd)+Char(13)   //" LOTE: 		 "
cQcode  +=AllTrim(cQtdPro)	+Char(13)  //" Quantidade:   "
cQcode  +=AllTrim(cID)		+Char(13)   //" Id Unico do lote:   "
//oPrint:Box(13,15,29,nColFim)
// Inf. Produto






oPrint:Box(nLin,nCol-2,110,200)
//oPrint:Box(35,nCol-2,65,295)
nLinAdd +=4
// Inf. Produto

oPrint:Say( nLin+nLinAdd	, nCol	,   "COD.: "	    	, oFont10N)
oPrint:Say( nLin+nLinAdd	, nCol+15 	, AllTrim(cCodProd)		, oFont11N)
nLinAdd+=5
oPrint:Say( nLin+nLinAdd	, nCol , 	"DES.: "			, oFont10N)
oPrint:Say( nLin+nLinAdd	, nCol+15 	, substr(AllTrim(cDescProd),1,30)	, oFont10N)
nLinAdd +=5
oPrint:Say( nLin+nLinAdd	, nCol+15 	, substr(AllTrim(cDescProd),31,30)	, oFont10N)
nLinAdd +=5

//*****************************Linha 1 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol 		    , "FAB.: "			, oFont10N ) 
nColAdd +=15
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	, AllTrim(cDFabric)		, oFont10N)
nColAdd +=22
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd	, "VAL.: "			, oFont10N )

nColAdd +=10
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	, AllTrim(cDtValid)		, oFont10N)

nLinAdd +=5
nColAdd :=0
//***********************Lote e Serie***************************************
oPrint:Say( nLin+nLinAdd	, nCol	, "LOT: "				, oFont10N )
nColAdd +=15
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	, AllTrim(cLoteProd)	, oFont11N)
nLinAdd +=5
nColAdd :=0 
oPrint:Say( nLin+nLinAdd	, nCol			, "N/S: "					, oFont10N )
oPrint:Say( nLin+nLinAdd	, nCol+15  , AllTrim(cLoteProd)  		, oFont10N)


nLinAdd +=5
nColAdd :=0
//*****************************RMS ORIGEM**********************************

oPrint:Say( nLin+nLinAdd	, nCol 	, "ANV.: "			, oFont10N )
nColAdd +=15
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd  , AllTrim(cNrAnvi)+" - ORIG.: "+AllTrim(POSICIONE("SYA", 1, xFilial("SYA") + cProced, "YA_SIGLA") )			, oFont10N)

//****************************************************************************

nLinAdd +=5
nColAdd :=0
//*****************************Linha 2 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol 			, "NCM: "					, oFont10N )
nColAdd +=15
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd  , AllTrim(cNCM)  		, oFont10N)

nLinAdd +=5
nColAdd :=0
//oPrint:Box(65,nCol-2,95,285)
//*****************************Linha 3 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol 	     	, "IND.: "		   	, oFont10N )
nColAdd +=15
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	,	cFabric	, oFont10N)
nLinAdd +=5
oPrint:Say( nLin+nLinAdd	, nCol 	, "END.: "	, oFont10N)

oPrint:Say( nLin+nLinAdd	, nCol+15 	, substr(AllTrim(cEndFabr),1,30)	, oFont10N)
nLinAdd +=5
oPrint:Say( nLin+nLinAdd	, nCol+15 	, substr(AllTrim(cEndFabr),31,30)	, oFont10N)
nLinAdd +=5
nColAdd :=0
oPrint:Say( nLin+nLinAdd	, nCol 	, AllTrim("TEC.:")	, oFont10N)
oPrint:Say( nLin+nLinAdd	, nCol+15 	, AllTrim(cRespTec)	, oFont10N)

nColAdd :=0
//****************************************************************************


//oPrint:Box(95,nCol-2,125,285)
nLinAdd +=5
nColAdd :=0
//*****************************Linha 3 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol 	     	, "DIS.: "		   	, oFont10N )
oPrint:Say( nLin+nLinAdd	, nCol+15	, "MONTEIRO ANTUNES INSUMOS"	, oFont10N)
nLinAdd +=5
nColAdd +=0
oPrint:Say( nLin+nLinAdd	, nCol+15	, "HOSPITALARES LTDA"	, oFont10N)
nLinAdd +=5
nColAdd :=0
oPrint:Say( nLin+nLinAdd	, nCol 	, 'CNPJ: '	, oFont10N)
oPrint:Say( nLin+nLinAdd	, nCol+15 	,	AllTrim(cICnpj), oFont10N)
nLinAdd +=5
nColAdd :=0
oPrint:Say( nLin+nLinAdd	, nCol 	, 'END.: '	, oFont10N)
oPrint:Say( nLin+nLinAdd	, nCol+15 	,	AllTrim(cIEnd), oFont10N)
nLinAdd +=5
nColAdd :=0
oPrint:Say( nLin+nLinAdd	, nCol+15 	, cICid+", "+cIBairro+" - "+cIEst	, oFont10N)
nLinAdd +=5
nColAdd :=0
oPrint:Say( nLin+nLinAdd	, nCol 	, AllTrim("TEC.:")	, oFont10N)
oPrint:Say( nLin+nLinAdd	, nCol+15	, AllTrim(cRespTec)	, oFont10N)
nColAdd :=0
//***************************************************************************/*  

//*************QrCode*************
oPrint:QRCode(110,12,cQcode , 95) 
//********************************

oPrint:SayBitmap( nLin+28, nCol+82,"C:\MA.bmp", 07, 65 )
nLinAdd +=0
//oPrint:Box(50,35,100,100)
//oPrint:Say( 75	, 35   	, "MA"					, oFont24N,,)
nLinAdd +=0
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaSx       บAutor  ณEdnei Silva      บ Data ณ  01/06/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do grupo de perguntas                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function CriaSx1( cPerg )
Local cValid   := ""
Local cF3      := ""
Local cPicture := ""
Local cDef01   := ""
Local cDef02   := ""
Local cDef03   := ""
Local cDef04   := ""
Local cDef05   := ""

u_PutSX1(cPerg, "01", "Produto"	    ,"MV_PAR01", "MV_CH0", TamSX3("B8_PRODUTO")[3]    , TamSX3("B8_PRODUTO")[1]    , TamSX3("B8_PRODUTO")[2]    , "G", atuData(), "SB8ETI", cPicture,  cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Codigo do Produto")
u_PutSX1(cPerg, "02", "Lote"	    ,"MV_PAR02", "MV_CH1", TamSX3("B8_LOTECTL")[3]    , TamSX3("B8_LOTECTL")[1]    , TamSX3("B8_LOTECTL")[2]    , "G", cValid,       cF3    , cPicture,  cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Lote")
u_PutSX1(cPerg, "03", "Validade"	,"MV_PAR03", "MV_CH2", TamSX3("B8_DTVALID")[3]    , TamSX3("B8_DTVALID")[1]	   , TamSX3("B8_DTVALID")[2]    , "G", cValid,       cF3    , cPicture,  cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Data de balidate")
u_PutSX1(cPerg, "04", "Fracionado"  ,"MV_PAR04", "MV_CH3", "N"                        , 01                         , 0                          , "C", cValid,       cF3    , cPicture,  "NAO" ,  "SIM" ,        cDef03,        cDef04,    cDef05, "Caixas pracinadas")

Return


static Function atuData()

MV_PAR02:=SB8->B8_LOTECTL
MV_PAR03:=SB8->B8_DTVALID

Return

/*---------------------------------------------------*
| Fun็ใo: fPutHelp                                  |
| Desc:   Fun็ใo que insere o Help do Parametro     |
*---------------------------------------------------*/

Static Function fPutHelp(cKey, cHelp, lUpdate)
Local cFilePor  := "SIGAHLP.HLP"
Local cFileEng  := "SIGAHLE.HLE"
Local cFileSpa  := "SIGAHLS.HLS"
Local nRet      := 0
Default cKey    := ""
Default cHelp   := ""
Default lUpdate := .F.

//Se a Chave ou o Help estiverem em branco
If Empty(cKey) .Or. Empty(cHelp)
	Return
EndIf

//**************************** Portugu๊s
nRet := SPF_SEEK(cFilePor, cKey, 1)

//Se nใo encontrar, serแ inclusใo
If nRet < 0
	SPF_INSERT(cFilePor, cKey, , , cHelp)
	
	//Senใo, serแ atualiza็ใo
Else
	If lUpdate
		SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
	EndIf
EndIf



//**************************** Ingl๊s
nRet := SPF_SEEK(cFileEng, cKey, 1)

//Se nใo encontrar, serแ inclusใo
If nRet < 0
	SPF_INSERT(cFileEng, cKey, , , cHelp)
	
	//Senใo, serแ atualiza็ใo
Else
	If lUpdate
		SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
	EndIf
EndIf



//**************************** Espanhol
nRet := SPF_SEEK(cFileSpa, cKey, 1)

//Se nใo encontrar, serแ inclusใo
If nRet < 0
	SPF_INSERT(cFileSpa, cKey, , , cHelp)
	
	//Senใo, serแ atualiza็ใo
Else
	If lUpdate
		SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
	EndIf
EndIf
Return

Static function cAbreNom(cNome)

  Local aNomes:={}
  Local i:=0
  Local n:=0
  Local cAbrevia:=''
  cAbrevia := cNome
  cNome  := AllTrim(cNome)
 
  if Len(cNome) > 0 
  
    aNomes:=separa(cNome,' ',.F.)
   
 
    if Len(aNomes) > 1 
                                                                      
      //Abreviar a partir do segundo nome, exceto o ๚ltimo.
      for i := 1 to Len(aNomes) - 1 
        //Cont้m mais de 3 letras? (ignorar de, da, das, do, dos, etc.)
        if Len(aNomes[i]) > 3
          aNomes[i] := substr(aNomes[i],1,3) + '.'
        endif
      next
      
      cAbrevia := ''
      
      for i := 1 to Len(aNomes)
        cAbrevia := cAbrevia + Trim(aNomes[i]) + ' '
      next
      
    endif
  endif
  
Return cAbrevia

static function Randomic(nMin,nMax)
Local nDiff := nMax-nMin
Local nDec := 0
If nDiff < 32766
   Return Randomize(nMin,nMax)
Endif
While nDiff > 32765
   nDiff /= 10 
   nDec++
Enddo
nTmp := randomize(0,int(nDiff))
While nDec > 0 
   nTmp *= 10 
   nTmp += randomize(0,10) 
   nDec--
Enddo
Return nMin+nTmp
