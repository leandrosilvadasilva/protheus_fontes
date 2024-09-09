#Include "Totvs.ch"
#Include "RptDef.CH"
#Include "FwPrintSetup.ch"
#Include "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMAHETI05    บAutor  ณEdnei Silva      บ Data ณ  18/05/21    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Impressao de Etiquetas de Consignado ou conferencia	      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


#define CRLF Chr(13)+Chr(10)
User Function MAHETI05( cAlias, nReg, nOpc )

Local cPerg			:= PadR("MAHETI05",10)
Local cFilePrint	:= "etiqueta_conferencia_"+ DtoS( dDataBase ) + StrTran(Time(),":","")
Local cPathInServer	:= "\spool\"
Local cSession		:= GetPrinterSession()
Local aDevice		:= {}
Local lOk			:= .F.
Local lExec			:= .F.
Private oPrint  := Nil
Private oSetup  := Nil
Private oFont05N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont10N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont11N:= TFont():New('Arial',,06,.T.,.F.)
Private oFont10B:= TFont():New('Arial',,04,.T.,.F.)
Private oFont12N:= TFont():New('Arial',,08,.T.,.F.)
Private oFont12B:= TFont():New('Arial',,08,.T.,.T.)
Private oFont14N:= TFont():New('Arial',,04,.T.,.F.)
Private oFont16N:= TFont():New('Arial',,16,.T.,.T.)
Private oFont24N:= TFont():New('Arial',,24,.T.,.T.)






Private nLin    	:= 0
Private nLinBar 	:= 0
Private nVolNF      := 1
Private lRefresh := .T.
Private aHeader  := {}
Private aCols 	 := {}
Private aRotina  := {}


oFont10B:Bold := .T.

CriaSX1( cPerg )

If Pergunte(cPerg,.T.)
	
	Private cFilialX    := MV_PAR01
	Private cDoc		:= MV_PAR02
	Private cSerie		:= MV_PAR03
	Private nTipo		:= MV_PAR04  // 01 - OPME; 02 - Conferencia  
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
	
	For nEtq := 1 To aCols[nPrd][13]
		
		IncProc()
		
		nLin 	:= 018
		nCol	:= 012
		nLinBar := 4.11
		nColBar := 2.20
		
		oPrint:StartPage()
		
		R001Imp( aCols[nPrd][1], aCols[nPrd][2], aCols[nPrd][3], aCols[nPrd][4],aCols[nPrd][5],str(aCols[nPrd][6]),str(aCols[nPrd][7]),aCols[nPrd][8],aCols[nPrd][9],aCols[nPrd][10],aCols[nPrd][11],aCols[nPrd][12])
		
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
Local aCampos	:= {"D2_FILIAL","D2_DOC", "D2_SERIE" , "A1_NREDUZ" , "A1_MUN" ,  "F2_VOLUME1" , "F2_PBRUTO", "A4_NREDUZ", "D2_TES",	"D2_EMISSAO", "D2_QUANT","D2_EST"	}
Local aButtons	:= {}
Local bOk		:= {||}
Local bCancel	:= {||}
Local nQtdEtq   := 1


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

cQuery := " SELECT	    "
cQuery += " D2_FILIAL,  "			
cQuery += " D2_EST,     "
cQuery += " D2_DOC,     "
cQuery += " D2_SERIE,	"					
cQuery += " A1_NREDUZ,  "
cQuery += " A1_MUN,     "
cQuery += " F2_VOLUME1, "
cQuery += " F2_PBRUTO,  "
cQuery += " A4_NREDUZ,  "
cQuery += " D2_TES,		"	
cQuery += " SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) D2_EMISSAO,	"		
cQuery += " SUM(D2_QUANT) D2_QUANT "
 
cQuery += " FROM	     "+RetSqlName("SD2") + " SD2 "
            
