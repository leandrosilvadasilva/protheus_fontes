#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#include "fileio.ch"


USER Function MAHR487()
PRIVATE cPerg  := PadR("MAHR487",10)



CriaSX1( cPerg )

If Pergunte(cPerg,.T.)

	Processa( {|| gerExcel()},"Gerando Analise de compras V1" )

Endif




Return



static function gerExcel()

Local   aCabec := {}
Local   aDados := {}


cQuery:=" " 

cQuery :=	" SELECT "
cQuery +=	" B9_FILIAL    , "
cQuery +=	" B9_LOCAL     , "
cQuery +=	" B9_DATA      , "
cQuery +=	" B1_COD       , "
cQuery +=	" B1_TIPO      , "
cQuery +=	" B1_GRUPO     , "
cQuery +=	" BM_DESC      , "
cQuery +=	" B1_DESC      , "
cQuery +=	" B1_MARCA     , "
cQuery +=	" B1_DESCMAR   , "
cQuery +=	" SUM(B9_QINI) B9_QINI , "
cQuery +=	" B1_ZCODEXT   , "
cQuery +=	" B1_ZMULTIP   , "

cQuery +=	" (Select "
	   
	  cQuery +=	" SUM(C6_QTDVEN-C6_QTDENT) "
	   
cQuery +=	" from "+RetSQLName("SC6")+ " SC6 "

cQuery +=	" Inner Join "+RetSQLName("SF4")+ " SF4 ON (SF4.F4_CODIGO=SC6.C6_TES  AND SF4.F4_FILIAL=SC6.C6_FILIAL) "
cQuery +=	" Inner Join "+RetSQLName("SC5")+ " SC5 ON (SC5.C5_NUM=SC6.C6_NUM  AND SC5.C5_FILIAL=SC6.C6_FILIAL)    "


cQuery +=	"   WHERE SC6.C6_FILIAL=SB9PAI.B9_FILIAL "
cQuery +=	"   AND SC6.C6_ENTREG >=SB9PAI.B9_DATA " 
cQuery +=	"   AND SC6.C6_ENTREG <=CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, 4,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	" 
cQuery +=	"   AND SC6.C6_PRODUTO=SB1.B1_COD        "
cQuery +=	"   AND SC6.C6_QTDVEN<>C6_QTDENT         "
cQuery +=	"   AND SC6.D_E_L_E_T_<>'*'              "
cQuery +=	"   AND SF4.D_E_L_E_T_<>'*'              "
cQuery +=	"   AND SC6.C6_BLQ<>'R'                  "


If !Empty(MV_PAR09)

  cQuery +=	"   AND B9_LOCAL IN " + FormatIn(AllTrim(MV_PAR09),";")

else 

  cQuery +=	"    AND SC6.C6_LOCAL='01'             "	

endif

If !Empty(MV_PAR12)
   cQuery +=	"   AND SC5.C5_NATUREZ IN " + FormatIn(AllTrim(MV_PAR12),";")
Endif 

cQuery +=	"   AND SC5.C5_NOTA<>'XXXXXXXXX') SALDO_PEDIDO, "

/*##### SALDO ATUAL ############################################################################################################################################################################################*/
/* SALDO ATUAL SEM CONSIDERAR PV E PC NAO FATURADOS */
/*#####################################################*/
cQuery +=	"   (SELECT  "
cQuery +=	"       B2_QATU  "
cQuery +=	"   FROM "+RetSQLName("SB2")+ " SB2 " 
cQuery +=	"   WHERE B2_FILIAL=SB9PAI.B9_FILIAL "
cQuery +=	"         AND B2_LOCAL=SB9PAI.B9_LOCAL "
cQuery +=	"   	  AND SB2.D_E_L_E_T_<>'*' "
cQuery +=	"   	  AND SB2.B2_COD=B1_COD) SLD_ATUAL, "


/*##### SALDO PEDID DE VENDAS ############################################################################################################################################################################################*/
/* SALDO PEDIDO DE VENDAS  */
/*#####################################################*/


cQuery +=	" (SELECT  "
    cQuery +=	" B2_QPEDVEN "
cQuery +=	" FROM "+RetSQLName("SB2")+ " SB2 "                
cQuery +=	" WHERE B2_FILIAL=SB9PAI.B9_FILIAL " 
cQuery +=	" AND B2_LOCAL=SB9PAI.B9_LOCAL     "
cQuery +=	" AND SB2.D_E_L_E_T_<>'*'          "
cQuery +=	" AND SB2.B2_COD=B1_COD) SALDO_PV, "

