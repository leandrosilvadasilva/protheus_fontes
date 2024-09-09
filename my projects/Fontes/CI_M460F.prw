#Include "rwmake.ch"
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CI_M460F     || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Função do Ponto de Entrada M460FIM                           ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CI_M460F()

Local aAreaAtu      := GetArea()
//IATAN EM 27/09/2022
Public incNFDest    := .F.

// tratamento para gerar pré-nota na filial de destino nos casos de transferência...
SM0->( dbSetOrder( 1 ) )
SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )

SA1->( dbSetOrder( 1 ) )
SA1->( dbSeek( xFilial( 'SA1' ) + SF2->F2_CLIENTE + SF2->F2_LOJA, .F. ) )

Conout('Executando rotina para gerar pré-nota na filial de destino nos casos de transferência - CI_M460F')

// verifica se é uma transferência de mercadoria entre filiais...
// desconsidera se o emitente for o mesmo destinatário...
If SF2->F2_TIPO == 'N' .and. Left( SM0->M0_CGC, 8 ) == Left( SA1->A1_CGC, 8 ) .and. SM0->M0_CGC <> SA1->A1_CGC
	
	If IsBlind()
		IncNFDest()
	Else
		FWMsgRun(, {|oSay| IncNFDest( ) }, cCadastro, 'Incluindo Documento de Entrada na filial de destino...' )
	EndIf
EndIf

//IATAN EM 15/08/2023 - QUANDO QUALQUER UMA DAS FILIAIS EMITIR UMA NOTA PARA A EMPRESA 5001 (OUTRA RAIZ DE CNPJ)
//                      DEVEMOS INCLUIR UM PEDIDO DE COMPRAS NA FILIAL 5001 E INCLUIR O DOCUMENTO DE ENTRADA
IF SF2->F2_CLIENTE == '000170' .AND. SF2->F2_LOJA = '0001' .AND. Left( SM0->M0_CGC, 8 ) == '04078043'// VENDA DE QUALQUER FILIAL PARA A EMPRESA 5001
	If IsBlind()
		IncNFDest("5001")
	Else
		FWMsgRun(, {|oSay| IncNFDest( "5001" ) }, cCadastro, 'Incluindo PC e Documento de Entrada na empresa de destino (5001)...' )
	EndIf
//		IncPCNF() // Inclui o Pedido de compras e o documento de entrada na filial 5001
ENDIF

Restarea( aAreaAtu )

Return


/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: IncNFDest    || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Inclui Documento de Entrada na filial de destino             ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function IncNFDest( empDest )

Local aAreaSA2      := SA2->(GetArea())

Local aAutoCab		:= {}
Local aAutoItens	:= {}

//Variaveis para geração do Pedido de Compras
Local aCab := {}
Local aItens := {}
Local aLinha := {}
Local numPed := ''

Local cFilBkp		:= cFilAnt
Local cFilDest
Local lClassifNF	:= .F.
//Local cZtetran		:= ''

Private lMsHelpAuto 	:= .T.	// Habilita a captura das mensagens de erro
Private lMsErroAuto 	:= .F.	// Indica de se houve erro não fatal durante a execução

//IATAN EM 27/09/2022
incNFDest    := .T.

// localiza a filial de origem no cadastro de fornecedores...
SA2->( dbSetOrder( 3 ) )
SA2->( dbSeek( xFilial( 'SA2' ) + SM0->M0_CGC, .f. ) )

// identifica a filial de destino...
SM0->( dbSetOrder( 1 ) )
SM0->( dbSeek( cEmpAnt, .F. ) )

IF empDest == "5001"
	Conout('Gerando pc + pré-nota na empresa de destino nos casos de Venda para empresa 5001 - CI_M460F')
ELSE
	Conout('Gerando pré-nota na filial de destino nos casos de transferência - CI_M460F')
ENDIF

While SM0->( !EoF() ) .and. SM0->M0_CODIGO == cEmpAnt
	
	If SM0->M0_CGC == SA1->A1_CGC
		
		Exit
	EndIf
	
	SM0->( dbSkip() )
End

cFilDest	:= Left( SM0->M0_CODFIL, Len( cFilAnt ) )

