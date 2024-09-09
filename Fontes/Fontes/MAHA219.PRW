#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#include "fileio.ch"




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunction ณzeraZ30     บAutor  ณEdnei Silva        บ Data ณ  20/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Zerar a coluna Z30_QTDCOM                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  atuZ30()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


USER Function MAHA219()
Local nRetReg:=0
Local cQuery :=""
Local cMsg   :=""
Local nRegAdd:=0

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
cQuery+= " F4_FINALID,  "
cQuery+= " B6_SALDO,    "
cQuery+= " B1_DESC,     "
cQuery+= " B6_IDENT,    "
cQuery+= " B6_LOJA,     "
cQuery+= " B6_CUSTO1,   "
cQuery+= " B1_GRUPO,    "
cQuery+= " B1_MARCA,    "
cQuery+= " B1_DESCMAR  ,"
cQuery+= " A3_COD,      "
cQuery+= " A3_NOME,     "
cQuery+= " A1_NOME ,    "
cQuery+= " A1_LOJA,     "
cQuery+= " BM_DESC      "

cQuery+= " FROM  SB6010 SB6  INNER JOIN  SD2010 SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_ITEM='01' AND SD2.D_E_L_E_T_<>'*') "
cQuery+= " INNER JOIN  SC5010 SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*')"
cQuery+= " INNER JOIN  SA1010 SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "
cQuery+= " INNER JOIN  SA3010 SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*') "
cQuery+= " JOIN  SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "
cQuery+= " JOIN  SF4010 SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
cQuery+= " JOIN  SBM010 SBM ON (SB1.B1_GRUPO=SBM.BM_GRUPO AND SBM.D_E_L_E_T_<>'*') "

cQuery+= " WHERE SB6.B6_DOC >= '' "
cQuery+= " AND SB6.B6_DOC <= 'ZZZZZZZZZ' "
cQuery+= " AND SB6.B6_SERIE   	 >= '' "
cQuery+= " AND SB6.B6_SERIE   	 <= 'ZZZ' "
cQuery+= " AND SB6.B6_EMISSAO 	 >= '20150101' "
cQuery+= " AND SB6.B6_EMISSAO 	 <=  '" + DTOS(dDataBase) + "'"
cQuery+= " AND SB6.B6_PRODUTO 	 >= '' "
cQuery+= " AND SB6.B6_PRODUTO 	 <= 'ZZZZZZZZZZZ' "
cQuery+= " AND SB6.B6_SALDO		 >0 "
cQuery+= " AND SA3.A3_COD         >= '' "
cQuery+= " AND SA3.A3_COD  	     <= 'ZZZZZZ' "
cQuery+= " AND B6_TPCF			  = 'C' "
cQuery+= " AND SB6.B6_TIPO		  = 'E' "
cQuery+= " AND SB6.B6_TES		  IN ('608','683') "
cQuery+= " AND SB6.D_E_L_E_T_	 <> '*' "
cQuery+= " AND SB1.B1_TIPO	 	  = 'M1' "

cQuery+= " Order By SB6.B6_DOC, SB6.B6_SERIE, SB6.B6_EMISSAO "



MEMOWRITE("EMTERCEIROSXLS.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TSB6",.F.,.T.)
TCSETFIELD( "TSB6","DB_DATA","D")



