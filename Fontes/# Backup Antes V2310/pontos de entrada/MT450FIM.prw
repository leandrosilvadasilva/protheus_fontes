#INCLUDE "PROTHEUS.CH"
/*--------------------------------------------------------------------------------------------------*
| Func:  PONTO DE ENTRADA MT450FIM()                                      							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  Descrição:                                                                                 |
| Este ponto pertence à rotina de liberação de crédito, MATA450(). Está localizado na liberação     |
|  manual do crédito por pedido A450LIBMAN(). É executado ao final da liberação de um pedido.		|																							|
| altrações .:      /                                                            					|
*--------------------------------------------------------------------------------------------------*/
User Function MT450FIM()

Local aArea 	    := GetArea()
Local cNumPedido    := ParamIxb[1]

    DbSelectArea("SC9")
    SC9->( DBSetOrder( 1 ) )
    SC9->( MsSeek(xFilial("SC9") + cNumPedido ) )
    
    DbSelectArea("SC5")
    SC5->( DBSetOrder( 1 ) )
    SC5->( MsSeek(xFilial("SC5") + cNumPedido ) )

    // -------------------------------------------------------------------------------
    // 1º Integra pedido de venda para AKR avia API CASO NÃO HAJA BLOQUEIO DE CREDITO.
    // -------------------------------------------------------------------------------
    U_EnvPedWMS()
	
RestArea( aArea )

Return()
