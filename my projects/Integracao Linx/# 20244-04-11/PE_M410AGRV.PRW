#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} M410AGRV

Descrição:
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). Está localizado na rotina de gravação do pedido, A410GRAVA(). É executado antes da gravação das alterações.
https://tdn.totvs.com/pages/releaseview.action?pageId=6784142

@type function
@version  
@author LSSOUZA
@since 9/19/2023
@return variant, return_description
/*/
User function M410AGRV()
Local lOpcIncluir    := PARAMIXB[1] == 1                       AS LOGICAL
Local lPrivateInclui := INCLUI                                 AS LOGICAL
Local lAutomatico    := AllTrim( __CINTERNET ) == "AUTOMATICO" AS LOGICAL
Local lExecAuto      := IsBlind()                              AS LOGICAL
Local lIntegLinx     := FwIsIncallStack( "MyMATA410ExeAuto")   AS LOGICAL
Local lLinxInteg     := FwIsIncallStack( "MAWSLNX20")          AS LOGICAL


     PutMV( "MV_BLOQUEI", .F. )

Return NIL
