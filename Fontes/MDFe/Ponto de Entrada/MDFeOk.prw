#Include "Protheus.ch"

/*/{Protheus.doc} MDFeOk
description
@type function
@version  
@author dwt.rudinei
@since 26/11/2023
@return variant, return_description
/*/
USER FUNCTION MDFeOk()
    Local lRet := .T.

    If nPBruto > VAL(Posicione('DA3',1,xFilial('DA3')+CVEICULO,'DA3_ZCAPAC'))
        MsgInfo('Peso total das notas carregadas no manifesto, excede a capacidade do veículo. Verifique!')
        lRet := .F.
    EndIf
Return lRet
