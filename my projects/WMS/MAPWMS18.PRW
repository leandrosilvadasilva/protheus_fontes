
#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

 /*

{
	"importacao": [
    {
        "codigo_fornecedor": "0036890003",
        "codigo_produto": "CV-PC1161000        ",
        "filial": "0101",
        "importacao": true,
        "item_documento": "0001",
        "lote": "TESTEAKR1",
        "lote_importacao": "AUTO009495",
        "numero_documento": "000046279",
        "quantidade": 6.0,
        "serie_documento": "1"
    },
    {
        "codigo_fornecedor": "0036890003",
        "codigo_produto": "CV-PC1161000        ",
        "filial": "0101",
        "importacao": true,
        "item_documento": "0001",
        "lote": "TESTEAKR2",
        "lote_importacao": "AUTO009495",
        "numero_documento": "000046279",
        "quantidade": 3.0,
        "serie_documento": "1"
    }
]
}

*/
Class DocImport

	Data filial 			As Character
	Data fornecedor			As Character 
	Data loja   			As Character 
	Data produto			As Character
	Data item   			As Character
	Data loteImport			As Character
	Data lote           	As Character
	Data documento      	As Character
	Data serie      		As Character
	Data quantidade			As Numeric
	
    Data aParam				As Array 

	Data cCode 				As Character 
	Data cMessage 			As Character 

	Method New() CONSTRUCTOR
	Method Movimentar()
	
EndClass 

/*
---------------------------------------------------------------------
Metodo  	: New
Objetivo	: Inicializa as propriedades com base no JSON
----------------------------------------------------------------------
*/
Method New( oBody ) Class DocImport

