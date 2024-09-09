#include "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHTRG010³ Autor ³ Ednei R. Silva        ³ Data ³ Mar/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que instala uma trigger nas tabela para             ³±±
±±³          ³ gravar a Data + Hora de inclusao, alteracao e exclusao de  ³±±
±±³          ³ registros.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Executa  ºAutor  ³ Ednei R. Silva     º Data ³  MAR/2020   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criar ou alterar a trigger no Banco de dados.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MAHTRG010                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
