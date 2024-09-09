#Include "Protheus.ch"
#Include "Vkey.ch"

Static NomePrt		:= "CADZM1"
Static VersaoJedi	:= "V1.01"

/*/{Protheus.doc} PRT0478
Manutenção de dados da tabela ZM1 (Operações WMS)
@author 
@since 
@return Nil, Sem retorno
@type function
/*/
User function CADZM1()
	Local cVldAlt 		:= ".T." // Operacao: Alteracao
	Local cVldExc		:= ".T." // Operacao: Exclusao
	Local cNomeTab		:= ""

	Private cCadastro 	:= ""

	dbSelectArea("SX2")
	SX2->(dbSetOrder(1))
	If SX2->(dbSeek("ZM1"))
		cNomeTab := AllTrim( SX2->(X2Nome()) )
	EndIf

	cCadastro := NomePrt + " - " + cNomeTab + " - " + VersaoJedi

	ChkFile("ZM1")
	dbSelectArea("ZM1")
	ZM1->(dbSetOrder(1))

	AxCadastro("ZM1", cCadastro, cVldExc, cVldAlt)
Return
