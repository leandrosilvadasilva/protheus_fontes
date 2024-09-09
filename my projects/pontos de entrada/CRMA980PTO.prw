#include "protheus.ch"
#include "parmtype.ch"
#include 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "colors.ch"

//Pontos de entrada em MVC rotina CRMA980 
//Ponto de entrada fora desse fonte: CRM980MDef()

User Function CRMA980()
//*********************
    Local aParam := PARAMIXB
    Local lRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.
    Local aClientes := {}
    Local aArea 	:= GetArea()
    Local aAreaSA1  := SA1->(GetArea())
    Local aData     := {}
    Local aRet      := {}
    Local cTexLog   := ''
    Local lLogGEN	:= GetMV( 'CI_GENLOG', .F., .T. )
    Local cFile
    Local nTent := 0
    Local cStatus := ''
    Local aBtn 		:= {}
    Local nOperation := 0
    if aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)
        nOperation := oObj:GetOperation()
        if cIdPonto == "MODELVLDACTIVE"
        elseif cIdPonto == "MODELPOS"
        elseif alltrim(cIdModel) == "SA1MASTER" .and. cIdPonto == "FORMPOS"
        elseif cIdPonto == "FORMLINEPRE"
        elseif cIdPonto == "FORMLINEPOS"
        elseif cIdPonto == "MODELCOMMITTTS" //após a gravação do modelo dentro da transação
            if nOperation == 3//Inclui
                //Envia alterações de cadastro para o WMS (AKR)
                aClientes := {{"CODPN",M->A1_COD+M->A1_LOJA},;
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
                U_MAPWMS03(aClientes)
            endif    
            if nOperation == 4//Altera
                //Envia alterações de cadastro para o WMS (AKR)
                aClientes := {{"CODPN",M->A1_COD+M->A1_LOJA},;
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
                U_MAPWMS03(aClientes)
            endif
            if nOperation !=3 .and. nOperation != 4//!Inclui .and. !Altera
                //Envia alterações de cadastro para o WMS (AKR)
                aClientes := {{"CODPN",M->A1_COD},;
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
                    {"ATIVO",.F.}; //Por ser exclusão, manda como .F.                             
                    }
                //Envia os dados do cliente para o WMS
                U_MAPWMS03(aClientes)
            endif
            if nOperation== 3 .or. nOperation == 4//altera .or. inclui
                /*if SA1->A1_PESSOA != M->A1_PESSOA .or. SA1->A1_CGC != M->A1_CGC .or. alltrim(SA1->A1_NREDUZ) != alltrim(M->A1_NREDUZ);
                    .or. alltrim(SA1->A1_NOME) != alltrim(M->A1_NOME) .or. alltrim(SA1->A1_EMAIL) != alltrim(M->A1_EMAIL);
                    .or. alltrim(SA1->A1_END) != alltrim(M->A1_END) .or. alltrim(SA1->A1_BAIRRO) != alltrim(M->A1_BAIRRO);
                    .or. alltrim(SA1->A1_MUN) != alltrim(M->A1_MUN) .or. SA1->A1_EST != M->A1_EST .or. SA1->A1_CEP != M->A1_CEP .or. SA1->A1_TEL != M->A1_TEL;
                    .or. M->A1_MSBLQL != SA1->A1_MSBLQL
                    lEnvia := .T.
                endif*/
                lEnvia := .T.
                if lEnvia .or. nOperation == 3//inclui
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
                    if /*altera*/ nOperation == 4 .and. empty(SA1->A1_IDGENES)
                        aRet := U_GENFWS( 'clientes/', 'GET', alltrim(SA1->A1_COD )+alltrim(SA1->A1_LOJA))
                        if len(aRet) > 0 .and. !empty(aRet[1,1])
                            RecLock("SA1",.F.)
                                SA1->A1_IDGENES := aRet[1,1]
                                SA1->A1_FLAGGEN := Dtos(Date())+'-'+Time()
                            SA1->(MsUnlock())
                        endif
                    endif
                    if (/*altera*/ nOperation == 4 .and. empty(SA1->A1_IDGENES)) .or. nOperation==3//inclui
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
                    if /*altera*/ nOperation == 4 .and. empty(SA1->A1_ZDGENES)
                        aRet := U_GENFWS( 'setores/', 'GET', alltrim(SA1->A1_COD )+alltrim(SA1->A1_LOJA))
                        if len(aRet) > 0 .and. !empty(aRet[1,1])
                            RecLock("SA1",.F.)
                                SA1->A1_ZDGENES := aRet[1,1]    
                                M->A1_ZDGENES := aRet[1,1]    
                            SA1->(MsUnlock())
                        endif
                    endif
                    if (/*altera*/ nOperation == 4 .and. empty(SA1->A1_ZDGENES)) .or. nOperation == 3 //inclui
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
            endif

            // DWT Luciano - 20240513
            If oObj:GetOperation() == MODEL_OPERATION_UPDATE

                If SA1->(FieldPos("A1_MSEXP")) > 0

                    RecLock("SA1",.F.)
                    SA1->A1_MSEXP = DtoS( Date() )
                    // SA1->A1_HREXP = Time()
                    SA1->(MsUnlock())
                EndIf
            EndIf
                        
            RestArea(aAreaSA1)
            RestArea(aArea)
        elseif cIdPonto == "MODELCOMMITNTTS"
            //na gravação fora da transação
        elseif cIdPonto == "FORMCOMMITTTSPRE"
            //apos a gravacao da tabela do formulario
        elseif cIdPonto == "FORMCOMMITTTSPOS"
            //apos a gravacao da tabela do formulario
        elseif cIdPonto == "MODELCANCEL"
            //cMsg := "Deseja realmente sair?"
            //xRet := ApMsgYesNo(cMsg)
        elseif cIdPonto == "BUTTONBAR"
           // Aadd(aBtn,{"BUDGET", {|| U_MAH0200() },"Hist. Cliente"})//Visualiza tabela Z80 - Historico de Cliente
            aBtn    := {{'Hist. Cliente',;                              //Titulo para o botão
                     'BUDGET',;                                         //Nome do Bitmap para exibição
                     {|| U_MAH0200()},;    //CodeBlock a ser executado
                     'Visualiza tabela Z80 - Historico de Cliente'}}      //ToolTip (Opcional)

            Return(aBtn)
        endif
    endif
Return(lRet)
