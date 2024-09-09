#INCLUDE "PROTHEUS.CH"
#INCLUDE "SPEDNFE.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "APWIZARD.CH"

#define ENTER           CHR(13) + CHR(10)
#define POS_MARCA       01
#define POS_LEGENDA     02
#define POS_PEDIDO      03
#define POS_DOC         04
#define POS_SERIE       05
#define POS_CLIENTE     06
#define POS_LOJA        07
#define POS_CLINOME     08
#define POS_ESTADO      09
#define POS_EMISSAO     10
#define POS_CPNJTRANSP  11
#define POS_TRANSPORT   12

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	KTFatMnt
Descrição	:	Função responsável por visualizar o processo de transmissão de nf-e por pedido
----------------------------------------------------------------------------------------------------*/
user function KTFatMnt()
    local _cTit      := "Transmissão de NF-e por Pedido"
    local cError     := ""
    local oDlgFat    := nil
    local oFWLayer   := nil
    local oDlgOpc    := nil
    local oDlgPainel := nil
    local oBtnClose  := nil
    local oBtnFiltro := nil
    local oBtnPesq   := nil
    local oBtnTrans  := nil
    local oBtnMonit  := nil
    local oBtnImpr   := nil
    local aSize      := {}
    local oListPed   := nil
    local cPicture   := ""
    local oMenu      := nil
    local oAcoes     := nil
    local oMenu01    := nil
    local oMenu0101  := nil
    local oMenu0102  := nil
    local oMenu0103  := nil
    local oMenu0104  := nil
    local oParNfe    := nil
    local oEventos   := nil
	local cVersaoTSS := getVersaoTSS()
	local cTitulo	 := ""

    private oNTrans    := LoadBitmap( GetResources(), "BR_VERMELHO")
    private oAut       := LoadBitmap( GetResources(), "BR_VERDE")
    private oTrans     := LoadBitmap( GetResources(), "BR_AZUL")
    private oDenegado  := LoadBitmap( GetResources(), "BR_CINZA")
    private oNAut      := LoadBitmap( GetResources(), "BR_PRETO")
    private oOk        := LoadBitmap( GetResources(), "LBOK" )
    private oNo        := LoadBitmap( GetResources(), "LBNO" )
    private cIdEnt     := getCfgEntidade(@cError) 
    private lMarca     := .T.
    private aPedidos   := {}

	cTitulo	 := "MONITORAMENTO DA NFE-SEFAZ - ENTIDADE : " + cIdEnt + " - TSS: " + cVersaoTSS

    begin sequence

    if empty(cIdEnt)
        Help( ,, "TSS",, "Entidade do serviço do TSS não encontrado." , 1, 0,,,,,, {cError} )
        break
    endif

    if ProcFiltro(@aPedidos)

        aSize := MsAdvSize()
        cPicture := PesqPict("SA1","A1_CGC")

        _cTit += " - Empresa: " + FwCodEmp() + "/" + FwCodFil() + " - " + FWFilRazSocial()
        oDlgFat := TDialog():New(000,000,aSize[6],aSize[5],_cTit ,,,,,,,,,.T.)

        oFWLayer := FWLayer():New()
        oFWLayer:Init(oDlgFat,.F.)
        oFWLayer:AddCollumn("JANELA",100,.T.)
        oFWLayer:AddWindow("JANELA","OPCAO"  ,cTitulo     ,015,.F.,.F.,/*bAction*/,/*cIDLine*/,/*bGotFocus*/)
        oFWLayer:AddWindow("JANELA","PAINEL" ,"Pedidos"  ,085,.F.,.F.,/*bAction*/,/*cIDLine*/,/*bGotFocus*/)
        oDlgOpc := oFWLayer:GetWinPanel("JANELA","OPCAO")
        oDlgPainel := oFWLayer:GetWinPanel("JANELA","PAINEL")

        oListPed := TCBrowse():New( 25 , 5, 270, 135,,;
                                    {' ',' ','Pedido', 'Documento', 'Série', 'Cód. Cliente', 'Loja', 'Cliente', 'Estado', 'Emissão', 'CNPJ Transportadora', 'Transportadora'},;
                                    {20,20,20,50,20,40,20,150,20,20,80,150},;
                                    oDlgPainel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

        oListPed:SetArray(aPedidos)
        oListPed:Align := CONTROL_ALIGN_ALLCLIENT
        oListPed:BlDblClick := { || aPedidos[oListPed:nAt, POS_MARCA] := !aPedidos[oListPed:nAt, POS_MARCA], oListPed:DrawSelect()}
        oListPed:bHeaderClick := {|o, nCol| ProcOrd(o, nCol) }
        oListPed:bLine := { || { if(aPedidos[oListPed:nAt,POS_MARCA], oOk,oNo),;
                                 aPedidos[oListPed:nAt,POS_LEGENDA],;
                                 aPedidos[oListPed:nAt,POS_PEDIDO],;
                                 aPedidos[oListPed:nAt,POS_DOC],;
                                 aPedidos[oListPed:nAt,POS_SERIE],;
                                 aPedidos[oListPed:nAt,POS_CLIENTE],;
                                 aPedidos[oListPed:nAt,POS_LOJA],;
                                 aPedidos[oListPed:nAt,POS_CLINOME],;
                                 aPedidos[oListPed:nAt,POS_ESTADO],;
                                 aPedidos[oListPed:nAt,POS_EMISSAO],;
                                 Transform(aPedidos[oListPed:nAt,POS_CPNJTRANSP] , cPicture ) ,;
                                 aPedidos[oListPed:nAt,POS_TRANSPORT]} }

        oBtnPesq := TButton():New( 000,002,"Pesquisar",oDlgOpc,{|| Pesquisa( @oListPed ) },040,013,,,,.T.)
        oBtnTrans := TButton():New( 000,045,"Transmitir",oDlgOpc,{|| ProcTrans( @oListPed ) },040,013,,,,.T.)
        oBtnMonit := TButton():New( 000,088,"Monitorar",oDlgOpc,{|| ProcMonitor( @oListPed ) },040,013,,,,.T.)
        oBtnImpr := TButton():New( 000,131,"Danfe",oDlgOpc,{|| ProcDanfe( @oListPed ) },040,013,,,,.T.)
        oAcoes := TButton():New( 000,174, "Outras Ações",oDlgOpc,{|| },050,013,,,,.T.)

        oMenu01 := tMenu():new(0, 0, 0, 0, .T., , oMenu)          
        oMenu0101 := tMenuItem():new(oMenu01, "Exportar"      ,,,, {|| Exportar( @oListPed ) },,,,,,,,,.T.) 
        oMenu0102 := tMenuItem():new(oMenu01, "Visualizar Doc.",,,, {|| VisDoc( @oListPed ) },,,,,,,,,.T.)
        oMenu0103 := tMenuItem():new(oMenu01, "Parametros"    ,,,, {||},,,,,,,,,.T.)
        oMenu0104 := tMenuItem():new(oMenu01, "Legenda",,,, {|| Legenda() },,,,,,,,,.T.)

        oParNfe := tMenuItem():new(oMenu0103, "Nfe"    ,,,, {|| SpedNFePar() },,,,,,,,,.T.)
        oEventos := tMenuItem():new(oMenu0103, "Eventos",,,, {|| ParaEvent()},,,,,,,,,.T.)

        oMenu01:add(oMenu0101)
        oMenu01:add(oMenu0102)
        oMenu01:add(oMenu0103)
        oMenu01:add(oMenu0104)
        oMenu0103:add(oParNfe) 
        oMenu0103:add(oEventos)
        oAcoes:setPopupMenu(oMenu01)  

        oBtnFiltro := TButton():New( 000, ((oDlgOpc:nRight/2) - 56),"Filtro",oDlgOpc,{|| ProcFiltro(@oListPed:aArray, @oListPed ) , oDlgPainel:Refresh()},025,013,,,,.T.)
        oBtnClose := TButton():New( 000, ((oDlgOpc:nRight/2) - 30),"Fechar",oDlgOpc,{|| oDlgFat:End() },025,013,,,,.T.)

        oDlgFat:Activate(,,,.T.)

    endif

    end sequence

return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	ProcOrd
Descrição	:	Função responsável por order os dados da tela
----------------------------------------------------------------------------------------------------*/
static function ProcOrd( oObj, nColuna )
    local nLinha     := 0
    local nAt        := oObj:nAt

    if nColuna == POS_PEDIDO .Or. nColuna == POS_LEGENDA 
        aSort(oObj:aArray,,,{|x,y| x[nColuna] < y[nColuna]  })
    elseif nColuna == POS_MARCA
        for nLinha := 1 to len(oObj:aArray)
            oObj:aArray[nLinha][POS_MARCA] := lMarca
        next
        lMarca := !lMarca
    elseif nColuna == POS_EMISSAO
        aSort(oObj:aArray,,,{|x,y| dToS(x[nColuna]) + x[POS_PEDIDO] < dTOS(y[nColuna]) + y[POS_PEDIDO] })
    else
        aSort(oObj:aArray,,,{|x,y| x[nColuna] + x[POS_PEDIDO] < y[nColuna] + y[POS_PEDIDO] })
    endif
    oObj:DrawSelect()
    oObj:Refresh()
    oObj:nAt := nAt

return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	ProcFiltro
Descrição	:	Função responsável por realizar o filtro de pedidos
----------------------------------------------------------------------------------------------------*/
static function ProcFiltro( aDados, oObj )
    local lRet       := .F.
    local aParamBox  := {}
    local aFiltro    := {}
    local nTamPed    := getSX3Cache("C9_PEDIDO", "X3_TAMANHO")
    local nTamSerie  := getSX3Cache("C9_SERIENF", "X3_TAMANHO")

    default aDados     := {}

    aAdd(aParamBox,{1,"Pedido De ",Space(nTamPed),"","","","",0,.F.})
    aAdd(aParamBox,{1,"Pedido Ate",Space(nTamPed),"","","","",0,.F.})
    aAdd(aParamBox,{1,"Serie" ,Space(nTamSerie),"","","","",0,.F.})
    while ParamBox(aParamBox,"Parametros",@aFiltro,,,.T.,,,,"KTFATMNT")
        aDados := {}
        FWMsgRun(,{|| ProcQuery( aFiltro, @aDados ) },"Carregando...","Por favor, aguarde o término do processamento.")
        if len(aDados) > 0
            lRet := .T.
        else
            MsgInfo("Não foi encontrado registro para os dados informados.", "Atenção")
            aDados := { {.F., oNAut, "", "", "", "", "", "", "", "", "", "" }}
            lRet := .F.
        endif
        exit
    end 

    if valtype(oObj) == "O"
        aPedidos := aDados
        oObj:DrawSelect()
        oObj:Refresh(.T.)
    endif

return lRet

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	ProcQuery
Descrição	:	Função responsável por realizar a query
----------------------------------------------------------------------------------------------------*/
static function ProcQuery( aParam, aRetorno )
    local cAliasQry  := ""
    local cQuery     := ""
    local aArea      := {}
    local cPedIni    := aParam[1]
    local cPedFim    := aParam[2]
    local cSerie     := aParam[3]
    local cQry       := ""

    aArea := getArea()

    cQuery := " SELECT "
    cQuery += " DISTINCT SC9.C9_PEDIDO AS PEDIDO, SC9.C9_CLIENTE AS CLIENTE, SC9.C9_LOJA AS LOJA, SC9.C9_NFISCAL AS NFISCAL, SC9.C9_SERIENF AS SERIE, "
    cQuery += " SA1.A1_NOME AS NOME, "
    cQuery += " SF2.F2_FIMP AS STATUS, SF2.F2_ESPECIE AS ESPECIE, SF2.F2_EMISSAO AS EMISSAO, SF2.F2_EST AS ESTADO, "
    cQuery += " CASE WHEN RTRIM(SA4.A4_COD) IS NULL THEN ' ' ELSE SA4.A4_CGC END AS CNPJ_TRANSPORTADORA, "
    cQuery += " CASE WHEN RTRIM(SA4.A4_COD) IS NULL THEN ' ' ELSE SA4.A4_NOME END AS TRANSPORTADORA "
    cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
    cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ' ' "
    cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
    cQuery += " AND SA1.A1_COD = SC9.C9_CLIENTE "
    cQuery += " AND SA1.A1_LOJA = SC9.C9_LOJA "
    cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON SF2.D_E_L_E_T_ = ' ' "
    cQuery += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
    cQuery += " AND SF2.F2_DOC = SC9.C9_NFISCAL "
    cQuery += " AND SF2.F2_SERIE = SC9.C9_SERIENF "
    cQuery += " AND SF2.F2_CLIENTE = SC9.C9_CLIENTE "
    cQuery += " AND SF2.F2_LOJA = SC9.C9_LOJA "
    cQuery += " LEFT JOIN " + RetSqlName("SA4") + " SA4 ON SA4.D_E_L_E_T_ = ' ' "
    cQuery += " AND SA4.A4_FILIAL = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.A4_COD = SF2.F2_TRANSP "
    cQuery += " WHERE SC9.D_E_L_E_T_ = ' ' "
    cQuery += " AND SC9.C9_FILIAL = '" + xFilial("SC9") + "' "
    if alltrim(upper(cPedIni)) == alltrim(upper(cPedFim))
        cQuery += " AND SC9.C9_PEDIDO = '" + cPedIni + "' "
    else
        cQuery += " AND SC9.C9_PEDIDO BETWEEN '" + cPedIni + "' AND '" + cPedFim + "' "
    endif
    if !empty(cSerie)
        cQuery += " AND SC9.C9_SERIENF = '" + cSerie + "' "
    endif
    cQuery += " AND SC9.C9_NFISCAL <> ' ' "

    // Limita somente trazer 1000 pedidos
    if (empty(cPedIni) .and. "Z" $ alltrim(upper(cPedFim))) .or. ;
        (empty(cPedIni) .and. alltrim(upper(cPedFim)) == "999999") .or. ;
        (!empty(cPedIni) .and. !empty(cPedFim) .and. ( val(cPedFim) - val(cPedIni) ) > 1000 ) 
        cQry := cQuery
        cQuery := " SELECT PED.PEDIDO, PED.CLIENTE, PED.LOJA, PED.NFISCAL, PED.SERIE, PED.NOME, PED.STATUS, PED.ESPECIE, PED.EMISSAO,  PED.ESTADO, "
        cQuery += " PED.CNPJ_TRANSPORTADORA, PED.TRANSPORTADORA FROM ( " + cQry + " ) PED  "
        cQuery += " ORDER BY PEDIDO, CLIENTE, NFISCAL, SERIE "
    else
        cQuery += " ORDER BY SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_NFISCAL, SC9.C9_SERIENF "
    endif

    cAliasQry := getNextAlias()
    dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),cAliasQry, .F., .T.)
    TCsetField(cAliasQry, "EMISSAO", "D", 8, 0)

    (cAliasQry)->(dbGoTop())
    while (cAliasQry)->(!eof())

        aAdd(aRetorno, { .F., RetLegenda( alltrim(upper((cAliasQry)->STATUS)) , alltrim(upper((cAliasQry)->ESPECIE)) ) , (cAliasQry)->PEDIDO, (cAliasQry)->NFISCAL, (cAliasQry)->SERIE, (cAliasQry)->CLIENTE, (cAliasQry)->LOJA, (cAliasQry)->NOME, (cAliasQry)->ESTADO , (cAliasQry)->EMISSAO, (cAliasQry)->CNPJ_TRANSPORTADORA, (cAliasQry)->TRANSPORTADORA } ) 

        (cAliasQry)->(dbSkip())
    end
    (cAliasQry)->(dbCloseArea())

    restArea(aArea)

