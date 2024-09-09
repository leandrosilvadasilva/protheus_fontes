#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Saldo em Estoque.                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico MA Hospitalar                                   ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���															              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

WSRESTFUL MAHESTOQUE DESCRIPTION "Saldo em Estoque"

	WSDATA B2_COD		AS STRING	
	WSDATA B2_FILIAL 	AS STRING
	WSDATA B2_LOCAL 	AS STRING

	WSMETHOD GET DESCRIPTION "Saldo em Estoque" WSSYNTAX "/MAHESTOQUE" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Saldo em estoque Protheus.        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE B2_FILIAL,B2_COD, B2_LOCAL WSSERVICE MAHESTOQUE

	Local lOk    := .T.
	Local nSaldo := 0	
	 
	 
	// Define o tipo de retorno do metodo
	::SetContentType("application/json")
    ConOut(PadR( ::B2_FILIAL, TamSX3("B2_FILIAL")[1]) + PadR( ::B2_COD, TamSX3("B2_COD")[1]) + PadR( ::B2_LOCAL, TamSX3("B2_LOCAL")[1]))
	If Empty( ::B2_COD ) .And. Empty( ::B2_FILIAL ) .And. Empty( ::B2_LOCAL )
	
		lOk := .F.
		SetRestFault( 1, "Nao foi informado nenhum parametro." )

	ELse
	
		dbSelectArea("SB2")
		dbSetOrder(1)
		
		If SB2->( dbSeek( PadR( ::B2_FILIAL, TamSX3("B2_FILIAL")[1]) + PadR( ::B2_COD, TamSX3("B2_COD")[1]) + PadR( ::B2_LOCAL, TamSX3("B2_LOCAL")[1]) ) )
		
			nSaldo := SaldoSB2()
			
			::SetResponse('{')
			::SetResponse('"')
			::SetResponse('NSALDO')	
			::SetResponse('"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse(cValToChar(nSaldo))				
			::SetResponse('"')				
			::SetResponse('}')  
			
		Else
		
			lOk := .F.
			SetRestFault( 2, "Codigo do produto ou local invalido ou nao existente." )
		
		EndIf
		
	EndIf
		
Return( lOk )