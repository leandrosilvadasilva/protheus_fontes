#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FR650FIL

P.E. no processamento do relatório de retorno de cobrança

@type function
@version  
@author dwt.luciano
@since 30/11/2023
@return variant, return_description
@see http://tdn.totvs.com.br/pages/releaseview.action?pageId=173081174

Estrutura de aValores passado por parâmetro - FINA200
PARAMIXB := {  	Numero do T¡tulo	- 01	,
				data da Baixa		- 02	,
				Tipo do T¡tulo		- 03	,
				Nosso Numero		- 04	,
				Valor da Despesa	- 05	,
				Valor do Desconto	- 06	,
				Valor do Abatiment	- 07	,
				Valor Recebido    	- 08	,
				Juros				- 09	,
				Multa				- 10	,
				Valor do Credito	- 11	,
				Data Credito		- 12	,
				Ocorrencia			- 13	,
				Linha Inteira		- 14	}


TODO
	[ ] - Criar um indice com E2_COD, E2_LOJA, E2_VENCTO, E2_VALOR

/*/
User Function FR650FIL()
Local aTmpParamIXB := PARAMIXB                  as ARRAY
Local aTmpLeitura  := aLeitura                  as ARRAY
Local lRetorno     := .F.                       as BOOLEAN

Local cCNPJ        := aTmpLeitura[20]           as ARRAY
Local lTmpDDA      := !Empty( aTmpLeitura[25] ) as Character
Local lCtasPagar   := MV_PAR07 = 2              as BOOLEAN

Local cTmpNumTit   := aTmpLeitura[01]           as ARRAY

Local cAliasSA2    := GetNextAlias()            as Character
Local cAliasSE2    := GetNextAlias()            as Character

Local nValorTit    := aTmpParamIXB[01][08]          as NUMERIC
Local cDataVcto    := DtoS(aTmpParamIXB[1][02])    as Character

    If lCtasPagar  
    
        If lTmpDDA .and. !Empty(cCNPJ)

			BEGINSQL Alias cAliasSA2

				SELECT SA2.A2_FILIAL, SA2.A2_COD, SA2.A2_LOJA, SA2.A2_CGC
				FROM %Table:SA2% SA2
				WHERE 1=1
				  AND SA2.A2_FILIAL = %Exp:FWxFilial("SA2")%
				  AND SA2.A2_CGC    = %Exp:cCNPJ%
				  AND SA2.%NotDel%
				ORDER BY %Order:SA2%
			ENDSQL

			cQyerySA2 := GetLastQuery()[2]

			If (cAliasSA2)->(!Eof())

				cChaveSE2  := (cAliasSA2)->(A2_COD + A2_LOJA)
				cCodFornec := (cAliasSA2)->(A2_COD)
				cLojaForec := (cAliasSA2)->(A2_LOJA)

				BEGINSQL Alias cAliasSE2

					SELECT SA2.A2_FILIAL, SA2.A2_COD, SA2.A2_LOJA
					FROM %Table:SE2% SE2
					WHERE 1=1
  				      AND SE2.E2_FILIAL  = %Exp:FWxFilial("SE2")%
                      AND SE2.E2_FORNECE = %Exp:cCodFornec%
					  AND SE2.E2_FORNECE = %Exp:cLoja%
					  AND SE2.E2_LOJA    = %Exp:cLoja%
					  AND SE2.E2_VENCTO  = %Exp:cDataVcto%
					  ANd SE2.E2_VALOR   = %Exp:nValorTit%
					  AND SE2.%NotDel%
					ORDER BY %Order:SE2%
				ENDSQL

				cQuerySE2 := GetLastQuery()[2]
				
				If (cAliasSE2)->(!Eof())

					lRetorno := .T.
				EndIf
			EndIf
			(cAliasSA2)->(dbCloseArea())
        Else

            // Faz o padrão,  o que "ja fez antes" de entrar nesse PE
			// que não curti fazer  :-(
            SE2->(dbSetOrder(13))
            If !Empty(cTmpNumTit) .and. MsSeek(cTmpNumTit)

                lRetorno := .T.
            EndIf
        EndIf

    EndIf

Return lRetorno
