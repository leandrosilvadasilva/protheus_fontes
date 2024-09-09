#INCLUDE "PROTHEUS.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MAHWORD   ºAutor  ³Expedito Mendonca   º Data ³  28/12/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenchimento de variaveis da proposta comercial usando   º±±
±±º          ³a integracao com o WORD.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente MA Hospitalar                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MAHWORD()
Local aArea			:= GetArea()						//Armazena area atual
Local hWord 		:= ParamIXB[1]						//Objeto usado para preenchimento
Local cProposta		:= Space(TamSX3("CJ_PROPOST")[1])	//Numero da proposta comercial
Local cDtEmissao	:= Space(TamSX3("CJ_EMISSAO")[1])	//Data de emissao
Local cCodigo		:= Space(TamSX3("A1_COD")[1])		//Codigo da entidade (cliente ou prospect)
Local cLoja			:= Space(TamSX3("A1_LOJA")[1])		//Loja
Local cNome 		:= Space(TamSX3("A1_NOME")[1])		//Nome
Local cEndereco		:= Space(TamSX3("A1_END")[1])   	//Endereco
Local cBairro		:= Space(TamSX3("A1_BAIRRO")[1])   //Bairro
Local cCidade		:= Space(TamSX3("A1_MUN")[1])  	//Cidade       
Local cCep			:= Space(TamSX3("A1_CEP")[1])  	//CEP 
Local cCgc			:= Space(TamSX3("A1_CGC")[1])  	//CPF do cliente 
Local cUF			:= Space(TamSX3("A1_ESTADO")[1])  	//Estado (UF)   
Local cIE			:= Space(TamSX3("A1_INSCRM")[1])  	//Inscricao estadual
Local cCliTel		:= Space(TamSX3("A1_ESTADO")[1])  	//Telefone do Cliente    
Local cPRevisa		:= ' '                              //Revisao dos itens da proposta comercial gravado na tabela ADZ
Local aCronoFin		:= {}								//Array que armazena o cronograma financeiro
Local aTipo09		:= {}								//Array que armazena o tipo de pagamento 9
Local nTotProp		:= 0								//Total da proposta comercial
Local nI			:= 0                               	//Usado no laco do While
Local nX            := 0                                //Usado no laco do For
Local nY			:= 0								//Usado no laco do While
Local nCount		:= 0								//Incremento para utilizar no itens de cond. pagto.   
Local cContato      := Space(3)  						//Contato    
Local cPathWord 	:= GetMV("MV_PATWORD")  
Local cValorExt		:=' '  
local cDescPag		:=' ' // Descricao da condicao de pagamento
local cVendedor		:=' ' // Vendedor da proposta 
local cTelefone		:=' ' // Telefone do Vendedor 
local cEmail		:=' ' //E-mail do Vendedor                                 
local cMunMA 		:=' ' //Municipio da proposta
local cFrete 		:=' ' //Tipo de Frete 
local cGaran		:=' ' //Garantia                                                          
local cForPg		:=' ' //Forma de pagameto 
local cVigencia     :=' ' // Tempo de vigencia do contrato
Local cNOport    	:=' ' //Numero da oportunidade
aSX5				:=' '
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le dados do cabecalho da proposta comercial (Tabela ADY)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cProposta	:= ADY->ADY_PROPOS
cNOport     := ADY->ADY_OPORTU 
cPRevisa	:= ADY->ADY_PREVIS
cDescEnt	:= Space(30)
cDtEmissao	:= Dtoc(ADY->ADY_DATA)
aCronoFin	:= Ft600CroFin(cProposta,cPRevisa,aTipo09)
cObserv    	:= ADY->ADY_OBS               
cGaran    	:= ADY->ADY_GARANT
cTpProp     := AG1->AG1_CODIGO   //AD1->AD1_TPPROP   
cVigencia	:= ADY->ADY_TMPVIG 
//cNOport := "TESTE"
   
//Definir a parte escrita do tipo de frete
If ADY->ADY_TPFRET == "C"             
	cFrete := "CIF"
Elseif ADY->ADY_TPFRET == "F" 
	cFrete := "FOB"
