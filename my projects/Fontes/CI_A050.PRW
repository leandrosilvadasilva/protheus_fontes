#include "TOTVS.CH"
#include "rwmake.CH"
#INCLUDE "Protheus.ch"
/*
//------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CI_A050   ºAutor  ³CIRESULT		     º Data ³  03/29/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Especifico MA - Tratamento do Boleto		      	          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CI_A050(oDanfe)
//------------------------------------------------------------------
//Local oDanfe :=  PARAMIXB[1]

Local aAreaSEE := GetArea()
Local aAreaSF2 := GetArea()
Local aAreaSC5 := GetArea()
Local aAreaSD2 := GetArea()

//Pergunte("NFSIGW",.f.)           

Conout('CI_A050 - Geracao do Boleto')

aAreaSD2 := SD2->( GetArea() )
aAreaSC5 := SC5->( GetArea() )
aAreaSL1 := SL1->( GetArea() )
aAreaSEE := SEE->( GetArea() )

cAliasSF2 := GetNextAlias()
cQuery := " SELECT SF2.R_E_C_N_O_ ,F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_NFELETR,F2_FILIAL,F2_DUPL,F2_PREFIXO,F2_PDV,F2_COND"
cQuery += " FROM " + RetSqlName("SF2") + " SF2 " 
cQuery += " WHERE	F2_FILIAL  = '" + xFilial("SF2")  + "'"
cQuery += "   AND	F2_DOC BETWEEN ('" + MV_PAR01 + "') AND ('" + MV_PAR02 + "') "
cQuery += "   AND	F2_SERIE   = '" + MV_PAR03 + "'"
cQuery += "   AND	F2_DUPL    <> ' '"	// somente notas fiscais que geraram duplicata
cQuery += "   AND	SF2.D_E_L_E_T_ <> '*'"
cQuery += "   AND	F2_CHVNFE<>''" 
cQuery += " ORDER BY F2_DOC, F2_SERIE"

//MEMOWRIT('CI_A050.SQL',cQuery)   
Conout('CI_A050 - Query - '+cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF2, .F., .T.)
TcSetField( cAliasSF2, "F2_EMISSAO" , "D", 8, 0 )

While ( cAliasSF2 )->( !Eof() )
	
	//Buscando pedido
	dbSelectArea("SD2")
	dbSetOrder(3)
	MsSeek(xFilial("SD2")+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	If !MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)
		//MsgInfo("Pedido "+SD2->D2_PEDIDO+ " não encontrado ") 
		Conout('CI_A050 - Pedido '+SD2->D2_PEDIDO+' não encontrado')
		RestArea( aAreaSEE )
		RestArea( aAreaSC5 )
		RestArea( aAreaSD2 )
		RestArea( aAreaSF2 )
		Return
	ElseIf SC5->C5_FORPG <> 'BO'
		Conout('CI_A050 - Forma de pagamento diferente de BO - '+SC5->C5_FORPG)
		RestArea( aAreaSEE )
		RestArea( aAreaSC5 )
		RestArea( aAreaSD2 )
		RestArea( aAreaSF2 )
		Return
	Endif 
	
	/*
	dbSelectArea("SE4")
	dbSetOrder(1)//E4_FILIAL+E4_CODIGO
	If !dbSeek( xFilial("SE4") + SC5->C5_CONDPAG)
		MsgInfo("Condição de Pagamento "+SC5->C5_CONDPAG+ " não encontrado ")
		RestArea( aAreaSEE )
		RestArea( aAreaSC5 )
		RestArea( aAreaSD2 )
		RestArea( aAreaSF2 )
		Return
	End
	
	If !Alltrim(SE4->E4_FORMA) $ "BOL" 
		RestArea( aAreaSEE )
		RestArea( aAreaSC5 )
		RestArea( aAreaSD2 )
		RestArea( aAreaSF2 )
		Return
	End
	
	// Especifico para MA. Nao precisa da validacao abaixo pois a regra do banco esta fixada no fonte da DANFE
	
	If Empty(SC5->C5_BANCO	) 
		Alert("Condicao de Pagamento com impressao de BOLETO, mas Banco nao foi informado no Pedido de Venda !")
		RestArea( aAreaSEE )
		RestArea( aAreaSC5 )
		RestArea( aAreaSD2 )
		RestArea( aAreaSF2 )
		Return
	End
	*/
	
	aBcoBol:=Array(4)
	aTitBol:=Array(18)
	AFill( aBcoBol, " " )
	
	//busca as config bancarias a partir do banco do pedido
	//aBcoBol:=u_CIRG050SEE(SC5->C5_BANCO,aBcoBol)

	// Especifico para MA. Nao precisa da validacao abaixo pois a regra do banco esta fixada no fonte da DANFE
	aBcoBol:=u_CI_G050SEE(aBcoBol)


	////////////////////////////////////////////////////////////
	////Array com os Paramentros dos Titulos a Serem Impressos//
	////Manter essa Ordem:                                    //
	////01 - Prefixo Inicial                                  //
	////02 - Prefixo Final                                    //
	////03 - Titulo Inical                                    //
	////04 - Titulo Final                                     //
	////05 - Parcela Inicial                                  //
	////06 - Parcela Final                                    //
	////07 - Tipo Titulo Inicial                              //
	////08 - Tipo Titulo Final                                //
	////09 - Data Emissao Inicial                             //
	////10 - Data Emissao Final                               //
	////11 - Data Vencimento Real Inicial                     //
	////12 - Data Vencimento Real Final                       //
	////13 - Bordero Inicial                                  //
	////14 - Bordero Final                                    //
	////15 - Cliente Inicial                                  //
	////16 - Loja Inicial                                     //
	////17 - Cliente Inicial                                  //
	////18 - Loja Inicial                                     //
	////////////////////////////////////////////////////////////
		
	aTitBol[01] := ( cAliasSF2 )->F2_PREFIXO
	aTitBol[02] := ( cAliasSF2 )->F2_PREFIXO
	aTitBol[03] := ( cAliasSF2 )->F2_DUPL
	aTitBol[04] := ( cAliasSF2 )->F2_DUPL
	aTitBol[05] := ' '
	aTitBol[06] := 'ZZ'
	aTitBol[07] := ' '
	aTitBol[08] := 'ZZZ'
	aTitBol[09] := CToD('  /  /  ')
	aTitBol[10] := ( cAliasSF2 )->F2_EMISSAO + 3650 //SF2->F2_EMISSAO + 3650
	aTitBol[11] := CToD('  /  /  ')
	aTitBol[12] := ( cAliasSF2 )->F2_EMISSAO + 3650 //SF2->F2_EMISSAO + 3650
	aTitBol[13] := ""
	aTitBol[14] := "ZZZZZZ"
	aTitBol[15] := ( cAliasSF2 )->F2_CLIENTE
	aTitBol[16] := ( cAliasSF2 )->F2_LOJA
	aTitBol[17] := ( cAliasSF2 )->F2_CLIENTE
	aTitBol[18] := ( cAliasSF2 )->F2_LOJA

	Conout('CI_A050 - Chamada da impressao do boleto CI_F001C')	
	//chama rotina padro da fabrica
	U_CI_F001C( aTitBol, aBcoBol, @oDanfe )//Rotina para gerar o boleto
	
	( cAliasSF2 )->( dbSkip() )
	
