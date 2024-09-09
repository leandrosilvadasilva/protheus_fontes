#include 'protheus.ch'
#Include 'rwmake.ch'
#include 'totvs.ch'
//Ponto de entrada no ok de alteração da base instalada

User Function At040TOk()
**********************
    Local lRet := .F.
    Local aArea     := GetArea()
    Local aData
    Local aRet      := {}
    Local cTexLog   := ''
    Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
    Local cFile
    //if alltrim(SB1->B1_TIPO) !='M1'
    //    Return(lRet)
    //endif
    if alltrim(SB1->B1_TIPO) $ 'M1/M2/M3' .and. (inclui .or. altera)
        DbSelectArea("SBM")
        SBM->(DbSetOrder(1))
        if !SBM->(DBSeek(xFilial("SBM")+SB1->B1_GRUPO))
            Return(lRet)    
        endif
        aData   := {}
        if M->AA3_MSBLQL = '1'
            cStatus := 'Inativo'
        else
            cStatus := 'Ativo'
        endif
        ConOut( cTexLog +=  'GE050Run - ItensMaterias: ' +M->AA3_CODPRO+' '+M->AA3_NUMSER +' '+M->AA3_CODCLI+M->AA3_LOJA  + CHR(10) + CHR(13) )
        aAdd( aData, { 'idCliente'       , CHR(34) + AllTrim(SA1->A1_IDGENES)                      + CHR(34) } )
        aAdd( aData, { 'idSetor'         , CHR(34) + AllTrim(SA1->A1_ZDGENES)                      + CHR(34) } )
        aAdd( aData, { 'idModelo'        , CHR(34) + AllTrim(SB1->B1_IDGENES)                      + CHR(34) } )
        aAdd( aData, { 'idMaterial'      , CHR(34) + AllTrim(SBM->BM_IDGENES)                      + CHR(34) } )
        aAdd( aData, { 'nserie'          , CHR(34) + AllTrim(M->AA3_NUMSER)                        + CHR(34) } )
        //aAdd( aData, { 'dataAquisicao'   , str(if(empty(M->AA3_DTVEND),0,DateDiffDay(sTod('19700101'),(M->AA3_DTVEND))*36000))})
        //aAdd( aData, { 'dataInstalacao'  , str(if(empty(M->AA3_DTINST),0,DateDiffDay(sTod('19700101'),(M->AA3_DTINST))*36000))})
        aAdd( aData, { 'dataAquisicao'   , if(empty(M->AA3_DTVEND),0,alltrim(str(val(FWTimeStamp(4,M->AA3_DTVEND,"00:00:00"))*1000)))})
        aAdd( aData, { 'dataInstalacao'  , if(empty(M->AA3_DTINST),0,alltrim(str(val(FWTimeStamp(4,M->AA3_DTINST,"00:00:00"))*1000)))})
        aAdd( aData, { 'valorUnitario'   , AllTrim(Transform(SB1->B1_UVLRC,"999999999.99"))                 } )
        aAdd( aData, { 'situacao'        , CHR(34) + 'Proprio'                                              + CHR(34) } )
        //aAdd( aData, { 'garantia'        , str(if(empty(M->AA3_DTGAR),0,DateDiffDay(sTod('19700101'),(M->AA3_DTGAR))*36000))})
        aAdd( aData, { 'garantia'        , if(empty(M->AA3_DTGAR).or.empty(M->AA3_DTINST),0,alltrim(str(DateDiffMonth( M->AA3_DTINST , M->AA3_DTGAR ))))})
        aAdd( aData, { 'marca'           , CHR(34) + AllTrim(SB1->B1_DESCMAR)                      + CHR(34) } )
        aAdd( aData, { 'codigoExterno'   , CHR(34) + AllTrim(M->AA3_CODPRO)                      + CHR(34) } )
        aAdd( aData, { 'outros'          , CHR(34) + AllTrim(M->AA3_CODPRO)                      + CHR(34) } )
        //aRet := U_GENFWS('itens-materiais/','GET', AllTrim(M->AA3_CODPRO))
        if altera .and. !empty(M->AA3_IDGENE) //len(aRet) > 0 .and. !empty(aRet[1,1])
            //M->AA3_IDGENE := aRet[1,1]
            aRet := U_GENFWS( 'itens-materiais/'+alltrim(M->AA3_IDGENE), 'PUT', aData )
            cTexLog += aRet[1,2]
            M->AA3_FLAGGE := Dtos(Date())+'-'+Time()
        else
            aRet := U_GENFWS( 'itens-materiais/', 'POST', aData )
            if len(aRet) > 0 .and. !empty(aRet[1,1])
                M->AA3_FLAGGE := Dtos(Date())+'-'+Time()
                M->AA3_IDGENE := aRet[1,1]
            endif
            cTexLog += aRet[1,2]
        endif
    endif
    if lLogGEN .and. alltrim(SB1->B1_TIPO) $ 'M1/M2/M3' .and. (inclui .or. altera)
        if !ExistDir( '\logGenesis' )
            MakeDir( '\logGenesis' )
        endif
        nTent   := 1
        while .T.
            cFile   := '\logGenesis\'+'itens-materiais' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'
            if !File( cFile )
                MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
                Exit
            endif
            nTent ++
        enddo
    endif
    RestArea(aArea)
    lRet := .T.
Return(lRet)