Elseif ADY->ADY_TPFRET == "T"
	cFrete := "POR TERCEIROS" 
Elseif ADY->ADY_TPFRET == "S"
	cFrete := "SEM FRETE"
Endif                                         

//DEFINIR A PARTE ESCRITA DA FORMA DE PAGAMENTO
If ADY->ADY_FORPG == "BO"             
	cForPg := "BOLETO BANCÁRIO"
Elseif ADY->ADY_FORPG == "R$" 
	cForPg := "EM CARTEIRA À VISTA"
Elseif ADY->ADY_FORPG == "CC"
	cForPg := "CARTÃO DECRÉDITO" 
Elseif ADY->ADY_FORPG == "CH"
	cForPg := "CHEQUE"            
Elseif ADY->ADY_FORPG == "DC" 
	cForPg := "DEPÓSITO EM CONTA CORRENTE"  
Elseif ADY->ADY_FORPG == "PS" 
	cForPg := "PAGUE SEGURO"
Endif                                         

If ADY->ADY_ENTIDA == "1"   	// Dados de clientes
	dbSelectArea("SA1")
	dbSetOrder(1)
	If	dbSeek(xFilial("SA1")+ADY->ADY_CODIGO+ADY->ADY_LOJA)
		cCodigo		:= ADY->ADY_CODIGO
		cLoja		:= ADY->ADY_LOJA
		cNome 		:= SA1->A1_NOME
		cEndereco	:= SA1->A1_END
		cBairro		:= SA1->A1_BAIRRO
		cCidade		:= SA1->A1_MUN    
		cCep		:= SA1->A1_CEP    
		cCgc		:= SA1->A1_CGC
		cUF			:= SA1->A1_EST 
		cIE			:= SA1->A1_INSCRM
		cDescEnt	:= SA1->A1_NREDUZ             
		cCliTel 	:= Alltrim(SA1->A1_DDD) + ' ' + Alltrim(SA1->A1_TEL)  
	Endif
Else							// Dados de prospects
	dbSelectArea("SUS")
	dbSetOrder(1)
	If	dbSeek(xFilial("SUS")+ADY->ADY_CODIGO+ADY->ADY_LOJA)
		cCodigo		:= ADY->ADY_CODIGO
		cLoja		:= ADY->ADY_LOJA 
		cNome 		:= SUS->US_NOME
		cEndereco	:= SUS->US_END
		cBairro		:= SUS->US_BAIRRO
		cCidade		:= SUS->US_MUN
		cUF			:= SUS->US_EST
		cDescEnt	:= SUS->US_NREDUZ
	Endif
Endif
  
If AD1->AD1_CANAL == "000002"             
	cMunMA := "Porto Alegre"
Elseif AD1->AD1_CANAL == "000003"
	cMunMA := "Itajaí"
Elseif AD1->AD1_CANAL == "000004"
	cMunMA := "Curitiba"
Endif
             
cNomeWord	:=	''
cNomeWord	:= 'P'+cProposta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descricao da Oportunidade de Venda         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetDocumentVar(hWord,'cDesOport',Capital(POSICIONE("AD1",1,xFilial("AD1")+ADY->ADY_OPORTU,"AD1_DESCRI")))
//OLE_SetDocumentVar(hWord,'cNOport',Capital(POSICIONE("AD1",1,xFilial("AD1")+ADY->ADY_OPORTU,"AD1_NROPOR")))

// Nome do contato                  
AD9->(dbSetOrder(1))	// AD9_FILIAL+AD9_NROPOR+AD9_REVISA+AD9_CODCON
AD9->(dbSeek(xFilial("AD9")+AD1->AD1_NROPOR+AD1->AD1_REVISA,.F.))
cContato := POSICIONE("SU5",1,xFilial("SU5")+AD9->AD9_CODCON,"U5_CONTAT") 

//Condicao de pagamento
cDescPag := POSICIONE("SE4",1,xFilial("SE4")+ADY->ADY_CONDPG,"E4_DESCRI") 

