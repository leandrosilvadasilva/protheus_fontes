#include "Protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"
#include "FWMVCDEF.ch"
#Include "TOTVS.ch" 
#INCLUDE "rwmake.ch"


USER FUNCTION GETDTORIG()

    Local retorno

    retorno := xData(ACG->ACG_FILIAL, ACG->ACG_PREFIX, ACG->ACG_TITULO, ACG->ACG_PARCEL, ACG->ACG_TIPO)

RETURN retorno


Static Function xData(filial, prefixo, titulo, parcela, tipo)

Local retorno := STOD("")
Local sql := ""

     sql +=" SELECT E1_VENCORI "
     sql +=" FROM SE1010    "
     sql +="  WHERE D_E_L_E_T_ <> '*' "
     sql +="  AND E1_FILIAL = '" + SUBSTR(filial, 1, 2) + "' "
     sql +="  AND E1_NUM = '" + titulo + "' "
     sql +="  AND E1_PREFIXO = '" + prefixo + "' "
     sql +="  AND E1_PARCELA = '" + parcela + "' "
     sql +="  AND E1_TIPO = '" + tipo + "'  "

    TCQuery sql New Alias "QRY_SE1"
    
    QRY_SE1->(DbGoTop())

    While ! QRY_SE1->(Eof())
        
        retorno := STOD(QRY_SE1->E1_VENCORI)
        QRY_SE1->(DbSkip())
    EndDo

    QRY_SE1->(DbCloseArea())


Return Retorno
