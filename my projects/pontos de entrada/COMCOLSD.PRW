#Include 'Protheus.ch'
User Function COMCOLSD()
Local aArea := GETAREA()
Local aCols := PARAMIXB[1]
Local aHeader := PARAMIXB[2]
Local posFilial 

posFilial := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="DT_FILIAL"})
posCnpj   := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="DT_CNPJ"})
posFornec := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="DT_FORNEC"})
posLoja   := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="DT_LOJA"})
posDoc    := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="DT_DOC"})
// Validações do usuário 

//DT_FILIAL+DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE                                                                                                             
SDT->(dBSetOrder(1))
If SDT->(MsSeek(xFilial("SDT")+SDS->DS_CNPJ+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE))
    While SDS->DS_CNPJ == SDT->DT_CNPJ .And. SDS->DS_FORNEC == SDT->DT_FORNEC .And. SDS->DS_LOJA == SDT->DT_LOJA .And. SDS->DS_DOC == SDT->DT_DOC
        POSICIONE("SB1", 1, XFILIAL("SB1")+SDT->DT_COD, "B1_DESC")
        If SB1->B1_XQTMULT > 0 .AND. !EMPTY(ALLTRIM(SB1->B1_XFTMULT)) .AND. EMPTY(ALLTRIM(SDT->DT_XCONV))
            RecLock("SDT",.F.)
                IF ALLTRIM(SB1->B1_XFTMULT) == '1' // MULTIPLICAR
                    SDT->DT_QUANT := SDT->DT_QUANT * SB1->B1_XQTMULT
                    SDT->DT_VUNIT := SDT->DT_VUNIT / SB1->B1_XQTMULT
                    SDT->DT_XCONV := 'S'
                ELSE // DIVIDIR
                    SDT->DT_QUANT := SDT->DT_QUANT / SB1->B1_XQTMULT
                    SDT->DT_VUNIT := SDT->DT_VUNIT * SB1->B1_XQTMULT
                    SDT->DT_XCONV := 'S'
                ENDIF
            MsUnLock()
        EndIF
        SDT-> (DbSkip())
    End
EndIf

RestArea(aArea)

Return
