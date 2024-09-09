#Include "rwmake.ch"
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CI_M100A     || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Função do Ponto de Entrada MT100AGR                          ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CI_M100A()

Local aAreaAtu      := GetArea()

If INCLUI .and. GetMV( 'MV_LOCALIZ' ) == 'S'

	If IsBlind()
		
		IncEnderec()
	Else
		FWMsgRun(, {|oSay| IncEnderec( oSay ) }, cCadastro, 'Incluindo Enderecamento...' )
	EndIf
	
EndIf	

Restarea( aAreaAtu )

Return


/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: IncEnderec   || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Inclui Endereçamento                                         ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function IncEnderec()

Local aArea			:= GetArea()                                                                                   
Local aAreaSB1		:= SB1->( GetArea() )
Local aAreaSF4		:= SF4->( GetArea() )
Local aAreaSDA		:= SDA->( GetArea() )
Local aAreaSDB		:= SDB->( GetArea() )
Local aAreaSBE		:= SBE->( GetArea() )
Local lTransfFil	:= .F.
Local cFilOrig
Local aNumSeri		:= {}
Local aCab, aItens, aItem
Local cItem, nSaldo

Private lMsHelpAuto 	:= .T.	// Habilita a captura das mensagens de erro
Private lMsErroAuto 	:= .F.	// Indica de se houve erro não fatal durante a execução

SM0->( dbSetOrder( 1 ) )
SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )

// verifica se é transferência e identifica a filial de origem...
SA2->( dbSetOrder( 1 ) )
SA2->( dbSeek( xFilial( 'SA2' ) + SF1->F1_FORNECE + SF1->F1_LOJA, .F. ) )

If SF1->F1_TIPO == 'N' .and. Left( SM0->M0_CGC, 8 ) == Left( SA2->A2_CGC, 8 ) .and. SM0->M0_CGC <> SA2->A2_CGC
	
	lTransfFil	:= .T.
	
	SM0->( dbSetOrder( 1 ) )
	SM0->( dbSeek( cEmpAnt, .F. ) )
	
	While SM0->( !EoF() ) .and. SM0->M0_CODIGO == cEmpAnt
		
		If SM0->M0_CGC == SA2->A2_CGC
			
			Exit
		EndIf
		
		SM0->( dbSkip() )
	End
	
	cFilOrig	:= Left( SM0->M0_CODFIL, Len( cFilAnt ) )
	
	SM0->( dbSetOrder( 1 ) )
	SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )
	
	// localiza a filial de destino no cadastro de clientes...
	SA1->( dbSetOrder( 3 ) )
	SA1->( dbSeek( xFilial( 'SA1' ) + SM0->M0_CGC, .f. ) )
EndIf

SD1->( dbSetOrder( 1 ) )	// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
SD1->( dbSeek( xFilial( 'SD1' ) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA, .f. ) )

