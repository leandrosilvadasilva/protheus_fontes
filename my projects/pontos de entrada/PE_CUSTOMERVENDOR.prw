//Bibliotecas
#Include "Protheus.ch" 


User Function CUSTOMERVENDOR() 
    Local aParam := PARAMIXB 
    Local xRet := .T. 
    Local oObj := Nil 
    Local cIdPonto := ""
    Local cIdModel := ""
    Local nOper := 0 
    Local _aPN := {}
  
    
    //Se tiver parâmetros
    If aParam != Nil

        //Pega informações dos parâmetros
        oObj := aParam[1] 
        cIdPonto := aParam[2] 
        cIdModel := aParam[3] 
 
         //Commit das operações (após a gravação)
        If cIdPonto == "MODELCOMMITNTTS"
            nOper := oObj:nOperation
            
           Do Case
                Case M->A2_TIPO = 'J'
                    _sNomeGrp := "PESSOA JURIDICA"
                Case M->A2_TIPO == 'F'
                    _sNomeGrp := "PESSOA FISICA "
                Otherwise
                    _sNomeGrp := "PESSOA OUTROS"
            EndCase 
                
            Do Case
            Case cValToChar(nOper) $ "3|4" //Incluir / Copiar / Alterar

                _aPN := { {"CODPN",M->A2_COD+M->A2_LOJA},;
                            {"RAZAO",M->A2_NOME},;
                            {"TIPO","F"},;
                            {"CODGRP",M->A2_TIPO},;
                            {"NOMEGRP",_sNomeGrp},;
                            {"UF",M->A2_EST},;  
                            {"CIDADE",M->A2_MUN},;
                            {"BAIRRO",M->A2_BAIRRO},;  
                            {"RUA",Alltrim(M->A2_END) + "," + Alltrim(M->A2_NR_END)},;  
                            {"CEP",M->A2_CEP},;  
                            {"FONE",M->A2_TEL},;  
                            {"CGC",M->A2_CGC},;  
                            {"IE",M->A2_INSCR},;  
                            {"IM",M->A2_INSCRM},;   
                            {"CONDPAG",M->A2_COND},;
                            {"ATIVO",IIF(M->A2_MSBLQL <> '1',.T.,.F.)};                             
                            }

            Case nOper = 5 // Excluir
                _aPN := { {"CODPN",M->A2_COD+M->A2_LOJA},;
                          {"RAZAO",M->A2_NOME},;
                          {"TIPO","F"},;
                          {"CODGRP",M->A2_TIPO},;
                          {"NOMEGRP",_sNomeGrp},;
                          {"UF",M->A2_EST},;  
                          {"CIDADE",M->A2_MUN},;
                          {"BAIRRO",M->A2_BAIRRO},;  
                          {"RUA",Alltrim(M->A2_END)+ "," +Alltrim(M->A2_NR_END)},;  
                          {"CEP",M->A2_CEP},;  
                          {"FONE",M->A2_TEL},;  
                          {"CGC",M->A2_CGC},;  
                          {"IE",M->A2_INSCR},;  
                          {"IM",M->A2_INSCRM},;   
                          {"ATIVO",.F.};                             
                          }
            EndCase

            //Envia os dados dos Parceiros de Negocios (PN) para o WMS
            U_MAPWMS03(_aPN)
           // MsgAlert("Operação "+cValToChar(noper))
        EndIf
    EndIf
Return xRet
