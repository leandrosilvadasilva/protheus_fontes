#INCLUDE 'TOTVS.ch'

/*--------------------------------------------------------------------------------------------------*
| Func:  MT040DEL()                                                     							    |
| Autor: Valmor Marchi                                              								|
| Data:  08/02/2022                                                   								|
| Desc:  Este ponto de entrada pertence à rotina de cadastro de Vendedores (MATA040). Ele é executado  |
|        após a gravação da EXCLUSÃO.										    					|
|		                                                                          					|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/

User Function MT040DEL()
    Local _aVend := {}
    
    //Envia alterações de cadastro para o WMS (AKR)
    _aVend := {{"CODUSER",M->A3_COD},;
                {"NOMEUSER",M->A3_NOME},;
                {"OBS",""},;
                {"VLRCOMIS",M->A3_COMIS},;
                {"CODGRP","0"},;
                {"LOCK","N"},;  
                {"CARDCODE",""},;
                {"FONE",M->A3_TEL},;  
                {"EMAIL",M->A3_EMAIL},;  
                {"ATIVO",.F.};                             
                  }
        
        //Envia os dados do cliente para o WMS
        U_MAPWMS04(_aVend)
Return
