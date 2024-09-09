#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//---------------------------------------------------------------------------------------
/*/
{Protheus.doc} MA103OPC
Realiza a validação da linha conforme necessiade.
@author      Davidson Carvalho
@since        13/10/2023
@version       12.1.33
@obs
MA103OPC - Adição de itens no menu
Link: https://tdn.totvs.com/pages/releaseview.action?pageId=6085341

Retorno: Array contendo dados do novo item do menu.

Data                        Programador                          Motivo
13/10/2023    			Davidson Carvalho					Validar conta contabil produto x natureza financeira.
/*/
//---------------------------------------------------------------------------------------
User Function MA103OPC()

	Local aArea      := GetArea()
	Local cUsrLibDoc := SuperGetMv("MH_USRLIB",.F.,"000000")
	Local lAtivBlq      := SuperGetMv("MH_BLQNAT",.F.,"")
	Local aRet       := {}

	If lAtivBlq
    
		If __CUSERID $ cUsrLibDoc

			aAdd(aRet,{'Libera Documento Contábil', 'U_MAHLIBCTB()', 0, 5})
		EndIf
	EndIf
	RestArea(aArea)
Return aRet