/*##### SALDO PEDIDO DE COMPRAS ############################################################################################################################################################################################*/
/* SALDO PEDIDO DE COMPRAS */
/*#####################################################*/


cQuery +=	" (SELECT "
cQuery +=	" SUM(SOMA_PRE) AS SALDO_PC_PRE_NOTA " 
cQuery +=	" FROM " 
cQuery +=	" (SELECT ISNULL(SUM(D1_QUANT),0) AS SOMA_PRE "
cQuery +=	" FROM "+RetSQLName("SD1")+ " SD1 " 
cQuery +=	" INNER JOIN "+RetSQLName("SA2")+ " SA2  ON (SA2.A2_COD=SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA) "	
cQuery +=	" WHERE     D1_COD         = B1_COD "
cQuery +=	" AND D1_FILIAL      = SB9PAI.B9_FILIAL "   
cQuery +=	" AND D1_LOCAL       = SB9PAI.B9_LOCAL  "
cQuery +=	" AND SA2.D_E_L_E_T_ <> '*' " 
cQuery +=	" AND SD1.D_E_L_E_T_ <> '*' " 
cQuery +=	" AND SD1.D1_NUMSEQ  = ''   "
cQuery +=	" AND SA2.A2_NOME NOT LIKE 'MONTEIRO ANTUNES - INSUMOS HOSPITALARES LTDA' "

cQuery +=	" UNION " 

cQuery +=	" SELECT " 
cQuery +=	" ISNULL(SUM(C7_QUANT - C7_QUJE),0) AS SOMA_PRE " 
cQuery +=	" FROM "+RetSQLName("SC7")+ " SC7"
cQuery +=	" INNER JOIN SA2010 SA2 ON (SA2.A2_COD=SC7.C7_FORNECE AND SA2.A2_LOJA=SC7.C7_LOJA) " 
cQuery +=	" WHERE " 
cQuery +=	" SC7.C7_PRODUTO = B1_COD " 
cQuery +=	" AND SC7.C7_RESIDUO = '' " 
cQuery +=	" AND (SC7.C7_QUANT - SC7.C7_QUJE) > 0 "
cQuery +=	" AND SC7.C7_FILIAL =SB9PAI.B9_FILIAL "
cQuery +=	" AND SC7.C7_LOCAL =SB9PAI.B9_LOCAL "
cQuery +=	" AND SA2.D_E_L_E_T_ <> '*' "
cQuery +=	" AND SC7.D_E_L_E_T_ <> '*' "
cQuery +=	" AND SA2.A2_NOME NOT LIKE 'MONTEIRO ANTUNES - INSUMOS HOSPITALARES LTDA') AS TAB) SALDO_PC_PRE_NOTA, " 


/*##### SALDO PEDIDO DE COMPRAS TRANSFERENCIA ############################################################################################################################################################################################*/
/* SALDO PEDIDO DE COMPRAS TRANSFERENCIA */
/*#####################################################*/


cQuery +=	" (SELECT "
cQuery +=	" SUM(SOMA_PRE) AS SALDO_PC_PRE_NOTA_TRANSF " 
cQuery +=	" FROM " 
cQuery +=	" (SELECT ISNULL(SUM(D1_QUANT),0) AS SOMA_PRE "
cQuery +=	" FROM "+RetSQLName("SD1")+ " SD1 " 
cQuery +=	" INNER JOIN "+RetSQLName("SA2")+ " SA2  ON (SA2.A2_COD=SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA) "	
cQuery +=	" WHERE     D1_COD         = B1_COD "
cQuery +=	" AND D1_FILIAL      = SB9PAI.B9_FILIAL "   
cQuery +=	" AND D1_LOCAL       = SB9PAI.B9_LOCAL  "
cQuery +=	" AND SA2.D_E_L_E_T_ <> '*' " 
cQuery +=	" AND SD1.D_E_L_E_T_ <> '*' " 
cQuery +=	" AND SD1.D1_NUMSEQ  = ''   "
cQuery +=	" AND SA2.A2_NOME LIKE 'MONTEIRO ANTUNES - INSUMOS HOSPITALARES LTDA' "

cQuery +=	" UNION " 