return
/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	RetLegenda
Descrição	:	Função responsável por retornar o status do documento
----------------------------------------------------------------------------------------------------*/
static function RetLegenda( cStatus, cEspecie )
    local oRet := nil

    default cStatus     := ""
    default cEspecie    := ""

    do case 
        case empty(cStatus) .and. cEspecie == "SPED" // não transmitida
            oRet := oNTrans

        case cStatus == "S" // autorizada
            oRet := oAut

        case cStatus == "T" // transmitida
            oRet := oTrans

        case cStatus == "D" // denegado
            oRet := oDenegado

        case cStatus == "N" // não autorizada
            oRet := oNAut

        otherwise
            oRet := oNTrans
    endcase

return oRet

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	RetDoc
Descrição	:	Função responsável por retornar os documentos selecionados
----------------------------------------------------------------------------------------------------*/
static function RetDoc( aDados, lSkip )
    local aRet     	:= {}
    local nPosDoc  	:= 0
    local aDocs    	:= {}
    
    Default lSkip	:= .F.

    nPosDoc := aScan( aDados , { |X| X[POS_MARCA] } ) 
    if nPosDoc > 0

        dbSelectArea("SF2")
        SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
        aDocs := aClone(aDados)
        aSort(aDocs,,,{|x,y| x[1] > y[1] })
        for nPosDoc := 1 to len( aDocs )
            if aDocs[nPosDoc][POS_MARCA]
            	if lSkip .And. ( aDocs[nPosDoc][POS_LEGENDA] == oAut )
           			Loop
            	else
	                if SF2->(dbSeek( xFilial("SF2") + aDocs[nPosDoc][POS_DOC] + aDocs[nPosDoc][POS_SERIE] + aDocs[nPosDoc][POS_CLIENTE] + aDocs[nPosDoc][POS_LOJA] ))
    	                aAdd( aRet, { SF2->F2_DOC, SF2->F2_SERIE, SF2->(Recno()), aDocs[nPosDoc][POS_PEDIDO] })
        	        endif
        	    endif
            else
                exit
            endif
        next

    endif

