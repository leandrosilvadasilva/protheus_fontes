#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#include "fileio.ch"


USER Function MAHR485()

Processa( {|| gerExcel()},"Gerando Relatorio de Poder de/em Terceiro" )

Return

Static Function gerExcel()

Local aCabec   := {}
Local aDados   := {}
Local cValid   := ""
Local cF3      := ""
Local cPicture := ""   
Local cDef01   := ""    
Local cDef02   := ""  
Local cDef03   := ""  
Local cDef04   := ""  
Local cDef05   := ""
PRIVATE cPerg  := "MHR485"



If cPerg == "MHR485"
		
   u_PutSX1(cPerg, "01", "Ordem:" 	                           ,"MV_PAR01", "MV_CH1", "N" , 1  ,0    , "G", cValid, cF3   , cPicture,  "Fornecedor", "Cliente", "Ambos",  cDef04,  cDef05, "Opção de ordem para a impressao do relatório:")
   u_PutSX1(cPerg, "02", "De Nota:"		                       ,"MV_PAR02", "MV_CH2", "C" , 9  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "De Nota:")
   u_PutSX1(cPerg, "03", "Ate Nota:"	                       ,"MV_PAR03", "MV_CH3", "C" , 9  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Ate Nota:")
   u_PutSX1(cPerg, "04", "De Serie:"	                       ,"MV_PAR04", "MV_CH4", "C" , 3  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "De Serie:")
   u_PutSX1(cPerg, "05", "Ate Serie:"	                       ,"MV_PAR05", "MV_CH5", "C" , 3  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Ate Serie:")
   u_PutSX1(cPerg, "06", "Data de:"	                           ,"MV_PAR06", "MV_CH6", "D" , 8  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Dt Emissao inicial a ser considerada:")
   u_PutSX1(cPerg, "07", "Data ate:"	                       ,"MV_PAR07", "MV_CH7", "D" , 8  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Dt Emissao final a ser considerada:")
   u_PutSX1(cPerg, "08", "De Produto:"                         ,"MV_PAR08", "MV_CH8", "C" , 15 ,0    , "G", cValid, "SB1" , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Cod. Produto inicial a ser considerado:")
   u_PutSX1(cPerg, "09", "Ate Produto:"                        ,"MV_PAR09", "MV_CH9", "C" , 15 ,0    , "G", cValid, "SB1" , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Cod. Produto Final   a ser considerado:")
   u_PutSX1(cPerg, "10", "De Fornec/Client:"                   ,"MV_PAR10", "MV_CHA", "C" , 9  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Cod. Cliente/Fornecedor inicial a ser considerado:")
   u_PutSX1(cPerg, "11", "Ate Fornec/Client:"                  ,"MV_PAR11", "MV_CHB", "C" , 9  ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Cod. Cliente/Fornecedor final a ser considerado:")
   u_PutSX1(cPerg, "12", "Tipo:" 	              			   ,"MV_PAR12", "MV_CHC", "N" , 1  ,0    , "G", cValid, cF3   , cPicture,  "De Terceiros", "Em Terceiros", "Ambos",  cDef04,  cDef05, "Opcao de impressao:")
   u_PutSX1(cPerg, "13", "De Vendedor:"                        ,"MV_PAR13", "MV_CHD", "C" , 6 ,0     , "G", cValid, "SA3" , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Cod. Vendedor inicial a ser considerado:")
   u_PutSX1(cPerg, "14", "Ate Vendedor:"                       ,"MV_PAR14", "MV_CHE", "C" , 6 ,0     , "G", cValid, "SA3" , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Cod. Vendedor final   a ser considerado:")
   u_PutSX1(cPerg, "15", "De TES(Ex: '501','502'...):"         ,"MV_PAR15", "MV_CHF", "C" , 20 ,0    , "G", cValid, cF3   , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Grupo de TES. Ex: '501','502'. Se o campo nao for preenchido considera tudo.")
   u_PutSX1(cPerg, "16", "Considera itens sem saldo?" 	       ,"MV_PAR16", "MV_CHG", "N" , 1  ,0    , "G", cValid, cF3   , cPicture,         "SIM",     "NAO",  cDef03,  cDef04,  cDef05, "Considera itens sem saldo?")
   u_PutSX1(cPerg, "17", "Grupo:"                              ,"MV_PAR17", "MV_CHH", "C" , 4 ,0     , "G", cValid, "SBM" , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Grupo de Produtos:")
   u_PutSX1(cPerg, "18", "Marca:"                              ,"MV_PAR18", "MV_CHI", "C" , 2 ,0     , "G", cValid, "ZX"  , cPicture,        cDef01,    cDef02,  cDef03,  cDef04,  cDef05, "Marca de Produtos:")
		
		

EndIf

Pergunte(cPerg,.T.)

cQuery:=" "



cQuery :=	" SELECT B6_FILIAL,B6_DOC,B6_SERIE,B6_CLIFOR,B6_TPCF,B6_PRODUTO,B6_QUANT, "
cQuery +=	" B6_PRUNIT, B6_EMISSAO,B6_TIPO,B6_TES,B6_PODER3, F4_FINALID, B6_SALDO, B1_DESC, B6_IDENT, B6_LOJA, B6_CUSTO1,  "
cQuery +=   " B1_GRUPO,B1_MARCA,B1_DESCMAR "

If MV_PAR01 == 2
	cQuery +=	" , A3_COD, A3_NOME, A1_NOME , A1_LOJA, A1_EST "
Else
    cQuery +=	" , A2_NOME, A2_LOJA, A2_EST "
Endif


cQuery +=	" FROM  "+RetSQLName("SB6")+ " SB6 "

If MV_PAR01 == 2
   
	cQuery +=   " INNER JOIN  "+RetSQLName("SD2")+ " SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR  " 
	cQuery +=   "  AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_ITEM='01' AND SD2.D_E_L_E_T_<>'*')  "
	cQuery +=   " INNER JOIN  "+RetSQLName("SC5")+ " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*')  "
	cQuery +=   " INNER JOIN  "+RetSQLName("SA1")+ "  SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*')  " 
	cQuery +=   " INNER JOIN  "+RetSQLName("SA3")+ " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')  "
else
	cQuery += 	" INNER JOIN "+RetSQLName("SF1")+ "  SF1 ON (SF1.F1_DOC=SB6.B6_DOC AND SF1.F1_SERIE=SB6.B6_SERIE  "
	cQuery += 	"                       AND SF1.F1_FORNECE=SB6.B6_CLIFOR AND SF1.D_E_L_E_T_<>'*')" 
	cQuery += 	" INNER JOIN  "+RetSQLName("SA2")+ " SA2 ON (SF1.F1_FORNECE=SA2.A2_COD AND SF1.F1_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_<>'*') "
Endif



cQuery += 	"  JOIN "+RetSQLName("SB1")+ " SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*')  "
cQuery += 	"  JOIN "+RetSQLName("SF4")+ " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*')  "
 


cQuery += 	" WHERE "
//cQuery +=	" SB6.B6_FILIAL  	 	 = '"+xFilial("SB6")+"'"
cQuery +=	"  SB6.B6_DOC     	 >= '"+AllTrim(MV_PAR02)+"'"
cQuery +=	" AND SB6.B6_DOC     	 <= '"+AllTrim(MV_PAR03)+"'"
cQuery +=	" AND SB6.B6_SERIE   	 >= '"+AllTrim(MV_PAR04)+"'"
cQuery +=	" AND SB6.B6_SERIE   	 <= '"+AllTrim(MV_PAR05)+"'"
cQuery +=	" AND SB6.B6_EMISSAO 	 >= '"+Dtos(mv_par06)+"'"
cQuery +=	" AND SB6.B6_EMISSAO 	 <= '"+Dtos(mv_par07)+"'"
cQuery +=	" AND SB6.B6_PRODUTO 	 >= '"+AllTrim(MV_PAR08)+"'"
cQuery +=	" AND SB6.B6_PRODUTO 	 <= '"+AllTrim(MV_PAR09)+"'"
If Alltrim(MV_PAR17)<>""
cQuery +=	" AND SB1.B1_GRUPO 	 	 = '"+AllTrim(MV_PAR17)+"'"
Endif

If Alltrim(MV_PAR18)<>""
cQuery +=	" AND SB1.B1_MARCA 	 	 = '"+AllTrim(MV_PAR18)+"'"
Endif


If MV_PAR16 == 2
    cQuery +=	" AND SB6.B6_SALDO>0  "
Endif

IF !EMPTY(AllTrim(MV_PAR15))
	cQuery    += " AND SB6.B6_TES     IN (" + MV_PAR15 + ") "
Endif

 
If MV_PAR01 == 2
	cQuery +=	" AND SA3.A3_COD     >= '"+AllTrim(MV_PAR13)+"'"
	cQuery +=	" AND SA3.A3_COD  	 <= '"+AllTrim(MV_PAR14)+"'"
Endif


If MV_PAR01 == 2	
	cQuery += " AND B6_TPCF = 'C'"
Else
	cQuery += " AND B6_TPCF = 'F'"
Endif


If MV_PAR01 == 3
	cQuery += " AND B6_TPCF IN ('C','F')"
EndIf



If MV_PAR12 == 1
	cQuery +=	" AND SB6.B6_TIPO= 'D' "
Endif

If MV_PAR12 == 2
	cQuery +=	" AND SB6.B6_TIPO= 'E' "
Endif


cQuery +=   " AND SB6.D_E_L_E_T_ <> '*' "
cQuery +=   " Order By SB6.B6_DOC, SB6.B6_SERIE, SB6.B6_EMISSAO "




MEMOWRITE("EMTERCEIROSXLS.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TSB6",.F.,.T.)




If !ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel não instalado!")
	Return
EndIf


aCabec:={}
//Colunas fixas
AAdd(aCabec,'FILIAL')
AAdd(aCabec,'NOTA')
AAdd(aCabec,'SERIE')
AAdd(aCabec,'CLIENTE/FORNECEDOR')
AAdd(aCabec,'LOJA')
AAdd(aCabec,'NOME')
AAdd(aCabec,'UF')
If MV_PAR01 == 2
	AAdd(aCabec,'CODIGO VENDEDOR')
	AAdd(aCabec,'NOME VENDEDOR')
Endif
AAdd(aCabec,'PRODUTO')
AAdd(aCabec,'DESCRICAO')
AAdd(aCabec,'QUANTIDADE ')
AAdd(aCabec,'CUSTO UNITARIO ')
AAdd(aCabec,'CUSTO TOTAL')
AAdd(aCabec,'SALDO')
AAdd(aCabec,'DATA EMISSAO')
AAdd(aCabec,'TIPO DE/EM')
AAdd(aCabec,'TES')
AAdd(aCabec,'FINALIDADE TES')
AAdd(aCabec,'TIPO NF')


AAdd(aCabec,'GRUPO')
AAdd(aCabec,'COD. MARCA')
AAdd(aCabec,'DESC. MARCA')



ProcRegua(TSB6->(RECCOUNT()))
dbGoTop()
While !TSB6->(Eof())
	
	
	IncProc("Gerando NF :  "+TSB6->B6_DOC)
	
	aLinha:={}
	 
	aadd(aLinha,chr(160)+TSB6->B6_FILIAL)
	aadd(aLinha,chr(160)+TSB6->B6_DOC)
	aadd(aLinha,chr(160)+TSB6->B6_SERIE)
	aadd(aLinha,chr(160)+STRZERO(VAL(TSB6->B6_CLIFOR),6))
	If MV_PAR01 == 2
	    aadd(aLinha,chr(160)+TSB6->A1_LOJA)
	    aadd(aLinha,TSB6->A1_NOME)
	    aadd(aLinha,TSB6->A1_EST)
		aadd(aLinha,chr(160)+STRZERO(VAL(TSB6->A3_COD),6))
		aadd(aLinha,TSB6->A3_NOME)
	Else
       aadd(aLinha,chr(160)+TSB6->A2_LOJA)
       aadd(aLinha,TSB6->A2_NOME)
       aadd(aLinha,TSB6->A3_NOME) 
	Endif
	aadd(aLinha,chr(160)+TSB6->B6_PRODUTO)
	aadd(aLinha,TSB6->B1_DESC)
	aadd(aLinha,TSB6->B6_QUANT) 
	aadd(aLinha,Transform(TSB6->B6_CUSTO1,'@E 99,999,999,999.99'))
	aadd(aLinha,Transform(TSB6->B6_CUSTO1*TSB6->B6_QUANT,'@E 99,999,999,999.99'))
	aadd(aLinha,TSB6->B6_SALDO)
	aadd(aLinha,sToD(TSB6->B6_EMISSAO))
	aadd(aLinha,TSB6->B6_TIPO)
	aadd(aLinha,chr(160)+TSB6->B6_TES)
	aadd(aLinha,TSB6->F4_FINALID)
	aadd(aLinha,TSB6->B6_PODER3)
	aadd(aLinha,chr(160)+TSB6->B1_GRUPO)
	aadd(aLinha,chr(160)+TSB6->B1_MARCA)
	aadd(aLinha,TSB6->B1_DESCMAR)
	aadd(aDados,aLinha)
	
	
	TSB6->(dbSkip())
	
Enddo


If !ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel não instalado!")
	Return
EndIf






TSB6->(dbCloseArea())

MsgRun("Aguarde.....", "Exportando os Registros para o Excel",{||DlgToExcel({{"ARRAY", "Poder de/em Terceiros", aCabec, aDados}  })})

return
