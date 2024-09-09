#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#include "fileio.ch"


USER Function MAHR070()
Private aColun:={}
Private aDados:={}
Private aLinha:={}
Private nMaxCol:=0
Private cPerg:="ZMAR070"
cColDin:=''


CriaSX1( cPerg )

If Pergunte(cPerg,.T.)
	
	
	
	MontCabe()
	Processa( {|| MontData() },"Gerando Relatorio de Oportunidades x Prospect" )
	geraXLS()
	
Endif


return


Static Function CriaSx1( cPerg )
Local cValid   := ""
Local cF3      := ""
Local cPicture := ""
Local cDef01   := ""
Local cDef02   := ""
Local cDef03   := ""
Local cDef04   := ""
Local cDef05   := ""

u_PutSX1(cPerg, "01", "Periodo de:"	,"MV_PAR01", "MV_CH0", TamSX3("AD1_DATA")[3]  , TamSX3("AD1_DATA")[1] , TamSX3("AD1_DATA")[2] , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Periodo Balancete De")
u_PutSX1(cPerg, "02", "Periodo Ate:"	,"MV_PAR02", "MV_CH2", TamSX3("AD1_DATA")[3]  , TamSX3("AD1_DATA")[1] , TamSX3("AD1_DATA")[2] , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Periodo Balancete Ate")
u_PutSX1(cPerg, "03", "Marca:"  		,"MV_PAR03", "MV_CH3", TamSX3("BM_DESC")[3]  , TamSX3("BM_DESC")[1] , TamSX3("BM_DESC")[2] , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Marca")


Return


Static Function MontCabe()

aColun:={}
//Colunas fixas

AAdd(aColun,'Filial')
AAdd(aColun,'Vendedor')
AAdd(aColun,'Nome Vendedor')
AAdd(aColun,'Codigo Prospect')
AAdd(aColun,'Nome Prospect')
AAdd(aColun,'CNPJ Prospect')
AAdd(aColun,'Oportunidade')
AAdd(aColun,'Descricao Oportunidade')
AAdd(aColun,'Dt. Emissao Oportunidade')
AAdd(aColun,'Probabilidade de Sucesso')
AAdd(aColun,'Processo de Venda')
AAdd(aColun,'Estagio da Venda ')
AAdd(aColun,'Codigo do Produto')
AAdd(aColun,'Descricao do Produto')
AAdd(aColun,'Tipo do Produto')
AAdd(aColun,'Marca do Produto')
AAdd(aColun,'Grupo do Produto')
AAdd(aColun,'Proposta')
AAdd(aColun,'Revisao')
AAdd(aColun,'Descricao da Proposta')
AAdd(aColun,'Item')
AAdd(aColun,'Moeda')
AAdd(aColun,'Status Oportunidade')
AAdd(aColun,'Status Proposta')
AAdd(aColun,'Tipo Processo')
AAdd(aColun,'Dt. Emissao Proposta')
AAdd(aColun,'Dt. Aprovacao Proposta')
AAdd(aColun,'Dt. Faturamento Proposta')
AAdd(aColun,'Dt. Reprovacao Proposta')
AAdd(aColun,'Dt. Geracao Pedido')
AAdd(aColun,'Loja Cliente')
AAdd(aColun,'Quantidade')
AAdd(aColun,'Preco Tabela')
AAdd(aColun,'Preco Venda')
AAdd(aColun,'Valor Total')

//--------------------------------------

return


Static Function MontData()

aDados:={}

cQuery:=" SELECT ADZ.ADZ_FILIAL AS FILIAL, "
cQuery+=" (SELECT A3_COD FROM SA3010 SA3 WHERE  SA3.D_E_L_E_T_ = ' ' AND A3_COD = ADY.ADY_VEND)  AS VENDEDOR, "
cQuery+=" (SELECT A3_NOME FROM SA3010 SA3 WHERE  SA3.D_E_L_E_T_ = ' ' AND A3_COD = ADY.ADY_VEND)  AS NOME_VEND, "
cQuery+=" ISNULL((SELECT US_COD  FROM  SUS010 SUS  WHERE  SUS.D_E_L_E_T_ = ' ' AND US_COD = ADY.ADY_CODIGO AND US_LOJA = ADY.ADY_LOJA AND US_COD IS NOT NULL AND ADY.ADY_ENTIDA='2'),'') AS PROSPECT, "
cQuery+=" ISNULL((SELECT US_NOME  FROM  SUS010 SUS  WHERE  SUS.D_E_L_E_T_ = ' ' AND US_COD = ADY.ADY_CODIGO AND US_LOJA = ADY.ADY_LOJA AND US_COD IS NOT NULL AND ADY.ADY_ENTIDA='2'),'') AS NOME, "
cQuery+=" ISNULL((SELECT US_CGC  FROM  SUS010 SUS  WHERE  SUS.D_E_L_E_T_ = ' ' AND US_COD = ADY.ADY_CODIGO AND US_LOJA = ADY.ADY_LOJA AND US_COD IS NOT NULL AND ADY.ADY_ENTIDA='2'),'') AS CNPJ, "
cQuery+=" ADY.ADY_OPORTU AS OPORTUNIDADE, "
cQuery+=" (SELECT AD1_DESCRI FROM AD1010 AD1 WHERE  AD1.D_E_L_E_T_ = ' ' AND AD1_NROPOR = ADY.ADY_OPORTU AND AD1_REVISA = ADY.ADY_REVISA)  AS DESCRICAO_OPORTUNIDADE, "
cQuery+=" (SELECT AD1_DATA  FROM  AD1010 AD1  WHERE  AD1.D_E_L_E_T_ = ' ' AND AD1_NROPOR = ADY.ADY_OPORTU AND AD1_REVISA = ADY.ADY_REVISA) AS DEMISSAO_OPORTUNIDADE,  "
cQuery+=" (SELECT AD1_FEELIN FROM AD1010 AD1 WHERE  AD1.D_E_L_E_T_ = ' ' AND AD1_NROPOR = ADY.ADY_OPORTU AND AD1_REVISA = ADY.ADY_REVISA)  AS PROBABILIDADE_SUCESSO,  "
cQuery+=" (SELECT AC1_DESCRI  FROM  AC1010 AC1 INNER JOIN AD1010 AD1 ON AC1_FILIAL = AD1_FILIAL AND AC1_PROVEN = AD1_PROVEN "
cQuery+=" WHERE  AC1.D_E_L_E_T_ = ' ' AND AD1.D_E_L_E_T_ = ' ' AND AD1_NROPOR = ADY.ADY_OPORTU AND AD1_REVISA = ADY.ADY_REVISA) AS PROCESSO_VENDAS, "
cQuery+=" (SELECT AC2_DESCRI FROM AC2010 AC2 INNER JOIN AD1010 AD1 ON AC2_FILIAL = AD1_FILIAL AND AC2_PROVEN = AD1_PROVEN AND AC2_STAGE = AD1_STAGE "
cQuery+=" WHERE  AC2.D_E_L_E_T_ = ' ' AND AD1.D_E_L_E_T_ =' ' AND AD1_NROPOR = ADY.ADY_OPORTU AND AD1_REVISA = ADY.ADY_REVISA)  AS ESTAGIO_VENDAS,  "
cQuery+=" ADZ.ADZ_PRODUT AS CODIGO_PRODUTO, "
cQuery+=" (SELECT B1_COD  FROM  SB1010 SB1  WHERE  D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '    ' AND B1_COD = ADZ.ADZ_PRODUT) AS DESCRICAO_PRODUTO, "
cQuery+=" (SELECT B1_TIPO FROM SB1010 SB1 WHERE  D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '    ' AND B1_COD = ADZ.ADZ_PRODUT)  AS TIPO_PRODUTO, "
cQuery+=" (SELECT X5_DESCRI  FROM  SX5010  WHERE  D_E_L_E_T_ = ' ' AND X5_TABELA = 'ZX' AND X5_CHAVE = (SELECT B1_MARCA FROM SB1010 WHERE  D_E_L_E_T_ = ' ' AND B1_COD = ADZ.ADZ_PRODUT AND B1_COD = ADZ.ADZ_PRODUT ) ) AS MARCA_PRODUTO, "
cQuery+=" (SELECT BM_DESC  FROM  SBM010  WHERE  D_E_L_E_T_ = ' ' AND BM_FILIAL = '01  ' AND BM_GRUPO = (SELECT B1_GRUPO FROM SB1010 WHERE  D_E_L_E_T_ = ' ' AND B1_COD = ADZ.ADZ_PRODUT AND B1_COD = ADZ.ADZ_PRODUT) ) AS GRUPO_PRODUTO, "
cQuery+=" ADZ.ADZ_PROPOS AS PROPOSTA, "
cQuery+=" ADZ.ADZ_REVISA AS REVISAO,  "
cQuery+=" ADZ.ADZ_DESCRI AS DESCRICAO_PROPOSTA, "
cQuery+=" ADZ.ADZ_ITEM AS ITEM, "
cQuery+=" ADZ.ADZ_MOEDA AS MOEDA, "
cQuery+=" CASE "
cQuery+=" (SELECT AD1_STATUS  FROM  AD1010  WHERE  D_E_L_E_T_ = ' ' AND AD1_NROPOR = ADY.ADY_OPORTU AND AD1_REVISA = ADY.ADY_REVISA) "
cQuery+=" WHEN '1' THEN 'Aberta'   "
cQuery+=" WHEN '2' THEN 'Perdido'  "
cQuery+=" WHEN '3' THEN 'Suspenso' "
cQuery+=" WHEN '9' THEN 'Ganha'    "

cQuery+=" END AS STATUS_OPORTUNIDADE, "
cQuery+=" ADY.ADY_STATUS AS STATUS_PROPOSTA, "

cQuery+=" CASE (SELECT AD1_TPPROP FROM AD1010 WHERE  D_E_L_E_T_ = ' ' AND AD1_NROPOR = ADY.ADY_OPORTU AND AD1_REVISA = ADY.ADY_REVISA)  "
cQuery+=" WHEN '1' THEN 'Revenda' "
cQuery+=" WHEN '2' THEN 'Representada' "
cQuery+=" WHEN '3' THEN 'Importacao Direta' "
cQuery+=" WHEN '4' THEN 'Locacao' "
cQuery+=" WHEN '5' THEN 'Contrato Manutencao' "
cQuery+=" WHEN '6' THEN 'Comodato' "
cQuery+=" END AS TIPO_PROCESSO, "
cQuery+=" ADY.ADY_DATA AS DEMISSAO_PROPOSTA, "
cQuery+=" ADY.ADY_DTAPRO AS DAPROVACAO_PROPOSTA,  "
cQuery+=" ADY.ADY_DTFAT AS DFATURAMENTO_PROPOSTA, "
cQuery+=" ADY.ADY_DTREPR AS DREPROVACAO_PROPOSTA, "
cQuery+=" ADY.ADY_DTPDV AS DGERACAO_PEDIDO,       "
cQuery+=" ADY.ADY_CODIGO+ADY.ADY_LOJA AS CODLOJ_CLIENTE, "
cQuery+=" ADZ.ADZ_QTDVEN AS QUANTIDADE, "
cQuery+=" ADZ.ADZ_PRCTAB AS PRECO_TABELA, "
cQuery+=" ADZ.ADZ_PRCVEN AS PRECO_VENDA, "
cQuery+=" ADZ.ADZ_TOTAL AS VALOR_TOTAL, "
cQuery+=" ADY.ADY_SINCPR AS SINCRONISMO_PROPOSTA FROM ADZ010 ADZ "

cQuery+=" INNER JOIN ADY010 ADY ON ADZ.ADZ_FILIAL = ADY.ADY_FILIAL AND ADZ.ADZ_PROPOS = ADY.ADY_PROPOS "


cQuery+=" WHERE "

cQuery+=" ADZ.D_E_L_E_T_ = ' ' "
cQuery+=" AND ADY.D_E_L_E_T_ = ' ' "
cQuery+=" AND ADY.D_E_L_E_T_ = ' ' "

cQuery+=" AND ADZ.ADZ_REVISA = (SELECT MAX(ADZ_REVISA)  FROM  ADZ010  WHERE  D_E_L_E_T_ = ' ' AND ADZ_FILIAL = ADZ.ADZ_FILIAL AND ADZ_PROPOS = ADZ.ADZ_PROPOS ) "



//cQuery+=" AND  CQ2.CQ2_DATA >= '"+Dtos(MV_PAR01)+"'"
//cQuery+=" AND  CQ2.CQ2_DATA <= '"+Dtos(MV_PAR02)+"'"
//cQuery+=" ORDER BY CQ2_DATA "
MEMOWRITE ("\CRMDEBORA.SQL", cQuery)
cQuery:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TSFT",.F.,.T.)

//TcSetField( "TSFT", "CQ2_DEBITO" , TamSX3("CQ2_DEBITO")[3] , TamSX3("CQ2_DEBITO")[1] , TamSX3("CQ2_DEBITO")[2] )
//TcSetField( "TSFT", "CQ2_CREDIT" , TamSX3("CQ2_CREDIT")[3] , TamSX3("CQ2_CREDIT")[1] , TamSX3("CQ2_CREDIT")[2] )

cEmpresa:=AllTrim(MV_PAR03)
cContrato:=""
nLin:=0
ProcRegua(TSFT->(RECCOUNT()))
dbGoTop()
While TSFT->(!EOF())
	
	
	If (TSFT->DEMISSAO_OPORTUNIDADE>=Dtos(MV_PAR01) .And. TSFT->DEMISSAO_OPORTUNIDADE<=Dtos(MV_PAR02)) .And. AllTrim(TSFT->PROSPECT)<>'' 
	 if !EMPTY(AllTrim(MV_PAR03)) .And. AllTrim(TSFT->MARCA_PRODUTO)=AllTrim(MV_PAR03) 
		IncProc("Gerando registro referente a conta: "+TSFT->OPORTUNIDADE)
		
		aLinha:={}
		
		aadd(aLinha,chr(160)+TSFT->FILIAL)
		aadd(aLinha,chr(160)+TSFT->VENDEDOR)
		aadd(aLinha,chr(160)+TSFT->NOME_VEND)
		aadd(aLinha,chr(160)+TSFT->PROSPECT)
		aadd(aLinha,chr(160)+TSFT->NOME)
		aadd(aLinha,chr(160)+TSFT->CNPJ)
		aadd(aLinha,chr(160)+TSFT->OPORTUNIDADE)
		aadd(aLinha,chr(160)+TSFT->DESCRICAO_OPORTUNIDADE)
		aadd(aLinha,DtoC(sTod(DEMISSAO_OPORTUNIDADE)))
		aadd(aLinha,chr(160)+TSFT->PROBABILIDADE_SUCESSO)
		aadd(aLinha,chr(160)+TSFT->PROCESSO_VENDAS)
		aadd(aLinha,chr(160)+TSFT->ESTAGIO_VENDAS)
		aadd(aLinha,chr(160)+TSFT->CODIGO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->DESCRICAO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->TIPO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->MARCA_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->GRUPO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->PROPOSTA)
		aadd(aLinha,chr(160)+TSFT->REVISAO)
		aadd(aLinha,chr(160)+TSFT->DESCRICAO_PROPOSTA)
		aadd(aLinha,chr(160)+TSFT->ITEM)
		aadd(aLinha,chr(160)+TSFT->MOEDA)
		aadd(aLinha,chr(160)+TSFT->STATUS_OPORTUNIDADE)
		aadd(aLinha,chr(160)+TSFT->STATUS_PROPOSTA)
		aadd(aLinha,chr(160)+TSFT->TIPO_PROCESSO)
		aadd(aLinha,DtoC(sTod(DEMISSAO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DAPROVACAO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DFATURAMENTO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DREPROVACAO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DGERACAO_PEDIDO)))
		aadd(aLinha,chr(160)+TSFT->CODLOJ_CLIENTE)
		aadd(aLinha,Transform(TSFT->QUANTIDADE, "@ZE 9999.99" ))
		aadd(aLinha,Transform(TSFT->PRECO_TABELA, "@ZE 999,999,999.99" ))
		aadd(aLinha,Transform(TSFT->PRECO_VENDA, "@ZE 999,999,999.99" ))
		aadd(aLinha,Transform(TSFT->VALOR_TOTAL, "@ZE 999,999,999.99" ))
		
		aadd(aDados,aLinha)
	 Endif
	 if EMPTY(AllTrim(MV_PAR03))  
		IncProc("Gerando registro referente a conta: "+TSFT->OPORTUNIDADE)
		
		aLinha:={}
		
		aadd(aLinha,chr(160)+TSFT->FILIAL)
		aadd(aLinha,chr(160)+TSFT->VENDEDOR)
		aadd(aLinha,chr(160)+TSFT->NOME_VEND)
		aadd(aLinha,chr(160)+TSFT->PROSPECT)
		aadd(aLinha,chr(160)+TSFT->NOME)
		aadd(aLinha,chr(160)+TSFT->CNPJ)
		aadd(aLinha,chr(160)+TSFT->OPORTUNIDADE)
		aadd(aLinha,chr(160)+TSFT->DESCRICAO_OPORTUNIDADE)
		aadd(aLinha,DtoC(sTod(DEMISSAO_OPORTUNIDADE)))
		aadd(aLinha,chr(160)+TSFT->PROBABILIDADE_SUCESSO)
		aadd(aLinha,chr(160)+TSFT->PROCESSO_VENDAS)
		aadd(aLinha,chr(160)+TSFT->ESTAGIO_VENDAS)
		aadd(aLinha,chr(160)+TSFT->CODIGO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->DESCRICAO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->TIPO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->MARCA_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->GRUPO_PRODUTO)
		aadd(aLinha,chr(160)+TSFT->PROPOSTA)
		aadd(aLinha,chr(160)+TSFT->REVISAO)
		aadd(aLinha,chr(160)+TSFT->DESCRICAO_PROPOSTA)
		aadd(aLinha,chr(160)+TSFT->ITEM)
		aadd(aLinha,chr(160)+TSFT->MOEDA)
		aadd(aLinha,chr(160)+TSFT->STATUS_OPORTUNIDADE)
		aadd(aLinha,chr(160)+TSFT->STATUS_PROPOSTA)
		aadd(aLinha,chr(160)+TSFT->TIPO_PROCESSO)
		aadd(aLinha,DtoC(sTod(DEMISSAO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DAPROVACAO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DFATURAMENTO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DREPROVACAO_PROPOSTA)))
		aadd(aLinha,DtoC(sTod(DGERACAO_PEDIDO)))
		aadd(aLinha,chr(160)+TSFT->CODLOJ_CLIENTE)
		aadd(aLinha,Transform(TSFT->QUANTIDADE, "@ZE 9999.99" ))
		aadd(aLinha,Transform(TSFT->PRECO_TABELA, "@ZE 999,999,999.99" ))
		aadd(aLinha,Transform(TSFT->PRECO_VENDA, "@ZE 999,999,999.99" ))
		aadd(aLinha,Transform(TSFT->VALOR_TOTAL, "@ZE 999,999,999.99" ))
		
		aadd(aDados,aLinha)
	 Endif	
	Endif
	
	TSFT->(dbSkip())
EndDo


TSFT->(dbCloseArea())

Return



Static Function geraXLS()

If !ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel n„o instalado!")
	Return
EndIf

MsgRun("Aguarde.....", "Exportando os Registros para o Excel",{||DlgToExcel({ {"ARRAY", "Gerando Relatorio de Oportunidades x Prospect", aColun, aDados} })})
//DlgToExcel({ {"ARRAY", "Fluxo por Contrato", aColun, aDados} })


Return
