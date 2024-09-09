#INCLUDE "PROTHEUS.CH"

User Function SCPLOTE()
//Local cExprFilTop := "CP_NUM='"+SCP->CP_NUM+"'"
Local cExprFilTop := "CP_STATUS='' AND CP_FILIAL='"+xFilial("SCP")+"'"
Private cCadastro := "Ajusta Requisição"
Private cDelFunc  := ".T."
Private cString   := "SCP"
Private aRotina   := { { "Pesquisar" , "AxPesqui" , 0 , 1 } ,;
{ "Alterar" , "U_AltFT46" , 0 , 4 } ,;
{ "Visualizar" , "U_VisFT46" , 0 , 2 } }
dbSelectArea("SCP")
dbSetOrder(1)
//dbSelectArea(cString)
mBrowse( 005, 005,093,180,cString, NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , cExprFilTop )
//mBrowse( 005, 005,093,180,cString, NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL)
Return


User Function VisFT46()

Local aAlias := SCP->(GetArea())
local aAcho := {"CP_FILIAL", "CP_NUM", "CP_PRODUT", "CP_QUANT","CP_ZLOTCTL", "CP_ZNLOTE","CP_NSERI", "CP_LOCLIZ"} //campos a ser visualizado
//Local cTudOk := "NaoVazio(M->B1_COD)"
Local nRet

nRet := AxVisual("SCP", SCP->(RecNo()), 4, aAcho,,,,/*cTudOk*/,,,,,,.T.)

If nRet == 1
	SCP->(DbGoTop())
Else
	RestArea(aAlias)
EndIf
Return 

User Function AltFT46()

Local aAlias := SCP->(GetArea())
//local aAlter :={"CP_ZLOTCTL", "CP_ZNLOTE","CP_ZNSERI", "CP_ZLOCLIZ"}// campo travado a edição
local aAcho := {"CP_ZLOTCTL", "CP_ZNLOTE","CP_ZNSERI", "CP_ZLOCLIZ"}// campo a ser editado
//Local cTudOk := "NaoVazio(M->B1_COD)"
Local nRet

nRet := AxAltera("SCP", SCP->(RecNo()), 2, aAcho,,,,/*cTudOk*/,,,,,,.T.)

If nRet == 1
	SCP->(DbGoTop())
Else
	RestArea(aAlias)
EndIf
Return
