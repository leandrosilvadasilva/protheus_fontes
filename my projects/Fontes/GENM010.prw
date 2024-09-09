#include 'totvs.ch'
/*/{Protheus.doc} GENJob010
	
	Integração Protheus x GENESIS - Clientes
	
	@type  Function
	@author Jeferson Silva
	@since 12/04/2021
	@version P12

/*/
*******************************************************************************
User Function GENJob010( aParam )

Private nIE         := 0

RPCSetType( 3 )  // não consome licença 

RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob010] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob010] Empresa Logada: ' + aParam[ 1 ]  )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob010] Filial Logada: ' + aParam[ 2 ] )

U_GE010Run( 2 )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob010] Clientes integrados: ' + Transform( nIE, '@E 9,999,999' ) )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_SM010Job] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

//Reset Environment
RpcClearEnv()

Return



********************************************************************************
User Function GE010Run( nOpc )

Local aArea     := GetArea()
Local cQuery
Local aData
Local cAliasQry	:= GetNextAlias()
Local aRet      := {}
Local cTexLog   := ''
Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
Local cFile
Local lGet := .F.
cQuery	:= " SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_PESSOA,A1_CGC,A1_NREDUZ,A1_EMAIL,A1_END,A1_BAIRRO,A1_MUN,A1_EST,A1_CEP,A1_TEL,A1_MSBLQL,A1_FLAGGEN,A1_IDGENES "
cQuery	+= " FROM " + RetSqlName( 'SA1' ) + " SA1"
cQuery	+= " WHERE A1_FILIAL = '" + xFilial( 'SA1' ) + "'"
cQuery	+= " AND A1_CGC <> '' "
//cQuery	+= " AND A1_FLAGGEN = '' "
cQuery	+= " AND SA1.D_E_L_E_T_ = ' '"
dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )
while (cAliasQry)->( !EOF() )
    lGet := .F.
    aData   := {}
    if (cAliasQry)->A1_MSBLQL == '1'
        cStatus := 'Inativo'
    else
        cStatus := 'Ativo'
    endif
    ConOut( cTexLog +=  'GE010Run - Cliente: ' + (cAliasQry)->A1_COD+' '+(cAliasQry)->A1_LOJA+' '+(cAliasQry)->A1_NOME + CHR(10) + CHR(13) )
    aAdd(aData, { 'codigoExterno'              , CHR(34) + AllTrim( (cAliasQry)->A1_COD )+AllTrim( (cAliasQry)->A1_LOJA ) + CHR(34) } )
    aAdd(aData, { 'cnpj'                       , CHR(34) + IF( (cAliasQry)->A1_PESSOA='J',AllTrim( (cAliasQry)->A1_CGC) ,'') + CHR(34) } )
    aAdd(aData, { 'cpf'                        , CHR(34) + IF( (cAliasQry)->A1_PESSOA='F',AllTrim( (cAliasQry)->A1_CGC) ,'') + CHR(34) } )
    aAdd(aData, { 'nomeFantasia'               , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->A1_NREDUZ)) + CHR(34) } )
    aAdd(aData, { 'razaoSocial'                , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->A1_NOME)) + CHR(34) } )
    aAdd(aData, { 'status'                     , CHR(34) + AllTrim( cStatus )              + CHR(34) } )
    aAdd(aData, { 'email'                      , CHR(34) + AllTrim(FwCutOff(FWNoAccent((cAliasQry)->A1_EMAIL))) + CHR(34) } )
    aAdd(aData, { 'endereco'                   , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->A1_END )) + CHR(34) } )
    aAdd(aData, { 'enderecoBairro'             , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->A1_BAIRRO)) + CHR(34) } )
    aAdd(aData, { 'enderecoCidade'             , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->A1_MUN )) + CHR(34) } )
    aAdd(aData, { 'enderecoUF'                 , CHR(34) + AllTrim((cAliasQry)->A1_EST ) + CHR(34) } )
    aAdd(aData, { 'cep'                        , CHR(34) + AllTrim( (cAliasQry)->A1_CEP ) + CHR(34) } )
    aAdd(aData, { 'telefone'                   , CHR(34) + AllTrim(U_USLimpDesc((cAliasQry)->A1_TEL )) + CHR(34) } )
    if empty((cAliasQry)->A1_IDGENES)
        aRet := U_GENFWS('clientes/','GET', alltrim((cAliasQry)->A1_COD )+alltrim((cAliasQry)->A1_LOJA))
        if len(aRet) > 0 .and. !empty(aRet[1,1])
            SA1->(DBSetOrder(3))
	        if SA1->(DBSeek(xFilial('SA1')+(cAliasQry)->A1_CGC))
                SA1->( RecLock( 'SA1', .F. ) )
                    SA1->A1_IDGENES := aRet[1,1]
                    SA1->A1_FLAGGEN := Dtos(Date())+'-'+Time()
                SA1->( MsUnlock() )
                lGet := .T.
                cTexLog         += aRet[1,2]
            endif
        endif
    endif
    if !lGet .and. Empty( (cAliasQry)->A1_IDGENES )
        aRet            := U_GENFWS('clientes/','POST', aData )
        cIdClienentesWS := aRet[1,1]
        cTexLog         += aRet[1,2]
    else
        if lGet
            aRet    := U_GENFWS('clientes/'+Alltrim(aRet[1,1]), 'PUT', aData )
        else
            aRet    := U_GENFWS( 'clientes/'+Alltrim( (cAliasQry)->A1_IDGENES ), 'PUT', aData )
        endif
        cIdClienentesWS := aRet[1,1]
        cTexLog         += aRet[1,2]
        if Empty(cIdClienentesWS)
            cIdClienentesWS := Alltrim( (cAliasQry)->A1_IDGENES )
        endif
    endif
	SA1->( dbSetOrder( 3 ) )
	SA1->( dbSeek( xFilial( 'SA1' ) + (cAliasQry)->A1_CGC ) )
    if !Empty(cIdClienentesWS) .And. Empty( (cAliasQry)->A1_IDGENES ) // Inclusao 
        SA1->( RecLock( 'SA1', .F. ) )
            SA1->A1_IDGENES := cIdClienentesWS
            SA1->A1_FLAGGEN := Dtos(Date())+'-'+Time()
        SA1->( MsUnlock() )
    endif
    if !Empty(cIdClienentesWS) .And. !Empty( (cAliasQry)->A1_IDGENES ) // Alteracao 
        SA1->( RecLock( 'SA1', .F. ) )
            SA1->A1_FLAGGEN := Dtos(Date())+'-'+Time()
        SA1->( MsUnlock() )
    endif
    (cAliasQry)->(dbSkip()) 
enddo
(cAliasQry)->(dbCloseArea())
if lLogGEN
    if !ExistDir( '\logGenesis' )
      MakeDir( '\logGenesis' )
    endif
    nTent   := 1
    while .T.
        cFile   := '\logGenesis\' + 'clientes' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'
        if !File( cFile )
            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
            Exit
        endif
        nTent ++
    enddo
endif
RestArea( aArea )
Return()

