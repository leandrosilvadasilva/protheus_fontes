#Include "rwmake.ch"
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CI_M520E     || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Função do Ponto de Entrada SF2520E                           ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CI_M520E()

Local aAreaAtu      := GetArea()

// tratamento para gerar pré-nota na filial de destino nos casos de transferência...
SM0->( dbSetOrder( 1 ) )
SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )

SA1->( dbSetOrder( 1 ) )
SA1->( dbSeek( xFilial( 'SA1' ) + SF2->F2_CLIENTE + SF2->F2_LOJA, .F. ) )

// verifica se é uma transferência de mercadoria entre filiais...
// desconsidera se o emitente for o mesmo destinatário...
If SF2->F2_TIPO == 'N' .and. Left( SM0->M0_CGC, 8 ) == Left( SA1->A1_CGC, 8 ) .and. SM0->M0_CGC <> SA1->A1_CGC
	
	If IsBlind()
		
		ExcNFDest()
	Else
		FWMsgRun(, {|oSay| ExcNFDest( oSay ) }, cCadastro, 'Excluindo Documento de Entrada na filial de destino...' )
	EndIf
EndIf

Restarea( aAreaAtu )

Return


/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: ExcNFDest    || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Exclui Documento de Entrada na filial de destino             ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ExcNFDest()

Local aAreaSA2      := SA2->(GetArea())

Local aAutoCab		:= {}
Local aAutoItens	:= {}
Local cFilBkp		:= cFilAnt
Local cFilDest

Private lMsHelpAuto 	:= .T.	// Habilita a captura das mensagens de erro
Private lMsErroAuto 	:= .F.	// Indica de se houve erro não fatal durante a execução

// localiza a filial de origem no cadastro de fornecedores...
SA2->( dbSetOrder( 3 ) )
SA2->( dbSeek( xFilial( 'SA2' ) + SM0->M0_CGC, .f. ) )

// identifica a filial de destino...
SM0->( dbSetOrder( 1 ) )
SM0->( dbSeek( cEmpAnt, .F. ) )

While SM0->( !EoF() ) .and. SM0->M0_CODIGO == cEmpAnt
	
	If SM0->M0_CGC == SA1->A1_CGC
		
		Exit
	EndIf
	
	SM0->( dbSkip() )
End

cFilDest	:= Left( SM0->M0_CODFIL, Len( cFilAnt ) )

SF1->( dbSetOrder( 1 ) )
If SF1->( dbSeek( cFilDest + SF2->F2_DOC + SF2->F2_SERIE + SA2->A2_COD + SA2->A2_LOJA + 'N', .F. ) )

	aAutoCab	:= {{ "F1_TIPO"		, SF1->F1_TIPO								, Nil }, ;
					{ "F1_FORMUL"	, SF1->F1_FORMUL							, Nil }, ;
					{ "F1_DOC"		, SF1->F1_DOC								, Nil }, ;
					{ "F1_SERIE"	, SF1->F1_SERIE								, Nil }, ;
					{ "F1_EMISSAO"	, SF1->F1_EMISSAO							, Nil }, ;
					{ "F1_FORNECE"	, SF1->F1_FORNECE							, Nil }, ;
					{ "F1_LOJA"		, SF1->F1_LOJA								, Nil }, ;
					{ "F1_ESPECIE"	, SF1->F1_ESPECIE							, Nil }, ;
					{ "F1_COND"		, SF1->F1_COND								, Nil }}
	
	SD1->( dbSetOrder( 1 ) )	// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->( dbSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA, .f. ) )
	
	While SD1->( !Eof() ) .and. SD1->D1_FILIAL	== SF1->F1_FILIAL ;
						  .and. SD1->D1_DOC		== SF1->F1_DOC ;
						  .and. SD1->D1_SERIE	== SF1->F1_SERIE ;
						  .and. SD1->D1_FORNECE	== SF1->F1_FORNECE ;
						  .and. SD1->D1_LOJA	== SF1->F1_LOJA

		aItem	:= {{ 'D1_ITEM'		, SD1->D1_ITEM								, Nil }, ;
					{ 'D1_COD'		, SD1->D1_COD								, Nil }, ;
					{ 'D1_QUANT'	, SD1->D1_QUANT								, Nil }, ;
					{ 'D1_VUNIT'	, SD1->D1_VUNIT								, Nil }, ;
					{ 'D1_TOTAL'	, SD1->D1_TOTAL								, Nil }}
		
		If !Empty( SD1->D1_TES )
			
			aAdd( aItem, { 'D1_TES'		, SD1->D1_TES							, Nil } )
		EndIf
		
		aAdd( aAutoItens, aItem )
		
		SD1->( dbSkip() )
	End
	
	// atualiza a filial para a filial de destino...
	cFilAnt	:= cFilDest	// SF2->F2_LOJA
	
	// reinicializa ambiente para o fiscal...
	If MaFisFound()
		MaFisEnd()
	EndIf
	
	If Empty( SF1->F1_STATUS )

		MSExecAuto( {|x,y,z| Mata140( x, y, z ) }, aAutoCab, aAutoItens, 5 )
	Else
		MSExecAuto( {|x,y,z| Mata103( x, y, z ) }, aAutoCab, aAutoItens, 5 )
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
EndIf

Restarea( aAreaSA2 )

Return
