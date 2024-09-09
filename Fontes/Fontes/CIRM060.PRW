#Include "Totvs.ch"

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | CIRM060 | Autor | CI Result              | Data |03/09/2019|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Conferencia na Separacao do Pedido de Venda                |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|||  Uso      |                                                            |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function CIRM060()

Local aArea        := GetArea()
Local aAreaSX3     := SX3->(GetArea())
Local aAreaSC5     := SC5->( GetArea())
Local aAreaSC6     := SC6->( GetArea())
Local aAreaSB1     := SB1->( GetArea())
Local oDlg         := Nil
Local oSize        := Nil
Local aDimTop      := {}	// Array de dimensoes do topo
Local aDimTop2     := {}	// Array de dimensoes do topo
Local aDimMid      := {}	// Array de dimensoes do meio
Local cCadastro    := OemToAnsi("Conferência na Separação do Pedido de Venda")
Local oGrpTop      := Nil	// Grupo do Topo
Local oGrpTop2     := Nil	// Grupo do Topo 2
Local oGrpMid      := Nil	// Grupo do Meio
Local oLabel       := TFont():New("Arial",,12,.T.,.T.)
Local oTexto       := TFont():New("Arial",,38,.T.,.T.)
Local bBtOk        := {||}
Local bBtGravar    := {||}
Local bBtCanc      := {||}
Local oBtGravar    := Nil
Local oBtCanc      := Nil
Local cMsgExit     := "Esta ação ira cancelar a leitura de todos os itens." + CRLF + "Deseja prosseguir?"
Local aButtons     := { "Sim", "Não" }
Local cDelOk       := "U_M060DelIC()"


Private aHeadCon   := {}
Private aColsCon   := {}
Private aHeadSC9   := {}
Private aColsSC9   := {}
Private n          := 1
Private oLeitura   := Nil
Private cLeitura   := Space(TamSx3("C9_PRODUTO")[1]) + Space(TamSx3("C9_LOTECTL")[1]) + Space(TamSx3("C9_DTVALID")[1]) + Space(TamSx3("C9_QTDLIB")[1])
Private oLPedido   := Nil
Private cLPedido   := Space(TamSx3("C9_FILIAL")[1]) + Space(TamSx3("C9_PEDIDO")[1])
Private oPedido    := Nil
Private cPedido    := Space(TamSx3("C9_PEDIDO")[1])
Private oCliente   := Nil
Private cCliente   := Space(TamSx3("A1_COD")[1]) + Space(1) + Space(TamSx3("A1_LOJA")[1]) + Space(1) + Space(TamSx3("A1_NOME")[1])
Private oVendedor  := Nil
Private cVendedor  := Space(TamSx3("A3_COD")[1]) + Space(1) + Space(TamSx3("A3_NOME")[1])
Private oFilPed    := Nil
Private cFilPed	   := Space(TamSx3("C9_FILIAL")[1])
Private oEmissao   := Nil
Private dEmissao   := CToD('  /  /  ')
Private oGLote := Nil
Private oGPedido:= Nil
Private lContinua  := .t.

//|===========================================|
//| Calculo de dimensionamento da tela        |
//|===========================================|
oSize := FwDefSize():New(.f.)
oSize:AddObject( "TOP"		,100, 45, .T., .T. ) // 45% do topo da tela
oSize:AddObject( "MIDDLE"	,100, 55, .T., .T. ) // 55% do meio da tela
oSize:lProp := .T.
oSize:Process()

// Dimensoes das areas da tela
aAdd( aDimTop, oSize:GetDimension("TOP","LININI") ) // Ajuste necessario para ocupar a area da enchoice
aAdd( aDimTop, oSize:GetDimension("TOP","COLINI") )
aAdd( aDimTop, oSize:GetDimension("TOP","LINEND") )
aAdd( aDimTop, oSize:GetDimension("TOP","COLEND") * 0.50 ) // 0.50 = só até a metade da tela

aAdd( aDimTop2, oSize:GetDimension("TOP","LININI") ) // Ajuste necessario para ocupar a area da enchoice
aAdd( aDimTop2, oSize:GetDimension("TOP","COLEND") * 0.50 ) // 0.50 = só até a metade da tela
aAdd( aDimTop2, oSize:GetDimension("TOP","LINEND")- 070 )
aAdd( aDimTop2, oSize:GetDimension("TOP","COLEND") )

aAdd( aDimMid, oSize:GetDimension("MIDDLE","LININI") )
aAdd( aDimMid, oSize:GetDimension("MIDDLE","COLINI") )
aAdd( aDimMid, oSize:GetDimension("MIDDLE","LINEND") )
aAdd( aDimMid, oSize:GetDimension("MIDDLE","COLEND") )

// Dimensoes da tela
nTop 	:= oSize:aWindSize[1]
nLeft 	:= oSize:aWindSize[2]
nBottom	:= oSize:aWindSize[3]
nRight	:= oSize:aWindSize[4]

