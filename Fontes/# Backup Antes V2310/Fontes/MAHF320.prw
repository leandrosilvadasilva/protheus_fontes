#Include 'rwmake.ch'
/*
�����������������������������������������������������������������������������
���Programa  �MAHF320   �Autor  �Microsiga           � Data �  12/25/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Retirno de Instrucoes Bancarias                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP 12                                                      ���
�����������������������������������������������������������������������������
*/
User Function MAHF320()

Local cRet := '0000'

/*
BB
1) E1_SALDO < 5000 C/ INSTRUCAO DE CARTORIO > BRASIL17.REM
2) SALDO > 5000 S/ INSTRUCAO > BRASI171.REM
3) IMPRESSAO PELO BANCO > BRASIL.REM CARTEIRA 11  >>> O USUARIO VAI ESCOLHER MANUALMENTE DE ACORDO COM OS TITULOS QUE RESTARAM....

ITAU
IDEM AOS CASOS 1 E 2 DO BB
*/


If SE1->E1_SALDO < 5000 //Ter� instrucao para Protesto
   cRet := '0601'
Else //N�o ter� instru��o de cart�rio
   cRet := '0701'
EndIf

Return(cRet)