While SD1->( !Eof() ) .and. SD1->D1_FILIAL	== xFilial( 'SD1') ;
					  .and. SD1->D1_DOC		== SF1->F1_DOC ;
					  .and. SD1->D1_SERIE	== SF1->F1_SERIE ;
					  .and. SD1->D1_FORNECE	== SF1->F1_FORNECE ;
					  .and. SD1->D1_LOJA	== SF1->F1_LOJA

	SB1->( dbSetOrder( 1 ) )
	SB1->( dbSeek( xFilial( 'SB1' ) + SD1->D1_COD, .F. ) )
	
	SF4->( dbSetOrder( 1 ) )
	SF4->( dbSeek( xFilial( 'SF4' ) + SD1->D1_TES, .F. ) )

	SBE->( dbSetOrder( 1 ) )	// BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
	SDA->( dbSetOrder( 1 ) )	// DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	
	If SB1->B1_LOCALIZ == 'S' .and. ;
		SD1->D1_TIPO $ 'NDB' .and. Empty( SD1->D1_OP ) .and. ;
		SF4->F4_ESTOQUE == 'S' .and. ;
		SBE->( dbSeek( xFilial( 'SBE' ) + SD1->D1_LOCAL, .F. ) ) .and. ;
		SDA->( dbSeek( xFilial( 'SDA' ) + SD1->D1_COD + SD1->D1_LOCAL + SD1->D1_NUMSEQ + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA, .F. ) )

		aCab	:= {{ 'DA_PRODUTO'	, SDA->DA_PRODUTO	, Nil }, ;
					{ 'DA_LOCAL'	, SDA->DA_LOCAL		, Nil }, ;
					{ 'DA_NUMSEQ'	, SDA->DA_NUMSEQ	, Nil }, ;
					{ 'DA_DOC'		, SDA->DA_DOC		, Nil }, ;
					{ 'DA_SERIE'	, SDA->DA_SERIE		, Nil }, ;
					{ 'DA_CLIFOR'	, SDA->DA_CLIFOR	, Nil }, ;
					{ 'DA_LOJA'		, SDA->DA_LOJA		, Nil }, ;
					{ 'DA_LOTECTL'	, SDA->DA_LOTECTL	, Nil }, ;
					{ 'DA_DATA'		, SDA->DA_DATA		, Nil } }
		
		aItens	:= {}
		cItem	:= '0000'
		nSaldo	:= SDA->DA_SALDO
		
		If SD1->( FieldPos( 'D1_NUMSERI' ) ) > 0 .and. !Empty( SD1->D1_NUMSERI )

			aItem	:= {{ 'DB_ITEM'		, cItem	:= Soma1( cItem )	, Nil }, ;
						{ 'DB_LOCALIZ'	, SBE->BE_LOCALIZ			, Nil }, ;
						{ 'DB_QUANT'	, 1							, Nil }, ;
						{ 'DB_DATA'		, dDataBase					, Nil }, ;
						{ 'DB_NUMSERI'	, SD1->D1_NUMSERI			, Nil }}
			
			aAdd( aItens, aItem )
			
			nSaldo	--
			
		ElseIf lTransfFil

			SD2->( dbSetOrder( 3 ) )	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->( dbSeek( cFilOrig + SD1->D1_DOC + SD1->D1_SERIE + SA1->A1_COD + SA1->A1_LOJA + SD1->D1_COD, .F. ) )
			
			While SD2->( !EoF() ) 	.and. SD2->D2_FILIAL	== cFilOrig ;
									.and. SD2->D2_DOC		== SD1->D1_DOC ;
									.and. SD2->D2_SERIE		== SD1->D1_SERIE ;
									.and. SD2->D2_CLIENTE	== SA1->A1_COD ;
									.and. SD2->D2_LOJA		== SA1->A1_LOJA ;
									.and. SD2->D2_COD		== SD1->D1_COD ;
									.and. nSaldo > 0

				SDB->( dbSetOrder( 1 ) )	// DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
				SDB->( dbSeek( SD2->D2_FILIAL + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_NUMSEQ + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA, .F. ) )
				
				While SDB->( !EoF() )	.and. SDB->DB_FILIAL	== SD2->D2_FILIAL ;
										.and. SDB->DB_PRODUTO	== SD2->D2_COD ;
										.and. SDB->DB_LOCAL		== SD2->D2_LOCAL ;
										.and. SDB->DB_NUMSEQ	== SD2->D2_NUMSEQ ;
										.and. SDB->DB_DOC		== SD2->D2_DOC ;
										.and. SDB->DB_SERIE		== SD2->D2_SERIE ;
										.and. SDB->DB_CLIFOR	== SD2->D2_CLIENTE ;
										.and. SDB->DB_LOJA		== SD2->D2_LOJA ;
										.and. nSaldo > 0

					// confere se este número de série não foi utilizado neste endereçamento...
					If !Empty( SDB->DB_NUMSERI ) .and. ( Empty( aNumSeri ) .or. aScan( aNumSeri, { |x| x[ 1 ] == SDB->DB_PRODUTO .and. x[ 2 ] == SDB->DB_NUMSERI } ) <= 0 )
						
						aItem	:= {{ 'DB_ITEM'		, cItem	:= Soma1( cItem )	, Nil }, ;
									{ 'DB_LOCALIZ'	, SBE->BE_LOCALIZ			, Nil }, ;
									{ 'DB_QUANT'	, 1							, Nil }, ;
									{ 'DB_DATA'		, dDataBase					, Nil }, ;
									{ 'DB_NUMSERI'	, SDB->DB_NUMSERI			, Nil }}
						
						aAdd( aItens, aItem )
						
						nSaldo	--
						
						aAdd( aNumSeri, { SDB->DB_PRODUTO, SDB->DB_NUMSERI } )
					EndIf
					
					SDB->( dbSkip() )
				End
				
				SD2->( dbSkip() )
			End
		EndIf
		
		If !Empty( aItens )

			SBE->( dbSetOrder( 1 ) )  
			dbSelectArea("SDA")
			dbSelectArea("SDB")

			MsExecAuto( { |x,y,z| MatA265( x, y, z ) }, aCab, aItens, 3 )  // 3-Distribui, 4-Estorna					  
			
			If lMsErroAuto
				Mostraerro()
			EndIf
		EndIf	    
  	EndIf
	
	SD1->( dbSkip() )
End

RestArea( aAreaSBE )
RestArea( aAreaSDB )
RestArea( aAreaSDA )
RestArea( aAreaSF4 )
RestArea( aAreaSB1 )
RestArea( aArea )

Return
