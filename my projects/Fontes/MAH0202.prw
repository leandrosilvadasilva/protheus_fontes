#Include 'Totvs.ch'
#Include 'Fileio.ch'
#define  CRLF Chr(10) + Chr(13)
#Include 'Totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc}
Função para Importar CSV Matriz de Vendas 
@author Ednei Rosa da Silva
@since 28/07/2021
@version 1.0
@return Nil,
@example
u_MAH0202()
/*/

User Function MAH0202()

Local aArea   	:= GetArea()
Local aInfo     := {}
Local cTitulo 	:= "Imparta CSV Matriz de Vendas"
Local bProcess  := {||}
Local oProcess  := Nil

Private cPerg   := PadR("MAH202",10)

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01		, cDef02		 , cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Arquivo:"        		, "mv_par01", "mv_ch1"	, "C"		, 99						, 0			, "G"		, ""            	,"DIR" 		, 			,				,				 ,			,			,			,		, 			)

Pergunte(cPerg,.F.)

aAdd( aInfo, { "Cancelar", 	{ |oPanelCenter| oPanelCenter:oWnd:End() },	"CANCEL"  })

bProcess := { |oProcess| M202Proc( oProcess ) }

cDescRot := "Esta rotina tem o objetivo de importar um arquivo CSV matriz de vendas"

oProcess := TNewProcess():New( "M201Proc", cTitulo, bProcess, cDescRot, cPerg, aInfo,.F., 5,'Processamento', .T.,.T.)

RestArea(aArea)
Return Nil

/*/{Protheus.doc}
Função para Importar CSV matriz de vendas 
@author Ednei Rosa da Silva
@since 28/07/2021
@version 1.0
@return Nil,
@example
M201Proc()
/*/
Static Function M202Proc( oProcess )


#Define TZA7_FILIAL   01  // "Filial do Sistema" + ';'
#Define TZA7_CODCLI   02  // "Codigo Cliente" + ';'
#Define TZA7_LOJCLI   03  // "Loja Cliente" + ';'
#Define TZA7_NOME     04  // "Nome Cliente" + ';'
#Define TZA7_CODVEN   05  // "Codigo Vendedor" + ';'
#Define TZA7_NOMVEN   06  // "Nome Vendedor" + ';'
#Define TZA7_MARCA    07  // "Marca" + ';'
#Define TZA7_DESMAR   08  // "Descricao Marca" + ';'
#Define TZA7_CODGRU   09  // "Codigo Grupo" + ';'
#Define TZA7_DESGRU   10  // "Descricao Grupo" + ';'
#Define TZA7_EST      11  // "UF" + ';'
#Define TZA7_MUNIC    12  // "Municipio" + ';'

Local aDados	:= {}
Local aLinha	:= {}
Local nHandle   := 0
Local nLinArq	:= 0
Local nCnt		:= 0
Local nLn   	:= 0
Local lNew      :=.T.
Local cMsg      :=''
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

While !FT_FEOF() .and. nLinArq<10000
	
	If nCnt = 0
		
		FT_FSKIP()
		nCnt++
		
	Else
		
		nLinArq++
		
		// Le a linha do arquivo delimitado por ponto e virgula e transforma em um Array
		aLinha := Separa(FT_FReadLn(),';',.T.)
		//alert(FT_FReadLn())
		///alert(aLinha[1]+' | '+aLinha[2]+' | '+aLinha[3]+' | '+aLinha[4]+' | '+aLinha[5]+' | '+aLinha[6]+' | '+aLinha[7]+' | '+aLinha[8]+' | '+aLinha[9]+' | '+aLinha[10]+' | '+aLinha[11]+' | '+aLinha[12]+' | ')
		If aLinha[TZA7_FILIAL] = "ZA7_FILIAL"
			
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


lNew:=.T.
// Processa a criação do Orçamento Contábil
If Len(aDados) > 0
		
	//For nLn :=64874 To Len(aDados)
	For nLn :=1 To Len(aDados)
       
		//--< Grava na Tabela ZA7 >--\\
		Begin Transaction
			// adiciona as 12 linhas para o vendedor antes de gravar o registro
			
			
			IF Reclock( "ZA7",.T. )
			
				ZA7->ZA7_FILIAL  :=AllTrim(aDados[nLn,   TZA7_FILIAL])
				ZA7->ZA7_CODCLI  :=AllTrim(aDados[nLn,   TZA7_CODCLI])
				ZA7->ZA7_LOJCLI  :=AllTrim(aDados[nLn,   TZA7_LOJCLI])
				ZA7->ZA7_NOME    :=AllTrim(aDados[nLn,   TZA7_NOME])
				ZA7->ZA7_CODVEN  :=AllTrim(aDados[nLn,   TZA7_CODVEN])
				ZA7->ZA7_NOMVEN  :=AllTrim(aDados[nLn,   TZA7_NOMVEN])				
				ZA7->ZA7_MARCA   :=AllTrim(aDados[nLn,   TZA7_MARCA])				
				ZA7->ZA7_DESMAR  :=AllTrim(aDados[nLn,   TZA7_DESMAR])			
				ZA7->ZA7_CODGRU  :=AllTrim(aDados[nLn,   TZA7_CODGRU])						
				ZA7->ZA7_DESGRU  :=AllTrim(aDados[nLn,   TZA7_DESGRU])	
				ZA7->ZA7_EST     :=AllTrim(aDados[nLn,   TZA7_EST]) 
				ZA7->ZA7_MUNIC   :=AllTrim(aDados[nLn,   TZA7_MUNIC])						   		
 				
			   ConfirmSx8()
			   Msunlock("ZA7")
		    Else
        	    RollBackSX8()
		    endif
	    End Transaction
      
	Next nLn
	
Else
	cMsg := 'Arquivo ' + Alltrim(cArquivo) + ' esta vazio. O processo será abortado'
	oProcess:SaveLog(cMsg)
	Aviso("MAH0202", cMsg, {"Ok"}, 2)
	Return
Endif

oProcess:SaveLog(cMsg)
Aviso("MAH0202", cMsg, {"Ok"}, 2)

Return



