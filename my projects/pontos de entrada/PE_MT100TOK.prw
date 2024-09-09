#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//---------------------------------------------------------------------------------------
/*/
{Protheus.doc} MT100TOK
Valida a inclusão de NF
@author      Davidson Carvalho
@since        14/10/2023
@version       12.1.33
@obs
MT100TOK - Valida a inclusão de NF
Link: https://tdn.totvs.com/x/GNtc

Retorno: Deve retornar .T. para validar o item posicionado ou .F. para não validar.
Alteracoes Realizadas desde a Estruturacao Inicial

Data                        Programador                          Motivo
25/09/2023				Davidson Carvalho					Validar conta contabil produto x natureza financeira.
/*/

//---------------------------------------------------------------------------------------
User Function MT100TOK()

	Local aAreaSED      := GetArea("SED")
	Local aAreaSD1      := GetArea("SD1")
	Local nPosPrd       := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_COD' })
	Local nPosConta     := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CONTA' })
	Local cNatureza     := MaFisRet(,"NF_NATUREZA")
	Local lAtivBlq      := SuperGetMv("MH_BLQNAT",.F.,"")
	Local ContaNatureza := ""
	Local nI            := 0
	Local lRet          := .T.
	Local lAchou        := .F.
	Local lLiberado     := .F.

	
	If lAtivBlq
		
		//--Captura a natureza financeira da nota fiscal.
		dbSelectArea("SED")
		SED->(dbSetOrder(1)) // ED_FILIAL+ED_CODIGO
		If dbSeek(xFilial('SED')+cNatureza)

			ContaNatureza := SED->ED_CONTA
			lAchou:=.T.

			//--Valida se o documento foi liberado pela hirarquia de aprovação.
			If '2' $ SED->ED_FLAGCTB

				lLiberado := .T.
				lRet	  := .T.

				//--Volta o status orignal de bloqueado.
				dbSelectArea("SED")
				SED->(dbSetOrder(1))
				If dbSeek(xFilial( 'SED' )+cNatureza)

					If RecLock( 'SED' ,.F.)

						Replace ED_FLAGCTB With '1'

						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf


		//-- Valida se a conta contabil informada na linha do produto e igual a conta informada na natureza.
		If lAchou .And. !lLiberado

			//-- Valida se a conta contábil vinculada a natureza é a mesma do produto.
			For nI := 1 To Len(acols)
				If !GDDeleted(n,aHeader,acols)

					If ContaNatureza <> aCols[n][nPosConta]

						Aviso("MA Hospitalar","Conta contabil do produto diferente da conta vinculada a Natureza!"+Chr(13)+Chr(10)+"Favor verificar o produto. ",{"Voltar"},2,"Produto: "+aCols[n][nPosPrd])
						lRet := .F.

						//--Grava o status de bloqueio
						dbSelectArea("SED")
						SED->(dbSetOrder(1))
						If dbSeek(xFilial('SED')+cNatureza)

							If RecLock('SED',.F.)

								Replace ED_FLAGCTB 	With '1'

								MsUnlock()
							EndIf
						EndIf
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf
	RestArea(aAreaSED)
	RestArea(aAreaSD1)
Return(lRet)
