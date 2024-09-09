#include 'totvs.ch'
/*/{Protheus.doc} GENJob020
	
	Integração Protheus x GENESIS - Produtos
	
	@type  Function
	@author Jeferson Silva
	@since 12/04/2021
	@version P12
/*/

*******************************************************************************
User Function GENJob020( aParam )

Private nIE         := 0

RPCSetType( 3 )  // não consome licença 

RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob020] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob020] Empresa Logada: ' + aParam[ 1 ]  )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob020] Filial Logada: ' + aParam[ 2 ] )

U_GE020Run( 2 )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob020] Produtos integrados: ' + Transform( nIE, '@E 9,999,999' ) )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_SM020Job] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

//Reset Environment
RpcClearEnv()

Return



********************************************************************************
User Function GE020Run( nOpc )

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
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1"

cQuery  += "     inner join " + RetSQLName("SBM") + " SBM"  
cQuery  += "         on BM_FILIAL = '" + xFilial( 'SBM' ) + "'"  
cQuery  += "         and BM_GRUPO = B1_GRUPO"  

cQuery  += "     inner join " + RetSQLName("SX5") + " SX5"  
cQuery  += "         on X5_FILIAL = '" + xFilial( 'SX5' ) + "'"  
cQuery  += "         and X5_CHAVE = B1_MARCA and X5_TABELA = 'ZX'"  
	
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_TIPO in ('M1','M3') "
//cQuery	+= " and B1_FLAGGEN = '' "

cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and SBM.D_E_L_E_T_ = ' '"
cQuery	+= " and SX5.D_E_L_E_T_ = ' '"
cQuery	+= " Order By B1_COD "

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )

While (cAliasQry)->( !EOF() )
    lGet := .F.
    aData   := {}

    If (cAliasQry)->B1_MSBLQL = '1'
        cStatus := 'Inativo'
    Else
        cStatus := 'Ativo'
    EndIf

    ConOut( cTexLog +=  'GE020Run - modelos: ' + (cAliasQry)->B1_COD+' '+(cAliasQry)->B1_DESC + CHR(10) + CHR(13) )

    aAdd( aData, { 'codigoExterno'         , CHR(34) + AllTrim( (cAliasQry)->B1_COD )      + CHR(34) } )
    aAdd( aData, { 'nome'                  , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->B1_DESC))+CHR(34) } )
    aAdd( aData, { 'idEmpresaFabricante'   , CHR(34) + AllTrim( (cAliasQry)->X5_DESCENG)   + CHR(34) } )
    aAdd( aData, { 'idMaterial'            , CHR(34) + AllTrim( (cAliasQry)->BM_IDGENES)   + CHR(34) } )
    aAdd( aData, { 'status'                , CHR(34) + AllTrim( cStatus )                  + CHR(34) } )
    aAdd( aData, { 'nranvisa'              , CHR(34) + AllTrim( (cAliasQry)->B1_NRANVIS)   + CHR(34) } )
    if empty((cAliasQry)->B1_IDGENES)
        aRet := U_GENFWS( 'modelos/', 'GET', (cAliasQry)->B1_COD)
        if len(aRet) > 0 .and. !empty(aRet[1,1])
            SB1->( dbSetOrder( 1 ) )
	        if SB1->( dbSeek( xFilial( 'SB1' ) + (cAliasQry)->B1_COD ) )
                SB1->( RecLock( 'SB1', .F. ) )
                    SB1->B1_IDGENES := aRet[1,1]
                    SB1->B1_FLAGGEN := Dtos(Date())+'-'+Time()
                SB1->( MsUnlock() )
                lGet := .T.
                cTexLog         += aRet[1,2]
            endif
        endif
    endif
    If Empty( (cAliasQry)->B1_IDGENES )
        
        aRet            := U_GENFWS( 'modelos/', 'POST', aData )
        cIdProdutosWS   := aRet[1,1]
        cTexLog         += aRet[1,2]
    Else
        if lGet
            aRet := U_GENFWS( 'modelos/'+Alltrim(aRet[1,1]), 'PUT', aData )    
        else
            aRet := U_GENFWS( 'modelos/'+Alltrim( (cAliasQry)->B1_IDGENES ), 'PUT', aData )    
        endif
        cIdProdutosWS   := aRet[1,1]
        cTexLog         += aRet[1,2]
        If Empty(cIdProdutosWS)
            cIdProdutosWS := Alltrim( (cAliasQry)->B1_IDGENES )
        Endif

    Endif
	
    SB1->( dbSetOrder( 1 ) )
	SB1->( dbSeek( xFilial( 'SB1' ) + (cAliasQry)->B1_COD ) )

    If !Empty(cIdProdutosWS) .And. Empty( (cAliasQry)->B1_IDGENES ) // Inclusao 

        SB1->( RecLock( 'SB1', .F. ) )
            SB1->B1_IDGENES := cIdProdutosWS
            SB1->B1_FLAGGEN := Dtos(Date())+'-'+Time()
        SB1->( MsUnlock() )

    EndIf

    If !Empty(cIdProdutosWS) .And. !Empty( (cAliasQry)->B1_IDGENES ) // Alteracao 

        SB1->( RecLock( 'SB1', .F. ) )
            SB1->B1_FLAGGEN := Dtos(Date())+'-'+Time()
        SB1->( MsUnlock() )
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
        
        cFile   := '\logGenesis\' + 'modelos' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'

        If !File( cFile )

            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
            Exit
        EndIf

        nTent ++
    End
EndIf

RestArea( aArea )

Return