cQuery +=	" SELECT " 
cQuery +=	" ISNULL(SUM(C7_QUANT - C7_QUJE),0) AS SOMA_PRE " 
cQuery +=	" FROM "+RetSQLName("SC7")+ " SC7"
cQuery +=	" INNER JOIN SA2010 SA2 ON (SA2.A2_COD=SC7.C7_FORNECE AND SA2.A2_LOJA=SC7.C7_LOJA) " 
cQuery +=	" WHERE " 
cQuery +=	" SC7.C7_PRODUTO = B1_COD " 
cQuery +=	" AND SC7.C7_RESIDUO = '' " 
cQuery +=	" AND (SC7.C7_QUANT - SC7.C7_QUJE) > 0 "
cQuery +=	" AND SC7.C7_FILIAL =SB9PAI.B9_FILIAL "
cQuery +=	" AND SC7.C7_LOCAL =SB9PAI.B9_LOCAL "
cQuery +=	" AND SA2.D_E_L_E_T_ <> '*' "
cQuery +=	" AND SC7.D_E_L_E_T_ <> '*' "
cQuery +=	" AND SA2.A2_NOME LIKE 'MONTEIRO ANTUNES - INSUMOS HOSPITALARES LTDA') AS TAB) SALDO_PC_PRE_NOTA_TRNSF, " 



/*##### GIRO1 ############################################################################################################################################################################################*/
/* Giro Ultimo ms fechamento menos 1 */
/*#####################################################*/

cQuery +=	" (SELECT ISNULL(SUM(D2_QUANT),0) FROM " +RetSQLName("SF2")+ " SF2 "
cQuery +=	" INNER JOIN " +RetSQLName("SD2")+ " SD2 ON (SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D2_LOCAL=SB9PAI.B9_LOCAL "
cQuery +=	" AND SD2.D2_COD=B1_COD AND SD2.D_E_L_E_T_<>'*' AND SD2.D2_FILIAL=SB9PAI.B9_FILIAL) " 
cQuery +=	" INNER JOIN " +RetSQLName("SF4")+ " SF4 ON (SD2.D2_TES= SF4.F4_CODIGO AND  SD2.D2_FILIAL= SF4.F4_FILIAL ) "
cQuery +=	" WHERE "
cQuery +=	" D2_EMISSAO	    >CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -1,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	" 
cQuery +=	" AND D2_EMISSAO	    <=SB9PAI.B9_DATA "
cQuery +=	" AND D2_ORIGLAN	    <> 'LF'       "
cQuery +=	" AND D2_TIPO		<> 'D'            "
cQuery +=	" AND SF2.F2_FILIAL  = D2_FILIAL      "
cQuery +=	" AND SF2.F2_DOC     = SD2.D2_DOC     "
cQuery +=	" AND SF2.F2_SERIE   = SD2.D2_SERIE   "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery +=	" AND SF2.F2_LOJA    = SD2.D2_LOJA    "
If !Empty(MV_PAR11)
    cQuery +=	" AND SF4.F4_CODIGO IN " + FormatIn(AllTrim(MV_PAR11),";")
else
	cQuery +=	" AND SF4.F4_BIOPERA='01'    " 
endif
cQuery +=	" AND SD2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF4.D_E_L_E_T_ = '' "
cQuery +=	" ) AS B9_GIR01, "
/*############################################################################################################################################################################################################*/

/*##### GIRO2 ############################################################################################################################################################################################*/
/* Giro Ultimo ms fechamento menos 2 */
/*#####################################################*/

cQuery +=	" (SELECT ISNULL(SUM(D2_QUANT),0) FROM " +RetSQLName("SF2")+ " SF2 "
cQuery +=	" INNER JOIN " +RetSQLName("SD2")+ " SD2 ON (SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D2_LOCAL=SB9PAI.B9_LOCAL "
cQuery +=	" AND SD2.D2_COD=B1_COD AND SD2.D_E_L_E_T_<>'*' AND SD2.D2_FILIAL=SB9PAI.B9_FILIAL) " 
cQuery +=	" INNER JOIN " +RetSQLName("SF4")+ " SF4 ON (SD2.D2_TES= SF4.F4_CODIGO AND  SD2.D2_FILIAL= SF4.F4_FILIAL ) "
cQuery +=	" WHERE "
cQuery +=	" D2_EMISSAO	     >CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -2,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	" 
cQuery +=	" AND D2_EMISSAO	    <=CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -1,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	"
cQuery +=	" AND D2_ORIGLAN	    <> 'LF'       "
cQuery +=	" AND D2_TIPO		<> 'D'            "
cQuery +=	" AND SF2.F2_FILIAL  = D2_FILIAL      "
cQuery +=	" AND SF2.F2_DOC     = SD2.D2_DOC     "
cQuery +=	" AND SF2.F2_SERIE   = SD2.D2_SERIE   "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery +=	" AND SF2.F2_LOJA    = SD2.D2_LOJA    "
If !Empty(MV_PAR11)
    cQuery +=	" AND SF4.F4_CODIGO IN " + FormatIn(AllTrim(MV_PAR11),";")