// Dados do Vendedor 
cVendedor := POSICIONE("SA3",1,xFilial("SA3")+ADY->ADY_VEND,"A3_NOME")
cTelefone := Alltrim(SA3->A3_DDDTEL) + ' ' + Alltrim(SA3->A3_TEL)       
cEmail    := alltrim(SA3->A3_EMAIL)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza variaveis do cabecalho - Variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetDocumentVar(hWord,'cProposta'	,cProposta)
OLE_SetDocumentVar(hWord,'cNOport'	    ,cNOport )
OLE_SetDocumentVar(hWord,'cDtEmissao'	,cDtEmissao)
OLE_SetDocumentVar(hWord,'cCodigo'		,cCodigo)
OLE_SetDocumentVar(hWord,'cNome'		,cNome)
OLE_SetDocumentVar(hWord,'cEndereco'	,cEndereco)
OLE_SetDocumentVar(hWord,'cBairro'		,cBairro)
OLE_SetDocumentVar(hWord,'cCep'			,cCep)
OLE_SetDocumentVar(hWord,'cCgc'			,cCgc)
OLE_SetDocumentVar(hWord,'cCidade'		,cCidade)
OLE_SetDocumentVar(hWord,'cUF'			,cUF) 
OLE_SetDocumentVar(hWord,'cIE'			,cIE)  
OLE_SetDocumentVar(hWord,'cCliTel' 		,cCliTel)
OLE_SetDocumentVar(hWord,'cContato'		,cContato)
OLE_SetDocumentVar(hWord,'cDescPag'		,cDescPag)
OLE_SetDocumentVar(hWord,'cVendedor'	,cVendedor)   
OLE_SetDocumentVar(hWord,'cTelefone'	,cTelefone) 
OLE_SetDocumentVar(hWord,'cEmail'   	,cEmail)
OLE_SetDocumentVar(hWord,'cFrete'   	,cFrete)   
OLE_SetDocumentVar(hWord,'cObserv'   	,cObserv)   
OLE_SetDocumentVar(hWord,'cGaran'   	,cGaran) 
OLE_SetDocumentVar(hWord,'cMunMA'   	,cMunMA)  
OLE_SetDocumentVar(hWord,'cForPg'   	,cForPg)
OLE_SetDocumentVar(hWord,'cVigencia'   	,cVigencia)  

