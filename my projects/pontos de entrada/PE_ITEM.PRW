//Bibliotecas
#Include "Protheus.ch" 


User Function ITEM() 
    Local aParam := PARAMIXB 
    Local xRet := .T. 
    Local oObj := Nil 
    Local cIdPonto := ""
    Local cIdModel := ""
    Local nOper := 0 
    Local retorno
    
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
            Case cValToChar(nOper) $ "3|4" //Incluir / Copiar / Alterar

                // _sNomeGrupo := Alltrim(Posicione("SBM", 1, xFilial("SBM")+M->B1_GRUPO, "BM_DESC"))
                // _sNomeSecao := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"02"+M->B1_TIPO, "X5_DESCRI"))
                // _sNomeLinha := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"ZX"+M->B1_MARCA, "X5_DESCRI"))
                
                // _aItens := {{"CODITEM",M->B1_COD},;
                //             {"NOMEITEM",M->B1_DESC},;
                //             {"CODBAR",M->B1_CODBAR},;
                //             {"CODGRP",M->B1_GRUPO},;
                //             {"NOMEGRP",_sNomeGrupo},;
                //             {"UM",M->B1_UM},;
                //             {"ULTCOMPRA", M->B1_UPRC},;
                //             {"NCM",M->B1_POSIPI},;
                //             {"ATIVO",IIF(M->B1_MSBLQL <> '1',.T.,.F.)},;                            
                //             {"CODSEC",M->B1_TIPO},;
                //             {"NOMESEC",_sNomeSecao},;
                //             {"CODLN",M->B1_MARCA},;
                //             {"NOMELN",_sNomeLinha};
                //             }


                _sNomeGrupo := Alltrim(Posicione("SBM", 1, xFilial("SBM")+M->B1_GRUPO, "BM_DESC"))
                _sNomeSecao := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"02"+M->B1_TIPO, "X5_DESCRI"))
                _sNomeLinha := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"ZX"+M->B1_MARCA, "X5_DESCRI"))
                
                _aItens := {{"CODITEM",M->B1_COD},;
                            {"NOMEITEM",M->B1_DESC},;
                            {"TIPO","F"},;
                            {"CODBAR",M->B1_CODBAR},;
                            {"CODGRP",M->B1_GRUPO},;
                            {"NOMEGRP",_sNomeGrupo},;
                            {"UM",M->B1_UM},;
                            {"ULTCOMPRA", M->B1_UPRC},;
                            {"NCM",M->B1_POSIPI},;
                            {"ATIVO",IIF(M->B1_MSBLQL <> '1',.T.,.F.)},;                            
                            {"CODSEC",M->B1_TIPO},;
                            {"NOMESEC",_sNomeSecao},;
                            {"CODLN",M->B1_MARCA},;
                            {"RMS",M->B1_NRANVIS},;
                            {"CARDNAMEFAB",M->B1_FABRIC},;
                            {"CARDCODADD",M->B1_ENDFABR},;
                            {"NOMELN",_sNomeLinha};
                            }


            // Case nOper = 5 // Excluir
            //     _aItens := {{"CODITEM",M->B1_COD},;
            //                 {"NOMEITEM",M->B1_DESC},;
            //                 {"CODBAR",M->B1_CODBAR},;
            //                 {"CODGRP",M->B1_GRUPO},;
            //                 {"NOMEGRP",_sNomeGrupo},;
            //                 {"UM",M->B1_UM},;
            //                 {"ULTCOMPRA", M->B1_UPRC},;
            //                 {"NCM",M->B1_POSIPI},;
            //                 {"ATIVO",.F.},;
            //                 {"CODSEC",M->B1_TIPO},;
            //                 {"NOMESEC",_sNomeSecao},;
            //                 {"CODLN",M->B1_MARCA},;
            //                 {"NOMELN",_sNomeLinha};
            //                 }
            EndCase

            //Envia os dados dos itens para o WMS
            retorno := U_MAPWMS02(_aItens)
            //MsgAlert("Operação "+cValToChar(noper))
        EndIf
    EndIf
Return xRet


           