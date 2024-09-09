#Include 'Totvs.ch'
#Include 'Fileio.ch'
#define  CRLF Chr(10) + Chr(13)
#Include 'Totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc}
Função para Importar CSV Arquivo Orçamento Comercial
@author Ednei Rosa da Silva
@since 06/01/2021
@version 1.0
@return Nil,
@example
u_MAH0201()
/*/

User Function MAH0201()

Local aArea   	:= GetArea()
Local aInfo     := {}
Local cTitulo 	:= "Imparta CSV Orçamento de Vendas"
Local bProcess  := {||}
Local oProcess  := Nil

Private cPerg   := PadR("MAH201",10)

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01		, cDef02		 , cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Arquivo:"        		, "mv_par01", "mv_ch1"	, "C"		, 99						, 0			, "G"		, ""            	,"DIR" 		, 			,				,				 ,			,			,			,		, 			)

Pergunte(cPerg,.F.)

aAdd( aInfo, { "Cancelar", 	{ |oPanelCenter| oPanelCenter:oWnd:End() },	"CANCEL"  })

bProcess := { |oProcess| M201Proc( oProcess ) }

cDescRot := "Esta rotina tem o objetivo de importar um arquivo CSV e criar uma nova meta de vendas"

oProcess := TNewProcess():New( "M201Proc", cTitulo, bProcess, cDescRot, cPerg, aInfo,.F., 5,'Processamento', .T.,.T.)

RestArea(aArea)
Return Nil

/*/{Protheus.doc}
Função para Importar CSV Arquivo Orçamento Comercial
@author Ednei Rosa da Silva
@since 06/01/2021
@version 1.0
@return Nil,
@example
M201Proc()
/*/
Static Function M201Proc( oProcess )


#Define XCT_FILIAL   01  // "Filial do Sistema" + ';'
#Define XCT_TIPO     02  // "Tipo" + ';'
#Define XCT_GRUPO    03  // "Grupo" + ';'
#Define XCT_DESGRU   04  // "Descricao Grupo" + ';'
#Define XCT_MARCA    05  // "Marca" + ';'
#Define XCT_DESMAR   06  // "Descricao Marca" + ';'
#Define XCT_CONTA    07  // "Conta Contabil" + ';'
#Define XCT_CCUSTO   08  // "Centro Custo" + ';'
#Define XCT_ITEMC    09  // "Item Conta" + ';'
#Define XCT_CLVL     10  // "Classe Valor" + ';'
#Define XCT_CATEGO   11  // "Categoria" + ';'
#Define XCT_VEND     12  // "Vendedor" + ';'
#Define XCT_NVEND    13  // "Nome Vendedor + ';'
#Define XCT_SUPERV   14  // "Supervisor + ';'
#Define XCT_GERENT   15  // "Gerente + ';'
#Define XCT_DATA     16  // "Data" + ';'
#Define XCT_QTANT    17  // "Quantidade" + ';'
#Define XCT_VALOR    18  // "Valor" + ';'
#Define XCT_TPOPER   19  // "Tipo Operacao" 


Local aDados	:= {}
Local aLinha	:= {}
Local nHandle   := 0
Local nLinArq	:= 0
Local nCnt		:= 0
Local cTIPO     := ""
Local cGRUPO    := "" 
Local cMARCA    := ""
Local cVEND     := ""
Local nValor    := 0
Local cData     := ""
Local cNewDoc   := ""
Local cAno   	:= ""
Local cMes   	:= ""
Local nLn   	:= 0
Local lNew      :=.T.
Local lFim      :=.F.
Local nlinDupla :=0
Local nLinPost  :=0
Local nTotMeta  :=0
Local cDuplicadas:=""
local cMsgLogCT  :=""
Local cTexto     :=""
Local cLabel     :=""
Local cQuebra    :=CRLF+"---------------------------------------------------------------------"+CRLF
Private lMsErroAuto := .F.

cArquivo := MV_PAR01

nHandle := FT_FUse(cArquivo)

// Verifica se arquivo esta com erro
If nHandle == -1
	
	cMsg := 'Erro na abertura do arquivo ' + Alltrim(cArquivo) + '. Código do erro: ' + Str( fError() )
	oProcess:SaveLog(cMsg)
	Aviso("MAH0201", cMsg, {"Ok"}, 2)
	Return
	
EndIf

// Posiciona na primeria linha
FT_FGoTop()

oProcess:SetRegua1(0)

oProcess:IncRegua1('Processando...')

While !FT_FEOF() .or. nLinArq>110
	
	If nCnt = 0
		
		FT_FSKIP()
		nCnt++
		
	Else
		
		nLinArq++
		
		// Le a linha do arquivo delimitado por ponto e virgula e transforma em um Array
		aLinha := Separa(FT_FReadLn(),';',.T.)
		//alert(FT_FReadLn())
		//alert(aLinha[1]+' | '+aLinha[2]+' | '+aLinha[3]+' | '+aLinha[4]+' | '+aLinha[5]+' | '+aLinha[6]+' | '+aLinha[7]+' | '+aLinha[8]+' | '+aLinha[9]+' | '+aLinha[10]+' | '+aLinha[11]+' | '+aLinha[12]+' | ')
		If aLinha[XCT_FILIAL] = "Filial do Sistema"
			
			FT_FSKIP()
			Loop
		Endif
		
		aAdd( aDados, aLinha )
		// Pula para proxima linha
		FT_FSKIP()
		
	EndIf
	
EndDo // !FT_FEOF()

// Fecha o Arquivo
FT_FUSE()


cTIPO     := ""
cGRUPO    := "" 
cMARCA    := ""
cVEND     := ""
cTPOPER   := ""
nValor    := 0
cData     := ""
lNew:=.T.
// Processa a criação do Orçamento Contábil
If Len(aDados) > 0
		
	//For nLn :=64874 To Len(aDados)
	For nLn :=1 To Len(aDados)
       
		cAno:= SUBSTR(aDados[nLn,  XCT_DATA],1,4)
        cMes:= SUBSTR(aDados[nLn,  XCT_DATA],5,2)
		// Aqui eh feita a verificacao se o registro eh do mesmo indice: 
		// Tipo, grupo, marca vendedor.
		// Caso nao seja, grava a informacoes antigas e inicia outro documento.
        
		IF cTIPO == AllTrim(aDados[nLn,   XCT_TIPO]) .and. cGRUPO == AllTrim(aDados[nLn,  XCT_GRUPO]);
           .and. cMARCA == AllTrim(aDados[nLn,   XCT_MARCA]) .and. cVEND == AllTrim(aDados[nLn,   XCT_VEND]);
		   .and. cTPOPER == AllTrim(aDados[nLn,   XCT_TPOPER])	
		    lNew:=.F.
		Else
            lNew:=.T.
		Endif

        
		

		
		
		// Se for novo gero um novo documento 	
		IF lNew .or. nLn=1
		    cNewDoc:=""
		    ConOut("Gerando novo documento" )
			// pega o valor do ultimo documento
			cNewDoc	:= GetSxeNum("SCT","CT_DOC")
			nTotMeta++
            ConOut("Novo documento Metas de Vendas: "+ cNewDoc )			
			// atualizo os dados do indice agrupador 
				 
	    endif


		IF nTotReg(xFilial("SCT"),cNewDoc,AllTrim(aDados[nLn,   XCT_VEND]),;
			AllTrim(aDados[nLn,  XCT_DATA]),AllTrim(aDados[nLn,   XCT_TIPO]),;
			AllTrim(aDados[nLn,  XCT_GRUPO]),AllTrim(aDados[nLn,   XCT_MARCA]),;
			AllTrim(aDados[nLn,   XCT_TPOPER]))=0

		
			//--< Grava na Tabela SCT >--\\
			Begin Transaction
				// adiciona as 12 linhas para o vendedor antes de gravar o registro
				IF Reclock( "SCT",.T. )
					SCT->CT_DOC     :=cNewDoc
					SCT->CT_SEQUEN  :="0"+cMes
					SCT->CT_DESCRI  :=AllTrim(aDados[nLn,  XCT_NVEND])+" - 202 "
					SCT->CT_FILIAL  :=xFilial("SCT")	
					SCT->CT_TIPO    :=AllTrim(aDados[nLn,   XCT_TIPO])
					SCT->CT_GRUPO   :=AllTrim(aDados[nLn,   XCT_GRUPO])
					SCT->CT_MARCA   :=AllTrim(aDados[nLn,   XCT_MARCA])
					SCT->CT_VEND    :=AllTrim(aDados[nLn,   XCT_VEND])
					SCT->CT_REGIAO  :=""				
					SCT->CT_PRODUTO :=""				
					SCT->CT_QUANT   :=1			
					SCT->CT_MOEDA   :=1						
					SCT->CT_CCUSTO  :=AllTrim(aDados[nLn,   XCT_CCUSTO])	
					SCT->CT_CLVL    :=AllTrim(aDados[nLn,   XCT_CLVL]) 
					SCT->CT_MSBLQL  :="2"						   		
 					SCT->CT_VALOR   :=Val(aDados[nLn ,  XCT_VALOR]) 	
					SCT->CT_DATA    :=stod(AllTrim(aDados[nLn,  XCT_DATA]))  		  
        			SCT->CT_GERENTE :=AllTrim(aDados[nLn,   XCT_GERENT])	
					SCT->CT_SUPERVI :=AllTrim(aDados[nLn,   XCT_SUPERV])	
					SCT->CT_TPOPER  :=AllTrim(aDados[nLn,   XCT_TPOPER])	
					ConfirmSx8()
			   	   Msunlock("SCT")
		    	Else
        	    RollBackSX8()
		        endif
	       End Transaction
       Else
           nlinDupla++
		   
		   cDuplicadas+=CRLF+"Linha da Planilha: "+str(nLn)+" - "+;
		        xFilial("SCT")+" - "+cNewDoc+" - "+AllTrim(aDados[nLn,   XCT_VEND])+" - "+;
				AllTrim(aDados[nLn,  XCT_DATA])+" - "+AllTrim(aDados[nLn,   XCT_TIPO])+" - "+;
				AllTrim(aDados[nLn,  XCT_GRUPO])+" - "+AllTrim(aDados[nLn,   XCT_MARCA])+" - "+;
				AllTrim(aDados[nLn,   XCT_TPOPER])+" - "+AllTrim(aDados[nLn ,  XCT_VALOR])
		   
		   
		   
		   //Se a linha que esta inserida na tabela esta com o valor ZERO e for 
		   //menor que o valor da linha que estamos deixando de inserir, atualizamos 
		   //o com o maior valor.
	       IF nValReg(xFilial("SCT"),cNewDoc,AllTrim(aDados[nLn,   XCT_VEND]),;
		   		AllTrim(aDados[nLn,  XCT_DATA]),AllTrim(aDados[nLn,   XCT_TIPO]),;
				AllTrim(aDados[nLn,  XCT_GRUPO]),AllTrim(aDados[nLn,   XCT_MARCA]),;
			AllTrim(aDados[nLn,   XCT_TPOPER])) < Val(aDados[nLn ,  XCT_VALOR])
           
		  
              // atualiza o valor.
			  postVal(xFilial("SCT"),cNewDoc,AllTrim(aDados[nLn,   XCT_VEND]),;
				AllTrim(aDados[nLn,  XCT_DATA]),AllTrim(aDados[nLn,   XCT_TIPO]),;
				AllTrim(aDados[nLn,  XCT_GRUPO]),AllTrim(aDados[nLn,   XCT_MARCA]),;
				AllTrim(aDados[nLn,   XCT_TPOPER]),Val(aDados[nLn ,  XCT_VALOR]))
              
			 
			  nLinPost++
		   Endif
	   Endif

	   cTIPO   := AllTrim(aDados[nLn,   XCT_TIPO])
	   cGRUPO  := AllTrim(aDados[nLn,   XCT_GRUPO])
	   cMARCA  := AllTrim(aDados[nLn,   XCT_MARCA])
	   cVEND   := AllTrim(aDados[nLn,   XCT_VEND])
	   cTPOPER := AllTrim(aDados[nLn,   XCT_TPOPER])		
	   nValor  := Val(aDados[nLn ,  XCT_VALOR]) 
	   cData   := AllTrim(aDados[nLn,   XCT_DATA])
    
	Next nLn
	
Else
	cMsg := 'Arquivo ' + Alltrim(cArquivo) + ' esta vazio. O processo será abortado'
	oProcess:SaveLog(cMsg)
	Aviso("MAH0201", cMsg, {"Ok"}, 2)
	Return
Endif

cLabel:=CRLF+"Resultado	                 Linha - Fil  - Doc       - Vend   - Data     - Tip- Grupo-Marc- TP - Valor"+CRLF
cMsgLogCT:=""
cMsgLogCT+= CRLF+"Total de documentos Lancados "+str(nTotMeta)
cMsgLogCT+= CRLF+"Total de Linhas Duplicadas "  +str(nlinDupla)
cMsgLogCT+= CRLF+"Total de valores atualizados "+str(nLinPost)

//Montando a mensagem
cTexto := "Função   - "+ FunName()       + CRLF
cTexto += "Usuário  - "+ cUserName       + CRLF
cTexto += "Data     - "+ dToC(dDataBase) + CRLF
cTexto += "Hora     - "+ Time()          + CRLF

cTexto += "Mensagem - " + " Log Cadastro de Metas" + cQuebra  + cMsgLogCT + cQuebra + cLabel + cDuplicadas
MemoWrite('LogMetasdeVendas.TXT',cTexto)

cMsg := "Importação finalizada com sucesso."
oProcess:SaveLog(cMsg)
Aviso("MAH0201", cMsg, {"Ok"}, 2)

Return



/*/{Protheus.doc}
	Função para validar se o registro ja existe na tabela
	@author Ednei Rosa da Silva
	@since 08/01/2021
	@version 1.0
	@return Nil,
	@example
	nTotReg(cFilSct,cDoc,cVend,cData,cTipo,cGrupo,cMarca,cTpOper)
	--------------------------------------------------------------
	Parametros 
    --------------------------------------------------------------
	cFilSct - Filial 
	cDoc    - Documento 
	cVend   - Codigo do Vendedor 
	cData   - Data 
	cTipo   - Tipo do produto 
	cGrupo  - Grupo 
	cMarca  - Marca
	cTpOper - Tipo da operacao (Revenda=RV, Representada=RP)
