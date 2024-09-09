#Include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºADAPTADO  ³MAHF318   ºAutor  ³Marcelo Tarasconi   º Data ³  29/11/2008 º±±
±±ºPrograma  ³MAHF318   ºAutor  ³Marcelo Tarasconi   º Data ³  27/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para declarar variaveis contadoras para cnab a pagar º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 12                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MAHF318()


Local aArea    := GetArea()
Local aAreaSE2 := SE2->(GetArea())
local nAbat    := 0

//Procura abatimento
nAbat := Posicione('SE2',1,xFilial('SE2')+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+'AB-','E2_VALOR')

//Volto area original
RestArea(aAreaSE2)
RestArea(aArea)

//Return(STRZERO((SE2->E2_VALOR-nAbat)*100, 15))
Return(STRZERO((SE2->E2_SALDO-nAbat)*100, 15))