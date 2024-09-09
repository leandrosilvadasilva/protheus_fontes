
#Include "Protheus.ch"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAAVCRED ³ Autor ³ Ednei R. Silva        ³ Data ³ MAI/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada personalizacao analise de credito.        ³±±
±±³          ³                    .                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³															              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MAAVCRED()
Local aArea      := GetArea()
Local aAreaSC5   := GetArea("SC5")
Local aAreaSC6   := GetArea("SC6")
Local aAreaSF4   := GetArea("SF4")
Local lRet       := .T.
Local cCND       := SuperGetMV("ES_CNDNLIB") // Paramtro que contem condicoes de pagamentos que nao podem ser liberadas automaticamente
Local cTES       := SuperGetMV("ES_TESINV") // Paramtro que contem Tipo de Saida(TES REMESSA) que nao podem ser liberadas automaticamente
Local cCodCli    := PARAMIXB[1]
Local cLoja      := PARAMIXB[2]
Local nValor     := PARAMIXB[3]
Local nMoeda     := PARAMIXB[4]
Local lPedido    := PARAMIXB[5]
Local cCodigo    := {}
Local aEmpenho   := {}
Local nVlrCred   := 0
Local nVlAdicCre := 0
Local aValdet    := {}
Local cConsig    := "F"

Local cPessoa    := " "

Local lOnAVCredLINX := SuperGetMV( "ES_LINXAVC", .F., .F. )


//--------------------------------------------------------

// Posicionando na tabela de TES para pegar o F4_DUPLIC

//--------------------------------------------------------
DbSelectArea("SF4") 
dbSetOrder(1)
SF4->( dbSeek(xFilial('SF4') + SC6->C6_TES) )

IF (SC6->C6_TES $ cTES )
   cConsig      :="T"
Endif

IF (SC6->C6_TES $ cTES ) .Or. (SF4->F4_DUPLIC = "S")


    
    //----------------------------------------------------------------
    // Rotina padrao de avaliacao de credito com ajuste A1_LC+A1_ZLCREM
    // A1_LC = Limeite de credito padrao
    // A1_ZLCREM = Limite de credito Remessa consignado
    // Codigo do Cliente                                    
    // ExpC2: Loja do Cliente                                      
    // ExpN3: Valor a ser avaliado                                
    // ExpN4: Moeda do valor a ser avaliado                        
    // ExpL5: Considera acumulados de Pedido de Venda do SA1       
    // ExpC6: Codigo do Bloqueio.                                  
    // ExpC7: aEmpenho                                            
    // ExpN8: Valor a ser adicionado ao limite de credito          
    // ExpN9: Valor adicional de credito 
    //----------------------------------------------------------------
    lRet:= AvlCrd(cCodCli,cLoja,nValor,nMoeda,lPedido,cCodigo,aEmpenho,nVlrCred,nVlAdicCre,aValdet)
    
    //----------------------------------------------------------------
    // Regra condicao de pagamento MA Hospitalar
    // Todas as condicoe que estiveram no paramentro devem bloquear o 
    // pedido ES_CNDNLIB
    //----------------------------------------------------------------
    
    IF (SC5->C5_CONDPAG $ cCND) .and. (cConsig="F")
       lRet     := .F.
    Endif

	IF (SC5->C5_FORPG ='CC')
       lRet     := .F.
    Endif
    
    IF SC5->C5_NATUREZ $ '111102|111214'
       lRet     := .T.
    Endif
    
 Endif   
        
    RestArea(aArea)
    RestArea(aAreaSC5)
    RestArea(aAreaSC6)
    RestArea(aAreaSF4)

	// Fiz depois da restauração das areas pra garantir a tomada de decisao
	If lOnAVCredLINX  
	
		If FWIsInCallStack( "MAWSLNX20" )  .or.  FWIsInCallStack( "U_MAWSLNX20" )

			cPessoa := GetAdvFVal( "SA1", "A1_PESSOA", FWxFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI), 1, "J" )
			IF cPessoa == "F"  
		
				lRet := .T.
			EndIf

			VarInfo( "lRet", lRet )
			VarInfo( "cPessoa", cPessoa )
		EndIf
	EndIf
	
