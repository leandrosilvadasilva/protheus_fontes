#include 'totvs.ch'
/*/{Protheus.doc} GENJob050
	
	Integração Protheus x GENESIS - ItensMaterias
	
	@type  Function
	@author Jeferson Silva
	@since 12/04/2021
	@version P12
/*/

*******************************************************************************
User Function GENJob050( aParam )

Private nIE         := 0

RPCSetType( 3 )  // não consome licença 

RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob050] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob050] Empresa Logada: ' + aParam[ 1 ]  )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob050] Filial Logada: ' + aParam[ 2 ] )

U_GE050Run( 2 )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [GENJob050] ItensMaterias integrados: ' + Transform( nIE, '@E 9,999,999' ) )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_SM050Job] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

//Reset Environment
RpcClearEnv()

Return



********************************************************************************
User Function GE050Run( nOpc )

Local aArea     := GetArea()
Local cQuery
Local aData
Local cAliasQry	:= GetNextAlias()
Local aRet      := {}
Local cTexLog   := ''
Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
Local cFile
Local lGet := .F.

cQuery	:= " SELECT A1_IDGENES, A1_ZDGENES, B1_IDGENES, AA3_NUMSER, AA3_MSBLQL, AA3_CODPRO,  "
cQuery	+= " AA3_CODCLI, AA3_LOJA, AA3_IDGENE, AA3_FILORI, AA3_FLAGGE,B1_DESCMAR, AA3_DTVEND, AA3_DTINST,B1_UVLRC, BM_IDGENES,  "
cQuery	+= " DATEDIFF(ms, '1970-01-01 00:00:00', IIF(AA3_DTINST='','1970-01-01 00:00:00',AA3_DTINST)) AA3_DTINST_GEN, "
cQuery	+= " DATEDIFF(ms, '1970-01-01 00:00:00', IIF(AA3_DTVEND='','1970-01-01 00:00:00',AA3_DTVEND)) AA3_DTVEND_GEN,  " 
cQuery	+= " IIF (DATEDIFF(MONTH, AA3_DTVEND, AA3_DTGAR)<0,0,DATEDIFF(MONTH, AA3_DTVEND, AA3_DTGAR)) AA3_DTGAR_GEN "
cQuery	+= " FROM " + RetSqlName( 'AA3' ) + " AA3 "

cQuery  += "     inner join " + RetSQLName("SA1") + " SA1 "  
cQuery  += "         on A1_FILIAL = '" + xFilial( 'SA1' ) + "'"  
cQuery  += "         and A1_COD = AA3_CODCLI"  
cQuery  += "         and A1_LOJA = AA3_LOJA "  

cQuery  += "     inner join " + RetSQLName("SB1") + " SB1 "  
cQuery  += "         on B1_FILIAL = '" + xFilial( 'SB1' ) + "'"  
cQuery  += "         and B1_COD = AA3_CODPRO "

cQuery   += "    inner join " + RetSQLName("SBM") + " SBM "  
cQuery  += "         on BM_FILIAL = '" + xFilial( 'SBM' ) + "'"  
cQuery  += "         and BM_GRUPO = B1_GRUPO "  
	
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_TIPO in ('M1','M3') "
//cQuery	+= " and AA3_FLAGGE = '' "
cQuery	+= " and AA3.D_E_L_E_T_ = ' '"
cQuery	+= " and SA1.D_E_L_E_T_ = ' '"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and SBM.D_E_L_E_T_ = '' "
cQuery  += " AND AA3_DTINST NOT LIKE ('99%') "
cQuery  += " AND AA3_DTVEND NOT LIKE ('99%') "
cQuery  += " ORDER BY AA3.R_E_C_N_O_ "

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )

