#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"


/*/{Protheus.doc} COMP021_MVC


@author Carlos Eduardo Reinert	
@since 09/06/2019
@version 1.0

TODO
     [ ] - SX9
     [ ] - X2_UNICO
     [ ] - Descrição linha cabeçalho
     [ ] - Retirar os comentarios
     [ ] - Função separada pra execução da Query pois vou usar em outros lugares

/*/ 
User Function MAWSLNX90()
    Local oBrowse := FwLoadBrw("COMP021_MVC")

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SERÁ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("ZZ5")
    oBrowse:SetDescription('Tabela de Frete por Regiao [AVTMSM03] ')

    oBrowse:SetMenuDef("COMP021_MVC")

    oBrowse:SetAttach( .T. )
    oBrowse:SetOpenChart( .T. ) //Define se o gráfico virá aberto ou oculto no carregamento do browse

    //oBrowse:AddButton( "Pesq. CEP Regiao", {|| Self:fPesq()} )
    oBrowse:AddButton( "Pesq. CEP Regiao", {|| CursorWait(),FwMsgRun(,{|| fPesq() },"Aguarde","Pesquisando CEP..."), FwMsgRun(,{|| oBrowse:Refresh(.T.) },Nil,nil) ,  CursorArrow() } ,, 2 ) //"Confirmar"
    //aCampos := { {"ZZ6_REIGIAO", "Regiao ZZ6", "C", 3, 0, "@!"},  {"ZZ6_CEPDE", "CEP DE", "C", 8, 0, ""} }    
    //oBrowse:SetFieldFilter( aCampos )

Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
    // FUNÇÃO PARA CRIAR MENUDEF
    Local aRotina := FwMVCMenu("COMP021_MVC")
Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP021M")

    // INSTANCIA OS SUBMODELOS
    Local oStruZZ5 := FwFormStruct(1, "ZZ5")
    Local oStruZZ6 := FwFormStruct(1, "ZZ6")

    // DEFINE SE OS SUBMODELOS SERÃO FIELD OU GRID
    oModel:AddFields("ZZ5MASTER", NIL, oStruZZ5)
    oModel:AddGrid("ZZ6DETAIL", "ZZ5MASTER", oStruZZ6)

    // DEFINE A RELAÇÃO ENTRE OS SUBMODELOS
    oModel:SetRelation("ZZ6DETAIL", {{"ZZ6_FILIAL", "FwXFilial('ZZ6')"}, {"ZZ6_REGIAO", "ZZ5_REGIAO"}}, ZZ6->(IndexKey( 1 )))

    oModel:SetPrimaryKey({'ZZ5_FILIAL', 'ZZ5_REGIAO', 'R_E_C_N_O_' })
    
    // DESCRIÇÃO DO MODELO
    oModel:SetDescription( 'Tabela de Frete por Regiao [AVTMSM03] ' )

    // DESCRIÇÃO DOS SUBMODELOS
	oModel:GetModel('ZZ5MASTER'):SetDescription( 'Dados da Região' )
	oModel:GetModel('ZZ6DETAIL'):SetDescription( 'Lista de CEP por Região' )	
Return (oModel)

// INTERFACE GRÁFICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruZZ5 := FwFormStruct(2, "ZZ5")
    Local oStruZZ6 := FwFormStruct(2, "ZZ6")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("COMP021_MVC")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_ZZ5", oStruZZ5, "ZZ5MASTER")
    oView:AddGrid("VIEW_ZZ6", oStruZZ6, "ZZ6DETAIL")

    // CRIA BOXES HORIZONTAIS
    oView:CreateHorizontalBox("SUPERIOR", 30)
    oView:CreateHorizontalBox("INFERIOR", 70)

    // RELACIONA OS BOXES COM AS ESTRUTURAS VISUAIS
    oView:SetOwnerView("VIEW_ZZ5", "SUPERIOR")
    oView:SetOwnerView("VIEW_ZZ6", "INFERIOR")

    // DEFINE AUTO-INCREMENTO AO CAMPO
    oView:AddIncrementField("VIEW_ZZ6", "ZZ6_ITEM")

    // DEFINE OS TÍTULOS DAS SUBVIEWS
    oView:EnableTitleView("VIEW_ZZ6","CEP por Regiao")

    oView:SetViewProperty("VIEW_ZZ6", "GRIDFILTER", {.T.})
    oView:SetViewProperty("VIEW_ZZ6", "GRIDSEEK"  , {.T.})    

Return (oView)


Static function fPesq()
Local aPergs   := {}
Local nCep     := 0
Local aMvPar   := {}
Local nCntFor  := 1

Local cAlias   := GetNextAlias()

    // Salva os MV_PAR
    For nCntFor := 1 To 40
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nCntFor, 2, 0 ) ) )
    Next nCntFor

    MV_PAR01 := 0
    nCEP     := 0

    aAdd(aPergs, {1, "CEP", nCep,  "@E 99999-999", "NaoVazio()", "", ".T.", 80,  .F.})

    If ParamBox(aPergs, "Informe um CEP")

        cCEP := cValToChar( MV_PAR01 )

        BeginSql Alias cAlias
            SELECT
                ZZ6_REGIAO, ZZ5_VALFRE, ZZ5_DESREG
            FROM %table:ZZ6% ZZ6, %table:ZZ5% ZZ5
            WHERE 1=1
              AND ZZ6.ZZ6_FILIAL= %xFilial:ZZ6% AND ZZ5.ZZ5_FILIAL= %xFilial:ZZ5% 
              AND ZZ6.%NotDel% AND ZZ5.%NotDel%
              AND ZZ5.ZZ5_REGIAO = ZZ6.ZZ6_REGIAO
              AND %Exp:cCEP% BETWEEN ZZ6.ZZ6_CEPDE AND ZZ6.ZZ6_CEPATE
    
        EndSql

        cQuery := GetLastQuery()[2]
        VarInfo( "cQuery", cQuery )

        // Caso nao acha nada,  vai trazer em branco
        cRegiao := (cAlias)->ZZ6_REGIAO

        If Empty( cRegiao )

            FwAlertInfo( "CEP sem amarração de regiao")
        Else

            cMsg := "A Região do CEP: " + Transform( Val( cCep ), "@R 99999-999" ) + ' é a  <b><font color="#FF0000">' + (cAlias)->ZZ5_DESREG + '</font></b>' + ;
                    CRLF + CRLF + ;
                    "Com Valor de Frete: " + Transform( (cAlias)->ZZ5_VALFRE, "@E 999,999.99" )  
            FwAlertInfo( cMsg )
        EndIf
    EndIf

    //oBrowse:Refresh(.T.)

    // Restaura os MV_PAR
    For nCntFor := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nCntFor, 2, 0 ) ) := aMvPar[ nCntFor ]
    Next nCntFor

Return .T.


