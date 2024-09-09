#include 'totvs.ch'
/*/{Protheus.doc} GENJob040
	
	Integração Protheus x GENESIS - Empresas
	
	@type  Function
	@author Jeferson Silva
	@since 12/04/2021
	@version P12
/*/

*******************************************************************************
User Function GENJob040( aParam )

Private nIE         := 0

RPCSetType( 3 )  // não consome licença 

RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob040] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob040] Empresa Logada: ' + aParam[ 1 ]  )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob040] Filial Logada: ' + aParam[ 2 ] )

U_GE040Run( 2 )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob040] Empresas integrados: ' + Transform( nIE, '@E 9,999,999' ) )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_SM040Job] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

//Reset Environment
RpcClearEnv()

Return



********************************************************************************
User Function GE040Run( nOpc )

Local aArea     := GetArea()
Local cQuery
Local aData
Local cAliasQry	:= GetNextAlias()
Local aRet      := {}
Local cTexLog   := ''
Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
Local cFile

cQuery	:= " select * "
cQuery	+= " from " + RetSqlName( 'SX5' ) + " SX5"
cQuery	+= " where X5_FILIAL = '" + xFilial( 'SX5' ) + "'"
cQuery	+= " and X5_TABELA = 'ZX'"
cQuery	+= " and SX5.D_E_L_E_T_ = ' '"
cQuery	+= " order by X5_CHAVE "

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )

While (cAliasQry)->( !EOF() )

    aData   := {}
    cStatus := 'Ativo'
    
    ConOut( cTexLog +=  'GE040Run - Empresas: ' + (cAliasQry)->X5_CHAVE+' '+(cAliasQry)->X5_DESCRI + CHR(10) + CHR(13) )

    aAdd( aData, { 'codigoExterno'              , CHR(34) + AllTrim((cAliasQry)->X5_CHAVE ) + CHR(34) } )
    aAdd( aData, { 'nomeFantasia'               , CHR(34) + AllTrim((cAliasQry)->X5_DESCRI) + CHR(34) } )
    aAdd( aData, { 'razaoSocial'                , CHR(34) + AllTrim((cAliasQry)->X5_DESCRI) + CHR(34) } )
    aAdd( aData, { 'cnpj'                       , CHR(34) + '0'                              + CHR(34) } )
    aAdd( aData, { 'status'                     , CHR(34) + AllTrim( cStatus )               + CHR(34) } )
    aAdd( aData, { "fabricante"                 , 'true'                                               } )
    aAdd( aData, { "fornecedor"                 , 'true'                                               } )
 
   
    If Empty( (cAliasQry)->X5_DESCENG )
        
        aRet            := U_GENFWS( 'empresas/', 'POST', aData )
        cIdEmpresasWS   := aRet[1,1]
        cTexLog         += aRet[1,2]
    Else

        aRet            := U_GENFWS( 'empresas/'+Alltrim( (cAliasQry)->X5_DESCENG ), 'PUT', aData )
        cIdEmpresasWS   := aRet[1,1]
        cTexLog         += aRet[1,2]
        
        If Empty(cIdEmpresasWS)
            cIdEmpresasWS := Alltrim( (cAliasQry)->X5_DESCENG )
        Endif

    Endif
	
    SX5->( dbSetOrder( 1 ) )
	SX5->( dbSeek( xFilial( 'SX5' ) + 'ZX' +(cAliasQry)->X5_CHAVE ) )

    If !Empty(cIdEmpresasWS) .And. Empty( (cAliasQry)->X5_DESCENG ) // Inclusao 

        
        FwPutSX5("",'ZX',  +(cAliasQry)->X5_CHAVE, "", cIdEmpresasWS, "", "")
        
        //SX5->( RecLock( 'SX5', .F. ) )
         //   SX5->X5_DESCENG := cIdEmpresasWS
        //SX5->( MsUnlock() )

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
        
        cFile   := '\logGenesis\' + 'empresas' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'

        If !File( cFile )

            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
            Exit
        EndIf

        nTent ++
    End
EndIf

RestArea( aArea )

Return