else
	cQuery +=	" AND SF4.F4_BIOPERA='01'    " 
endif
cQuery +=	" AND SD2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF4.D_E_L_E_T_ = '' "
cQuery +=	" ) AS B9_GIR02, "
/*############################################################################################################################################################################################################*/


/*##### GIRO3 ############################################################################################################################################################################################*/
/* Giro Ultimo ms fechamento menos 3 */
/*#####################################################*/

cQuery +=	" (SELECT ISNULL(SUM(D2_QUANT),0) FROM " +RetSQLName("SF2")+ " SF2 "
cQuery +=	" INNER JOIN " +RetSQLName("SD2")+ " SD2 ON (SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D2_LOCAL=SB9PAI.B9_LOCAL "
cQuery +=	" AND SD2.D2_COD=B1_COD AND SD2.D_E_L_E_T_<>'*' AND SD2.D2_FILIAL=SB9PAI.B9_FILIAL) " 
cQuery +=	" INNER JOIN " +RetSQLName("SF4")+ " SF4 ON (SD2.D2_TES= SF4.F4_CODIGO AND  SD2.D2_FILIAL= SF4.F4_FILIAL ) "
cQuery +=	" WHERE "
cQuery +=	" D2_EMISSAO	     >CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -3,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	" 
cQuery +=	" AND D2_EMISSAO	    <=CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -2,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	"
cQuery +=	" AND D2_ORIGLAN	    <> 'LF'       "
cQuery +=	" AND D2_TIPO		<> 'D'            "
cQuery +=	" AND SF2.F2_FILIAL  = D2_FILIAL      "
cQuery +=	" AND SF2.F2_DOC     = SD2.D2_DOC     "
cQuery +=	" AND SF2.F2_SERIE   = SD2.D2_SERIE   "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery +=	" AND SF2.F2_LOJA    = SD2.D2_LOJA    "
If !Empty(MV_PAR11)
    cQuery +=	" AND SF4.F4_CODIGO IN " + FormatIn(AllTrim(MV_PAR11),";")
else
	cQuery +=	" AND SF4.F4_BIOPERA='01'    " 
endif
cQuery +=	" AND SD2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF4.D_E_L_E_T_ = '' "
cQuery +=	" ) AS B9_GIR03, "
/*############################################################################################################################################################################################################*/



/*##### GIRO4 ############################################################################################################################################################################################*/
/* Giro Ultimo ms fechamento menos 4 */
/*#####################################################*/

cQuery +=	" (SELECT ISNULL(SUM(D2_QUANT),0) FROM " +RetSQLName("SF2")+ " SF2 "
cQuery +=	" INNER JOIN " +RetSQLName("SD2")+ " SD2 ON (SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D2_LOCAL=SB9PAI.B9_LOCAL "
cQuery +=	" AND SD2.D2_COD=B1_COD AND SD2.D_E_L_E_T_<>'*' AND SD2.D2_FILIAL=SB9PAI.B9_FILIAL) " 
cQuery +=	" INNER JOIN " +RetSQLName("SF4")+ " SF4 ON (SD2.D2_TES= SF4.F4_CODIGO AND  SD2.D2_FILIAL= SF4.F4_FILIAL ) "
cQuery +=	" WHERE "
cQuery +=	" D2_EMISSAO	     >CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -4,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	" 
cQuery +=	" AND D2_EMISSAO	    <=CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -3,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	"
cQuery +=	" AND D2_ORIGLAN	    <> 'LF'       "
cQuery +=	" AND D2_TIPO		<> 'D'            "
cQuery +=	" AND SF2.F2_FILIAL  = D2_FILIAL      "
cQuery +=	" AND SF2.F2_DOC     = SD2.D2_DOC     "
cQuery +=	" AND SF2.F2_SERIE   = SD2.D2_SERIE   "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery +=	" AND SF2.F2_LOJA    = SD2.D2_LOJA    "
If !Empty(MV_PAR11)
    cQuery +=	" AND SF4.F4_CODIGO IN " + FormatIn(AllTrim(MV_PAR11),";")
else
	cQuery +=	" AND SF4.F4_BIOPERA='01'    " 