/*/
static function nTotReg(cFilSct,cDoc,cVend,cData,cTipo,cGrupo,cMarca,cTpOper)

Local nRet   :=0
Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ:=" SELECT COUNT(CT_DOC) NREG "
cQueryZ+=" FROM SCT010 "
cQueryZ+=" WHERE "
cQueryZ+=" CT_FILIAL     ='" + xFilial("SCT") + "'"
cQueryZ+=" AND  CT_DOC   ='" + cDoc    + "'"
cQueryZ+=" AND  CT_VEND  ='" + cVend   + "'"
cQueryZ+=" AND  CT_DATA  ='" + cData   + "'"
cQueryZ+=" AND  CT_TIPO  ='" + cTipo   + "'"
cQueryZ+=" AND  CT_GRUPO ='" + cGrupo  + "'"
cQueryZ+=" AND  CT_MARCA ='" + cMarca  + "'"
cQueryZ+=" AND  CT_TPOPER='" + cTpOper + "'"
cQueryZ+=" AND SCT010.D_E_L_E_T_ <> '*' "
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
IF (cArea)->NREG >0
	nRet:=1
endif
(cArea)->( dbCloseArea() )
return nRet

/*/{Protheus.doc}
	Função para buscal o valor do lancamento ja existente
	@author Ednei Rosa da Silva
	@since 08/01/2021
	@version 1.0
	@return Nil,
	@example
	nTotReg(cFilSct,cDoc,cVend,cData,cTipo,cGrupo,cMarca,cTpOper)
	--------------------------------------------------------------
	Parametros 
    --------------------------------------------------------------
	cFilSct - Filial 
	cDoc    - Documento 
	cVend   - Codigo do Vendedor 
	cData   - Data 
	cTipo   - Tipo do produto 
	cGrupo  - Grupo 
	cMarca  - Marca
	cTpOper - Tipo da operacao (Revenda=RV, Representada=RP)
