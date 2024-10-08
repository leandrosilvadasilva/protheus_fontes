#INCLUDE "TOTVS.CH"

#DEFINE FORMAPAGTO_CARTAO_CREDITO   "CC"
#DEFINE FORMAPAGTO_BOLETO           "BO"    
#DEFINE FORMAPAGTO_PIX              "R$"
#DEFINE AUTORIZADA					"100"

/*/{Protheus.doc} FISMNTNFE

	https://tdn.totvs.com/display/public/TSS/FISENVNFE+-+Envio+de+NF-e
	Quando chega nesse PE,  j�  gravou na  SPED050 com os dados:  STAUS = 6  e   STATUSMAIL = 1  e  F3_CODRET = T
	Inclusive ja tenho o F3_CODESET como 100  que efetuado o " Monitor "
	E o SE1 posicionado

	Vamos usar devido a transmiss�o automatica de notas,  bem como de forma  manual
	Saberedores que temos a opera��o de integra��o manual disponibilizada no menu

	TODO
	[ ] - Ver se a plataforma est� ativaj
	[ ] - Ver se o titulo est� baixado antes de baixar
	[ ] - tem que ter a op��o de ser manual  
	[ ] - e quando rejeitar uma nota - tem que validar esse cen�rio com o PE
@type function
@version 1.0
@author DWT Luciano Souza
@since 09/11/2022
@return logico, return description
/*/
User Function FISMNTNFE()	
Local lRetorno   := .T.
Local aIdNfe     := PARAMIXB[1]
Local aNfeInf    := PARAMIXB[2]
Local cCodRetNfe := aNfeInf[1][9]

Local aArea      := FWGetArea()
Local aPVLinx    := {}
Local cNota      := ""
Local cSerie     := ""
Local cPVLinx    := ""
Local cFormPG    := ""
Local cFilSC5    := ""
Local cCliente   := ""
Local cLojaCli   := ""
Local cTipo      := "NF "
Local cParcela   := " "
Local oLinx      := FATBCAIntegracaoLinx():New()
Local lSchedule  := ValType(CEMPANT) == "A"
Local lIsBlind   := IsBlind()
Local lSIXLinx   := FWSIXUtil():ExistIndex( "SC5" , "SC5LINX" , .T. )
Local aSE1Linx   := {}
Local cParcelas  := ""
Local lOk        := .F.
Local SE1Area    := SE1->(FWGetArea())

	If cCodRetNfe == AUTORIZADA

		VarInfo( "aNfeInf", aNfeInf )
  		autoNfeMsg("Fluxo Financeiro..... - F", .F.)
  		autoNfeMsg("Fluxo Financeiro..... - F", .T.)		

		If lSIXLinx

			If !lSchedule  .and.  Len(aIdNfe) > 0		

				cNota    := Subs( aIdNfe, 4, 9 )
				cSerie   := Subs( aIdNfe, 1, 3 )

				aPVLinx  := GetAdvFVal( "SC5", {"C5_FILIAL", "C5_ZIDLINX", "C5_FORPG", "C5_CLIENTE", "C5_LOJACLI", "C5_NUM" }, FWxFilial("SC5") + cNota + cSerie, 14, {"","","","","",""} )
						
				cFilSC5  := aPVLinx[1]
				cPVLinx  := aPVLinx[2]  // <<----
				cFormPG  := aPVLinx[3]
				cCliente := aPVLinx[4]
				cLojaCli := aPVLinx[5]

				VarInfo( "aPVLinx", aPVLinx)

				If NaoVazio( cPVLinx )  

					// Baixa o titulo principal ( do cliente )
					aSE1Linx := GetAdvFVal( "SE1", {"E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_LOJA", "E1_VALOR", "E1_PEDIDO", "E1_SALDO", "E1_BAIXA", "E1_STATUS" }, ;
													FWxFilial("SE1") + cSerie + cNota + cParcela + cTipo + cCliente + cLojaCli, 1, {"","","","","","","",0,"",0,"",""} )

					VarInfo( "aSE1Linx", aSE1Linx )
					FWRestArea( SE1Area )

					// S� baixa o titulo se  n�o  estiver  baixado
					If aSE1Linx[10] > 0

						lOk := oLinx:BaixaTitCliente( aSE1Linx )
					EndIf

					If  lOk  
					
						If cFormPG == FORMAPAGTO_CARTAO_CREDITO

							FWRestArea( SE1Area )
							lOk := oLinx:GetOrderByNumber( aPVLinx, @cParcelas )

							lOk := oLinx:GeraParcelasCC( cParcelas, aSE1Linx, .T. )
						ElseIf ( cFormPG == FORMAPAGTO_BOLETO  .or.  cFormPG == FORMAPAGTO_PIX )

							cParcelas := 1
							lOk := oLinx:GeraParcelasCC( cParcelas, aSE1Linx, .F. )
						EndIf
						// Gera parcelas do CC pela compra do cliente no LINX
					EndIf
				EndIf 
			EndIf
		Else
			
			FWAlertError( "Para a funcionalide de baixa do titulo do cliente bem como cria��o de tiulos de parcelas de cart�o de credito, � necess�rio a cria��o do seguinte indice: ")
		EndIf
	EndIf

FWFreeObj( oLinx )
FWRestArea( aArea )
Return lRetorno