return aRet

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	Pesquisa
Descrição	:	Função responsável por pesquisar na lista
----------------------------------------------------------------------------------------------------*/
static function Pesquisa( oObj )
	local aDados	 := oObj:aArray
    local oDlgPsq    := nil
    local oCombo     := nil
    local cCampo     := ""
    local aCampos    := {}
    local oGet       := nil
    local cGet       := Space(20)
    local oButton    := nil

    oDlgPsq := TDialog():New(000,000,090,450,"Pesquisa",,,,,,,,,.T.)
    aAdd( aCampos, "Pedido")
    aAdd( aCampos, "Documento")
    oCombo := TCombobox():New(005,005,{|u| if(PCount()>0,cCampo := u,cCampo)},aCampos,060,015,oDlgPsq,,{|| },,,,.T.,,,,,,,,,"cCampo", "Tipo de pesquisa: ")
    oGet := TGet():New(025,005,{|u| Iif(PCount()>0,cGet:=u,cGet)},oDlgPsq, 100, 015, "@!", {||  },,,,,,.T.,,,,,,,.F.,,,"cGet")
    oButton := TButton():New( 025,((oDlgPsq:nRight/2) - 50) ,"Pesquisar",oDlgPsq, {|| if( PosReg( @aDados, @oObj, cCampo, cGet ), oDlgPsq:end(),) },040,015,,,,.T.)

    oDlgPsq:activate()

