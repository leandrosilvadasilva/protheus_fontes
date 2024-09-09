#INCLUDE "Protheus.ch"     

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CONF23() �Autor  � Fernando Mazzarolo � Data �  03/19/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Define o Codigo de barra nos pagamentos via cnab           ���
�������������������������������������������������������������������������͹��
���Uso       � SIGASUL                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function CONF23()

	Local cRet    := ""                        
	Local cCodBar := AllTrim( SE2->E2_CODBAR  )
	
	//Se o tamanho do codigo de barra for maior que 44 , � Digitado.....entao possui 47 posicoes...
	If Len( cCodBar ) > 44 
		
	   cRet := Substr( cCodBar , 1 , 4 )   // Banco + Moeda              4 
	   cRet += Substr( cCodBar , 33, 1 )   // DV do Codigo de Barra      1
	   cRet += Substr( cCodBar , 34, 4 )   // Fator de Vencimento        4
	   cRet += Substr( cCodBar , 38, 10)   // Valor                     10	   
	   cRet += Substr( cCodBar , 5 , 5 )   // Campo Livre                5
	   cRet += Substr( cCodBar , 11, 10)   // Campo Livre               10
	   cRet += Substr( cCodBar , 22, 10)   // Campo Livre               10
	   	                                                  // TOTAL =>   44
	Else
		// Codigo de Barra pelo Leitor 44 posicoes                                                                                                                                                                                                                                            
		cRet := cCodBar
	
	EndIf        	
	
Return( cRet )
