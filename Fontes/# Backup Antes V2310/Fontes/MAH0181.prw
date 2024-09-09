#include 'protheus.ch'
#Include "TopConn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMAH0181  บ Autor ณEdnei Rosa da Silva  บ Data ณ 03-12-2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza tabela de preco com preco de custo para envio     บฑฑ
ฑฑบDescricao ณ de remessa ao cliente 								      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ MAH0181()                                                  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MAH0181()


U_MAH0181A()


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMAH0181A  บ Autor ณEdnei Rosa da Silva  บ Data ณ 03-12-2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Clona a tabela (007 REAIS) e cria 024 com preco de custo   บฑฑ
ฑฑบDescricao ณ para envio de remessa ao cliente 						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ MAH0181A()                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MAH0181A()

	Local cAliasZ	  := GetNextAlias()
	Local cQueryZ     :=''

    
	cQueryZ := "    SELECT      "
	cQueryZ += "    DA1_FILIAL, "
	cQueryZ += "    DA1_ITEM,   "
	cQueryZ += "    '024' DA1_CODTAB,      "
	cQueryZ += "    DA1_CODPRO, "
	cQueryZ += "    DA1_GRUPO,  "
	cQueryZ += "    DA1_REFGRD, "
	cQueryZ += "    (SELECT ROUND(ISNULL(AVG(SB2.B2_CM1),0),2) FROM " + RetSQLName("SB2") + " SB2 WHERE SB2.B2_COD=DA1_CODPRO AND SB2.D_E_L_E_T_<>'*' AND SB2.B2_LOCAL='01') AS DA1_PRCVEN, "
	cQueryZ += "    DA1_VLRDES, "
	cQueryZ += "    DA1_PERDES, "
	cQueryZ += "    DA1_ATIVO,  "
	cQueryZ += "    DA1_FRETE,  "
	cQueryZ += "    DA1_ESTADO, "
	cQueryZ += "    DA1_TPOPER, "
	cQueryZ += "    DA1_QTDLOT, "
	cQueryZ += "    DA1_INDLOT, "
	cQueryZ += "    DA1_MOEDA,  "
	cQueryZ += "    (SELECT DA0_DATDE FROM " + RetSQLName("DA0") + " DA0 WHERE DA0.DA0_CODTAB='024' AND DA0.D_E_L_E_T_<>'*') DA1_DATVIG, "
	cQueryZ += "    DA1_ITEMGR, "
	cQueryZ += "    DA1_DTUMOV, "
	cQueryZ += "    DA1_HRUMOV, "
	cQueryZ += "    DA1_PRCMAX, "
	cQueryZ += "    DA1_USERGA, "
	cQueryZ += "    DA1_USERGI, "
	cQueryZ += "    DA1_MSEXP,  "
	cQueryZ += "    DA1_HREXPO, "
	cQueryZ += "    DA1_ECSEQ,  "
	cQueryZ += "    DA1_ECDTEX, "
	cQueryZ += "    DA1_UPSITE, "
	cQueryZ += "    DA1_UPVLR,  "
	cQueryZ += "    DA1_PRCDOL, "
	cQueryZ += "    DA1_PRCEUR, "
	cQueryZ += "    DA1_TIPO,   "
	cQueryZ += "    DA1_TIPPRE, "
	cQueryZ += "    DA1_ZOHDTH, "
	cQueryZ += "    DA1_CODTIP  "

	cQueryZ += "    FROM " + RetSQLName("DA1") + " WHERE DA1_CODTAB='007' AND D_E_L_E_T_<>'*' "
    
	cQueryZ := ChangeQuery(cQueryZ)			
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQueryZ ),cAliasZ,.F.,.T. )

	
	While ( cAliasZ )->( !Eof() )
		
		
		IF !U_MAH0181C(( cAliasZ  )->DA1_CODTAB,( cAliasZ  )->DA1_CODPRO)
			DbSelectArea("DA1")
			reclock("DA1",.T.)
			
			DA1->DA1_FILIAL= ( cAliasZ  )->DA1_FILIAL
			DA1->DA1_ITEM	= ( cAliasZ  )->DA1_ITEM
			DA1->DA1_CODTAB = ( cAliasZ  )->DA1_CODTAB
			DA1->DA1_CODPRO = ( cAliasZ  )->DA1_CODPRO
			DA1->DA1_GRUPO  = ( cAliasZ  )->DA1_GRUPO
			DA1->DA1_REFGRD = ( cAliasZ  )->DA1_REFGRD
			DA1->DA1_PRCVEN = ( cAliasZ  )->DA1_PRCVEN
			DA1->DA1_VLRDES = ( cAliasZ  )->DA1_VLRDES
			DA1->DA1_PERDES = ( cAliasZ  )->DA1_PERDES
			DA1->DA1_ATIVO  = ( cAliasZ  )->DA1_ATIVO
			DA1->DA1_FRETE  = ( cAliasZ  )->DA1_FRETE
			DA1->DA1_ESTADO = ( cAliasZ  )->DA1_ESTADO
			DA1->DA1_TPOPER = ( cAliasZ  )->DA1_TPOPER
			DA1->DA1_QTDLOT = ( cAliasZ  )->DA1_QTDLOT
			DA1->DA1_INDLOT = ( cAliasZ  )->DA1_INDLOT
			DA1->DA1_MOEDA  = ( cAliasZ  )->DA1_MOEDA
			DA1->DA1_DATVIG = sToD(( cAliasZ  )->DA1_DATVIG)
			DA1->DA1_ITEMGR = ( cAliasZ  )->DA1_ITEMGR
			DA1->DA1_DTUMOV = sToD(( cAliasZ  )->DA1_DTUMOV)
			DA1->DA1_HRUMOV = ( cAliasZ  )->DA1_HRUMOV
			DA1->DA1_PRCMAX = ( cAliasZ  )->DA1_PRCMAX
			DA1->DA1_USERGA = ( cAliasZ  )->DA1_USERGA
			DA1->DA1_USERGI = ( cAliasZ  )->DA1_USERGI
			DA1->DA1_MSEXP  = ( cAliasZ  )->DA1_MSEXP
			DA1->DA1_HREXPO = ( cAliasZ  )->DA1_HREXPO
			DA1->DA1_ECSEQ  = ( cAliasZ  )->DA1_ECSEQ
			DA1->DA1_ECDTEX = ( cAliasZ  )->DA1_ECDTEX
			DA1->DA1_UPSITE = ( cAliasZ  )->DA1_UPSITE
			DA1->DA1_UPVLR  = ( cAliasZ  )->DA1_UPVLR
			DA1->DA1_PRCDOL = ( cAliasZ  )->DA1_PRCDOL
			DA1->DA1_PRCEUR = ( cAliasZ  )->DA1_PRCEUR
			DA1->DA1_TIPO   = ( cAliasZ  )->DA1_TIPO
			DA1->DA1_TIPPRE = ( cAliasZ  )->DA1_TIPPRE
			DA1->DA1_ZOHDTH = sToD(( cAliasZ  )->DA1_ZOHDTH)
			DA1->DA1_CODTIP = ( cAliasZ  )->DA1_CODTIP
			
		    MsUnLock()  
		 else  
	        U_MAH0181B(( cAliasZ  )->DA1_CODTAB, ( cAliasZ  )->DA1_CODPRO, ( cAliasZ  )->DA1_PRCVEN)
	     endif 
    
    
	( cAliasZ  )->( dbSkip() )	
	EndDo

	( cAliasZ  )->( dbCloseArea() )
	( "DA1" )->( dbCloseArea() )
	
Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMAH0181B  บ Autor ณEdnei Rosa da Silva  บ Data ณ 03-12-2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza tabela de preco de custo caso ja exista na tabela บฑฑ
ฑฑบDescricao ณ 24					 								      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ MAH0181B()                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MAH0181B(cTab, cProduto, nCusto)

