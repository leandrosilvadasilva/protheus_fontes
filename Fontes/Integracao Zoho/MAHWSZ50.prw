#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "TbiConn.ch" 
//Opcoes ExecAuto
#Define PD_INCLUIR 3

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MERWS050 � Autor � Jeferson Dambros      � Data � Ago/2017 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X AIS.        ���
���          � Pedido de venda.                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente MERIDIONAL MEAT                         ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSRESTFUL MAHPEDVENDA DESCRIPTION "Pedido de Venda"

WSDATA C5_FILIAL  AS STRING  // FILIAL = '0101' ou '0102' ou '0103' ou '0104'
WSDATA C5_CLIENTE AS STRING  // Codigo Protheus do Modulo de Conta
WSDATA C5_LOJACLI AS STRING  // Loja Protheus do Modulo de Conta
WSDATA C5_PEDCLI  AS STRING  // Numero pedido do cliente
WSDATA C5_TIPOCLI AS STRING  // Tipo do cliente do modulo de conta
WSDATA C5_TRANSP  AS STRING  // Codigo da transportadora do modulo de condicao
WSDATA C5_CONDPAG AS STRING  // Codigo da condicao de pagamento do modulo condicao
WSDATA C5_TABELA  AS STRING  // codigo da tabela de preco modulo tabela de preco
WSDATA C5_FORPG   AS STRING  // Codigo Forma de pagamento modulo forma de pagamento
WSDATA C5_OBSEXPE AS STRING  // Observacao do estoque
WSDATA C5_OBSNFSE AS STRING  // Observaao da nota
WSDATA C5_VEND1   AS STRING  // Codigo vendedor tamanho Char 6
WSDATA C5_TPFRETE AS STRING  // CIF OU FOB
WSDATA C5_FRETE   AS STRING  // Valor do Frete
WSDATA C5_ZTPLIBE AS STRING  // Libera Parcial 1=Sim 2=Nao
WSDATA C5_EMISSAO AS STRING  // Data emissao pedido formato aaaammdd
WSDATA OPERACAO   AS STRING  // Codigoda operacao do modulo de operacao
WSDATA C5_PACIENT AS STRING  // Char 60 Campo Nome do Paciente
WSDATA C5_CODMED  AS STRING  // Char 06 Codigo do Medico
WSDATA C5_NOMMED  AS STRING  // Char 60 Nome do Medico
WSDATA C5_CODCONV AS STRING  // Char 06 Codigo do Convenio
WSDATA C5_NOMCONV AS STRING  // Char 60 Nome do convenio
WSDATA C5_CODZHO  AS STRING  // Char 50 Codigo Zoho
WSDATA C6_PRODUTO AS STRING	 // Codigo do produto protheus do modulo de produtos
WSDATA C6_QTDVEN  AS STRING	 // Quantidade vendida
WSDATA C6_PRCVEN  AS STRING	 // preco de venda
WSDATA C6_OPER    AS STRING  // Codigoda operacao do modulo de operacao
WSDATA C6_PRUNIT  AS STRING  // preco da tabela do modulo de tabela de preco
WSDATA C6_ENTREG  AS STRING  // data de entrega (solucao stor7)
WSDATA C6_CODZHO  AS STRING  // Char 50 Codigo Zoho
WSDATA C5_LICITA  AS STRING  // 1=SIM 2=NAO Se 'e oriundo de licitacao'
WSDATA C5_ZCODPRC AS STRING  // Codigo do procedimento 
WSDATA C5_ZDESPRC AS STRING  // Nome Procedimento
WSDATA C5_ZCLIRET AS STRING  // Codigo do procedimento 
WSDATA C5_ZLOJRET AS STRING  // Nome Procedimento
WSDATA C5_DPROCED AS STRING  // Data do procedimento
WSDATA C5_ARMAZEM AS STRING  // ARMAZEM OPME

WSMETHOD POST DESCRIPTION "Incluir Pedido de Venda." WSSYNTAX "/"

