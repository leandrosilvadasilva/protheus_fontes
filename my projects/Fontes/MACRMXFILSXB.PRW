#INCLUDE "PROTHEUS.CH" 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXFilSXB

Filtra as consultas padrao para o CRM.

@sample 	CRMXFilSXB(cAlias)

@param		ExpC1 - Alias Atual

@Return   	ExpC - Codicao do filtro

@author		Ednei Silva 
@since		20/04/2018
@version	12.0
/*/
//------------------------------------------------------------------------------

Static oMapKey := THashMap():New()

USER Function MACRMXFilSXB(cAliasEnt)

Local cFiltro		:= ""
Local cAliasAO4		:= GetNextAlias()
Local cChaveAO4     := ""
Local cCodUsr    	:= ""
Local cKeyUnique	:= ""
Local aMapKey		:= {}
Local lRetorno   	:= .T.
Local aRegistros	:= {}

Default cAliasEnt	:= ""

If !Empty(cAliasEnt) .And. nModulo == 73
	
	cCodUsr		:= RetCodUsr()

	If ( Empty( oMapKey ) .Or. ( ! oMapKey:Get( "FILSXB" + cAliasEnt + cCodUsr, @aMapKey ) ) )	
	
		cFiltro := CRMXFilEnt(cAliasEnt,.T.)
	
	If !Empty(cFiltro)
		
			cFiltro :=	 "%" + cFiltro + "%"
		
			If Select(cAliasAO4) > 0
				(cAliasAO4)->(DbCloseArea())
	EndIf
			
			BeginSql Alias cAliasAO4
				SELECT AO4.AO4_CHVREG
				FROM %Table:AO4% AO4
				WHERE AO4.AO4_FILIAL = %xFilial:AO4% AND %Exp:cFiltro% AND AO4.%NotDel%
			EndSql
			
			While (cAliasAO4)->( !(Eof() ) )
				aAdd(aRegistros, (cAliasAO4)->AO4_CHVREG )
				(cAliasAO4)->( DbSkip() )
				End
				
			(cAliasAO4)->(DbCloseArea())

			cKeyUnique	:= AllTrim(CRMXGetSX2(cAliasEnt)[1])
			aMapKey := { cKeyUnique, cFiltro, aRegistros }
			oMapKey:Set( "FILSXB" + cAliasEnt + cCodUsr, aMapKey ) 
			EndIf
		
		EndIf
		
	If !Empty(aMapKey)
		cChaveAO4	:= PadR( xFilial( cAliasEnt ) + (cAliasEnt)->&(aMapKey[1]) , TAMSX3("AO4_CHVREG")[1] ) 	
		lRetorno := ( ! aScan(aMapKey[3],{|x| x == cChaveAO4 } ) == 0 ) 
	EndIf
	
EndIf

Return(lRetorno)