//|===========================================|
//| Montagem do aHeader/Acols Pedido          |
//|===========================================|
aAdd ( aHeadCon, {"Produto"      	, "C9_PRODUTO" 	, ""   , TamSX3("C9_PRODUTO")[1] 	, TamSX3("C9_PRODUTO")[2] , ".F.", "", TamSX3("C9_PRODUTO")[3]	, ""       }  )
aAdd ( aHeadCon, {"Qtde"      	  	, "C9_QTDLIB"  	, ""   , TamSX3("C9_QTDLIB")[1] 	, TamSX3("C9_QTDLIB")[2] , ".F.", "", TamSX3("C9_QTDLIB")[3]	, ""       }  )
aAdd ( aHeadCon, {"Lote"        	, "C9_LOTECTL"  , ""   , TamSX3("C9_LOTECTL")[1] 	, TamSX3("C9_LOTECTL")[2] , ".F.", "", TamSX3("C9_LOTECTL")[3]	, ""       }  )
aAdd ( aHeadCon, {"Endereco"      	, "C9_NUMLOTE"  , ""   , TamSX3("C9_NUMLOTE")[1] 	, TamSX3("C9_NUMLOTE")[2] , ".F.", "", TamSX3("C9_NUMLOTE")[3]	, ""       }  )
aAdd ( aHeadCon, {"Num de Serie"  	, "C9_NUMSERI"  , ""   , TamSX3("C9_NUMSERI")[1] 	, TamSX3("C9_NUMSERI")[2] , ".F.", "", TamSX3("C9_NUMSERI")[3]	, ""       }  )
aAdd ( aHeadCon, {"Validade"      	, "C9_DTVALID"  , ""   , TamSX3("C9_DTVALID")[1] 	, TamSX3("C9_DTVALID")[2] , ".F.", "", TamSX3("C9_DTVALID")[3]	, ""       }  )
aAdd ( aHeadCon, {"Endereco"      	, "C6_LOCALIZ"  , ""   , TamSX3("C6_LOCALIZ")[1] 	, TamSX3("C6_LOCALIZ")[2] , ".F.", "", TamSX3("C6_LOCALIZ")[3]	, ""       }  )
aAdd ( aHeadCon, {"Potencia"      	, "C9_POTENCI"  , ""   , TamSX3("C9_POTENCI")[1] 	, TamSX3("C9_POTENCI")[2] , ".F.", "", TamSX3("C9_POTENCI")[3]	, ""       }  )
aAdd ( aHeadCon, {"Descricao"      	, "B1_DESC"  	, ""   , TamSX3("B1_DESC")[1] 		, TamSX3("B1_DESC")[2] 	  , ".F.", "", TamSX3("B1_DESC")[3]		, ""       }  )

//|===========================================|
//| Montagem do aHeader/Acols - Itens         |
//|===========================================|
aAdd ( aHeadSC9, {"Item"        	, "C9_ITEM"    , ""   , TamSX3("C9_ITEM" )[1] 	, TamSX3("C9_ITEM" )[2]  , ".F.", "", TamSX3("C9_ITEM" )[3]	    , ""       }  )
aAdd ( aHeadSC9, {"Produto" 	   	, "C9_PRODUTO" , ""   , TamSX3("C9_PRODUTO" )[1], TamSX3("C9_PRODUTO")[2], ".F.", "", TamSX3("C9_PRODUTO" )[3]	, ""       }  )
aAdd ( aHeadSC9, {"Descrição"     	, "B1_DESC"    , ""   , TamSX3("B1_DESC")[1] 	, TamSX3("B1_DESC")[2]	 , ".F.", "", TamSX3("B1_DESC")[3]		, ""       }  )
aAdd ( aHeadSC9, {"Qtd Liberada"   	, "C9_QTDLIB"  , ""   , TamSX3("C9_QTDLIB")[1] 	, TamSX3("C9_QTDLIB")[2] , ".F.", "", TamSX3("C9_QTDLIB")[3]	, ""       }  )
aAdd ( aHeadSC9, {"Qtd Separada"   	, "C9_QTDLIB"  , ""   , TamSX3("C9_QTDLIB")[1] 	, TamSX3("C9_QTDLIB")[2] , ".F.", "", TamSX3("C9_QTDLIB")[3]	, ""       }  )
aAdd ( aHeadSC9, {"RecnoSC9"   		, "RECNO"  	   , ""   , 					  40,                       0, ".F.", "", 						  "", ""       }  )