END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � POST     �Autor  � Jeferson Dambros   � Data �  Ago/2017   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para incluir Pedido de venda.                       ���
�������������������������������������������������������������������������͹��
���Uso       � MERWS050                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE MAHPEDVENDA

Local lOk		:= .T.
Local cBody		:= ::GetContent()
Local cMsg		:= ""
Local cNumPed	:= ""
Local cErro  	:= ""
Local cQuery	:= ""
Local cArea		:= ""
Local cBlCred	:= ""
Local aMsg		:= {}
Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local nX		:= 0
Local cNatAux   :="" 
Local cNat      :=""
Local cForpag   :=""
Local oJson     
Local oJsonBAQ := JsonObject():New()
Local cFilPed   :=""
Local cFilEmp   :=""
Local cNoSld    :=""
Local cPrdSld    :=""
Local clotSld    :=""
Local cTestOrdem :=""
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

PRIVATE oJsonBAK := NIL


ConOut('Chamada do Metodo: MAHPEDVENDA')
Conout(cBody)

::SetContentType("application/json")//Define o tipo de retorno do metodo

If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
	
	lOk := .F.
	SetRestFault( 1, "Nao foi possivel processar a estrutura Json." )
	
Else
	
    IF oJson:OPERACAO = '15'
        If EMPTY(oJson:C5_ZCLIRET) .or. EMPTY(oJson:C5_ZLOJRET)
        	lOk := .F.
        	SetRestFault( 6, "Para realizar um retorno e preciso preencher Cliente Solicitante e Loja Solicitante! ")
		Endif
    Endif
    
    IF nVldZho(oJson:C5_CODZHO)>0
    	lOk := .F.
		SetRestFault( 2, "Codigo Zoho ja cadastrado "+oJson:C5_CODZHO)
    endif 
	
	//+---------------------------------------+
	//| Verifica se o cliente esta cadastrado |
	//+---------------------------------------+
	cFilEmp:=substr(oJson:C5_FILIAL,1,2)
	cFilPed:=oJson:C5_FILIAL

	//RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cFilEmp,cFilPed,,,,GetEnvServer(),{"SC5","SC6"} )

	dbSelectArea("SA1")
	dbSetOrder(1)
	If !dbSeek( xFilial("SA1") + PadR( oJson:C5_CLIENTE, TamSX3("A1_COD")[01] ) + oJson:C5_LOJACLI )
		
		lOk := .F.
		SetRestFault( 3, "Cliente nao cadastrado no sistema." )
		
	EndIf
	
	/*IF !EMPTY(oJson:C5_ZCLIRET) .AND. !EMPTY(oJson:C5_ZLOJRET)
		
		For nX := 1 To Len( oJson:itens )
			IF nSldB6(oJson:C5_ZCLIRET,oJson:C5_ZLOJRET,oJson:itens[nX]:C6_PRODUTO)<Val(oJson:itens[nX]:C6_QTDVEN) 				
				cNoSld += oJson:itens[nX]:C6_PRODUTO+" - "
			else
			    If EMPTY(clotSld)
			    	clotSld+="'"+oJson:itens[nX]:C6_PRODUTO+"'"
			    else
			        clotSld+=",'"+oJson:itens[nX]:C6_PRODUTO+"'"
			    endif
			endif
		Next nX	
	
		If !EMPTY(cNoSld)
			SetRestFault( 4, "Produto(s) sem saldo para retorno: "+cNoSld )
			U_eOpme03(oJson:C5_FILIAL+' - ZOHO: '+oJson:C5_CODZHO,Upper( oJson:C5_OBSEXPE ),oJson:C5_CLIENTE+' - '+oJson:C5_LOJACLI,'retorno',AllTrim(getMV("ES_WFEMA03")),oJson:C5_ZCLIRET,oJson:C5_ZLOJRET,clotSld)
			lOk := .F.
		Endif
	
	ENDIF*/
	cTestOrdem:=""
	cTestOrdem:=cPedCli(oJson:C5_PEDCLI,oJson:C5_CLIENTE,oJson:C5_LOJACLI)
	IF cTestOrdem<>''
	   
	        SetRestFault( 5, "Esta ordem de compra ja foi utilizada no "+cTestOrdem )
			lOk := .F.
	Endif
	
	
	
	If lOk
		cNat :=""
		DO CASE
			CASE oJson:OPERACAO $ '01/26/07' // Operacao de Revenda
				
				cNat := '111101'
				// sempre do cliente 
			CASE oJson:OPERACAO  $ "04/05/06/08/09/10/11/12/13/14/17/18/19/20/21/27/28/"
			    cNat := '811101'
			CASE oJson:OPERACAO = '15'
                cNat := '111102'
                // se a natureza for 111206
				// conteudo cnat= nova natureza
				// caso contrario=111102
            CASE oJson:OPERACAO = '22'
			 	cNat := '111202'    
			CASE oJson:OPERACAO = '60'
                cNat := '833108'    
			CASE oJson:OPERACAO $ '61/62/63/64'	
				cNat := '811101'    
            OTHERWISE
				cNat := '111101'
				
		ENDCASE
		
		// Forma de pagamento
		DO CASE
			
			CASE oJson:C5_FORPG $ 'Boleto' // Operacao de Revenda
				
				 cForpag := 'BO'
				
			CASE oJson:C5_FORPG $ 'Carteira a Vista' // Operacao de Revenda
				
				 cForpag := 'R$'
			    
            CASE 'Credito' $ oJson:C5_FORPG //oJson:C5_FORPG $ 'Cart�o de Credito' // Operacao de Revenda

				cForpag := 'CC'
				
			CASE oJson:C5_FORPG $ 'Cheque' // Operacao de Revenda
				
				cForpag := 'CH'
			
			CASE oJson:C5_FORPG $ 'Deposito em Conta' // Operacao de Revenda
				
				cForpag := 'DC'
			
			CASE oJson:C5_FORPG $ 'Pague Seguro' // Operacao de Revenda
				
				cForpag := 'PS'
            			
			OTHERWISE
				
				cForpag :=''
				
		ENDCASE
		
		ConOut("> WSPEDIDO02"+CRLF+;
        "  VALIDOU Operacao "+CRLF+;
        "  Operacao"+oJson:OPERACAO+" cNat: "+ cNat )
		//------------------------------------------------
		// Se for natureza de revenda 
		
		cNatAux :=""
		If cNat == "111101"
        	cNatAux:=cRetNat( oJson:C5_CLIENTE,oJson:C5_LOJACLI)
			If Empty( cNatAux)
					cNatAux:= cNat
			EndIf
			cNat:=cNatAux
		Else
			cNatAux := cNat
		EndIf

        //------------------------------------------------
		// Se for natureza de revenda 
		
		If cNat == "111102" 
        	cNatAux :=""
			cNatAux:=cRetNat( oJson:C5_CLIENTE,oJson:C5_LOJACLI)
			If Empty( cNatAux) .or. cNatAux<>'111206'
					cNatAux:= cNat
			
			else			    
				if   cNatAux=='111206'
			       cNatAux:='111214'  
				endif   

			EndIf
			
		Else
			cNatAux := cNat
		EndIf

		
		ConOut("> WSPEDIDO03"+CRLF+;
        "  VALIDOU Natureza "+CRLF+;
        "  Operacao"+oJson:OPERACAO+" cNat: "+ cNatAux )
		
		//cNumPed	:= GetSxeNum("SC5","C5_NUM")
		//RollBackSX8()
	   
		VarInfo( "MAHPEDVENDA - oJson - aCab ANTES", oJson )        

		aAdd( aCabec,{"C5_FILIAL"  , oJson:C5_FILIAL	    					        , Nil} )
		//aAdd( aCabec,{"C5_NUM" 	   , cNumPed										    , Nil} )
		aAdd( aCabec,{"C5_TIPO"    , "N"												, Nil} )
		aAdd( aCabec,{"C5_CLIENTE" , PadR( oJson:C5_CLIENTE, TamSX3("A1_COD")[01] )		, Nil} )
		aAdd( aCabec,{"C5_LOJACLI" , PadR( oJson:C5_LOJACLI, TamSX3("A1_LOJA")[01])		, Nil} )
		aAdd( aCabec,{"C5_PEDCLI"  , oJson:C5_PEDCLI									, Nil} )
		aAdd( aCabec,{"C5_TIPOCLI" , oJson:C5_TIPOCLI									, Nil} )
		aAdd( aCabec,{"C5_NATUREZ" , cNatAux				     						, Nil} )
		aAdd( aCabec,{"C5_TRANSP"  , oJson:C5_TRANSP									, Nil} )
		aAdd( aCabec,{"C5_CONDPAG" , oJson:C5_CONDPAG									, Nil} )
		aAdd( aCabec,{"C5_FORPG"   , cForpag									    	, Nil} ) 
		aAdd( aCabec,{"C5_TABELA"  , oJson:C5_TABELA									, Nil} )
		aAdd( aCabec,{"C5_OBSEXPE" , Upper(oJson:C5_OBSEXPE)							, Nil} )
		aAdd( aCabec,{"C5_OBSNFSE" , Upper(oJson:C5_OBSNFSE)							, Nil} )
		aAdd( aCabec,{"C5_VEND1"   , oJson:C5_VEND1								    	, Nil} )
		aAdd( aCabec,{"C5_TPFRETE" , IIF(!Empty(oJson:C5_TPFRETE),oJson:C5_TPFRETE,'S')	, Nil} )
		aAdd( aCabec,{"C5_FRETE"   , Val(oJson:C5_FRETE)								, Nil} )
		aAdd( aCabec,{"C5_ZTPLIBE" , oJson:C5_ZTPLIBE									, Nil} )
		aAdd( aCabec,{"C5_EMISSAO" , SToD(oJson:C5_EMISSAO)						    	, Nil} )
		aAdd( aCabec,{"C5_PACIENT" , oJson:C5_PACIENT						     		, Nil} )
		aAdd( aCabec,{"C5_ZCLIRET" , oJson:C5_ZCLIRET						     		, Nil} )
		aAdd( aCabec,{"C5_DPROCED" , SToD(oJson:C5_DPROCED)								, Nil} )
		aAdd( aCabec,{"C5_ZLOJRET" , oJson:C5_ZLOJRET						     		, Nil} )
		IF !EMPTY(oJson:C5_CODMED)
			aAdd( aCabec,{"C5_CODMED"  , oJson:C5_CODMED								, Nil} )
		End
		//IF !EMPTY(oJson:C5_NOMMED)
		//	aAdd( aCabec,{"C5_NOMMED"  , oJson:C5_NOMMED							, Nil} )
		//End
		IF !EMPTY(oJson:C5_CODCONV)
			aAdd( aCabec,{"C5_CODCONV" , oJson:C5_CODCONV							, Nil} )
		End
		//IF !EMPTY(oJson:C5_NOMCONV)
		//	aAdd( aCabec,{"C5_NOMCONV" , oJson:C5_NOMCONV							, Nil} )
		//End
		aAdd( aCabec,{"C5_CODZHO"  , oJson:C5_CODZHO								, Nil} )
		IF !EMPTY(oJson:C5_ZCODPRC)
			aAdd( aCabec,{"C5_ZCODPRC" , oJson:C5_ZCODPRC							, Nil} )
		End
		//IF !EMPTY(oJson:C5_ZDESPRC)
		//	aAdd( aCabec,{"C5_ZDESPRC" , oJson:C5_ZDESPRC								, Nil} )
		//End
		aAdd( aCabec,{"C5_LICITA"  , oJson:C5_LICITA								, Nil} )
		cItem := StrZero( 0, TamSX3("C6_ITEM")[1] )
		
		For nX := 1 To Len( oJson:itens )
			
			cItem := Soma1(cItem)
			
			aLinha := {}
			aAdd( aLinha,{"C6_ITEM"		, cItem														, Nil} )
			aAdd( aLinha,{"C6_PRODUTO"	, PadR( oJson:itens[nX]:C6_PRODUTO, TamSX3("B1_COD")[01] )	, Nil} )
			aAdd( aLinha,{"C6_QTDVEN"	, Val(oJson:itens[nX]:C6_QTDVEN) 							, Nil} )
			aAdd( aLinha,{"C6_QTDLIB"	, Val(oJson:itens[nX]:C6_QTDVEN)							, Nil} )
			aAdd( aLinha,{"C6_PRCVEN"	, Val(oJson:itens[nX]:C6_PRCVEN)							, Nil} )
			aAdd( aLinha,{"C6_ENTREG"	, SToD(oJson:itens[nX]:C6_ENTREG)							, Nil} )
			
			
			If cNatAux $ '111102/111214'
				SaldoLocal(oJson:C5_FILIAL,oJson:itens[nX]:C6_PRODUTO)
				aAdd( aLinha,{"C6_LOCAL"	, IIF (oJson:C5_ARMAZEM	$ '06|07',oJson:C5_ARMAZEM,'07') , Nil} )
			Endif 
			
			If !Empty( oJson:itens[nX]:C6_OPER )
				aAdd( aLinha,{"C6_OPER"	, oJson:itens[nX]:C6_OPER	, Nil} )
				if alltrim(oJson:itens[nX]:C6_OPER) $ '05|06|11'
					aAdd( aLinha,{"C6_LOCAL", '03' , Nil} )
				endif
			Else
				aAdd( aLinha,{"C6_TES"	, oJson:itens[nX]:C6_TES	, Nil} )
			EndIf
			
			aAdd( aLinha,{"C6_PRUNIT"	, Val(oJson:itens[nX]:C6_PRUNIT) , Nil} )
			aAdd( aLinha,{"C6_CODZHO"	, oJson:itens[nX]:C6_CODZHO		 , Nil} )
			aAdd( aItens, aLinha )
			
		Next nX

		VarInfo( "MAHPEDVENDA - oJson - ExecAuto ANTES", oJson )

		oJsonBAK := oJson
		oJsonBAQ := oJson

		lMsErroAuto    := .F.
		lAutoErrNoFile := .T.
		
		MSExecAuto( {|x,y,z| MATA410(x,y,z)}, aCabec, aItens, PD_INCLUIR )
		
		If lMsErroAuto
			
			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })
			
			lOk := .F.
			SetRestFault( 7, "Erro ao incluir Pedido de Venda." + CRLF + cErro )
			
			ConOut("> WSPEDIDO03"+CRLF+;
			"  Erro ao incluir Pedido de Venda. "+CRLF+;
			"  VALIDOU Numero Pedido "+CRLF+;
			"  Ordem Venda Zoho  "+oJson:C5_CODZHO+CRLF+;
			"  Operacao"+oJson:OPERACAO )

			Conout( "Erro ao incluir Pedido de Venda." + CRLF + cErro )
		
		Else
			::SetResponse('{')
			::SetResponse('"PEDIDO"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse( SC5->C5_NUM  )
			::SetResponse('"')
			::SetResponse('}')
			
			VarInfo( "MAHPEDVENDA - oJson - ExecAuto DEPOIS", oJson )
			
			
			ConOut("> WSPEDIDO03"+CRLF+;
			"  Pedido Incluido com Sucesso "+CRLF+;
			"  Ordem Venda Zoho  "+oJsonBAK:C5_CODZHO+CRLF+;
			"  Operacao"+oJsonBAK:OPERACAO+" cPed: "+ SC5->C5_NUM )
			


			If cNatAux $ '111102/111214' .And. !EMPTY(oJsonBAK:C5_ZCLIRET) .AND. !EMPTY(oJsonBAK:C5_ZCLIRET)
				U_eOpme01(oJsonBAK:C5_FILIAL+' - '+SC5->C5_NUM +' - Armazem Retorno: '+oJsonBAK:C5_ARMAZEM,Upper( oJsonBAK:C5_OBSEXPE ),oJsonBAK:C5_CLIENTE+' - '+oJsonBAK:C5_LOJACLI,'retorno',AllTrim(getMV("ES_WFEMA01")),oJsonBAK:C5_ZCLIRET,oJsonBAK:C5_ZLOJRET,clotSld)
			endif

			U_EmailEst(oJsonBAK:C5_CLIENTE,oJsonBAK:C5_LOJACLI,SC5->C5_NUM ,oJsonBAK:C5_FILIAL)

			atuTrig1(oJsonBAK:C5_FILIAL,SC5->C5_NUM )
			atuTrig2(oJsonBAK:C5_FILIAL,SC5->C5_NUM )
			atuTrig3(oJsonBAK:C5_FILIAL,SC5->C5_NUM )

		EndIf
	EndIf
EndIf
Return( lOk )




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � WS050CRE �Autor  � Jeferson Dambros   � Data �  Ago/2017   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retornar avaliacao de credito.                             ���
�������������������������������������������������������������������������͹��
���Uso       � MERWS050                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function WS050CRE( cC5Blq, cC5Num )

Local cQuery  := ""
Local cBlCred := "1" // 1 = Ok,  0 =  de Credito / Regra


If !Empty( cC5Blq )
	
	cBlCred := "0"
	
Else
	
	cQuery := " SELECT C9_BLCRED "
	cQuery += " FROM " + RetSQLName("SC9")
	cQuery += " WHERE	C9_FILIAL	= '" + xFilial("SC9") + "'"
	cQuery += "		AND	C9_PEDIDO	= '" + cC5Num + "'"
	cQuery += "		AND	D_E_L_E_T_ <> '*'"
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	While (cArea)->( !Eof() )
		
		If !Empty( (cArea)->C9_BLCRED )
			
			cBlCred := "0"
			
			Exit
			
		EndIf
		
		(cArea)->( dbSkip() )
		
	EndDo
	
	(cArea)->( dbCloseArea() )
	
EndIf

Return( cBlCred )

Static Function cRetNat( cZcli,cZloja)
Local cZNatCli    := ""
Local cAliasTMP3 := 'TMP3'

BeginSql Alias cAliasTMP3
	SELECT SA1.A1_NATUREZ 
	FROM %Table:SA1% SA1 
	WHERE SA1.A1_FILIAL = %xFilial:SA1% 
	AND SA1.A1_COD      = %Exp:cZcli%
	AND SA1.A1_LOJA     = %Exp:cZloja%
	AND SA1.%notdel%
EndSql

cZNatCli  := AllTrim((cAliasTMP3)->A1_NATUREZ )

(cAliasTMP3)->( dbCloseArea() )
Return( cZNatCli )



static function atuTrig2(cC5Filial,cC5Num)

Local nRet:=0
Local cQurery2:=""

cQurery2:=""
cQurery2+=" UPDATE SC5010 SET    "
cQurery2+=" C5_NOMCONV=ZA2_NOME  "



cQurery2+=" FROM SC5010 "
cQurery2+=" INNER JOIN ZA2010 ZA2 ON (ZA2.ZA2_CODIGO=C5_CODCONV) "
cQurery2+=" WHERE C5_FILIAL='" + cC5Filial + "'"
cQurery2+=" AND C5_NUM='" + cC5Num + "'"
cQurery2+=" AND ZA2.D_E_L_E_T_ <> '*' "
cQurery2+=" AND SC5010.D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQurery2)
If nRet<>0
	ConOut("Erro ao atualizar nome do medico no pedido" + TCSQLERROR())
Endif


return

static function atuTrig1(cC5Filial,cC5Num)

Local nRet:=0
Local cQurery1:=""

cQurery1:=""
cQurery1+=" UPDATE SC5010 SET     "
cQurery1+=" C5_NOMMED=ZA1_NOME   "



cQurery1+=" FROM SC5010 "
cQurery1+=" INNER JOIN ZA1010 ZA1 ON (ZA1.ZA1_CODIGO=C5_CODMED)  "

cQurery1+=" WHERE C5_FILIAL='" + cC5Filial + "'"
cQurery1+=" AND C5_NUM='" + cC5Num + "'"
cQurery1+=" AND ZA1.D_E_L_E_T_ <> '*' "
cQurery1+=" AND SC5010.D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQurery1)
If nRet<>0
	ConOut("Erro ao atualizar nome do medico no pedido" + TCSQLERROR())
Endif


return


static function atuTrig3(cC5Filial,cC5Num)

Local nRet:=0
Local cQurery3:=""

cQurery3:=""
cQurery3+=" UPDATE SC5010 SET     "
cQurery3+=" C5_ZDESPRC=ZA4_DESCRI "


cQurery3+=" FROM SC5010 "
cQurery3+=" INNER JOIN ZA4010 ZA4 ON (ZA4.ZA4_COD=C5_ZCODPRC) "

cQurery3+=" WHERE C5_FILIAL='" + cC5Filial + "'"
cQurery3+=" AND C5_NUM='" + cC5Num + "'"
cQurery3+=" AND ZA4.D_E_L_E_T_ <> '*' "
cQurery3+=" AND SC5010.D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQurery3)
If nRet<>0
	ConOut("Erro ao atualizar nome do medico no pedido" + TCSQLERROR())
Endif


return

static function nVldZho(cZoho)

Local nRet   :=0
Local cArea	 := ""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ+=" SELECT COUNT(C5_CODZHO) C5_CODZHO  "
cQueryZ+=" FROM SC5010 "
cQueryZ+=" WHERE "
cQueryZ+=" C5_CODZHO='" + cZoho + "'"
cQueryZ+=" AND SC5010.D_E_L_E_T_ <> '*' "
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
IF (cArea)->C5_CODZHO >0
	nRet:=1
endif
(cArea)->( dbCloseArea() )
return nRet



static function cPedCli(cPedCli,cClien,cLoja)

Local cRet   :=""
Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ+=" SELECT ISNULL(C5_PEDCLI,'')C5_PEDCLI,C5_CODZHO,C5_NUM "
cQueryZ+=" FROM SC5010 "
cQueryZ+=" WHERE "
cQueryZ+=" C5_PEDCLI ='" + cPedCli + "'"
cQueryZ+=" AND C5_CLIENTE='" + cClien  + "'"
cQueryZ+=" AND C5_LOJACLI='" + cLoja   + "'"
cQueryZ+=" AND SC5010.D_E_L_E_T_ <> '*' "
cQueryZ+=" AND C5_CODZHO<>'' "
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)

