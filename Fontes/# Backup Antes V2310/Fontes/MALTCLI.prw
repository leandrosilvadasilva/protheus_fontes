#INCLUDE 'TOTVS.ch'

/*--------------------------------------------------------------------------------------------------*
| Func:  MALTCLI()                                                     							    |
| Autor: Valmor Marchi                                              								|
| Data:  08/02/2022                                                   								|
| Desc:  Este ponto de entrada pertence à rotina de cadastro de clientes, MATA030. Ele é executado  |
|        após a gravação das ALTERAÇÕES.															|
|		 Documentação: https://tdn.totvs.com/display/public/PROT/MALTCLI          					|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/

User Function MALTCLI()
    Local _aClientes := {}
    Local aArea 	:= GetArea()
    Local aAreaSA1  := SA1->(GetArea())
    Local aData     := {}
    Local aRet      := {}
    Local cTexLog   := ''
    Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
    Local cFile
    Local nTent := 0
    Local cStatus := ''
    
    //Envia alterações de cadastro para o WMS (AKR)
    _aClientes := {{"CODPN",M->A1_COD+M->A1_LOJA},;
                   {"RAZAO",M->A1_NOME},;
                   {"TIPO","C"},;
                   {"CODGRP",1},;
                   {"NOMEGRP","GERAL"},;
                   {"UF",M->A1_EST},;  
                   {"CIDADE",M->A1_MUN},;
                   {"BAIRRO",M->A1_BAIRRO},;  
                   {"RUA",M->A1_END},;  
                   {"CEP",M->A1_CEP},;  
                   {"FONE",M->A1_TEL},;  
                   {"CGC",M->A1_CGC},;  
                   {"IE",M->A1_INSCR},;  
                   {"IM",M->A1_INSCRM},;   
                   {"CONDPAG",M->A1_COND},;
                   {"ATIVO",IIF(M->A1_MSBLQL <> '1',.T.,.F.)};                             
                  }
        
        //Envia os dados do cliente para o WMS
        U_MAPWMS03(_aClientes)
        if altera .and. l030tokEn
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

    RestArea(aAreaSA1)
    RestArea(aArea)


Return
