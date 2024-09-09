#Include "Protheus.Ch"

/*-----------------------------------------------------------------------------
Ponto de entrada M185MOD2 - Encerra Requisição e Gera movimentação interna
Chamado em MATA185 - BAIXA
ExecBlock("M185MOD2",.F.,.F.,aCols)
-----------------------------------------------------------------------------*/

USER FUNCTION M185MOD2()

Local   aAliasCP     := SCP->(GetArea())
Local   aAliasCQ     := SCQ->(GetArea())
Local   aItem        := {}
Local   aAuto        := {}
local 	cArmDest     :=""
Local   nSaldo       :=0.00
Local   nVezes       := 0
Local   cMsgSld      :=""
Local   nX           := 1
Private lMsErroAuto	 := .F.

/*-----------------------------------------------------------------------------------------------------
aCols recebido via parâmetro
.F.	ou .T.	,;									//  1 Marca de selecionado na tela
CP_NUM		,; 									//  2 Numero da SA
CP_ITEM		,;									//  3 Item da SA
CP_PRODUTO	,;									//  4 Produto
CP_DESCRI	,;									//  5 Descricao do Produto
CP_LOCAL	,;									//  6 Armazem
CP_UM		,;									//  7 UM
Transform(aRetCQ[2],PesqPictQt('D3_QUANT')),;	//  8 Qtd. a Requisitar (Formato Caracter)
aRetCQ[2]	,;									//  9 Qtd. a Requisitar
CP_CC		,;									// 10 Centro de Custo
CP_SEGUM	,;									// 11 2a.UM
nQtdSegUm	,;									// 12 Qtd. 2a.UM
CP_OP		,;									// 13 Ordem de Producao
CP_CONTA	,;									// 14 Conta Contabil
CP_ITEMCTA	,;									// 15 Item Contabil
CP_CLVL		,;									// 16 Classe Valor
CriaVar('AFH_PROJET',.F.),; 				 	// 17 Projeto
CP_NUMOS 	,;									// 18 Nr. da OS
CriaVar('AFH_TAREFA',.F.),;				 	    // 19 Tarefa
"SCP"	,;										// 20 Alias Walk-Thru
SCP->(RecNo()) ,;								// 21 Recno Walk-Thru
Iif(lPIMSInt,CP_NRBPIMS,' ')})					// 22 Numero Boletim PIMS
----------------------------------------------------------------------------------------------------*/

nVezes := len(PARAMIXB)