return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	PosReg
Descrição	:	Função responsável por posicionar na tela
----------------------------------------------------------------------------------------------------*/
static function PosReg( aDados, oObj, cCampo, cInfo )
    local lRet       := .F.
    local nPos       := 0
    local nPosPesq   := 0
    local nTamCpo    := 0

    do case
        case alltrim(upper(cCampo)) == "PEDIDO"
            nPosPesq := POS_PEDIDO
            nTamCpo := getSX3Cache("C9_PEDIDO", "X3_TAMANHO")
        case alltrim(upper(cCampo)) == "DOCUMENTO"
            nPosPesq := POS_DOC
            nTamCpo := getSX3Cache("C9_NFISCAL", "X3_TAMANHO")
    end case
    
    if val(cInfo) > 0
        cInfo := SubStr( cInfo, 1, nTamCpo)
        cInfo := StrZero( val(cInfo), nTamCpo )
        nPos := aScan( aDados, { |X| X[nPosPesq] == cInfo} )
        if nPos == 0
            Help( ,, "PESQUISA",, "Não foi encontrado o " + lower(cCampo) + ".", 1, 0,,,,,, {cCampo + " " + cInfo} )
        else
            if valtype(oObj) == "O"
                oObj:nAt := nPos
                lRet := .T.
            endif
        endif
    endif

return lRet

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	ProcTrans
Descrição	:	Função responsável pela tramissão do documento para SEFAZ
----------------------------------------------------------------------------------------------------*/
static function ProcTrans( oObj )
    local aDados	:= RetDoc( oObj:aArray, .T. )
    local nX      	:= 0

	private lMnt	:= .F.

	FWMsgRun(,{|| TrfWizard( aDados ) },"Aguarde","Carregando o assistente de transmissão ...")

	If lMnt
		If MsgYesNo( "Deseja realizar o monitoramento das notas transmitidas ?", "Monitor" )	
		    ProcMonitor( oObj )
		Endif
	Endif

return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	ProcMonitor
Descrição	:	Função responsável por monitorar os documentos
----------------------------------------------------------------------------------------------------*/
static function ProcMonitor( oObj )
	local aDados	 := oObj:aArray
	local nX		 := 0
    local cDoc       := ""
    local cSerie     := ""
    local cCliente   := ""
    local cLoja      := ""

	dbSelectArea("SF2")
    dbSetOrder(1)

    begin sequence

	    if len(aDados) == 0
			Help( ,, "Monitor",, "Monitoramento inválido", 1, 0,,,,,, {"Nenhum pedido foi selecionado para o monitoramento."} )
	        break
	    endif

		MsgRun("Aguarde realizando o monitoramento ...","Monitor",{|| MntNFe( aDados )})
		
		for nX := 1 to len( aDados )
	    	if aDados[nX][POS_MARCA]
		        cDoc	:= aDados[nX][POS_DOC]
		        cSerie	:= aDados[nX][POS_SERIE]
		        cCliente:= aDados[nX][POS_CLIENTE]
		        cLoja 	:= aDados[nX][POS_LOJA]
		
		        if SF2->(dbSeek( xFilial("SF2") + cDoc + cSerie + cCliente + cLoja ))
		            aDados[nX][POS_LEGENDA] := RetLegenda( alltrim(upper(SF2->F2_FIMP)), alltrim(upper(SF2->F2_ESPECIE)) )
		        endif
	        endif
        next

        oObj:refresh()

    end sequence
    
return

/*---------------------------------------------------------------------------------------------------
Data     	:	18/07/2019
Função   	:	MntNFe
Descrição	:	Tela de monitoramento dos pedidos
----------------------------------------------------------------------------------------------------*/
Static Function MntNFe( aDados )

Local nX		:= 0
Local cModel	:= "55"	// NFe
Local aListBox	:= {}
Local cError	:= ""
Local oBtn1		:= NIL
Local oBtn2		:= NIL
Local oBtn3		:= NIL
Local oBtn4		:= NIL
Local oBtn5		:= NIL

Default aDados	:= {}

aListBox := retListBox( aDados )

If Len( aListBox ) > 0

	aSize		:= MsAdvSize()

	aObjects	:= {}
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )

	aInfo	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj	:= MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE "Monitor" From aSize[7],0 to aSize[6],aSize[5] PIXEL

	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox ;
	Fields HEADER "","NF","Ambiente","Modalidade","Protocolo","Recomendação","Tempo","Tempo SEF"; 
	SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
	oListBox:SetArray( aListBox )
	oListBox:bLine := { || { aListBox[oListBox:nAT,1],aListBox[oListBox:nAT,2],aListBox[oListBox:nAT,3],aListBox[oListBox:nAT,4],aListBox[oListBox:nAT,5],aListBox[oListBox:nAT,6],aListBox[oListBox:nAT,7],aListBox[oListBox:nAT,8]} }

	@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT "OK"   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
	@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT "Mensagens"   	ACTION (StaticCall(SPEDNFE,Bt2NFeMnt,aListBox[oListBox:nAT][09])) OF oDlg PIXEL SIZE 035,011 //"Mensagens"
	@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT "Rec.XML"   	ACTION (StaticCall(SPEDNFE,Bt3NFeMnt,cIdEnt,aListBox[ oListBox:nAT,2 ],,,cModel)) OF oDlg PIXEL SIZE 035,011 //"Rec.XML"
	@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Refresh"	 	ACTION (aListBox := retListBox(aDados),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
	@ aPosObj[2,1],aPosObj[2,4]-200 BUTTON oBtn5 PROMPT "Schema"  		ACTION (StaticCall(SPEDNFE,Bt3NFeMnt,cIdEnt,aListBox[ oListBox:nAT,2 ],2,,cModel)) OF oDlg PIXEL SIZE 035,011 //"Schema"

	ACTIVATE MSDIALOG oDlg

EndIf

Return

