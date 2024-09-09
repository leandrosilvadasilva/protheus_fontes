#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "TbiConn.ch" 

//Opcoes ExecAuto 
#Define PD_INCLUIR 3 
#Define PD_ALTERAR 4 
#Define PD_EXCLUIR 5   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHTRG10 ³ Autor ³ Ednei R. Silva      ³ Data ³ MAR/2020   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para instalar trigger.                              ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA  Hospitalar                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL MAHADDCLI DESCRIPTION "Incluir Cliente" 

WSDATA A1_NOME     AS STRING //(60) Razao social
WSDATA A1_NREDUZ   AS STRING //(30) Nome Fantasia 
WSDATA A1_CGC      AS STRING //(14) CNPJ
WSDATA A1_EST      AS STRING //(2)  UF do Cliente
WSDATA A1_COD_MUN  AS STRING //(5)  Codigo do Municipio
WSDATA A1_INSCR    AS STRING //(18) Inscricao Estadual
WSDATA A1_INSCRM   AS STRING //(18) Inscricao Municipal
WSDATA A1_DDD      AS STRING //(3)  DDD 
WSDATA A1_TEL      AS STRING //(15) Telefone
WSDATA A1_EMAIL    AS STRING //(100) Email
WSDATA A1_PAIS     AS STRING //(3) Codigo do País               
WSDATA A1_NATUREZ  AS STRING //(10) Codigo da Nat Financeira    (Sera preenchido pelo protheus)
WSDATA A1_RISCO    AS STRING //(1)  Grau de Risco do cliente    (Sera preenchido pelo protheus)
WSDATA A1_VEND     AS STRING //(6) Vendedor Protheus
WSDATA A1_PESSOA   AS STRING //(1) F=Fisica;J=Juridica                                                                                                              
WSDATA A1_TPESSOA  AS STRING //(2) Tipo do Cliente CI=Comercio/Industria;PF=Pessoa Fisica;OS=Prestacäo de Servico;EP=Empresa Publica                                               
WSDATA A1_TPJ      AS STRING //(1) Tipo de pessoa Juridica 1=ME - Micro Empresa;2=EPP - Empresas de Pequeno Porte;3=MEI - Microempreendedor Individual;4=Não Optante                       
WSDATA A1_CODZHO   AS STRING //(50)ID ZOHO -
WSDATA A1_MSBLQL   AS STRING //1=Inactivo;2=Activo                                                                                                              
WSDATA A1_TIPO     AS STRING //(1) Tipo do Cliente F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao                                                             
WSDATA A1_CEP      AS STRING //(8)  CEP
WSDATA A1_END      AS STRING //(80) Endereco
WSDATA A1_BAIRRO   AS STRING //(40) Bairro
WSDATA A1_CONTATO  AS STRING //(15) Contato
WSDATA A1_COND     AS STRING //(60) Condicao sugerida
WSDATA A1_FORMA    AS STRING // forma de pagamento
WSDATA A1_LIMITE   AS STRING // Valor venda maximo cliente 		
WSDATA A1_CONTFIN  AS STRING // Contato Financeiro
WSDATA A1_MAILFIN  AS STRING // Email Financeiro
	
WSMETHOD POST DESCRIPTION "Incluir cliente." WSSYNTAX "/" 
WSMETHOD PUT DESCRIPTION "Atualiza cliente." WSSYNTAX "/" 
//WSMETHOD GET DESCRIPTION "Consulta cliente." WSSYNTAX "/MAHADDCLI" 
	
