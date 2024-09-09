#Include 'Totvs.ch'
#Include 'Fileio.ch'
#define CRLF Chr(10) + Chr(13)
#Include 'Totvs.ch'
#include 'topconn.ch'
 
/*/{Protheus.doc}
Função para Importar CSV Arquivo Orçamento Contábil
@author Jeferson Silva
@since 18/11/2019
@version 1.0
@return Nil,
@example
u_CIRM400()
/*/

User Function CI_M400()

Local aArea   	:= GetArea()
Local aInfo     := {}
Local cTitulo 	:= "Imparta CSV Orçamento Contábil"
Local bProcess  := {||}
Local oProcess  := Nil

Private cPerg   := PadR("CI_M400",10)

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01		, cDef02		 , cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Arquivo:"        		, "mv_par01", "mv_ch1"	, "C"		, 99						, 0			, "G"		, ""            	,"DIR" 		, 			,				,				 ,			,			,			,		, 			)

Pergunte(cPerg,.F.)

aAdd( aInfo, { "Cancelar", 	{ |oPanelCenter| oPanelCenter:oWnd:End() },	"CANCEL"  })

bProcess := { |oProcess| M400Proc( oProcess ) }

cDescRot := "Esta rotina tem o objetivo de importar um arquivo CSV e criar um novo Orçamento Contábil"

oProcess := TNewProcess():New( "CI_M400", cTitulo, bProcess, cDescRot, cPerg, aInfo,.F., 5,'Processamento', .T.,.T.)

RestArea(aArea)
Return Nil

/*/{Protheus.doc}
Funcção para Processamento da importação do Arquivo Orçamento Contábil
@author Jeferson Silva
@since 18/11/2019
@version 1.0
@return Nil,
@example
M400Proc()
/*/
Static Function M400Proc( oProcess )

#Define PCV1_FILIAL   01  // "Filial do Sistema" + ';'
#Define PCV1_ORCMTO   02  // "Codigo do Orcamento" + ';'
#Define PCV1_DESCRI   03  // "Descrição do Orcamento" + ';'
#Define PCV1_CALEND   04  // "Calendario" + ';'
#Define PCV1_MOEDA    05  // "Moeda" + ';'
#Define PCV1_REVISA   06  // "Revisao" + ';'
#Define PCV1_CT1INI   07  // "Conta Inicial" + ';'
#Define PCV1_CT1FIM   09  // "Conta Final" + ';'
#Define PCV1_CTTINI   11  // "Centro de Custo Inicial" + ';'
#Define PCV1_CTTFIM   12  // "Centro de Custo Final" + ';'
#Define PCV1_CTDINI   13  // "Item Inicial" + ';'
#Define PCV1_CTDFIM   14  // "Item Final" + ';'
#Define PCV1_CTHINI   15  // "Classe de Valor Inicial" + ';'
#Define PCV1_CTHFIM   16  // "Classe de Valor  Final" + ';'
#Define PCV1_DTINI    17  // "Periodo Inicial" + ';'
#Define PCV1_DTFIM    18  // "Periodo Final" + ';'
#Define PCV1_VALOR    19  // "Valor Orcado" + ';'
#Define P_L18   20  // "Valor Contabilizado" + ';'
#Define P_L19   21  // "Valor NFE nao Contabilizadas" + ';'
#Define P_L20   22  // "Valor Total Realizado" + ';'
#Define P_L21   23  // "Variacao em %" + ';'
#Define P_L22   24 // "Variacao em Real"

Local aLinha    := {}
Local aDados	:= {}

Local nHandle   := 0
Local nLinArq	:= 0
Local nCnt		:= 0
Local cDtIni    := ''
Local nSeq      := 0
Local nPer      := 0
Local nLn
cArquivo := MV_PAR01

nHandle := FT_FUse(cArquivo)

// Verifica se arquivo esta com erro
If nHandle == -1
	
	cMsg := 'Erro na abertura do arquivo ' + Alltrim(cArquivo) + '. Código do erro: ' + Str( fError() )
	oProcess:SaveLog(cMsg)
	Aviso("CI_M400", cMsg, {"Ok"}, 2)
	Return
	
EndIf

// Posiciona na primeria linha
FT_FGoTop()

oProcess:SetRegua1(0)

oProcess:IncRegua1('Processando...')

While !FT_FEOF()
	
	If nCnt = 0
		
		FT_FSKIP()
		nCnt++
		
	Else
		
		nLinArq++
		
		// Le a linha do arquivo delimitado por ponto e virgula e transforma em um Array
		aLinha := Separa(FT_FReadLn(),';',.T.)
		
		If aLinha[PCV1_FILIAL] = "Filial do Sistema"
			
			FT_FSKIP()
			Loop
		Endif
		
		If Empty(aLinha[PCV1_ORCMTO])
			
			cMsg := 'Erro no arquivo ' + Alltrim(cArquivo) + '. Linha: ' + Str(nLinArq)
			oProcess:SaveLog(cMsg)
			Aviso("CI_M400", cMsg, {"Ok"}, 2)
			Return
			
		EndIf
		
		aAdd( aDados, aLinha )
		
		// Pula para proxima linha
		FT_FSKIP()
		
	EndIf
	
