#INCLUDE "PROTHEUS.CH"


User Function MVDATFIS  
// Variaveis Locais da Funcao                             
Local cEdit1	 := GetMv("MV_DATAFIS")
Local cEdit2	 := GetMv("MV_DATAFIS")
Local oEdit1
Local oEdit2
Private _oDlg				// Dialog Principal

DEFINE MSDIALOG _oDlg TITLE "MV_DATAFIS" FROM C(350),C(575) TO C(487),C(721) PIXEL
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
PutMv("MV_DATAFIS",cEdit2)
Return


Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿟ratamento para tema "Flat"�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)
