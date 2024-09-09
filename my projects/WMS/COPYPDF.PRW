#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"
#INCLUDE "FWPrintSetup.ch"



/*
    IATAN EM 29/09/2022 - chamada de rotina de geração de pdf via chedule do protheus
*/
USER FUNCTION CPY_PDF()

    Local cCommand := "D:\Totvs\Protheus\bin\smartclient\smartclient.exe -q -p=u_CPYPDF -c=PDF -e=PRODUCAO -m -l=1 "
    Local lWait  := .F.
    Local cPath     := "C:\temp\"

    WaitRunSrv( @cCommand , @lWait , @cPath )


RETURN

/*FUNÇÃO DE CÓPIA DOS BOLETOS*/
USER FUNCTION CPYPDF()

  Local nX
  Local nCount
  Local aFilesWMS := Directory("\pdf_wms\boleto\*.pdf",,,,2)
  Local aFilesZ := Directory("z:\boleto\*.pdf",,,,2)
  Local posicao
  Local arrInfo := GetUserInfoArray()

    Local contador := 0
    Local nW := 1

    CONOUT("--->> ENTRANDO DA ROTINA DE COPIA DE PDF<<---")

    FOR nW := 1 TO LEN(arrInfo)
        IF ALLTRIM(arrInfo[nW][5]) == "U_CPYPDF"
            contador++
        ENDIF
    NEXT nX
     
    IF contador > 1 // 1 = THREAD ATUAL
        CONOUT("--->> SAINDO DA ROTINA DE COPIA DE PDF PORQUE JA ESTA SENDO EXECUTADA<<---")
        RETURN
    ENDIF

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT" 

  ASORT(aFilesWMS, , , { | x,y | x[3] > y[3] } )//ORDENA POR DATA
  ASORT(aFilesZ, , , { | x,y | x[3] > y[3] } )//ORDENA POR DATA
  nCount := Len( aFilesWMS )
  For nX := 1 to nCount
      //ConOut('Arquivo: ' + aFiles[nX,1] + ' - Size: ' + AllTrim(Str(aFiles[nX,2])) )
      IF aFilesWMS[nX][3] <> DDATABASE
            EXIT
      ENDIF

      posicao  := aScan(aFilesZ,{|x| AllTrim(x[1])==aFilesWMS[nX][1]})
      IF posicao == 0
            bOK := CpyS2T( "\pdf_wms\boleto\"+aFilesWMS[nX][1], "z:\boleto", .F. )
            IF bOK == .F.
                CONOUT("FALHA NA COPIA DO BOLETO ... "+aFilesWMS[nX][1])
            ELSE
                CONOUT("SUCESSO NA COPIA DO BOLETO ... "+aFilesWMS[nX][1])
            ENDIF
      ENDIF

  Next nX

  aFilesWMS := Nil
  aFilesZ := Nil
  nCount := 0
  nX := 0

  aFilesWMS := Directory("\pdf_wms\pdf\*.pdf",,,,2)
  aFilesZ := Directory("z:\pdf\*.pdf",,,,2)

  ASORT(aFilesWMS, , , { | x,y | x[3] > y[3] } )//ORDENA POR DATA
  ASORT(aFilesZ, , , { | x,y | x[3] > y[3] } )//ORDENA POR DATA
  nCount := Len( aFilesWMS )
  For nX := 1 to nCount
      //ConOut('Arquivo: ' + aFiles[nX,1] + ' - Size: ' + AllTrim(Str(aFiles[nX,2])) )
      IF aFilesWMS[nX][3] <> DDATABASE
            EXIT
      ENDIF

      posicao  := aScan(aFilesZ,{|x| AllTrim(x[1])==aFilesWMS[nX][1]})
      IF posicao == 0
            bOK := CpyS2T( "\pdf_wms\pdf\"+aFilesWMS[nX][1], "z:\pdf", .F. )
            IF bOK == .F.
                CONOUT("FALHA NA COPIA DO ARQUIVO PDF ... "+aFilesWMS[nX][1])
            ELSE 
                CONOUT("SUCESSO NA COPIA DO ARQUIVO PDF ... "+aFilesWMS[nX][1])
            ENDIF
      ENDIF

  Next nX

    RESET ENVIRONMENT
  CONOUT("--->> SAINDO DA ROTINA DE COPIA DE PDF<<---")

RETURN
