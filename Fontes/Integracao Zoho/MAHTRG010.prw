#include "Totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHTRG010� Autor � Ednei R. Silva        � Data � Mar/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao que instala uma trigger nas tabela para             ���
���          � gravar a Data + Hora de inclusao, alteracao e exclusao de  ���
���          � registros.                                                 ���
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
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function MAHTRG010()
	
	Local cMsg  := ""
	Local aDado := {}
	Local nX    := 0

	If !(TCIsConnected())
		Return MsgAlert("Voce precisa abrir a conexao com o banco de dados","MAHTRG010")
	EndIf

	If !("MSSQL"$TCGetDB())
	    Return MsgStop(TCGetDB() + " - Nao tratado!","MAHTRG010")
	EndIf
	aAdd( aDado, { "SA1", "A1_ZOHDTH",  "DATAHORAVENDEDOR" } )        //Cadastro de Vendedor
	aAdd( aDado, { "SA1", "A1_ZOHDTH",  "DATAHORACLIENTE" } )        //Cadastro de Cliente
	aAdd( aDado, { "SA4", "A4_ZOHDTH",  "DATAHORATRANSPORTADORA" } ) //Cadastro Transportadora
	aAdd( aDado, { "SB1", "B1_ZOHDTH",  "DATAHORAPRODUTO" } )        //Cadastro Produto
	aAdd( aDado, { "SC5", "C5_ZOHDTH",  "DATAHORAPEDIDOVENDA" } )    //Cadastro Pedido de Venda
	aAdd( aDado, { "DA0", "DA0_ZOHDTH", "DATAHORATABELAPRECO" } )    //Cadastro Tabela de Preco
	aAdd( aDado, { "SE4", "E4_ZOHDTH",  "DATAHORACONDICAOPAG" } )    //Cadastro Condicao de Pagamento
	
	For nX := 1 To Len(aDado)
	
		cMsg += Executa( aDado[nX][1], aDado[nX][2], aDado[nX][3] )
	
	Next
		
	MsgInfo(cMsg)
	
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Executa  �Autor  � Ednei R. Silva     � Data �  MAR/2020   ���
�������������������������������������������������������������������������͹��
���Desc.     � Criar ou alterar a trigger no Banco de dados.              ���
�������������������������������������������������������������������������͹��
���Uso       � MAHTRG010                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Executa( cTab, cCpo, cNomTrig )

	Local cTabela := RetSQLName(cTab)
	Local cQuery  := ""
	Local cSQL    := ""
	Local cAliasT := ""
	Local cMsg    := ""
	

	cAliasT := GetNextAlias()
	cQuery := " SELECT name, OBJECT_NAME(parent_obj) AS TABELA"
	cQuery += " FROM sys.sysobjects"
	cQuery += " WHERE xtype = 'TR'"
	cQuery += "   AND name  = '"+ cNomTrig +"'"
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If Empty( ( cAliasT )->TABELA )
		
		cSQL := " CREATE TRIGGER [dbo].["+ cNomTrig +"]"
		cMsg := "Trigger "+ cNomTrig +" (" + cTab + ") CRIADA."

	Else
	
		cSQL := " ALTER TRIGGER [dbo].["+ cNomTrig +"]"
		cMsg := "Trigger "+ cNomTrig +" (" + cTab + ") ALTERADA."
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	cSQL += " ON [dbo].[" + cTabela + "]"
	cSQL += " AFTER INSERT, UPDATE, DELETE AS"
	cSQL += " Declare"
	cSQL += "     @LNOTA INT"
	cSQL += " Begin"  
	cSQL += "    Select @LNOTA = R_E_C_N_O_"
	cSQL += "    From INSERTED"
	cSQL += "    	UPDATE " + cTabela 
	cSQL += "    	SET " + cCpo + " = format(cast( SYSDATETIME() as date),'yyyyMMdd')"
	cSQL += "  		FROM " + cTabela
	cSQL += "		WHERE @LNOTA = " + cTabela + ".R_E_C_N_O_"      
	cSQL += " End"
	
	If ( TCSQLExec( cSQL ) < 0 )
	    
	    cMsg := "TCSQLError() " + TCSQLError()
		
	EndIf		
	
Return( cMsg + CRLF + CRLF )
