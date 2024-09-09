/*
	[1] - cAlias - Nome da tabela;
	[2] - cCpoSX8 - Nome do campo que será utilizado para verificar o próximo sequencial;
	[3] - cAliasSX8 - Filial e nome da tabela na base de dados que será utilizada para verificar o sequencial;
	[4] - nOrdSX8 - Índice de pesquisa a ser usada na tabela.
*/



#include "protheus.ch"
#include "topconn.ch"

//Ponto de Entrada para controle de numeração
user function CRIASXE()

	local cNumero  		:= ""
	local cNumQry		:= ""
	local cNumREC		:= ""
	local cNumDB		:= ""
	local aArea 		:= getArea()
	local cTabelaSX8	:= paramIXB[1]
	local cCpoSX8   	:= paramIXB[2]
	local cID_SX8	 	:= paramIXB[3]
	local nOrdSX8   	:= paramIXB[4]
	local cQuery 		:= ""
	local cCpoFilial	:= ""

	Local lSchedule     := FWGetRunSchedule()
	Local lInterface    := IsBlind()

	//caso um dos parametros venham nulos
	if valtype( cTabelaSX8 ) = 'U';
	 .or. valtype( cCpoSX8 ) = 'U';
	 .or. valtype( cID_SX8 ) = 'U';
	 .or. valtype( nOrdSX8 ) = 'U'
	
		return nil
	
	endif
	
	cCpoFilial	:= left( cCpoSX8, at("_", cCpoSX8) ) + "FILIAL"
	
	//bloco que busca o ultimo numero pelo RECNO
	cQuery += " SELECT " + CRLF
	cQuery += " 	TOP 1 MAX(R_E_C_N_O_) AS RECNO, " + cCpoSX8 + " AS NUMERO " + CRLF
	cQuery += " FROM " + RetSqlName( cTabelaSX8 ) + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " 	D_E_L_E_T_ = '' " + CRLF
	cQuery += " 	AND " + cCpoFilial + " = '" + xFilial( cTabelaSX8 ) + "' " + CRLF
	cQuery += " GROUP BY " + cCpoSX8 + CRLF
	cQuery += " ORDER BY MAX(R_E_C_N_O_) DESC " + CRLF
	
	MemoWrite( "c:\temp\queryCRIASXE.txt", cQuery )
	
	TCQUERY ChangeQuery( cQuery ) New Alias CRIA_SXE
	
	cNumREC := CRIA_SXE->RECNO
	cNumQry := CRIA_SXE->NUMERO
	
	CRIA_SXE->( dbCloseArea() )
	
	if empty( cNumREC )
		return nil
	endif
	
	cNumero := SOMA1(cNumQry)	
	// FIM bloco que busca o ultimo numero pelo RECNO
	
	//bloco que busca o ultimo numero pelo código da tabela
	dbselectArea( cTabelaSX8 )
	( cTabelaSX8 )->( dbSetOrder( nOrdSX8 ) )
	( cTabelaSX8 )->( dbGoBottom() )
	cNumDB := &( cCpoSx8 )
	//FIM bloco que busca o ultimo numero pelo código da tabela
	
	
	//sugerimos a seguinte numeração para dar sequencia

	If !lInterface
	
		MsgGet2( "Indique o numero correto para a tabela: " + cTabelaSX8,;
		         "Campo: " + cCposx8 + " " + CRLF + ;
		         "Ultimo Nº tabela: " + cNumDB + " " + CRLF + ;
		         "Ultimo Nº incluso: " + cNumQry + " " + CRLF,;	 
		@cNumero, , , )	
	EndIf	
	
	restArea( aArea )

return cNumero