endif
cQuery +=	" AND SD2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF4.D_E_L_E_T_ = '' "
cQuery +=	" ) AS B9_GIR04, "
/*############################################################################################################################################################################################################*/

/*##### GIRO5 ############################################################################################################################################################################################*/
/* Giro Ultimo ms fechamento menos 5 */
/*#####################################################*/

cQuery +=	" (SELECT ISNULL(SUM(D2_QUANT),0) FROM " +RetSQLName("SF2")+ " SF2 "
cQuery +=	" INNER JOIN " +RetSQLName("SD2")+ " SD2 ON (SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D2_LOCAL=SB9PAI.B9_LOCAL "
cQuery +=	" AND SD2.D2_COD=B1_COD AND SD2.D_E_L_E_T_<>'*' AND SD2.D2_FILIAL=SB9PAI.B9_FILIAL) " 
cQuery +=	" INNER JOIN " +RetSQLName("SF4")+ " SF4 ON (SD2.D2_TES= SF4.F4_CODIGO AND  SD2.D2_FILIAL= SF4.F4_FILIAL) "
cQuery +=	" WHERE "
cQuery +=	" D2_EMISSAO	     >CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -5,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	" 
cQuery +=	" AND D2_EMISSAO	    <=CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -4,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	"
cQuery +=	" AND D2_ORIGLAN	    <> 'LF'       "
cQuery +=	" AND D2_TIPO		<> 'D'            "
cQuery +=	" AND SF2.F2_FILIAL  = D2_FILIAL      "
cQuery +=	" AND SF2.F2_DOC     = SD2.D2_DOC     "
cQuery +=	" AND SF2.F2_SERIE   = SD2.D2_SERIE   "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery +=	" AND SF2.F2_LOJA    = SD2.D2_LOJA    "
If !Empty(MV_PAR11)
   cQuery +=	"   AND SF4.F4_CODIGO IN " + FormatIn(AllTrim(MV_PAR11),";")
else
	cQuery +=	" AND SF4.F4_BIOPERA='01'    " 
endif
cQuery +=	" AND SD2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF4.D_E_L_E_T_ = '' "
cQuery +=	" ) AS B9_GIR05, "
/*############################################################################################################################################################################################################*/

/*##### GIRO6 ############################################################################################################################################################################################*/
/* Giro Ultimo ms fechamento menos 6 */
/*#####################################################*/

cQuery +=	" (SELECT ISNULL(SUM(D2_QUANT),0) FROM " +RetSQLName("SF2")+ " SF2 "
cQuery +=	" INNER JOIN " +RetSQLName("SD2")+ " SD2 ON (SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D2_LOCAL=SB9PAI.B9_LOCAL "
cQuery +=	" AND SD2.D2_COD=B1_COD AND SD2.D_E_L_E_T_<>'*' AND SD2.D2_FILIAL=SB9PAI.B9_FILIAL) " 
cQuery +=	" INNER JOIN " +RetSQLName("SF4")+ " SF4 ON (SD2.D2_TES= SF4.F4_CODIGO AND  SD2.D2_FILIAL= SF4.F4_FILIAL  ) "
cQuery +=	" WHERE "
cQuery +=	" D2_EMISSAO	     >CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -6,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	" 
cQuery +=	" AND D2_EMISSAO	    <=CONVERT( char, convert(DATE,CAST(DATEADD( MONTH, -5,SB9PAI.B9_DATA) AS DATE), 112 ), 112 )	"
cQuery +=	" AND D2_ORIGLAN	    <> 'LF'       "
cQuery +=	" AND D2_TIPO		<> 'D'            "
cQuery +=	" AND SF2.F2_FILIAL  = D2_FILIAL      "
cQuery +=	" AND SF2.F2_DOC     = SD2.D2_DOC     "
cQuery +=	" AND SF2.F2_SERIE   = SD2.D2_SERIE   "
cQuery +=	" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery +=	" AND SF2.F2_LOJA    = SD2.D2_LOJA    "
If !Empty(MV_PAR11)
   cQuery +=	"   AND SF4.F4_CODIGO IN " + FormatIn(AllTrim(MV_PAR11),";")
else
	cQuery +=	" AND SF4.F4_BIOPERA='01'    " 
endif
cQuery +=	" AND SD2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF2.D_E_L_E_T_ = '' "
cQuery +=	" AND SF4.D_E_L_E_T_ = '' "
cQuery +=	" ) AS B9_GIR06 "
/*############################################################################################################################################################################################################*/


