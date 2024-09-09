#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//---------------------------------------------------------------------------------------
/*/
{Protheus.doc} MAHLIBCTB
Realiza a libera��o da natureza financeira.
@author      Davidson Carvalho
@since        25/09/2023
@version       12.1.33
@obs
MT100TOK - Valida a inclus�o de NF
Link: https://tdn.totvs.com/x/GNtc

Retorno: Deve retornar .T. para validar o item posicionado ou .F. para n�o validar.
Alteracoes Realizadas desde a Estruturacao Inicial

Data                        Programador                          Motivo
25/09/2023				Davidson Carvalho					Validar conta contabil produto x natureza financeira.
/*/

//---------------------------------------------------------------------------------------
User Function MAHLIBCTB()

	Local aAreaSED   := GetArea("SED")
	Local oFtTxt     := TFont():New('Tahoma', , 018, , .T., , , , , .F., .F.)
	Local lAtivBlq   := SuperGetMv("MH_BLQNAT",.F.,"")
	Local lRet       := .T.
	Local lHasButton := .T.
	Local cNatureza  := Space(14)
	Local oDlg
	Local oGet1

	If lAtivBlq
		
        //-----------------------------------------------------------------------------------
		// Tela para sele��o da natureza a ser liberada.
		//-----------------------------------------------------------------------------------
		DEFINE MSDIALOG oDlg TITLE "Natureza Financeira" FROM 0,0 TO 050,350 PIXEL Style DS_MODALFRAME

		@ 008,005 SAY "C�digo" FONT oFtTxt PIXEL OF oDlg

		oGet1 := TGet():New( 008,040, { | u | If( PCount() == 0, cNatureza, cNatureza := u ) },oDlg, ;
			065, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNatureza",,,,lHasButton  )

		@ 008,115 BUTTON "Liberar" SIZE 060,012 ACTION  fLibNaturez(cNatureza) OF oDlg PIXEL

		oGet1:cTooltip := 'Pressione ESC para fechar a tela.'
		oGet1:cF3      := 'SED'
		oGet1:bHelp    :={|| ShowHelpCpo( 'Ajuda' , { ' Pressione ESC para fechar a tela !! ' }, 0 )}

		ACTIVATE MSDIALOG oDlg CENTERED
	
    EndIf
	RestArea(aAreaSED)

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fLibNaturez.
Fun��o respons�vel pela libera��o da natureza financeira.

@Author   Davidson Carvalho 
@Since 	14/10/2023
@Version 	12.1.33
@param   	n/t
@return  	Retorno da Static Function
xxxxx
/*/
//-----------------------------------------------------------------------------------------------------------
Static Function fLibNaturez(cNatureza)

	Local aSaveArea := GetArea()

	dbSelectArea("SED")
	SED->(dbSetOrder(1))
	If dbSeek(xFilial( 'SED' )+cNatureza)

		If RecLock( 'SED' ,.F.)

			Replace ED_FLAGCTB With '2'

			MsUnlock()
		EndIf

		MsgInfo('Natureza liberada.',"Sucesso!!" )
	Else

		MsgAlert('C�digo de Natureza n�o encontrado!','Aten��o!')
	EndIf
	RestArea(aSaveArea)
Return