/*---------------------------------------------------------------------------------------------------
Data     	:	18/07/2019
Função   	:	retListBox
Descrição	:	Função responsável por retornar a lista de NFe monitoradas
----------------------------------------------------------------------------------------------------*/
Static Function retListBox( aDocs )

	Local aDados	:= RetDoc( aDocs )
	Local nX		:= 0
	Local nY		:= 0
	Local aRet		:= {}
	Local aList		:= {}
	Local cUrl		:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
	Local nTpMnt	:= 1	// Monitor Faixa
	Local aParam	:= {}
	Local cModel	:= "55"	// NFe
	Local cSerie	:= ""
	Local cDocIni	:= ""
	Local cDocFim	:= ""
	Local nTamDoc	:= TamSX3( "F2_DOC" )[1]

	aSort( aDados,,,{|x,y| x[2]+x[1] < y[2]+y[1]} )
	
	If Len( aDados ) > 0
	
		cSerie 	:= aDados[1][2]
		cDocIni := aDados[1][1]
		cDocFim := aDados[1][1]
		
		For nX := 1 To Len( aDados )
		
			If aDados[nX][2] == cSerie

				If nX > 1
	
					If StrZero( Val( aDados[(nX-1)][1] ) + 1, nTamDoc ) <> aDados[nX][1]

						aList := StaticCall( SPEDNFE, getListBox, cIdEnt, cUrl, { cSerie, cDocIni, cDocFim, CtoD(""), CtoD("") }, nTpMnt, cModel,, .F. )
		
						For nY := 1 To Len( aList )
							AADD( aRet, aList[nY] )
						Next
			
						cSerie 	:= aDados[nX][2]
						cDocIni := aDados[nX][1]
						cDocFim := aDados[nX][1]

					Endif
			                            
				Endif
				
				If aDados[nX][1] < cDocIni
					cDocIni := aDados[nX][1]
				Endif
	
				If aDados[nX][1] > cDocFim
					cDocFim := aDados[nX][1]
				Endif
		
			Else
	
				aList := StaticCall( SPEDNFE, getListBox, cIdEnt, cUrl, { cSerie, cDocIni, cDocFim, CtoD(""), CtoD("") }, nTpMnt, cModel,, .F. )

				For nY := 1 To Len( aList )
					AADD( aRet, aList[nY] )
				Next
	
				cSerie 	:= aDados[nX][2]
				cDocIni := aDados[nX][1]
				cDocFim := aDados[nX][1]
			
			Endif
	
		Next
	
		aList := StaticCall( SPEDNFE, getListBox, cIdEnt, cUrl, { cSerie, cDocIni, cDocFim, CtoD(""), CtoD("") }, nTpMnt, cModel,, .F. )

		For nY := 1 To Len( aList )
			AADD( aRet, aList[nY] )
		Next

	Endif

Return( aRet )

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	ProcDanfe
Descrição	:	Função responsável pela impressão da Danfe
----------------------------------------------------------------------------------------------------*/
static function ProcDanfe( oObj )
    local aDados	   		:= oObj:aArray
    local aProcDoc   		:= RetDoc( aDados )
    local nDoc       		:= 0
    Local oDanfe			:= NIL
    Local cFilePrint		:= ""
    Local oSetup			:= NIL
    Local aDevice  			:= {}
    Local cSession  		:= GetPrinterSession()
    Local cError			:= ""
    Local nTipo				:= 0
    Local lAdjustToLegacy	:= .F. // Inibe legado de resolução com a TMSPrinter

    Private aListNF := {}

    begin sequence

	    if len(aProcDoc) == 0
	        Help( ,, "DANFE",, "Nenhum pedido foi selecionado", 1, 0,,,,,, {"Retorne a tela de monitoramento e selecione ao menos um pedido"} )
	        break
	    endif
	
	    if !FindFunction( "U_PRTNFESEF" )
		    Help( ,, "RDMAKE",, "Fonte de impressão do DANFE não compilado", 1, 0,,,,,, {"Acesse o portal do cliente baixe os fontes DANFEII.PRW e compile em seu ambiente"} )
	        break
	    endif
	
	    aListNF := aProcDoc
	
	    AADD(aDevice,"DISCO") // 1
	    AADD(aDevice,"SPOOL") // 2
	    AADD(aDevice,"EMAIL") // 3
	    AADD(aDevice,"EXCEL") // 4
	    AADD(aDevice,"HTML" ) // 5
	    AADD(aDevice,"PDF"  ) // 6
	
	    cFilePrint		:= "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
	    nLocal       	:= If( fwGetProfString( cSession, "LOCAL", "SERVER", .T. ) == "SERVER", 1, 2 )
	    nOrientation 	:= If( fwGetProfString( cSession, "ORIENTATION", "PORTRAIT", .T. ) == "PORTRAIT", 1, 2 )
	    cDevice     	:= If( Empty( fwGetProfString( cSession, "PRINTTYPE", "SPOOL", .T. ) ), "PDF", fwGetProfString( cSession, "PRINTTYPE", "SPOOL", .T. ) )
	    nPrintType      := aScan( aDevice, {|x| x == cDevice} )
	
	    oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)
	
	    // ----------------------------------------------
	    // Cria e exibe tela de Setup Customizavel
	    // OBS: Utilizar include "FWPrintSetup.ch"
	    // ----------------------------------------------
	    nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	
	    If ( !oDanfe:lInJob )
	
	        oSetup := FWPrintSetup():New(nFlags, "DANFE")
	        // ----------------------------------------------
	        // Define saida
	        // ----------------------------------------------
	        oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	        oSetup:SetPropert(PD_ORIENTATION , nOrientation)
	        oSetup:SetPropert(PD_DESTINATION , nLocal)
	        oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
	        oSetup:SetPropert(PD_PAPERSIZE   , 2)
	
	        If ExistBlock( "SPNFESETUP" )
	            Execblock( "SPNFESETUP" , .F. , .F. , {oDanfe, oSetup} )
	        Endif
	
	    EndIf
	
	    // ----------------------------------------------
	    // Pressionado botão OK na tela de Setup
	    // ----------------------------------------------
	    If oSetup:Activate() == PD_OK // PD_OK =1
	
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	        //³Salva os Parametros no Profile             ³
	        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        fwWriteProfString( cSession, "LOCAL"      , If( oSetup:GetProperty(PD_DESTINATION) == 1,"SERVER","CLIENT" ), .T. )
	        fwWriteProfString( cSession, "PRINTTYPE"  , If( oSetup:GetProperty(PD_PRINTTYPE) == 2,"SPOOL","PDF" ), .T. )
	        fwWriteProfString( cSession, "ORIENTATION", If( oSetup:GetProperty(PD_ORIENTATION )== 1,"PORTRAIT","LANDSCAPE" ), .T. )
	
	        // Configura o objeto de impressão com o que foi configurado na interface.
	        oDanfe:setCopies( val( oSetup:cQtdCopia ) )
	
	        If oSetup:GetProperty(PD_ORIENTATION) == 1
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	            //³Danfe Retrato DANFEII.PRW                  ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				U_PrtNfeSef( cIdEnt, /*cVal1*/, /*cVal2*/, oDanfe, oSetup, cFilePrint, /*lIsLoja*/, nTipo, .T. )
	        Else
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	            //³Danfe Paisagem DANFEIII.PRW                ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            //U_DANFE_P1(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/ )
	        EndIf
	
	    Endif

    end sequence

    oDanfe := Nil
    oSetup := Nil

