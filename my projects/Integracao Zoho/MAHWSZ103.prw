#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "TbiConn.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHTRG10 � Autor � Ednei R. Silva      � Data � MAR/2020   ���
�������������������������������������������������������������������������Ĵ��
���Descricao � WS para gravar chave acesso zoho no protheus.              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico MA  Hospitalar                                  ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSRESTFUL MAHADDKEY DESCRIPTION "Incluir Chave Zoho" 

WSDATA ES_ZHOKEY     AS STRING //ES_ZHOKEY

WSMETHOD POST DESCRIPTION "Incluir chave protheus." WSSYNTAX "/" 
	
END WSRESTFUL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � POST     �Autor  � Ednei Silva        � Data �  MAR/2021   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para incluir Pedido de venda.                       ���
�������������������������������������������������������������������������͹��
���Uso       � MA Hospitalar                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE MAHADDKEY

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local oJson 
	
	::SetContentType("application/json")//Define o tipo de retorno do metodo	
				
	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
	
		lOk := .F.
		SetRestFault( 1, "Nao foi possivel processar a estrutura Json." )	

	Else
		
		
		If Empty( oJson:ES_ZHOKEY )
			lOk := .F.	 				
	 		SetRestFault( 90, "Campo obrigatorio: ES_ZHOKEY." )
		Endif 
      
        IF lOk
	        PUTMV("ES_ZHOKEY", oJson:ES_ZHOKEY)
			::SetResponse('{')
			::SetResponse('"Status"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse( 'Ok' )
			::SetResponse('"')
			::SetResponse('}')
	    else
			SetRestFault( 91, "Erro a incluir a informacao no sistema!" )
		Endif		
    Endif
Return( lOk )