IF empDest == "5001"
	aAutoCab	:= {{ "F1_TIPO"		, 'N'										, Nil }, ;
	{ "F1_FORMUL"	, 'N'										, Nil }, ;
	{ "F1_DOC"		, SF2->F2_DOC								, Nil }, ;
	{ "F1_SERIE"	, SF2->F2_SERIE								, Nil }, ;
	{ "F1_EMISSAO"	, SF2->F2_EMISSAO							, Nil }, ;
	{ "F1_FORNECE"	, SA2->A2_COD								, Nil }, ;
	{ "F1_LOJA"		, SA2->A2_LOJA								, Nil }, ;
	{ "F1_ESPECIE"	, 'SPED'										, Nil }, ;
	{ "F1_COND"		, SA2->A2_COND								, Nil }, ;
	{ "F1_CHVNFE"	, SF2->F2_CHVNFE							, Nil }}
ELSE
	aAutoCab	:= {{ "F1_TIPO"		, 'N'										, Nil }, ;
	{ "F1_FORMUL"	, 'N'										, Nil }, ;
	{ "F1_DOC"		, SF2->F2_DOC								, Nil }, ;
	{ "F1_SERIE"	, SF2->F2_SERIE								, Nil }, ;
	{ "F1_EMISSAO"	, SF2->F2_EMISSAO							, Nil }, ;
	{ "F1_FORNECE"	, SA2->A2_COD								, Nil }, ;
	{ "F1_LOJA"		, SA2->A2_LOJA								, Nil }, ;
	{ "F1_ESPECIE"	, 'SPED'									, Nil }, ;
	{ "F1_COND"		, SA2->A2_COND								, Nil }, ;
	{ "F1_CHVNFE"	, SF2->F2_CHVNFE							, Nil }}
ENDIF
//-------------------
SD2->( dbSetOrder( 3 ) )	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->( dbSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA, .f. ) )

IF empDest == "5001" 

	cQuery	:= "select D2_ITEM, SD2.R_E_C_N_O_ RECSD2"
	cQuery	+= " from " + RetSqlName( "SD2" ) + " SD2 " 
	cQuery	+= " where D2_FILIAL= '" + SF2->F2_FILIAL + "'"
	cQuery	+= " and D2_DOC     = '" + SF2->F2_DOC + "'"
	cQuery	+= " and D2_SERIE   = '" + SF2->F2_SERIE + "'"
	cQuery	+= " and D2_CLIENTE = '" + SF2->F2_CLIENTE + "'"
	cQuery	+= " and D2_LOJA    = '" + SF2->F2_LOJA + "'"
	cQuery	+= " and SD2.D_E_L_E_T_ = ' '"
	cQuery	+= " order by D2_ITEM" 

ELSE

	cQuery	:= "select D2_ITEM, SD2.R_E_C_N_O_ RECSD2"
	cQuery	+= " from " + RetSqlName( "SD2" ) + " SD2, " + RetSqlName("SF4") + " SF4"
	cQuery	+= " where D2_FILIAL= '" + SF2->F2_FILIAL + "'"
	cQuery  += " and D2_FILIAL  = F4_FILIAL"
	cQuery  += " and D2_TES     = F4_CODIGO"
	cQuery	+= " and D2_DOC     = '" + SF2->F2_DOC + "'"
	cQuery	+= " and D2_SERIE   = '" + SF2->F2_SERIE + "'"
	cQuery	+= " and D2_CLIENTE = '" + SF2->F2_CLIENTE + "'"
	cQuery	+= " and D2_LOJA    = '" + SF2->F2_LOJA + "'"
	cQuery	+= " and F4_ZPREXNF <> ' ' "
	cQuery	+= " and F4_ZTETRAN <> ' ' "
	cQuery	+= " and SD2.D_E_L_E_T_ = ' '"
	cQuery	+= " and SF4.D_E_L_E_T_ = ' '"
	cQuery	+= " order by D2_ITEM" 

ENDIF
	
dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "SD2TMP", .F., .T. )
Count to nReg

If  nReg == 0 
	SD2TMP->( dbCloseArea() )
	Restarea( aAreaSA2 )
    Return
Endif

SD2TMP->(DbGoTop() )

