#INCLUDE "PROTHEUS.CH"
#Include "Totvs.ch"
#Include "RptDef.CH"
#Include "FwPrintSetup.ch"
#Include "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMAHETI02    บAutor  ณEdnei Silva      บ Data ณ  01/06/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Impressao de Etiquetas de Recebimento					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



User Function MAHQCODE()

#DEFINE CRLF (Chr(13)+Chr(10))

Local cPerg			:= PadR("MAHETI03",10)
Local cFilePrint	:= "etiqueta_recebimento_"+ DtoS( dDataBase ) + StrTran(Time(),":","")
Local cPathInServer	:= "\spool\"
Local cSession		:= GetPrinterSession()
Local aDevice		:= {}
Local lOk			:= .F.
Local lExec			:= .F.

Private oPrint  := Nil
Private oSetup  := Nil
Private oFont05N:= TFont():New('Arial',,06,.T.,.F.)
Private oFont10N:= TFont():New('Arial',,06,.T.,.T.)
Private oFont10B:= TFont():New('Arial',,06,.T.,.T.)
Private oFont11N:= TFont():New('Arial',,07,.T.,.T.)
Private oFont12N:= TFont():New('Arial',,08,.T.,.T.)
Private oFont14N:= TFont():New('Arial',,10,.T.,.T.)
Private oFont16N:= TFont():New('Arial',,12,.T.,.T.)

Private nLin    	:= 5
Private nLinBar 	:= 0

Private lRefresh := .T.
Private aHeader  := {}
Private aCols 	 := {}
Private aRotina  := {}

Private cICnpj  :="04.078.043/0002-21"
Private cIEnd   :="ALBERTO WERNER"
Private cINumEnd:="191"
Private cIBairro:="VILA OPERARIA"
Private cIEst   :="SC"
Private cICid   :="ITAJAI"
Private cITel   :="+55(47)30456695"






oFont10B:Bold := .T.

CriaSX1( cPerg )

If Pergunte(cPerg,.T.)
	
	Private cProduto  	:= MV_PAR01
	Private cLote		:= MV_PAR02
	Private dValid		:= MV_PAR03
	
	lOk := R001List()
	
EndIf

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
	
	For nEtq := 1 To aCols[nPrd][12]
		
		IncProc()
		
		nLin 	:= 018
		nCol	:= 012
		nLinBar := 4.11
		nColBar := 2.20
		
		oPrint:StartPage()
		
		R001Imp( aCols[nPrd][1], aCols[nPrd][2], aCols[nPrd][3], aCols[nPrd][4],aCols[nPrd][5],aCols[nPrd][6],aCols[nPrd][7],aCols[nPrd][8],aCols[nPrd][9],aCols[nPrd][10],aCols[nPrd][11])
		
		
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
Local aCampos	:= {"B8_PRODUTO","B1_DESC","B8_LOTECTL","B1_CODBAR","B8_DTVALID","B1_NRANVIS","B1_PROCEDE","B8_DFABRIC","B1_RESPTEC","B1_FABRIC","B1_ENDFABR"}
Local aButtons	:= {}
Local bOk		:= {||}
Local bCancel	:= {||}
aSX3            := {} 
cDesCampo       :=""        
//dbSelectArea("SX3")
//dbSetOrder(2)

For nI := 1 To Len( aCampos )
	
	dbSeek( aCampos[nI] )
	aSX3:={}
	cDesCampo:=""
	aSX3:=FWSX3Util():GetFieldStruct( aCampos[nI] )
    cDesCampo:=FWSX3Util():GetDescription( aCampos[nI] )
	aAdd(aHeader,{Trim(cDesCampo),;
	aSX3[01] ,;
	"",;
	aSX3[03],;
	aSX3[04],;
	"",;
	"",;
	aSX3[02],;
	"",;
	"" })
	
Next nI

aAdd( aHeader, { "Qdte. Etiquetas","QTDE_ETQ","999",3,0, ,"","N","","" } )

cQuery := " SELECT SB8.B8_PRODUTO, SB8.B8_LOTECTL, "
cQuery += " SUBSTRING(B8_DTVALID,7,2)+'/'+SUBSTRING(B8_DTVALID,5,2)+'/'+SUBSTRING(B8_DTVALID,1,4) B8_DTVALID, "
cQuery += " SUBSTRING(B8_DFABRIC,7,2)+'/'+SUBSTRING(B8_DFABRIC,5,2)+'/'+SUBSTRING(B8_DFABRIC,1,4) B8_DFABRIC, "
cQuery += " SB1.B1_MARCA, SB1.B1_NRANVIS, SB1.B1_PROCEDE, SB1.B1_RESPTEC, SB1.B1_FABRIC, SB1.B1_ENDFABR FROM  "
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
		( cAliasTmp )->B1_ENDFABR,1, .F.} )
		
		
		( cAliasTmp )->( dbSkip() )
		
	EndDo
	
	bOk     := {|| Iif( R001TdOk(oGetDados:aCols), oDlg:End(), MsgAlert("Existem produtos sem quantidade informada","Atenมo") ), lOk := .T. }
	bCancel := {|| oDlg:End(), lRet := .F. }
	
	DEFINE MSDIALOG oDlg TITLE "Listagem de Produtos" FROM 000,000 TO 400,745 PIXEL
	
	oGetDados := MsNewGetDados():New(050, 000, 188, 375, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",;
	"",{"QTDE_ETQ"}, 0, , "AllwaysTrue", "AllwaysTrue", "AllwaysFalse", oDlg, aHeader, aCols)
	
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
	
	If aCols[nP][12] <= 0
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


