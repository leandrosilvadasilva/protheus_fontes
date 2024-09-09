#include 'totvs.ch'
/*/{Protheus.doc} GENJob030
	
	Integração Protheus x GENESIS - Materiais
	
	@type  Function
	@author Jeferson Silva
	@since 12/04/2021
	@version P12
/*/

*******************************************************************************
User Function GENJob030( aParam )

Private nIE         := 0

RPCSetType( 3 )  // não consome licença 

RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob030] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob030] Empresa Logada: ' + aParam[ 1 ]  )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob030] Filial Logada: ' + aParam[ 2 ] )

U_GE030Run( 2 )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob030] Materiais integrados: ' + Transform( nIE, '@E 9,999,999' ) )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_SM030Job] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

//Reset Environment
RpcClearEnv()

Return



********************************************************************************
User Function GE030Run( nOpc )

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
cQuery	+= " from " + RetSqlName( 'SBM' ) + " SBM"
cQuery	+= " where BM_FILIAL = '" + xFilial( 'SBM' ) + "'"
//cQuery	+= " and BM_FLAGGEN = '' "
cQuery	+= " and SBM.D_E_L_E_T_ = ' '"

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )

While (cAliasQry)->( !EOF() )

    aData   := {}
    lGet := .F.
    If (cAliasQry)->BM_MSBLQL = '1'
        cStatus := 'Inativo'
    Else
        cStatus := 'Ativo'
    EndIf

    ConOut( cTexLog +=  'GE030Run - Materiais: ' + (cAliasQry)->BM_GRUPO+' '+(cAliasQry)->BM_DESC + CHR(10) + CHR(13) )

    aAdd( aData, { 'codigoExterno'              , CHR(34) + AllTrim( (cAliasQry)->BM_GRUPO ) + CHR(34) } )
    aAdd( aData, { 'nome'                       , CHR(34) + AllTrim( U_USLimpDesc((cAliasQry)->BM_DESC))   + CHR(34) } )
    aAdd( aData, { 'status'                     , CHR(34) + AllTrim( cStatus )               + CHR(34) } )
    aAdd( aData, { 'grauRisco'                  , CHR(34) + 'Medio'                          + CHR(34) } )
    if empty((cAliasQry)->BM_IDGENES)
        aRet := U_GENFWS('materiais/','GET', alltrim((cAliasQry)->BM_GRUPO))
        if len(aRet) > 0 .and. !empty(aRet[1,1])
            SBM->( dbSetOrder( 1 ) )
	        if SBM->( dbSeek( xFilial( 'SBM' ) + (cAliasQry)->BM_GRUPO ) )
                SBM->( RecLock( 'SBM', .F. ) )
                    SBM->BM_IDGENES := aRet[1,1]
                    SBM->BM_FLAGGEN := Dtos(Date())+'-'+Time()
                SBM->( MsUnlock() )
                lGet := .T.
                cTexLog         += aRet[1,2]
            endif
        endif
    endif
    If !lGet .and. Empty( (cAliasQry)->BM_IDGENES )
        aRet            := U_GENFWS( 'materiais/', 'POST', aData )
        cIdMateriaisWS  := aRet[1,1]
        cTexLog         += aRet[1,2]
    Else
        if lGet
            aRet    := U_GENFWS( 'materiais/'+Alltrim(aRet[1,1]), 'PUT', aData )
        else
            aRet    := U_GENFWS( 'materiais/'+Alltrim( (cAliasQry)->BM_IDGENES ), 'PUT', aData )
        endif
        cIdMateriaisWS  := aRet[1,1]
        cTexLog         += aRet[1,2]
        If Empty(cIdMateriaisWS)
            cIdMateriaisWS := Alltrim( (cAliasQry)->BM_IDGENES )
        Endif
    Endif
    SBM->( dbSetOrder( 1 ) )
	SBM->( dbSeek( xFilial( 'SBM' ) + (cAliasQry)->BM_GRUPO ) )
    If !Empty(cIdMateriaisWS) .And. Empty( (cAliasQry)->BM_IDGENES ) // Inclusao 
        SBM->( RecLock( 'SBM', .F. ) )
            SBM->BM_IDGENES := cIdMateriaisWS
            SBM->BM_FLAGGEN := Dtos(Date())+'-'+Time()
        SBM->( MsUnlock() )
    EndIf
    If !Empty(cIdMateriaisWS) .And. !Empty( (cAliasQry)->BM_IDGENES ) // Alteracao 
        SBM->( RecLock( 'SBM', .F. ) )
            SBM->BM_FLAGGEN := Dtos(Date())+'-'+Time()
        SBM->( MsUnlock() )
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
        cFile   := '\logGenesis\' + 'materiais' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'
        If !File( cFile )
            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
            Exit
        EndIf
        nTent ++
    End
EndIf

RestArea( aArea )

Return
