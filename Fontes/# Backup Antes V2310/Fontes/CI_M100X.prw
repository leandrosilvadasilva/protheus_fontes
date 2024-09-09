
#Include "rwmake.ch"
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CI_M100X     || Autor: CI RESULT             || Data: 20/04/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Função para Enderecar produtos da SDA                        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CI_M100X()

Local aAreaAtu      := GetArea()

DbSelectArea('SD1')
DbSelectArea('SD2')
DbSelectArea('SBE')
DbSelectArea('SDA')
DbSelectArea('SDB')
DbSelectArea('SF4')
DbSelectArea('SB1')
DbSelectArea('SF1')

If GetMV( 'MV_LOCALIZ' ) == 'S'
	IncEnderec()
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
Local lTransfFil	:= .T.
Local cFilOrig
Local aNumSeri		:= {}
Local aCab, aItens, aItem
Local cItem, nSaldo

Private lMsHelpAuto 	:= .T.	// Habilita a captura das mensagens de erro
Private lMsErroAuto 	:= .T.	// Indica de se houve erro não fatal durante a execução

DbselectArea('SF1')
DbSetOrder(1)
If dbSeek( xFilial('SF1'), .f. )
	While SF1->( !Eof() ) .and. F1_FILIAL	== xFilial( 'SF1')
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

				aCab	:= {}
				aAdd(aCab,{"DA_FILIAL"	,SDA->DA_FILIAL	,NIL})
				aAdd(aCab,{"DA_PRODUTO"	,SDA->DA_PRODUTO	,NIL})
				aAdd(aCab,{"DA_QTDORI"	,SDA->DA_QTDORI	,NIL})
				aAdd(aCab,{"DA_SALDO"	,SDA->DA_SALDO	,NIL})
				aAdd(aCab,{"DA_DATA"		,SDA->DA_DATA		,NIL})
				aAdd(aCab,{"DA_LOTECTL"	,SDA->DA_LOTECTL	,NIL})
				aAdd(aCab,{"DA_NUMLOTE"	,SDA->DA_NUMLOTE	,NIL})
				aAdd(aCab,{"DA_LOCAL"	,SDA->DA_LOCAL	,NIL})
				aAdd(aCab,{"DA_DOC"		,SDA->DA_DOC		,NIL})
				aAdd(aCab,{"DA_SERIE"	,SDA->DA_SERIE	,NIL})
				aAdd(aCab,{"DA_CLIFOR"	,SDA->DA_CLIFOR	,NIL})
				aAdd(aCab,{"DA_LOJA"		,SDA->DA_LOJA		,NIL})
				aAdd(aCab,{"DA_TIPONF"	,SDA->DA_TIPONF	,NIL})
				aAdd(aCab,{"DA_ORIGEM"	,SDA->DA_ORIGEM	,NIL})
				aAdd(aCab,{"DA_NUMSEQ"	,SDA->DA_NUMSEQ	,NIL})
				aAdd(aCab,{"DA_QTSEGUM"	,SDA->DA_QTSEGUM	,NIL})
				aAdd(aCab,{"DA_QTDORI2"	,SDA->DA_QTDORI2	,NIL})
	
				aItens	:= {}
				cItem	:= '0000'
				nSaldo	:= SDA->DA_SALDO
			 
				If SDA->DA_LOCAL = '10'
					cEnd := '0101           '
				Else
					cEnd := '0301           '
				Endif
				
				If SD1->( FieldPos( 'D1_NUMSERI' ) ) > 0 .and. !Empty( SD1->D1_NUMSERI )
					aItem	:= {{ 'DB_ITEM'		, cItem	:= Soma1( cItem )	, Nil }, ;
					{ 'DB_LOCAL'	, SDA->DA_LOCAL				, Nil }, ;
					{ 'DB_LOCALIZ'	, cEnd		   				, Nil }, ;
					{ 'DB_QUANT'	, 1							, Nil }, ;
					{ 'DB_DATA'		, dDataBase					, Nil }, ;
					{ 'DB_NUMSERI'	, SD1->D1_NUMSERI			, Nil }}
					
					aAdd( aItens, aItem )
					
					nSaldo	--
					
				ElseIf lTransfFil
					SD2->( dbSetOrder( 3 ) )	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					SD2->( dbSeek( '0101' + SD1->D1_DOC + SD1->D1_SERIE + '000001' + '0004' + SD1->D1_COD, .F. ) )
					
					While SD2->( !EoF() ) 	.and. SD2->D2_FILIAL	== '0101' ;
						.and. SD2->D2_DOC		== SD1->D1_DOC ;
						.and. SD2->D2_SERIE		== SD1->D1_SERIE ;
						.and. SD2->D2_CLIENTE	== '000001' ;
						.and. SD2->D2_LOJA		== '0004' ;
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
				
								aItem := Array(0)
								aAdd(aItem,{"DB_ITEM"	,cItem	:= Soma1( cItem )			,NIL})
								aAdd(aItem,{"DB_LOCAL"	,SDA->DA_LOCAL	,NIL})
								aAdd(aItem,{"DB_DOC"		,SDA->DA_DOC	,NIL})
								aAdd(aItem,{"DB_SERIE"	,SDA->DA_SERIE	,NIL})
								aAdd(aItem,{"DB_CLIFOR"	,SDA->DA_CLIFOR	,NIL})
								aAdd(aItem,{"DB_LOJA"	,SDA->DA_LOJA	,NIL})
								aAdd(aItem,{"DB_TIPONF"	,SDA->DA_TIPONF	,NIL})
								aAdd(aItem,{"DB_NUMSEQ"	,SDA->DA_NUMSEQ	,NIL})
								aAdd(aItem,{"DB_DATA"	,SDA->DA_DATA	,NIL})
								aAdd(aItem,{"DB_QUANT"  ,1  			,NIL})
								aAdd(aItem,{"DB_LOCALIZ",cEnd  			,NIL})
								aAdd(aItem,{"DB_NUMSERI",SDB->DB_NUMSERI,NIL})
								
								aAdd( aItens, aItem )
								
								nSaldo	--
								
								aAdd( aNumSeri, { SDB->DB_PRODUTO, SDB->DB_NUMSERI } )
							EndIf
							
							SDB->( dbSkip() )
						End
						
						SD2->( dbSkip() )
					End
				EndIf
			
				SBE->( dbSetOrder( 1 ) )  
				dbSelectArea("SDA")
				dbSelectArea("SDB")
			
				If !Empty( aItens )
					MsExecAuto( { |x,y,z| MatA265( x, y, z ) }, aCab, aItens, 3 )  // 3-Distribui, 4-Estorna
				
					If lMsErroAuto
						
						Mostraerro()
					EndIf
				EndIf
			EndIf
			
			SD1->( dbSkip() )
		End
		
		SF1->( dbSkip() )
	End
	
Endif
RestArea( aAreaSBE )
RestArea( aAreaSDB )
RestArea( aAreaSDA )
RestArea( aAreaSF4 )
RestArea( aAreaSB1 )
RestArea( aArea )

Return      