EndDo

( cAliasSF2 )->( dbCloseArea() )

RestArea( aAreaSEE )
RestArea( aAreaSC5 )
RestArea( aAreaSD2 )
RestArea( aAreaSF2 )

Return
//------------------------------------------------------------
//seleciona dados de config bancarias a partir do codigo banco parametrizado
User Function CI_G050SEE(aBcoBol)
//------------------------------------------------------------
Local aAreaSEE := GetArea()

DbSelectArea('ZA8')
dbSetOrder(1)
DbGoTop()

dbSelectArea("SEE")
dbSetOrder(1)
If( dbSeek(xFilial("SEE")+ZA8->ZA8_BCO+ZA8->ZA8_AGE+ZA8->ZA8_CTA+ZA8->ZA8_SCT) )
	aBcoBol[01] := SEE->EE_CODIGO
	aBcoBol[02] := SEE->EE_AGENCIA
	aBcoBol[03] := SEE->EE_CONTA
	aBcoBol[04] := SEE->EE_SUBCTA
Else
	Conout('CI_A050 - Banco de emissao do boleto nao encontrado - '+ZA8->ZA8_BCO+ZA8->ZA8_AGE+ZA8->ZA8_CTA+ZA8->ZA8_SCT)	
Endif 

RestArea( aAreaSEE )
Return aBcoBol          