// AD1_TPPROP   // TIPOS DE PROPOSTA COMERCIAL
//OLE_SetDocumentVar(hWord,'cTipoProposta',POSICIONE("AD1",1,xFilial("AD1")+ADY->ADY_OPORTU,"AD1_TPPROP"))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza variaveis do itens da proposta comercial (Tabela ADZ) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ADZ")
DbSetOrder(3)
If dbSeek(xFilial("ADZ")+cProposta+cPRevisa) 
	
	While ADZ->(!Eof()) .and. xFilial("ADZ") == ADZ->ADZ_FILIAL .AND. cProposta == ADZ->ADZ_PROPOS
		
		nI++                  
		
		cDescProd := Alltrim( Posicione("SB1",1,xFilial("SB1")+ADZ->ADZ_PRODUT,"B1_DESC") )

		// DEFINICAO DAS VARIAVEIS (WORD) PARA CADA MODELO   
		
		If cTpProp == '001'    // SIMPLIFICADA 

			cTxtItem := Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
			//SX5->( dbSeek("    "+"ZX"+SB1->B1_MARCA) )
			aSX5:=FWGetSx5('ZX',SB1->B1_MARCA,'pt-br')
			IF !empty(aSX5[1][1])	
				cTxtMarca:=AllTrim(aSX5[1][4])
			ELSE
				cTxtMarca:=""
			ENDIF
			//cTxtMarca := Alltrim(SX5->X5_DESCRI)
		    OLE_SetDocumentVar(hWord,"cTxtMarca"+Alltrim(str(nI))  , cTxtMarca )      
		    
		    cTxtQuant := Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		    
		    cTxtPrev := Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
		   	
			OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)),Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
	
			OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) ,Transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99"))

		ElseIf cTpProp == '002' //SIMPLIFICADA II COM FOTO
		
			cTxtItem := Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
			//SX5->( dbSeek("    "+"ZX"+SB1->B1_MARCA) )
			//cTxtMarca := Alltrim(SX5->X5_DESCRI)
			IF !empty(aSX5[1][1])	
				cTxtMarca:=AllTrim(aSX5[1][4])
			ELSE
				cTxtMarca:=""
			ENDIF
		    OLE_SetDocumentVar(hWord,"cTxtMarca"+Alltrim(str(nI))  , cTxtMarca )      
		    
		    cTxtQuant := Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		    
		    cTxtPrev := Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
		   	
			OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)),Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
	
			OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) ,Transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99"))
			                                                                             
		   //Carregar FOTOS 
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , " " )
	        EndIf
			
		ElseIf cTpProp == '003' // PROPOSTA COMODATO 

			cTxtItem := "Item: "+ Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := "Código: "+ Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := "Produto: "+cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
		    cTxtQuant := "Quantidade: "+Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		                                                                          
		   	nValUni:= "Valor Unitário: R$ "+Alltrim(Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
		   	OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)) , nValUni )       
		   
		    nTotal:= "Valor total Item: R$ "+Alltrim(transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99")) 
		    OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) , nTotal )  
		   	
			cTxtPrev := "Previsão de Entrega: "+Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
			                                                                                                      
			cTxtFicha := "Ficha Técnica: " + CRLF + Alltrim(SB1->B1_FICHATE )
			OLE_SetDocumentVar(hWord,"cFichaTec"+Alltrim(str(nI)) , cTxtFicha )   
			
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , " " )
	        EndIf
		
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , " " )
	        EndIf

		ElseIf cTpProp == '004' //IMPORTACAO 


			cTxtItem := "Item: "+ Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := "Código: "+ Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := "Produto: "+cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
		    cTxtQuant := "Quantidade: "+Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		   	 
			nValUni:= "Valor Unitário: US$ "+Alltrim(Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
		   	OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)) , nValUni )       
		   
		    nTotal:= "Valor total Item: US$ "+Alltrim(transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99")) 
		    OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) , nTotal )  
			
			cTxtPrev := "Previsão de Entrega: "+Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			 OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
			                                                                                                      
			cTxtFicha := "Ficha Técnica: " + CRLF + Alltrim(SB1->B1_FICHATE )
			OLE_SetDocumentVar(hWord,"cFichaTec"+Alltrim(str(nI)) , cTxtFicha )   
					
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , " " )
	        EndIf
		
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , " " )
	        EndIf

		ElseIf cTpProp == '005'  //LOCACAO

			cTxtItem := "Item: "+ Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := "Código: "+ Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := "Produto: "+cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
		    cTxtQuant := "Quantidade: "+Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
			
			nValUni:= "Valor Unitário: R$ "+Alltrim(Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
		   	OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)) , nValUni )       
		   
		    nTotal:= "Valor total Item: R$ "+Alltrim(transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99")) 
		    OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) , nTotal )    
			
			cTxtPrev := "Previsão de Entrega: "+Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
			                                                                                                      
			cTxtFicha := "Ficha Técnica: " + CRLF + Alltrim(SB1->B1_FICHATE )
			OLE_SetDocumentVar(hWord,"cFichaTec"+Alltrim(str(nI)) , cTxtFicha )   
					
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , " " )
	        EndIf
		
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , " " )
	        EndIf

		ElseIf cTpProp == '006'  //REPRESENTACAO
	

			cTxtItem := "Item: "+ Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := "Código: "+ Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := "Produto: "+cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
		    cTxtQuant := "Quantidade: "+Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		     		                                    
			nValUni:= "Valor Unitário: R$ "+Alltrim(Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
		   	OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)) , nValUni )       
		   
		    nTotal:= "Valor total Item: R$ "+Alltrim(transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99")) 
		    OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) , nTotal )
		      
			cTxtPrev := "Previsão Entrega: "+Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
			                                                                                                      
			cTxtFicha := "Ficha Técnica: " + CRLF + Alltrim(SB1->B1_FICHATE )
			OLE_SetDocumentVar(hWord,"cFichaTec"+Alltrim(str(nI)) , cTxtFicha )   
					
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , " " )
	        EndIf
		
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , " " )
	        EndIf

		ElseIf cTpProp == '007'    // Revenda
		
			cTxtItem := "Item: "+ Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := "Código: "+ Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := "Produto: "+cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
		    cTxtQuant := "Quantidade: "+Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		   				
			nValUni:= "Valor Unitário: R$ "+Alltrim(Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
		   	OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)) , nValUni )       
		   
		    nTotal:= "Valor total Item: R$ "+Alltrim(transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99")) 
		    OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) , nTotal )  
			
			cTxtPrev := "Previsão de Entrega: "+Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			 OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
			                                                                                                    
			cTxtFicha := "Ficha Técnica: " + CRLF + Alltrim(SB1->B1_FICHATE )
			OLE_SetDocumentVar(hWord,"cFichaTec"+Alltrim(str(nI)) , cTxtFicha )   
					
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , " " )
	        EndIf
		
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , " " )
	        EndIf 
	        
		ElseIf cTpProp == '008'    // Manutencao
		
        	cTxtItem := Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
			//SX5->( dbSeek("    "+"ZX"+SB1->B1_MARCA) )
			//cTxtMarca := Alltrim(SX5->X5_DESCRI)

			IF !empty(aSX5[1][1])	
				cTxtMarca:=AllTrim(aSX5[1][4])
			ELSE
				cTxtMarca:=""
			ENDIF

		    OLE_SetDocumentVar(hWord,"cTxtMarca"+Alltrim(str(nI))  , cTxtMarca )      
		    
		    cTxtQuant := Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		    
		    cTxtPrev := Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
		   	
			OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)),Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
	
			OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) ,Transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99"))
        
	
		ElseIf cTpProp == '009'    // Manutencao   MA_ATII
		
        	cTxtItem := Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
			//SX5->( dbSeek("    "+"ZX"+SB1->B1_MARCA) )
			//cTxtMarca := Alltrim(SX5->X5_DESCRI)

			IF !empty(aSX5[1][1])	
				cTxtMarca:=AllTrim(aSX5[1][4])
			ELSE
				cTxtMarca:=""
			ENDIF

		    OLE_SetDocumentVar(hWord,"cTxtMarca"+Alltrim(str(nI))  , cTxtMarca )      
		    
		    cTxtQuant := Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		    
		    cTxtPrev := Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
		   	
			OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)),Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
	
			OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) ,Transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99"))
			
	   ElseIf cTpProp == '010'    // Manutencao   MA_ATII
	   
        	cTxtItem := Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
			//SX5->( dbSeek("    "+"ZX"+SB1->B1_MARCA) )
			//cTxtMarca := Alltrim(SX5->X5_DESCRI)

			IF !empty(aSX5[1])	
				cTxtMarca:=AllTrim(aSX5[1][4])
			ELSE
				cTxtMarca:=""
			ENDIF

		    OLE_SetDocumentVar(hWord,"cTxtMarca"+Alltrim(str(nI))  , cTxtMarca )      
		    
		    cTxtQuant := Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		    
		    cTxtPrev := Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
		   	
			OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)),Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
	
			OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) ,Transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99"))     
			
			
		ElseIf cTpProp == '011' //IMPORTACAOII
		 
			cTxtItem := "Item: "+ Alltrim(ADZ->ADZ_ITEM)
		    OLE_SetDocumentVar(hWord,"cTxtItem"+Alltrim(str(nI))  , cTxtItem )      
			  
			cTxtCodigo := "Código: "+ Alltrim(ADZ->ADZ_PRODUT)
		    OLE_SetDocumentVar(hWord,"cTxtCodigo"+Alltrim(str(nI))  , cTxtCodigo )      
			  
		    cTxtProduto := "Produto: "+cDescProd   
		    OLE_SetDocumentVar(hWord,"cTxtProduto"+Alltrim(str(nI))  , cTxtProduto )      
		    
		    cTxtQuant := "Quantidade: "+Alltrim(Str(ADZ->ADZ_QTDVEN))   
		    OLE_SetDocumentVar(hWord,"cTxtQuant"+Alltrim(str(nI))  , cTxtQuant ) 
		    
			nValUni:= "Valor Unitário: € "+Alltrim(Transform(ADZ->ADZ_PRCVEN,"@E 999,999,999.99"))
		   	OLE_SetDocumentVar(hWord,"nValUni"+Alltrim(str(nI)) , nValUni )       
		   
		    nTotal:= "Valor total Item: € "+Alltrim(transform(ADZ->ADZ_TOTAL,"@E 999,999,999.99")) 
		    OLE_SetDocumentVar(hWord,"nTotal"+Alltrim(str(nI)) , nTotal )  
			
			cTxtPrev := "Previsão de Entrega: "+Alltrim(Dtoc(ADZ->ADZ_ENTREG))
			 OLE_SetDocumentVar(hWord,"cTxtPrev"+Alltrim(str(nI))  , cTxtPrev )
			                                                                                                      
			cTxtFicha := "Ficha Técnica: " + CRLF + Alltrim(SB1->B1_FICHATE )
			OLE_SetDocumentVar(hWord,"cFichaTec"+Alltrim(str(nI)) , cTxtFicha )   
					
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_1"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_1") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_2"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_2") , " " )
	        EndIf
	        
			If File("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" )
				COPY FILE ("\imagens\"+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg" ) TO (cPathWord+Alltrim(ADZ->ADZ_PRODUT)+"_3"+".jpg")
	        Else
				OLE_SetDocumentVar(hWord,"cFotoProd"+Alltrim(str(nI)+"_3") , " " )
	        EndIf
        
	EndIf
	  
		nTotProp += ADZ->ADZ_TOTAL                                                                   
		ADZ->(dbSkip())
		
	Enddo
	
	OLE_SetDocumentVar( hWord , 'nTotProp' , alltrim(Transform(nTotProp,"@E 999,999,999.99")) ) 
	
	// Imprime o valor por extenso (total da proposta,F =valor 1= moeda
	cValorExt := Extenso(nTotProp,.F.,1)
	OLE_SetDocumentVar( hWord ,'cValorExt', cValorExt) 
