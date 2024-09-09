#INCLUDE "PROTHEUS.CH"

/*
    IATAN EM 09/05/2023
*/
User Function MVDATAFIN                         
// Variaveis Locais da Funcao
Local cEdit1	 := GetMv("MV_DATAFIN")
Local cEdit2	 := GetMv("MV_DATAFIN")
Local oEdit1
Local oEdit2
Local usrLib     := GetMv("MV_XUSRFIN")
Private _oDlg				// Dialog Principal


IF !(RETCODUSR() $ usrLib)
    ALERT('ACESSO NAO PERMITIDO')
    RETURN .F.
ENDIF

DEFINE MSDIALOG _oDlg TITLE "MV_DATAFIN/MV_DATAREC" FROM C(350),C(575) TO C(487),C(721) PIXEL
@ C(007),C(007) Say "Data Atual" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(015),C(007) MsGet oEdit1 Var cEdit1 Size C(060),C(009) COLOR CLR_BLACK WHEN .F. PIXEL OF _oDlg
@ C(030),C(007) Say "Nova Data" Size C(028),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(037),C(007) MsGet oEdit2 Var cEdit2 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg HASBUTTON
DEFINE SBUTTON FROM C(055),C(007) TYPE 1 ENABLE OF _oDlg ACTION _bOk(cEdit2)
DEFINE SBUTTON FROM C(055),C(040) TYPE 2 ENABLE OF _oDlg ACTION _oDlg:End()
ACTIVATE MSDIALOG _oDlg CENTERED
Return(.T.)

//**************************
Static Function _bOk(cEdit2)
//**************************
_oDlg:End()
PutMv("MV_DATAFIN",cEdit2)
PutMv("MV_DATAREC",cEdit2)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)
