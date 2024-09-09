#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
// aCndProp() - Atualiza ADZ_CONDPG com o conteudo ADY_CONDPG
// Funcao respensavel por garantir a mesma condicao de pagamento
// em todas as linhas da proposta
//-------------------------------------------------------------------

User Function FT600GRV()

Local oModel := PARAMIXB[1]
Local oMdlADY  		:= oModel:GetModel("ADYMASTER")
Local oMdlPRO  		:= oModel:GetModel("ADZPRODUTO")
//Local oMdlADZ  		:= oModel:GetModel("ADZACESSOR")
Local nOperation    := oMdlADY:GetOperation()
Local aArea    	  	:= GetArea()
Local nI       		:= 0
Local cCND 	   		:= oMdlADY:GetValue("ADY_CONDPG")

If (nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE)
	// atualiza condi��o de pagamento da aba produtos
	For nI := 1 To oMdlPRO:Length()
		oMdlPRO:GoLine( nI )
		If !oMdlPRO:IsDeleted()
			oMdlPRO:LoadValue("ADZ_CONDPG",cCND)
		Endif
	Next
	
	// atualiza condi��o de pagamento da aba acess�rios
	//For nI := 1 To oMdlADZ:Length()
	//	oMdlADZ:GoLine( nI )
	//	If !oMdlADZ:IsDeleted()
	//		oMdlADZ:LoadValue("ADZ_CONDPG",cCND)
	//	Endif
	//Next
		
Endif

RestArea(aArea)

Return(.T.)