Endif

If nI > 0	
	OLE_SetDocumentVar(hWord,'nItens_Proposta',alltrim(Str(nI)))

	// DEFINICAO DA MACRO (WORD) PARA CADA MODELO
	If cTpProp = '001'    // PROPOSTA SIMPLIFICADA
		OLE_ExecuteMacro(hWord,"Itens_Proposta_Simplificada")
	ElseIf cTpProp == '002' // 
		OLE_ExecuteMacro(hWord,"Itens_Proposta_Simplificada_Foto")
	ElseIf cTpProp == '003'
		OLE_ExecuteMacro(hWord,"Itens_Proposta")
	ElseIf cTpProp == '004'
		OLE_ExecuteMacro(hWord,"Itens_Proposta")
	ElseIf cTpProp == '005'
		OLE_ExecuteMacro(hWord,"Itens_Proposta")
	ElseIf cTpProp == '006'    // Representacao
		OLE_ExecuteMacro(hWord,"Itens_Proposta")
	ElseIf cTpProp == '007'    // Revenda
		OLE_ExecuteMacro(hWord,"Itens_Proposta") 
	ElseIf cTpProp == '008'   //Manutencao MA_AT - CONTRATO DE MANUTENCAO SEM PECAS
		OLE_ExecuteMacro(hWord,"Itens_Proposta_Manutencao")
	ElseIf cTpProp == '009'   //Manutencao MA_ATII- CONTRATO DE MANUTENCAO COM PECAS PREVENTIVAS
		OLE_ExecuteMacro(hWord,"Itens_Proposta_Manutencao")
	ElseIf cTpProp == '010'   //Manutencao MA_ATIII - CONTRATO DE MANUTENCAO COM INCLUSAO TOTAL DE PECAS
		OLE_ExecuteMacro(hWord,"Itens_Proposta_Manutencao") 
	ElseIf cTpProp == '011'   //MA_IMPORTACAOII - PROPOSTA COM VALORES EM EURO.
		OLE_ExecuteMacro(hWord,"Itens_Proposta") 				
	EndIf 
	
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a condicoes de pagamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aCronoFin)
	OLE_SetDocumentVar(hWord,"cParcela"+Alltrim(str(nX)),aCronoFin[nX][1])
	OLE_SetDocumentVar(hWord,"dVencto"+Alltrim(str(nX)) ,aCronoFin[nX][2])
	OLE_SetDocumentVar(hWord,"nValor"+Alltrim(str(nX)) ,Transform(aCronoFin[nX][3],"@E 999,999,999.99"))
	nCount++
