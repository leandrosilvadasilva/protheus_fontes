#Include 'rwmake.ch'
/*
�����������������������������������������������������������������������������
���ADAPTADO  �MAHF382   �Autor  �Marcelo Tarasconi   � Data �  29/11/2008 ���
���Programa  �MAHF382   �Autor  �Marcelo Tarasconi   � Data �  05/11/2007 ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para retornar cod barras                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP 12                                                      ���
�����������������������������������������������������������������������������
*/
User Function MAHF382()

Local cRet := SE2->E2_CODBAR                         //          1         2         3         4
                                                     // 123456789012345678901234567890123456789012345678
If Len(Alltrim(cRet)) == 48 //se vier com tamanho 48 // 123456789011123456789011234567890112345678901234
   cRet := Substr(cRet,01,11) + Substr(cRet,13,11) + Substr(cRet,25,11) + Substr(cRet,37,11)           
EndIf


Return(cRet)