//TCSetField(cAliasQry, "B1_UVLRC", "N",15,2)
While (cAliasQry)->( !EOF() )

    aData   := {}
    lGet := .F.
    If (cAliasQry)->AA3_MSBLQL = '1'
        cStatus := 'Inativo'
    Else
        cStatus := 'Ativo'
    EndIf

    ConOut( cTexLog +=  'GE050Run - ItensMaterias: ' + (cAliasQry)->AA3_CODPRO+' '+(cAliasQry)->AA3_NUMSER +' '+(cAliasQry)->AA3_CODCLI+(cAliasQry)->AA3_LOJA  + CHR(10) + CHR(13) )

    aAdd( aData, { 'idCliente'       , CHR(34) + AllTrim( (cAliasQry)->A1_IDGENES)                      + CHR(34) } )
    aAdd( aData, { 'idSetor'         , CHR(34) + AllTrim( (cAliasQry)->A1_ZDGENES)                      + CHR(34) } )
    aAdd( aData, { 'idModelo'        , CHR(34) + AllTrim( (cAliasQry)->B1_IDGENES)                      + CHR(34) } )
    aAdd( aData, { 'idMaterial'      , CHR(34) + AllTrim( (cAliasQry)->BM_IDGENES)                      + CHR(34) } )
    aAdd( aData, { 'nserie'          , CHR(34) + AllTrim( (cAliasQry)->AA3_NUMSER)                      + CHR(34) } )
    aAdd( aData, { 'dataAquisicao'   , str((cAliasQry)->AA3_DTVEND_GEN*1000)                                           } )
    aAdd( aData, { 'dataInstalacao'  , str((cAliasQry)->AA3_DTINST_GEN*1000)                                           } )
    aAdd( aData, { 'valorUnitario'   , AllTrim(Transform((cAliasQry)->B1_UVLRC,"999999999.99"))                 } )
    aAdd( aData, { 'situacao'        , CHR(34) + 'Proprio'                                              + CHR(34) } )
    aAdd( aData, { 'garantia'        , str((cAliasQry)->AA3_DTGAR_GEN)                                            } )
    aAdd( aData, { 'marca'           , CHR(34) + AllTrim( (cAliasQry)->B1_DESCMAR)                      + CHR(34) } )
    aAdd( aData, { 'codigoExterno'   , CHR(34) + AllTrim( (cAliasQry)->AA3_CODPRO)                      + CHR(34) } )
    aAdd( aData, { 'outros'          , CHR(34) + AllTrim( (cAliasQry)->AA3_CODPRO)                      + CHR(34) } )
    //if empty((cAliasQry)->AA3_IDGENE)
    //    aRet := U_GENFWS('itens-materiais/','GET', AllTrim( (cAliasQry)->AA3_CODPRO))
    //    if len(aRet) > 0 .and. !empty(aRet[1,1])
    //        lGet := .T.
    //        atuGenesis((cAliasQry)->AA3_CODCLI, (cAliasQry)->AA3_LOJA, (cAliasQry)->AA3_CODPRO, (cAliasQry)->AA3_NUMSER, (cAliasQry)->AA3_FILORI,aRet[1,1],Dtos(Date())+'-'+Time() )
    //        cTexLog         += aRet[1,2]
    //    endif
    //endif
    //If !lGet .and. Empty( (cAliasQry)->AA3_IDGENE )
    If Empty( (cAliasQry)->AA3_IDGENE )
        
        aRet                := U_GENFWS( 'itens-materiais/', 'POST', aData )
        cIdItensMateriasWS  := aRet[1,1]
        cTexLog             += aRet[1,2]
    Else
       // if lGet
       //     aRet := U_GENFWS( 'itens-materiais/'+Alltrim(aRet[1,1]), 'PUT', aData )
       // else
            aRet := U_GENFWS( 'itens-materiais/'+Alltrim( (cAliasQry)->AA3_IDGENE ), 'PUT', aData )
       // endif
        cIdItensMateriasWS  := aRet[1,1]
        cTexLog             += aRet[1,2]
        
        If Empty(cIdItensMateriasWS)
            cIdItensMateriasWS := Alltrim( (cAliasQry)->AA3_IDGENE )
        Endif

    Endif
	
    //AA3->( dbSetOrder( 1 ) )
	//AA3->( dbSeek( xFilial( 'AA3' ) + (cAliasQry)->(AA3_CODCLI + AA3_LOJA + AA3_CODPRO + AA3_NUMSER + AA3_FILORI) ) )

    If !Empty(cIdItensMateriasWS) .And. Empty( (cAliasQry)->AA3_IDGENE ) // Inclusao 

       // AA3->( RecLock( 'AA3', .F. ) )
       //     AA3->AA3_IDGENE := cIdItensMateriasWS
       //     AA3->AA3_FLAGGE := Dtos(Date())+'-'+Time()
       // AA3->( MsUnlock() )
       atuGenesis((cAliasQry)->AA3_CODCLI, (cAliasQry)->AA3_LOJA, (cAliasQry)->AA3_CODPRO, (cAliasQry)->AA3_NUMSER, (cAliasQry)->AA3_FILORI,cIdItensMateriasWS,Dtos(Date())+'-'+Time() )

    EndIf

    If !Empty(cIdItensMateriasWS) .And. !Empty( (cAliasQry)->AA3_IDGENE ) // Alteracao 

        //AA3->( RecLock( 'AA3', .F. ) )
        //    AA3->AA3_FLAGGE := Dtos(Date())+'-'+Time()
        //AA3->( MsUnlock() )
        atuGenesis((cAliasQry)->AA3_CODCLI, (cAliasQry)->AA3_LOJA, (cAliasQry)->AA3_CODPRO, (cAliasQry)->AA3_NUMSER, (cAliasQry)->AA3_FILORI,'',Dtos(Date())+'-'+Time() )
    EndIf
    
    (cAliasQry)->(dbSkip()) 
Enddo

(cAliasQry)->(dbCloseArea())

If lLogGEN Ç

    If !ExistDir( '\logGenesis' )

        MakeDir( '\logGenesis' )
    EndIf

    nTent   := 1

    While .T.
        
        cFile   := '\logGenesis\' + 'itensmaterias' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'

        If !File( cFile )

            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
            Exit
        EndIf

        nTent ++
    End
EndIf

RestArea( aArea )

Return

static function atuGenesis(cCODCLI, cLOJA, cCODPRO, cNUMSER, cFILORI,cIDGENE,cFLAGGE )



Local cQureryAA3:=""

cNUMSER:= STRTRAN(cNUMSER, "'", "")

cQureryAA3:=""
cQureryAA3+=" UPDATE "+RETSQLNAME("AA3")+" SET "
cQureryAA3+=" AA3_FLAGGE='"+Alltrim(cFLAGGE)+"'"
IF !EMPTY(cIDGENE)
   cQureryAA3+=" ,AA3_IDGENE ='"+Alltrim(cIDGENE)+"'"
ENDIF

cQureryAA3+=" WHERE     D_E_L_E_T_ <> '*' "
cQureryAA3+="       AND AA3_FILIAL ='"+xFilial( 'AA3' )+"'"
cQureryAA3+="       AND AA3_CODCLI ='"+Alltrim(cCODCLI)+"'"
cQureryAA3+="       AND AA3_LOJA   ='"+Alltrim(cLOJA)+"'"
cQureryAA3+="       AND AA3_CODPRO ='"+Alltrim(cCODPRO)+"'"
cQureryAA3+="       AND AA3_NUMSER='"+Alltrim(cNUMSER)+"'"
cQureryAA3+="       AND AA3_FILORI ='"+Alltrim(cFILORI)+"'"

nRet:=TcSqlExec(cQureryAA3)
If nRet<>0
	Alert(TCSQLERROR())
Endif



return
