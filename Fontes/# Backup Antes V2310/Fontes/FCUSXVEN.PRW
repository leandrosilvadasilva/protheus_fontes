#Include "Protheus.ch"



USER FUNCTION FCUSXVEN(cTes,cPro,cLoc,cTab)
Local  aArea		:= GetArea()
Local  aAreaDA1     := GetArea("DA1")
Local  aAreaSB1     := GetArea("SB1")
Local  aAreaSB2     := GetArea("SB2")
Local  cDA1PV:=POSICIONE("DA1",2, xFilial("DA1")+cPro+CTab, "DA1_PRCVEN")   //Preco Tabela
Local  cSB1PV:=POSICIONE("SB1",1, xFilial("SB1")+cPro, "B1_PRV1")        //Preco Venda Cadastro Produto
Local  cSB2CT:=POSICIONE("SB2",1, xFilial("SB2")+cPro+cLoc, "B2_CM1")   //Custo Medio
Local  cGTes :=Getmv( "ES_GTESCUS" )


cValor:=0.00
IF ALLTRIM(cTes) $ cGTes
	cValor:=cSB2CT
	return cValor
Endif

IF ALLTRIM(cTab)<>""
	cValor:=cDA1PV
	return cValor
Endif

cValor:=cSB1PV


RestArea( aArea )
RestArea( aAreaDA1 )
RestArea( aAreaSB1 )
RestArea( aAreaSB2 )


return  cValor


USER FUNCTION FCUSVENG(nQtd,nPrc)

nVal:= nQtd * nPrc

nVal:= Round(NoRound(nVal,4),2)

Return nVal 
