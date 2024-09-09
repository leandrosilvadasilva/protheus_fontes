#include 'totvs.ch'
/*/{Protheus.doc} GENJob020
	
	Integração Protheus x GENESIS - Estoque (partes e pecas)
	
	@type  Function
	@author Ednei Silva
	@since 23/07/2021
	@version P12
/*/

*******************************************************************************
User Function GENJob070( aParam )

Private nIE         := 0

RPCSetType( 3 )  // não consome licença 

RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob070] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob070] Empresa Logada: ' + aParam[ 1 ]  )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob070] Filial Logada: ' + aParam[ 2 ] )

U_GE070Run( 2 )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob070] Produtos integrados: ' + Transform( nIE, '@E 9,999,999' ) )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_SM070Job] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

//Reset Environment
RpcClearEnv()

Return



********************************************************************************
User Function GE070Run( nOpc )

Local aArea     := GetArea()
Local cQuery
Local aData
Local cAliasQry	:= GetNextAlias()
Local aRet      := {}
Local cTexLog   := ''
Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
Local cFile
Local lGet := .F.
cQuery	:= " select "

cQuery	+= " ISNULL((SELECT TOP 1 DA1MAX.DA1_PRCVEN FROM DA1010 DA1MAX WHERE DA1MAX.DA1_CODTAB='007' AND SB1.B1_COD=DA1MAX.DA1_CODPRO AND DA1MAX.D_E_L_E_T_<>'*' ORDER BY DA1MAX.DA1_ITEM DESC),0) PRECO_VENDA, "
cQuery	+= " ISNULL((SELECT AVG(B2_CM1) FROM SB2010 SB2 WHERE SB2.B2_COD=SB1.B1_COD AND SB2.D_E_L_E_T_<>'*' AND B2_LOCAL='01'),0) PRECO_CUSTO, * "
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1"

cQuery  += "     inner join " + RetSQLName("SBM") + " SBM"  
cQuery  += "         on BM_FILIAL = '" + xFilial( 'SBM' ) + "'"  
cQuery  += "         and BM_GRUPO = B1_GRUPO"  

cQuery  += "     inner join " + RetSQLName("SX5") + " SX5"  
cQuery  += "         on X5_FILIAL = '" + xFilial( 'SX5' ) + "'"  
cQuery  += "         and X5_CHAVE = B1_MARCA and X5_TABELA = 'ZX'"  
	
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_TIPO in ('M2','M3','SV') "
//cQuery	+= " and B1_FLAGEST != '' "

cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and SBM.D_E_L_E_T_ = ' '"
cQuery	+= " and SX5.D_E_L_E_T_ = ' '"
cQuery	+= " Order By B1_COD "

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )

While (cAliasQry)->( !EOF() )

    aData   := {}
    lGet := .F.
    If (cAliasQry)->B1_MSBLQL = '1'
        cStatus := 'Inativo'
    Else
        cStatus := 'Ativo'
    EndIf

    ConOut( cTexLog +=  'GE020Run - estoques: ' + (cAliasQry)->B1_COD+' '+(cAliasQry)->B1_DESC + CHR(10) + CHR(13) )

    aAdd( aData, { 'codigo'                , CHR(34) + AllTrim( (cAliasQry)->B1_COD )      + CHR(34) } )
    aAdd( aData, { 'codigoExterno'         , CHR(34) + AllTrim( (cAliasQry)->B1_COD )      + CHR(34) } )
    aAdd( aData, { 'controlarEstoque'      , 'false'                                                 } )
    aAdd( aData, { 'servico'               , IIF((cAliasQry)->B1_TIPO='SV','true','false')           } )
    aAdd( aData, { 'venda'                 , 'true'                                                  } )
    aAdd( aData, { 'consumo'               , 'true'                                                  } )
    aAdd( aData, { 'status'                , CHR(34) + AllTrim( cStatus )                  + CHR(34) } )
    aAdd( aData, { 'rgAnvisa'              , CHR(34) + AllTrim( (cAliasQry)->B1_NRANVIS)   + CHR(34) } )
    aAdd( aData, { 'descServico'           , CHR(34) + AllTrim( U_USLimpDesc((cAliasQry)->B1_DESC) )+ CHR(34) } )
    aAdd( aData, { 'descTecnica'           , CHR(34) + AllTrim( U_USLimpDesc((cAliasQry)->B1_DESC))+ CHR(34) } )
    aAdd( aData, { 'idCategoria'           , '1'                                                     } )
    aAdd( aData, { 'idFornecedor'          , AllTrim( (cAliasQry)->X5_DESCENG)                       } )
    aAdd( aData, { 'idFabricante'          , AllTrim( (cAliasQry)->X5_DESCENG)                       } )
    aAdd( aData, { 'qtd'                   , '1'                                                     } )
    if alltrim((cAliasQry)->B1_ORIGEM) != '1'
		aAdd( aData, { 'ipi'              , AllTrim(Transform(0,"999.99"))} )
	else
		aAdd( aData, { 'ipi'              , AllTrim(Transform((cAliasQry)->B1_IPI,"999.99"))} )
	endif
    aAdd( aData, { 'vlrCusto'              , AllTrim(Transform((cAliasQry)->PRECO_CUSTO,"999999999.99"))} )
    aAdd( aData, { 'vlrVenda'              , AllTrim(Transform((cAliasQry)->PRECO_VENDA,"999999999.99"))} )
    if empty((cAliasQry)->B1_IDGEST)
        aRet := U_GENFWS('estoques/','GET', AllTrim( (cAliasQry)->B1_COD ))
        if len(aRet) > 0 .and. !empty(aRet[1,1])
            lGet := .T.
            cTexLog         += aRet[1,2]
            atuGenesis((cAliasQry)->B1_COD, aRet[1,1] ,Dtos(Date())+'-'+Time())
        endif
    endif
    If !lGet .and. Empty( (cAliasQry)->B1_IDGEST )
        
        aRet            := U_GENFWS( 'estoques/', 'POST', aData )
        cIdEstoqueWS    := aRet[1,1]
        cTexLog         += aRet[1,2]
    Else
        if lGet
            aRet            := U_GENFWS( 'estoques/'+Alltrim(aRet[1,1]), 'PUT', aData )
        else
            aRet            := U_GENFWS( 'estoques/'+Alltrim( (cAliasQry)->B1_IDGEST ), 'PUT', aData )
        endif
        cIdEstoqueWS    := aRet[1,1]
        cTexLog         += aRet[1,2]
        
        If Empty(cIdEstoqueWS )
            cIdEstoqueWS  := Alltrim( (cAliasQry)->B1_IDGEST )
        Endif

    Endif
	
   // SB1->( dbSetOrder( 1 ) )
	//SB1->( dbSeek( xFilial( 'SB1' ) + (cAliasQry)->B1_COD ) )

    If !Empty(cIdEstoqueWS ) .And. Empty( (cAliasQry)->B1_IDGEST ) // Inclusao 

      //  SB1->( RecLock( 'SB1', .F. ) )
      //      SB1->B1_IDGEST := cIdEstoqueWS 
      //      SB1->B1_FLAGEST:= Dtos(Date())+'-'+Time()
      //  SB1->( MsUnlock() )
        atuGenesis((cAliasQry)->B1_COD, cIdEstoqueWS ,Dtos(Date())+'-'+Time())
    EndIf

    If !Empty(cIdEstoqueWS ) .And. !Empty( (cAliasQry)->B1_IDGEST ) // Alteracao 

        //SB1->( RecLock( 'SB1', .F. ) )
        //    SB1->B1_FLAGEST := Dtos(Date())+'-'+Time()
        //SB1->( MsUnlock() )
        
        //atuGenesis((cAliasQry)->B1_COD,'',Dtos(Date())+'-'+Time())
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
        
        cFile   := '\logGenesis\' + 'estoques' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'

        If !File( cFile )

            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
            Exit
        EndIf

        nTent ++
    End
EndIf

RestArea( aArea )

Return

static function atuGenesis(cCODPRO, cIDGENE,cFLAGGE)

Local cQuerySB1:=""
cQuerySB1:=""
cQuerySB1+=" UPDATE "+RETSQLNAME("SB1")+" SET "
cQuerySB1+=" B1_FLAGEST='"+Alltrim(cFLAGGE)+"'"
IF !EMPTY(cIDGENE)
   cQuerySB1+=" , B1_IDGEST ='"+Alltrim(cIDGENE)+"'"
ENDIF
cQuerySB1+=" WHERE     D_E_L_E_T_ <> '*' "
cQuerySB1+="       AND B1_FILIAL ='"+xFilial( 'SB1' )+"'"
cQuerySB1+="       AND B1_COD    ='"+Alltrim(cCODPRO)+"'"

nRet:=TcSqlExec(cQuerySB1)
If nRet<>0
	Alert(TCSQLERROR())
Endif



return

