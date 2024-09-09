#include 'protheus.ch'
#Include 'RwMake.ch'
#include "TopConn.ch"
#include 'parmtype.ch'

#define PULA Chr(13) + Chr(10)


/*/{Protheus.doc}P.E - M410PVNF                                                                          
 
    Este P.E. e' Executado antes da rotina de geração de NF's (MA410PVNFS()).                         
    
	@author: Súlivan Simões Silva 
	@since : 28/08/2019
	@version : 1.0
 	@Link  : https://tdn.totvs.com/pages/releaseview.action?pageId=6784152
 			 https://centraldeatendimento.totvs.com/hc/pt-br/articles/360021351991-MP-ADVPL-PE-M410PVNF-Prep-Doc-sa%C3%ADda-no-pedido-de-venda-                               
 	@Obs :  /
/*/  
user function M410PVNF()

	local aArea    	:= getArea()
	local lRetorno  := .T.
	
	ConOut("[u_M410PVNF] ++ - Entrou no ponto de entrada M410PVNF")
	
	// Função de validação chamada fora do Ponto de Entrada por questões de organização.
   	lRetorno := fValidEst()

	
	ConOut("[u_M410PVNF] ++ - Encerrou taferas no ponto de entrada M410PVNF")
	
	restArea(aArea)
		
return lRetorno


/*
	Summary: Verifica se tem saldo em estoque para poder gerar documento de saída.
	@since : 28/08/2019
	@version : 1.0
*/
static function fValidEst()

	local aArea    	:= getArea()
	local aAreaSC5 	:= SC5->(getArea())
	local aAreaSC6 	:= SC6->(getArea())
	local aAreaSB2  := SB2->(getArea())
	local cAliasTemp:= "QRYSC9"+right(retCodUsr(),3)
	local cQuerySC9 := ""

	local nSaldoEst	:= 0
	local nQtdLib   := 0		 
	local lRetorno	:= .T.
	
	//Monto uma consulta na SC9 do pedido agrupando os produtos iguais e desconsidando tes que não movimenta estoque.
	cQuerySC9 := "SELECT C9_PEDIDO, C9_PRODUTO, C9_LOCAL, SUM(C9_QTDLIB) AS C9_QTDLIB"
	cQuerySC9 += "FROM "+RetSqlName("SC9")+" SC9 "
	cQuerySC9 += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 ON C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM "
	cQuerySC9 += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 ON C6_TES = F4_CODIGO AND SF4.F4_FILIAL = SC6.C6_FILIAL"
	cQuerySC9 += " WHERE C9_FILIAL     = '"+SC5->C5_FILIAL+"' "										 //Filtra somente filial do pedido.
	cQuerySC9 += "		 AND C9_PEDIDO = '"+SC5->C5_NUM   +"' "										 //Filtra somente pedido que está sendo gerado documento. 
//	cQuerySC9 += "       AND SC9.C9_BLEST   = ' '"													 //Filtra os que estão sem bloqueio de estoque
	cQuerySC9 += "       AND SC9.C9_BLCRED  = ' '"													 //Filtra os que estão sem bloqueio de credito.
	cQuerySC9 += "       AND SC9.C9_NFISCAL = ' '"													 //Filtra somente os que não foram gerados nota ainda.
	cQuerySC9 += "       AND SF4.F4_ESTOQUE = 'S'"													 //Filtra somente TES que movimenta estoque.
	cQuerySC9 += "		 AND SC9.D_E_L_E_T_ = ' ' AND SC6.D_E_L_E_T_ = ' ' AND SF4.D_E_L_E_T_ = ' '" //Filtra somente não deletados.
	cQuerySC9 += " GROUP BY C9_PEDIDO, C9_PRODUTO, C9_LOCAL "
	
	cQuerySC9 := changeQuery(cQuerySC9)	
	TcQuery	cQuerySC9 New Alias ( cAliasTemp )
	
	//Verifico se tenho estoque suficiente p/gerar as notas.  
	while !( (cAliasTemp)->(eof() ) )
			
		nSaldoEst := posicione("SB2",1, xFilial("SB2") + (cAliasTemp)->C9_PRODUTO + (cAliasTemp)->C9_LOCAL,"B2_QATU")
		nQtdLib	  := (cAliasTemp)->C9_QTDLIB
		
		//Se quantidade liberada for maior que estoque atual.
		if( nQtdLib > nSaldoEst )
				
			Aviso("Aten��o", "Pedido " + (cAliasTemp)->C9_PEDIDO + " n�o tem estoque para todos os itens. " + PULA +;
							 "_______________________________________________________________"+ PULA +;
							 "Cod.: " + alltrim((cAliasTemp)->C9_PRODUTO) + PULA +;									 
							 "Desc.: "+ alltrim(posicione("SB1",1,xFilial("SB1")+(cAliasTemp)->C9_PRODUTO,"B1_DESC"))+ PULA +;
							 "_______________________________________________________________"+ PULA +; 
							 "Qdt. Liberada: "+ cValToChar(nQtdLib) 		+ PULA +;
						     "Saldo em estoque: " + cValToChar(nSaldoEst)   + PULA +;
						     "Armazem: " + (cAliasTemp)->C9_LOCAL 			+ PULA +;
						     "_______________________________________________________________"+ PULA +; 
						     "Estoque insuficiente para atender o pedido.", {"OK"},3)
								     													     					
					lRetorno := .F.
				EndIf
		
		SB2->(dbCloseArea())		
		(cAliasTemp)->( dbSkip() )	
	enddo	
	(cAliasTemp)->( dbCloseArea() )
	
	
	restArea(aArea)
	restArea(aAreaSC5)
	restArea(aAreaSC6)
	restArea(aAreaSB2)
	
return lRetorno