cQuery += " 			INNER JOIN "+RetSqlName("SF2") + " SF2 ON (SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_FILIAL=SD2.D2_FILIAL) "
cQuery += " 			INNER JOIN "+RetSqlName("SA4") + " SA4 ON (SA4.A4_COD=SF2.F2_TRANSP) "
cQuery += " 			INNER JOIN "+RetSqlName("SA1") + " SA1 ON (SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA) "

cQuery += " WHERE "

cQuery += "            SF2.D_E_L_E_T_<>'*' "
cQuery += " 		   AND SA1.D_E_L_E_T_<>'*' "
cQuery += " 		   AND SD2.D_E_L_E_T_<>'*' "
cQuery += " 		   AND SF2.F2_DOC='" + cDoc + "'"
cQuery += " 		   AND SF2.F2_SERIE='" + cSerie + "'"
cQuery += "            AND SF2.F2_FILIAL='" + cFilialX + "'"
cQuery += " 		   AND SA4.D_E_L_E_T_<>'*'  "

cQuery += " Group By    
cQuery += " D2_FILIAL,  "
cQuery += " D2_EST,  "
cQuery += " D2_DOC,     "
cQuery += " D2_SERIE,   "					
cQuery += " A1_NREDUZ,  "
cQuery += " A1_MUN,     "
cQuery += " F2_VOLUME1, "
cQuery += " F2_PBRUTO,  "
cQuery += " A4_NREDUZ,  "
cQuery += " D2_TES,		"	
cQuery += " D2_EMISSAO  "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T. )
dbSelectArea( cAliasTmp )
( cAliasTmp )->( dbGoTop() )

If ( cAliasTmp )->( !EoF() )
	
	While ( cAliasTmp )->( !EoF() )
			
		
        if nTipo=1
		    nQtdEtq:= Round((cAliasTmp )->D2_QUANT,0)
		else
		    nQtdEtq:= (cAliasTmp )->F2_VOLUME1
		endif

		aAdd( aCols, { ( cAliasTmp )->D2_FILIAL,;
		( cAliasTmp )->D2_DOC,;
		( cAliasTmp )->D2_SERIE,;
		( cAliasTmp )->A1_NREDUZ,;
		( cAliasTmp )->A1_MUN,;
		( cAliasTmp )->F2_VOLUME1,;
		( cAliasTmp )->F2_PBRUTO,;
		( cAliasTmp )->A4_NREDUZ,;
		( cAliasTmp )->D2_TES,;
		( cAliasTmp )->D2_EMISSAO,;
		( cAliasTmp )->D2_QUANT,;
		( cAliasTmp )->D2_EST,;
		nQtdEtq, .F.} )
		
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


Static Function R001Imp(cFilialNF, CNota, cSerieNota, cCliente, cMunicipio,cVolumes,cPeso,cTransporte,cTes,cDtEmissao,cQuantidade,cEst)

//Local nColAdd := 0
Local nLinAdd := 0
nCol 	+= 75
nLin 	+= 0
nLinBar += 0
nColBar += 0


cQcode  :=AllTrim(cNota)  +Char(13) //" Nota" 
cQcode  +=AllTrim(cSerie) +Char(13) //" Serie: "    





oPrint:Box(nLin+28,nCol,110,200)

If (nTipo = 1) .and. (cTES $ "722/697") 

    // - Etiqueta de conferencia OPME
	nLinAdd +=37
	oPrint:Say( nLin+26       , nCol+2  , "CONSIGNADO"	    	                       , oFont12B)
	oPrint:Say( nLin+nLinAdd  , nCol+2  , "NF:"	    	                               , oFont12B)
	oPrint:Say( nLin+nLinAdd  , nCol+20 , AllTrim(cNota)+' - '+AllTrim(cSerieNota)     , oFont12B)
	nLinAdd+=20
	oPrint:Say( nLin+nLinAdd  , nCol+11 , IIF (cTes='722',"PERMANENTE","TEMPORมRIO")   , oFont16N)
	nLinAdd +=28
	oPrint:Say( nLin+nLinAdd  , nCol+2  , "Dt. : "+AllTrim(cDtEmissao)	  			   , oFont11N)

