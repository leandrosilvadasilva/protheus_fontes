#INCLUDE "TOTVs.CH"

/*/{Protheus.doc} FISENVNFE

	https://tdn.totvs.com/display/public/TSS/FISENVNFE+-+Envio+de+NF-e
	Quando chega nesse PE,  já  gravou na  SPED050 com os dados:  STAUS = 6  e   STATUSMAIL = 1  e  F3_CODRET = T
	Inclusive ja tenho o F3_CODESET como 100  que efetuado o " Monitor "
	E o SE1 posicionado

	Vamos usar devido a transmissão automatica de notas,  bem como de forma  manual
	Saberedores que temos a operação de integração manual disponibilizada no menu

@type function
@version 1.0
@author DWT Luciano Souza
@since 09/11/2022
@return logico, return description
/*/
User Function FISENVNFE()	
Local aIdNfe   := PARAMIXB[1]
Local lRetorno := .T.
Local nCntFor  := 0
Local aArea    := FWGetArea()

    If Len(aIdNfe) > 0
 
        For nCntFor := 1 To Len(aIdNfe)



        Next nCntFor     
    EndIf

FWRestArea( aArea )
Return  lRetorno
