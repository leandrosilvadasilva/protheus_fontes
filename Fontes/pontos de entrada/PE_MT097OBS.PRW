#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT097OBS

    https://tdn.totvs.com/pages/releaseview.action?pageId=6085646
    Caso o Ponto de Entrada não retorne (.T. ou .F.),  a validação do campo "Observações" não será considerada.

@type function
@version  
@author dwt.luciano
@since 20/11/2023
@return variant, return_description
/*/
User Function MT097OBS()
Local lRet    := .T. AS BOOLEAN 
Local cObs    := ""  AS CHARACTER
Local lTemObs := .T. AS BOOLEAN 

    cObs    := PARAMIXB[1]
    lTemObs := Len( AllTrim( cObs )) == 0   

    If lTemObs

        FWAAlertInfo( "Campo observação é obrigatorio")   
        lRet:= .F.
    EndIF

Return lRet

