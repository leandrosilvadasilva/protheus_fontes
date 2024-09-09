#INCLUDE "PROTHEUS.CH"

User Function MAH0180()
Local aArea    := GetArea()
//Local aAreaE1  := SE1->(GetArea())
//Local aAreaA1  := SA1->(GetArea())
Local aRotAdic :={}
Local bPre := {||fPre(SE1->E1_CLIENTE,SE1->E1_Loja,SE1->E1_NUM,SE1->E1_TIPO,SE1->E1_PREFIXO,SE1->E1_PARCELA )}
Local bOK  := {.T.}
Local bTTS  := {}
Local bNoTTS  := {}
Local aButtons := {}//adiciona botões na tela de inclusão, alteração, visualização e exclusao

aadd(aButtons,{ "PRODUTO", {|| MsgAlert("Teste")}, "Teste", "Botão Teste" }  ) //adiciona chamada no aRotina
aadd(aRotAdic,{ "Adicional","U_Adic", 0 , 6 })
//Para Filtrar por um periodo
//Set Filter to SZ6->Z6_Data>=cFiltro1 .and. SZ6->Z6_Data<=cFiltro2
//	AxCadastro("Z60", "Historico de Cobranca", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )
//	AxCadastro("Z60", "Historico de Cobranca", , .T., aRotAdic, bPre, , , , , , aButtons, , )
DBselectArea("Z60")
cFiltro := "Z60_FILIAL = '"+SE1->E1_FILIAL+"' .AND. Z60_TITULO = '"+SE1->E1_NUM+"' .AND. Z60_PREFIX = '"+SE1->E1_PREFIXO+"' .AND. Z60_PARCEL = '"+SE1->E1_PARCELA+"' .AND. Z60_TIPO = '"+SE1->E1_TIPO+"'"  
SET FILTER TO &cFiltro	
	AxCadastro("Z60", "Historico de Cobranca", , ".T.", aRotAdic, bPre, , , , , , aButtons, , )
SET FILTER TO 
RestArea(aArea)
//RestArea(aAreaE1)
//RestArea(aAreaA1)
Return(.T.)

Static Function fPre(cCliente,cLoja,cTitulo,cTipo,cPrefixo,cParcela)


M->Z60_TITULO:=cTitulo
M->Z60_CLI   :=cCliente
M->Z60_LOJA  :=cLoja
M->Z60_PREFIX:=cPrefixo
M->Z60_TIPO  :=cTipo
M->Z60_PARCEL:=cParcela
M->Z60_USER  :=cUserName
M->Z60_ID    :=cValToChar(nProxId(cCliente,cLoja,cTitulo,cTipo,cPrefixo,cParcela))
M->Z60_DATA  :=date()
M->Z60_HORA  :=time()
M->Z60_ORIGEM:=Funname()

Return

Static Function DelOk()

Return

Static Function COK()

Return .t.

Static Function Adic()
MsgAlert("Rotina nao compilada")
Return


Static Function nProxId(cCliente,cLoja,cTitulo,cTipo,cPrefixo,cParcela)

cQuery:=''
cID:=''
cQuery:=" SELECT ISNULL(MAX(Z60_ID),0)+1 AS PROXID FROM Z60010 WHERE  "
cQuery+=" Z60_CLI='"+cCliente+"'"
cQuery+=" AND Z60_TITULO ='"+(cTitulo)+"'"
cQuery+=" AND Z60_CLI    ='"+(cCliente)+"'"
cQuery+=" AND Z60_LOJA   ='"+(cLoja)+"'"
cQuery+=" AND Z60_PREFIX ='"+(cPrefixo)+"'"
cQuery+=" AND Z60_TIPO   ='"+(cTipo)+"'"
cQuery+=" AND Z60_PARCEL ='"+(cParcela)+"'"
cQuery:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TPID",.F.,.T.)


cID:=TPID->PROXID

dbCloseArea("TPID")
Return cID