return 

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	Exportar
Descrição	:	Função responsável por exportar o documento
----------------------------------------------------------------------------------------------------*/
static function Exportar( oObj )
    local aDados	:= oObj:aArray
    local aProcDoc	:= RetDoc( aDados )
    local nDoc      := 0
    Local aPerg   	:= {}
    Local cNota		:= ""
    Local cSerie	:= ""
    Local nTipo		:= 1
    Local aParam  	:= {Space(60)}

    begin sequence

	    if len(aProcDoc) == 0
	    	Help( ,, "Exporta",, "Nenhum pedido foi selecionado", 1, 0,,,,,, {"Retorne a tela de monitoramento e selecione ao menos um pedido"} )
	        break
	    endif
	
	    AADD(aPerg,{6,"Informe a Pasta",aParam[01],"",".T.","",80,.T.,"Arquivos XML |*.XML","",GETF_RETDIRECTORY+GETF_LOCALHARD,.F.})
	
	    If ParamBox(aPerg,"Exportar",@aParam,,,,,,,,.T.,.T.)
	
	        for nDoc := 1 to len(aProcDoc)
	            cNota	:= aProcDoc[nDoc,1]
	            cSerie	:= aProcDoc[nDoc,2]
	            
	            StaticCall(SPEDNFE,SpedPExp,cIdEnt,cSerie,cNota,cNota,RTrim(aParam[01]),.F.,,,"","",nTipo)
	        next
	
	    Endif
    
    end sequence

return 

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	VisDoc
Descrição	:	Função responsável por visulizar o documento
----------------------------------------------------------------------------------------------------*/
static function VisDoc( oObj )
	local nX		:= 0
	local aDados	:= oObj:aArray
    local cDoc      := ""
    local cSerie    := ""
    local cCliente  := ""
    local cLoja     := ""
    local nCont		:= 0

	dbSelectArea("SF2")
	dbSetOrder(1)

	for nX := 1 to len( aDados )

    	if aDados[nX][POS_MARCA]
            
			If nCont > 0
				if !MsgYesNo( "Deseja continuar visualizando ?", "Visualizar Documento" )
		    		Exit
	  			endif
	  		Endif

	        cDoc	:= aDados[nX][POS_DOC]
	        cSerie	:= aDados[nX][POS_SERIE]
	        cCliente:= aDados[nX][POS_CLIENTE]
	        cLoja 	:= aDados[nX][POS_LOJA]
	
	        if SF2->(dbSeek( xFilial("SF2") + cDoc + cSerie + cCliente + cLoja ))
				MsgRun("Aguarde... processando o documento " + RTrim(cDoc) + "/" + RTrim(cSerie),"Visualizar Documento",{|| Mc090Visual("SF2",SF2->(RecNo()),1)})
			else
		        Help( ,, "Visualizar Documento",, "Visualização inválida", 1, 0,,,,,, {"Documento [" + Rtrim(cDoc) + "/" + Rtrim(cSerie) + "] não encontrado."} )
			endif
			
			nCont++

    	Endif

 	Next

return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	Legenda
Descrição	:	Função responsável por apresentar a legenda
----------------------------------------------------------------------------------------------------*/
static function Legenda()

Local aLegenda := {}

Aadd(aLegenda, {"ENABLE"    ,"NF autorizada"})
Aadd(aLegenda, {"DISABLE"   ,"NF não transmitida"})
Aadd(aLegenda, {"BR_AZUL"   ,"NF Transmitida"})
Aadd(aLegenda, {"BR_PRETO"  ,"NF nao autorizada"})
Aadd(aLegenda, {"BR_CINZA"  ,"NF Uso Denegado"})

BrwLegenda("Legenda","Legenda",aLegenda)

Return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	ParaEvent
Descrição	:	Função responsável pela configuração de eventos
----------------------------------------------------------------------------------------------------*/
static function ParaEvent()

Private aPergEvento := { {}, {} }

SpedCCePar()

return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	TrfWizard
Descrição	:	Wizard de transmissao da nfe
----------------------------------------------------------------------------------------------------*/
Static Function TrfWizard(aDados,cSerie,cNotaIni,cNotaFim,lCTe,lRetorno)

Local cAlias       	:= "SF2"
Local aPerg       	:= {}
Local aParam      	:= {Space(If(TamSx3("F2_SERIE")[1] == 14,TamSx3("F2_SDOC")[1],TamSx3("F2_SERIE")[1])),Space(TamSx3("F2_DOC")[1]),Space(TamSx3("F2_DOC")[1]),CtoD(""),CtoD("")}
Local aTexto      	:= {}
Local aXML        	:= {}
local aAutoCfg      := {}
local bCaution      := {|| }
local cMsgCont 		:= ""
local cError	  	:= ""
Local cRetorno    	:= ""
Local cModalidade 	:= ""
Local cAmbiente   	:= ""
Local cVersao     	:= ""
Local cVersaoCTe  	:= ""
Local cVersaoMDFe 	:= ""
Local cVersaoDpec 	:= ""
Local cMonitorSEF 	:= ""
Local cSugestao   	:= ""
Local cParNfeRem  	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
Local cURL        	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cVersTSS   	:= ""
local cCaution   	:= ""
Local nX          	:= 0

Local lOk         	:= .T.
Local lUsaColab   	:= .F.
Local lSdoc       	:= TamSx3("F2_SERIE")[1] == 14

Local oWizard		:= Nil
Local cModel      	:= "55"

local oTBitmap1		:= Nil

Private oWS       	:= Nil
Private bFilTraBrw	:= {|| .T.}

Default lCTe      	:= .F.
Default lRetorno  	:= .F.

If lCTE
	cModel:= "57"
EndIf

if cModel <> "65"
	lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )
endif

If cSerie == Nil
	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfeRem,aPerg,1,aParam[01]),If(lSdoc,TamSx3("F2_SDOC")[1],TamSx3("F2_SERIE")[1]))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfeRem,aPerg,2,aParam[02]),TamSx3("F2_DOC")[1])
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfeRem,aPerg,3,aParam[03]),TamSx3("F2_DOC")[1])
Else
	MV_PAR01 := aParam[01] := cSerie
	MV_PAR02 := aParam[02] := cNotaIni
	MV_PAR03 := aParam[03] := cNotaFim
