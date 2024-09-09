#INCLUDE "PROTHEUS.CH"
/*--------------------------------------------------------------------------------------------------*
| Func:  PONTO DE ENTRADA M440STTS()                                      							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  Ponto de Entrada para envio de email em caso de bloqueio de crédito. Este ponto de entrada |
| é executado após o fechamento da transação de liberação do pedido de venda    	 				|
|																									|
| altrações .:      /                                                            					|
*--------------------------------------------------------------------------------------------------*/
User Function M440STTS()

Local aArea 	    := GetArea()
Local aSC5area 	    := SC5->(GetArea())
Local aSC6area 	    := SC6->(GetArea())
Local aSC9area 	    := SC9->(GetArea())

    // -------------------------------------------------------------------------------
    // 1º Integra pedido de venda para AKR avia API CASO NÃO HAJA BLOQUEIO DE CREDITO.
    // -------------------------------------------------------------------------------
    U_EnvPedWMS()
	
RestArea(aSC5area)
RestArea(aSC6area)
RestArea(aSC9area)
RestArea( aArea )

Return()
