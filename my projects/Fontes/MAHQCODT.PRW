#INCLUDE "PROTHEUS.CH"
#Include "Totvs.ch"
#Include "RptDef.CH"
#Include "FwPrintSetup.ch"
#Include "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMAHETI02    บAutor  ณEdnei Silva      บ Data ณ  10/07/19 	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Impressao de Etiquetas de produtos em terceiros	 		  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



User Function MAHQCODT()

#DEFINE CRLF (Chr(13)+Chr(10))

Local cPerg			:= PadR("MAHQCODT",10)
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
Private oFont24N:= TFont():New('Arial',,24,.T.,.T.)


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
ฑฑบPrograma  ณR001Exec     บAutor  ณEdnei Silva      บ Data ณ  10/07/19   บฑฑ
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
Local nPosEti   := 1 
ProcRegua( Len( aCols ) )

For nPrd := 1 To Len( aCols )
	
	For nEtq := 1 To aCols[nPrd][12]
		
		IncProc()
		
		nLin 	:= 018
		nCol	:= 012
		nLinBar := 4.11
		nColBar := 2.20
		
		DO CASE
	    
	    CASE nPosEti = 1 
			oPrint:StartPage()
		    R001Imp( aCols[nPrd][1], aCols[nPrd][2], aCols[nPrd][3], aCols[nPrd][4],aCols[nPrd][5],aCols[nPrd][6],aCols[nPrd][7],aCols[nPrd][8],aCols[nPrd][9],aCols[nPrd][10],aCols[nPrd][11])
		CASE nPosEti = 2
			R001ImpA( aCols[nPrd][1], aCols[nPrd][2], aCols[nPrd][3], aCols[nPrd][4],aCols[nPrd][5],aCols[nPrd][6],aCols[nPrd][7],aCols[nPrd][8],aCols[nPrd][9],aCols[nPrd][10],aCols[nPrd][11])
		    oPrint:EndPage()
		ENDCASE
		
		
		
	 If nPosEti=1
	    nPosEti:=2
	 else
	    nPosEti:=1
	 endif    
	       
				
	Next nEtq
	
Next nPrd

If nPrd = Len( aCols ) .And. nPosEti=1
	oPrint:EndPage()
Endif