IF empDest == "5001"

	// atualiza a filial para a filial de destino...
	cFilAnt	:= "5001"	// SF2->F2_LOJA

	// reinicializa ambiente para o fiscal...
	If MaFisFound()
		MaFisEnd()
	EndIf


	While SD2TMP->( !EOF() )

		SD2->( dbGoTo( SD2TMP->RECSD2 ) )

		AADD(aCab, {"C7_FILIAL"    ,"5001", NIL})
		AADD(aCab, {"C7_EMISSAO"   ,dDataBase, NIL})
		AADD(aCab, {"C7_FORNECE"   ,SA2->A2_COD, NIL})
		AADD(aCab, {"C7_LOJA"      ,SA2->A2_LOJA, NIL})
		AADD(aCab, {"C7_COND"      ,"001", NIL}) 
		AADD(aCab, {"C7_FILENT"    ,"5001", NIL})          
		AADD(aCab, {"C7_MOEDA"     ,1.00, NIL})    
		AADD(aCab, {"C7_CONAPRO"   ,"L", NIL})    
		AADD(aCab,{"C7_USER"       ,"000000", NIL}) 

		aCab:= WsAutoOpc(aCab) 

		aLinha := {}

		AADD( aLinha,{"C7_FILIAL"  ,"5001", NIL})
		AADD( aLinha,{"C7_ITEM"    ,SD2->D2_ITEM, NIL})
		AADD( aLinha,{"C7_PRODUTO" ,SD2->D2_COD	, NIL})    
		AADD( aLinha,{"C7_TIPO"    ,1, NIL})
		AADD( aLinha,{"C7_QUANT"   ,SD2->D2_QUANT, NIL})
		AADD( aLinha,{"C7_PRECO"   ,SD2->D2_PRCVEN, NIL})
		AADD( aLinha,{"C7_TOTAL"   ,SD2->D2_TOTAL, NIL})
		AADD( aLinha,{"C7_LOCAL"   ,SD2->D2_LOCAL, NIL})    
		AADD( aLinha,{"C7_OBS"     ,"IMPORTACAO AUTOMATICA", NIL}) 
		AADD( aLinha,{"C7_FORNECE" ,SA2->A2_COD, NIL})
		AADD( aLinha,{"C7_LOJA"    ,SA2->A2_LOJA, NIL})
		AADD( aLinha,{"C7_COND"    ,"001", NIL}) // CONDIÇÃO 001 FIXA
		AADD( aLinha,{"C7_EMISSAO" ,dDataBase, NIL})
		AADD( aLinha,{"C7_FILENT"  ,"5001", NIL})          
		AADD( aLinha,{"C7_TPFRETE" ," ", NIL})          
		AADD( aLinha,{"C7_FLUXO"   ,"S", NIL})
		AADD( aLinha,{"C7_QTDSOL"  ,SD2->D2_QUANT, NIL})
		AADD( aLinha,{"C7_TXMOEDA" ,1.00, NIL})
		AADD( aLinha,{"C7_MOEDA"   ,1.00, NIL})         
		AADD( aLinha,{"C7_PENDEN"  ,"N", NIL})         
		AADD( aLinha,{"C7_POLREPR" ,"N", NIL})         
		AADD( aLinha,{"C7_GRADE"   ,"N", NIL})         
		AADD( aLinha,{"C7_RATEIO"  ,"2", NIL})
		AADD( aLinha,{"C7_ACCPROC" ,"2", NIL})
		AADD( aLinha,{"C7_FRETE"   ,0.00, NIL})
		AADD( aLinha,{"C7_DESPESA" ,0.00, NIL})
		AADD( aLinha,{"C7_SEGURO"  ,0.00, NIL})
		AADD( aLinha,{"C7_DESC1"   ,0.00, NIL})
		AADD( aLinha,{"C7_DESC2"   ,0.00, NIL})
		AADD( aLinha,{"C7_DESC3"   ,0.00, NIL})
		AADD( aLinha,{"C7_QUJE"    ,0.00, NIL})
		AADD( aLinha,{"C7_RESIDUO" ," ", NIL})
		AADD( aLinha,{"C7_CONAPRO" ,"L", NIL}) 
		AADD( aLinha,{"C7_USER"    ,"000000", NIL}) 

		AADD(aItens,aLinha)


		SD2TMP->( dbSkip() )

	End

	SD2TMP->(DbGoTop() )

	lMsErroAuto := .F.                    
	MATA120(1,aCab,aItens,3)

	If lMsErroAuto
		lErro := .T.
		IF IsBlind()

		ELSE
			Alert("Erro ao Cadastrar Pedido")
			MostraErro()
		ENDIF
	ELSE
		numped := SC7->C7_NUM
	ENDIF

	// retorna a filial original...
	cFilAnt	:= cFilBkp

	SM0->( dbSetOrder( 1 ) )
	SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )

	// reinicializa ambiente para o fiscal...
	If MaFisFound()
		MaFisEnd()
	EndIf