cQuery +=	" FROM " +RetSQLName("SB9")+ " SB9PAI "  
cQuery +=	" INNER JOIN  " +RetSQLName("SB1")+ " SB1 ON (SB1.B1_COD=SB9PAI.B9_COD)  "
cQuery +=	" INNER JOIN  " +RetSQLName("SBM")+ " SBM ON (SB1.B1_GRUPO=SBM.BM_GRUPO) "  
cQuery +=	" WHERE SB1.D_E_L_E_T_   <>'*' "  
cQuery +=	"   AND SB9PAI.D_E_L_E_T_<>'*' "
cQuery +=	"   AND SBM.D_E_L_E_T_   <>'*' "  

If !Empty(mv_par06)
   cQuery +=	"   AND B9_DATA  = '"+Dtos(mv_par06)+"'"
Endif   

If !Empty(MV_PAR07)
   cQuery +=	"   AND B1_COD   = '"+AllTrim(MV_PAR07)+"'"
Endif   

If !Empty(MV_PAR09)

  cQuery +=	"   AND B9_LOCAL  IN " + FormatIn(AllTrim(MV_PAR09),";")

Endif   

If !Empty(MV_PAR04)

   cQuery +=	"   AND B1_MARCA  IN " + FormatIn(AllTrim(MV_PAR04),";")

Endif 

If !Empty(MV_PAR05)
    cQuery +=	"   AND B1_GRUPO  IN " + FormatIn(AllTrim(MV_PAR05),";")
Endif 
   
If !Empty(MV_PAR08)
   cQuery +=	"   AND B9_FILIAL IN " + FormatIn(AllTrim(MV_PAR08),";")
Endif    

If !Empty(MV_PAR10)
    cQuery +=	"   AND B1_TIPO  IN " + FormatIn(AllTrim(MV_PAR10),";")
else
	cQuery +=	"   AND SB1.B1_TIPO IN('M1','M2','M3','M4','M5') "
Endif 

cQuery +=	" GROUP BY    "
cQuery +=	" B9_FILIAL,  " 
cQuery +=	" B9_LOCAL,   " 		
cQuery +=	" B9_DATA,    " 			
cQuery +=	" B1_COD,     "
cQuery +=	" B1_TIPO   , "
cQuery +=	" B1_GRUPO,   "
cQuery +=	" BM_DESC,    "  
cQuery +=	" B1_DESC,    "     
cQuery +=	" B1_MARCA,	  "	
cQuery +=	" B1_DESCMAR, "	
cQuery +=	" B1_ZCODEXT, " 
cQuery +=	" B1_ZMULTIP  "

 	

cQuery +=	" ORDER BY B9_FILIAL, B9_DATA "



MEMOWRITE("AnaliseCompras.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TSB6",.F.,.T.)


If !ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel não instalado!")
	Return
EndIf


aCabec:={}

AAdd(aCabec,'FILIAL')
AAdd(aCabec,'ARMAZEM')
AAdd(aCabec,'DT FECHAMENTO')
AAdd(aCabec,'CODIGO PRODUTO')
AAdd(aCabec,'CODIGO PRODUTO EXTERNO')
AAdd(aCabec,'DESCRICAO')
AAdd(aCabec,'TIPO')
AAdd(aCabec,'GRUPO')
AAdd(aCabec,'DESCRICAO GRUPO')
AAdd(aCabec,'CODIGO MARCA')
AAdd(aCabec,'DESCRICAO MARCA')
AAdd(aCabec,'SALDO INICIAL')
AAdd(aCabec,'MULTIPLICADOR')
AAdd(aCabec,'SALDO PEDIDO ')
AAdd(aCabec,'SALDO ATUAL ')
AAdd(aCabec,'SALDO PC/PRE NOTA')
AAdd(aCabec,'SALDO EM TRANSFERENCIA')
//AAdd(aCabec,'GIRO MES/ANO '+ AnoMes(sToD(TSB6->B9_DATA)))
//AAdd(aCabec,'GIRO MES/ANO '+ AnoMes(MonthSub(sToD(TSB6->B9_DATA), 1)))
//AAdd(aCabec,'GIRO MES/ANO '+ AnoMes(MonthSub(sToD(TSB6->B9_DATA), 2)))
//AAdd(aCabec,'GIRO MES/ANO '+ AnoMes(MonthSub(sToD(TSB6->B9_DATA), 3)))
//AAdd(aCabec,'GIRO MES/ANO '+ AnoMes(MonthSub(sToD(TSB6->B9_DATA), 4)))
//AAdd(aCabec,'GIRO MES/ANO '+ AnoMes(MonthSub(sToD(TSB6->B9_DATA), 5)))
AAdd(aCabec,'GIRO MENSAL 01') 
AAdd(aCabec,'GIRO MENSAL 02')
AAdd(aCabec,'GIRO MENSAL 03')
AAdd(aCabec,'GIRO MENSAL 04')
AAdd(aCabec,'GIRO MENSAL 05')
AAdd(aCabec,'GIRO MENSAL 06')