Return( Len( aCols ) > 0 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR001List     บAutor  ณEdnei Silva      บ Data ณ  10/07/19   บฑฑ
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



cQuery := " SELECT SB1.B1_COD  B8_PRODUTO, "
cQuery += " 	   SB1.B1_DESC ,           "
cQuery += "        SD2.D2_ITEM ITEM,       "
cQuery += " 	   SD2.D2_LOTECTL B8_LOTECTL, "
cQuery += " 	   SUBSTRING(SD2.D2_DTVALID,7,2)+'/'+SUBSTRING(SD2.D2_DTVALID,5,2)+'/'+SUBSTRING(SD2.D2_DTVALID,1,4) B8_DTVALID, "
cQuery += "        SUBSTRING(SD2.D2_DFABRIC,7,2)+'/'+SUBSTRING(SD2.D2_DFABRIC,5,2)+'/'+SUBSTRING(SD2.D2_DFABRIC,1,4) B8_DFABRIC, "
cQuery += " 	   D2_FILIAL ,  "
cQuery += " 	   D2_DOC    ,  "
cQuery += " 	   D2_SERIE  ,  "
cQuery += " 	   A1_COD    ,  "
cQuery += " 	   A1_NOME   ,  "
cQuery += " 	   A1_LOJA   ,  "
cQuery += " 	   A3_COD       "
cQuery += " FROM  	   			"+ RetSqlName("SB6") + " SB6 " 
cQuery += " 		INNER JOIN  "+ RetSqlName("SD2") + " SD2 ON (SD2.D2_FILIAL=SB6.B6_FILIAL AND SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_COD=SB6.B6_PRODUTO AND  SD2.D_E_L_E_T_<>'*') " 
cQuery += " 		INNER JOIN  "+ RetSqlName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*')  " 
cQuery += " 		INNER JOIN  "+ RetSqlName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*')   "
cQuery += " 		INNER JOIN  "+ RetSqlName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')  "  
cQuery += " 	  		  JOIN  "+ RetSqlName("SB1") + " SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*')     "
cQuery += " 	  	      JOIN  "+ RetSqlName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*')  "
cQuery += " WHERE       SB6.B6_DOC 		 >= '" + Alltrim(MV_PAR03) + "'"
cQuery += " 		AND SB6.B6_DOC 		 <= '" + Alltrim(MV_PAR04) + "'"
cQuery += " 		AND SB6.B6_SERIE   	 >= '" + Alltrim(MV_PAR05) + "'"
cQuery += " 		AND SB6.B6_SERIE   	 <= '" + Alltrim(MV_PAR06) + "'"
cQuery += " 		AND SB6.B6_EMISSAO 	 >= '20150101' "
cQuery += " 		AND SB6.B6_EMISSAO 	 <= '" + DTOS(dDataBase)   + "'"
cQuery += " 		AND SB6.B6_PRODUTO 	 >= '" + Alltrim(MV_PAR01) + "'"
cQuery += " 		AND SB6.B6_PRODUTO 	 <= '" + Alltrim(MV_PAR02) + "'"
cQuery += " 		AND SB6.B6_SALDO>0 "
cQuery += " 		AND SA1.A1_COD		  >='" + Alltrim(MV_PAR07) + "'"
cQuery += " 		AND SA1.A1_COD		  <='" + Alltrim(MV_PAR08) + "'"
cQuery += " 		AND SA1.A1_LOJA		  >='" + Alltrim(MV_PAR09) + "'"
cQuery += " 		AND SA1.A1_LOJA		  <='" + Alltrim(MV_PAR10) + "'"    
cQuery += " 		AND SA3.A3_COD        >='" + Alltrim(MV_PAR11) + "'"
cQuery += " 		AND SA3.A3_COD  	  <='" + Alltrim(MV_PAR12) + "'"
cQuery += " 		AND B6_TPCF			  = 'C' " 
cQuery += " 		AND SB6.B6_TIPO		  = 'E' " 
cQuery += " 		AND SB6.D_E_L_E_T_	 <> '*' "
cQuery += " 		AND SB1.B1_TIPO='M1' "
cQuery += " 		AND F4_CODIGO IN ('508','608','683','542','642','664','699','512','512','611','612','675','659','669') "
cQuery += "         AND B6_IDENT NOT IN('145959','145960','145961','145962','145963','145964','145965','145966','145967','145968','145969','145970','145971','145972', "
cQuery += "         								 '151272','294963','294964','296555','315049','321881','327462','327463','327464','327465','301562','145959','145960', "
cQuery += "                                          '145961','145962','145963','145964','145965','145966','145967','145968','145969','145970','145971','145972','151272', "
cQuery += "                                          '294963','294964','296555','315049','321881','327462','327463','327464','327465','301562') "
cQuery += "         Group By SB1.B1_COD,    "
cQuery += "               SB1.B1_DESC,      "
cQuery += "               SD2.D2_ITEM,      "
cQuery += "         	  SD2.D2_LOTECTL,   "
cQuery += "         	  D2_DTVALID,       "
cQuery += "               D2_DFABRIC,       "
cQuery += "         	  D2_FILIAL,        "
cQuery += "         	  D2_DOC,           "
cQuery += "         	  D2_SERIE,         "
cQuery += "         	  A1_COD,           "
cQuery += "         	  A1_NOME,          "
cQuery += "         	  A1_LOJA,          "
cQuery += "         	  A3_COD            "




MEMOWRITE ("MAHQCODT.SQL", cQuery)
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
		"",;
		"",;
		"",;
		"",;
		( cAliasTmp )->B8_DFABRIC,;
		"",1, .F.} )
		
		
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
ฑฑบPrograma  ณR001TdOk     บAutor  ณEdnei Silva      บ Data ณ  10/07/19   บฑฑ
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
ฑฑบPrograma  ณR001Imp      บAutor  ณEdnei Silva      บ Data ณ  10/07/19   บฑฑ
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
Local nColNac := 0
Local nLinNac := 0
Local nColAdd2:= 0
Local nLinAdd2:= 0
Local nColFim2:= 285
Local nColNac2:= 0
Local nLinNac2:= 0
Local aSM0    := FWLoadSM0()
Local nPosSM0 :=1
Local cQcode  :=''
Local cQtdPro :=''
Private oQrCode

 
nCol 	+= 122
nLin 	+= 0
nLinBar += 0
nColBar += 0
nColNac += 10
nLinNac += 20

cQtdPro :=''                                           

IF AllTrim(cCodProd) $ '352/5855;351/5878;350/5422;355/5427;353/19004;331/5661;331/5389;355/5814;352/5877'
   cQtdPro :='25'
Else
   cQtdPro :='1'
Endif   