Static Function R001Imp( cCodProd, cDescProd, cLoteProd, cCodBar,cDtValid,cNrAnvi,cProced,cDFabric,cRespTec,cFabric,cEndFabr)
Local nColAdd := 0
Local nLinAdd := 0
Local nColFim := 285
Local aSM0    := FWLoadSM0()
Local nPosSM0 :=1
Local cQcode  :=''
Private oQrCode

 
nCol 	+= 122
nLin 	+= 0
nLinBar += 0
nColBar += 0



cQcode  :=AllTrim(cCodProd) +CRLF   //" COD. PRODUTO: " 
cQcode  +=AllTrim(cDFabric) +CRLF   //" DT. FAB.: 	 "    
cQcode  +=AllTrim(cDtValid) +CRLF   //" VALIDADE: 	 "    
cQcode  +=AllTrim(cLoteProd)+CRLF  //" LOTE: 		 "		  

oPrint:Box(13,15,29,nColFim)
// Inf. Produto
nLinAdd +=0
oPrint:Say( nLin+nLinAdd+2	, 17   	, "COD.: "		, oFont11N)
oPrint:Say( nLin+nLinAdd+2	, 17+020 	, AllTrim(cCodProd)		, oFont11N)
nLinAdd+=07
//oPrint:Say( nLin+nLinAdd	, nCol 	    , "DESC.: "		   	, oFont11N)
oPrint:Say( nLin+nLinAdd+2	, 17    	, AllTrim(cDescProd)	, oFont11N)

oPrint:Box(35,nCol-2,65,nColFim)
nLinAdd +=17

//*****************************Linha 1 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol 		    , "DT. FAB.: "			, oFont10B ) 
nColAdd +=25
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	, AllTrim(cDFabric)		, oFont10N)
nColAdd +=40
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd	, "DT. VAL.: "			, oFont10B )
nColAdd +=30
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	, AllTrim(cDtValid)		, oFont10N)
nColAdd :=0
//****************************************************************************


nLinAdd +=10
//*****************************Linha 2 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol			, "LOTE: "				, oFont10B )
nColAdd +=25
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 		, AllTrim(cLoteProd)	, oFont10N)
nColAdd +=40
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd , "N/S: "					, oFont10B )
nColAdd +=30
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd  , AllTrim(cLoteProd)  		, oFont10N)
nColAdd :=0

nLinAdd +=10
//*****************************Linha 3 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol 	        , "ANVISA: "			, oFont10B )
nColAdd +=25
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd  , AllTrim(cNrAnvi)			, oFont10N)
nColAdd +=40
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd	, "PROCED.: "			, oFont10B )
nColAdd +=30
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	, AllTrim(POSICIONE("SYA", 1, xFilial("SYA") + cProced, "YA_SIGLA") ), oFont10N)
nColAdd :=0
//****************************************************************************

oPrint:Box(65,nCol-2,124,nColFim)

nLinAdd +=12   

//*****************************Linha 3 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, nCol 	     	, "FABRICADO POR: "		   	, oFont10B )
nColAdd +=65
oPrint:Say( nLin+nLinAdd	, nCol+nColAdd 	,	cFabric	, oFont10N)
nColAdd +=60
nLinAdd +=10
oPrint:Say( nLin+nLinAdd	, nCol 	, AllTrim(cEndFabr)	, oFont10N)
nColAdd +=60
nLinAdd +=10
oPrint:Say( nLin+nLinAdd	, nCol 	, AllTrim("RESP. TEC.:")	, oFont10B)
nColAdd +=60
oPrint:Say( nLin+nLinAdd	, nCol+40 	, AllTrim(cRespTec)	, oFont10N)

nColAdd :=0
//****************************************************************************

oPrint:Box(129,15,161,nColFim)
nLinAdd +=42

//*****************************Linha 3 Box 1**********************************
oPrint:Say( nLin+nLinAdd	, 17 	, "IMPORTADO POR: "		   	, oFont10B )
oPrint:Say( nLin+nLinAdd	, 17+60	, "MONTEIRO ANTUNES INSUMOS HOSPITALARES LTDA"	, oFont10N)
nLinAdd +=10
oPrint:Say( nLin+nLinAdd	, 17 	, AllTrim('CNPJ: '+cICnpj+", "+cIEnd+", "+cICid+", "+cIBairro+" - "+cIEst)	, oFont10N)
nLinAdd +=10
oPrint:Say( nLin+nLinAdd	, 17 	, AllTrim("RESP. TEC.:")	, oFont10B)
oPrint:Say( nLin+nLinAdd	, 17+60 , AllTrim(cRespTec)	, oFont10N)
nColAdd :=0
//***************************************************************************/*  


oPrint:QRCode(126,12,cQcode , 5) 



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

u_PutSX1(cPerg, "01", "Produto"	    ,"MV_PAR01", "MV_CH0", TamSX3("B8_PRODUTO")[3]    , TamSX3("B8_PRODUTO")[1]    , TamSX3("B8_PRODUTO")[2]    , "G", atuData(), "SB8ETI", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Codigo do Produto")
u_PutSX1(cPerg, "02", "Lote"			,"MV_PAR02", "MV_CH1", TamSX3("B8_LOTECTL")[3]    , TamSX3("B8_LOTECTL")[1]    , TamSX3("B8_LOTECTL")[2]    , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Lote")
u_PutSX1(cPerg, "03", "Validade"		,"MV_PAR03", "MV_CH2", TamSX3("B8_DTVALID")[3]    , TamSX3("B8_DTVALID")[1]	   , TamSX3("B8_DTVALID")[2]    , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Data de balidate")


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
