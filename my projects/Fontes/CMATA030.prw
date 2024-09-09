#include 'Totvs.ch'

User Function CMATA030()
Local lOk		:= .T.

Local aCliente	:= {}
Local aAI0Auto  := {}
Local cCodCGC   :=""
Local cQuery	:= ""
Local cAliasT	:= GetNextAlias()
Local cError    :=""
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.



IF lOk
	cCodCGC := StrTran( StrTran( StrTran( '45543915000181',"." ), "-" ),"/" )
	
	cQuery := " SELECT Count(*) AS EXISTE,"
	cQuery += "        A1_COD,"
	cQuery += "        A1_LOJA"
	cQuery += " FROM " + RetSQLName("SA1")
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") 	+ "'"
	cQuery += "   AND A1_CGC    = '" + cCodCGC      +"'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery += " GROUP BY A1_COD,A1_LOJA"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->EXISTE > 0
		
		ConOut("CNPJ/CPF existente - " + cCodCGC )
		lOk := .F.
		SetRestFault( 97, "CNPJ ja existe no sistema: "+( cAliasT )->A1_COD + " e Loja: " + ( cAliasT )->A1_LOJA )
		
	Else
		//ConOut("Antes teste numero! " + cCodCli)
		//cCodCli := GetSXENum("SA1","A1_COD")
		//ConOut("Teste numero! " + cCodCli)
		
		
		
		
		aAdd(aCliente, {"A1_FILIAL"	 , ""   				, Nil} )
		aAdd( aCliente, {"A1_COD"    , "006734"    	        , Nil} )
		aAdd( aCliente, {"A1_LOJA"   , "0001"				, Nil} )
		aAdd( aCliente, {"A1_PESSOA" , "J" 	    , Nil} )
		aAdd( aCliente, {"A1_CGC"    , "45543915000181"	  	    , Nil} )
		aAdd( aCliente, {"A1_NOME"   , "EDNEI TESTE"	  	, Nil} )
		aAdd( aCliente, {"A1_CONTATO", "EDNEI" 	, Nil} )
		aAdd( aCliente, {"A1_NREDUZ" , "EDNEI REDUZ"  	, Nil} )
		aAdd( aCliente, {"A1_TIPO"   , "R"    	            , Nil} )
		aAdd( aCliente, {"A1_CEP"    , "95860000"           , Nil} )
		aAdd( aCliente, {"A1_END"    , "TAQUARI TESTE"     	, Nil} )
		aAdd( aCliente, {"A1_BAIRRO" , "BAIRRO TESTE"   	, Nil} )
		aAdd( aCliente, {"A1_EST" 	 , "RS"     	, Nil} )
		aAdd( aCliente, {"A1_COD_MUN", "14902" 	, Nil} )
		aAdd( aCliente, {"A1_INSCR"	 , "ISENTO"   	, Nil} )
		aAdd( aCliente, {"A1_INSCRM" , ""  	, Nil} )
		aAdd( aCliente, {"A1_DDD" 	 , ""    	, Nil} )
		aAdd( aCliente, {"A1_TEL" 	 , "997901595"    	, Nil} )
		aAdd( aCliente, {"A1_EMAIL"  , "EDYYMAIS@GMAIL.COM"  	, Nil} )
		aAdd( aCliente, {"A1_PAIS"   , "105"	   	, Nil} )
		aAdd( aCliente, {"A1_NATUREZ", ""     , Nil} )
		aAdd( aCliente, {"A1_RISCO"  , "E"	    , Nil} )
		aAdd( aCliente, {"A1_VEND"   , "000029"		, Nil} )
		aAdd( aCliente, {"A1_TPESSOA", "CI"    , Nil} )
		aAdd( aCliente, {"A1_TPJ" 	 , "2"		    , Nil} )
		aAdd( aCliente, {"A1_MSBLQL" , "1"	    , Nil} )
		aAdd( aCliente, {"A1_CODZHO" , "283432843284234"	    , Nil} )
		aAdd(aCliente,	{"A1_INCISS" , "N" 			,Nil} )
		aAdd(aCliente,	{"A1_GRPVEN" , "000001" 	,Nil} )
		 
		
		//---------------------------------------------------------
		// Dados do Complemento do Cliente
		//---------------------------------------------------------
		aAdd(aAI0Auto,{"AI0_SALDO" ,1 ,Nil})
		
		//------------------------------------
		// Chamada para cadastrar o cliente.
		//------------------------------------
		MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, 3, aAI0Auto)
		
		//MSExecAuto({|x,y| Mata030(x,y)},aCliente,3) //3- Inclusão, 4- Alteração, 5- Exclusão
		
		If (!lMsErroAuto) // OPERAÇÃO FOI EXECUTADA COM SUCESSO
			ConOut(PadC("Automatic routine successfully ended", 80))
			SetRestFault( 99, "Incluido." )
			//ConfirmSX8()
			
			
		Else // OPERAÇÃO EXECUTADA COM ERRO
			If (!IsBlind()) // COM INTERFACE GRÁFICA
				
				lOk := .F.
				SetRestFault( 98, "Erro ao incluir Pedido de Venda COM INTERFACE GRÁFICA.")
				//RollBackSX8()
			Else // EM ESTADO DE JOB
				cError := MostraErro("restEdnei.log") // ARMAZENA A MENSAGEM DE ERRO
				ConOut(PadC("Automatic routine ended with error "+cError, 80))
				
				//RollBackSX8()
				lOk := .F.
				SetRestFault( 98, "Erro ao incluir Pedido de Venda EM ESTADO DE JOB."+cError)
			EndIf
		EndIf
		
	Endif
	( cAliasT )->( dbCloseArea() )
EndIf
