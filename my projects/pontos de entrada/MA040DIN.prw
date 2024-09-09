#INCLUDE 'TOTVS.ch'

/*--------------------------------------------------------------------------------------------------*
| Func:  MA040DIN()                                                     							    |
| Autor: Valmor Marchi                                              								|
| Data:  08/02/2022                                                   								|
| Desc:  Este ponto de entrada pertence � rotina de cadastro de Vendedores (MATA040). Ele � executado  |
|        ap�s a grava��o da INCLUS�O.										    					|
|		                                                                          					|
|																									|
| Altera��es .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/

User Function MA040DIN()
    Local _aVend := {}
    
    //Envia altera��es de cadastro para o WMS (AKR)
    _aVend := {{"CODUSER",M->A3_COD},;
                {"NOMEUSER",M->A3_NOME},;
                {"OBS",""},;
                {"VLRCOMIS",M->A3_COMIS},;
                {"CODGRP","0"},;
                {"LOCK","N"},;  
                {"CARDCODE",""},;
                {"FONE",M->A3_TEL},;  
                {"EMAIL",M->A3_EMAIL},;  
                {"ATIVO",IIF(M->A1_MSBLQL <> '1',.T.,.F.)};                             
                  }
        
        //Envia os dados do cliente para o WMS
        U_MAPWMS04(_aVend)
Return
