#include 'totvs.ch'
/*/{Protheus.doc} GENJob060
	
	Integração Protheus x GENESIS - Setor
	
	@type  Function
	@author Jeferson Silva
	@since 12/04/2021
	@version P12

/*/
*******************************************************************************
User Function GENJob060( aParam )

Private nIE         := 0

RPCSetType( 3 )  // não consome licença 

RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob060] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob060] Empresa Logada: ' + aParam[ 1 ]  )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob060] Filial Logada: ' + aParam[ 2 ] )

U_GE060Run( 2 )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob060] Setor integrados: ' + Transform( nIE, '@E 9,999,999' ) )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_SM060Job] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

//Reset Environment
RpcClearEnv()

Return


********************************************************************************
User Function GE060Run( nOpc )

Local aArea     := GetArea()
Local cQuery
Local aData
Local cAliasQry	:= GetNextAlias()
Local aRet      := {}
Local cTexLog   := ''
Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
Local cFile
Local lGet := .F.

cQuery	:= " select * "
cQuery	+= " from " + RetSqlName( 'SA1' ) + " SA1"
cQuery	+= " where A1_FILIAL = '" + xFilial( 'SA1' ) + "'"
cQuery	+= " and A1_CGC <> '' "
cQuery	+= " and A1_IDGENES <> '' "
//cQuery	+= " and A1_ZDGENES = '' "
cQuery	+= " and SA1.D_E_L_E_T_ = ' '"

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )

While (cAliasQry)->( !EOF() )

    aData   := {}
    lGet := .F.
    If (cAliasQry)->A1_MSBLQL = '1'
        cStatus := 'Inativo'
    Else
        cStatus := 'Ativo'
    EndIf

    ConOut( cTexLog +=  'GE060Run - Setor: ' + (cAliasQry)->A1_COD+' '+(cAliasQry)->A1_LOJA+' '+(cAliasQry)->A1_NOME + CHR(10) + CHR(13) )

    aAdd( aData, { 'codigoExterno'              , CHR(34) + AllTrim( (cAliasQry)->A1_COD )+AllTrim( (cAliasQry)->A1_LOJA ) + CHR(34) } )
    aAdd( aData, { 'nome'                       , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->A1_NOME)) + CHR(34) } )
    aAdd( aData, { 'idCliente'                  , CHR(34) + AllTrim( (cAliasQry)->A1_IDGENES ) + CHR(34) } )
    if empty((cAliasQry)->A1_ZDGENES)
        aRet := U_GENFWS('setores/','GET', AllTrim( (cAliasQry)->A1_COD )+AllTrim( (cAliasQry)->A1_LOJA ))
        if len(aRet) > 0 .and. !empty(aRet[1,1])
            lGet := .T.
            cTexLog         += aRet[1,2]
            SA1->( dbSetOrder( 3 ) )
	        SA1->( dbSeek( xFilial( 'SA1' ) + (cAliasQry)->A1_CGC ) )
            SA1->( RecLock( 'SA1', .F. ) )
                SA1->A1_ZDGENES := aRet[1,1]
            SA1->( MsUnlock() )
        endif
    endif

    If !lGet .and. Empty( (cAliasQry)->A1_ZDGENES )
        
        aRet            := U_GENFWS( 'setores/', 'POST', aData )
        cIdSetoresWS    := aRet[1,1]
        cTexLog         += aRet[1,2]
    Else
        if lGet
            aRet := U_GENFWS( 'setores/'+Alltrim(aRet[1,1]), 'PUT', aData )
        else
            aRet := U_GENFWS( 'setores/'+Alltrim( (cAliasQry)->A1_ZDGENES ), 'PUT', aData )
        endif
        cIdSetoresWS    := aRet[1,1]
        cTexLog         += aRet[1,2]
        
        If Empty(cIdSetoresWS)
            cIdSetoresWS := Alltrim( (cAliasQry)->A1_ZDGENES )
        Endif

    Endif
	
    SA1->( dbSetOrder( 3 ) )
	SA1->( dbSeek( xFilial( 'SA1' ) + (cAliasQry)->A1_CGC ) )

    If !Empty(cIdSetoresWS) .And. Empty( (cAliasQry)->A1_ZDGENES ) // Inclusao 
        SA1->( RecLock( 'SA1', .F. ) )
            SA1->A1_ZDGENES := cIdSetoresWS
        SA1->( MsUnlock() )

    EndIf
    
    (cAliasQry)->(dbSkip()) 
End

(cAliasQry)->(dbCloseArea())

If lLogGEN

    If !ExistDir( '\logGenesis' )

        MakeDir( '\logGenesis' )
    EndIf

    nTent   := 1

    While .T.
        
        cFile   := '\logGenesis\' + 'setor' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'

        If !File( cFile )

            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
            Exit
        EndIf

        nTent ++
    End
EndIf

RestArea( aArea )

Return