cQcode  :=AllTrim(cCodProd) +CRLF   //" COD. PRODUTO: " 
cQcode  +=AllTrim(cDFabric) +CRLF   //" DT. FAB.: 	 "    
cQcode  +=AllTrim(cDtValid) +CRLF   //" VALIDADE: 	 "    
cQcode  +=AllTrim(cLoteProd)+CRLF  //" LOTE: 		 "
cQcode  +=AllTrim(cQtdPro)	+CRLF   //" Quantidade:   "		  		  

//oPrint:Box(13,15,29,nColFim)
// Inf. Produto
nLinAdd +=0
oPrint:Say( nLinNac+nLin+nLinAdd+10	, nColNac+17    	, "MA"					, oFont24N )
nLinAdd +=0
//oPrint:Say( nLin+nLinAdd+2	, 17+33	    , "COD.: "				, oFont11N)
oPrint:Say( nLinNac+nLin+nLinAdd+9	, nColNac+17+30 	, AllTrim("Cod.:"+cCodProd)		, oFont11N)
nLinAdd+=07
//oPrint:Say( nLin+nLinAdd	, nCol 	    , "DESC.: "		   	, oFont11N)
oPrint:Say( nLinNac+nLin+nLinAdd+9	, nColNac+18    	, AllTrim(cAbreNom(cDescProd))	, oFont10N)
//oPrint:Box(35,nCol-2,124,nColFim)
nLinAdd +=17

//**********************************Linha 1 Box 1****************************************
oPrint:Say( nLinNac+nLin+120	, nColNac+18	, AllTrim("Dt. Valid.:"+cDtValid)+"  Qtd.: "+cQtdPro, oFont10N)
oPrint:Say( nLinNac+nLin+126	, nColNac+18	, AllTrim("Lote/Serie:"+cLoteProd)   	            , oFont10N)
//***************************************************************************************

//*************QrCode*************
oPrint:QRCode(nLinNac+132,nColNac+16,cQcode , 5) 
//********************************


Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR001Imp      บAutor  ณEdnei Silva      บ Data ณ  10/07/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Imprime as informacoes a serem impressas na etiqueta      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function R001ImpA( cCodProd, cDescProd, cLoteProd, cCodBar,cDtValid,cNrAnvi,cProced,cDFabric,cRespTec,cFabric,cEndFabr)
Local nColAdd := 0
Local nLinAdd := 0
Local nColFim := 285
Local nColNac := 0
Local nLinNac := 0
Local nColAdd2:= 0
Local nLinAdd2:= 0
Local nColFim2:= 285
Local nColNac2:= 0
Local nLinNac2:= 0
Local aSM0    := FWLoadSM0()
Local nPosSM0 :=1
Local cQcode  :=''
Local cQtdPro :=''
Private oQrCode

 
nCol 	+= 122
nLin 	+= 0
nLinBar += 0
nColBar += 0
nColNac += 10
nLinNac += 20

cQtdPro :=''                                           

IF AllTrim(cCodProd) $ '352/5855;351/5878;350/5422;355/5427;353/19004;331/5661;331/5389;355/5814;352/5877'
   cQtdPro :='25'
Else
   cQtdPro :='1'
Endif   

nColAdd2 := 0
nLinAdd2 := 0

nLinBar2 := 0
nColBar2 := 0
nColNac2 := 0
nLinNac2 := 0


nLinBar2 += 0
nColBar2 += 0
nColNac2 += 164
nLinNac2 += 20

cQtdPro :=''                                           

IF AllTrim(cCodProd) $ '352/5855;351/5878;350/5422;355/5427;353/19004;331/5661;331/5389;355/5814;352/5877'
   cQtdPro :='25'
Else
   cQtdPro :='1'
Endif   
      


cQcode  :=AllTrim(cCodProd) +CRLF   //" COD. PRODUTO: " 
cQcode  +=AllTrim(cDFabric) +CRLF   //" DT. FAB.: 	  "    
cQcode  +=AllTrim(cDtValid) +CRLF   //" VALIDADE: 	  "    
cQcode  +=AllTrim(cLoteProd)+CRLF   //" LOTE: 		  "
cQcode  +=AllTrim(cQtdPro)	+CRLF   //" Quantidade:   "		  

//oPrint:Box(13,15,29,nColFim)
// Inf. Produto
nLinAdd2 +=0
oPrint:Say( nLinNac2+nLin+nLinAdd2+10	, nColNac2+17    	, "MA"					, oFont24N )
nLinAdd2 +=0
//oPrint:Say( nLin+nLinAdd+2	, 17+33	    , "COD.: "				, oFont11N)
oPrint:Say( nLinNac2+nLin+nLinAdd2+9	, nColNac2+17+30 	, AllTrim("Cod.:"+cCodProd)		, oFont11N)
nLinAdd2+=07
//oPrint:Say( nLin+nLinAdd	, nCol 	    , "DESC.: "		   	, oFont11N)
oPrint:Say( nLinNac2+nLin+nLinAdd2+9	, nColNac2+18    	, AllTrim(cAbreNom(cDescProd))	, oFont10N)
//oPrint:Box(35,nCol-2,124,nColFim)
nLinAdd2 +=17

