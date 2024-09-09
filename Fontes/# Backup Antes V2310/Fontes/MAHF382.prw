#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºADAPTADO  ³MAHF382   ºAutor  ³Marcelo Tarasconi   º Data ³  29/11/2008 º±±
±±ºPrograma  ³MAHF382   ºAutor  ³Marcelo Tarasconi   º Data ³  05/11/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para retornar cod barras                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 12                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAHF382()

Local cRet := SE2->E2_CODBAR                         //          1         2         3         4
                                                     // 123456789012345678901234567890123456789012345678
If Len(Alltrim(cRet)) == 48 //se vier com tamanho 48 // 123456789011123456789011234567890112345678901234
   cRet := Substr(cRet,01,11) + Substr(cRet,13,11) + Substr(cRet,25,11) + Substr(cRet,37,11)           
EndIf


Return(cRet)