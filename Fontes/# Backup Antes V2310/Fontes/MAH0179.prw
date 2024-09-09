#include 'protheus.ch'
#Include "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ MAH0178  ณ Autor ณ Ednei Rosa da Silva  ณ Data ณ31/10/2020 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Matriz de reposicao consignado permanente                  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ FUNCAO DE VALIDACAO                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ                          ULTIMAS ALTERACOES                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ Motivo da Alteracao                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MAH0179()

Local   aRotAdic  := {}

Local   cFunc     := "U_MAH0179A()"
Local   cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString   := "ZA5"


dbSelectArea("ZA5")
dbSetOrder(1)
aadd(aRotAdic,{ "Atualizar Matriz",cFunc, 0 , 6 })
AxCadastro(cString,"Matriz de reposicao consignado Permanente",cVldExc,"U_COK()",aRotAdic)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMAHG010   บ Autor ณEdnei Rosa da Silva  บ Data ณ            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gatilho para sugestao de comissao                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ U_MANH010( cCodVend )                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function MAH0179A()

	Local cAliasZ	  := GetNextAlias()
	Local cQueryZ     :=''

	cQueryZ := " SELECT "
	cQueryZ += " B6_CLIFOR,  "
	cQueryZ += " B6_LOJA,    "
	cQueryZ += " A1_NOME,    "
	cQueryZ += " B6_PRODUTO, "
	cQueryZ += " B1_DESC,    " 
	cQueryZ += " A3_COD,     " 
	cQueryZ += " A3_NOME,    "
	cQueryZ += " SUM(B6_SALDO) B6_SALDO, " 
	cQueryZ += " SUM(B6_CUSTO1) B6_TOTCUS, " 
	cQueryZ += " SUM(B6_PRUNIT*B6_SALDO) B6_TOTVEN  "
	cQueryZ += " FROM " + RetSQLName("SB6")+ " SB6 " 	
	cQueryZ += " INNER JOIN  " + RetSQLName("SD2") + " SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_IDENTB6=SB6.B6_IDENT AND SD2.D_E_L_E_T_<>'*')  "  
	cQueryZ += " INNER JOIN  " + RetSQLName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*') "    
	cQueryZ += " INNER JOIN  " + RetSQLName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "   
	cQueryZ += " INNER JOIN  " + RetSQLName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')    JOIN SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "    
	cQueryZ += " INNER JOIN  " + RetSQLName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
	cQueryZ += " WHERE SB6.D_E_L_E_T_ <> '*'"
	cQueryZ += " AND SB6.B6_SALDO>0  "
	cQueryZ += " AND SB6.B6_TES IN ('722')  "
	
    cQueryZ += " GROUP BY B6_CLIFOR,  "
	cQueryZ += " B6_LOJA,    "
	cQueryZ += " A1_NOME,    "
	cQueryZ += " B6_PRODUTO, "
	cQueryZ += " B1_DESC,    " 
	cQueryZ += " A3_COD,     " 
	cQueryZ += " A3_NOME     "
    
	cQueryZ := ChangeQuery(cQueryZ)			
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQueryZ ),cAliasZ,.F.,.T. )

  
	
	While ( cAliasZ )->( !Eof() )
		
	
		IF !U_MAH0179C(( cAliasZ  )->B6_CLIFOR,( cAliasZ  )->B6_LOJA,( cAliasZ  )->B6_PRODUTO)
			DbSelectArea("ZA5")
			If reclock("ZA5",.T.)
				ZA5->ZA5_CLI      := ( cAliasZ  )->B6_CLIFOR
				ZA5->ZA5_LOJA     := ( cAliasZ  )->B6_LOJA
				ZA5->ZA5_CLINOM   := ( cAliasZ  )->A1_NOME
				ZA5->ZA5_QTDPRV   := 0
				ZA5->ZA5_QTDATU   := ( cAliasZ  )->B6_SALDO
				ZA5->ZA5_QTDREP   := ( cAliasZ  )->B6_SALDO
				ZA5->ZA5_CODVEN   := ( cAliasZ  )->A3_COD
				ZA5->ZA5_NOMVEN   := ( cAliasZ  )->A3_NOME
				ZA5->ZA5_TOTCUS   := ( cAliasZ  )->B6_TOTCUS
				ZA5->ZA5_TOTVEN   := ( cAliasZ  )->B6_TOTVEN
				ZA5->ZA5_CODPRO   := ( cAliasZ  )->B6_PRODUTO
		        ZA5->ZA5_NOMPRO   := ( cAliasZ  )->B1_DESC
		        ZA5->ZA5_AUDITO   := 'MonteiroBot'
		        ZA5->ZA5_FONTE    := 'MonteiroBot'
	        endif 
	 	MsUnLock()  
		 else  
	        U_MAH0179B(( cAliasZ  )->B6_CLIFOR, ( cAliasZ  )->B6_LOJA, ( cAliasZ  )->B6_PRODUTO, ( cAliasZ  )->B6_SALDO, ( cAliasZ  )->B6_TOTCUS, ( cAliasZ  )->B6_TOTVEN ) 
	     endif 
    
    
	( cAliasZ  )->( dbSkip() )	
	EndDo

	( cAliasZ  )->( dbCloseArea() )
	
	
Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunction ณatuZ30      บAutor  ณEdnei Silva        บ Data ณ  20/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Atualizr a coluna ZA5                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  atuZ30()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function MAH0179B(cCli, cLoja, cProduto, nQTDATU, nTOTCUS, nTOTVEN )

