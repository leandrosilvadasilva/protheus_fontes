#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"


USER FUNCTION GERASB7()

Local i
Local cpath := "c:\temp\"
Local aLinha := {}
cType := "Arquivo CSV " + "(*.CSV) |*.csv|" //Arquivos .txt

_arquivo := cGetFile(cType, "Selecione arquivo", 0,, .T.,nor(GETF_LOCALHARD,GETF_NETWORKDRIVE))  //Seleciona o arquivo

IF EMPTY(_arquivo)
	ALERT("Arquivo não encontrado")
	RETURN
ENDIF

//Leitura do arquivo csv contendo TODAS as informações 
aDados := CARGACSV(_arquivo)

FOR i:=2 TO LEN(aDados)

   IF !EMPTY(ALLTRIM(aDados[i][1]))

      IF RecLock("SB7",.T.)
         SB7->B7_FILIAL  := CFILANT
         SB7->B7_COD     := ALLTRIM(aDados[i][1])
         IF LEN(ALLTRIM(aDados[i][2])) == 1
            SB7->B7_LOCAL   := "0" + ALLTRIM(aDados[i][2]) // PARA GARANTIR QUE O ARMAZEM TENHA 2 DIGITOS
         ELSE 
            SB7->B7_LOCAL   := ALLTRIM(aDados[i][2])
         ENDIF
         SB7->B7_TIPO    := POSICIONE("SB1", 1, XFILIAL("SB1")+ALLTRIM(aDados[i][1]), "B1_TIPO")
         SB7->B7_DOC     := ALLTRIM(aDados[i][3])
         SB7->B7_QUANT   := VAL(ALLTRIM(aDados[i][4]))
         SB7->B7_DATA    := DDATABASE
         SB7->B7_LOTECTL := ALLTRIM(aDados[i][5])
      
         dataValid       := getDtValid(CFILANT, ALLTRIM(aDados[i][1]), ALLTRIM(aDados[i][2]), ALLTRIM(aDados[i][5]))
         IF !EMPTY(ALLTRIM(dataValid))
            SB7->B7_DTVALID := CTOD( dataValid )
         ENDIF
      
         SB7->B7_STATUS  := "1"
         SB7->(MsUnlock())
        
      ELSE 
         ALERT( "ERRO. IMPOSSIVEL DAR RECLOCK NA SB7") 
      ENDIF
   ENDIF

Next i


RETURN



STATIC Function CargaCSV(cArq)

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



Static Function getDtValid(filial, produto, local, lote)

	Local dataValid
	Local cQry

    cQry := " SELECT Substring(B8_DTVALID,7,2)+'/'+Substring(B8_DTVALID,5,2)+'/'+Substring(B8_DTVALID,1,4) AS B8_DTVALID "
	cQry += " FROM SB8010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND B8_FILIAL = '" + filial + "' AND B8_PRODUTO = '" + ALLTRIM(produto) + "' "
	cQry += "       AND B8_LOCAL = '" + local + "' AND B8_LOTECTL = '" + ALLTRIM(lote) + "' "

	CONOUT("CONSULTA ( getDtValid ).: " + cQry)

	TCQuery cQry New Alias "QRY_SB8"
	
	QRY_SB8->(DbGoTop())

	While ! QRY_SB8->(Eof())

        dataValid := QRY_SB8->B8_DTVALID
		
		QRY_SB8->(DbSkip())
	EndDo

	QRY_SB8->(DbCloseArea())

Return dataValid
