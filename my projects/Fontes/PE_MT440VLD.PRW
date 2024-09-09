#Include "Protheus.ch"
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  MT440VLD                                                                                      |
 | Desc:  Ponto de entrada antes de começar a liberação, a após mostrar a primeira pergunta             |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=6784366                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function MT440VLD()
    Local aArea    := GetArea()
    Local aAreaSC5 := GetArea("SC5")
    Local lRet     := .T.
    Local cCND     := SuperGetMV("ES_CNDNLIB") // Paramtro que contem condicoes de pagamentos que nao podem ser liberadas automaticamente
    MsgYesNo("Teste de Liberacao automatica! Pedido - "+SC5->C5_NUM, "Atenção")
    IF SC5->C5_CONDPAG $ cCND
    lRet     := .F.
    Endif
    RestArea(aArea)
    RestArea(aAreaSC5)
Return lRet