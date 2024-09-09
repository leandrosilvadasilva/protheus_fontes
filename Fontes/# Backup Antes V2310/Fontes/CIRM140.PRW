#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc}                                                                                                                      
Função de Servico Web service para integracao do Pedido de Venda 
@author Jeferson Silva
@since 28/12/2019
@version 1.0
@return Nil,
@example
u_CIRM140()
/*/
WSRESTFUL M140PEDVEN DESCRIPTION "API para Integracao do Pedido de Venda do Protheus."

	WSDATA C5_FILIAL	AS STRING
	WSDATA C5_NUM		AS STRING	
	WSDATA C5_TIPO 		AS STRING
	WSDATA C5_CLIENTE	AS STRING
	WSDATA C5_LOJACLI	AS STRING
	WSDATA C5_EMISSAO	AS STRING
	
	WSMETHOD GET  	DESCRIPTION "Lista entidades no Pedido de Venda do Protheus."	WSSYNTAX "/m140pedven?c5_filial=0101&c5_num=432198"
	
END WSRESTFUL
 
/*/{Protheus.doc}                                                                                                                      
Metodo para listagem do Pedido de Vendas do Protheus 
@author Jeferson Silva
@since 28/12/2019
@version 1.0
@return Nil,
@example
Metodo GET
/*/
WSMETHOD GET WSRECEIVE C5_FILIAL,C5_NUM,C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_EMISSAO WSSERVICE M140PEDVEN

	Local cQuery		:= ""
	Local cAliasT		:= GetNextAlias()
	Local cMsg	  		:= ""
	Local cNumPed		:= ""
	Local cC5Fil		:= ""
	Local nX			:= 0
	Local nY			:= 0
	Local lOK			:= .T.	
	 
	::SetContentType("application/json")	// define o tipo de retorno do mÈtodo

	ConOut("Executando Metodo GET Pedido de Venda")
	
	//+--------------------------------------------------------+
	//| Verificar se passou pelo menos a filial como parametro |
	//+--------------------------------------------------------+
	If Empty( ::C5_FILIAL )
	
		lOK := .F.
		
		cMsg := "Informar filial nos parametros."
		SetRestFault( 1, "Informar filial nos parametros." )
	
	EndIf
	
	If lOK
	
		If AllTrim( ::C5_FILIAL ) == "0"
			cC5Fil := Space( TamSX3("C5_FILIAL")[01] )
		Else
			cC5Fil := PadR( ::C5_FILIAL, TamSX3("C5_FILIAL")[01] )
		EndIf

		cQuery := " SELECT SC5.C5_FILIAL,"
		cQuery += "        SC5.C5_NUM,"
      	cQuery += "        SC5.C5_TIPO,"
	   	cQuery += "        SC5.C5_CLIENTE,"
	  	cQuery += "        SC5.C5_LOJACLI,"
	  	cQuery += "        SC5.C5_EMISSAO,"
		cQuery += "        SC6.C6_FILIAL,"		
	   	cQuery += "        SC6.C6_ITEM,"
	   	cQuery += "        SC6.C6_NUM,"
	   	cQuery += "        SC6.C6_PRODUTO,"
	   	cQuery += "        SC6.C6_DESCRI,"
	   	cQuery += "        SC6.C6_QTDVEN,"
	   	cQuery += "        SC6.C6_PRCVEN,"
	   	cQuery += "        SC6.C6_QTDLIB,"
	   	cQuery += "        SC6.C6_VALOR"
	   	
		cQuery += " FROM " + RetSQLName("SC5") + " SC5, "
		cQuery +=            RetSQLName("SC6") + " SC6" 
		cQuery += " WHERE SC5.C5_FILIAL = '" + cC5Fil + "'"
		
	  	If !Empty( ::C5_NUM ) 	  	
	  		cQuery += "   AND SC5.C5_NUM  = '" + ::C5_NUM + "'"	  		
	  	EndIf
	  	
	  	If !Empty( ::C5_TIPO )
	  		cQuery += "   AND SC5.C5_TIPO  = '" + ::C5_TIPO + "'"
	  	EndIf
	  	
	  	If !Empty( ::C5_CLIENTE )
	  		cQuery += "   AND SC5.C5_CLIENTE  = '" + ::C5_CLIENTE + "'"
	  	EndIf
	  	
	  	If !Empty( ::C5_LOJACLI )
	  		cQuery += "   AND SC5.C5_LOJACLI  = '" + ::C5_LOJACLI + "'"
	  	EndIf
	  	
	  	If !Empty( ::C5_EMISSAO )
	  		cQuery += "   AND SC5.C5_EMISSAO  = '" + ::C5_EMISSAO + "'"
	  	EndIf
  		
  		cQuery += "   AND SC6.C6_FILIAL  = SC5.C5_FILIAL"
  		cQuery += "   AND SC6.C6_NUM     = SC5.C5_NUM"
  		
  		cQuery += "   AND SC5.D_E_L_E_T_ = ' '"   		  		  		
  		cQuery += "   AND SC6.D_E_L_E_T_ = ' '"   		  		  		
  		cQuery += " ORDER BY SC5.C5_NUM"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),cAliasT,.F.,.T. )

		If ( cAliasT )->( !EOF() )
				
			::SetResponse('[')
							
			While ( cAliasT )->( !EOF() )
			
				cNumPed := ( cAliasT )->C5_NUM

				If nY >= 1
					::SetResponse(',')
				EndIf
																						
				::SetResponse('{"C5_NUM":'		+ CHR(34)	 + cNumPed						  		+ CHR(34)	+;
							',"C5_FILIAL":'		+ CHR(34)	 + AllTrim( ( cAliasT )->C5_FILIAL )	+ CHR(34)	+;
							',"C5_TIPO":'		+ CHR(34)	 + ( cAliasT )->C5_TIPO			   		+ CHR(34)	+;														
							',"C5_CLIENTE":'	+ CHR(34)	 + ( cAliasT )->C5_CLIENTE 		  		+ CHR(34)	+;
							',"C5_LOJACLI":'	+ CHR(34)	 + ( cAliasT )->C5_LOJACLI 				+ CHR(34)	+;							
							',"C5_EMISSAO":'	+ CHR(34)	 + DtoC(StoD( ( cAliasT )->C5_EMISSAO ))+ CHR(34)	+',')
																													
				::SetResponse('"itens":[')
  		  		
				While ( cAliasT )->( !EOF() ) .And. AllTrim( cNumPed ) == AllTrim( ( cAliasT )->C5_NUM )
				
					If nX >= 1
						::SetResponse(',')
					EndIf					

					::SetResponse('{"C6_ITEM":'	+ CHR(34)	+ ( cAliasT )->C6_ITEM 				+ CHR(34)	+;
								',"C6_NUM":'	+ CHR(34)	+ ( cAliasT )->C6_NUM 				+ CHR(34)	+;	
								',"C6_FILIAL":'	+ CHR(34)	+ ( cAliasT )->C6_FILIAL			+ CHR(34)	+;
								',"C6_PRODUTO":'+ CHR(34)	+ AllTrim( ( cAliasT )->C6_PRODUTO )+ CHR(34)	+;
								',"C6_DESCRI":'	+ CHR(34)	+ AllTrim( ( cAliasT )->C6_DESCRI ) + CHR(34)	+;
								',"C6_PRCVEN":'	+ cValToChar( ( cAliasT )->C6_PRCVEN )		  	+;
								',"C6_QTDLIB":'	+ cValToChar( ( cAliasT )->C6_QTDLIB )		  	+;
								',"C6_QTDVEN":'	+ cValToChar( ( cAliasT )->C6_QTDVEN )		 	+;
								',"C6_VALOR":'	+ cValToChar( ( cAliasT )->C6_VALOR )		 	+'}')
			   		nX++
			   	 	
					( cAliasT )->( dbSkip() )
		  			
				EndDo
								
				::SetResponse(']')
				
				nX := 0
				nY++
	  	
	  			::SetResponse('}')
	  			
	  		EndDo
	  		
	  		nY := 0
	  		::SetResponse(']')
	  		
			( cAliasT )->( dbCloseArea() )
					  	
		Else
							
			lOK	:= .F.
			SetRestFault( 2, "Nao existem Pedidos de venda a serem listados." )			
			
		EndIf
		
  	EndIf	
	
Return( lOK )

