

USER FUNCTION LOTEDEVAT()

    Local lote := ""
    Local nI
    Local aAreaSD2 := SD2->(GETAREA())

    FOR nI := 1 TO len(AAUTOITENS)

        posCod := ASCAN(AAUTOITENS[nI],{|x| upper(alltrim(x[1]))=="D1_COD"})
        posCliente := ASCAN(AAUTOCAB,{|x| upper(alltrim(x[1]))=="F1_FORNECE"})
        posLoja    := ASCAN(AAUTOCAB,{|x| upper(alltrim(x[1]))=="F1_LOJA"})
        IF RIGHT(ALLTRIM(AAUTOITENS[nI][posCod][2]),3) == 'IMB'

            posNFOri   := ASCAN(AAUTOITENS[nI],{|x| upper(alltrim(x[1]))=="D1_NFORI"})
            posSerOri  := ASCAN(AAUTOITENS[nI],{|x| upper(alltrim(x[1]))=="D1_SERIORI"})
            posItOri   := ASCAN(AAUTOITENS[nI],{|x| upper(alltrim(x[1]))=="D1_ITEMORI"})

            IF posNFOri > 0 .AND. posSerOri > 0 .AND. posItOri > 0 
                
                POSICIONE("SD2", 3, XFILIAL("SD2")+AAUTOITENS[nI][posNfOri][2]+AAUTOITENS[nI][posSerOri][2]+AAUTOCAB[posCliente][2]+AAUTOCAB[posLoja][2]+AAUTOITENS[nI][posCod][2]+AAUTOITENS[nI][posItOri][2],"D2_LOTECTL")
                lote := SD2->D2_LOTECTL
                
            ENDIF

        ENDIF

    NEXT nI

    RESTAREA( aAreaSD2 )

RETURN lote