Local cQueryW := ""

cQueryW:=""
cQueryW+=" UPDATE ZA5010 SET ZA5_QTDATU="+cValToChar(nQTDATU)
cQueryW+=" ,ZA5_TOTCUS="+cValToChar(nTOTCUS)
cQueryW+=" ,ZA5_TOTVEN="+cValToChar(nTOTVEN)
cQueryW+=" ,ZA5_QTDREP=ZA5_QTDPRV-"+cValToChar(nQTDATU)
cQueryW+=" WHERE "
cQueryW+=" ZA5_CLI		  =  '"+cCli+"'"
cQueryW+=" AND ZA5_LOJA   =  '"+cLoja+"'"
cQueryW+=" AND ZA5_CODPRO =  '"+cProduto+"'"
cQueryW+=" AND D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQueryW)
If nRet<>0
	Alert(TCSQLERROR())
Endif

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunction ณatuZ30      บAutor  ณEdnei Silva        บ Data ณ  20/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Testa se existe o Registro na ZA5                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  atuZ30()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function MAH0179C(cCli,cLoja,cProduto)
Local lOk		:= .F.
Local cArea   	:= ""
Local cQueryZ   := ""

// Procura na matriz de consignado permanete se ja existe previsao de consumo 
// do produto para o cliente  

cQueryZ:=""
cQueryZ+=" SELECT COUNT(ZA5_CLI) QTD_REG"
cQueryZ+=" FROM ZA5010 "
cQueryZ+=" WHERE "
cQueryZ+=" ZA5_FILIAL       = '" + xFILIAL("ZA5") + "'"
cQueryZ+=" AND ZA5_CLI 	    = '" + cCli + "'"
cQueryZ+=" AND ZA5_LOJA     = '" + cLoja + "'"
cQueryZ+=" AND ZA5_CODPRO   = '" + cProduto + "'"
cQueryZ+=" AND D_E_L_E_T_ <> '*' "
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)

IF (cArea)->QTD_REG>0
	lOk		:= .T.
Endif

(cArea)->( dbCloseArea() )
return lOk


 


User Function COK()  
Local   cUserID   := ""
Local   cNomUser  := ""
cUserID   := RetCodUsr()
cNomUser  := UsrRetName(cUserID)

M->ZA5_AUDITO := cNomUser
  
Return .T.