IF AllTrim((cArea)->C5_PEDCLI)=""
	cRet:=AllTrim((cArea)->C5_PEDCLI)
else
	cRet:="PV - "+AllTrim((cArea)->C5_NUM)+" COD ZOHO - "+AllTrim((cArea)->C5_NUM)
endif 
(cArea)->( dbCloseArea() )
return cRet




static function nSldB6(cCliRet,cLojaRet,cProduto)

Local cQuery :=""

	cQuery := " SELECT "
	cQuery += " ISNULL(SUM(B6_SALDO),0) SALDO "
	cQuery += " FROM " + RetSQLName("SB6")+ " SB6 " 	
	cQuery += " INNER JOIN  " + RetSQLName("SD2") + " SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_IDENTB6=SB6.B6_IDENT AND SD2.D_E_L_E_T_<>'*')  "  
	cQuery += " INNER JOIN  " + RetSQLName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "   
	cQuery += " INNER JOIN  " + RetSQLName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')    JOIN SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
	cQuery += " WHERE SB6.D_E_L_E_T_ <> '*'"
	cQuery += " AND SB6.B6_SALDO>0  "
	cQuery += " AND SB6.B6_TES IN ('697','722')  "
	cQuery += " AND SB6.B6_CLIFOR ='" +cCliRet+ "'  "
	cQuery += " AND SB6.B6_LOJA ='" + cLojaRet+ "'  "
	cQuery += " AND SB6.B6_PRODUTO ='" +cProduto+ "'  "

	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	dbSelectArea(cArea)
	nRet:= (cArea)->SALDO
	(cArea)->( dbCloseArea() )
