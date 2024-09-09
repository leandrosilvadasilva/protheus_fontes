#Include "Totvs.ch"

/*/{Protheus.doc} User Function FC010BTN
	Ponto de entrada para adicionar botão na rotina Posição do Cliente
	@type  Function
	@author Leandro Marquardt
	@since 27/12/2022
	/*/
User Function FC010BTN()

	Local aArea	   := GetArea()
	Local aIndex   := {} 
	Local cFiltro  := "Z60_CLI = '"+SA1->A1_COD+"' .AND. Z60_LOJA = '"+SA1->A1_LOJA+"'"
	
	Private cCadastro  := "Historico de Cobrança MA" 
	Private aRotina    := {{ "Visualizar" , "AxVisual" , 0 , 2 }} 
	Private bFiltraBrw := { || FilBrowse( "Z60" , @aIndex , @cFiltro ) }
	
	If Paramixb[1] == 1// Deve retornar o nome a ser exibido no botÃ£o
		Return OemToAnsi("Hist. Cobrança MA")
	ElseIf Paramixb[1] == 2// Deve retornar a mensagem do botÃ£o
		Return OemToAnsi("Historico de Cobrança MA")
	Else

		Eval( bFiltraBrw ) 
		mBrowse( 6 , 1 , 22 , 75 , "Z60" ) 
		EndFilBrw( "Z60" , @aIndex ) 
		
	Endif

	RestArea(aArea)
	
Return



