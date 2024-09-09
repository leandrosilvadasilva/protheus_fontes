#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120QRY
description
@type function
@version  
@author LSSOUZA
@since 6/11/2024
@return variant, return_description

TODO
    [ ] - Lembrar do  Meu Protheus
    [ ] - Usuarios no grupo de ADMIN do Protheus,  não  filtra
          Por causa do Fabio,  por exemplo
    [ ] - Quais os usuarios do RH
/*/
User Function MT120QRY()
Local cRet       := ""
Local oSay       := NIL
Local UsurioDoRH := SuperGetMV( "ES_MT120QRY", .F., "000569/000609/000568" )

    If !( RetCodUsr() $ UsurioDoRH )

        FWMsgRun(, {|oSay| cRet := FiltraPCRH( oSay ) }, "Aguarde", "Filtrando pedidos..." )
    EndIf

Return cRet

Static Function FiltraPCRH( oSay )
Local cRet := ""
Local cQry := ""

    //Selecionando os dados
    cQry := " SELECT "
    cQry += "     SC7.R_E_C_N_O_ "
    cQry += " FROM "
    cQry += "     " + RetSQLName('SC7') + " SC7 "
    cQry += "     INNER JOIN " + RetSQLName('SB1') + " SB1 "
    cQry += "     ON SB1.B1_COD = SC7.C7_PRODUTO "
    cQry += " WHERE "
    cQry += "     SC7.C7_FILIAL = '" + FWxFilial('SC7') + "' "
    cQry += "     AND SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "
    cQry += "     AND SC7.D_E_L_E_T_ = ' ' "
    cQry += "     AND SB1.D_E_L_E_T_ = ' ' "
    cQry += "     AND SB1.B1_TIPO   <> 'DC' "    
    cQry += "     AND SB1.B1_COD NOT IN ( '0000077', '0000087', '0000142') "    

    //Montando retorno do ponto de entrada
    cRet := " R_E_C_N_O_ IN ( " + cQry + " ) "

Return cRet