For nX :=1 to nVezes

	If PARAMIXB[nX] [1]

		cQuery := " SELECT * "
		cQuery += " FROM " + RetSQLName("SCP")
		cQuery += " WHERE CP_FILIAL  = '" + xFilial("SCP") + "'"
		cQuery += " AND   CP_NUM     = '" + PARAMIXB[nX][2] + "'"
		cQuery += " AND   CP_ITEM    = '" + PARAMIXB[nX][3] + "'"      
		cQuery += " AND   CP_STATUS  <>'E' "
		cQuery += " AND   D_E_L_E_T_ <> '*' "
		cQuery += " Order by CP_ITEM "
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPCP",.F.,.T.)


		// ------------------------Verifica Saldo do Lote a ser baixado
		//										               Produto     Local Origem    Lote Customizado
		nSaldo := POSICIONE("SB8", 3, xFilial("SB8") + TMPCP->CP_PRODUTO + TMPCP->CP_LOCAL + TMPCP->CP_ZLOTCTL, "B8_SALDO" )
				
		If PARAMIXB[nX] [9] > nSaldo             // verifica se qtde requerida tem no saldo
			cMsgSld:=PARAMIXB[nX] [4]
			Alert("O produto "+cMsgSld+" nao possui saldo ("+cvaltochar(nSaldo)+") para realizar esta operacao.")
			TMPCP->(dbcloseArea())
			Return .F.
		Endif
	
		// ------------------------ Altera STATUS SA
		If  (TMPCP->CP_NUM+TMPCP->CP_ITEM) <> (SCP->CP_NUM+SCP->CP_ITEM)
			DbSelectArea("SCP")
			DbSetOrder(1)
			DbSeek(xFilial("SCP")+TMPCP->CP_NUM+TMPCP->CP_ITEM,.F.)
		Endif		

		RecLock("SCP", .F.)
			If PARAMIXB[nX] [9] > 0
				SCP->CP_QUJE   := PARAMIXB[nX] [9]
			Endif
			SCP->CP_STATUS := "E"
			SCP->CP_PREREQU:= "S"
		MsUnlock()

		dbSelectArea("SCQ")
		dbSetOrder(1)
        dbSeek(xFilial()+TMPCP->CP_NUM + TMPCP->CP_ITEM)		
		//----------------------------------------------------------------Encerra Requisiçao
        While !Eof() .And. xFilial()+ TMPCP->CP_NUM + TMPCP->CP_ITEM == CQ_FILIAL + CQ_NUM + CQ_ITEM

            RecLock("SCQ",.F.)
				SCQ->CQ_STATUSC := "D"           // Deletada
            MsUnlock()

            If Empty(CQ_NUMREQ)

                RecLock("SCQ",.F.,.T.)
                    dbDelete()
                MsUnlock()
            EndIf
			
			SCQ->(DbSkip())

		End

		//------------------------------------------- Baixa quantidade empenhada na solicitação
        dbSelectArea("SB2")
        dbSetOrder(1)

        If dbSeek(xFilial("SB2") + TMPCP->CP_PRODUTO + TMPCP->CP_LOCAL)
            RecLock("SB2", .F.)
			SB2->B2_QEMPSA  -= Min(SB2->B2_QEMPSA,PARAMIXB[nX] [9])
            MsUnlock()
        Endif
	
		// --------------------------------------------Regra para definir o armazem de destino
		IF xFilial("SCP")='0101'
			cArmDest:="10"
		Endif
		IF xFilial("SCP")='0102'
			cArmDest:="20"
		Endif
		IF xFilial("SCP")='0103'
			cArmDest:="30"
		Endif
		IF xFilial("SCP")='0104'
			cArmDest:="10"
		Endif
		IF xFilial("SCP")='0105'
			cArmDest:="10"
		Endif
		IF xFilial("SCP")='0106'
			cArmDest:="10"
		Endif
		IF xFilial("SCP")='0107'
			cArmDest:="10"
		Endif
		// --------------------------------------------Gera movimentacoes internas

        aAuto := {{ 'SA' + RIGHT(TMPCP->CP_NUM,5)+TMPCP->CP_ITEM, dDataBase }}

		aItem := {}

        SB1->( dbSetOrder( 1 ) )
        SB1->( dbSeek( xFilial( 'SB1' ) + TMPCP->CP_PRODUTO, .F. ) )

        // Origem
        aAdd( aItem, TMPCP->CP_PRODUTO )              //  1 D3_COD
        aAdd( aItem, SB1->B1_DESC )                   //  2 D3_DESCRI
        aAdd( aItem, SB1->B1_UM )                     //  3 D3_UM
        aAdd( aItem, TMPCP->CP_LOCAL )                //  4 D3_LOCAL
        aAdd( aItem, TMPCP->CP_ZLOCLIZ )              //  5 D3_LOCALIZ
                                                               
        // Destino
        aAdd( aItem, SCP->CP_PRODUTO )                //  6 D3_COD
        aAdd( aItem, SB1->B1_DESC )                   //  7 D3_DESCRI
        aAdd( aItem, SB1->B1_UM )                     //  8 D3_UM
        aAdd( aItem, cArmDest )                       //  9 D3_LOCAL
        aAdd( aItem, TMPCP->CP_ZLOCLIZ )              // 10 D3_LOCALIZ                           

        // Origem
        aAdd( aItem, '' )                             // 11 D3_NUMSERI
        aAdd( aItem, TMPCP->CP_ZLOTCTL )              // 12 D3_LOTECTL                           
        aAdd( aItem, '' )                             // 13 D3_NUMLOTE
        aAdd( aItem, STOD(TMPCP->CP_ZDTLOTE) )        // 14 D3_DTVALID

        aAdd( aItem, 0 )                              // 15 D3_POTENCI
        aAdd( aItem, PARAMIXB[nX] [9] )               // 16 D3_QUANT
        aAdd( aItem, 0 )                              // 17 D3_QTSEGUM
        aAdd( aItem, '' )                             // 18 D3_ESTORNO
        aAdd( aItem, '' )                             // 19 D3_NUMSEQ

        // Destino
        aAdd( aItem, TMPCP->CP_ZLOTCTL )              // 20 D3_LOTECTL
        aAdd( aItem, STOD(TMPCP->CP_ZDTLOTE) )              // 21 D3_DTVALID
        aAdd( aItem, '' )                             // 22 D3_ITEMGRD

        aAdd( aItem, 'SA '+ TMPCP->CP_NUM +'/'+ TMPCP->CP_ITEM ) // 23 D3_OBSERVA

        aAdd( aAuto, aItem )    
        // -------------------------------------------cria saldo no armaz�m de destino, caso n�o exista...
  
        SB2->( dbSetOrder( 1 ) )
        If SB2->( !dbSeek( xFilial( 'SB2' ) + aItem[ 6 ] + aItem[ 9 ], .F. ) )

            lMsErroAuto := .F.

            MSExecAuto( { |x,y| MATA220( x, y ) }, { { 'B9_COD', aItem[ 6 ], Nil }, { 'B9_LOCAL', aItem[ 9 ], Nil } }, 3 )

            If lMsErroAuto
    			MostraErro()
            EndIf

        EndIf

		TMPCP->(dbcloseArea())

		lMsErroAuto := .F.

		MSExecAuto( { |x,y| MATA261( x, y ) }, aAuto, 3 )

		If lMsErroAuto
			MostraErro()
		EndIf

	Endif

Next	

RestArea(aAliasCP)
RestArea(aAliasCQ)

Return .F.
