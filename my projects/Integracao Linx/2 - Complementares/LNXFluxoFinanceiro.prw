#INCLUDE "TOTVS.CH"

#DEFINE FORMAPAGTO_CARTAO_CREDITO   "CC"

/*/{Protheus.doc} FISENVNFE

	https://tdn.totvs.com/display/public/TSS/FISENVNFE+-+Envio+de+NF-e
	Quando chega nesse PE,  já  gravou na  SPED050 com os dados:  STAUS = 6  e   STATUSMAIL = 1  e  F3_CODRET = T
	Inclusive ja tenho o F3_CODESET como 100  que efetuado o " Monitor "
	E o SE1 posicionado

	Vamos usar devido a transmissão automatica de notas,  bem como de forma  manual
	Saberedores que temos a operação de integração manual disponibilizada no menu

	TODO
	[ ] - Ver se a plataforma está ativa
	[ ] - Ver se o titulo está baixado antes de baixar
	[ ] - tem que ter a opção de ser manual  
	[ ] - e quando rejeitar uma nota - tem que validar esse cenário com o PE
@type function
@version 1.0
@author DWT Luciano Souza
@since 09/11/2022
@return logico, return description
/*/
Function MA_3_WSLNX()	
Local cDiaSemana     := "" 
Local cHora          := "" 
Local cRodaFimSemana := "" 
Local cHoraInicial   := "" 
Local cHoraFinal     := "" 

	RpcSetType(3)
	RpcSetEnv("01","0101",,,"FAT")  //  Colocar um usuario pra ser especificop no DBACESS

    cDiaSemana     := Upper(AllTrim(DiaSemana( dDataBase )))
    cHora          := Time()
    cRodaFimSemana := SuperGetMV( "ES_LINXSD", .F., .F. )
    cHoraInicial   := SuperGetMV( "ES_LINXHI", .F., "07:00" )
    cHoraFinal     := SuperGetMV( "ES_LINXHF", .F., "19:00" )

    If cRodaFimSemana  .or.  !( cDiaSemana $ "DOMINGO/SABADO" )  

        If cHora > cHoraInicial .and.  cHora <= cHoraFinal

    	    LNXFluxoFinanceiro()
        EndIf
    EndIf

	RpcClearEnv()
Return

Static Function Function LNXFluxoFinanceiro()		
Return return_var
Local aIdNfe    := PARAMIXB[1]
Local lRetorno  := .T.
Local nCntFor   := 0
Local aArea     := FWGetArea()
Local aPVLinx   := {}
Local cNota     := ""
Local cSerie    := ""
Local cPVLinx   := ""
Local cFormPG   := ""
Local cFilSC5   := ""
Local cCliente  := ""
Local cLojaCli  := ""
Local cTipo     := "NF "
Local cParcela  := "   "
Local oLinx     := FATBCAIntegracaoLinx():New()
Local lSchedule := ValType(CEMPANT) == "A" 
Local lIsBlind  := IsBlind()
Local lSIXLinx  := FWSIXUtil():ExistIndex( "SC5" , "SC5LINX" , .T. )
Local aSE1Linx  := {}
Local cParcelas := ""
Local lOk       := .T.

Local SE1Area   := SE1->(FWGetArea())


	select

	do while

	If lSIXLinx

		If !lSchedule  .and.  Len(aIdNfe) > 0
	
			For nCntFor := 1 To Len(aIdNfe)

				cNota    := Subs( aIdNfe[nCntFor], 4, 9 )
				cSerie   := Subs( aIdNfe[nCntFor], 1, 3 )

				aPVLinx  := GetAdvFVal( "SC5", {"C5_FILIAL", "C5_ZIDLINX", "C5_FORPG", "C5_CLIENTE", "C5_LOJACLI", "C5_NUM" }, FWxFilial("SC5") + cNota + cSerie, 14, {"","","","","",""} )
						
				cFilSC5  := aPVLinx[1]
				cPVLinx  := aPVLinx[1]
				cFormPG  := aPVLinx[3]
				cCliente := aPVLinx[4]
				cLojaCli := aPVLinx[5]

				VarInfo( "aPVLinx", aPVLinx)

				If NaoVazio( cPVLinx )  

					// Baixa o titulo principal ( do cliente )
					aSE1Linx := GetAdvFVal( "SE1", {"E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_LOJA", "E1_VALOR", "E1_PEDIDO", "E1_SALDO", "E1_BAIXA", "E1_STATUS" }, ;
					                                FWxFilial("SE1") + cSerie + cNota + cParcela + cTipo + cCliente + cLojaCli, 1, {"","","","","","","","","","",""} )

					VarInfo( "aSE1Linx", aSE1Linx )
					FWRestArea( SE1Area )

					// Só baixa o titulo se  não  estiver  baixado
					If aSE1Linx[10] > 0

						lOk := oLinx:BaixaTitCliente( aSE1Linx )
					EndIf

					If  lOk  .and.  cFormPG == FORMAPAGTO_CARTAO_CREDITO

						FWRestArea( SE1Area )
						lOk := oLinx:GetOrderByNumber( aPVLinx, @cParcelas )

						lOk := oLinx:GeraParcelasCC( cParcelas, aSE1Linx )

						// Gera parcelas do CC pela compra do cliente no LINX
					EndIf
				EndIf
			Next nCntFor     
		EndIf


		marcar os caras
	Else
		
		FWAlertError( "Para a funcionalide de baixa do titulo do cliente bem como criação de tiulos de parcelas de cartão de credito, é necessário a criação do seguinte indice: ")
	EndIf

FWFreeObj( oLinx )
FWRestArea( aArea )
Return  lRetorno