Return lRet

static Function AvlCrd(cCodCli,cLoja,nValor,nMoeda,lPedido,cCodigo,aEmpenho,nVlrCred,nVlAdicCre,aValdet)
Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local aStruSA1 := {}
Local cTipoLim := SuperGetMv("MV_CREDCLI")
Local cQuery   := ""
Local cAliasSE1:= "SE1"
Local cAliasSA1:= "SA1"
Local cAliasQry:= ""
Local nLimCred := 0
Local nLimCredFin := 0
Local nVlrReal := xMoeda(nValor,nMoeda,1,dDataBase,2)
Local nVlrFin  := 0
Local nVlrPed  := nVlrReal
Local nLiminCr := SuperGetMv("MV_LIMINCR")  //Limite Minimo de Credito
Local nPerMax  := SuperGetMv("MV_PERMAX")   //Percentual Maximo comprometido com o Limite de Credito
Local nFaixaA  := SuperGetMv("MV_PEDIDOA")  //Limite de Credito para a Faixa A
Local nFaixaB  := SuperGetMv("MV_PEDIDOB")  //Limite de Credito para a Faixa B
Local nFaixaC  := SuperGetMv("MV_PEDIDOC")  //Limite de Credito para a Faixa C
Local nNumDias := 0
Local nRegEmp  := 0
Local nMCusto  := 0
Local nX       := 0
//Local lMaAvCred:= ExistBlock("MAAVCRED")
//Local lMaAvCrPr:= ExistBlock("MAAVCRPR")
Local lQuery   := .F.
Local lRetorno := .T.
Local lCredito := .F.
Local lTitVenc := .F. 
Local xRetorno := ""
Local cPerEmal :=""

#IFDEF TOP 
	Local cSepNeg   := If("|"$MV_CRNEG,"|",",")
	Local cSepProv  := If("|"$MVPROVIS,"|",",")
	Local cSepRec   := If("|"$MVRECANT,"|",",")
#ENDIF

Local lIntGC	 := IIf((SuperGetMV("MV_VEICULO",,"N")) == "S",.T.,.F.)

DEFAULT nVlrCred   := 0
DEFAULT nVlAdicCre := 0
DEFAULT aValdet	:= {} // [cCodigo[lCredito,lTitVenc]] Detalha o tipo de bloqueio por credito (Credito,TÌtulo)

