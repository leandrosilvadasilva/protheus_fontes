#INCLUDE 'TOTVS.ch'

/*--------------------------------------------------------------------------------------------------*
| Func:  M030EXC()                                                     							    |
| Autor: Valmor Marchi                                              								|
| Data:  08/02/2022                                                   								|
| Desc:  Este ponto de entrada pertence à rotina de cadastro de clientes, MATA030. Ele é executado  |
|        após a gravação da EXCLUSÃO.										    					|
|		                                                                          					|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/

User Function M030EXC()
    Local _aClientes := {}
    
    //Envia alterações de cadastro para o WMS (AKR)
    _aClientes := {{"CODPN",M->A1_COD},;
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
        U_MAPWMS03(_aClientes)
Return