Else
	// - Etiqueta de conferencia
	nLinAdd +=37
	//oPrint:Say( nLin+26       	, nCol     , "CONFERIDO"	    	                         , oFont16N)
	oPrint:Say( nLin+26	, nCol+2	  , "NF:"	    	                                         , oFont16N)
	oPrint:Say( nLin+26	, nCol+22     , AllTrim(cNota)+' - '+AllTrim(cSerieNota)                 , oFont16N)
	oPrint:Say( nLin+nLinAdd , nCol+2 , substr(AllTrim(cCliente),01,23)	                         , oFont12N)
	nLinAdd +=08
    oPrint:Say( nLin+nLinAdd , nCol+2 , substr(AllTrim(cCliente),24,23)	                         , oFont12N)
	nLinAdd +=08
	oPrint:Say( nLin+nLinAdd , nCol+2 , substr(AllTrim(cMunicipio),1,27)+' - '+AllTrim(cEst)+"." , oFont12N)
	nLinAdd +=10
	oPrint:Say( nLin+nLinAdd , nCol+2 , "TRANSP./VOLUMES "			   				             , oFont12B)
	nLinAdd +=10
	oPrint:Say( nLin+nLinAdd , nCol+2 , substr(AllTrim(cTransporte),1,20)				         , oFont12N)
	nLinAdd +=08
	oPrint:Say( nLin+nLinAdd , nCol+2 , "VOL.: "+AllTrim(str(nVolNF))+'/'+AllTrim(cVolumes)	   	 , oFont12N)
	oPrint:Say( nLin+nLinAdd , nCol+42, "PESO NF: "+AllTrim(cPeso)	   				             , oFont12N)
	nLinAdd +=08
	oPrint:Say( nLin+nLinAdd , nCol+2 , "Dt. : "+AllTrim(cDtEmissao)	                         , oFont12N)

Endif
   



//*************QrCode*************
oPrint:QRCode(110,12,cQcode , 73) 
//********************************

oPrint:SayBitmap( nLin+28, nCol+106,"C:\MA.bmp", 07, 65 )

IF nVolNF<val(cVolumes)
   nVolNF:=nVolNF+1
endif
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

u_PutSX1(cPerg, "01", "Filial"	    ,"MV_PAR01", "MV_CH0", TamSX3("D2_FILIAL")[3]    , TamSX3("D2_FILIAL")[1]          , TamSX3("D2_FILIAL")[2]     , "G", cValid, cF3    , cPicture,  cDef01,  cDef02         , cDef03,        cDef04,    cDef05, "Codigo do Produto")
u_PutSX1(cPerg, "02", "NF"			,"MV_PAR02", "MV_CH1", TamSX3("D2_DOC")[3]       , TamSX3("D2_DOC")[1]             , TamSX3("D2_DOC")[2]        , "G", cValid, cF3    , cPicture,  cDef01,  cDef02         , cDef03,        cDef04,    cDef05, "Lote")
u_PutSX1(cPerg, "03", "Serie"		,"MV_PAR03", "MV_CH2", TamSX3("D2_SERIE")[3]     , TamSX3("D2_SERIE")[1]	       , TamSX3("D2_SERIE")[2]      , "G", cValid, cF3    , cPicture,  cDef01,  cDef02         , cDef03,        cDef04,    cDef05, "Serie da Nota")
u_PutSX1(cPerg, "04", "TIpo"        ,"MV_PAR04", "MV_CH3", "N"                       , 01                              , 0                          , "C", cValid, cF3    , cPicture,  "OPME",  "CONFERENCIA"  , cDef03,        cDef04,    cDef05, "Tipo da Etiqueta")

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