/*/
static function nValReg(cFilSct,cDoc,cVend,cData,cTipo,cGrupo,cMarca,cTpOper)

Local nRet   :=0
Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ:=" SELECT ISNULL(CT_VALOR,0) VREG "
cQueryZ+=" FROM SCT010 "
cQueryZ+=" WHERE "
cQueryZ+=" CT_FILIAL     ='" + xFilial("SCT") + "'"
cQueryZ+=" AND  CT_DOC   ='" + cDoc    + "'"
cQueryZ+=" AND  CT_VEND  ='" + cVend   + "'"
cQueryZ+=" AND  CT_DATA  ='" + cData   + "'"
cQueryZ+=" AND  CT_TIPO  ='" + cTipo   + "'"
cQueryZ+=" AND  CT_GRUPO ='" + cGrupo  + "'"
cQueryZ+=" AND  CT_MARCA ='" + cMarca  + "'"
cQueryZ+=" AND  CT_TPOPER='" + cTpOper + "'"
cQueryZ+=" AND SCT010.D_E_L_E_T_ <> '*' "
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
nRet:=(cArea)->VREG
(cArea)->( dbCloseArea() )
return nRet



/*/{Protheus.doc}
	Função paraatualizar o valor do lancamento.
	@author Ednei Rosa da Silva
	@since 08/01/2021
	@version 1.0
	@return Nil,
	@example
	nTotReg(cFilSct,cDoc,cVend,cData,cTipo,cGrupo,cMarca,cTpOper,nValor)
	--------------------------------------------------------------
	Parametros 
    --------------------------------------------------------------
	cFilSct - Filial 
	cDoc    - Documento 
	cVend   - Codigo do Vendedor 
	cData   - Data 
	cTipo   - Tipo do produto 
	cGrupo  - Grupo 
	cMarca  - Marca
	cTpOper - Tipo da operacao (Revenda=RV, Representada=RP)
	nValor  - valor atual do registo
/*/
static function postVal(cFilSct,cDoc,cVend,cData,cTipo,cGrupo,cMarca,cTpOper,nValor)
Local nRet:=0
Local cQuery2:=""

cQuery2:=""
cQuery2:=" UPDATE SCT010 SET CT_VALOR ="+cValToChar(nValor)
cQuery2+="  WHERE "
cQuery2+=" CT_FILIAL     ='" + xFilial("SCT") + "'"
cQuery2+=" AND  CT_DOC   ='" + cDoc    + "'"
cQuery2+=" AND  CT_VEND  ='" + cVend   + "'"
cQuery2+=" AND  CT_DATA  ='" + cData   + "'"
cQuery2+=" AND  CT_TIPO  ='" + cTipo   + "'"
cQuery2+=" AND  CT_GRUPO ='" + cGrupo  + "'"
cQuery2+=" AND  CT_MARCA ='" + cMarca  + "'"
cQuery2+=" AND  CT_TPOPER='" + cTpOper + "'"
cQuery2+=" AND SCT010.D_E_L_E_T_ <> '*' "
	
nRet:=TcSqlExec(cQuery2)
If nRet<>0
	ConOut("Erro ao atualizar nome do medico no pedido" + TCSQLERROR())
Endif
return 