AAdd(aCabec,'CURVA')
AAdd(aCabec,'ESTOQUE SEGURANCA')
AAdd(aCabec,'SUGESTAO DE COMPRA')



ProcRegua(TSB6->(RECCOUNT()))
dbGoTop()
While !TSB6->(Eof())
	
	
	IncProc("Gerando Analise do periodo :  "+TSB6->B9_DATA)
	
	aLinha:={}
	 
	
	aadd(aLinha,chr(160)+TSB6->B9_FILIAL)
	aadd(aLinha,chr(160)+TSB6->B9_LOCAL)
	aadd(aLinha,sToD(TSB6->B9_DATA))
	aadd(aLinha,chr(160)+TSB6->B1_COD)
	aadd(aLinha,chr(160)+TSB6->B1_ZCODEXT)
	aadd(aLinha,chr(160)+TSB6->B1_DESC)
	aadd(aLinha,chr(160)+TSB6->B1_TIPO)
	aadd(aLinha,chr(160)+TSB6->B1_GRUPO)
	aadd(aLinha,chr(160)+TSB6->BM_DESC)
	aadd(aLinha,chr(160)+TSB6->B1_MARCA)
	aadd(aLinha,chr(160)+TSB6->B1_DESCMAR)
	aadd(aLinha,TSB6->B9_QINI)
	aadd(aLinha,TSB6->B1_ZMULTIP)
	aadd(aLinha,TSB6->SALDO_PEDIDO)
	aadd(aLinha,TSB6->SLD_ATUAL)
	aadd(aLinha,TSB6->SALDO_PC_PRE_NOTA)
	aadd(aLinha,TSB6->SALDO_PC_PRE_NOTA_TRANSF)
	aadd(aLinha,TSB6->B9_GIR01)
	aadd(aLinha,TSB6->B9_GIR02)
	aadd(aLinha,TSB6->B9_GIR03)
	aadd(aLinha,TSB6->B9_GIR04)
	aadd(aLinha,TSB6->B9_GIR05)
	aadd(aLinha,TSB6->B9_GIR06)
	aadd(aLinha,chr(160)+'?')
	aadd(aLinha,chr(160)+'?')
	aadd(aLinha,chr(160)+'0')
	aadd(aDados,aLinha)
	
	
	TSB6->(dbSkip())
	
Enddo


If !ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel não instalado!")
	Return
EndIf






TSB6->(dbCloseArea())

MsgRun("Aguarde.....", "Exportando os Registros para o Excel",{||DlgToExcel({{"ARRAY", "Analise de Compra", aCabec, aDados}  })})


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


