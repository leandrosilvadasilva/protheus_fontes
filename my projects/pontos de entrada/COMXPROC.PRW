#Include 'Protheus.ch'
#Include "TOTVS.ch"

User Function COMXPROC()

Local aArea := GETAREA()
Local mensagem := ''


//DT_FILIAL+DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE                                                                                                             
SDT->(dBSetOrder(1))
If SDT->(MsSeek(xFilial("SDT")+SDS->DS_CNPJ+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE))
    While SDS->DS_CNPJ == SDT->DT_CNPJ .And. SDS->DS_FORNEC == SDT->DT_FORNEC .And. SDS->DS_LOJA == SDT->DT_LOJA .And. SDS->DS_DOC == SDT->DT_DOC
        IF !EMPTY(ALLTRIM(SDT->DT_PEDIDO)) .AND. !EMPTY(ALLTRIM(SDT->DT_ITEMPC))
            POSICIONE("SC7", 1, SDT->DT_FILIAL+SDT->DT_PEDIDO+SDT->DT_ITEMPC, "C7_FILIAL")
            IF SDT->DT_QUANT > SC7->C7_QUANT
                mensagem := mensagem + "ERRO NO ITEM " + ALLTRIM(SDT->DT_ITEMPC) + " QTD XML = " + CVALTOCHAR(SDT->DT_QUANT) + " QTD P.C. = " + CVALTOCHAR(SC7->C7_QUANT) + Chr(13) + Chr(10) 
            ENDIF
            
            IF SDT->DT_VUNIT <> SC7->C7_PRECO            
                mensagem := mensagem + "ERRO NO ITEM " + ALLTRIM(SDT->DT_ITEMPC) + " VALOR XML = R$ " + CVALTOCHAR(SDT->DT_VUNIT) + " VALOR P.C. = R$ " + CVALTOCHAR(SC7->C7_PRECO) + Chr(13) + Chr(10) 
            ENDIF

        ENDIF
        SDT-> (DbSkip())
    End
EndIf

IF !EMPTY(ALLTRIM(mensagem))
    MsgInfo(mensagem)
ENDIF

RestArea(aArea)

Return .T.
