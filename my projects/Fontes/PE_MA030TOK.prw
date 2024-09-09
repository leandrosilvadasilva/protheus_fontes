#include 'protheus.ch'
#Include 'rwmake.ch'
#include 'totvs.ch'
//Ponto de entrada na confirmacao de inclusão do cliente ou alteracao

User Function MA030TOK()
**********************
    Local aArea 	:= GetArea()
    Local aAreaSA1  := SA1->(GetArea())
    Local aData     := {}
    Local aRet      := {}
    Local cTexLog   := ''
    Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
    Local cFile
    Local nTent := 0
    Local cStatus := ''
    Local lEnvia := .F.
    Public l030tokEn := .F.
    if altera
        if SA1->A1_PESSOA != M->A1_PESSOA .or. SA1->A1_CGC != M->A1_CGC .or. alltrim(SA1->A1_NREDUZ) != alltrim(M->A1_NREDUZ);
           .or. alltrim(SA1->A1_NOME) != alltrim(M->A1_NOME) .or. alltrim(SA1->A1_EMAIL) != alltrim(M->A1_EMAIL);
           .or. alltrim(SA1->A1_END) != alltrim(M->A1_END) .or. alltrim(SA1->A1_BAIRRO) != alltrim(M->A1_BAIRRO);
           .or. alltrim(SA1->A1_MUN) != alltrim(M->A1_MUN) .or. SA1->A1_EST != M->A1_EST .or. SA1->A1_CEP != M->A1_CEP .or. SA1->A1_TEL != M->A1_TEL;
           .or. M->A1_MSBLQL != SA1->A1_MSBLQL
           lEnvia := .T.
        endif
    endif
    if (altera .and. lEnvia) .or. inclui
        ConOut( cTexLog +=  'GE010Run - Cliente: ' + M->A1_COD+' '+M->A1_LOJA+' '+M->A1_NOME + CHR(10) + CHR(13) )
        If M->A1_MSBLQL == '1'
            cStatus := 'Inativo'
        Else
            cStatus := 'Ativo'
        EndIf
        aAdd( aData, { 'codigoExterno'              , CHR(34) + AllTrim(M->A1_COD )+AllTrim(M->A1_LOJA ) + CHR(34) } )
        aAdd( aData, { 'cnpj'                       , CHR(34) + if(M->A1_PESSOA=='J',AllTrim(M->A1_CGC) ,'') + CHR(34) } )
        aAdd( aData, { 'cpf'                        , CHR(34) + if(M->A1_PESSOA=='F',AllTrim(M->A1_CGC) ,'') + CHR(34) } )
        aAdd( aData, { 'nomeFantasia'               , CHR(34) + AllTrim(U_USLimpDesc(M->A1_NREDUZ)) + CHR(34) } )
        aAdd( aData, { 'razaoSocial'                , CHR(34) + AllTrim(U_USLimpDesc(M->A1_NOME)) + CHR(34) } )
        aAdd( aData, { 'status'                     , CHR(34) + AllTrim( cStatus )              + CHR(34) } )
        aAdd( aData, { 'email'                      , CHR(34) + AllTrim(FwCutOff(FWNoAccent(M->A1_EMAIL))) + CHR(34) } )
        aAdd( aData, { 'endereco'                   , CHR(34) + AllTrim(U_USLimpDesc(M->A1_END )) + CHR(34) } )
        aAdd( aData, { 'enderecoBairro'             , CHR(34) + AllTrim(U_USLimpDesc(M->A1_BAIRRO)) + CHR(34) } )
        aAdd( aData, { 'enderecoCidade'             , CHR(34) + AllTrim(U_USLimpDesc(M->A1_MUN )) + CHR(34) } )
        aAdd( aData, { 'enderecoUF'                 , CHR(34) + AllTrim(M->A1_EST ) + CHR(34) } )
        aAdd( aData, { 'cep'                        , CHR(34) + AllTrim(M->A1_CEP ) + CHR(34) } )
        aAdd( aData, { 'telefone'                   , CHR(34) + AllTrim(U_USLimpDesc(M->A1_TEL )) + CHR(34) } )
        if inclui
            //Cliente
            aRet  := U_GENFWS( 'clientes/', 'POST', aData )
            cTexLog         += aRet[1,2]
            if len(aRet) > 0 .and. !empty(aRet[1,1])
                M->A1_IDGENES := aRet[1,1]
                M->A1_FLAGGEN := Dtos(Date())+'-'+Time()
            endif
            //Setor
            aData := {}
            aRet := {}
            aAdd( aData,{'codigoExterno'              , CHR(34) + AllTrim(M->A1_COD)+AllTrim(M->A1_LOJA ) + CHR(34) } )
            aAdd( aData,{'nome'                       , CHR(34) + AllTrim(U_USLimpDesc(M->A1_NOME)) + CHR(34) } )
            aAdd( aData,{'idCliente'                  , CHR(34) + AllTrim(M->A1_IDGENES ) + CHR(34) } )
            aRet  := U_GENFWS( 'setores/', 'POST', aData )
            cTexLog += aRet[1,2]
            if len(aRet) > 0 .and. !empty(aRet[1,1])
                M->A1_ZDGENES := aRet[1,1]
            endif
        elseif !GetMV('MV_TESTTI')
            //cliente
            aRet := {}
            if empty(SA1->A1_IDGENES)
                aRet := U_GENFWS( 'clientes/', 'GET', alltrim(SA1->A1_COD )+alltrim(SA1->A1_LOJA))
                if len(aRet) > 0 .and. !empty(aRet[1,1])
                    RecLock("SA1",.F.)
                        SA1->A1_IDGENES := aRet[1,1]
                        SA1->A1_FLAGGEN := Dtos(Date())+'-'+Time()
                    SA1->(MsUnlock())
                endif
            endif
            if empty(SA1->A1_IDGENES)
                aRet  := U_GENFWS( 'clientes/', 'POST', aData )
                cTexLog         += aRet[1,2]
                if len(aRet) > 0 .and. !empty(aRet[1,1])
                    RecLock("SA1",.F.)
                        SA1->A1_IDGENES := aRet[1,1]
                        SA1->A1_FLAGGEN := Dtos(Date())+'-'+Time()
                    SA1->(MsUnlock())
                endif
            else
                aRet    := U_GENFWS( 'clientes/'+Alltrim(SA1->A1_IDGENES),'PUT',aData )
                if len(aRet) > 0 .and. !empty(aRet[1,1])
                    RecLock("SA1",.F.)
                        SA1->A1_FLAGGEN := Dtos(Date())+'-'+Time()
                    SA1->(MsUnlock())
                endif
                cTexLog         += aRet[1,2]
            endif
            //setor
            aData := {}
            aAdd( aData,{'codigoExterno'              , CHR(34) + AllTrim(SA1->A1_COD )+AllTrim(SA1->A1_LOJA ) + CHR(34) } )
            aAdd( aData,{'nome'                       , CHR(34) + AllTrim(U_USLimpDesc(SA1->A1_NOME)) + CHR(34) } )
            aAdd( aData,{'idCliente'                  , CHR(34) + AllTrim(SA1->A1_IDGENES ) + CHR(34) } )
            if empty(SA1->A1_ZDGENES)
                aRet := U_GENFWS( 'setores/', 'GET', alltrim(SA1->A1_COD )+alltrim(SA1->A1_LOJA))
                if len(aRet) > 0 .and. !empty(aRet[1,1])
                    RecLock("SA1",.F.)
                        SA1->A1_ZDGENES := aRet[1,1]    
                        M->A1_ZDGENES := aRet[1,1]    
                    SA1->(MsUnlock())
                endif
            endif
            if empty(SA1->A1_ZDGENES)
                aRet  := U_GENFWS( 'setores/','POST', aData )
                cTexLog += aRet[1,2]
                if len(aRet) > 0 .and. !empty(aRet[1,1])
                    RecLock("SA1",.F.)
                        SA1->A1_ZDGENES := aRet[1,1]
                        M->A1_ZDGENES := aRet[1,1]    
                    SA1->(MsUnlock())
                endif
            else
                aRet := U_GENFWS( 'setores/'+Alltrim(SA1->A1_ZDGENES ),'PUT', aData )
                cTexLog += aRet[1,2]
            endif*/
        endif
        if lLogGEN
            if !ExistDir( '\logGenesis' )
                MakeDir( '\logGenesis' )
            endif
            nTent   := 1
            while .T.
                cFile   := '\logGenesis\'+'setores_clientes' + '_' + DtoS( Date() ) + '_' + StrTran( Time(), ':' ) + '_' + StrZero( nTent, 3 ) + '.log'
                if !File( cFile )
                    MemoWrite( cFile, cTexLog + CHR(10) + CHR(13) )
                    Exit
                endif
                nTent ++
            enddo
        endif
    endif
    l030tokEn := lEnvia
    RestArea(aAreaSA1)
    RestArea(aArea)
Return(.T.)