//PutSX1( cGrupo, cOrdem, cTexto		, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid	, cF3		, cPicture	, cDef01		, cDef02			, cDef03			, cDef04	, cDef05	, cHelp	, cGrpSXG	, cCnt01		)
u_PutSX1(cPerg, "01","Meses Curva A: "  ,"MV_PAR01", "MV_CH1", TamSX3("C7_QUANT")[3]      , TamSX3("C7_QUANT")[1]	   , TamSX3("C7_QUANT")[2]    , "G", cValid,       cF3,   "@E 999.99",        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Estoque seguranca para Curva A ")
u_PutSX1(cPerg, "02","Meses Curva B: "  ,"MV_PAR02", "MV_CH2", TamSX3("C7_QUANT")[3]      , TamSX3("C7_QUANT")[1]	   , TamSX3("C7_QUANT")[2]    , "G", cValid,       cF3,   "@E 999.99",        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Estoque seguranca para Curva B ")
u_PutSX1(cPerg, "03","Meses Curva C: "  ,"MV_PAR03", "MV_CH3", TamSX3("C7_QUANT")[3]      , TamSX3("C7_QUANT")[1]	   , TamSX3("C7_QUANT")[2]    , "G", cValid,       cF3,   "@E 999.99",        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Estoque seguranca para Curva C ")		
u_PutSX1(cPerg, "04","Marca:         "  ,"MV_PAR04", "MV_CH4", TamSX3("B1_MARCA")[3]      , 20	   					   , TamSX3("B1_MARCA")[2]    , "G", cValid,       cF3 ,  cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Marca do produto   ")		
u_PutSX1(cPerg, "05","Grupo:         "  ,"MV_PAR05", "MV_CH5", TamSX3("B1_GRUPO")[3]      , 20	   					   , TamSX3("B1_GRUPO")[2]    , "G", cValid,       cF3,   cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Grupo do produto   ")		
u_PutSX1(cPerg, "06","Dt. Fechamento:"  ,"MV_PAR06", "MV_CH6", TamSX3("B9_DATA")[3]       , TamSX3("B9_DATA")[1]	   , TamSX3("B9_DATA")[2]     , "G", cValid,       cF3,   cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Data do Fechamento ")		
u_PutSX1(cPerg, "07","Produto:       "  ,"MV_PAR07", "MV_CH7", TamSX3("B1_COD")[3]        , TamSX3("B1_COD")[1]	   , TamSX3("B1_COD")[2]      , "G", cValid,       "SB1", cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Produto ")		
u_PutSX1(cPerg, "08","FIlial:        "  ,"MV_PAR08", "MV_CH8", TamSX3("B9_FILIAL")[3]     , 20	   					   , TamSX3("B9_FILIAL")[2]   , "G", cValid,       cF3,   cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Filial ")		
u_PutSX1(cPerg, "09","Armazem:       "  ,"MV_PAR09", "MV_CH9", TamSX3("B9_LOCAL")[3]      , 20	   					   , TamSX3("B9_LOCAL")[2]    , "G", cValid,       cF3,   cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Armazem ")		
u_PutSX1(cPerg, "10","TIPO:          "  ,"MV_PAR10", "MV_CHA", TamSX3("B9_LOCAL")[3]      , 20	   					   , TamSX3("B9_LOCAL")[2]    , "G", cValid,       cF3,   cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "TIPO ")	
u_PutSX1(cPerg, "11","TES:           "  ,"MV_PAR11", "MV_CHB", TamSX3("D2_TES")[3]        , 20	   					   , TamSX3("D2_TES")[2]      , "G", cValid,       cF3,   cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "TES ")
u_PutSX1(cPerg, "12","NATUREZA:      "  ,"MV_PAR12", "MV_CHC", TamSX3("C5_NATUREZ")[3]    , 30	   					   , TamSX3("D2_TES")[2]      , "G", cValid,       cF3,   cPicture,           cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "NATUREZ ")
u_PutSX1(cPerg, "13","Consolidado    "  ,"MV_PAR13", "MV_CHD", "N"                        , 01                        , 0                          , "C", cValid,     cF3,   cPicture,           "NAO" ,  "SIM" ,        cDef03,        cDef04,    cDef05, "Consolidado")
Return
	   
/*---------------------------------------------------*
| Função: fPutHelp                                  |
| Desc:   Função que insere o Help do Parametro     |
*---------------------------------------------------*/

Static Function fPutHelp(cKey, cHelp, lUpdate)
Local cFilePor  := "SIGAHLP.HLP"
Local cFileEng  := "SIGAHLE.HLE"
Local cFileSpa  := "SIGAHLS.HLS"
Local nRet      := 0
Default cKey    := ""
Default cHelp   := ""
Default lUpdate := .F.

//Se a Chave ou o Help estiverem em branco
If Empty(cKey) .Or. Empty(cHelp)
	Return
EndIf

//**************************** Português
nRet := SPF_SEEK(cFilePor, cKey, 1)

//Se não encontrar, será inclusão
If nRet < 0
	SPF_INSERT(cFilePor, cKey, , , cHelp)
	
	//Senão, será atualização
Else
	If lUpdate
		SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
	EndIf
EndIf



//**************************** Inglês
nRet := SPF_SEEK(cFileEng, cKey, 1)

//Se não encontrar, será inclusão
If nRet < 0
	SPF_INSERT(cFileEng, cKey, , , cHelp)
	
	//Senão, será atualização
Else
	If lUpdate
		SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
	EndIf
EndIf



//**************************** Espanhol
nRet := SPF_SEEK(cFileSpa, cKey, 1)

//Se não encontrar, será inclusão
If nRet < 0
	SPF_INSERT(cFileSpa, cKey, , , cHelp)
	
	//Senão, será atualização
Else
	If lUpdate
		SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
	EndIf
EndIf
Return
	










