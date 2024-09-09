#include "TOTVS.CH"

User Function MT410TOK()

Local aArea       := GetArea()
Local aAreaSC5    := SC5->(GetArea())
Local aAreaSC6    := SC6->(GetArea())
Local aAreaSB2    := SB2->(GetArea())
Local lRet   	  := .T. 
Local __cPedCli	  := M->C5_PEDCLI
Local nPosPCli    :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_PEDCLI" } )
Local nY

// Iatan em 25/10/2022
Local nX
Local nPosArmz    :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_LOCAL" } )
Local nPosOper    :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_OPER" } )
Local nPosPrcVen  :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_PRCVEN" } )
Local nPosPrUnit  :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_PRUNIT" } )
Local nPosValor   :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_VALOR" } )
Local nPosTES     :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_TES" } )
Local nPosDes     :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_VLDESMA" } )
Local nPosPDes    :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_DESCOMA" } )
Local nPosProd    :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" } )
Local nPosQtdV    :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_QTDVEN" } )
Local nPosComis   :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_COMIS1" } )
Local encontrou   := .F.
Local temp


IF INCLUI .or. ALTERA
	For nY := 1 to Len(aCols)
		aCols[ nY ,nPosPCli ]:=__cPedCli
	Next
	
Endif

//IATAN EM 25/10/2022
IF !isBlind() .AND. (INCLUI .OR. ALTERA)
	For nX := 1 to Len(aCols)
		IF aCols[ nX, nPosOper ] $ "05-06-11" .AND. aCols[ nX, nPosArmz ] <> "03"
			aCols[ nX, nPosArmz ] := "03"
			encontrou := .T.
			
			IF aCols[ nX, nPosTES ] $  GETMV( "ES_GTESCUS")
				aCols[ nX, nPosPrcVen ] := U_FCUSXVEN( aCols[ nX, nPosTES  ], aCols[ nX, nPosProd ],"01",M->C5_TABELA)
				aCols[ nX, nPosValor  ] := U_FCUSVENG( aCols[ nX, nPosQtdV ], aCols[ nX, nPosPrcVen ])
				aCols[ nX, nPosDes    ] := aCols[ nX, nPosPrUnit ] - aCols[ nX, nPosPrcVen ]
				aCols[ nX, nPosPDes   ] := ( aCols[ nX, nPosDes ] ) / aCols[ nX, nPosPrUnit ] * 100
				aCols[ nX, nPosComis  ] := U_MAHG010(M->C5_VEND1)

				//Iatan em 31/10/2022 - a pedido do Eder
				aCols[ nX, nPosPrUnit ] := aCols[ nX, nPosPrcVen ]
			ENDIF
		ENDIF		
	Next
	IF encontrou == .T.
		IF !isBlind()
			FWAlertSuccess("Alterado armazem para '03' com Sucesso.")
		ENDIF
	ENDIF 
Endif


	//IATAN EM 01/11/2022 - SOLICITAÇÃO DO EDER
	//Está fora do IF acima pois esta condição tambem deve ser aplicada para 
	
IF INCLUI .OR. ALTERA
	For nX := 1 to Len(aCols)
		IF aCols[ nX, nPosOper ] $ "04" .AND. aCols[ nX, nPosDes ] == 0
			aCols[ nX, nPosPrcVen ] := U_FCUSXVEN( aCols[ nX, nPosTES  ], aCols[ nX, nPosProd ],"01",M->C5_TABELA)
			aCols[ nX, nPosValor  ] := U_FCUSVENG( aCols[ nX, nPosQtdV ], aCols[ nX, nPosPrcVen ])
			aCols[ nX, nPosDes    ] := aCols[ nX, nPosPrUnit ] - aCols[ nX, nPosPrcVen ]
			aCols[ nX, nPosPDes   ] := ( aCols[ nX, nPosDes ] ) / aCols[ nX, nPosPrUnit ] * 100
			aCols[ nX, nPosComis  ] := U_MAHG010(M->C5_VEND1)

			//Iatan em 31/10/2022 - a pedido do Eder
			aCols[ nX, nPosPrUnit ] := aCols[ nX, nPosPrcVen ]
		ENDIF
	Next
ENDIF

// IATAN EM 23/04/2024
IF INCLUI .OR. ALTERA
	For nX := 1 to Len(aCols)
		IF aCols[ nX, nPosOper ] $ "60" 
			//A PEDIDO DE EDER EM 23/04/2024.:
			// - QUANDO FOR OPERAÇÃO 60 DEVEMOS SEMPRE ESTAR NO ARMAZEM 03 E BUSCAR O CM1 DO ARMAZEM 03
			IF aCols[ nX, nPosArmz ] <> "03"
				aCols[ nX, nPosArmz ] := "03"
			ENDIF
			POSICIONE("SB2",1, xFilial("SB2") + aCols[ nX, nPosProd ] + "03", "B2_CM1")
			aCols[ nX, nPosPrcVen ] := SB2->B2_CM1
			aCols[ nX, nPosValor  ] := SB2->B2_CM1 * aCols[ nX, nPosQtdV ]
			aCols[ nX, nPosDes    ] := aCols[ nX, nPosPrUnit ] - aCols[ nX, nPosPrcVen ]
			aCols[ nX, nPosPDes   ] := ( aCols[ nX, nPosDes ] ) / aCols[ nX, nPosPrUnit ] * 100
			aCols[ nX, nPosComis  ] := 0
			aCols[ nX, nPosPrUnit ] := SB2->B2_CM1
		ENDIF
	Next
ENDIF


RestArea( aArea )
RestArea( aAreaSC5 )
RestArea( aAreaSC6 )
RestArea( aAreaSB2 )

Return(lRet)

