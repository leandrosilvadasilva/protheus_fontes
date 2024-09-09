/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_VLSTOPOR³ Autor ³ Expedito Mendonca Jr  ³ Data ³12/11/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao no campo AD1_STATUS de modo que so os analistas  ³±±
±±³          ³ comerciais possam colocar a oportunidade como Ganha.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_VlStOpor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function VlStOpor()
Local cAreaAnt := Alias()
Local cQuery,cNomeFil
Local lRet              


If M->AD1_STATUS == "9"		// Ganha

	// Verifica se o usuario logado no sistema eh do grupo de analistas comerciais 
	cQuery := " SELECT AO5_CODANE"
	cQuery += " FROM " + RetSQLName("AO5") + " AO5, " + RetSQLName("ACA") + " ACA"
	cQuery += " WHERE AO5_FILIAL = '" + xFilial("AO5")	+ "'"
	cQuery += " 	AND	AO5_ENTPAI = 'ACA'"      // Equipe de vendas
	// Relacionamento com ACA
	cQuery += " 	AND	ACA.ACA_FILIAL = '" + xFilial("ACA") + "'"	
	cQuery += " 	AND	ACA_GRPREP = AO5_CODPAI"
	cQuery += " 	AND	ACA_ENCOPO = 'S'"	 // Tem direitos para encerrar oportunidade como ganha
	cQuery += " 	AND	ACA.D_E_L_E_T_ <> '*'"
	// Filtra o usuario logado
	cQuery += " 	AND	AO5_ENTANE = 'USU'"		 // Usuarios
	cQuery += " 	AND	AO5_CODANE = '" + RetCodUsr() + "'"
	cQuery += " 	AND	AO5.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRAB1", .F., .T.)
	lRet := !Eof()
	TRAB1->( dbCloseArea() )
	If lRet
		cNomeFil :=	AllTrim( Posicione('SM0', 1, cEmpAnt + cFilAnt,  'M0_FILIAL' ) )
		lRet := MsgYesNo( "Confirma a geracao do pedido de venda na filial " + cNomeFil + "?" )
	Else 
		Alert("Usuario sem permissao para encerrar a oportunidade como ganha!")
	Endif
	
Else

	lRet := .T.

Endif	
	
dbSelectArea(cAreaAnt)

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_IPDSTAGE³ Autor ³ Expedito Mendonca Jr  ³ Data ³15/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador padrao do campo descricao do estagio.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IPDSTAGE()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function IPDSTAGE()
Local cAreaAnt := alias()
Local aAreaAC1 := AC1->(Getarea())
Local aAreaAC2 := AC2->(Getarea())
Local cDescEstagio
                                   
dbSelectArea("AC2")
dbSetOrder(1) 	// AC2_FILIAL+AC2_PROVEN+AC2_STAGE
dbSeek(xFilial("AC2")+M->AD1_PROVEN+AD1_STAGE,.F.)

cDescEstagio := Trim(Posicione("AC1",1,xFilial("AC1")+AC2->AC2_PROVEN,"AC1_DESCRI"))+"/"+AC2->AC2_DESCRI

// Restaura o ambiente
Restarea(aAreaAC1)
Restarea(aAreaAC2)
dbSelectArea(cAreaAnt)

Return cDescEstagio


// Incializador padrao do campo AD1_NOMEMP
User Function IPNOMEMP(lBrowse)
Local cRet                    

If lBrowse .or. !INCLUI
	
	If Empty(AD1->AD1_PROSPE)
		cRet := POSICIONE("SA1",1,XFILIAL("SA1")+AD1->AD1_CODCLI+AD1->AD1_LOJCLI,"A1_NOME")
	Else
		cRet := POSICIONE("SUS",1,XFILIAL("SUS")+AD1->AD1_PROSPE+AD1->AD1_LOJPRO,"US_NOME")
	Endif
	
Else
	
	cRet := ""
	
Endif

Return cRet		


// Inicializador padrao do campo Pedido na tela de oportunidades de venda
User Function IPAD1Ped()
Local cAreaAnt := Alias()
Local aAreaSCJ := SCJ->(Getarea())
Local aAreaSCK := SCK->(Getarea())
Local cRet := ""

If !Empty(AD1->AD1_PROPOS)
		                   
	// Posiciona tabela SCJ
	dbSelectArea("SCJ")
	dbSetOrder(4)		// CJ_FILIAL+CJ_PROPOST
	If dbSeek(xFilial("SCJ")+AD1->AD1_PROPOS,.F.)
	
		// Posiciona tabela SCK
		dbSelectArea("SCK")  
		dbSetOrder(1)		// CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
		dbSeek(xFilial("SCK")+SCJ->CJ_NUM,.F.)
		
		cRet := SCK->CK_NUMPV
	Endif	
	
Endif      

Restarea(aAreaSCJ)
Restarea(aAreaSCK)
dbSelectArea(cAreaAnt)

Return cRet      


// Inicializador padrao do campo IPAD1NF()
User Function IPAD1NF()
Local cAreaAnt := Alias()
Local aAreaSC5 := SCJ->(Getarea())
Local cNumPed
Local cRet := ""

cNumPed := u_IPAD1Ped()

If !Empty(cNumPed)
		                   
	// Posiciona tabela SC5
	dbSelectArea("SC5")
	dbSetOrder(1)		// C5_FILIAL+C5_NUM
	dbSeek(xFilial("SC5")+cNumPed,.F.)
	
	cRet := SC5->C5_NOTA	
	
Endif      

Restarea(aAreaSC5)
dbSelectArea(cAreaAnt)

Return cRet