nRetReg:=0
cMsg   :=''
dbGoTop()
zeraZ30()
While !TSB6->(Eof())
	
	nRetReg:=atuZ30(TSB6->B6_CLIFOR, TSB6->B6_LOJA, TSB6->B6_SALDO,TSB6->B1_GRUPO)
	If nRetReg=0
		nRegAdd++
		DbSelectArea("Z30")
		reclock("Z30",.T.)
		//--------------------------
		
		cMsg += '[ITEM - '      +cValToChar(nRegAdd)			  +']; '
	    cMsg += '[ NF/SERIE'    + TSB6->B6_DOC +'/'+ TSB6->B6_DOC +']; '  
		cMsg += '[ Z30->CODGRU' + TSB6->B1_GRUPO 				  +']; '
		cMsg += '[ Z30_DESCRI ' + TSB6->BM_DESC  				  +']; '
		cMsg += '[ Z30_CODCLI ' + TSB6->B6_CLIFOR				  +']; '
		cMsg += '[ Z30_LOJA   ' + TSB6->A1_LOJA					  +']; '
		cMsg += '[ Z30_NOME   ' + TSB6->A1_NOME					  +']; '
		cMsg += '[ Z30_QUANT  ' + '0'							  +']; '
		cMsg += '[ Z30_MARCA  ' + TSB6->B1_MARCA				  +']; '
		cMsg += '[ Z30_DESMAR ' + TSB6->B1_DESCMAR				  +']; '
		cMsg += '[ Z30_VALOR  ' + '0'							  +']; '
		cMsg += '[ Z30_DTINIC ' + str(YEAR(ddatabase))+'0101'	  +']; '
		cMsg += '[ Z30_QTDCOM ' + '0'							  +']; '
		cMsg += '[ Z30_PRVCOM ' + cValToChar(TSB6->B6_SALDO)	  +']; '+ CRLF
		
		
		
		//Z30->Z30_FILIAL :=TSB6->B6_FILIAL
		Z30->Z30_CODCLI :=TSB6->B6_CLIFOR
		Z30->Z30_LOJA   :=TSB6->A1_LOJA
		Z30->Z30_DTINIC :=StoD(Year2Str(ddatabase)+'0101')
		Z30->Z30_DTFIM  :=StoD(Year2Str(ddatabase)+'1231')
		Z30->Z30_CODGRU :=TSB6->B1_GRUPO
		Z30->Z30_DESCRI :=TSB6->BM_DESC
		Z30->Z30_NOME   :=TSB6->A1_NOME
		Z30->Z30_QUANT  :=0
		Z30->Z30_MARCA  :=TSB6->B1_MARCA
		Z30->Z30_DESMAR :=TSB6->B1_DESCMAR
		Z30->Z30_VALOR  :=0
		//Z30->Z30_QTDCOM :='0'
		Z30->Z30_PRVCOM :=TSB6->B6_SALDO
		//--------------------------
		MsUnLock()
				
	endif
	TSB6->(dbSkip())
	
Enddo

MEMOWRITE("LogComodato_"+dToS(ddatabase)+".TXT",cMsg)
Alert('Atualizacao concluida. Forma incluidos mais: '+cValToChar(nRegAdd))
dbCloseArea("Z30")	    
dbCloseArea("TSB6")
return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunction ณzeraZ30     บAutor  ณEdnei Silva        บ Data ณ  20/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Zerar a coluna Z30_QTDCOM                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  atuZ30()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function zeraZ30()

//Local cArea01 := Alias()

cQureryAZ30:=""
cQureryAZ30+=" UPDATE Z30010 SET Z30_PRVCOM=0"
cQureryAZ30+=" WHERE D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQureryAZ30)
If nRet<>0
	Alert(TCSQLERROR())
Endif

//dbCloseArea(cArea01)

return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunction ณatuZ30      บAutor  ณEdnei Silva        บ Data ณ  20/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Atualizr a coluna Z30_QTDCOM                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  atuZ30()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function atuZ30(cCliente, cLoja, nB6SLD, cGrupo)

//Local cArea02 := Alias()
Local nRegZ30 :=0

cQuery03:=""
cQuery03:=" SELECT * FROM Z30010 "
cQuery03+=" WHERE "
cQuery03+=" Z30_CODCLI 		= '"+cCliente+"'"
cQuery03+=" AND Z30_LOJA 	= '"+cLoja+"'"
cQuery03+=" AND Z30_CODGRU  = '"+cGrupo+"'"
cQuery03+=" AND D_E_L_E_T_  <> '*' "

MEMOWRITE("atuZ30_Query03.SQL",cQuery03)
cQuery03 := ChangeQuery(cQuery03)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery03 ),"TZ30",.F.,.T.)


While !TZ30->(Eof())
	
	nRegZ30++
	TZ30->(dbSkip())	
Enddo                        

dbCloseArea("TZ30")
dbSelectArea("TSB6")

cQureryUZ30:=""
cQureryUZ30+=" UPDATE Z30010 SET Z30_PRVCOM=Z30_PRVCOM+"+cValToChar(nB6SLD)
cQureryUZ30+=" WHERE "
cQureryUZ30+=" Z30_CODCLI	= '"+cCliente+"'"
cQureryUZ30+=" AND Z30_LOJA = '"+cLoja+"'"
cQureryUZ30+=" AND Z30_CODGRU = '"+cGrupo+"'"
cQureryUZ30+=" AND D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQureryUZ30)
If nRet<>0
	Alert(TCSQLERROR())
Endif




//dbCloseArea(cArea02)


return nRegZ30