ENDIF



	While SD2TMP->( !EOF() )

		SD2->( dbGoTo( SD2TMP->RECSD2 ) )

		aItem	:= {{ 'D1_ITEM'   , SD2->D2_ITEM					, Nil }, ;
					{ 'D1_COD'    , SD2->D2_COD						, Nil }, ;
					{ 'D1_QUANT'  , SD2->D2_QUANT					, Nil }, ;
					{ 'D1_VUNIT'  , SD2->D2_PRCVEN					, Nil }, ;
					{ 'D1_TOTAL'  , SD2->D2_TOTAL					, Nil }, ;
					{ 'D1_LOCAL'  , SD2->D2_LOCAL					, Nil }}


		IF empDest == "5001"
			lClassifNF	:= .F.
			aAdd( aItem, { 'D1_PEDIDO'	, numPed				, Nil } )
			aAdd( aItem, { 'D1_ITEMPC'	, SD2->D2_ITEM   		, Nil } )
		ELSE 
			SF4->( dbSetOrder( 1 ) )
			SF4->( dbSeek( xFilial('SF4')+SD2->D2_TES, .f. ) )
			
			If SF4->( FieldPos( 'F4_ZTETRAN' ) ) > 0 .and. !Empty( SF4->F4_ZTETRAN )
				
				//aAdd( aItem, { 'D1_TES'	, SF4->F4_ZTETRAN					, Nil } )  //comentado em  21/02/11 (Marlovani)
				
				If SF4->( FieldPos( 'F4_ZPREXNF' ) ) > 0 .and. !Empty( SF4->F4_ZPREXNF )
					If SF4->F4_ZPREXNF = 'N' //Nota
						aAdd( aItem, { 'D1_TES'	, SF4->F4_ZTETRAN					, Nil } )    //incluido 21/02/11 (Marlovani)
						lClassifNF	:= .T.
					ElseIf SF4->F4_ZPREXNF = 'P' //Pre Nota
						lClassifNF	:= .F.
					Endif
				EndIf
				
			Endif
		ENDIF
		
		aAdd( aItem, { 'D1_LOCAL'	, SD2->D2_LOCAL					, Nil } )
		
		If Rastro( SD2->D2_COD, 'L' )
				
			aAdd( aItem, { 'D1_LOTECTL'	, SD2->D2_LOTECTL				, Nil } )
			aAdd( aItem, { 'D1_DTVALID'	, SD2->D2_DTVALID				, Nil } )
		EndIf
			
		aAdd( aAutoItens, aItem )


		SD2TMP->( dbSkip() )

	End


	SD2TMP->( dbCloseArea() )

/*---------------------------------------------------------------------------
SD2->( dbSetOrder( 3 ) )	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->( dbSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA, .f. ) )

While SD2->( !EoF() ) 	.and. SD2->D2_FILIAL	== SF2->F2_FILIAL ;
	.and. SD2->D2_DOC		== SF2->F2_DOC ;
	.and. SD2->D2_SERIE		== SF2->F2_SERIE ;
	.and. SD2->D2_CLIENTE	== SF2->F2_CLIENTE ;
	.and. SD2->D2_LOJA		== SF2->F2_LOJA
	
	aItem := {{ 'D1_ITEM' , StrZero(Val(SD2->D2_ITEM),4), Nil }, ;
	{ 'D1_COD'    , SD2->D2_COD						, Nil }, ;
	{ 'D1_QUANT'  , SD2->D2_QUANT					, Nil }, ;
	{ 'D1_VUNIT'  , SD2->D2_PRCVEN					, Nil }, ;
	{ 'D1_TOTAL'  , SD2->D2_TOTAL					, Nil }}
---------------------------------------------------------------------------*/


// atualiza a filial para a filial de destino...
cFilAnt	:= cFilDest	// SF2->F2_LOJA

// reinicializa ambiente para o fiscal...
If MaFisFound()
	MaFisEnd()
EndIf

If lClassifNF
	MSExecAuto( {|x,y,z| Mata103( x, y, z ) }, aAutoCab, aAutoItens, 3 )
Else
	MSExecAuto( {|x,y,z| Mata140( x, y, z ) }, aAutoCab, aAutoItens, 3 )
EndIf

If lMsErroAuto
	MostraErro()
EndIf

// retorna a filial original...
cFilAnt	:= cFilBkp

SM0->( dbSetOrder( 1 ) )
SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )

// reinicializa ambiente para o fiscal...
If MaFisFound()
	MaFisEnd()
EndIf

Restarea( aAreaSA2 )

Return

