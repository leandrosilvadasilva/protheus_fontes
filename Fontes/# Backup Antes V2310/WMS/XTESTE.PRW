#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"
#INCLUDE "FWPrintSetup.ch"


USER FUNCTION XTESTE()



Local aDados := {}
Local cType
Local _arquivo
Local qry
Local i

Local aSA1Auto := {}
Local aAI0Auto := {}
Local nOpcAuto := 3//MODEL_OPERATION_INSERT
Local lRet := .T.
 
Private lMsErroAuto := .F.

Private cpath := "c:\temp\"
Private aLinha := {}
Private negK := {}
Private arr0200 := {}
Private stri0200 := ""
Private vK200 := {}
Private grpExc := "" // grupo de produtos que não serão enviados para o K200
Private arqK
Private linhaK
Private contador
Private qtd0200 :=0 
Private qtdk200 := 0 
Private qtdk280 := 0 
Private tLin := 0
Private dataInicial
Private dataFinal
Private dataRef
Private cquery
Private _arqOrig
Private _arqNew
Private _contK := 2 
Private _cont0200 := 0 


/*
	CQUERY := " INSERT INTO SB7010 (B7_FILIAL,B7_COD,B7_LOCAL,B7_TIPO,B7_DOC,B7_QUANT,B7_DATA,B7_LOTECTL,B7_NUMDOC,B7_DTVALID) VALUES( '0101', 'CV-SIGPSHELL        ', '01', 'M4', 'INV100622',  70, '20220610', 'N1L0695Y', 'N1L0695Y', '20241031') "
	nstatus := TcSqlExec(CQUERY)	

    if (nStatus < 0)
        alert("TCSQLError() " + TCSQLError())
    else 
        alert('sucesso')
    endif
   
  TCUnlink()
*/




cType := "Arquivo CSV " + "(*.CSV) |*.csv|" //Arquivos .txt

_arquivo := cGetFile(cType, "Selecione arquivo", 0,, .T.,nor(GETF_LOCALHARD,GETF_NETWORKDRIVE))  //Seleciona o arquivo

IF EMPTY(_arquivo)
	ALERT("Arquivo não encontrado")
	RETURN
ENDIF

//Leitura do arquivo csv contendo TODAS as informações 
aDados := U_CARGACSV(_arquivo)

FOR i:=1 TO LEN(aDados)

        RecLock("SB7", .T.)
            SB7->B7_FILIAL  := REPLACE(ALLTRIM(aDados[i][1]), "'","")
            SB7->B7_COD     := REPLACE(ALLTRIM(aDados[i][2]), "'","")
            SB7->B7_LOCAL   := REPLACE(ALLTRIM(aDados[i][3]), "'","")
            SB7->B7_TIPO    := REPLACE(ALLTRIM(aDados[i][4]), "'","")
            SB7->B7_DOC     := REPLACE(ALLTRIM(aDados[i][5]), "'","")
            SB7->B7_QUANT   := VAL(ALLTRIM(aDados[i][6]))
            temp := REPLACE(ALLTRIM(aDados[i][7]), "'","")
            temp := SUBSTRING(temp, 7, 2)+'/'+SUBSTRING(temp, 5, 2)+'/'+SUBSTRING(temp, 1, 4)
            SB7->B7_DATA    := CTOD(temp)
            SB7->B7_LOTECTL := REPLACE(ALLTRIM(aDados[i][8]), "'","")
            SB7->B7_NUMDOC  := REPLACE(ALLTRIM(aDados[i][9]), "'","")
            temp2 := REPLACE(ALLTRIM(aDados[i][10]), "'","")
            temp2 := SUBSTRING(temp2, 7, 2)+'/'+SUBSTRING(temp2, 5, 2)+'/'+SUBSTRING(temp2, 1, 4)
            SB7->B7_DTVALID := CTOD(temp2)
        SB7->(MSUNLOCK())        

NEXT i

RETURN





user Function CargaCSV(cArq)

Local cLinha  := ""
Local nLin    := 1 
Local nTotLin := 0
Local aDados  := {}
Local cFile   :=  cArq
Local nHandle := 0


//abre o arquivo csv gerado na temp
nHandle := Ft_Fuse(cFile)
If nHandle == -1
   Return aDados
EndIf
Ft_FGoTop()                                                         
nLinTot := FT_FLastRec()-1
ProcRegua(nLinTot)
/*
//Pula as linhas de cabeçalho
While nLinTit > 0 .AND. !Ft_FEof()
   Ft_FSkip()
   nLinTit--
EndDo
*/
//percorre todas linhas do arquivo csv
Do While !Ft_FEof()
   //exibe a linha a ser lida
   IncProc("Carregando Linha "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))
   nLin++
   //le a linha
   cLinha := Ft_FReadLn()
   //verifica se a linha está em branco, se estiver pula
   If Empty(AllTrim(StrTran(cLinha,';','')))
      Ft_FSkip()
      Loop
   EndIf
   //transforma as aspas duplas em aspas simples
   cLinha := StrTran(cLinha,'"',"'")
   cLinha := '{"'+cLinha+'"}' 
   //adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array 
   cLinha := StrTran(cLinha,';','","')
   aAdd(aDados, &cLinha)
   
   //passa para a próxima linha
   FT_FSkip()
   //
EndDo

//libera o arquivo CSV
FT_FUse()             

Return aDados