While lContinua
	
	//|===========================================|
	//| Configuracao da tela                      |
	//|===========================================|
	oDlg := MSDialog():New(nTop,nLeft,nBottom,nRight,cCadastro,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	
	//>----- INICIO TOPO -----<
	oGrpTop	 := TGroup():New( aDimTop[1],aDimTop[2],aDimTop[3],aDimTop[4],"",oDlg,,,.T. )
	
	bBtOk1	  := {|| ValPedido() }
	
	oLPedido := TGet():New( 008,008,{|u| IIf( PCount()>0, cLPedido := u, cLPedido ) },;
	oDlg,150,022,"@!", {|| If(!Empty(cLPedido),Eval(bBtOk1),Nil) },;
	0,,oTexto,.F.,,.T.,,.F.,,.F.,.F.,{||},.F.,.F.,,cLPedido,,,,,,,"QR Pedido",1,oLabel,CLR_BLUE,"", )
	
	oTBitmap1 := TBitmap():New(15,165,035,032,,'\system\IMAGQR.BMP',.T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oTBitmap1:lStretch:= .T.
	
	oTBitmap2 := TBitmap():New(97,275,035,032,,'\system\IMAGQR.BMP',.T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oTBitmap2:lStretch:= .T.
	
	@ 054,008 Say 'Pedido: ' Of oDlg Pixel
	@ 054,038 msGet oPedido Var cPedido When .f. Size 045,008 Of oDlg Pixel
	
	@ 054,090 Say 'Cliente: ' Of oDlg Pixel
	@ 054,120 msGet oCliente Var cCliente When .f. Size 170,008 Of oDlg Pixel
	
	@ 071,008 Say 'Emissão: ' Of oDlg Pixel
	@ 071,038 msGet oEmissao Var dEmissao When .f. Size 45,008 Of oDlg Pixel
	
	@ 074,090 Say 'Vendedor: ' Of oDlg Pixel
	@ 074,120 msGet oVendedor Var cVendedor When .f. Size 170,008 Of oDlg Pixel
	
	bBtOk2	  := {|| M060Leitura( @cLeitura, oGLote, oGPedido ) }
	
	oLeitura := TGet():New( 090,008,{|u| IIf( PCount()>0, cLeitura := u, cLeitura ) },;
	oDlg,260,022,"@!", {|| If(!Empty(cLeitura),Eval(bBtOk2),Nil) },;
	0,,oTexto,.F.,,.T.,,.F.,,.F.,.F.,{||},.F.,.F.,,cLeitura,,,,,,,"QR Itens",1,oLabel,CLR_BLUE,"", )
	
	bBtGravar := {|| U_A30AGravar( oGLote, oGPedido, oDlg ) }
	bBtCanc	  := {|| Iif( nOpc := Aviso( "CIRM060", cMsgExit, aButtons, 2) == 1, Sair(oDlg),Nil ) }
	
	oBtGravar := TButton():New( 115, 515, "&Gravar"  ,  oDlg, bBtGravar, 50,25,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtCanc   := TButton():New( 115, 575, "&Cancelar",  oDlg, bBtCanc, 50,25,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//>----- INICIO TOPO -----<
	
	//>----- INICIO TOPO2 -----<
	oGrpTop2 := TGroup():New( aDimTop2[1],aDimTop2[2],aDimTop2[3],aDimTop2[4],"",oDlg,,,.T. )
	
	oGLote  := MsNewGetDados():New(	aDimTop2[1]+2,;	// 01 - nTop - Numérico	Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contém.
	aDimTop2[2]+2,;	// 02 - nLeft - Numérico	Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contém.
	aDimTop2[3]-2,;	// 03 - nBottom - Numérico	Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contém.
	aDimTop2[4]-2,;	// 04 - nRight - Numérico	Distancia entre a MsNewGetDados e o extremidade direita do objeto que a contém.
	Nil,;			// 05 - nStyle - Numérico	Essa nova propriedade, passada via parâmetro, substitui a passagem das variáveis nOpc. Pode ser utilizada GD_INSERT + GD_UPDATE + GD_DELETE para criar a flexibilidade da MsNewGetdados.
	Nil,;			// 06 - cLinhaOk - Caracter	Função executada para validar o contexto da linha atual do aCols.
	/*inicpos*/,;	// 07 - cTudoOk - Caracter	Função executada para validar o contexto geral da MsNewGetDados (todo aCols).
	Nil,;			// 08 - cIniCpos - Caracter	Nome dos campos do tipo caracter que utilizarão incremento automático. Este parametro deve ser no formato “+++...”.
	Nil,;			// 09 - aAlter - Array of Record	Vetor com os campos que poderão ser alterados.
	/*freeze*/,;	// 10 - nFreeze - Numérico	Congela a coluna da esquerda para a direita. Se 0 não congela, se 1 congela a primeira coluna. Obs: atualmente só é possivel congelar a primeira coluna, devido a limitação do objeto.
	Len(aColsCon),;	// 11 - nMax - Numérico	Número máximo de linhas permitidas. Valor padrão 99.
	Nil,;			// 12 - cFieldOk - Caracter	Função executada na validação do campo.
	/*superdel*/,;	// 13 - cSuperDel - Caracter	Função executada quando pressionada as teclas +.
	/*delok*/,;		// 14 - cDelOk - Caracter	Função executada para validar a exclusão de uma linha do aCols.
	oDlg,;			// 15 - oWnd - Objeto	Objeto no qual a MsGetDados será criada.
	aHeadCon,;		// 16 - aPartHeader - Array of Record	aHeader
	aColsCon,;		// 17 - aParCols Array of Record	Acols
	Nil,;			// 18 - uChange - Bloco de código	Bloco de execução a ser executado na propriedade bChange do Objeto.
	Nil;			// 19 - cTela	Caracter	String contendo os campos contidos no X3_TELA.
	)
	
	//oGLote:oBrowse:lReadOnly:= .T.
	
	
	//>----- FIM TOPO2 -----<
	
	
	//>----- INICIO MEIO -----<
	
	oGrpMid	 := TGroup():New( aDimMid[1],aDimMid[2],aDimMid[3],aDimMid[4],"",oDlg,,,.T. )
	
	oGPedido  := MsNewGetDados():New(	aDimMid[1]+2,;	// 01 - nTop - Numérico	Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contém.
	aDimMid[2]+2,;	// 02 - nLeft - Numérico	Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contém.
	aDimMid[3]-2,;	// 03 - nBottom - Numérico	Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contém.
	aDimMid[4]-2,;	// 04 - nRight - Numérico	Distancia entre a MsNewGetDados e o extremidade direita do objeto que a contém.
	GD_DELETE,;		// 05 - nStyle - Numérico	Essa nova propriedade, passada via parâmetro, substitui a passagem das variáveis nOpc. Pode ser utilizada GD_INSERT + GD_UPDATE + GD_DELETE para criar a flexibilidade da MsNewGetdados.
	Nil,;			// 06 - cLinhaOk - Caracter	Função executada para validar o contexto da linha atual do aCols.
	/*inicpos*/,;	// 07 - cTudoOk - Caracter	Função executada para validar o contexto geral da MsNewGetDados (todo aCols).
	Nil,;			// 08 - cIniCpos - Caracter	Nome dos campos do tipo caracter que utilizarão incremento automático. Este parametro deve ser no formato “+++...”.
	Nil,;			// 09 - aAlter - Array of Record	Vetor com os campos que poderão ser alterados.
	/*freeze*/,;	// 10 - nFreeze - Numérico	Congela a coluna da esquerda para a direita. Se 0 não congela, se 1 congela a primeira coluna. Obs: atualmente só é possivel congelar a primeira coluna, devido a limitação do objeto.
	Len(aColsSC9),;	// 11 - nMax - Numérico	Número máximo de linhas permitidas. Valor padrão 99.
	Nil,;			// 12 - cFieldOk - Caracter	Função executada na validação do campo.
	Nil,;			// 13 - cSuperDel - Caracter	Função executada quando pressionada as teclas +.
	cDelOk,;		// 14 - cDelOk - Caracter	Função executada para validar a exclusão de uma linha do aCols.
	oDlg,;			// 15 - oWnd - Objeto	Objeto no qual a MsGetDados será criada.
	aHeadSC9,;		// 16 - aPartHeader - Array of Record	aHeader
	aColsSC9,;		// 17 - aParCols Array of Record	Acols
	Nil,;			// 18 - uChange - Bloco de código	Bloco de execução a ser executado na propriedade bChange do Objeto.
	Nil;			// 19 - cTela	Caracter	String contendo os campos contidos no X3_TELA.
	)
	
	//oGPedido:oBrowse:lReadOnly:= .T.
	
	//>----- FIM MEIO -----<
	
	oDlg:Activate( {||.T.} , , ,.T., , , )
	
EndDo

RestArea( aAreaSB1 )
RestArea( aAreaSC6 )
RestArea( aAreaSC5 )
RestArea( aAreaSX3 )
RestArea( aArea )

Return Nil

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | Sair    | Autor | CI Result              | Data |10/01/2017|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function Sair( oDlg )

lContinua := .f.
oDlg:End()

Return ( Nil )

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    |ValPedido| Autor | CI Result              | Data |15/11/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao |Valida o pedido de venda                                    |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC01 - Numero do Pedido de Venda                         |||
|||           | ExpO02 - Objeto do Pedido de Venda                         |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL01 - Verdadeiro ou Falso                               |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ValPedido()

Local aArea      := GetArea()
Local lReturn    := .t.
Local aColsCon   := {}
Local lOk        := .t.
Local cAliasTMP  := GetNextAlias()

Tone(3500,1)

cAuxFilial := SubStr(cLPedido,1,TamSx3("C9_FILIAL")[1])
cAuxPedido := SubStr(cLPedido,TamSx3("C9_FILIAL")[1]+1,TamSx3("C9_PEDIDO")[1])

If !Empty(cAuxPedido)
	
	If lOk
		
		SA1->( dbSetOrder(1) ) // A1_FILIAL + A1_COD + A1_LOJA
		SA3->( dbSetOrder(1) ) // A3_FILIAL + A3_COD
		SB1->( dbSetOrder(1) ) // B1_FILIAL + B1_COD
		SC5->( dbSetOrder(1) ) // C5_FILIAL + C5_NUM
		If SC5->( MsSeek( cAuxFilial + cAuxPedido ) )
			
			cPedido	 := SC5->C5_NUM
			dEmissao := SC5->C5_EMISSAO
			cFilPed  := SC5->C5_FILIAL
			
			dbSelectArea("SA1")
			If MsSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
				cCliente := SA1->A1_COD + "/" + SA1->A1_LOJA + "-" + SA1->A1_NOME
			EndIf
			
			dbSelectArea("SA3")
			If MsSeek( xFilial("SA3") + SC5->C5_VEND1 )
				cVendedor := SA3->A3_COD  + "-" + SA3->A3_NOME
			EndIf
			
			dbSelectArea("SC9")
			If MsSeek( SC5->C5_FILIAL + SC5->C5_NUM, .T. )
				While !Eof() .and. C9_FILIAL == SC5->C5_FILIAL  .and. C9_PEDIDO == SC5->C5_NUM
					If (!C9_BLEST=='  '.And.C9_BLEST<>'10'.And.C9_BLEST<>'ZZ')
						dbSelectArea("SB1")
						If MsSeek( xFilial("SB1") + SC9->C9_PRODUTO )
							aAdd( aColsSC9,{SC9->C9_ITEM,SC9->C9_PRODUTO,AllTrim(B1_DESC),SC9->C9_QTDLIB,0,SC9->(Recno()),.F.} )
							If Len(aColsCon) = 0
								aAdd ( aColsCon, { "",0,"","","",Ctod(''),"",0,"","",.f.} )  
							Endif
							//aColsCon[1,1] += SC9->C9_QTDLIB
						EndIf
					Endif
					dbSelectArea("SC9")
					dbSkip()
				EndDo
			EndIf
			
			If Len(aColsSC9) == 0
				//aAdd ( aColsCon, { 0,0,0,0,0,.f.} )
				//aAdd ( aColsSC9, { 	Space(TamSX3("C9_ITEM" )[1]),Space(TamSX3("C9_PRODUTO" )[1]),Space(TamSX3("B1_DESC")[1]),0,0,.f.} )
				Aviso( "PEDIDO", "Nenhum item encontrado para este pedido!", {"Ok"}, 2)
				lReturn := .f.
			EndIf
		Else
			
			Aviso( "PEDIDO", "Pedido inválido!", {"Ok"}, 2)
			lReturn := .F.
			
		EndIf
		
		oGLote:aCols := aColsCon
		oGPedido:aCols := aColsSC9
		oGLote:ForceRefresh()
		oGPedido:ForceRefresh()
		oLPedido:Disable()
		ObjectMethod(oPedido,"Refresh()")
		ObjectMethod(oCliente,"Refresh()")
		ObjectMethod(oEmissao,"Refresh()")
		ObjectMethod(oVendedor,"Refresh()")
		
	EndIf
	
EndIf

Return ( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M060Leitura|Autor | CI Result             | Data |15/11/2018|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao |Leitura do chip                                             |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M060Leitura( cLeitura, oGLote, oGPedido )           |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL01 - Verdadeiro ou Falso                               |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M060Leitura( cLeitura, oGLote, oGPedido )

Local lReturn    := .T.
Local nPosLProd := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Produto"		} )
Local nPosLQtde := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Qtde"		} )
Local nPosLLote := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Lote"		} )
Local nPosLSubL := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Sub-Lote" 	} )
Local nPosLEnde := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Endereco" 	} )
Local nPosLNumS := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Num de Serie"} )
Local nPosLVali := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Validade" 	} )
Local nPosLPote := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Potencia" 	} )
Local nPosLDesc := aScan(oGLote:aHeader,{ |x| Alltrim(x[1])== "Descricao" 	} )      

Local nPosPProd := aScan(oGPedido:aHeader,{ |x| Alltrim(x[1])== "Produto"		} )
Local nPosPQtdl := aScan(oGPedido:aHeader,{ |x| Alltrim(x[1])== "Qtd Liberada"	} )
Local nPosPQtdS := aScan(oGPedido:aHeader,{ |x| Alltrim(x[1])== "Qtd Separada"	} )

Local nScan      := 0

SC6->C6_LOTECTL := aSaldos[nX][1]
SC6->C6_NUMLOTE := aSaldos[nX][2]
SC6->C6_LOCALIZ := aSaldos[nX][3]
SC6->C6_NUMSERI := aSaldos[nX][4]
SC6->C6_DTVALID := aSaldos[nX][7]
SC6->C6_POTENCI := aSaldos[nX][6]

Tone(3500,1)

cAuxProduto := SubStr(cLeitura,1,TamSx3("C9_PRODUTO")[1])
cAuxLotectl := SubStr(cLeitura,TamSx3("C9_PRODUTO")[1]+1,TamSx3("C9_LOTECTL")[1])
dAuxDtValid := SubStr(cLeitura,TamSx3("C9_PRODUTO")[1]+TamSx3("C9_LOTECTL")[1]+1,TamSx3("C9_DTVALID")[1])
nAuxQtdSep	:= SubStr(cLeitura,TamSx3("C9_PRODUTO")[1]+TamSx3("C9_LOTECTL")[1]+TamSx3("C9_DTVALID")[1]+1,TamSx3("C9_QTDLIB")[1])

dAuxDtValid := Ctod(dAuxDtValid)
nAuxQtdSep	:= Val(nAuxQtdSep)

If !Empty(cLeitura)
	
	
	//If Empty(oGPedido:aCols[1][1])
	//	oGPedido:aCols := {}
	//EndIf
	
	// Verificar se o produto lido se encontra no acols
	If ( nScan := Ascan ( oGPedido:aCols, { |X| AllTrim(X[nPosPProd]) == AllTrim(cAuxProduto) } )) <> 0
		
		If oGPedido:aCols[nScan][nPosPQtdl] >= oGPedido:aCols[nScan][nPosPQtdS] + nAuxQtdLib
			
			oGPedido:aCols[nScan][nPosPQtdS] += nAuxQtdSep
			
		Else
			oGLote:aCols[1][nPosILidos] += nAuxQtdLib
		Endif
	Else
		oGLote:aCols[1][nPosIDiver] += nAuxQtdLib
	Endif
	
EndIf

cLeitura   := Space(TamSx3("C9_PRODUTO")[1]) + Space(TamSx3("C9_LOTECTL")[1]) + Space(TamSx3("C9_DTVALID")[1]) + Space(TamSx3("C9_QTDLIB")[1])

oGLote:ForceRefresh()
oGPedido:ForceRefresh()
ObjectMethod(oLeitura,"Refresh()")
oLeitura:SetFocus()

Return( lReturn )


/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | A30ADelIC| Autor | CI Result              | Data |15/11/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Validacao da delecao da linha                              |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A30DelIC( oGLote, oGPedido )                        |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL01 - Verdadeiro ou Falso                               |||
|||-----------+------------------------------------------------------------|||
|||  Uso      |                                                            |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function _A30ADelIC()

Local lReturn    := .T.
Local nPosProduto:= aScan( oGLote:aHeader, { |x| Alltrim(x[2])== "C6_OPERAD"  } )
Local nPosQtdeV  := aScan( oGLote:aHeader, { |x| Alltrim(x[2])== "C6_QTDVEN"  } )
Local nPosLidos  := aScan( oGLote:aHeader, { |x| Alltrim(x[2])== "NN_LIDOS"   } )
Local nPosICCID  := aScan( oGPedido:aHeader , { |x| Alltrim(x[2])== "Z01_ICCID"  } )
Local nPosNomOp  := aScan( oGPedido:aHeader , { |x| Alltrim(x[2])== "Z01_NOMOPE" } )
Local nLinha     := oGPedido:nAt
Local cLeitura   := oGPedido:aCols[nLinha][nPosICCID]
Local nPosDeleta := Len(oGPedido:aHeader)+1
Local nScan      := 0
Local lTudoLido  := .T.
Local nJ         := 0

// Verificar o funcionamento desta funcao
Return(.T.)
//


If ( nScan := Ascan ( oGLote:aCols, { |X| AllTrim(X[nPosOperad]) == AllTrim(oGPedido:aCols[nLinha][nPosNomOp]) } )) > 0
	
	If oGPedido:aCols[nLinha][nPosDeleta]
		
		If oGLote:aCols[nScan][nPosLidos] == oGLote:aCols[nScan][nPosQtdeV]
			
			Aviso( "Separação de Linha", "Ultrapassou a quantidade de linhas para operadora: " + AllTrim(oGPedido:aCols[nLinha][nPosNomOp]), {"Ok"}, 2)
			lReturn := .F.
			
		Else
			oGLote:aCols[nScan][nPosLidos]++
		EndIf
		
	Else
		
		oGLote:aCols[nScan][nPosLidos]--
	EndIf
	oGLote:ForceRefresh()
Else
	Aviso( "Separação de Linha", "Operadora: " + AllTrim(oGPedido:aCols[nLinha][nPosNomOp]) + " não consta neste pedido." , {"Ok"}, 2)
EndIf
oGPedido:ForceRefresh()

// Conferir se todas as linhas foram informadas para todas as operadoras
For nJ := 1 to Len(oGLote:aCols)
	
	If oGLote:aCols[nJ][nPosQtdeV] <> oGLote:aCols[nJ][nPosLidos]
		
		lTudoLido  := .f.
		Exit
		
	EndIf
	
Next nJ

If lTudoLido
	Aviso( "Separação de Linha", "Todos os ICCID's já foram lidos. Esta separação já pode ser gravada.", {"Ok"}, 2)
EndIf

Return ( lReturn )


/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    |A30AGravar|Autor | CI Result              | Data |15/11/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Validacao da gravacao da linha                             |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A30AGravar( oGLote, oGPedido )                        |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpO01 - Objeto dos pedidos de venda                       |||
|||           | ExpO02 - Objeto do monitor de linha                        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL01 - Verdadeiro ou Falso                               |||
|||-----------+------------------------------------------------------------|||
|||  Uso      |                                                            |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function _A30AGravar( oGLote, oGPedido, oDlg )

Local lReturn    := .T.
Local nJ         := 0
Local nL         := 0
Local aItensPedi := aClone( oGLote:aCols )
Local aItensICCI := aClone( oGPedido:aCols )
Local nPosProduto:= aScan ( oGLote:aHeader, { |x| Alltrim(x[2])== "C6_PRODUTO"  } )
Local nPosProDesc:= aScan ( oGLote:aHeader, { |x| Alltrim(x[2])== "B1_DESCP"     } )
Local nPosSerDesc:= aScan ( oGLote:aHeader, { |x| Alltrim(x[2])== "B1_DESCS"     } )
Local nPosLidos  := aScan ( oGLote:aHeader, { |x| Alltrim(x[2])== "NN_LIDOS"    } )
Local nPosCodServ:= aScan ( oGLote:aHeader, { |x| Alltrim(x[2])== "C6_CODSERV"  } )
Local nPosQtdeV  := aScan ( oGLote:aHeader, { |x| Alltrim(x[2])== "C6_QTDVEN"   } )
Local nPosVlrServ:= aScan ( oGLote:aHeader, { |x| Alltrim(x[2])== "C6_VLRSERV"  } )
Local nPosICCID  := aScan ( oGPedido:aHeader , { |x| Alltrim(x[2])== "Z01_ICCID"   } )
Local nPosDeleta := Len(oGPedido:aHeader)+1
Local nPosNomOp  := aScan( oGPedido:aHeader , { |x| Alltrim(x[2])== "Z01_NOMOPE" } )
Local nPosPIDes  := aScan( oGPedido:aHeader , { |x| Alltrim(x[2])== "B1_DESCP"   } )
Local nPosSIDes  := aScan( oGPedido:aHeader , { |x| Alltrim(x[2])== "B1_DESCS"   } )
Local nCntFor    := 0
Local nCnt	     := 0
Local cProduto   := ""
Local cCodProd	 := ""
Local cCodServ	 := ""
Local cCodCli 	 := ""
Local cCodLoj 	 := ""
Local dDtValP	 := ""
Local nScan      := 0
Local nValUnit	 := 0
Local cStacli    := ""
Local nDtACli	 := 0
Local cNumAten   := Soma1( GetMV("ES_PROTATE") )//NUmero do Protocolo


If Len(aItensPedi) > 0
	
	If Empty(aItensPedi[1][1])
		
		Aviso( "Separação de Linha", "Não foi informado nenhum pedido de venda!", {"Ok"}, 2)
		lReturn := .F.
		
	EndIf
	
EndIf

If Len(aItensICCI) > 0
	
	If Empty(aItensICCI[1][1])
		
		Aviso( "Separação de Linha", "Não foi lido nenhum ICCID!", {"Ok"}, 2)
		lReturn := .F.
		
	EndIf
	
EndIf

If lReturn
	
	// Zerar os lidos
	//For nJ := 1 to Len(aItensPedi)
	//	aItensPedi[nJ][nPosLidos] := 0
	//Next nJ
	
	// Conferir se todas as linhas foram informadas para todas as operadoras
	//For nJ := 1 to Len(aItensPedi)
	
	//For nL := 1 to Len(aItensICCI)
	
	//	If AllTrim(Posicione("SB1", 1, xFilial("SB1")+aItensPedi[nJ][nPosProduto], "B1_DESC")) == AllTrim(aItensICCI[nL][nPosNomOp]) .and. !aItensICCI[nL][nPosDeleta]
	//		aItensPedi[nJ][nPosLidos] ++
	//    EndIf
	
	//Next nL
	
	//Next nJ
	
	For nJ := 1 to Len(aItensPedi)
		
		dbselectArea("SB1")
		dbSetOrder(1)
		If dbSeek( xFilial("SB1") + aItensPedi[nJ][nPosProduto] )
			
			If aItensPedi[nJ][nPosLidos] <> aItensPedi[nJ][nPosQtdeV]
				
				Aviso( "Separação de Linha", "Não foram lidos todos ICCID's para o produto: " + AllTrim(Posicione("SB1", 1, xFilial("SB1")+aItensPedi[nJ][nPosProduto], "B1_DESC")) , {"Ok"}, 2)
				lReturn := .F.
				
			EndIf
			
		EndIf
		
	Next nJ
	
	If lReturn
		
		dbSelectArea("SC5")
		dbSetOrder(1)//C5_FILIAL + C5_NUM
		If dbSeek( cFilPed + cPedido )
			
			dDtValP := SC5->C5_DTVALP
			cCicFat := SC5->C5_CICFAT
			cCodCli := SC5->C5_CLIENTE
			cCodLoj := SC5->C5_LOJACLI
			nDtACli := SC5->C5_DIASATI
			cStacli	:= SC5->C5_STACLI
			
			
			Reclock("SC5",.F.)
			SC5->C5_DTSEPL := dDataBase
			Msunlock()
			
		EndIf
		
		For nJ := 1 to Len(aItensICCI)
			
			Begin Transaction
			
			dbSelectArea("Z01")
			Z01->( dbSetOrder(1) ) // Monitor de Linha - Z01_FILIAL + Z01_ICCID
			If MsSeek( xFilial("Z01") + PadR(aItensICCI[nJ][nPosICCID], TamSx3("Z01_ICCID")[1]) )
				
				For nCntFor := 1 To FCount()
					If !AllTrim(FieldName(nCntFor)) $ "Z01_USERGI|Z01_USERGA"
						M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
					EndIf
				Next nCntFor
				
				//dbSelectArea("SC6")
				//dbSetOrder(2)//C6_FILIAL+C6_PRODUTO+C6_NUM
				//If dbSeek( cFilPed + PadR( cCodServ,TamSX3("C6_PRODUTO")[01] ) + cPedido )
				//cStacli	 := Posicione("SF4", 1, xFilial("SF4") + SC6->C6_TES, "F4_STACLI")
				//EndIf
				
				nPAux := Ascan ( oGLote:aCols, { |X| AllTrim(X[nPosProDesc])+AllTrim(X[nPosSerDesc]) == AllTrim(aItensICCI[nJ][nPosPIDes])+AllTrim(aItensICCI[nJ][nPosSIDes]) } )
				
				RecLock("Z01",.F.)
				Z01->Z01_DTSEPL := dDataBase
				Z01->Z01_PROD	:= aItensPedi[nPAux][nPosProduto]
				Z01->Z01_SERV	:= aItensPedi[nPAux][nPosCodServ]
				Z01->Z01_PEDIDO := cPedido
				Z01->Z01_DTVALP := dDtValP
				Z01->Z01_CICFAT := cCicFat
				Z01->Z01_CLIENT	:= cCodCli
				Z01->Z01_LOJCLI	:= cCodLoj
				Z01->Z01_VALSER := aItensPedi[nPAux][nPosVlrServ]
				Z01->Z01_DTACLI := dDataBase+nDtACli
				Z01->Z01_STACLI	:= cStacli
				Z01->Z01_IMPORT	:= ''
				MsUnLock()
				
				// Criar um registro na Z03 neste momento
				Reclock( "Z03",.T. )
				Z03->Z03_FILIAL	:= xFilial("Z03")
				Z03->Z03_ICCID	:= Z01_ICCID
				Z03->Z03_LINHA	:= Z01_LINHA
				Z03->Z03_OCORRE	:= '000353'
				Z03->Z03_DTSOLI := dDataBase
				Z03->Z03_PRODUT := Z01_PROD
				Z03->Z03_USRCHA := __CUSERID
				Z03->Z03_HRCHAM := StrTran(Time(),":","")
				Z03->Z03_DTCHAM := dDatabase
				Z03->Z03_PROTOC := cNumAten
				Z03->Z03_SERV	:= Z01->Z01_SERV
				Z03->Z03_VALOR	:= Z01->Z01_VALSER
				Z03->Z03_DTVALP := Z01->Z01_DTVALP
				Z03->Z03_DTACLI := Z01->Z01_DTACLI
				Z03->Z03_DTEFET := dDataBase
				Z03->Z03_STACLI	:= Z01->Z01_STACLI
				Z03->Z03_NVTITU	:= cCodCli
				Z03->Z03_LJNVTI	:= cCodLoj
				Msunlock()
				
			EndIf
			
			End Transaction
			
		Next nJ
		
		PutMV("ES_PROTATE", cNumAten)
		Aviso( "Separação de Linha", "Gravação efetuado com sucesso." , {"Ok"}, 2)
		
		Sair(oDlg)
		U_VRTA030A()
		
	EndIf
	
EndIf

Return( lReturn )