END WSRESTFUL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ POST     ºAutor  ³ Ednei Silva        º Data ³  Ago/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para incluir Pedido de venda.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MA Hospitalar                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE MAHADDCLI

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local aCliente	:= {}
	Local oJson 
	Local cCodCGC   :=""
	Local cCodCli	:=""
	Local cCodLoja	:="0001"
	Local cQuery	:= ""
	Local cAliasT	:= GetNextAlias()
	Local aMsg		:= {}
	Local cErrorLog	:= ""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
    ConOut('Chamada do Metodo: MAHADDCLI')
	Conout(cBody)

	::SetContentType("application/json")//Define o tipo de retorno do metodo	
				
	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
	
		lOk := .F.
		SetRestFault( 1, "Nao foi possivel processar a estrutura Json." )	

	Else
		
		
		If Empty( oJson:A1_NOME )
			lOk := .F.	 				
	 		SetRestFault( 90, "Campo obrigatorio: RAZAO SOCIAL." )
		Endif 
		
		If Empty( oJson:A1_PESSOA )
			lOk := .F.	 				
	 		SetRestFault( 91, "Campo obrigatorio: PESSOA J ou F." )
		Endif  
		
		If Empty( oJson:A1_END )
		    lOk := .F.	 				
	 		SetRestFault( 92, "Campo obrigatorio: ENDERECO." )
		Endif 
		 
		If Empty( oJson:A1_NREDUZ ) 
		    lOk := .F.	 				
	 		SetRestFault( 93, "Campo obrigatorio: NOME FANTASIA." )
		Endif 	
		
		If Empty( oJson:A1_TIPO ) 
			lOk := .F.	 				
	 		SetRestFault( 94, "Campo obrigatorio: TIPO." )
		Endif 
		
		If Empty( oJson:A1_EST ) 
		    lOk := .F.	 				
	 		SetRestFault( 95, "Campo obrigatorio: UF." )
		Endif 
		//If Empty( oJson:A1_COD_MUN )
		//	lOk := .F.	 				
	 	//	SetRestFault( 96, "Campo obrigatorio: NOME." )
		//Endif 
   
	      
      IF lOk
	   cCodCGC := StrTran( StrTran( StrTran( oJson:A1_CGC,"." ), "-" ),"/" )
		
	   cQuery := " SELECT Count(*) AS EXISTE,"
	   cQuery += "        A1_COD,"
	   cQuery += "        A1_LOJA"
	   cQuery += " FROM  SA1010 " // + RetSQLName("SA1")
	   cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") 	+ "'"
	   cQuery += "   AND A1_CGC    = '" + cCodCGC      +"'"
	   cQuery += "   AND D_E_L_E_T_<>'*'"
	   cQuery += " GROUP BY A1_COD,A1_LOJA"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
		If ( cAliasT )->EXISTE > 0
			if empty(oJson:A1_CONTFIN) .and. empty(oJson:A1_MAILFIN)
				ConOut("CNPJ/CPF existente e sem dados para atualizar - " + cCodCGC )
				lOk := .F.	 				
				SetRestFault( 97, "CNPJ ja existe no sistema e sem dados para atualizar: "+( cAliasT )->A1_COD + " e Loja: " + ( cAliasT )->A1_LOJA )	
			else
				DbSelectArea("SA1")			
				SA1->(DbSetOrder(3))
				if SA1->(DBSeek(xFilial("SA1")+cCodCGC))
					RecLock("SA1",.F.)
						SA1->A1_CONTFIN := oJson:A1_CONTFIN
						SA1->A1_MAILFIN := oJson:A1_MAILFIN	
					SA1->(MsUnlock())
					ConOut(PadC("Cliente atualizado", 80))
	        		SetRestFault( 100, "Cliente Atualizado." )
					lOk := .T.	 				
				endif
			endif
		Else
		    
			//cCodCli := GetSXENum("SA1","A1_COD")
	        
			cCodZHO := oJson:A1_CODZHO				
			cZHOVend := oJson:A1_VEND
			cZHOCOND := oJson:A1_COND
			cZHOForma := oJson:A1_FORMA
			cZHOLimite := oJson:A1_LIMITE			
		 
			aAdd(aCliente, {"A1_FILIAL"	 , ""   						, Nil} )
			//aAdd( aCliente, {"A1_COD"    , cCodCli    	        		, Nil} )
			aAdd( aCliente, {"A1_LOJA"   , "0001"						, Nil} )
			aAdd( aCliente, {"A1_PESSOA" , UPPER(oJson:A1_PESSOA) 	    , Nil} )
			aAdd( aCliente, {"A1_CGC"    , oJson:A1_CGC			  	    , Nil} )
			aAdd( aCliente, {"A1_NOME"   , UPPER(oJson:A1_NOME)		  	, Nil} )
			aAdd( aCliente, {"A1_CONTATO", UPPER(oJson:A1_CONTATO)	 	, Nil} )		
			aAdd( aCliente, {"A1_NREDUZ" , UPPER(oJson:A1_NREDUZ)	  	, Nil} )
			aAdd( aCliente, {"A1_TIPO"   , UPPER(oJson:A1_TIPO)    		, Nil} )
			aAdd( aCliente, {"A1_CEP"    , oJson:A1_CEP         		, Nil} )
			aAdd( aCliente, {"A1_END"    , UPPER(oJson:A1_END)	     	, Nil} )
			aAdd( aCliente, {"A1_BAIRRO" , UPPER(oJson:A1_BAIRRO)	  	, Nil} )
			aAdd( aCliente, {"A1_EST" 	 , UPPER(oJson:A1_EST)	     	, Nil} )
			aAdd( aCliente, {"A1_COD_MUN", oJson:A1_COD_MUN	  			, Nil} )	
			aAdd( aCliente, {"A1_INSCR"	 , oJson:A1_INSCR   			, Nil} )
			aAdd( aCliente, {"A1_INSCRM" , oJson:A1_INSCRM  			, Nil} )		
			aAdd( aCliente, {"A1_DDD" 	 , oJson:A1_DDD     			, Nil} )
			aAdd( aCliente, {"A1_TEL" 	 , oJson:A1_TEL     			, Nil} )
			aAdd( aCliente, {"A1_EMAIL"  , oJson:A1_EMAIL   			, Nil} )
			aAdd( aCliente, {"A1_PAIS"   , oJson:A1_PAIS	   			, Nil} )	
			aAdd( aCliente, {"A1_NATUREZ", oJson:A1_NATUREZ    		    , Nil} )
			aAdd( aCliente, {"A1_RISCO"  , "E"	                		, Nil} )
			aAdd( aCliente, {"A1_VEND"   , oJson:A1_VEND				, Nil} )	
			aAdd( aCliente, {"A1_TPESSOA", oJson:A1_TPESSOA	   			, Nil} )
			aAdd( aCliente, {"A1_TPJ" 	 , oJson:A1_TPJ		   			, Nil} )
			aAdd( aCliente, {"A1_MSBLQL" , oJson:A1_MSBLQL	    		, Nil} )
			aAdd( aCliente, {"A1_CODZHO" , oJson:A1_CODZHO	    		, Nil} )			
	        aAdd( aCliente, {"A1_CONTFIN" , oJson:A1_CONTFIN	    	, Nil} )			
			aAdd( aCliente, {"A1_MAILFIN" , oJson:A1_MAILFIN	    	, Nil} )			
	        
		 	MSExecAuto({|x,y,z| CRMA980(x,y,z)}, aCliente,3,{}) //3- Inclusão, 4- Alteração, 5- Exclusão
			//MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)


	        If (!lMsErroAuto) // OPERAÇÃO FOI EXECUTADA COM SUCESSO

				cCodCli := SA1->A1_COD

	        	ConOut(PadC("Automatic routine successfully ended", 80))
	        	SetRestFault( 99, "Incluido." )
				ConfirmSX8()
				::SetResponse('{')
				::SetResponse('"A1_CODZHO"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( cCodZHO  )
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"A1_COD"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( cCodCli  )
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"A1_LOJA"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( cCodLoja  )
				::SetResponse('"')
				::SetResponse('}')


	       		 u_eConta(cCodCli,'0001', cZHOVend, cCodZHO, cZHOCOND, cZHOForma, cZHOLimite)
			Else // OPERAÇÃO EXECUTADA COM ERRO
	        	If (!IsBlind()) // COM INTERFACE GRÁFICA
	   		 
	        			lOk := .F.				 				
	        			SetRestFault( 98, "Erro ao incluir cliente.")
				        RollBackSX8()
	        	Else // EM ESTADO DE JOB
	        			cErrorLog := "ERRO - "
	        			aMsg := GetAutoGRLog()
	        			aEval(aMsg,{|x| cErrorLog += x + Space(1) })
	        			//cError := MostraErro("restEdnei.log") // ARMAZENA A MENSAGEM DE ERRO
	        			
	        			ConOut(cErrorLog)
	        		
	        			RollBackSX8()			 
	        			lOk := .F.				 				
	        			SetRestFault( 98,cErrorLog)
	            EndIf
            EndIf 
		      
		 Endif	
		 ( cAliasT )->( dbCloseArea() )	 		
		EndIf
	EndIf
	
Return( lOk )

WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE MAHADDCLI

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local oJson 
	Local cCodCGC   :=""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	ConOut('Chamada do Metodo: MAHADDCLI')
	Conout(cBody)
	::SetContentType("application/json")//Define o tipo de retorno do metodo	
	if !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
		lOk := .F.
		SetRestFault( 1, "Nao foi possivel processar a estrutura Json." )	
	else
		if Empty( oJson:A1_CGC )
			lOk := .F.	 				
	 		SetRestFault( 90, "Campo obrigatorio: CNPJ." )
		endif 
		if lOk .and. empty(oJson:A1_CONTFIN) .and. empty(oJson:A1_MAILFIN)
			lOk := .F.	 				
	 		SetRestFault( 91, "Não há dados para atualizar: Contato financeiro e email do contat" )
		endif  
	endif
	if lOk
	   cCodCGC := StrTran( StrTran( StrTran( oJson:A1_CGC,"." ), "-" ),"/" )
		DbSelectArea("SA1")			
		SA1->(DbSetOrder(3))
		if SA1->(DBSeek(xFilial("SA1")+cCodCGC))
			RecLock("SA1",.F.)
				SA1->A1_CONTFIN := oJson:A1_CONTFIN
				SA1->A1_MAILFIN := oJson:A1_MAILFIN	
			SA1->(MsUnlock())
			ConOut(PadC("Cliente atualizado", 80))
			SetRestFault( 100, "Cliente Atualizado." )
			lOk := .T.	 				
		else
			ConOut(PadC("Cliente nao localizado", 80))
	        SetRestFault( 100, "Cliente nao localizado." )
			lOk := .F.	 				
		endif
	endif
Return( lOk )
/*
WSMETHOD GET WSRECEIVE A1_CGC WSSERVICE MAHADDCLI

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local aCliente	:= {}
	Local oJson 
	Local cCodCGC   :=""
	Local cCodCli	:=""
	Local cCodLoja	:=""
	Local cQuery	:= ""
	Local cAliasT	:= GetNextAlias()
	Local aMsg		:= {}
	Local cErrorLog	:= ""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
    ConOut('Chamada do Metodo: MAHADDCLI')
	Conout(cBody)

	::SetContentType("application/json")//Define o tipo de retorno do metodo	
				
		
		If Empty( ::A1_CGC ) 
		    lOk := .F.	 				
	 		SetRestFault( 95, "Campo obrigatorio: CNPJ." )
		Endif 
      IF lOk
	    cCodCGC := StrTran( StrTran( StrTran( ::A1_CGC,"." ), "-" ),"/" )
		DbSelectArea("SA1")			
		SA1->(DbSetOrder(3))
		if SA1->(DBSeek(xFilial("SA1")+cCodCGC))
			ConOut(PadC("Automatic routine successfully ended", 80))
			SetRestFault( 99, "Localizado." )
			::SetResponse('{')
			::SetResponse('"A1_CODZHO"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse( SA1->A1_CODZHO  )
			::SetResponse('"')
			::SetResponse(',')
			::SetResponse('"A1_COD"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse( SA1->A1_COD  )
			::SetResponse('"')
			::SetResponse(',')
			::SetResponse('"A1_LOJA"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse( SA1->A1_LOJA  )
			::SetResponse('"')
			::SetResponse('}')
			lOk := .T.	 				
		else
			SetRestFault( 100, "Cliente não Localizado." )
			lOk := .F.	 				
		endif
	//EndIf
	
Return( lOk )
*/

