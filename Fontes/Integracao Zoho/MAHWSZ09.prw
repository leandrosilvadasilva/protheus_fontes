#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "TbiConn.ch" 

//Opcoes ExecAuto 
#Define PD_INCLUIR 3 
#Define PD_ALTERAR 4 
#Define PD_EXCLUIR 5   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWSZ09 � Autor � Ednei R. Silva      � Data � AGO/2020   ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Update Codigo Zoho no produto.                             ���
���          �                                                            ���
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
���                       ULTIMAS ALTERACOES                              ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSRESTFUL MAHADDPRO DESCRIPTION "Update Codigo Zoho Produto" 

WSDATA B1_COD     AS STRING //(20) Codigo Produto Protheus
WSDATA B1_CODZHO  AS STRING //(50) Codigo Zoho

		
	
WSMETHOD POST DESCRIPTION "Incluir Pedido de Venda." WSSYNTAX "/" 
	
END WSRESTFUL



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � POST     �Autor  � Ednei Silva        � Data �  Ago/2017   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para incluir Pedido de venda.                       ���
�������������������������������������������������������������������������͹��
���Uso       � MA Hospitalar                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE MAHADDPRO

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local aProduto	:= {}
	Local oJson 
	Local cAliasT	:= GetNextAlias()
	Local cError    :=""
	Local aMsg		:= {}
	Local cMsg 		:= ""
	Local cErrorLog	:= ""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
    ConOut('01')
	::SetContentType("application/json")//Define o tipo de retorno do metodo	
				
	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
	
		lOk := .F.
		SetRestFault( 1, "Nao foi possivel processar a estrutura Json." )	

	Else
		
		
		If Empty( oJson:B1_COD )
			lOk := .F.	 				
	 		SetRestFault( 90, "Campo obrigatorio: Codigo Produto Protheus." )
		Endif 
		
		If Empty( oJson:B1_CODZHO )
			lOk := .F.	 				
	 		SetRestFault( 91, "Campo obrigatorio: Codigo Zoho" )
		Endif  
		
			
			
		cQurery:=""
		cQurery+=" UPDATE SB1010 SET B1_CODZHO='" + oJson:B1_CODZHO + "'"
		cQurery+=" WHERE D_E_L_E_T_ <> '*' "
		cQurery+=" AND B1_COD='" + oJson:B1_COD + "'"
		nRet:=TcSqlExec(cQurery)
		If nRet<>0
			SetRestFault( 91,(TCSQLERROR()))
		ELSE

			::SetResponse('{')
			::SetResponse('"B1_CODZHO"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse( oJson:B1_CODZHO  )
			::SetResponse('"')
			::SetResponse(',')
			::SetResponse('"B1_COD"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse( oJson:B1_COD  )
			::SetResponse('"')
			::SetResponse('}')
	        
	     Endif	
	Endif 			
Return( lOk )
