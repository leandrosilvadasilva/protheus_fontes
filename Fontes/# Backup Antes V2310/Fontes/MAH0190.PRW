#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#include "rwmake.ch"


User Function MAH0190()
Private cPerg:="MAH0190"
Private cEOL  :="CHR(13)+CHR(10)"


CriaSX1( cPerg )

If Pergunte(cPerg,.T.)
	
	Processa({|| Imprime() },"Recibo","Imprimindo")
Endif

Return

Static Function CriaSx1( cPerg )
Local cValid   := ""
Local cF3      := ""
Local cPicture := ""
Local cDef01   := ""
Local cDef02   := ""
Local cDef03   := ""
Local cDef04   := ""
Local cDef05   := ""

u_PutSX1(cPerg, "01", "NF :"	    ,"MV_PAR01", "MV_CH0", TamSX3("F2_DOC")[3]      , TamSX3("F2_DOC")[1]     , TamSX3("F2_DOC")[2]     , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Numero da Nota")
u_PutSX1(cPerg, "02", "Cliente :"	,"MV_PAR02", "MV_CH2", TamSX3("F2_CLIENTE")[3]  , TamSX3("F2_CLIENTE")[1] , TamSX3("F2_CLIENTE")[2] , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Cliente")
u_PutSX1(cPerg, "03", "Loja:"  	,"MV_PAR03", "MV_CH3", TamSX3("F2_LOJA")[3]     , TamSX3("F2_LOJA")[1]    , TamSX3("F2_LOJA")[2]    , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Loja")


Return


//********************************************************************************************
//                                          MONTA A PAGINA DE IMPRESSAO
//********************************************************************************************
Static Function Imprime()
Local   cQuery:=""
Private cStartPath:= GetSrvProfString("Startpath","")
Private nLin:=50
Private nLen:=0
Private nPulaLin:=50
Private nMaxCol :=2300
Private nMinCol :=0150
Private cBitmap := cStartPath+"lgrl01.BMP" // Empresa+Filial

If !File( cBitmap )
	cBitmap := cStartPath+"LGRLl0.BMP" // Empresa
EndIf

//Fontes a serem utilizadas no relat€rio
Private oFont09  	:= TFont():New( "Arial",,09,,.f.,,,,,.f.)
Private oFont10  	:= TFont():New( "Arial",,10,,.f.,,,,,.f.)
Private oFont10N 	:= TFont():New( "Arial",,10,,.T.,,,,,.f.)
Private oFont10I 	:= TFont():New( "Arial",,10,,.f.,,,,,.f.,.T.)
Private oFont11  	:= TFont():New( "Arial",,11,,.f.,,,,,.f.)
Private oFont11N 	:= TFont():New( "Arial",,11,,.T.,,,,,.f.)
Private oFont12N 	:= TFont():New( "Arial",,12,,.T.,,,,,.f.)
Private oFont13N 	:= TFont():New( "Arial",,13,,.T.,,,,,.f.)
Private oFont15N 	:= TFont():New( "Arial",,-15,,.T.,,,,,.f.)
Private oFont17 	:= TFont():New( "Arial",,17,,.F.,,,,,.F.)
Private oFont17N 	:= TFont():New( "Arial",,17,,.T.,,,,,.F.)
Private cData  :=''
Private nCText := CLR_BLACK   // COR DO TEXTO
Private nCBack := CLR_GRAY  // COR DO FUNDO
Private oPrn:= TMSPrinter():New()



cQuery:=" SELECT SF2.F2_DOC, "
cQuery+=" SF2.F2_SERIE, 	 "
cQuery+=" SUBSTRING(F2_EMISSAO,7,2)+'/'+SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4) DTA, "
cQuery+=" SF2.F2_CLIENTE,    "
cQuery+=" SA1.A1_NOME,       "
cQuery+=" SF2.F2_LOJA,       "
cQuery+=" SD2.D2_COD,        "
cQuery+=" SD2.D2_QUANT,      "
cQuery+=" SD2.D2_TOTAL,      "
cQuery+=" SB1.B1_DESC,	     "
cQuery+=" SA1.A1_END,	     "
cQuery+=" SA1.A1_TEL,	     "
cQuery+=" SA1.A1_CGC,	     "
cQuery+=" SA1.A1_EST,	     "
cQuery+=" SA1.A1_CEP 	     "
cQuery+=" FROM  SF2010 SF2   "
cQuery+=" INNER JOIN SD2010 SD2 ON (SF2.F2_DOC=SD2.D2_DOC "
cQuery+=" AND SF2.F2_SERIE=SD2.D2_SERIE "
cQuery+=" AND SF2.F2_CLIENTE=SD2.D2_CLIENTE "
cQuery+=" AND SF2.F2_LOJA=SD2.D2_LOJA) "
cQuery+=" INNER JOIN SA1010 SA1 ON (SA1.A1_COD=SF2.F2_CLIENTE "
cQuery+=" AND SA1.A1_LOJA=SF2.F2_LOJA) "
cQuery+=" INNER JOIN SB1010 SB1 ON (SB1.B1_COD=SD2.D2_COD) "
cQuery+=" WHERE "
cQuery+=" SF2.D_E_L_E_T_<>'*' "
cQuery+=" AND SD2.D_E_L_E_T_<>'*' "
cQuery+=" AND SF2.F2_SERIE='LOC'  "
cQuery+=" AND SF2.F2_DOC='"+MV_PAR01+"'"
cQuery+=" AND SF2.F2_CLIENTE='"+MV_PAR02+"'"
cQuery+=" AND SF2.F2_LOJA='"+MV_PAR03+"'"
cQuery:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TNOTA",.F.,.T.)



oPrn:SetPortrait()()  // SetPortrait() - Formato retrato   SetLandscape() - Formato Paisagem

oPrn:StartPage()	//Inicia uma nova pagina

nLin:=50
nInfMA:=440
nWidthMA:=50
oPrn:SayBitmap(nLin+30,nMinCol,cBitmap,0400,0400)
//Dados da Empresa************************//
oPrn:say(nLin+30,nMinCol+nInfMA,"Monteiro Antunes Insumos Hospitalares Ltda", oFont11N) //Nome
nLin+=nPulaLin
oPrn:say(nLin+30,nMinCol+nInfMA,"CNPJ 04.078.043/0001-40", oFont11N) //Cnpj
nLin+=nPulaLin
oPrn:say(nLin+30,nMinCol+nInfMA,"Rua Maestro Mendanha, 102 - Cep: 90620-160", oFont11N) //Endereco + CEP
nLin+=nPulaLin
oPrn:say(nLin+30,nMinCol+nInfMA,"Bairro Santana - Porto Alegre - RS", oFont11N)
nLin+=nPulaLin
oPrn:say(nLin+30,nMinCol+nInfMA,"Tel: 51 3029-8385", oFont11N)
nLin+=nPulaLin
oPrn:say(nLin+30,nMinCol+nInfMA,"www.mahospitalar.com.br", oFont11N)
//****************************************//
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
oPrn:line(nLin,nMinCol,nLin,nMaxCol)

oBrush1 := TBrush():New( , CLR_GRAY )
oPrn:FillRect( {nLin,nMinCol,nLin+50,nMaxCol}, oBrush1 )
oBrush1:End()

oPrn:say(nLin,nMinCol+1000,"RECIBO", oFont13N)
nLin+=nPulaLin
oPrn:say(nLin,nMinCol+650,"PRESTA«√O DE SERVI«O DE LOCA«√O", oFont13N)
nLin+=nPulaLin
nLin+=nPulaLin
cData:=dtoc(date())
oPrn:say(nLin,nMinCol+040,"Data: ", oFont11N)
oPrn:say(nLin,nMinCol+0150,TNOTA->DTA, oFont11N)
oPrn:say(nLin,nMinCol+1810,"Numero: "+TNOTA->F2_DOC , oFont11N)
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
oPrn:say(nLin,nMinCol,"Dados do Cliente ", oFont11N)
nLin+=nPulaLin
oPrn:box(nLin,nMinCol,nLin+300,nMaxCol) // Box Informa¡Ño Cliente
nLin+=nPulaLin
oPrn:say(nLin,nMinCol+10,"Raz„o Social: ", oFont11N)
oPrn:say(nLin,nMinCol+300,TNOTA->A1_NOME, oFont10)
nLin+=nPulaLin
oPrn:say(nLin,nMinCol+10,"EndereÁo: ", oFont11N)
oPrn:say(nLin,nMinCol+300,TNOTA->A1_END, oFont10)
oPrn:say(nLin,nMinCol+860,"CNPJ/CPF: ", oFont11N)
oPrn:say(nLin,nMinCol+1100,TNOTA->A1_CGC, oFont10)
nLin+=nPulaLin
oPrn:say(nLin,nMinCol+10,"Municipio/UF: ", oFont11N)
oPrn:say(nLin,nMinCol+300,TNOTA->A1_EST, oFont10)
oPrn:say(nLin,nMinCol+500," ", oFont10)
nLin+=nPulaLin
oPrn:say(nLin,nMinCol+10,"CEP: ", oFont11N)
oPrn:say(nLin,nMinCol+300,TNOTA->A1_CEP, oFont10)
oPrn:say(nLin,nMinCol+500,"TEL: ", oFont11N)
oPrn:say(nLin,nMinCol+600,TNOTA->A1_TEL, oFont10)
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
oPrn:say(nLin,nMinCol,"DescriÁ„o da LocaÁ„o ", oFont11N)
nLin+=nPulaLin
oPrn:box(nLin,nMinCol,nLin+300,nMaxCol) // Box Descri¡Ño da Loca¡Ño
oPrn:box(nLin,nMaxCol-400,nLin+300,nMaxCol) // Box Descri¡aÑo da Loca¡Ño Valores
nLin+=nPulaLin
oPrn:say(nLin-30,nMinCol+010,"Produto", oFont11N)
oPrn:say(nLin-30,nMinCol+300,"DescriÁ„o", oFont11N)

//Itens do Pedido

While !TNOTA->(Eof())
	
	nLin+=nPulaLin
	oPrn:say(nLin-30,nMinCol+010,TNOTA->D2_COD, oFont10)
	oPrn:say(nLin-30,nMinCol+300,TNOTA->B1_DESC, oFont10)
	oPrn:say(nLin,nMaxCol-380,PADC("R$ "+Transform(TNOTA->D2_TOTAL,"@ER 9,999,999.99"),40), oFont10)
	TNOTA->(dBskip())
EndDo



cQuery1:=" SELECT "
cQuery1+=" E1_SALDO, "
cQuery1+=" E1_ACRESC, "
cQuery1+=" E1_DECRESC, "
cQuery1+=" E1_HIST, "
cQuery1+=" E1_VENCREA, "
cQuery1+=" E1_PEDIDO "
cQuery1+=" FROM SE1010 "
cQuery1+=" WHERE "
cQuery1+=" E1_NUM='"+MV_PAR01+"'" 
cQuery1+=" AND E1_CLIENTE='"+MV_PAR02+"'"
cQuery1+=" AND E1_LOJA='"+MV_PAR03+"'"
cQuery1+=" AND E1_PREFIXO= 'LOC' "
cQuery1+=" AND D_E_L_E_T_<>'*' "
MemoWrite('ReciboFim.SQL',cQuery1)
cQuery1:= ChangeQuery(cQuery1)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery1 ),"TFIN",.F.,.T.)

nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin                                        //10901
nLin+=nPulaLin
nLin+=nPulaLin
oBrush1 := TBrush():New( , CLR_GRAY )
oPrn:FillRect( {nLin,nMaxCol-400,nLin+50,nMaxCol}, oBrush1 )
oBrush1:End()
oPrn:say(nLin,nMaxCol-1010,"Total dos ServiÁos: ", oFont15N)

cQuery2:=" SELECT "
cQuery2+=" REPLACE((ISNULL( CONVERT( VARCHAR(8000), CONVERT(VARBINARY(8000), C5_OBSNFSE)),'')),'/','') AS MEMO  "
cQuery2+=" FROM SC5010 "
cQuery2+=" WHERE "
cQuery2+=" C5_NUM='"+TFIN->E1_PEDIDO+"'" 
cQuery2+=" AND D_E_L_E_T_<>'*' "
MemoWrite('OBSPED.SQL',cQuery2)
cQuery2:= ChangeQuery(cQuery2)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery2 ),"TOBS",.F.,.T.)



