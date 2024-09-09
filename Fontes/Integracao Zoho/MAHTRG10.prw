#INCLUDE "Totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHTRG10 � Autor � Ednei R. Silva      � Data � MAR/2020   ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para instalar trigger.                              ���
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
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MAHTRG10()
	
	Local cMsg	:= ""
	Local aDado	:= {}
	Local nX	:= 0
	Local lOk	:= .T.

	If !( TCIsConnected() )
		MsgAlert("� necess�rio abrir a conexao com o banco de dados.","MERTRG10")
		lOk := .F.
	EndIf

	If !( "ORACLE" $ TCGetDB() )
	    MsgStop( TCGetDB() + " - Nao tratado!","MERTRG10")
	    lOk := .F.
	EndIf
	
	If lOk
	
		aAdd( aDado, { "SA1", "A1_AISDTH", "WS_APIS_DTH_" + "SA1"+cEmpAnt+"0" } ) 
	    aAdd( aDado, { "SA3", "A3_AISDTH", "WS_APIS_DTH_" + "SA3"+cEmpAnt+"0" } )
		aAdd( aDado, { "SA4", "A4_AISDTH", "WS_APIS_DTH_" + "SA4"+cEmpAnt+"0" } )
		aAdd( aDado, { "SB1", "B1_AISDTH", "WS_APIS_DTH_" + "SB1"+cEmpAnt+"0" } ) 
		aAdd( aDado, { "SC5", "C5_AISDTH", "WS_APIS_DTH_" + "SC5"+cEmpAnt+"0" } ) 
		aAdd( aDado, { "DA0", "DA0_AISDTH", "WS_APIS_DTH_" + "DA0"+cEmpAnt+"0" } )
		aAdd( aDado, { "DA3", "DA3_AISDTH", "WS_APIS_DTH_" + "DA3"+cEmpAnt+"0" } ) 
		aAdd( aDado, { "SE4", "E4_AISDTH", "WS_APIS_DTH_" + "SE4"+cEmpAnt+"0" } ) 
		
		For nX := 1 To Len(aDado)
		
			cMsg += Executa( RetSQLName( aDado[nX][1] ), aDado[nX][2], aDado[nX][3] )
			cMsg += CRLF
			cMsg += CRLF
		
		Next
			
		MsgInfo(cMsg)
		
	EndIf
	
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Executa  �Autor  � Ednei R. Silva     � Data �  MAR/2020   ���
�������������������������������������������������������������������������͹��
���Desc.     � Criar ou alterar trigger no Banco de dados.                ���
�������������������������������������������������������������������������͹��
���Uso       � MAHTRG010                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Executa( cTab, cCpo, cNomTrig )

	Local cSql	:= ""
	Local cMsg	:= "Trigger "+ cNomTrig +" executada com sucesso. " 
	
    
   // cSql := "DROP TRIGGER " + cNomTrig+ "; "
    
	cSql := " CREATE OR REPLACE TRIGGER " + cNomTrig
	cSql += " BEFORE INSERT OR UPDATE ON " + cTab   
	cSql += " FOR EACH ROW"
	cSql += " BEGIN"
	cSql += " :NEW."+ cCpo +" := TO_CHAR( SYSDATE, 'YYYYMMDD HH24:MI:SS' );"
	cSql += " END;"
	
	If ( TCSQLExec( cSql ) < 0 )
	    
	    cMsg := "TCSQLError() " + TCSQLError()
	    		
	EndIf		
	
Return( cMsg )