dbSelectArea("SA1")
dbSetOrder(1)
//If ( SuperGetMv("MV_BLOQUEI" ) .And. !lMaAvCred )
If ( SuperGetMv("MV_BLOQUEI" ) )
	Do Case
		//-----------------------------------------------------------------------------
		// Aqui e Verificado o Cliente Por Codigo + Loja                           
		//-----------------------------------------------------------------------------
	Case ( cTipoLim=="L" )
		If ( MsSeek(xFilial("SA1")+cCodCli+cLoja) )
			If ( SA1->A1_RISCO == "A" )
				lRetorno := .T.
			EndIf
			If ( SA1->A1_RISCO == "E" .And. nVlrCred<=0)
				lRetorno := .F.
				cCodigo  := "01" // Limite de Credito
				lCredito := .T.
				
			EndIf
			If ( SA1->A1_RISCO == "Z" .And. nVlrCred<=0)
				SerSolLbCR()
				lRetorno := .F.
				cCodigo  := "01" // Limite de Credito
				lCredito := .T.
			Else
				If SerSolLbCR()
					cCodigo  := "04" //Vencimento do Limite de Credito
					lRetorno := .F.
				EndIf
			EndIf
			//-----------------------------------------------------------------------------
			// Aqui e avaliado o Vencimento do Limite de Credito do Cliente            
			//-----------------------------------------------------------------------------
			If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase ) .And. nVlrCred <= 0
				cCodigo  := "04" //Vencimento do Limite de Credito
				lRetorno := .F.
				lCredito := .T.
			EndIf
			If ( SA1->A1_RISCO <> "A" .And. !(SA1->A1_RISCO $ "E,Z" .And. nVlrCred<=0) .And. lRetorno)
				//-----------------------------------------------------------------------------
				// Aqui e verificado o Limite de Credito do Cliente + Loja                  
				//-----------------------------------------------------------------------------
				//-----------------------------------------------------------------------------
				// O Limite de Credito sempre esta na Moeda MV_MCUSTO, mas os calculos sao  
				// em na moeda corrente.                                                   
				//-----------------------------------------------------------------------------
				nMCusto	 := IIf(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(SuperGetMv("MV_MCUSTO")))
				nVlrCred := xMoeda(nVlrCred,nMoeda,1,dDataBase,2)
				If SA1->A1_RISCO$"E,Z"
					nLimCred := 0
				Else
					nLimCred := xMoeda(SA1->A1_LC+SA1->A1_ZLCREM,nMCusto,1,dDataBase,2)
				EndIf
				//-----------------------------------------------------------------------------
				// Adicional de CrÈdito quando utilizado o 9o Par‚metro							
				//-----------------------------------------------------------------------------
				If nVlAdicCre > 0 .and. lIntGC // Modulo de Concession·rias
					nLimCred += nVlAdicCre
				Endif
				//-----------------------------------------------------------------------------
				// Verifica se o Valor nao eh maior que o Limite de Credito                
				//-----------------------------------------------------------------------------
				If ( lPedido )
					If nVlrCred < nVlrReal
						nVlrReal += SA1->A1_SALDUP + xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDatabase,2)
					Else
						nVlrReal += SA1->A1_SALDUP + xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDatabase,2)
						nLimCred += nVlrCred
					EndIf
					If ( aEmpenho <> Nil ) .And. ( !Empty(aEmpenho) )
						nRegEmp  := aScan(aEmpenho[1],{|x| x[1]==SA1->(RecNo())})
						If ( nRegEmp <> 0 )
							nVlrReal += xMoeda(aEmpenho[1][nRegEmp][2],nMCusto,1,dDatabase,2)
						EndIf
					EndIf
				EndIf
				If ( nVlrReal > nLimCred .And. nVlrReal > 0)
					cCodigo  := "01" // Limite de Credito
					lRetorno := .F.
					lCredito := .T.
				EndIf
				//-----------------------------------------------------------------------------
				// Controle de limite de credito secundario                                
				//-----------------------------------------------------------------------------
				If SA1->A1_RISCO $ "E,Z"
					nLimCredFin	:= xMoeda(SA1->A1_LCFIN,nMCusto,1,dDataBase,MsDecimais(1))
				Else
					nLimCredFin := 0
				EndIf
				If ( aEmpenho <> Nil ) .And. ( !Empty(aEmpenho) )
					nRegEmp  := aScan(aEmpenho[1],{|x| x[1]==SA1->(RecNo())})
					If ( nRegEmp <> 0 )
						nLimCredFin -= aEmpenho[1][nRegEmp][3]
					EndIf
				EndIf				
				If SA1->A1_SALFIN > nLimCredFin .And. SA1->A1_LCFIN > 0
					cCodigo 	:= "01" // Limite de Credito
					lRetorno := .F.
					lCredito := .T.
				EndIf
				//-----------------------------------------------------------------------------
				// Verifica as Classes de Cliente                                          
				//-----------------------------------------------------------------------------
				If nVlrReal > 0
					Do Case
					Case ( nVlrReal <= nLiMinCr )
						lRetorno := .T.
						cCodigo  := ""
						lCredito := .T.
					Case ( nVlrReal > ((nPerMax * nLimCred) / 100) )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito
						lCredito := .T.		
					Case ( SA1->A1_CLASSE == "A" .And. nVlrPed > nfaixaA .And. nFaixaA <> 0 )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito
						lCredito := .T.
					Case ( SA1->A1_CLASSE == "B" .And. nVlrPed > nfaixaB .And. nFaixaB <> 0 )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito
						lCredito := .T.
					Case ( SA1->A1_CLASSE == "C" .And. nVlrPed > nfaixaC .And. nFaixaC <> 0 )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito
						lCredito := .T.
					EndCase
					//-----------------------------------------------------------------------------
					// Aqui e verificado o Grau de Risco do Cliente + Loja                     
					//-----------------------------------------------------------------------------
					If ( lRetorno .And. !Empty(SA1->A1_RISCO) .And. !SA1->A1_RISCO$"E,Z")
						nNumDias := SuperGetMv("MV_RISCO"+SA1->A1_RISCO)
						dbSelectArea("SE1")
						dbSetOrder(8)
						#IFDEF TOP
							lQuery    := .T.
							cAliasSE1 := "MAAVALCRED"

							cQuery    := "SELECT MIN(E1_VENCREA) VENCREAL "
							cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
							cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
							cQuery    += "SE1.E1_CLIENTE='"+cCodCli+"' AND "
							cQuery    += "SE1.E1_LOJA='"+cLoja+"' AND "
							cQuery    += "SE1.E1_STATUS='A' AND "												
							cQuery    += "SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "	                    
							cQuery    += "SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
							cQuery    += "SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
							cQuery    += "SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  + " AND "							
							cQuery    += "SE1.D_E_L_E_T_=' ' "


							cQuery := ChangeQuery(cQuery)

							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)

							TcSetField(cAliasSE1,"VENCREAL","D",8,0)
							
							If (cAliasSE1)->(!Eof()) .And. !Empty((cAliasSE1)->VENCREAL) .And. (dDataBase - (cAliasSE1)->VENCREAL) >= nNumDias
								lRetorno := .F.
								cCodigo  := "01" // Limite de Credito
								lTitVenc := .T.
							EndIf

							dbSelectArea(cAliasSE1)
							dbCloseArea()
							dbSelectArea("SE1")
							
						#ELSE
							MsSeek(xFilial("SE1")+cCodCli+cLoja+"A")


							While ( !Eof() .And. (cAliasSE1)->E1_FILIAL == xFilial("SE1") .And.;
									(cAliasSE1)->E1_CLIENTE == cCodCli .And.;
									(cAliasSE1)->E1_LOJA  == cLoja .And.;
									(cAliasSE1)->E1_STATUS == "A" )
								If ( !(cAliasSE1)->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !(cAliasSE1)->E1_TIPO$MVABATIM )
									If ( ( dDataBase - (cAliasSE1)->E1_VENCREA ) >= nNumDias )
										lRetorno := .F.
										cCodigo  := "01" // Limite de Credito
										lTitVenc := .T.
									EndIf
									//-------------------------------------------------------------
									// Aqui o Loop eh abortado pois esta em ordem de vencto Real 
									//----------------------------------------------------------
									Exit
								EndIf
								dbSelectArea(cAliasSE1)
								dbSkip()
							EndDo
						#ENDIF									
					EndIf
				EndIf
			EndIf
		EndIf
		//-----------------------------------------------------------------------------
		// Aqui e verificado apenas o Codigo ( Matriz )                            
		//-----------------------------------------------------------------------------
	Case ( cTipoLim == "C" )
		If ( MsSeek(xFilial("SA1")+cCodCli) )
			//------------------------------------------------------------------
			//  O Grau de Risco deve ser Avaliado da Matriz                   
			//---------------------------------------------------------------
			If ( SA1->A1_RISCO == "A" )
				lRetorno := .T.
				cCodigo  := ""
			EndIf
			If ( SA1->A1_RISCO == "E"  .And. nVlrCred<=0)
				lRetorno := .F.
				cCodigo  := "01" // Limite de Credito
				lCredito := .T.
			EndIf
			If ( SA1->A1_RISCO == "Z" .And. nVlrCred<=0)
				SerSolLbCR()			
				lRetorno := .F.
				cCodigo  := "01" // Limite de Credito
				lCredito := .T.
			Else
				SerSolLbCR()
			EndIf
			//-----------------------------------------------------------------------------
			// Aqui e avaliado o Vencimento do Limite de Credito do Cliente            
			//-----------------------------------------------------------------------------
			If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase )
				lRetorno := .F.
				cCodigo  := "04" // Vencimento do Limite de Credito
			EndIf
			//-----------------------------------------------------------------------------
			// Aqui e verificado o Limite de Credito do Cliente                        
			//-----------------------------------------------------------------------------
			//-----------------------------------------------------------------------------
			// O Limite de Credito sempre esta na Moeda MV_MCUSTO, mas os calculos sao 
			// em na moeda corrente.                                                   
			//-----------------------------------------------------------------------------
			If ( SA1->A1_RISCO <> "A" .And. !(SA1->A1_RISCO $ "E,Z" .And. nVlrCred<=0) .And. lRetorno )
				nLimCred := 0
				nLimCredFin	:= 0	
				dbSelectArea("SA1")
				dbSetOrder(1)				
				#IFDEF TOP
					cAliasSA1 := "QRYSA1"
					lQuery    := .T.

					aStruSa1  := SA1->(dbStruct())

					cQuery := "SELECT A1_FILIAL,A1_COD,A1_MOEDALC,(A1_ZLCREM+A1_LC) A1_LC,A1_LCFIN,A1_SALFIN,A1_SALDUP,A1_SALPEDL,A1_VENCLC,A1_RISCO,R_E_C_N_O_ RECSA1 "
					cQuery += " FROM "+RetSqlName("SA1")+" SA1 "
					cQuery += "WHERE "
					cQuery += "A1_FILIAL = '"+xFilial("SA1")+"' AND "
					cQuery += "A1_COD = '"+cCodCli+"' AND "
					cQuery += "SA1.D_E_L_E_T_ = ' ' "
					cQuery += "ORDER BY "+SqlOrder(SA1->(IndexKey()))					

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1,.T.,.T.)

					For nX := 1 To Len(aStruSA1)
						If aStruSA1[nX,1]$"A1_FILIAL,A1_COD,A1_MOEDALC,A1_LC,A1_LCFIN,A1_SALFIN,A1_SALDUP,A1_SALPEDL,A1_VENCLC"						
							If aStruSA1[nX,2] <> "C" .And. FieldPos(aStruSA1[nX,1])<>0
								TcSetField(cAliasSA1,aStruSA1[nX,1],aStruSA1[nX,2],aStruSA1[nX,3],aStruSA1[nX,4])
							EndIf						
						EndIf
					Next nX

				#ELSE
					MsSeek(xFilial("SA1")+cCodCli)
				#ENDIF
				nMCusto	:= IIf((cAliasSA1)->A1_MOEDALC > 0,(cAliasSA1)->A1_MOEDALC,Val(SuperGetMv("MV_MCUSTO")))
				nVlrCred := xMoeda(nVlrCred,nMoeda,1,dDataBase,2)
				nLimCred := 0
				While ( !Eof() .And. xFilial("SA1") == (cAliasSA1)->A1_FILIAL .And.;
						cCodCli == (cAliasSA1)->A1_COD    .And.;
						lRetorno)
					If !(cAliasSA1)->A1_RISCO$"E,Z"
						nLimCred += xMoeda((cAliasSA1)->A1_LC,nMCusto,1,dDataBase,2)
					Else
						nLimCred := 0
					EndIf
					If (cAliasSA1)->A1_LCFIN >= 0
						nLimCredFin	+= xMoeda((cAliasSA1)->A1_LCFIN,nMCusto,1,dDataBase,MsDecimais(1))
						nVlrFin 	+= (cAliasSA1)->A1_SALFIN
					EndIf	
					If ( lPedido )
						If nVlrCred < nVlrReal
							nVlrReal += (cAliasSA1)->A1_SALDUP + xMoeda((cAliasSA1)->A1_SALPEDL,nMCusto,1,dDatabase,2)
						Else
							nVlrReal += SA1->A1_SALDUP + xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDatabase,2)
							nLimCred += nVlrCred
						EndIf
						If ( aEmpenho <> Nil ) .And. ( !Empty(aEmpenho) )
							nRegEmp  := aScan(aEmpenho[1],{|x| x[1]==IIf(lQuery,(cAliasSA1)->RECSA1,SA1->(RecNo())) })
							If ( nRegEmp <> 0 )
								nVlrReal += xMoeda(aEmpenho[1][nRegEmp][2],nMCusto,1,dDatabase,2)
							EndIf
							If ( nRegEmp <> 0 )
								nVlrFin += aEmpenho[1][nRegEmp][3]
							EndIf
						EndIf
					EndIf
					//-----------------------------------------------------------------------------
					// Aqui e avaliado o Vencimento do Limite de Credito do Cliente            
					//-----------------------------------------------------------------------------
					If ( !Empty((cAliasSA1)->A1_VENCLC) .And. (cAliasSA1)->A1_VENCLC < dDataBase ) .And. nVlrCred <= 0
						lRetorno := .F.
						cCodigo  := "04" // Vencimento do Limite de Credito
					EndIf
					dbSelectArea(cAliasSA1)
					dbSkip()
				EndDo
				If lQuery
					dbSelectArea(cAliasSA1)
					dbCloseArea()
					dbSelectArea("SA1")
				Endif
				//-----------------------------------------------------------------------------
				// Adicional de CrÈdito quando utilizado o 9o Par‚metro							
				//-----------------------------------------------------------------------------
				If nVlAdicCre > 0 .and. lIntGC // Modulo de Concession·rias
					nLimCred += nVlAdicCre
				Endif
				//-----------------------------------------------------------------------------
				// Verifica se o Valor nao eh maior que o Limite de Credito                
				//-----------------------------------------------------------------------------
				If ( lRetorno .And. nVlrReal > nLimCred .And. nVlrReal > 0)
					lRetorno := .F.
					cCodigo  := "01" // Limite de Credito
					lCredito := .T.
				EndIf
				//-----------------------------------------------------------------------------
				// Controle de limite de credito secundario                                
				//-----------------------------------------------------------------------------
				If lRetorno .And. nVlrFin > nLimCredFin .And. nLimCredFin > 0
					cCodigo 	:= "01" // Limite de Credito
					lRetorno := .F.
					lCredito := .T.
				EndIf
				//-----------------------------------------------------------------------------
				// Verifica as Classes de Cliente                                          
				//-----------------------------------------------------------------------------
				If nVlrReal > 0
					dbSelectArea("SA1")
					dbSetOrder(1)
					MsSeek(xFilial("SA1")+cCodCli)
					Do Case
					Case ( lRetorno .And. nVlrReal <= nLiMinCr )
						lRetorno := .T.
						cCodigo  := ""
					Case ( lRetorno .And. nVlrReal > ((nPerMax * nLimCred) / 100) )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito.
						lCredito := .T.
					Case ( lRetorno .And. SA1->A1_CLASSE == "A" .And. nVlrPed > nfaixaA .And. nFaixaA <> 0 )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito
						lCredito := .T.		
					Case ( lRetorno .And. SA1->A1_CLASSE == "B" .And. nVlrPed > nfaixaB .And. nFaixaB <> 0 )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito
						lCredito := .T.
					Case ( lRetorno .And. SA1->A1_CLASSE == "C" .And. nVlrPed > nfaixaC .And. nFaixaC <> 0 )
						lRetorno := .F.
						cCodigo  := "01" // Limite de Credito
						lCredito := .T.
					EndCase
					//----------------------------------------------------------------
					//  Aqui e avaliado o risco do Cliente - ( Matriz + Filiais )   
					//-------------------------------------------------------------
					If ( lRetorno .And. !Empty(SA1->A1_RISCO) .And. !SA1->A1_RISCO$"E,Z" )						
						#IFDEF TOP
							dbSelectArea("SE1")
							dbSetOrder(8)

							cAliasQry  := "QRYAVALCRD"
							lQuery     := .T.

							cQuery := "SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_RISCO,E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_TIPO,E1_VENCREA"
							cQuery += " FROM "+RetSqlName("SA1")+" SA1, "
							cQuery += RetSqlName("SE1")+" SE1 "
							cQuery += "WHERE "
							cQuery += "A1_FILIAL ='"+xFilial("SA1")+"' AND "
							cQuery += "A1_COD = '"+cCodCli+"' AND "
							cQuery += "SA1.D_E_L_E_T_ = ' ' AND "												
							cQuery += "E1_FILIAL = '"+xFilial("SE1")+"' AND "
							cQuery += "E1_CLIENTE = A1_COD AND "
							cQuery += "E1_LOJA = A1_LOJA AND "
							cQuery += "E1_STATUS = 'A' AND "
							cQuery += "SE1.D_E_L_E_T_ = ' ' "
							cQuery += "ORDER BY "+SqlOrder(StrTran(SE1->(IndexKey()),"E1_LOJA+",""))

							cQuery := ChangeQuery(cQuery)

							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

							TcSetField(cAliasQry,"E1_VENCREA","D",8,0)

							While (cAliasQry)->(!Eof()) .And. lRetorno
								If !Empty((cAliasQry)->A1_RISCO)
									nNumDias := SuperGetMv("MV_RISCO"+(cAliasQry)->A1_RISCO)
								Else
									If (cAliasQry)->A1_LOJA <> "01"
										Aviso("LOJA","Atencao necessario que o cliente e loja estejam com configuracoees de risco conforme outras lojas",{"Cancelar","Sair"},2)
										lRetorno := .F.
										cCodigo  := "01" // Limite de Credito
										Exit
									EndIf
								EndIf
								If ( !(cAliasQry)->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !(cAliasQry)->E1_TIPO $ MVABATIM)
									If ( ( dDataBase - (cAliasQry)->E1_VENCREA ) >= nNumDias )
										lRetorno := .F.
										cCodigo  := "01" // Limite de Credito
										lTitVenc := .T.
										
									EndIf
									Exit
								EndIf

								dbSelectArea(cAliasQry)
								dbSkip()

							EndDo
							If lQuery
								dbSelectArea(cAliasQry)
								dbCloseArea()
								dbSelectArea("SA1")
							EndIf
						#ELSE
							dbSelectArea("SA1")
							dbSetOrder(1)
							MsSeek(xFilial("SA1")+cCodCli)
							While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
									cCodCli        == SA1->A1_COD )
								If !Empty(SA1->A1_RISCO)
									nNumDias := SuperGetMv("MV_RISCO"+SA1->A1_RISCO)						
								EndIf
								dbSelectArea("SE1")
								dbSetOrder(8)
								MsSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA+"A")
								While ( !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And.;
										SE1->E1_CLIENTE== SA1->A1_COD .And.;
										SE1->E1_LOJA   == SA1->A1_LOJA .And.;
										SE1->E1_STATUS == "A" )
									If ( !SE1->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !SE1->E1_TIPO $ MVABATIM)
										If ( ( dDataBase - SE1->E1_VENCREA ) >= nNumDias )
											lRetorno := .F.
											cCodigo  := "01" // Limite de Credito
											lTitVenc := .T.
											
										EndIf
										Exit
									EndIf
									dbSelectArea("SE1")
									dbSkip()
								EndDo
								If ( !lRetorno )
									Exit
								EndIf
								dbSelectArea("SA1")
								dbSkip()
							EndDo
						#ENDIF			
					EndIf
				EndIf
			EndIf
		EndIf
	EndCase

EndIf
//-----------------------------------------------------------------------------
// Carrega o Array de detalhes da avaliacao de credito                     
//-----------------------------------------------------------------------------
If !Empty( cCodigo ) 
	Do Case
		Case cCodigo == "01"         
			aAdd( aValDet, {cCodigo,{ lCredito, lTitVenc } } ) //Codigo do bloqueio [Bloqueio Credito][Bloqueio por titulo atrasado]  
		Case cCodigo == "04"
			aAdd( aValDet, {cCodigo, {} } )
	EndCase	
EndIf
//IF ( nVlrReal > (( nLimCred*75) / 100) ) .and. (nLimCred>0) .and. (nVlrReal>0)
//   cPerEmal:=""
//   cPerEmal:=TRANSFORM((nVlrReal/nLimCred)*100, "@E 999.99") 
//   u_EmailFin(cCodCli,cLoja,cPerEmal)
//Endif
//-----------------------------------------------------------------------------
// Restaura a Entrada da Rotina                                            
//-----------------------------------------------------------------------------
RestArea(aAreaSA1)
RestArea(aAreaSE1)
RestArea(aArea)
Return( lRetorno )