return nRet

STATIC Function RemovChar(cRet)
Local cRet

cRet	:= upper(cRet)

cRet	:= STRTRAN(cRet,"�","A")
cRet	:= STRTRAN(cRet,"�","E")
cRet	:= STRTRAN(cRet,"�","I")
cRet	:= STRTRAN(cRet,"�","O")
cRet	:= STRTRAN(cRet,"�","U")
cRet	:= STRTRAN(cRet,"�","A")
cRet	:= STRTRAN(cRet,"�","E")
cRet	:= STRTRAN(cRet,"�","I")
cRet	:= STRTRAN(cRet,"�","O")
cRet	:= STRTRAN(cRet,"�","U")
cRet	:= STRTRAN(cRet,"�","A")
cRet	:= STRTRAN(cRet,"�","O")
cRet	:= STRTRAN(cRet,"�","A")
cRet	:= STRTRAN(cRet,"�","E")
cRet	:= STRTRAN(cRet,"�","I")
cRet	:= STRTRAN(cRet,"�","O")
cRet	:= STRTRAN(cRet,"�","U")
cRet	:= STRTRAN(cRet,"�","A")
cRet	:= STRTRAN(cRet,"�","E")
cRet	:= STRTRAN(cRet,"�","I")
cRet	:= STRTRAN(cRet,"�","O")
cRet	:= STRTRAN(cRet,"�","U")
cRet	:= STRTRAN(cRet,"�","C")   

