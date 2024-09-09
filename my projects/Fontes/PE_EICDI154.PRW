#Include 'Protheus.ch'

/*
    IATAN EM 31/08/2023
    DOCUMENTO DE REFERENCIA = https://tdn.totvs.com/pages/releaseview.action?pageId=574364993
*/

User Function EICDI154() 
Local cParam:= ""
Local aArea := GETAREA()
Local nI

Private valDesp 
  
   If Type("ParamIXB") == "A"
      cParam:= ParamIXB[1]
   ElseIf Type("ParamIXB") == "C"
      cParam:= ParamIXB
   EndIf
   cParam:= Upper(cParam)     

   IF cParam == "ALTERA_CALC_IMPOSTOS_2"

        /*
        ICMS BASE: CIF + IMPOSTOS FEDERAIS + TX SISCOMEX / 0,83
        250.786,48 + 28.088,09 + 9.063,42 + 5.266,52+ 24.200,90 + 154,23 / 0,83 = 382.601,97

                (     CIF     )    ( II + IPI + PIS + COFINS )    ( SISCOMEX / 0.83)
        IATAN.: 101 + 102 + 103  +   403 + 404 + 405 + 406     +  ( 419 / 0.83 ) --> BASE ICMS*/

        // ALTERA CALCULO DE IMPOSTOS
        IF CFILANT == '0101'
            
            //POSICIONO NO SB1 AFIM DE PEGAR O NCM
            POSICIONE("SB1", 1, XFILIAL("SB1")+Work1->WKCOD_I , "B1_POSIPI") //SB1->(DBseek(xFilial() + Work1->WKCOD_I))
            POSICIONE("SYD", 1, XFILIAL("SYD")+SB1->B1_POSIPI, "YD_TEC")

            //RECALCULA BASE E VALOR DE PIS
            Work1->WKBASPIS := Work1->WKCIF
            Work1->WKVLRPIS := ( Work1->WKCIF * (SYD->YD_PER_PIS / 100) )

            //RECALCULA BASE E VALOR DE COFINS
            Work1->WKBASCOF := Work1->WKCIF
            Work1->WKVLRCOF := ( Work1->WKCIF * (SYD->YD_PER_COF / 100) )

            //RECALCULA ICMS
            Work1->WKBASEICMS := ( Work1->WKIIVAL + Work1->WKVLRPIS + Work1->WKVLRCOF + Work1->WKTXSIRATI + Work1->WKIPIVAL + Work1->WKCIF ) / 0.82
            //Work1->WKVL_ICM := MDI_CIF + Work1->WKIIVAL + Work1->WKIPIVAL + NVALAFRMM/*Work1->WKVLRPIS*/ + Work1->WKVLRCOF + ( NTXSISC / 0.83 ) 
            //Work1->WKVL_ICM := MDI_CIF + Work1->WKIIVAL + Work1->WKIPIVAL + Work1->WKVLRPIS + Work1->WKVLRCOF + ( NTXSISC / 0.83 )  --> ULTIMO VALOR VALIDADO
            Work1->WKVL_ICM := ( Work1->WKBASEICMS * ( SYD->YD_ICMS_RE / 100 )  )
        ENDIF

   ENDIF
   
   //PONTO GRVWORK_3 SERVE PARA RECALCULAR OS ITENS QUANDO CLICAMOS NO BOTÃO "COMPLEMENTAR"
   IF cParam == "GRVWORK_3"
      // ALTERA CALCULO DE IMPOSTOS
      IF CFILANT == '0101'
         
         totalDespesas := MDI_OUTR
         somaICMSIPI    := 0
         
         FOR nI := 1 to LEN(aDespesa)
            IF aDespesa[nI][1] == "407" .OR. aDespesa[nI][1] == "423" // ICMS e IPI
               somaICMSIPI := somaICMSIPI + aDespesa[nI][2]
            ENDIF
         NEXT

         //RECALCULA VALORES NA PRIMEIRA TELA
         Work2->(DBGOTOP())
         DO WHILE  Work2->(!EOF())
            
            percentual := ((Work2->WKOUTRDESP*100)/totalDespesas) // percentual que representa o valor do item em relação ao total das despesas
            Work2->WKOUTRDESP := Work2->WKOUTRDESP - ROUND(( somaICMSIPI * percentual )/100, 2)
            
            Work2->(DBSKIP())

         ENDDO

         MDI_OUTR := MDI_OUTR - somaICMSIPI

         //RECALCULA VALORES PARA APARECER CORRETAMENTE QUANDO CLICAMOS EM "ITEM"
         Work1->(DBGOTOP())
         DO WHILE  Work1->(!EOF())

            percentual := ((Work1->WKOUT_DESP*100)/totalDespesas) // percentual que representa o valor do item em relação ao total das despesas
            Work1->WKOUT_DESP := Work1->WKOUT_DESP - ( somaICMSIPI * percentual )/100
            Work1->WKVALMERC  := Work1->WKVALMERC - ( somaICMSIPI * percentual )/100
            Work1->WKPRUNI    := Work1->WKOUT_DESP / Work1->WKQTDE

            Work1->(DBSKIP())

         ENDDO


      ENDIF
   ENDIF

   RESTAREA( aArea )

Return
