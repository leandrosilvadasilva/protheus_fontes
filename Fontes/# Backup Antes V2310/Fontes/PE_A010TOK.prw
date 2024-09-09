#include 'protheus.ch'
#Include 'rwmake.ch'
#include 'totvs.ch'
//Ponto de entrada na confirmacao de inclusão de modelos/produtos

User Function A010TOK()
**********************
   // Local aArea 	:= GetArea()
   // Local aAreaSB1  := SB1->(GetArea())
    Local aData     := {}
    Local aRet      := {}
    Local cTexLog   := ''
    Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
    Local cFile
    Local nTent := 0
    Local lGet := .F.
    Local cStatus := ''
    Local cAliasQry := ""
    Local nvlrCusto := 0
    Local nvlrVenda := 0
    if inclui .or. altera
        if M->B1_MARCA == '41' .and. empty(M->B1_CODGTIN)
            msginfo("Para produtos da marca: "+alltrim(M->B1_DESCMAR)+", é obrigatório informar o código EAN do produto!")
            Return(.F.)
        endif
    endif
    if inclui
        if alltrim(M->B1_TIPO) $ 'M1/M2/M3'
            DbSelectArea("SBM")
            SBM->(DbSetOrder(1))
            if !empty(M->B1_GRUPO) .and. SBM->(DBSeek(xFilial("SBM")+M->B1_GRUPO))
                if empty(SBM->BM_IDGENES)
                    aRet := U_GENFWS( 'materiais/', 'GET', M->B1_GRUPO)
                    if len(aRet) > 0 .and. !empty(aRet[1,1])
                        RecLock('SBM',.F.)
                            SBM->BM_IDGENES := aRet[1,1]
                            SBM->BM_FLAGGEN := Dtos(Date())+'-'+Time()
                        SBM->(MsUnlock())
                        lGet := .T.
                    endif
                    cTexLog += aRet[1,2]
                    if !lGet
                        aData   := {}
                        if SBM->BM_MSBLQL = '1'
                            cStatus := 'Inativo'
                        else
                            cStatus := 'Ativo'
                        endif
                        ConOut(cTexLog +=  'GE030Run - Materiais: ' + SBM->BM_GRUPO+' '+SBM->BM_DESC + CHR(10) + CHR(13) )
                        aAdd( aData, { 'codigoExterno'              , CHR(34) + AllTrim(SBM->BM_GRUPO ) + CHR(34) } )
                        aAdd( aData, { 'nome'                       , CHR(34) + AllTrim( U_USLimpDesc(SBM->BM_DESC))   + CHR(34) } )
                        aAdd( aData, { 'status'                     , CHR(34) + AllTrim( cStatus )               + CHR(34) } )
                        aAdd( aData, { 'grauRisco'                  , CHR(34) + 'Medio'                          + CHR(34) } )
                        aRet := U_GENFWS( 'materiais/', 'POST', aData )
                        if len(aRet) > 0 .and. !empty(aRet[1,1])
                            RecLock('SBM',.F.)
                                SBM->BM_IDGENES := aRet[1,1]
                                SBM->BM_FLAGGEN := Dtos(Date())+'-'+Time()
                            SBM->(MsUnlock())
                        endif
                        cTexLog += aRet[1,2]
                    endif
                endif
                if !empty(SBM->BM_IDGENES)
                    if M->B1_MSBLQL = '1'
                        cStatus := 'Inativo'
                    else
                        cStatus := 'Ativo'
                    endif
                    aData   := {}
                    ConOut( cTexLog +=  'GE020Run - modelos: ' + M->B1_COD+' '+M->B1_DESC + CHR(10) + CHR(13) )
                    aAdd( aData, { 'codigoExterno'         , CHR(34) + AllTrim(M->B1_COD )      + CHR(34) } )
                    aAdd( aData, { 'nome'                  , CHR(34) + AllTrim(U_USLimpDesc(M->B1_DESC))+CHR(34) } )
                    aAdd( aData, { 'idEmpresaFabricante'   , CHR(34) + AllTrim(M->X5_DESCENG)   + CHR(34) } )
                    aAdd( aData, { 'idMaterial'            , CHR(34) + AllTrim(SBM->BM_IDGENES)   + CHR(34) } )
                    aAdd( aData, { 'status'                , CHR(34) + AllTrim(cStatus )        + CHR(34) } )
                    aAdd( aData, { 'nranvisa'              , CHR(34) + AllTrim(M->B1_NRANVIS)   + CHR(34) } )
                    aRet := U_GENFWS( 'modelos/', 'POST', aData )
                    if len(aRet) > 0 .and. !empty(aRet[1,1])
                        //RecLock("SB1",.F.)
                            M->B1_IDGENES := aRet[1][1]
                            M->B1_FLAGGEN := Dtos(Date())+'-'+Time()                        
                        //SB1->(MsUnlock())
                    endif
                    cTexLog += aRet[1,2]
                else
                    ConOut( cTexLog +=  'GE020Run - modelos: grupo ' + M->B1_grupo+' nao localizado ' + CHR(10) + CHR(13) )
                endif
                if lLogGEN
                    if !ExistDir( '\logGenesis' )
                        MakeDir( '\logGenesis' )
                    endif
                    nTent   := 1
                    while .T.
                        cFile   := '\logGenesis\'+'modelos_materiais' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'
                        if !File( cFile )
                            MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
                            Exit
                        endif
                        nTent ++
                    enddo
                endif
            endif
        endif
        if alltrim(M->B1_TIPO) $ 'M2/M3/SV'
            If M->B1_MSBLQL = '1'
                cStatus := 'Inativo'
            Else
                cStatus := 'Ativo'
            EndIf
            ConOut( cTexLog +=  'GE020Run - estoques: ' + M->B1_COD+' '+M->B1_DESC + CHR(10) + CHR(13) )
            aAdd( aData, { 'codigo'                , CHR(34) + AllTrim(M->B1_COD )      + CHR(34) } )
            aAdd( aData, { 'codigoExterno'         , CHR(34) + AllTrim(M->B1_COD )      + CHR(34) } )
            aAdd( aData, { 'controlarEstoque'      , 'false'                                                 } )
            aAdd( aData, { 'servico'               , IIF(M->B1_TIPO='SV','true','false')           } )
            aAdd( aData, { 'venda'                 , 'true'                                                  } )
            aAdd( aData, { 'consumo'               , 'true'                                                  } )
            aAdd( aData, { 'status'                , CHR(34) + AllTrim( cStatus )                  + CHR(34) } )
            aAdd( aData, { 'rgAnvisa'              , CHR(34) + AllTrim( M->B1_NRANVIS)   + CHR(34) } )
            aAdd( aData, { 'descServico'           , CHR(34) + AllTrim( U_USLimpDesc(M->B1_DESC) )+ CHR(34) } )
            aAdd( aData, { 'descTecnica'           , CHR(34) + AllTrim( U_USLimpDesc(M->B1_DESC))+ CHR(34) } )
            aAdd( aData, { 'idCategoria'           , '1'                                                     } )
            aAdd( aData, { 'idFornecedor'          , AllTrim(Posicione("SX5",1,xFilial("SX5")+"ZX"+M->B1_MARCA,"X5_DESCENG"))                       } )
            aAdd( aData, { 'idFabricante'          , AllTrim(Posicione("SX5",1,xFilial("SX5")+"ZX"+M->B1_MARCA,"X5_DESCENG"))                       } )
            if alltrim(M->B1_ORIGEM) != '1'
				aAdd( aData, { 'ipi'                   , AllTrim(Transform(0,"999.99"))} )
			else	
				aAdd( aData, { 'ipi'                   , AllTrim(Transform(M->B1_IPI,"999.99"))} )
			endif
            aAdd( aData, { 'qtd'                   , '1'                                                     } )
            aAdd( aData, { 'vlrCusto'              , AllTrim(Transform(0,"999999999.99"))} )
            aAdd( aData, { 'vlrVenda'              , AllTrim(Transform(0,"999999999.99"))} )
            aRet := U_GENFWS('estoques/','GET', AllTrim(M->B1_COD ))
            if len(aRet) > 0 .and. !empty(aRet[1,1])
                cTexLog         += aRet[1,2]
                M->B1_IDGEST := aRet[1,1]
                M->B1_FLAGEST:= Dtos(Date())+'-'+Time()
                U_GENFWS( 'estoques/'+Alltrim(aRet[1,1]), 'PUT', aData )
                cTexLog         += aRet[1,2]
            else
                cTexLog += aRet[1,2]
                aRet            := U_GENFWS( 'estoques/', 'POST', aData )
                M->B1_IDGEST := aRet[1,1]
                M->B1_FLAGEST:= Dtos(Date())+'-'+Time()
                cTexLog         += aRet[1,2]
            endif
        endif
    /*elseif altera 
        if alltrim(M->B1_TIPO) $ 'M1/M2/M3' //.and. (alltrim(M->B1_DESC) != alltrim(SB1->B1_DESC) .or. alltrim(SB1->B1_DESC) != alltrim(M->B1_DESC) .or. M->B1_GRUPO != SB1->B1_GRUPO .or. M->B1_NRANVIS != SB1->B1_NRANVIS .or. M->B1_MSBLQL != SB1->B1_MSBLQL)
            DbSelectArea("SBM")
            SBM->(DbSetOrder(1))
            if !empty(M->B1_GRUPO) .and. SBM->(DBSeek(xFilial("SBM")+M->B1_GRUPO))
                if empty(SBM->BM_IDGENES)
                    //aRet := U_GENFWS( 'materiais/', 'GET', SB1->B1_GRUPO)
                    //if len(aRet) > 0 .and. !empty(aRet[1,1])
                    //    RecLock('SBM',.F.)
                    //        SBM->BM_IDGENES := aRet[1,1]
                    //        SBM->BM_FLAGGEN := Dtos(Date())+'-'+Time()
                    //    SBM->(MsUnlock())
                    //    lGet := .T.
                    //endif
                    if !lGet
                        aData   := {}
                        if SBM->BM_MSBLQL = '1'
                            cStatus := 'Inativo'
                        else
                            cStatus := 'Ativo'
                        endif
                        ConOut(cTexLog +=  'GE030Run - Materiais: ' + SBM->BM_GRUPO+' '+SBM->BM_DESC + CHR(10) + CHR(13) )
                        aAdd( aData, { 'codigoExterno'              , CHR(34) + AllTrim(SBM->BM_GRUPO ) + CHR(34) } )
                        aAdd( aData, { 'nome'                       , CHR(34) + AllTrim( U_USLimpDesc(SBM->BM_DESC))   + CHR(34) } )
                        aAdd( aData, { 'status'                     , CHR(34) + AllTrim( cStatus )               + CHR(34) } )
                        aAdd( aData, { 'grauRisco'                  , CHR(34) + 'Medio'                          + CHR(34) } )
                        aRet := U_GENFWS( 'materiais/', 'POST', aData )
                        if len(aRet) > 0 .and. !empty(aRet[1,1])
                            RecLock('SBM',.F.)
                                SBM->BM_IDGENES := aRet[1,1]
                                SBM->BM_FLAGGEN := Dtos(Date())+'-'+Time()
                            SBM->(MsUnlock())
                        endif
                        cTexLog += aRet[1,2]
                    endif
                endif
                if !empty(SBM->BM_IDGENES)
                    If M->B1_MSBLQL == '1'
                        cStatus := 'Inativo'
                    Else
                        cStatus := 'Ativo'
                    EndIf
                    ConOut( cTexLog +=  'GE020Run - modelos: ' + M->B1_COD+' '+M->B1_DESC + CHR(10) + CHR(13) )
                    aAdd( aData, { 'codigoExterno'         , CHR(34) + AllTrim(M->B1_COD )      + CHR(34) } )
                    aAdd( aData, { 'nome'                  , CHR(34) + AllTrim(U_USLimpDesc(M->B1_DESC))+CHR(34) } )
                    aAdd( aData, { 'idEmpresaFabricante'   , CHR(34) + AllTrim(Posicione("SX5",1,xFilial("SX5")+"ZX"+M->B1_MARCA,"X5_DESCENG"))   + CHR(34) } )
                    aAdd( aData, { 'idMaterial'            , CHR(34) + AllTrim(SBM->BM_IDGENES)   + CHR(34) } )
                    aAdd( aData, { 'status'                , CHR(34) + AllTrim(cStatus)        + CHR(34) } )
                    aAdd( aData, { 'nranvisa'              , CHR(34) + AllTrim(M->B1_NRANVIS)   + CHR(34) } )
                    if empty(M->B1_IDGENES)
                       aRet := U_GENFWS( 'modelos/', 'GET', M->B1_COD)
                        if len(aRet) > 0 .and. !empty(aRet[1,1])
                            //RecLock("SB1",.F.)
                                SB1->B1_IDGENES := aRet[1][1]
                                SB1->B1_FLAGGEN := Dtos(Date())+'-'+Time()                        
                            //SB1->(MsUnlock())
                            lGet := .T.
                        endif
                    endif
                    If empty(M->B1_IDGENES )
                        aRet := U_GENFWS( 'modelos/', 'POST', aData )
                        if len(aRet) > 0 .and. !empty(aRet[1,1])
                            //RecLock("SB1",.F.)
                                SB1->B1_IDGENES := aRet[1][1]
                                SB1->B1_FLAGGEN := Dtos(Date())+'-'+Time()                        
                            //SB1->(MsUnlock())
                        endif
                        cTexLog += aRet[1,2]
                    else
                        //  if lGet
                        //     aRet := U_GENFWS( 'modelos/'+Alltrim(aRet[1,1]),'PUT',aData )    
                        // else
                            aRet := U_GENFWS( 'modelos/'+Alltrim(M->B1_IDGENES ),'PUT',aData )    
                        //endif
                        if len(aRet) > 0 .and. !empty(aRet[1,1])
                            //RecLock("SB1",.F.)
                            //      SB1->B1_IDGENES := aRet[1][1]
                                SB1->B1_FLAGGEN := Dtos(Date())+'-'+Time()                        
                            //SB1->(MsUnlock())
                        endif
                        cTexLog += aRet[1,2]
                    endif
                endif
            endif
        endif*/
        if alltrim(M->B1_TIPO) $ 'M2/M3/SV' //.and. (alltrim(M->B1_TIPO) != alltrim(SB1->B1_TIPO) .or. AllTrim( M->B1_NRANVIS) != AllTrim(SB1->B1_NRANVIS);
                                                 //       .or. alltrim(M->B1_DESC) != alltrim(SB1->B1_DESC) .or. alltrim(SB1->B1_DESC) != alltrim(M->B1_DESC) )
            If M->B1_MSBLQL = '1'
                cStatus := 'Inativo'
            Else
                cStatus := 'Ativo'
            EndIf
            cAliasQry	:= GetNextAlias()
            cQuery	:= " SELECT TOP 1 DA1MAX.DA1_PRCVEN PRCVEN FROM DA1010 DA1MAX WHERE DA1MAX.DA1_CODTAB='007' AND DA1MAX.DA1_CODPRO = '"+M->B1_COD+"' AND DA1MAX.D_E_L_E_T_<>'*' ORDER BY DA1MAX.DA1_ITEM DESC "
            dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )
            if (cAliasQry)->(!EOF())
                nvlrVenda := (cAliasQry)->PRCVEN
            else
                nvlrVenda := 0    
            endif
            cAliasQry	:= GetNextAlias()
            cQuery	:= " SELECT AVG(B2_CM1) CUSTO FROM SB2010 SB2 WHERE SB2.B2_COD='"+M->B1_COD+"' AND SB2.D_E_L_E_T_<>'*' AND B2_LOCAL='01' AND D_E_L_E_T_ = ''  "
            dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .f., .t. )
            if (cAliasQry)->(!EOF())
                nvlrCusto := (cAliasQry)->CUSTO
            else
                nvlrCusto := 0    
            endif
            ConOut( cTexLog +=  'GE020Run - estoques: ' + M->B1_COD+' '+M->B1_DESC + CHR(10) + CHR(13) )
            aAdd( aData, { 'codigo'                , CHR(34) + AllTrim(M->B1_COD )      + CHR(34) } )
            aAdd( aData, { 'codigoExterno'         , CHR(34) + AllTrim(M->B1_COD )      + CHR(34) } )
            aAdd( aData, { 'controlarEstoque'      , 'false'                                                 } )
            aAdd( aData, { 'servico'               , IIF(M->B1_TIPO='SV','true','false')           } )
            aAdd( aData, { 'venda'                 , 'true'                                                  } )
            aAdd( aData, { 'consumo'               , 'true'                                                  } )
            aAdd( aData, { 'status'                , CHR(34) + AllTrim( cStatus )                  + CHR(34) } )
            aAdd( aData, { 'rgAnvisa'              , CHR(34) + AllTrim( M->B1_NRANVIS)   + CHR(34) } )
            aAdd( aData, { 'descServico'           , CHR(34) + AllTrim( U_USLimpDesc(M->B1_DESC) )+ CHR(34) } )
            aAdd( aData, { 'descTecnica'           , CHR(34) + AllTrim( U_USLimpDesc(M->B1_DESC))+ CHR(34) } )
            aAdd( aData, { 'idCategoria'           , '1'                                                     } )
            aAdd( aData, { 'idFornecedor'          , AllTrim(Posicione("SX5",1,xFilial("SX5")+"ZX"+M->B1_MARCA,"X5_DESCENG"))                       } )
            aAdd( aData, { 'idFabricante'          , AllTrim(Posicione("SX5",1,xFilial("SX5")+"ZX"+M->B1_MARCA,"X5_DESCENG"))                       } )
            if alltrim(M->B1_ORIGEM) != '1'
				aAdd( aData, { 'ipi'                   , AllTrim(Transform(0,"999.99"))} )
			else	
				aAdd( aData, { 'ipi'                   , AllTrim(Transform(M->B1_IPI,"999.99"))} )
			endif
			aAdd( aData, { 'qtd'                   , '1'                                                     } )
            aAdd( aData, { 'vlrCusto'              , AllTrim(Transform(nVlrCusto,"999999999.99"))} )
            aAdd( aData, { 'vlrVenda'              , AllTrim(Transform(nvlrVenda,"999999999.99"))} )
            aRet := U_GENFWS('estoques/','GET', AllTrim(M->B1_COD ))
            if len(aRet) > 0 .and. !empty(aRet[1,1])
                cTexLog         += aRet[1,2]
                M->B1_IDGEST := aRet[1,1]
                M->B1_FLAGEST:= Dtos(Date())+'-'+Time()
                U_GENFWS( 'estoques/'+Alltrim(aRet[1,1]), 'PUT', aData )
                cTexLog         += aRet[1,2]
            else
                cTexLog += aRet[1,2]
                aRet            := U_GENFWS( 'estoques/', 'POST', aData )
                M->B1_IDGEST := aRet[1,1]
                M->B1_FLAGEST:= Dtos(Date())+'-'+Time()
                cTexLog         += aRet[1,2]
            endif
        endif
    endif
    if lLogGEN .and. (inclui .or. altera)
        if !ExistDir( '\logGenesis' )
            MakeDir( '\logGenesis' )
        endif
        nTent   := 1
        while .T.
            cFile   := '\logGenesis\'+'estoque_modelos' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'
            if !File( cFile )
                MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
                Exit
            endif
            nTent ++
        enddo
    endif
    //RestArea(aAreaSB1)
    //RestArea(aArea)
Return(.T.)
