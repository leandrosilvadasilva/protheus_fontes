#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHA010  ³ Autor ³ MARLLON               ³ Data ³12/06/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao do cadastro de regra de comissao                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FUNCAO DE VALIDACAO                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAHA010()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "Z20"

dbSelectArea("Z20")
dbSetOrder(1)

AxCadastro(cString,"Tabela de Comissões",cVldExc,cVldAlt)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MAHG010   º Autor ³Marllon Figueiredo  º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gatilho para sugestao de comissao                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ U_MANH010( cCodVend )                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MAHG010(cVend, cProd, nDesco)

	Local aArea       := GetArea()
	Local aAreaSB1    := SB1->( GetArea() )
	Local aAreaSA3    := SA3->( GetArea() )
	Local nComis      := 0
	Local nLimDes     := 0 
	Local nPerRed     := 0
	Local cAliasZ20   := 'Z20TMP'
	

	// tratamento para quando pedido nasce pelo CRM
	If Funname() == 'CRMA110' .or. Funname() == 'CRMA290' .or. Funname() == "FATA300" .or. Funname() == "FATA320"
		If cProd == nil
			Return(0)
		Else
			cCodProd  := cProd
			nC6LIMDES := nDesco
		EndIf
	Else
		cCodProd  := GDFieldGet('C6_PRODUTO',N)
		nC6LIMDES := GDFieldGet('C6_DESCOMA',N)
	EndIf
		
	// posiciona no produto
	SB1->( dbSeek(xFilial('SB1')+cCodProd) )
	// posiciona no vendedor
	SA3->( dbSeek(xFilial('SA3')+cVend) )

	/*
	Regras contempladas:
	
	VEND	X	X	X	X	X	X
	TIPO	X	X	X	-	-	-
	GRUPO	X	X	-	X	-	-
	PRODU	X	-	-	-	X	-
		
    */
	
	// executa a consulta na tabela de comissoes considerando todos os campos preenchidos
	BeginSql  Alias cAliasZ20
	SELECT Z20_COMIS , Z20_LIMDES , Z20_PERRED
	FROM %Table:Z20% Z20
	WHERE Z20_FILIAL = %xFilial:Z20% AND
		  Z20_VEND = %Exp:SA3->A3_COD% AND 
		  Z20_TIPO = %Exp:SB1->B1_TIPO% AND 
		  Z20_GRUPO = %Exp:SB1->B1_GRUPO% AND 
		  Z20_COD = %Exp:SB1->B1_COD% AND 
		  Z20_BLOQ <> '1' AND 
		  Z20.%notdel%
	EndSql

	// atualiza a posicao referente ao percentual de comissao do item
	nComis   := (cAliasZ20)->Z20_COMIS
	nLimDes  := (cAliasZ20)->Z20_LIMDES
	nPerRed  := (cAliasZ20)->Z20_PERRED
	dbSelectArea(cAliasZ20)
	dbCloseArea()

	// executa a consulta na tabela de comissoes considerando produto em branco
	If nComis = 0
		BeginSql  Alias cAliasZ20
		SELECT Z20_COMIS , Z20_LIMDES , Z20_PERRED
		FROM %Table:Z20% Z20
		WHERE Z20_FILIAL = %xFilial:Z20% AND
			  Z20_VEND = %Exp:SA3->A3_COD% AND 
			  Z20_TIPO = %Exp:SB1->B1_TIPO% AND 
			  Z20_GRUPO = %Exp:SB1->B1_GRUPO% AND 
			  Z20_COD = ' ' AND 
			  Z20_BLOQ <> '1' AND 
			  Z20.%notdel%
		EndSql

		// atualiza a posicao referente ao percentual de comissao do item
		nComis   := (cAliasZ20)->Z20_COMIS
		nLimDes  := (cAliasZ20)->Z20_LIMDES
		nPerRed  := (cAliasZ20)->Z20_PERRED
		dbSelectArea(cAliasZ20)
		dbCloseArea()

	EndIf
	
	// executa a consulta na tabela de comissoes considerando produto e tipo em branco
	If nComis = 0
		BeginSql  Alias cAliasZ20
		SELECT Z20_COMIS , Z20_LIMDES , Z20_PERRED
		FROM %Table:Z20% Z20
		WHERE Z20_FILIAL = %xFilial:Z20% AND
			  Z20_VEND = %Exp:SA3->A3_COD% AND 
			  Z20_TIPO = %Exp:SB1->B1_TIPO% AND 
			  Z20_GRUPO = ' ' AND 
			  Z20_COD = ' ' AND 
			  Z20_BLOQ <> '1' AND 
			  Z20.%notdel%
		EndSql

		// atualiza a posicao referente ao percentual de comissao do item
		nComis   := (cAliasZ20)->Z20_COMIS
		nLimDes  := (cAliasZ20)->Z20_LIMDES
		nPerRed  := (cAliasZ20)->Z20_PERRED
		dbSelectArea(cAliasZ20)
		dbCloseArea()

	EndIf
	
	// executa a consulta na tabela de comissoes considerando produto, tipo e grupo em branco
	If nComis = 0
		BeginSql  Alias cAliasZ20
		SELECT Z20_COMIS , Z20_LIMDES , Z20_PERRED
		FROM %Table:Z20% Z20
		WHERE Z20_FILIAL = %xFilial:Z20% AND
			  Z20_VEND = %Exp:SA3->A3_COD% AND 
			  Z20_TIPO = ' ' AND 
			  Z20_GRUPO = %Exp:SB1->B1_GRUPO% AND 
			  Z20_COD = ' ' AND 
			  Z20_BLOQ <> '1' AND 
			  Z20.%notdel%
		EndSql
	
		// atualiza a posicao referente ao percentual de comissao do item
		nComis   := (cAliasZ20)->Z20_COMIS
		nLimDes  := (cAliasZ20)->Z20_LIMDES
		nPerRed  := (cAliasZ20)->Z20_PERRED
		dbSelectArea(cAliasZ20)
		dbCloseArea()

	EndIf

	// executa a consulta na tabela de comissoes considerando produto, tipo e grupo em branco
	If nComis = 0
		BeginSql  Alias cAliasZ20
		SELECT Z20_COMIS , Z20_LIMDES , Z20_PERRED
		FROM %Table:Z20% Z20
		WHERE Z20_FILIAL = %xFilial:Z20% AND
			  Z20_VEND = %Exp:SA3->A3_COD% AND 
			  Z20_TIPO = ' ' AND 
			  Z20_GRUPO = ' ' AND 
			  Z20_COD = %Exp:SB1->B1_COD% AND 
			  Z20_BLOQ <> '1' AND 
			  Z20.%notdel%
		EndSql
	
		// atualiza a posicao referente ao percentual de comissao do item
		nComis   := (cAliasZ20)->Z20_COMIS
		nLimDes  := (cAliasZ20)->Z20_LIMDES
		nPerRed  := (cAliasZ20)->Z20_PERRED
		dbSelectArea(cAliasZ20)
		dbCloseArea()

	EndIf

	// executa a consulta na tabela de comissoes considerando somente o produto preenchido
	If nComis = 0
		BeginSql  Alias cAliasZ20
		SELECT Z20_COMIS , Z20_LIMDES , Z20_PERRED
		FROM %Table:Z20% Z20
		WHERE Z20_FILIAL = %xFilial:Z20% AND
			  Z20_VEND = %Exp:SA3->A3_COD% AND 
			  Z20_TIPO = ' ' AND 
			  Z20_GRUPO = ' ' AND 
			  Z20_COD = ' ' AND 
			  Z20_BLOQ <> '1' AND 
			  Z20.%notdel%
		EndSql
	
		// atualiza a posicao referente ao percentual de comissao do item
		nComis   := (cAliasZ20)->Z20_COMIS
		nLimDes  := (cAliasZ20)->Z20_LIMDES
		nPerRed  := (cAliasZ20)->Z20_PERRED
		dbSelectArea(cAliasZ20)
		dbCloseArea()

	EndIf

	// tratamento dos limites de desconto
	If nC6LIMDES >= nLimDes
		nComis := nComis - (nComis * nPerRed / 100)
    EndIf
			
	RestArea(aAreaSB1)
	RestArea(aAreaSA3)
	RestArea(aArea)

Return( nComis )