Local cQueryW := ""

cQueryW:=""
cQueryW+=" UPDATE DA1010 SET DA1_PRCVEN="+cValToChar(nCusto)
cQueryW+=" WHERE "
cQueryW+=" DA1_CODTAB     =  '"+cTab+"'"
cQueryW+=" AND DA1_CODPRO =  '"+cProduto+"'"
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
ฑฑบFunction ณDA0      บAutor  ณEdnei Silva           บ Data ณ  20/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Testa se ja existo o item na tabela de preco 080          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  MAH0181C()                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function MAH0181C(cTabela,cProduto)
Local lOk		:= .F.
Local cAliasX	:= GetNextAlias()

// procura o produto na tabela de preco 

BeginSql  Alias cAliasX
SELECT COUNT(DA1_CODPRO) QTD_REG
FROM %Table:DA1% DA1
WHERE DA1_FILIAL    = %xFilial:DA1%  AND
	  DA1_CODTAB    = %Exp:cTabela%  AND  
	  DA1_CODPRO    = %Exp:cProduto% AND 
	  DA1.%notdel%  
EndSql
	
	  // verifi se e xiste registro
	  IF (cAliasX)->QTD_REG>0
	     lOk		:= .T.
	  Endif
( cAliasX  )->( dbCloseArea() )
return lOk 