EndDo // !FT_FEOF()

// Fecha o Arquivo
FT_FUSE()

// Processa a criação do Orçamento Contábil
If Len(aDados) > 0
	
	For nLn := 1 To Len(aDados)
		
		//--< Grava na Tabela CV1 >--\\
		Begin Transaction
		
		IF nLn = 1
			dbSelectArea("CV2")
			dbSetOrder(1)
			If dbSeek( xFilial("CV2") + aDados[nLn, PCV1_ORCMTO]+aDados[nLn, PCV1_CALEND]+aDados[nLn, PCV1_MOEDA]+aDados[nLn, PCV1_REVISA] )
				cMsg := 'Orçamento ' + aDados[nLn, PCV1_ORCMTO] + ' ' +aDados[nLn, PCV1_REVISA] +' já cadastrado. O processo será abortado. '
				oProcess:SaveLog(cMsg)
				Aviso("CI_M400", cMsg, {"Ok"}, 2)
			Else
				Reclock("CV2",.T.)
				CV2->CV2_FILIAL	:= xFilial("CV2")
				CV2->CV2_ORCMTO	:= aDados[nLn, PCV1_ORCMTO]  
				CV2->CV2_DESCRI := aDados[nLn, PCV1_DESCRI]
				CV2->CV2_CALEND	:= aDados[nLn, PCV1_CALEND]
				CV2->CV2_MOEDA	:= aDados[nLn, PCV1_MOEDA]
				CV2->CV2_REVISA	:= aDados[nLn, PCV1_REVISA]
				CV2->CV2_STATUS	:= '2'
				CV2->(MsUnlock())
				Msunlock()
				
				CdtIni := aDados[nLn, PCV1_DTINI]

				/*
				dbSelectArea("CTG")
				dbSetOrder(1)
				dbSeek(xFilial("CTG") + aDados[nLn, PCV1_CALEND])
				While !Eof() .And. CTG_FILIAL = xFilial('CTG') .And. CTG_CALEND = aDados[nLn, PCV1_CALEND]
				cAuxQtdPer := Val(CTG->CTG_PERIOD)
				DbSkip()
				Loop
				End
				*/
			Endif
		Endif
		/*
		If cAuxQtdPer = 0
		Aviso("CI_M400", 'Calendário ' + aDados[nLn, PCV1_CALEND]+ ' inconsistente. O processo será abortado', {"Ok"}, 2)
		cMsg := 'Calendário ' + aDados[nLn, PCV1_CALEND]+ ' inconsistente. O processo será abortado'
		oProcess:SaveLog(cMsg)
		Return
		Endif
		*/
		If aDados[nLn, PCV1_DTINI] = CdtIni     
			nSeq ++
			nPer := 1
		Else
			nPer ++
		Endif
		
		//dbSelectArea("CV1")
		Reclock( "CV1",.T. )
		CV1->CV1_FILIAL := xFilial("CV1")
		CV1->CV1_ORCMTO := aDados[nLn, PCV1_ORCMTO]
		CV1->CV1_DESCRI := aDados[nLn, PCV1_DESCRI]
		CV1->CV1_CALEND := aDados[nLn, PCV1_CALEND]
		CV1->CV1_MOEDA  := aDados[nLn, PCV1_MOEDA]
		CV1->CV1_REVISA := aDados[nLn, PCV1_REVISA]
		CV1->CV1_CT1INI := aDados[nLn, PCV1_CT1INI]
		CV1->CV1_CT1FIM := aDados[nLn, PCV1_CT1FIM]
		CV1->CV1_CTTINI := aDados[nLn, PCV1_CTTINI]
		CV1->CV1_CTTFIM := aDados[nLn, PCV1_CTTFIM]
		CV1->CV1_CTDINI := aDados[nLn, PCV1_CTDINI]
		CV1->CV1_CTDFIM := aDados[nLn, PCV1_CTDFIM]
		CV1->CV1_CTHINI := aDados[nLn, PCV1_CTHINI]
		CV1->CV1_CTHFIM := aDados[nLn, PCV1_CTHFIM]
		CV1->CV1_DTINI  := Ctod(aDados[nLn, PCV1_DTINI])
		CV1->CV1_DTFIM  := Ctod(aDados[nLn, PCV1_DTFIM])
		CV1->CV1_VALOR  := Val(aDados[nLn, PCV1_VALOR])
		CV1->CV1_STATUS := '2'
		
		CV1->CV1_SEQUEN  := Strzero(nSeq,4)
		CV1->CV1_PERIOD  := Strzero(nPer,2)
		
		Msunlock()
		
		End Transaction
		//--< Fim - Grava na Tabela >--\\
		
	Next nLn
	
Else
	cMsg := 'Arquivo ' + Alltrim(cArquivo) + ' esta vazio. O processo será abortado'
	oProcess:SaveLog(cMsg)
	Aviso("CI_M400", cMsg, {"Ok"}, 2)
	Return
Endif

cMsg := "Importação finalizada com sucesso."
oProcess:SaveLog(cMsg)
Aviso("CI_M400", cMsg, {"Ok"}, 2)

Return

