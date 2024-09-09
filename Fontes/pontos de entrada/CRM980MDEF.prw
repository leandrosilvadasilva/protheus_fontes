#include 'protheus.ch'
#Include 'rwmake.ch'

User Function CRM980MDEF()
************************
    Local aBtn 		:= Array(0)
    Local aArea 	:= GetArea()
    Local aAreaSA1  := SA1->(GetArea())
    //Aadd(aBtn,{"BUDGET", {|| U_MAH0200() },"Hist. Cliente"})//Visualiza tabela Z80 - Historico de Cliente
    AAdd(aBtn,{"Hist. Cliente","U_MAH0200()",2,0})
    RestArea(aAreaSA1)
    RestArea(aArea)
Return(aBtn)