//oPrn:say(nLin,nMaxCol-410,PADC("R$ "+Transform(SE1->E1_VALOR,"@ER 9,999,999.99"),40),oFont15N)
oPrn:say(nLin,nMaxCol-550,PADC("R$ "+Transform(TFIN->E1_SALDO+TFIN->E1_ACRESC-TFIN->E1_DECRESC,"@ER 9,999,999.99"),40),oFont15N)
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
oPrn:say(nLin,nMinCol,"ObservaÁıes ", oFont11N)
nLin+=nPulaLin
oPrn:box(nLin,nMinCol,nLin+300,nMaxCol) // Box Descri¡Ño da Loca¡Ño
nLin+=nPulaLin
oPrn:say(nLin-30,nMinCol+010,"Vencimento", oFont11N)
oPrn:say(nLin-30,nMinCol+300,"Pedido", oFont11N)
nLin+=nPulaLin
oPrn:say(nLin-30,nMinCol+10,dtoc(sTod(TFIN->E1_VENCREA)), oFont10)
oPrn:say(nLin-30,nMinCol+300,TFIN->E1_PEDIDO, oFont10)
nLin+=nPulaLin
oPrn:say(nLin-30,nMinCol+10,"OUTRAS INFORMA«’ES: ", oFont10)
nLin+=nPulaLin
oPrn:say(nLin-35,nMinCol+10,SUBSTR(AllTrim(StrTran(TOBS->MEMO,chr(13)+chr(10)," ")),1,120), oFont09)
nLin+=nPulaLin
oPrn:say(nLin-40,nMinCol+10,SUBSTR(AllTrim(StrTran(TOBS->MEMO,chr(13)+chr(10)," ")),121,120), oFont09)
nLin+=nPulaLin
oPrn:say(nLin-40,nMinCol+10,SUBSTR(AllTrim(StrTran(TOBS->MEMO,chr(13)+chr(10)," ")),241,120), oFont09)
nLin+=nPulaLin
nLin+=nPulaLin
oPrn:say(nLin-10,nMinCol,"Recibo de locaÁ„o de acordo com publicaÁ„o da LC 116/06, conforme art 7, decreto 5416/06",oFont10N)
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
nLin+=nPulaLin
oPrn:say(nLin,nMinCol,"................................................................................................................................................................................................................................................................", oFont10)
nLin+=nPulaLin
oPrn:say(nLin,nMinCol,"                                               Recebemos de Monteiro Antunes Insumos Hospitalares Ltda.CNPJ 04.078.043.0001-40.", oFont10)
nLin+=nPulaLin                                                          
oPrn:say(nLin,nMinCol,"Data	                                                                    IdentificaÁ„o e assinatura do recebedor	                                            Numero do Recibo  ", oFont10)
nLin+=nPulaLin
oPrn:box(nLin,nMinCol,nLin+150,nMaxCol)     // Box Assinatura
oPrn:box(nLin,nMinCol,nLin+150,nMinCol+300) // Box Assinatura
oPrn:box(nLin,nMinCol,nLin+150,nMaxCol-300) // Box Assinatura



oPrn :EndPage()


oPrn:Preview() //Preview DO RELATORIO
TOBS->(dbCloseArea())
TNOTA->(dbCloseArea())
TFIN->(dbCloseArea())
Return




	
