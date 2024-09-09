#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#include "fileio.ch"

/*
±±ºDesc.     ³  Calcular a coluna Z30_XQTDAJ                                 º±±
*/

USER Function MAHB219()
Local nRetReg:=0
Local cQuery :=""
Local cMsg   :=""
Local nRegAdd:=0
Local nRegAlt:=0

msgstop("Programa MAHB219 - Calcula quantidades realizadas e grava em campo de ajuste Z30_XQTDAJ")

cQuery:= " SELECT	B6_FILIAL, "
cQuery+= " B6_DOC,      "
cQuery+= " B6_SERIE,    "
cQuery+= " B6_CLIFOR,   "
cQuery+= " B6_TPCF,     "
cQuery+= " B6_PRODUTO,  "
cQuery+= " B6_QUANT,    "
cQuery+= " B6_PRUNIT,   "
cQuery+= " B6_EMISSAO,  "
cQuery+= " B6_TIPO,     "
cQuery+= " B6_TES,      "
cQuery+= " B6_PODER3,   "
//cQuery+= " F4_FINALID,  "
cQuery+= " B6_SALDO,    "
cQuery+= " B1_DESC,     "
cQuery+= " B6_IDENT,    "
cQuery+= " B6_LOJA,     "
cQuery+= " B6_CUSTO1,   "
cQuery+= " B1_GRUPO,    "
cQuery+= " B1_MARCA,    "
cQuery+= " B1_DESCMAR  "
//cQuery+= " A3_COD,      "
//cQuery+= " A3_NOME,     "
//cQuery+= " A1_NOME ,    "
//cQuery+= " A1_LOJA,     "
//cQuery+= " BM_DESC      "

cQuery+= " FROM  SB6010 SB6 "  
//INNER JOIN  SD2010 SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_ITEM='01' AND SD2.D_E_L_E_T_<>'*') "
//cQuery+= " INNER JOIN  SC5010 SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*')"
//cQuery+= " INNER JOIN  SA1010 SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "
//cQuery+= " INNER JOIN  SA3010 SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*') "
cQuery+= " JOIN  SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "
//cQuery+= " JOIN  SF4010 SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
//cQuery+= " JOIN  SBM010 SBM ON (SB1.B1_GRUPO=SBM.BM_GRUPO AND SBM.D_E_L_E_T_<>'*') "

cQuery+= " WHERE SB6.B6_DOC >= '' "
cQuery+= " AND SB6.B6_DOC <= 'ZZZZZZZZZ' "
cQuery+= " AND SB6.B6_EMISSAO 	 >= '20150101' "
cQuery+= " AND SB6.B6_EMISSAO 	 <=  '" + DTOS(dDataBase) + "'"
//cQuery+= " AND SB6.B6_CLIFOR	 ='000054'"
//cQuery+= " AND SB6.B6_LOJA		 ='0001'"
//cQuery+= " AND SB1.B1_GRUPO 	 ='2520'"
cQuery+= " AND SB6.B6_SALDO		 >0 "
cQuery+= " AND B6_TPCF			  = 'C' "
cQuery+= " AND SB6.B6_TIPO		  = 'E' "
cQuery+= " AND SB6.B6_TES		  IN ('608','683') "
cQuery+= " AND SB6.D_E_L_E_T_	 <> '*' "
cQuery+= " AND SB1.B1_TIPO	 	  = 'M1' "

cQuery+= " Order By SB6.B6_DOC, SB6.B6_SERIE, SB6.B6_EMISSAO "

//MEMOWRITE("EMTERCEIROSXLS.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TSB6",.F.,.T.)
TCSETFIELD( "TSB6","DB_DATA","D")

Count to nCount
msgstop("Vai processar "+cvaltochar(nCount)+" registros SB6")

nRetReg:=0
cMsg   :=''

TSB6->(dbGoTop())

zeraZ30()               // zera campo Z30_PRVCOM

While !TSB6->(Eof())
	
	nRetReg:=atuZ30(TSB6->B6_CLIFOR, TSB6->B6_LOJA, TSB6->B6_SALDO,TSB6->B1_GRUPO,TSB6->B6_EMISSAO)

	If nRetReg=0

		nRegAdd++

	Else

		nRegAlt := nRegAlt + nRetReg
	
	endif
	
	TSB6->(dbSkip())
	
Enddo

Alert('Não achou na Z30 : '+cValToChar(nRegAdd))

dbCloseArea("Z30")	    

dbCloseArea("TSB6")

return

/*
±±ºDesc.     ³  Zerar a coluna Z30_XQTDAJ                                 º±±
*/

static function zeraZ30()

//Local cArea01 := Alias()

cQureryAZ30:=""
cQureryAZ30+=" UPDATE Z30010 SET Z30_XQTDAJ=0"
cQureryAZ30+=" WHERE D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQureryAZ30)
If nRet<>0
	Alert(TCSQLERROR())
Endif

//dbCloseArea(cArea01)

return

Static Function atuZ30(cCliente, cLoja, nB6SLD, cGrupo, cEmissao)

Local nRegZ30 :=0

cQuery03:=""
cQuery03:=" SELECT * FROM Z30010 "
cQuery03+=" WHERE "
cQuery03+="     Z30_CODCLI 	 = '"+cCliente+"'"
cQuery03+=" AND Z30_LOJA 	 = '"+cLoja   +"'"
cQuery03+=" AND Z30_CODGRU   = '"+cGrupo  +"'"
cQuery03+=" AND D_E_L_E_T_  <> '*' "
cQuery03+=" AND Z30_DTINIC  <= '"+cEmissao +"'"
cQuery03+=" AND Z30_DTFIM   >= '"+cEmissao +"'"

MEMOWRITE("atuZ30_Query03.SQL",cQuery03)

cQuery03 := ChangeQuery(cQuery03)

dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery03 ),"TZ30B",.F.,.T.)

//----------------------------------Conta quantos registros do cliente no intervalo de vigencia ref. data da nota
While !TZ30B->(Eof())
	
	nRegZ30++
//MSGSTOP(cvaltochar(nRegZ30))
	TZ30B->(dbSkip())	

Enddo                        

dbCloseArea("TZ30B")
dbSelectArea("TSB6")

If  nRegZ30 > 0 

	cQureryUZ30:=""
	cQureryUZ30+=" UPDATE Z30010     SET Z30_XQTDAJ=Z30_XQTDAJ+"+cValToChar(nB6SLD)
	cQureryUZ30+=" WHERE "
	cQureryUZ30+="     Z30_CODCLI  = '"+cCliente+"'"
	cQureryUZ30+=" AND Z30_LOJA    = '"+cLoja+"'"
	cQureryUZ30+=" AND Z30_CODGRU  = '"+cGrupo+"'"
	cQureryUZ30+=" AND D_E_L_E_T_ <> '*' "
	cQureryUZ30+=" AND Z30_DTINIC <= '"+cEmissao +"'"
	cQureryUZ30+=" AND Z30_DTFIM  >= '"+cEmissao +"'"

	nRet:=TcSqlExec(cQureryUZ30)

	If nRet<>0
		Alert(TCSQLERROR())
	Endif

Endif

return nRegZ30