Return(cRet)



static function SaldoLocal(cFilP,cProduto)

Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ+=" SELECT COUNT(B9_COD) NID "
cQueryZ+=" FROM SB9010 "
cQueryZ+=" WHERE "
cQueryZ+=" B9_LOCAL='07' "
cQueryZ+=" AND B9_FILIAL='" +cFilP+ "'  "
cQueryZ+=" AND B9_COD   ='" +cProduto+ "'  "
cQueryZ+=" AND D_E_L_E_T_ <> '*' "
cQueryZ := ChangeQuery(cQueryZ)	
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)

IF (cArea)->NID=0
	U_zGeraB9(cFilP,cProduto, '07', 0)
Endif 	
(cArea)->( dbCloseArea() )
return 


User Function zGeraB9(cFilArm,cCodProd, cArmazem , nQuant)
Local aArea := GetArea()
 
DbSelectArea("SB9")
DbSetOrder(1) //B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
 
//Setando valores da rotina autom�tica
lMsErroAuto := .F.
aVetor :={;
{"B9_FILIAL" ,cFilArm                           ,Nil},;
{"B9_COD"    ,cCodProd                          ,Nil},;
{"B9_LOCAL"  ,"07"                              ,Nil},;
{"B9_DATA"   ,dDataBase                         ,Nil},;
{"B9_QINI"   ,nQuant                            ,Nil}}
 
//Iniciando transa��o e executando saldos iniciais
Begin Transaction
MSExecAuto({|x,y| Mata220(x,y)}, aVetor)
 
//Se houve erro, mostra mensagem
If lMsErroAuto
lHouveErro := .T.
MostraErro()
DisarmTransaction()
EndIf
End Transaction
 
RestArea(aArea)
Return

