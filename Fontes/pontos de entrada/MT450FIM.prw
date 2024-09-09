#INCLUDE "PROTHEUS.CH"
/*--------------------------------------------------------------------------------------------------*
| Func:  PONTO DE ENTRADA MT450FIM()                                      							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  Descri��o:                                                                                 |
| Este ponto pertence � rotina de libera��o de cr�dito, MATA450(). Est� localizado na libera��o     |
|  manual do cr�dito por pedido A450LIBMAN(). � executado ao final da libera��o de um pedido.		|																							|
| altra��es .:      /                                                            					|
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
    // 1� Integra pedido de venda para AKR avia API CASO N�O HAJA BLOQUEIO DE CREDITO.
    // -------------------------------------------------------------------------------
    U_EnvPedWMS()
	
RestArea( aArea )

Return()