//**********************************Linha 1 Box 1****************************************
oPrint:Say( nLinNac2+nLin+120	, nColNac2+18	, AllTrim("Dt. Valid.:"+cDtValid)+"  Qtd.: "+cQtdPro, oFont10N)
oPrint:Say( nLinNac2+nLin+126	, nColNac2+18	, AllTrim("Lote/Serie:"+cLoteProd)   				, oFont10N)
//***************************************************************************************

//*************QrCode*************
oPrint:QRCode(nLinNac2+132,nColNac2+16,cQcode , 5) 
//********************************




Return





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaSx       บAutor  ณEdnei Silva      บ Data ณ  10/07/19   บฑฑ
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

u_PutSX1(cPerg, "01", "Produto de "    ,"MV_PAR01", "MV_CH1", TamSX3("B8_PRODUTO")[3]    , TamSX3("B8_PRODUTO")[1]    , TamSX3("B8_PRODUTO")[2]    , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Codigo do Produto de")
u_PutSX1(cPerg, "02", "Produto Ate"	,"MV_PAR02", "MV_CH2", TamSX3("B8_PRODUTO")[3]    , TamSX3("B8_PRODUTO")[1]    , TamSX3("B8_PRODUTO")[2]    , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Codigo do Produto Ate")

u_PutSX1(cPerg, "03", "Doc. de "       ,"MV_PAR03", "MV_CH3", TamSX3("D2_DOC")[3]        , TamSX3("D2_DOC")[1]        , TamSX3("D2_DOC")[2]        , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Documento de")
u_PutSX1(cPerg, "04", "Doc. Ate"	    ,"MV_PAR04", "MV_CH4", TamSX3("D2_DOC")[3]        , TamSX3("D2_DOC")[1]        , TamSX3("D2_DOC")[2]        , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Documento Ate")

u_PutSX1(cPerg, "05", "Serie de "      ,"MV_PAR05", "MV_CH5", TamSX3("D2_SERIE")[3]      , TamSX3("D2_SERIE")[1]      , TamSX3("D2_SERIE")[2]      , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Serie de")
u_PutSX1(cPerg, "06", "Serie Ate"	    ,"MV_PAR06", "MV_CH6", TamSX3("D2_SERIE")[3]      , TamSX3("D2_SERIE")[1]      , TamSX3("D2_SERIE")[2]      , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Serie Ate")


u_PutSX1(cPerg, "07", "Cliente de "    ,"MV_PAR07", "MV_CH7", TamSX3("A1_COD")[3]    	  , TamSX3("A1_COD")[1]        , TamSX3("A1_COD")[2]        , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Cliente de")
u_PutSX1(cPerg, "08", "Cliente Ate"	,"MV_PAR08", "MV_CH8", TamSX3("B8_PRODUTO")[3]    , TamSX3("A1_COD")[1]        , TamSX3("A1_COD")[2]        , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Cliente Ate")


u_PutSX1(cPerg, "09", "Loja de "       ,"MV_PAR08", "MV_CH9", TamSX3("A1_LOJA")[3]    	  , TamSX3("A1_LOJA")[1]       , TamSX3("A1_LOJA")[2]       , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,   cDef05,  "Loja de")
u_PutSX1(cPerg, "10", "Loja Ate"	    ,"MV_PAR10", "MV_CHA", TamSX3("A1_LOJA")[3]       , TamSX3("A1_LOJA")[1]       , TamSX3("A1_LOJA")[2]       , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,   cDef05,  "Loja Ate")

u_PutSX1(cPerg, "11", "Vendedor de "   ,"MV_PAR11", "MV_CHB", TamSX3("A3_COD")[3]    	  , TamSX3("A3_COD")[1]        , TamSX3("A3_COD")[2]        , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Vendedor de")
u_PutSX1(cPerg, "12", "Vendedor Ate"	,"MV_PAR12", "MV_CHC", TamSX3("A3_COD")[3]        , TamSX3("A3_COD")[1]        , TamSX3("A3_COD")[2]        , "G", "", "", cPicture,      cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Vendedor Ate")


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
  cAbrevia:=substr(cAbrevia,1,30)
Return cAbrevia