EndIf

aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.})	//"Nota fiscal final"

If lSdoc
	MV_PAR04 := aParam[04] := ParamLoad(cParNfeRem,aPerg,4,aParam[04])
	MV_PAR05 := aParam[05] := ParamLoad(cParNfeRem,aPerg,5,aParam[05])

	aadd(aPerg,{1,"Dt. Emissão De"	,aParam[04],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"
	aadd(aPerg,{1,"Dt. Emissão Até"	,aParam[05],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"
EndIf

If StaticCall(SPEDNFE,IsReady)

	If !Empty(cIdEnt)

		//Ambiente
		cAmbiente := getCfgAmbiente(@cError, cIdEnt, cModel)
		lOk := empty(cError)

		//Versao de Release do TSS
		If lOk
			cVersaoTSS := getVersaoTSS(@cError)
			lOk := empty(cError)
		EndIf

		//Cofiguração de  parâmetros(SEFAZ TSS ou TOTVS Colaboracao)
		If lOk .And. cVersaoTSS >= "1.35"
			setCfgParamSped(/*cError*/, /*cIdEnt*/, /*nAMBIENTE*/,/*nMODALIDADE*/, /*cVERSAONFE*/,/*cVERSAONSE*/,;
							 /*cVERSAODPEC*/,/*cVERSAOCTE*/, /*cNFEDISTRDANFE*/,/*cNFEENVEPEC*/,cModel)
		EndIf

		// obtem a Modalidade
		If lOk
			cModalidade    := getCfgModalidade(@cError, cIdEnt, cModel)
			lOk := empty(cError)
		EndIf

		//Obtem a Versao de trabalho da NFe
		If lOk
			cVersao        := getCfgVersao(@cError, cIdEnt, cModel )
			lOk := empty(cError)
		EndIf

		// Obtem a Versao de trabalho da CTe
		If lOk
			cVersaoCTe     := getCfgVersao(@cError, cIdEnt, "57" )
			lOk := empty(cError)
		EndIf

		// Obtem a Versao de trabalho da MDFe
		If lOk .And. findfunction ("getCfgMdfe") .And. nModulo <> 43
			cVersaoMDFe     :=  getCfgMdfe(@cError)[5]
			lOk := empty(cError)
		EndIf

		//Obtem a Versao de trabalho do Dpec NFe
		If lOk
			cVersaoDpec	   := getCfgVerDpec(@cError, cIdEnt)
			lOk := empty(cError)
		EndIf

		//Configura a Versao de trabalho do Epec CTe
		If lOk
			If cModel == "57"
				getCfgEpecCte()
			EndIf
		EndIf

		//Verifica o status na SEFAZ
		If lOk .And. !lUsaColab
			oWS:= WSNFeSBRA():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
			lOk := oWS:MONITORSEFAZMODELO()
			If lOk
				aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
				For nX := 1 To Len(aXML)
					// NFC-e tem um metodo de remessa especifico REMESSA3
					If aXML[nX]:cModelo == "65"		//NFC-e
						Loop
					Endif
					Do Case
						Case aXML[nX]:cModelo == "55"
							cMonitorSEF += "- NFe"+CRLF
							cMonitorSEF += STR0017+cVersao+CRLF	//"Versao do layout: "
							If !Empty(aXML[nX]:cSugestao)
								cSugestao += "Sugestão"+"(NFe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
							EndIf

						    //Consulta configuração de contingência automática no TSS
						    if( getCfgAutoCont( "0", cIdEnt, cModel, , , @aAutoCfg ) )

						        if( aAutoCfg[1] == "1")

						            cModalidade :=  getCfgModalidade(cError, cIdEnt, cModel, , .T.)

						            cMsgCont := CRLF + CRLF + space(20) + "Habilitada contingência automática para Modalidade " + getDescMod(aAutoCfg[2])
						            cCaution := CRLF + space(21) + STR0019

	                                bCaution := {|oObj| if(oTBitmap1 == nil, oTBitmap1 := TBitmap():New(02,29,260,184,,"UpdWarning.png",.T.,oObj, {||},,.F.,.F.,,,.F.,,.T.,,.F.), oTBitmap1:refresh()) , .T.}

						        else
						            cCaution := STR0019
						            cMsgCont := STR0020
						            bCaution := {||}
						        endif

						    endif

						Case aXML[nX]:cModelo == "57"
							cMonitorSEF += "- CTe"+CRLF
							cMonitorSEF += STR0017+cVersaoCTe+CRLF	//"Versao do layout: "
							If !Empty(aXML[nX]:cSugestao)
								cSugestao += 'STR0125'+"(CTe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
							EndIf
						Case aXML[nX]:cModelo == "58"
							cMonitorSEF += "- MDFe"+CRLF
							cMonitorSEF += STR0017+cVersaoMDFe+CRLF	//"Versao do layout: "
							If !Empty(aXML[nX]:cSugestao)
								cSugestao += 'STR0125'+"(MDFe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
							EndIf
					EndCase
					cMonitorSEF += Space(6)+"Versão da mensagem"+": "+aXML[nX]:cVersaoMensagem+CRLF //"Versão da mensagem"
					cMonitorSEF += Space(6)+"Código do Status"+": "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF //"Código do Status"
	                cMonitorSEF += Space(6)+"UF Origem"+": "+aXML[nX]:cUFOrigem //"UF Origem"
	                If !Empty(aXML[nX]:cUFResposta)
		                cMonitorSEF += "("+aXML[nX]:cUFResposta+")"+CRLF //"UF Resposta"
		   			Else
		   				cMonitorSEF += CRLF
		   			EndIf
	                If aXML[nX]:nTempoMedioSEF <> Nil
						cMonitorSEF += Space(6)+STR0071+": "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF //"Tempo de espera"
					EndIf
					If !Empty(aXML[nX]:cMotivo)
						cMonitorSEF += Space(6)+"Motivo"+": "+aXML[nX]:cMotivo+CRLF //"Motivo"
					EndIf
					If !Empty(aXML[nX]:cObservacao)
						cMonitorSEF += Space(6)+"Observação"+": "+aXML[nX]:cObservacao+CRLF //"Observação"
					EndIf
				Next nX
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Interface                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((lOk == .T. .or. lOk == Nil) .And. (!lCTe))
			aadd(aTexto,{})
			If lUsaColab
				aTexto[1] := 'STR0496'+" " //"Esta rotina tem como objetivo auxilia-lo na geração do arquivo da Nota Fiscal eletrônica para transmissão via TOTVS Colaboração."
				aTexto[1] += 'STR0494'+CRLF+CRLF //"Neste momento o sistema, está operando com a seguinte configuração: "
				cVersTSS 	:= " TC2.0 "//"Vesão - TSS ou TC2.0"
			Else
				aTexto[1] := STR0013+" " 		//"Esta rotina tem como objetivo auxilia-lo na transmissão da Nota Fiscal eletrônica para o serviço Totvs Services SPED. "
				aTexto[1] += STR0014+CRLF+CRLF //"Neste momento o Totvs Services SPED, está operando com a seguinte configuração: "
				cModalidade    := getCfgModalidade(@cError, cIdEnt, cModel,cModalidade)
				cVersTSS		:= " TSS: " + getVersaoTSS()
			EndIf

			aTexto[1] += STR0015+cAmbiente+CRLF //"Ambiente: "
			aTexto[1] += STR0016+cModalidade+CRLF	//"Modalidade de emissão: "
			aTexto[1] += STR0037+cVersTSS+CRLF	//"Vesão - TSS ou TC2.0"
			If !Empty(cSugestao)
				aTexto[1] += CRLF
				aTexto[1] += cSugestao
				aTexto[1] += CRLF
			EndIf
			aTexto[1] += cMonitorSEF

			aadd(aTexto,{})

			//"Assistente de transmissão da Nota Fiscal Eletrônica - Panel 1"
	 		oWizard := APWizard():New( cCaution,cMsgCont,STR0018+" por pedido",aTexto[1] ,{|| btmCaution(oTBitmap1, .F.) }, {|| .T.},.F., ,  )
 			@ 010,010 GET aTexto[1] MEMO SIZE 280, 125 READONLY PIXEL OF oWizard:oMPanel[1]

			//Mensagem de Notifocação de entrada em contingencia
			eval(bCaution, oWizard:oHeaderTitle)

			CREATE PANEL oWizard  ;
				HEADER STR0018 ;//"Assistente de transmissão da Nota Fiscal Eletrônica"
				MESSAGE ""	;
				BACK {|| btmCaution(oTBitmap1, .T.)} ;
				NEXT {|| ParamSave(cParNfeRem,aPerg,"1"),Processa({|lEnd| cRetorno := TrfNfe(cAlias,aDados,cAmbiente,cModalidade,cVersao,@lEnd)}),aTexto[02]:= cRetorno,.T.} ;
				PANEL

				cTexto := "Atenção !" + CRLF
				cTexto += "Serão transmitidas " + cValToChar( Len( aDados ) ) + " nota(s) do Protheus para o Totvs Services SPED." + CRLF + CRLF
				cTexto += "Aguarde o término da transmissão..."
	
				@ 010,010 GET cTexto MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[2]
	
			CREATE PANEL oWizard  ;
				HEADER STR0018;//"Assistente de configuração da Nota Fiscal Eletrônica"
				MESSAGE "";
				BACK {|| .T.} ;
				FINISH {|| lMnt := .T.} ;
				PANEL
				@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
	
			ACTIVATE WIZARD oWizard CENTERED
	
		ElseIf (lCTe) .And. (lOk)
	
			SpedNFeTrf(cAlias,aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersaoCTe,.T., lCTe,,aParam[04],aParam[05])
	
		EndIf

		lRetorno := lOk

	Else

		lRetorno := .F.

	EndIf

Else

	If (!lCTe)
		Aviso("SPED",STR0021,{'STR0114'},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	Else
		lRetorno := .F.
	EndIf

EndIf

Return

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	TrfNfe
Descrição	:	Funcao responsavel pela transmissao da nfe
----------------------------------------------------------------------------------------------------*/
Static Function TrfNfe(cAlias,aDados,cAmbiente,cModalidade,cVersao,lEnd)

Local nX		:= 0   
Local nCont		:= 0
Local cRet		:= ""
Local cDocIni	:= ""
Local cDocFim	:= ""
Local cSerie	:= ""
Local cTimeIni	:= Time()
Local nTamDoc	:= TamSX3( "F2_DOC" )[1]

aSort( aDados,,,{|x,y| x[2]+x[1] < y[2]+y[1]} )

If Len( aDados ) > 0

	cSerie 	:= aDados[1][2]
	cDocIni := aDados[1][1]
	cDocFim := aDados[1][1]
	
	For nX := 1 To Len( aDados )
	
		If aDados[nX][2] == cSerie
		
			If nX > 1

				If StrZero( Val( aDados[(nX-1)][1] ) + 1, nTamDoc ) <> aDados[nX][1]

					SpedNFeTrf( cAlias, cSerie, cDocIni, cDocFim, cIdEnt, cAmbiente, cModalidade, cVersao, @lEnd )

					cSerie 	:= aDados[nX][2]
					cDocIni := aDados[nX][1]
					cDocFim := aDados[nX][1]

				Endif

			Endif

			If aDados[nX][1] < cDocIni
				cDocIni := aDados[nX][1]
			Endif

			If aDados[nX][1] > cDocFim
				cDocFim := aDados[nX][1]
			Endif
				
		Else

			SpedNFeTrf( cAlias, cSerie, cDocIni, cDocFim, cIdEnt, cAmbiente, cModalidade, cVersao, @lEnd )

			cSerie 	:= aDados[nX][2]
			cDocIni := aDados[nX][1]
			cDocFim := aDados[nX][1]
		
		Endif

	Next

	SpedNFeTrf( cAlias, cSerie, cDocIni, cDocFim, cIdEnt, cAmbiente, cModalidade, cVersao, @lEnd )
    
Endif

cRet := "Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED." + CRLF
cRet += "Verifique se as notas foram autorizadas na SEFAZ, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe." + CRLF + CRLF
cRet += "Foram transmitidas " + cValToChar( Len( aDados ) ) + " nota(s) em " +  Left( ElapTime( cTimeIni, Time() ), 5 )

Return( cRet )

/*---------------------------------------------------------------------------------------------------
Data     	:	15/07/2019
Função   	:	BtmCaution
Descrição	:	Funcao responsavel por habilitar/desabilitar o BitMap
----------------------------------------------------------------------------------------------------*/
static function BtmCaution(oTBitmap1, lEnable)

    if( oTBitmap1 <> nil )
        oTBitmap1:lVisible := lEnable
        oTBitmap1:refresh()
    endif

return .T.
