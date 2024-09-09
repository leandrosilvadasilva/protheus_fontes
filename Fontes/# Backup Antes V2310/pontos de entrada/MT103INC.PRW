#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include 'Totvs.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MT100GE2    ³ Autor ³ Ednei Silva	    ³ Data ³18/07/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta uma tela para Informar o Motivo da Devolucao         ³±±
±±³          ³ 									                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MAHOPITALAR / Faturamento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
#define DS_MODALFRAME   128

User Function MT103INC()

Local nLinha	  := 010
Local lEdita	  := .F.
Local oCodDev
Local oDescDev
Local aArea     := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSF1  := SF1->(GetArea())
//IATAN EM 18/05/2023 
Local retorno  := .T.
//PRIVATE nTIPO := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_TIPO' }))
//PRIVATE nDoc  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_DOC' }))
//PRIVATE nMot  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_ZMOTDEV' }))
//PRIVATE nDes  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_ZDESMOT' }))
Private cCodDev	  := SPACE(4)
Private cDesDev	  := SPACE(50)
Private oDlg01
Private lGrava	  := .F.

//ALERT(' DOCUMENTO '+PARAMIXB1[nDoc]+' TIPO '+PARAMIXB1[nTIPO])

//IDENTIFICAR SE ESTÁ VINDO VIA INTEGRAÇÃO WMS
IF ISINCALLSTACK("U_DEVOLUCAO") .OR. ISINCALLSTACK("U_DEV2")
	RETURN
ENDIF

IF EMPTY(SF1->F1_ZMOTDEV) .and. SF1->F1_TIPO='D'

		Define MsDialog oDlg01 Title "Motivo da Devolucao"  From 000,000 To 250, 730 Pixel Style DS_MODALFRAME

		@ nLinha + 002, 010 Say OemToAnsi("Motivo Devolucao") Of oDlg01 Pixel
		//	@ nLinha, 055 MsGet oTransp Var cTransp of oDlg01  Pixel F3 "Z40" Valid (Vazio() .or. A010ValTrp(cTransp))
		@ nLinha, 055 MsGet oCodDev  Var cCodDev of oDlg01  Pixel F3 "Z40" Valid (Vazio() .or. A010ValMot(cCodDev))
		@ nLinha, 100 MsGet oDescDev Var cDesDev of oDlg01  Pixel When lEdita  Size 261, 012
		nLinha += 018

		@ 080, 330 Button 'Ok'		Size 030,015 Of oDlg01 Pixel Action (Grava())
		//	@ nLinha, 290 Button 'Cancelar'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )

		@ 110 + 002, 010 Say OemToAnsi("* É obrigatório informar o motivo de devolução para este tipo de documento") Of oDlg01 Pixel


		Activate MsDialog oDlg01 Centered

ELSE

	IF ISINCALLSTACK( "SA103Devol" )
		// DEVOLUÇÕES DEVEM SEGUIR NORMALMENTE
		//IATAN EM 31/07/2023 - NA V2210 A ROTINA DE DEVOLUÇÃO PADRÃO FOI SUBSTITUIDA PELA "SA103Devol"
	ELSE
		retorno := validaConfWMS()
		IF retorno == .F. 
				ALERT("Há itens ainda não conferidos pelo WMS. VERIFIQUE!")
		ENDIF
	ENDIF

ENDIF


RestArea(aAreaSE2)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
Return( retorno )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010ValMot ³ Autor ³   Ednei Silva    	³ Data ³18/07/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validação do Motivo		                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A010ValMot()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cMotivo - Motivo da Devolucao			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A010ValMot(_cMotivo)

lRet := .T.

If !Empty(_cMotivo)
	
	DbSelectArea("Z40")
	DbSetOrder(1)
	
	If	DbSeek(xFilial("Z40")+_cMotivo)
		cDesDev  := Z40->Z40_DESCRI
		lGrava   := .T.
	Else
		
		Aviso("AVISO","Motivo de Devolucão não cadastrada!", { "Sair" }, 2)
		lRet := .F.
		
	EndIf
	
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Grava ³ Autor ³   Ednei Silva    		³ Data ³18/07/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava o motivo de devolucao no cabecalho da nota			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  Grava()         	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grava()

If	lGrava
	RecLock('SF1',.F.)
	   SF1->F1_ZMOTDEV := cCodDev
	   SF1->F1_ZDESMOT := cDesDev
	SF1->(MsUnlock())
	
	MsgInfo("Dados gravados com sucesso!","Informação!")
	oDlg01:End()
Else
	MsgInfo("Selecione um motivo de devolucao!","Informação!")
EndIf

Return ()



// IATN EM 18/05/2023
Static Function validaConfWMS()
  Local _cQry := ""
  Local _bContinua := .T.

  _cQry := " SELECT D1_DOC, D1_SERIE, D1_FORNECE,D1_ITEM, D1_COD, D1_QUANT, D1_LOTECTL, D1_QUANT1, D1_LOTE1, D1_CONFWMS "
  _cQry += "   FROM SD1010 SD1 INNER JOIN SF1010 SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA "
  _cQry += "   WHERE SD1.D_E_L_E_T_ <> '*' AND SF1.D_E_L_E_T_ <> '*'  "
  _cQry += "    AND D1_DOC = '"+SF1->F1_DOC+"' "
  _cQry += "    AND D1_SERIE = '"+SF1->F1_SERIE+"' "
  _cQry += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'"
  _cQry += "    AND F1_ESPECIE = 'SPED' "
  _cQry += "    AND D1_TP IN ('M1', 'M2', 'M3', 'M4', 'M5') "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SD1",.T.,.T. )
  
  While (_SD1->(!EOF()))
    Do Case
    Case _SD1->D1_CONFWMS <> 'S'
        _bContinua := .F.
        exit
/*    Case _SD1->D1_QUANT1 <> _SD1->D1_QUANT
        _bContinua := .F.
        msg := "Item "+Alltrim(SD1->D1_ITEM)+" Cód. "+Alltrim(SD1->D1_COD)+" está com a QUANTIDADE informada na digitação diferente da conferida pelo WMS. VERIFIQUE!"
        exit
    Case _SD1->D1_LOTE1 <>  _SD1->D1_LOTECTL
        _bContinua := .F.
         msg := "Item "+Alltrim(SD1->D1_ITEM)+" Cód. "+Alltrim(SD1->D1_COD)+" está com LOTE informadO na digitação diferente do conferido pelo WMS. VERIFIQUE!"
         exit*/
    EndCase
    _SD1->(DbSkip())
  End
  _SD1->(DBCloseArea())

Return _bContinua