Next nX

//If nCount > 0
	
//	OLE_SetDocumentVar(hWord,'nItens_Cond_Pgto',alltrim(Str(nCount))) 
//	OLE_ExecuteMacro(hWord,"Cond_Pgto") 
	
//Endif

RestArea(aARea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft600CroFin ºAutor  ³Vendas CRM          º Data ³  12/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o Cronograma Financeiro.								º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Ft600Exe                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft600CroFin(cProposta,cPRevisa,aTipo09)

Local aArea			:= GetArea()
Local aVencto 		:= {}
Local aCronoAtu		:= {}
Local nC			:= 0
Local nA			:= 0
Local nI			:= 0
Local nPosData		:= 0
Local cTipoPar		:= SuperGetMv("MV_1DUP")
Local cSequencia    := " "
Local aProdutos		:= {}
Local aCronoFin		:= {}


DbSelectArea("ADZ")
DbSetOrder(3) 

If dbSeek(xFilial("ADZ")+cProposta+cPRevisa) 
	
	While ADZ->(!EOF()) .AND. ADZ_FILIAL == xFilial("ADZ")  .AND. ADZ_PROPOS == cProposta
		aAdd(aProdutos,{ADZ_PRODUT,ADZ_TOTAL,ADZ_CONDPG,ADZ_DT1VEN})
		ADZ->(DbSkip())
	End
	
EndIf


For nI:=1 To Len(aProdutos)
	
	dbSelectArea("SE4")
	dbSetOrder(1)
	IF	dbSeek(xFilial("SE4")+aProdutos[nI][03]) 
		
		If	E4_TIPO <> "9"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza cronograma financeiro para condicao diferente do tipo 9³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aVencto := Condicao(aProdutos[nI][02],aProdutos[nI][03],0,dDatabase,0)
			
			For nA:=1 To Len(aVencto)
				
				If	!Empty(aProdutos[nI][04]) .AND. aProdutos[nI][04] <> dDataBase .AND. nA == 1
					aVencto[nA,1] := aProdutos[nI][04]
				Endif
				
				nPosData := aScan( aCronoAtu, { |x| x[1] == aVencto[nA,1] } )
				
				If	nPosData == 0
					aadd(aCronoAtu,{aVencto[nA,1],aVencto[nA,2]})
				Else
					aCronoAtu[nPosData,2] += aVencto[nA,2]
				Endif
				
			Next nA
			
		Endif
		
	Endif
	
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza cronograma financeiro para condicao de pagamento tipo 9³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	Len(aTipo09)>0
	
	For nA:=1 To Len(aTipo09)
		
		If	Len(aCronoAtu)>0
			nPosData := aScan( aCronoAtu, { |x| x[1] == aTipo09[nA,2] } )
		Else
			nPosData := 0
		Endif
		
		If	nPosData == 0
			aadd(aCronoAtu,{aTipo09[nA,2],aTipo09[nA,3]})
		Else
			aCronoAtu[nPosData,2] += aTipo09[nA,3]
		Endif
		
	Next nA
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata o iniciador da parcela inicial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	cTipoPar == "A"
	cSequencia	:= "9"
Else
	cSequencia	:= "0"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena as parcelas pela data de vencimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCronoAtu := ASort(aCronoAtu,,,{|parc1,parc2|parc1[1]<parc2[1]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza cronograma financeiro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nC:=1 To Len(aCronoAtu)
	
	cSequencia := Soma1(cSequencia)
	
	If	nC == 1
		aadd(aCronoFin,{"",CtoD(Space(8)),0})
		aCronoFin[nC,1] := cSequencia
		aCronoFin[nC,2] := aCronoAtu[nC,1]
		aCronoFin[nC,3] := aCronoAtu[nC,2]
	Else
		AAdd(aCronoFin,{cSequencia,aCronoAtu[nC,1],aCronoAtu[nC,2] })
	Endif
	
Next nC

RestArea(aArea)

Return(aCronoFin)
