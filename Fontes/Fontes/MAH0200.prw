#INCLUDE "PROTHEUS.CH"

User Function MAH0200()
Local aAreaZ80  := Z80->(GetArea())
Local aRotAdic  := {}
Local bPre      := {||fPre(cVendedor(RetCodUsr()))}
Local bOK       := {.T.}
Local bTTS      := {}
Local bNoTTS    := {}
Local aButtons  := {}//adiciona botões na tela de inclusão, alteração, visualização e exclusao
aadd(aButtons,{ "Encerrar", {|| Encerra()}, "Encerrar", "Encerrar" }  )
//aadd(aRotAdic,{ "Encerrar","Encerra()", 0 , 7 })

DBselectArea("Z80")

IF AllTrim(cUserName)=='debora.menezes' .Or. AllTrim(cUserName)=='Administrador'
cFiltro :=''
Else
cFiltro := "Z80_USER = '"+cUserName+"'"
ENDIF
SET FILTER TO &cFiltro
AxCadastro("Z80", "Historico de Cliente", , ".T.", aRotAdic, bPre, , , , , , aButtons, , )
//SET FILTER TO


RestArea(aAreaZ80)
Return(.T.)

Static Function fPre(cCodVen)

IF INCLUI
	
	M->Z80_CODVEN:=cVendedor(RetCodUsr())
	M->Z80_USER  :=cUserName
	M->Z80_ID    :=cValToChar(nProxId(cCodven))
	M->Z80_DATA  :=date()
	M->Z80_HORA  :=time()
	M->Z80_CLIENT:=SA1->A1_COD
	M->Z80_LOJA  :=SA1->A1_LOJA
	M->Z80_NOMCLI:=SA1->A1_NOME
	M->Z80_CNPJ  :=SA1->A1_CGC
	
ENDIF


Return



Static Function Encerra()

IF INCLUI .OR. ALTERA
	
	
	IF !EMPTY(M->Z80_DTFECH) .or. !EMPTY(M->Z80_HFIM)
		
		Alert('Este chamado ja foi encerrado!')
	else
		
		M->Z80_DTFECH  :=date()
		M->Z80_HFIM    :=time()
		
	ENDIF
	
ENDIF

Return


Static Function DelOk()

Return

Static Function COK()

Return .t.

Static Function Adic()
MsgAlert("Rotina nao compilada")
Return


Static Function nProxId(cCodven)

cQuery:=''
cID:=''
cQuery:=" SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 AS PROXID FROM Z80010 WHERE "
cQuery+=" D_E_L_E_T_<>'*' "
cQuery:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TPID",.F.,.T.)


cID:=STRZERO(TPID->PROXID,6)

dbCloseArea("TPID")
Return cID

Static Function cVendedor(cCodven)

cQuery:=''
cCod:=''
cQuery:=" SELECT A3_COD FROM SA3010 WHERE  "
cQuery+=" A3_CODUSR='"+cCodven+"'"
cQuery+=" AND D_E_L_E_T_<>'*' "
cQuery:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TVEN",.F.,.T.)


cCod:=TVEN->A3_COD

dbCloseArea("TVEN")
Return cCod