Local aDocumentos	:= Nil 
Local nI 	    	:= 1

	Self:aParam := {}
	aDocumentos	:= oBody['importacao']

	For nI := 1 To Len( aDocumentos )

		IF nI == 1
		    // IATAN EM 31/07/2022 - LOG PARA GUARDAR OS JSONS RECEBIDOS
			FwMakeDir("\integracao_wms\importacao\")
			MEMOWRITE("\integracao_wms\importacao\"+ GetJsonCpo( aDocumentos[nI],"filial") + GetJsonCpo( aDocumentos[nI],	"numero_documento") + "__" + Year2Str(ddatabase) + Month2Str(DDATABASE) + Day2Str(DDATABASE) + '_' + REPLACE(TIME(), ':', '.') + ".json", oBody:GetJsonText("importacao") )
		ENDIF

		Self:filial			:= PadR( GetJsonCpo( aDocumentos[nI],	"filial")	          , TamSx3("D1_FILIAL")[1] ) 
		Self:fornecedor 	:= PadR( GetJsonCpo( aDocumentos[nI],	"codigo_fornecedor")  , TamSx3("D1_FORNECE")[1] )
		Self:loja			:= SUBSTRING( GetJsonCpo(aDocumentos[nI],"codigo_fornecedor"), TamSx3("D1_FORNECE")[1]+1, TamSx3("D1_LOJA")[1]) 
		Self:produto 		:= PadR( GetJsonCpo( aDocumentos[nI],	"codigo_produto")	  , TamSx3("D1_COD")[1] )
		Self:item			:= PadR( GetJsonCpo( aDocumentos[nI],	"item_documento")	  , TamSx3("D1_ITEM")[1] )
		Self:loteImport	    := PadR( GetJsonCpo( aDocumentos[nI],	"lote_importacao")	  , TamSx3("D1_LOTECTL")[1] )
		Self:lote	        := PadR( GetJsonCpo( aDocumentos[nI],	"lote")		          , TamSx3("D1_LOTECTL")[1] )
		Self:documento	    := PadR( GetJsonCpo( aDocumentos[nI],	"numero_documento")   , TamSx3("D1_DOC")[1] )
		Self:serie	        := PadR( GetJsonCpo( aDocumentos[nI],	"serie_documento")		, TamSx3("D1_SERIE")[1] )
		Self:quantidade		:= GetJsonCpo( aDocumentos[nI],	"quantidade")

		aAdd( Self:aParam, {Self:filial,Self:fornecedor,Self:loja,Self:produto,Self:item,Self:loteImport, Self:lote, Self:documento, Self:serie, Self:quantidade} )
	Next

Return( Self )


Method Movimentar() Class DocImport

Local cMessage	:= ""
Local lRet 		:= .T. 

	If U_MAPWMS18( Self:aParam, @cMessage ) 
		Self:cCode := "200"
		lRet := .T. 
	Else
		Self:cCode := "400"
		lRet := .F.
	EndIf 
	
	Self:cMessage := cMessage
	
Return( lRet )

User Function MAPWMS18( aLista, cMessage )

Local nX            := 0
Local nOpcAuto      := 0
Local cDocumen      := ""

Local aAuto := {}
Local aItem := {}
Local aLinha := {}

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

Default cMessage    := ""


    //Cabecalho a Incluir
    cDocumen := GetSxeNum("SD3","D3_DOC")
    cDocumen := nextnumero ("SD3", 2, "D3_DOC", .T.)
    aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho
    //Itens a Incluir
    aItem := {}

	For nX := 1 To Len(aLista)

        // POSICIONANDO NA SB1 E SD1
        POSICIONE("SB1", 1, xFilial("SB1")+aLista[nX][4], "B1_DESC")
        POSICIONE("SD1", 1, xFilial("SD1")+aLista[nX][8]+aLista[nX][9]+aLista[nX][2]+aLista[nX][3]+aLista[nX][4]+aLista[nX][5], "D1_DOC")
        IF SB1->B1_COD <> aLista[nX][4]
            cMessage := "NAO CONSEGUIU ENCONTRAR O PRODUTO - ERRO POSICIONAMENTO SB1"
            RETURN .F.
        ENDIF
        IF SD1->D1_DOC <> aLista[nX][8]
            cMessage := "NAO CONSEGUIU ENCONTRAR O DCTO DE ENTRADA - ERRO POSICIONAMENTO SD1"
            RETURN .F.
        ENDIF
        IF SD1->D1_LOTECTL <> aLista[nX][6]
            cMessage := "LOTE DE ORIGEM INFORMADO NO JSON DIFERENTE DO LOTE DE ORIGEM NO DCTO DE ENTRADA"
            RETURN .F.
        ENDIF

        aLinha := {} 
/*
        //Origem
        //aadd(aLinha,{"ITEM",'00'+cvaltochar(nX),Nil})
        aadd(aLinha,{"D3_COD",     SB1->B1_COD, Nil}) //Cod Produto origem
        aadd(aLinha,{"D3_DESCRI",  SB1->B1_DESC, Nil}) //descr produto origem
        aadd(aLinha,{"D3_UM",      SB1->B1_UM, Nil}) //unidade medida origem
        aadd(aLinha,{"D3_LOCAL",   SB1->B1_LOCPAD, Nil}) //armazem origem
        //aadd(aLinha,{"D3_LOCALIZ", PadR("ENDER01", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço origem        

    //Destino
        aadd(aLinha,{"D3_COD",     SB1->B1_COD, Nil}) //cod produto destino
        aadd(aLinha,{"D3_DESCRI",  SB1->B1_DESC, Nil}) //descr produto destino
        aadd(aLinha,{"D3_UM",      SB1->B1_UM, Nil}) //unidade medida destino
        aadd(aLinha,{"D3_LOCAL",   SB1->B1_LOCPAD, Nil}) //armazem destino
        //aadd(aLinha,{"D3_LOCALIZ", PadR("ENDER02", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço destino
        
//        aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
        aadd(aLinha,{"D3_LOTECTL", aLista[nX][6], Nil}) //Lote Origem
//        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
        aadd(aLinha,{"D3_DTVALID", SD1->D1_DTVALID, Nil}) //data validade
//        aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
        aadd(aLinha,{"D3_QUANT",   aLista[nX][10], Nil}) //Quantidade
//        aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
//        aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
//        aadd(aLinha,{"D3_NUMSEQ",  "", Nil}) // Numero sequencia D3_NUMSEQ
        
        aadd(aLinha,{"D3_LOTECTL", aLista[nX][7], Nil}) //Lote destino
//        aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
        aadd(aLinha,{"D3_DTVALID", SD1->D1_DTVALID, Nil}) //validade lote destino
//        aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade
        
//        aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
//        aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino
*/        

	aLinha := { {"D3_FILIAL",  CFILANT, Nil},;
				{"D3_COD",     SB1->B1_COD, Nil},;
	 			{"D3_DESCRI",  SB1->B1_DESC, Nil},;
	 			{"D3_UM",      SB1->B1_UM, Nil},;
	 			{"D3_LOCAL",   SB1->B1_LOCPAD, Nil},;
	 			{"D3_LOCALIZ", PadR(" ", tamsx3('D3_LOCALIZ') [1]),Nil},;
	 			{"D3_COD",     SB1->B1_COD, Nil},;
	 			{"D3_DESCRI",  SB1->B1_DESC, Nil},;
	 			{"D3_UM",      SB1->B1_UM, Nil},;
	 			{"D3_LOCAL",   SB1->B1_LOCPAD, Nil},;
	 			{"D3_LOCALIZ", PadR(" ", tamsx3('D3_LOCALIZ') [1]),Nil},;
	 			{"D3_NUMSERI", "", Nil},;
	 			{"D3_LOTECTL", SD1->D1_LOTECTL, Nil},;
	 			{"D3_NUMLOTE", "", Nil},;
	 			{"D3_DTVALID", SD1->D1_DTVALID, Nil},;
	 			{"D3_POTENCI", 0, Nil},;
	 			{"D3_QUANT",   aLista[nX][10], Nil},;
	 			{"D3_QTSEGUM", 0, Nil},;
	 			{"D3_ESTORNO", "", Nil},;
	 			{"D3_NUMSEQ", "", Nil},;
	 			{"D3_LOTECTL", aLista[nX][7], Nil},;
	 			{"D3_DTVALID", SD1->D1_DTVALID, Nil},;
	 			{"D3_SERVIC", "", Nil},;
	 			{"D3_ITEMGRD", "", Nil}}


        aAdd(aAuto,aLinha)
    
    Next 

    nOpcAuto := 3 // Inclusao
    PUTMV("MV_ESTNEG","S")
    MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
    PUTMV("MV_ESTNEG","N")

    IF lMsErroAuto
        PUTMV("MV_ESTNEG","N")
        aLogErr := GetAutoGRLog()
        IF "MA240NEGAT" $ aLogErr[1]
            cMessage := 'N�O EXISTE SALDO SUFICIENTE NO LOTE [SB8] - ' + ALLTRIM(aLogErr[1])
        ELSE
            cMessage := 'ERROR AO MOVIMENTAR IMPORTACAO [MATA261] - ' + ALLTRIM(aLogErr[1]) 
        ENDIF

        FwMakeDir("integracao_wms\importacao\erro\")
        MEMOWRITE("integracao_wms\importacao\erro\"+ NomeAutoLog() + ".log", ALLTRIM(cMessage) )
        RETURN .F.
    ELSE

    ENDIF


Return( .T. )


Static Function GetJsonCpo(oObj,cTag)
Local xRet
Local xValue
Local cType

If cTag == "quantidade"
	If oObj:GetJsonValue(cTag, @xValue, @cType)
		xRet := xValue
	Else 
		xRet :=  0
	EndIf 
Else 
	If oObj:GetJsonValue(cTag, @xValue, @cType) .And. !Empty(xValue) 
		xRet := DecodeUTF8(xValue)
	Else	
		xRet := " "
	EndIf
EndIf 

Return( xRet )


/*------------------------------------------------------------------
	FUNCAO PARA FORMATAR O RETORNO DO EXECAUTO - ERROR LOG
------------------------------------------------------------------*/ 
Static Function TrataErro( aErr )

Local lHelp   := .F.
Local lTabela := .F.
Local cLinha  := ""
Local aRet    := {}
Local nI      := 0

	For nI := 1 to LEN( aErr)
		cLinha  := UPPER( aErr[nI] )
		cLinha  := STRTRAN( cLinha,CHR(13), " " )
		cLinha  := STRTRAN( cLinha,CHR(10), " " )

		If SUBS( cLinha, 1, 4 ) $ 'HELP;AJUD'
			lHelp := .T.
		EndIf

		If SUBS( cLinha, 1, 6 ) == 'TABELA'
			lHelp   := .F.
			lTabela := .T.
		EndIf

		If  lHelp .or. ( lTabela .AND. '< -- INVALIDO' $  cLinha )
			aAdd( aRet,  cLinha )
		EndIf
	Next

	If Empty(aRet)
		aAdd( aRet,  "Indeterminado - " + Procname() )
	EndIf
Return( aRet )
