#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE 'FWMVCDef.CH'

#DEFINE HML		"2"
#DEFINE PRD		"1"

#DEFINE ENTER   CHR(10)+cHR(13)

#DEFINE PAGAMENTO_PAGO      68  // 68 - Due
#DEFINE PAGAMENTO_APROVADO  80  // 80 - Paid

#DEFINE PESSOA_JURIDICA     "C"
#DEFINE PESSOA_FISICA       "P"

#DEFINE TIPO_PESSOA_JURIDICA     67
#DEFINE TIPO_PESSOA_FISICA       80

#DEFINE ENDERECO_COBRANCA       "66"
#DEFINE ENDERECO_ENTREGA        "68"

#DEFINE FORMAPAGTO_BOLETO           "3"    
#DEFINE FORMAPAGTO_CARTAO_CREDITO   "1"
#DEFINE FORMAPAGTO_PIX              "19"

#DEFINE OPERATION_UPDATE        "U"

#DEFINE PRODUTO_TIPO_KIT        "1"
#DEFINE CATALOGO_TIPO_KIT       "7"
#DEFINE CATALOGO_TIPO_PRODUTO   "5"

#DEFINE MARKET_PLACE            "Hub"

/*
    TODO

    [ X ] - tratar endereço de entrega no cadastro do cliente
        [ ] - tanto em cliente novo
        [ ] - como em cliente já cadastrado

        - no sistema temos  03  endereços:  endereço padrao, cobrança e entrega
        - no LINx temos quais, quantos e como vai ser a relação  ???

        ja achei
        no  Customer  tem o  Endereço Prinicpal
        no  OrderSale que vem o endereço de entrega e o endereço de cobrança

        em que momento se  troca  ou onde está  amarrado o endereõ de entrega ao cliente / pedido  ???


        Entregue em PRD
        Precisa de mais testes


    [ ] - Normalmente se   altera   os dados  do cliente  toda vez que vem um novo pedido
        - como trataremos esse escopo ?
        - vamos nos ater a alguns campos para  sempre  alterar ?

        
        Isso está pendente de discução
        Vai ficar pra  terceira  onda


    [ X ] - tratar o tipo de frete no pedido de venda
          Entregue em PRD
          Precisa de mais testes

    [ X ] - tratar o valor do frete no pedido de venda
          Entregue em PRD
          Precisa de mais testes

    [ ] - tratar mais de uma condição de pagamento, quando vir de PIX, CC e até boleto
        - lembrar que o titulo vão ser dois SE1
          - 1 pra o cliente que compra e sempre será a parcela 001 pois é a vista e esse não deve nada pra MA
          - n para o cartão de credito, então essa informação de quantas parcelas que sera usada por uma rotina 
            que ja temos no projeto,  tem que ser usada, isto é, teremos que gravar a condição de pagemento pra uso posterior

        Entrega na  segunda  onda

    [ X ] - tratar a transportadora vinda na integração
        - poderia fazer uma regquisição a API de cadastro de meio de entrega e pegar o CNPJ e buscar no SN4
            - achei o campo CNPJ via plataforma, mas via  API não achei
            - /v1/Configuration/API.svc/web/GetDeliveryMethod
            - chamei a Agrada e tive o retorno que não temos essa possibilidade de se obter o CNPJ da tranportadora
            - seria apenas uma   alternativa,  mas vamos seguir com a ideia de  "de - para"

            Entrege em PRD
            Resolvido usando o campo no LINX "ID Integração" onde deve colocar o CNPJ do cadastro do Protheus

    [ X ] - tratar a forma de pagamento
        - PTH                           LINX        PaymentType     Alias       PaymentMethodID 
          BO - Boleto                   Boleto      3               Banco       950
          R$ - Carteira a Vista         PIX         19              PIX         944
          CC - Cartão de Credito        CC          1               VISA        959
          CH - Cheque                   ???
          DC - Deposito em CC           MaketPlace  21                          973
          PS - Pague Seguro             ???

          Temos esses campos que podemos analisar: SELECT * FROM SX3010 WHERE X3_CAMPO  IN ( 'E1_FORMA', 'E1_FORMREC', 'E1_FORMPG', 'C5_FORMAPG', 'C5_FORPG', 'E4_FRORMA')

          Atualmente o campo  C5_FORPG  eh  campo de usuario   e   não  influencia no  SE1


          Entrega em PRD
          Precisa de mais testes

    [ ] - Forma de pagamento na visão  financeiro - SE1
        - Campo Prefixo  ou  Campo padrão de forma de pagamento
        - observar o que vem do faturamento na geração da nota

        - podemos uar a naturza financeira  quebrando por forma de pagamento

        Vamos ver como vai se comportar a entraga na segunda onda, ficando esse item para terceira  onda

    [ X ] - tabela de preço ja validamos e mesmo colocanndo a 007,  está ficando o que vem da integração
          - dar uma segunda validada

          Entrega em PRD

    [ X ] - campo integra WMS sempre "N"

           Em PRD  criamos um  parametro que diz se vai como  "S"  ou "N"
           Atualmente está desligadom isto é, não vai direto pro WMS via esse campo

    [ x ] - não permitir que vindo do WMS alterar a transportadora nem o tipo de frete   
          - Esse é o fonte que ajusta a transportadora quando se altera pelo WMS - MAPWMS08.PRW
          - Tem outros campos que são alterados
          - E, lembro que temos uma  gap  relativo a criar um novo registro  SC9 que aocorreu no  Mais Negócios

          Entregue em PRD
          Precisa de mais testes

    [ ] - o fonte que gera a nota fiscal automática quando vem do  WMS é esse: MAPWMS08.PRW
        é nele que vai ter que ser feito a implementação de baixa automática do financeiro
        https://tdn.totvs.com/pages/releaseview.action?pageId=568947413
        https://tdn.totvs.com/display/public/PROT/FINA070+-++Baixas+a+Receber+-+Protheus+12
        https://tdn.totvs.com/pages/releaseview.action?pageId=306856119 - Desdobramento - E1_DESDOBR


        Vai entrar na  segunda  onda

    [ ] - não permitir a ação de  residuo  e  cancelamento de pedido de venda  origem  LINX pelo  Protheus
        - alinhar isso melhor
        - analisar


        Vai para a  terceira  onda,  esse item

    [ ] - verificar junto a Agrada
        [ ] - tem que informar a LINX na Fila de Integração que o pedido foi integrado com sucesso pra sair da fila em ambiente de PRD
        [ X ] - verificar qual  (API)   para gravar  os dados da NF  apos autorização

        Vai para a  terceira  onda,  esse item

    [ X ] - temos que analisar a questão do  "de-para" das transportadoras 

          Entregue em PRD
          Usando "ID Integração" pelo  CNPJ


    [ ] - temos que analisar a questão do  "de-para" de condição de pagamento que tem no LIX  vs  PTH
    
    [ ] - tem mais algo no cadastro de cliente que tem que ajustar ?
    [ ] - tem mais alguma informarção que precisamos gravar no PV ?
    
    [ ] - ainda tem a questão do envio do XML, PDF da NF boleto por e-mail ao cliente,  bem como  deixar  disponível na plataforma do LINX
    
    [ ] - vamos ter uma margem de segurança no estoque do e-commerce a considerar via parametro ?
    
    [ x ] - tratar o KIT - SKU do SKU
       
          Entregue em PRD
          Precisa de muito mais testes

    [ X ] - Incluir um pedido de venda com mais de um item

           Entregue em PRD

    [ X ] - é preciso "chumbar" um telefone no cadastro do cliente porque está retornando do SEFAZ solicitando telefone
          e no cadastro do LINX não é obrigatorio

          Entregue em PRD
          Mas ao visualziar no cadastro do Protheus,  tá  "*******"


    [ ] - pagamento via BOLETO,  está dando ocorerncia de  "não pagamento"

    [ ] - no controle de estoque vamos ter lote/sub-lote/endereçamento ?

    [ ] - Temos que tratar das categorias de produtos na LINX  x  PTH
           isso na integração de  PRODUTO - SB1

    [ ] - tratar o  NSU / dados "extras"  no  primeiro titulo finacneiro, do cliente que comprou e ja será baixado    
    [ ] - sao  três  momentos
        - momento 1 : o titulo a vista do cliente que comprou ja será baixado e criado automaticamente
        - momento 2 : a criação dos titulos em parcelas feitas por CC ou PIX
        - momento 3 : a conciliação vinda do carão do cartão de credito

        https://tdn.totvs.com/pages/releaseview.action?pageId=306856119 - Desdobramento - E1_DESDOBR

    [ ] - Cancelamento da compra efetuado pelo cliente 
        [ ] - pedido não faturados
        [ ] - pedidos já faturados

        Observar o cancelamento de notas em outros estados devido ao przo de cancelamento do SEFAZ


    [ ] - Analise de credito para compras de CNPJ tem que bloquear no credito no pedido para que ja na integração, de forma automatizado
          ja inclue o cliente e o pedido,  só que entra em credito, quando CNPJ
          já em CPF libera o credito direto

          CNPJ novos,  pois CNPJ ja na base e liberados devem seguir

    [ ] - validar pedidos de venda vindo do LINX onde o cliente está na base,  contudo  foi ou está  bloqueado
          pois o pedido de venda ja integra automaticamente

          lembrar nesses casos de " não tirar da fila "


    [ ] - na geração do titulo financeiro  seria bom ter um  prefixo / serie  separada         

    [ X ] - cobra do cliente o o frete ou seja  C - CIF
        [ ] - fazre um peiddo acima  de 600,00  
        [ ] - fazer um peiddo abaixo de 600,00 pra ver se tem frete

    [ ] - Valor do IPI  está  "embutido"  no preço de venda  vindo do  LINX ?
        - porque o sistema já calcula os impostos (IPI)  via  TES


        Para a conciliaçao de cartão de credito:

        https://tdn.totvs.com/display/public/PROT/Conciliador+Pagamentos+e+Vendas+-+Financeiro+%28Contas+a+Receber%29+-+P12
        https://centraldeatendimento.totvs.com/hc/pt-br/articles/360058597953-Cross-Segmentos-Backoffice-Protheus-SIGAFIN-FINA916-N%C3%A3o-faz-a-concilia%C3%A7%C3%A3o-de-vendas | Cross Segmentos - Backoffice Protheus - SIGAFIN - FINA916 - Não faz a conciliação de vendas – Central de Atendimento TOTVS
        https://tdn.totvs.com/display/public/PROT/Conciliador+Pagamentos+e+Vendas+-+Financeiro+%28Contas+a+Receber%29+-+P12 | Conciliador Pagamentos e Vendas - Financeiro (Contas a Receber) - P12 - Linha Microsiga Protheus - TDN
        https://tdn.totvs.com/display/public/PROT/TOTVS+Pagamentos+Digitais | TOTVS Pagamentos Digitais - Linha Microsiga Protheus - TDN
        https://produtos.totvs.com/ficha-tecnica/totvs-pagamento-instantaneo/ | Tudo sobre o TOTVS Pagamento Instantâneo para realização de Pix.
        https://www.totvs.com/blog/servicos-financeiros/conciliacao-de-cartoes/ | Conciliação de cartões: o que é, vantagens e como fazer - TOTVS
        https://compila.com.br/conciliador-de-cartao-de-credito/ | Conciliador de Cartão de Crédito – COMPILA
        http://www.fbsolutions.com.br/?s=Concilia%C3%A7%C3%A3o%20de%20Cart%C3%B5es | Conciliação De Cartões | FBS Consultoria
        https://tdfcont.com.br/2017/10/02/integracao-erp-e-conciliadora-de-cartoes-solucao-tdf-e-sansix/ | Integração ERP e conciliadora de cartões de crédito/débito: solução TDF e Sansix | TDF
        https://centraldeatendimento.totvs.com/hc/pt-br/articles/1500007187161-Cross-Segmento-Backoffice-Linha-Protheus-SIGAFIN-FINA910-Qual-a-diferen%C3%A7a-entre-Sitef-Antigo-FINA910-e-Sitef-Novo-FINA918

    [ X ] - verificar API de retorno do PV faturado e autorizado ao LINX


    Link

    [ ] - https://tdn.totvs.com/pages/releaseview.action?pageId=714237242
    [ ] - https://tdn.totvs.com/pages/releaseview.action?pageId=625947585
    [ ] - https://tdn.totvs.com/pages/releaseview.action?pageId=552590004
    [ ] - https://tdn.totvs.com/pages/releaseview.action?pageId=641461876
    [ ] - https://tdn.totvs.com/pages/releaseview.action?pageId=625947585
    [ ] - https://tdn.totvs.com/display/public/PROT/DT_Integracao_Ecommerce_Ciashop
    [ ] - https://centraldeatendimento.totvs.com/hc/pt-br/articles/360000583388-Cross-Segmentos-TOTVS-Backoffice-Linha-Protheus-SIGAFAT-Como-utilizo-ExecAuto-para-prepara%C3%A7%C3%A3o-da-nota-de-sa%C3%ADda

    [ X ] - Duplicado por causa do camo  ""Operation": "I",  e  "Operation": "U",
          no JSON da Fila de Integraçãp
          pelo alinhamento efetuado junto ao Douglas sera integrado somente quando  U

    [ X ] - Ajustar pedido com mais de um  item

    [ ] - o correto seria usar a função  SaldoSB2()  para ober o saldo em estoque


    [ ] - uma melhoria consideravel a ser realizada.
          todos os cadastro / entidade no LINX  tem um campo  "IntegrationID",  que podemos usar para colocar o
          código que temos no Protheus. Como exemplo o código do vendedor do Protheus estar nessa campo no LINX
          quem vai ver no JSON, e é só fazer a procura pelo campo"chave" do Rrotheus por esse "IntegrationID".
          Esse campo no LINX é um campo  de usuario,  um campo livre pra uso mesmo.


    [ ] - Mudar nome da função que é usado no  JOB

*/

User Function MA_2_WSLNX()
Local cDiaSemana     := "" 
Local cHora          := "" 
Local cRodaFimSemana := "" 
Local cHoraInicial   := "" 
Local cHoraFinal     := "" 

    // Achei um GAP a ser resolvido
       // Quando ocorrer um  error.log  no meio da integração,  os pedidos  posteriores,  não serão  integrados
       // e terá que ser feito uma  analise

	RpcSetType(3)
	RpcSetEnv("01","0101",,,"FAT")  //  Colocar um usuario pra ser especificop no DBACESS

    cDiaSemana     := Upper(AllTrim(DiaSemana( dDataBase )))
    cHora          := Time()
    cRodaFimSemana := SuperGetMV( "ES_LINXSD", .F., .F. )
    cHoraInicial   := SuperGetMV( "ES_LINXHI", .F., "07:00" )
    cHoraFinal     := SuperGetMV( "ES_LINXHF", .F., "19:00" )

    If cRodaFimSemana  .or.  !( cDiaSemana $ "DOMINGO/SABADO" )  

        If cHora > cHoraInicial .and.  cHora <= cHoraFinal

    	    U_MAWSLNX20()
        EndIf
    EndIf

	RpcClearEnv()
Return

User Function MAWSLNX20()
Local lRetorno    := .T.
Local oLinx       := FATBCAIntegracaoLinx():New()
Local aHeader     := oLinx:aHeadStr
Local cURLBase    := oLinx:cURLBase

Local lIsBlind    := IsBlind()
Local cLockName   := ProcName() + FWCodFil()
Local cDesc       := "Integração ERP x Linx - Fila de Integração"
Local cPerg       := ""
Local aInfoCustom := {}
Local cTxt        := ""
Local nTimeIni    := 0
Local oProcess    := NIL

Local lLogCV8     := SuperGetMV( "MA_LNXCV8", .F., .F. )

    TMSLogMSg( "INFO", "MAWSLNX20 -  Iniciando Integração Fila de Integracao - LINX -  Empresa:" + FWGrpCompany() )

	BEGIN SEQUENCE
    
        If oLinx:Requisitos()  .and.  oLinx:Conectado()

            // Controle de semaforo pra não rodar por mais de um usuario
            If !LockByName( cLockName,.F.,.F.,.T. ) 
            
                If !lIsBlind

                    cTxt := Iif( !lIsBlind, "por outro usuário", "pelo schedule" )
                    FWAlertInfo( "Rotina está sendo processada " + cTxt + "  -  " + cLockName )
                Else

                    TMSLogMSg("INFO", "Rotina está sendo processada por outro usuário - " + cLockName )
                Endif
                Break
            EndIf

            // Se não estiver rodando pelo  SCHEDULE
            if !lIsBlind .AND. !FwIsInCallStack("U_MAWSLNX90")

                nTimeIni := Time()
                oProcess := tNewProcess():New( 'U_MAWSLNX20', cDesc, {|oSelf| fProcFlIRun(oSelf) }, cDesc, cPerg, aInfoCustom,,, cDesc,.T.,.T. )
                FWAlertInfo( "Tempo de Duração " + ElapTime(nTimeIni, Time()) )
            else

                fProcFlIRun()
            endif

            UnLockByName( cLockName,.F.,.F.,.T. )
        Else
            
            FWAlertError( "Plataforma de Integração InaAtiva" )
        EndIf

	END SEQUENCE
    

    oLinx:Destroy()
    FWFreeObj( oLinx )    
    FWFreeObj( oProcess )       
    TMSLogMSg( "INFO", "MAWSLNX20 -  Finalizando Integração Fila de Integracao - LINX -  Empresa:" + FWGrpCompany() )

Return lRetorno

/*
   
*/
Static Function fProcFlIRun( oProcess )
Local lRetorno := .T.
Local aArea    := FWGetArea()
Local oJson    := NIL
Local oPage    := NIL
Local cJsonEnv := ""
Local cQueueID := SuperGetMV( "ES_QUEIEID", .F., 17 )

    oJson := JsonObject():New()

	If SuperGetMv( "MA_LNXAMB", .F., HML ) == HML

        oJson[ 'QueueID' ] := cQueueID //17
    Else
        
        oJson[ 'QueueID' ] := cQueueID // 01
    EndIf
    oJson[ 'QueueAlias' ]    := "erp-queue"
    oJson[ 'Attempts' ]      := 0
    oJson[ 'Where' ]         := ""
    oJson[ 'WhereMetadata' ] := ""
    oJson[ 'OrderBy' ]       := ""

    // -- oPage
    oPage                    := JsonObject():New()
    oPage[ "PageIndex" ]     := 0
    oPage[ "PageSize" ]      := 1000
    oJson[ 'Page' ]          := oPage

    // -- 
    cJsonEnv := oJson:ToJson()   
    
    FilaIntegracao( cJsonEnv )  

FWFreeObj( oJson )
FWFreeObj( oPage )
FWRestArea( aArea )
Return lRetorno

/*
   
*/
Static Function FilaIntegracao( cJsonEnv )
Local oRestClient     := NIL
Local cError          := ""
Local cRetorno        := ""
Local nStatus         := 0
Local lRetorno        := .T.
Local cHTTPError      := ""
Local llChkStatusCode := .T.
Local cHTTPCode       := ""
Local oJson           := JsonObject()          :New()

Local oLinx           := FATBCAIntegracaoLinx():New()
Local aHeader         := oLinx:aHeadStr
Local cURLBase        := oLinx:cURLBase
Local cPath           := "/Queue/API.svc/web/SearchQueueItems

Local nCntFor         := 0

// Variaveis para o  GravaLOG
Local cDataEnv        := Date()
Local cHorEnv         := Time() // FWTimeStamp(5)
Local cDataRec        := ""
Local cHorRec         := ""
Local cJsonRec        := ""
Local cTabela         := "FIL"
Local nRecno          := 0
Local cIdInteg        := ""
Local cComplMsgrun    := ""

    oRestClient := FWRest():New(cURLBase)
    oRestClient:SetPath(cPath)
    oRestClient:SetChkStatus(.F.)

    oRestClient:SetPostParams(cJsonEnv) 

    cDataRec        := Date()
    cHorRec         := Time() // FWTimeStamp(5)
    
    lSucess         := oRestClient:Post(aHeader)
    cRetorno        := oRestClient:GetResult()
    cError          := oRestClient:GetLastError()
    llChkStatusCode := oRestClient:GetChkStatus()
    cHTTPCode       := oRestClient:GetHTTPCode()
    nStatus         := HTTPGetStatus(@cHTTPError)

    do case
    case nStatus >= 200  .and.  nStatus <= 299

        // FwAlertWarning( cHTTPCode )
        cRetorno := DecodeUTF8(oRestClient:getResult(), "cp1252")
        cJsonRec := oJson:FromJson(cRetorno)

        VarInfo( "JSON Fila Integracao", oJson )

        If cJsonRec == NIL

            nError        := Len( oJson:GetJsonObject( 'Errors' ) )
            lError        := oJson:GetJsonObject( 'IsValid' )
            nQtdPV        := Len( oJson:GetJsonObject( 'Result' ) )
            nQtdPedVenda  := Val( DecodeUTF8( oJson:GetJsonObject( 'Page' ):GetJsonText( 'RecordCount' ), "cp1252" ) )
            cErrorMessage := DecodeUTF8( oJson:GetJsonObject( 'Page' ):GetJsonText( 'ErrorMessage' ), "cp1252" )

            If lError  .and.  nQtdPedVenda  >  0

                oLinx:GravaLog( cIdInteg, cDataEnv, cHorEnv, cDataRec, cHorRec, cJsonEnv, cRetorno, cTabela, nRecno, ;
                                cURLBase + cPath, "POST", FunName(), lError, cHTTPCode, cErrorMessage )

                For nCntFor = 1 to nQtdPV

                    cEntityKeyName := DecodeUTF8( oJson:GetJsonObject( 'Result' )[nCntFor]:GetJsonText( 'EntityKeyName' ), "cp1252" )
                    lOperation     := oJson:GetJsonObject( 'Result' )[nCntFor]:GetJsonText( 'Operation' )  ==  OPERATION_UPDATE

                    If cEntityKeyName == "OrderNumber"  .and.  lOperation

                        cEntityKeyValue := DecodeUTF8( oJson:GetJsonObject( 'Result' )[nCntFor]:GetJsonText( 'EntityKeyValue' ), "cp1252" )
                        cQueueItemID    := DecodeUTF8( oJson:GetJsonObject( 'Result' )[nCntFor]:GetJsonText( 'QueueItemID' ), "cp1252" )

                        cComplMsgrun :=  cValToChar( nCntFor ) + " de " + cValToChar( nQtdPV )
                        FWMsgRun(, {|oSay| LNXWSOrder( cEntityKeyValue, nQtdPV, cComplMsgrun ) }, "Aguarde", "Processando o pedido de venda vindo do LINX - " + cComplMsgrun + " ......" )
                    EndIf
                Next nCntFor
            ElseIf nQtdPedVenda  ==  0

                FwAlertInfo( "Retorno da Plataforma informa que não tem nenhum pedido a ser integrado!" + ENTER + "Verifique o Monitor de Filas" )
            Else

                FwAlertWarning( cErrorMessage )
            EndIf
        Else

            FWAlertError( "JSON Errado")
        EndIf
    case nStatus >= 300  .and.  nStatus <= 399

        FwAlertWarning( cHTTPCode )
    case nStatus >= 400  .and.  nStatus <= 499            

        FwAlertWarning( cHTTPCode )
    case nStatus >= 500  .and.  nStatus <= 599

        FwAlertWarning( cHTTPCode )
    end case

FWFreeObj( oLinx )    
FreeObj(oJson)
FreeObj(oRestClient)
Return lRetorno

/*
   
*/
Static Function LNXWSOrder( cNumPedVendaLinx, nQtdPV, cComplMsgrun )
Local lRetorno        := .T.
Local oRestClient     := NIL
Local cError          := ""
Local cRetorno        := ""
Local nStatus         := 0

Local cHTTPError      := ""
Local llChkStatusCode := .T.
Local cHTTPCode       := ""
Local oJson           := JsonObject()          :New()

Local oLinx           := FATBCAIntegracaoLinx():New()
Local aHeader         := oLinx:aHeadStr
Local cURLBase        := oLinx:cURLBase
Local cPath           := "/Sales/API.svc/web/GetOrderByNumber"

Local JaExisteSA1     := .F.

Local cCodCli         := ""
Local cLojaCli        := ""

// Variaveis para o  GravaLOG
Local cDataEnv        := Date()
Local cHorEnv         := Time() // FWTimeStamp(5)
Local cDataRec        := ""
Local cHorRec         := ""
Local cJsonRec        := ""
Local cTabela         := "PED"
Local nRecno          := 0
Local cIdInteg        := ""

Local lOkCliente      := .T.

    oRestClient := FWRest():New(cURLBase)
    oRestClient:SetPath(cPath)
    oRestClient:SetChkStatus(.F.)

    oRestClient:SetPostParams( cNumPedVendaLinx ) 

    cDataRec        := Date()
    cHorRec         := Time() // FWTimeStamp(5)

    lSucess         := oRestClient:Post(aHeader)
    cRetorno        := oRestClient:GetResult()
    cError          := oRestClient:GetLastError()
    llChkStatusCode := oRestClient:GetChkStatus()
    cHTTPCode       := oRestClient:GetHTTPCode()
    nStatus         := HTTPGetStatus(@cHTTPError)

    do case
    case nStatus >= 200  .and.  nStatus <= 299

        // FwAlertWarning( cHTTPCode )
        cRetorno := DecodeUTF8(oRestClient:getResult(), "cp1252")
        cJsonRec := oJson:FromJson(cRetorno)

        VarInfo( "JSON Pedido", oJson )

        If cJsonRec == NIL

            cPaymentStatus := oJson:GetJsonObject( 'PaymentStatus' ) 
            cStatusIDOrder := oJson:GetJsonObject( 'OrderStatusID' )
            cIDOrder       := oJson:GetJsonObject( 'OrderID' )
            cCountItems    := oJson:GetJsonObject( 'ItemsCount' )
            nItems         := Len( oJson:GetJsonObject( 'Items' ) )
            cIDCustomer    := oJson:GetJsonObject( 'CustomerID' )
            cCustomerName  := oJson:GetJsonObject( 'CustomerName' )

            cSA1ChaveUnica := ""
            If oJson:GetJsonObject( 'CustomerType' ) == PESSOA_JURIDICA

                cSA1ChaveUnica := oJson:GetJsonObject( 'CustomerCNPJ' )
            ElseIf oJson:GetJsonObject( 'CustomerType' ) == PESSOA_FISICA

                cSA1ChaveUnica := oJson:GetJsonObject( 'CustomerCPF' )
            EndIf

            cNumber        := oJson:GetJsonObject( 'OrderInvoice' ):GetJsonText( 'Number' )
            cCode          := oJson:GetJsonObject( 'OrderInvoice' ):GetJsonText( 'Code' )

            If AllTrim(cNumber) <> 'null'  .and.  AllTrim(cCode) == 'null'

                FWAlertInfo("Pedido ja emitido nota fiscal: " + cNumber )
            ElseIf AllTrim(cNumber) <> 'null'  .and.  AllTrim(cCode) <> 'null' 

                FWAlertInfo("Pedido ja emitido nota fiscal e com a Chave NFe: " + cNumber + " / " + cCode )
            ElseIf cPaymentStatus <> PAGAMENTO_APROVADO

                FWAlertInfo("Pedido não está com o status de  PAGAMENTO  PAGO" + ENTER + ENTER + "Status: " + cValToChar(cPaymentStatus) )
            ElseIf lError  

                // FWAlertInfo( "Integração com sucesso" )

                cJsonEnv := cNumPedVendaLinx
                oLinx:GravaLog( cIdInteg, cDataEnv, cHorEnv, cDataRec, cHorRec, cJsonEnv, cRetorno, cTabela, nRecno, ;
                                cURLBase + cPath, "POST", FunName(), lError, cHTTPCode, cErrorMessage )                

                lOkGravaSA1     := .F.
                cCodCli         := ""
                cLojaCli        := ""
                lBloqueado      := .F.
                FWMsgRun(, {|oSay| lOkCliente := MyCRMA980ExeAuto( cIDCustomer, cSA1ChaveUnica, @JaExisteSA1, @cCodCli, @cLojaCli, @lBloqueado, cCustomerName, nQtdPV ) }, "Aguarde", "Verificando o cliente - " + cComplMsgrun + "......" )
                

                // Se o clinte existe na base mas estiver bloqueado
                If JaExisteSA1  .and.  lBloqueado

                    FWAlertInfo("BLOQEUADO")
                    FWAlertInfo("Pedido não sera integrado")
                Else 

                    // senão,  ou ja vai estar incluido ou  será incluido em tempo de execução
                    If lOkCliente

                        FWMsgRun(, {|oSay| MyMATA410ExeAuto( oJson, cCodCli, cLojaCli, nItems, nQtdPV ) }, "Aguarde", "Montando e executando a inclusão do pedido - " + cComplMsgrun + "......" )
                    Else

                        FwAlertWarning( "Pedido não incluido devido a ocorrencia informada pelo cadastro do cliente" )
                    EndIf
                EndIf
            Else

                FwAlertWarning( cErrorMessage )
            EndIf
        Else

            FWAlertError( "JSON Errado")
        EndIf
    case nStatus >= 300  .and.  nStatus <= 399

        FwAlertWarning( cHTTPCode )
    case nStatus >= 400  .and.  nStatus <= 499            

        FwAlertWarning( cHTTPCode )
    case nStatus >= 500  .and.  nStatus <= 599

        FwAlertWarning( cHTTPCode )
    end case

FWFreeObj(oLinx)    
FreeObj(oJson)
FreeObj(oRestClient)

Return lRetorno

/*
   
*/
Static Function MyCRMA980ExeAuto( cIDCustomer, cSA1ChaveUnica, JaExisteSA1, cCodCli, cLojaCli, lBloqueado, cCustomerName, nQtdPV ) 
Local lRetorno        := .F.
Local oRestClient     := NIL
Local cError          := ""
Local cRetorno        := ""
Local nStatus         := 0

Local cHTTPError      := ""
Local llChkStatusCode := .T.
Local cHTTPCode       := ""
Local oJson           := JsonObject()          :New()

Local oLinx           := FATBCAIntegracaoLinx():New()
Local aHeader         := oLinx:aHeadStr
Local cURLBase        := oLinx:cURLBase
Local cPath           := "/Profile/API.svc/web/GetCustomer"

Local aSA1Auto        := {}
Local nOpcAuto        := 3 //MODEL_OPERATION_INSERT

// Variaveis para o  GravaLOG
Local cDataEnv        := Date()
Local cHorEnv         := Time() // FWTimeStamp(5)
Local cDataRec        := ""
Local cHorRec         := ""
Local cJsonRec        := ""
Local cTabela         := "CLI"
Local nRecno          := 0
Local cIdInteg        := ""
Local cLogExecAuto    := ""

Local oJsonCellPhone  := JsonObject():New()
Local cTipoCli        := ""
Local cAddressNotes   := ""

Local nQtdExibePV     := SuperGetMV( "ES_EXIBEPV", .F., 10 )

Private lMsErroAuto   := .F.

    If ClienteJaExiste( cSA1ChaveUnica, @cCodCli, @cLojaCli, lBloqueado, @cTipoCli )

        JaExisteSA1 := .T.
        lRetorno    := .T.

        cDataRec    := Date()
        cHorRec     := Time() // FWTimeStamp(5)
        cJsonEnv    := ""
        cJsonRec    := ""
        cTabela     := "SA1"
    Else
    
        oRestClient := FWRest():New(cURLBase)
        oRestClient:SetPath(cPath)
        oRestClient:SetChkStatus(.F.)

        oRestClient:SetPostParams( cValToChar( cIDCustomer ) ) 

        cDataRec        := Date()
        cHorRec         := Time() // FWTimeStamp(5)        

        lSucess         := oRestClient:Post(aHeader)
        cRetorno        := oRestClient:GetResult()
        cError          := oRestClient:GetLastError()
        llChkStatusCode := oRestClient:GetChkStatus()
        cHTTPCode       := oRestClient:GetHTTPCode()
        nStatus         := HTTPGetStatus(@cHTTPError)

        do case
        case nStatus >= 200  .and.  nStatus <= 299

            // FwAlertWarning( cHTTPCode )
            cRetorno := DecodeUTF8(oRestClient:getResult(), "cp1252")
            cJsonRec := oJson:FromJson(cRetorno)

            If cJsonRec == NIL
            
                aSA1Auto := {}

                cName             := cCustomerName   // oJson:GetJsonObject( 'Name' )
                cEMail            := oJson:GetJsonObject( 'Email' )
                cStatusIdCustomer := oJson:GetJsonObject( 'CustomerStatusID' )
                cTypeCustomer     := oJson:GetJsonObject( 'CustomerType' )
                cLineAddress      := oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'AddressLine' )
                cCity             := oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'City' )
                cComplem          := oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'Name' )
                cNeighBourHood    := oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'Neighbourhood' )
                cNumber           := oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'Number' )
                cPostalCode       := oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'PostalCode' )
                cState            := oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'State' )
                cAddressNotes     := AllTrim(Upper(oJson:GetJsonObject( 'Address' )[1]:GetJsonText( 'AddressNotes' )))

                // o campo  Contact  no  JSON  é do tipo  Objeto JSON  quando chega aqui :-)
                //oJsonCellPhone   := oJson:GetJsonObject( 'Contact' ):ToJson()                
                oJsonCellPhone:FromJson( ( oJson:GetJsonObject( 'Contact' ):ToJson() ) )
                cCellPhone        := oJsonCellPhone:GetJsonText( 'CellPhone' )

                If lError

                    // FWAlertInfo( "Integração com sucesso" )

                    cTipoPessoa := ""
                    If cTypeCustomer == TIPO_PESSOA_JURIDICA

                        cTipoPessoa := "J"
                    ElseIf cTypeCustomer == TIPO_PESSOA_FISICA

                        cTipoPessoa := "F"
                    EndIf
                    
                    cCity    := Upper( AllTrim( oLinx:NoAcento( cCity ) ) )
                    cCodMun  := GetAdvFVal( "CC2", "CC2_CODMUN", FWxFilial("CC2") + cState + cCity, 4, "" )

                    // Retira Caracteres
                    cName          := Upper( oLinx:NoAcento( cName ) )
                    cLineAddres    := Upper( oLinx:NoAcento( cLineAddres ) )
                    cNeighBourHood := Upper( oLinx:NoAcento( cNeighBourHood ) )
                    cState         := Upper( oLinx:NoAcento( cState ) )
                    cEMail         := Upper( oLinx:NoAcento( cEMail ) )

                    // Pelo alinhado vamos utilizar a condição de pagamento pelo pedido de veda
                    // cCondPagto := "007"

                    // Pelo alinhado vamos utilizar a natureza financeira pelo pedido de venda
                    //cNaturFinan := "111101"

                    //aAdd(aSA1Auto,{"A1_COD" , ,Nil})
                    aAdd(aSA1Auto,{"A1_LOJA"   , "0001"          , NIL})
                    aAdd(aSA1Auto,{"A1_NOME"   , substring( cName, 1, 60 )           , NIL})
                    aAdd(aSA1Auto,{"A1_NREDUZ" , substring( cName, 1, 30 )           , NIL}) 
                    aAdd(aSA1Auto,{"A1_TIPO"   , "F"             , NIL})
                    aAdd(aSA1Auto,{"A1_END"    , cLineAddres     , NIL}) 
                    aAdd(aSA1Auto,{"A1_BAIRRO" , cNeighBourHood  , NIL}) 
                    aAdd(aSA1Auto,{"A1_EST"    , cState          , NIL}) 
                    aAdd(aSA1Auto,{"A1_MUN"    , cCity           , NIL}) 
                    aAdd(aSA1Auto,{"A1_COD_MUN", cCodMun         , NIL}) 
                    aAdd(aSA1Auto,{"A1_INSCR"  , "ISENTO"        , NIL}) 
                    aAdd(aSA1Auto,{"A1_EMAIL"  , cEMail          , NIL}) 
                    aAdd(aSA1Auto,{"A1_PESSOA" , cTipoPessoa     , NIL}) 
                    aAdd(aSA1Auto,{"A1_CGC"    , cSA1ChaveUna    , NIL}) 

                    If cAddressNotes != "NULL"
                    
                        aAdd(aSA1Auto,{"A1_COMPLEM", cAddressNotes   , NIL}) 
                    EndIf

                    If Empty( cCellPhone )

                        aAdd(aSA1Auto,{"A1_TEL"    , "519926647"     , NIL}) 
                    Else

                        aAdd(aSA1Auto,{"A1_TEL"    , cCellPhone     , NIL}) 
                    EndIf

                    // Risco: No cadastro de cliente, informe o risco que este cliente terá podendo ser A,B,C,D ou E,
                      // sendo que risco A sempre irá liberar o crédito e risco E sempre irá bloquear o crédito
                      // https://tdn.totvs.com/pages/releaseview.action?pageId=225950030
                    If cTipoPessoa == 'J'
                    
                        aAdd(aSA1Auto,{"A1_RISCO"  , "E"             , NIL}) 
                    Else

                        aAdd(aSA1Auto,{"A1_RISCO"  , "A"             , NIL}) 
                    EndIf

                    // Se o tipo da pessoa no cadastro é Fisica (CPF), o campo "Contribuinte" é Não
                    If cTipoPessoa == "F"

                        aAdd(aSA1Auto,{"A1_CONTRIB"  , "2"           , NIL}) 
                    EndIf

                    aSA1Auto := FWVetByDic(aSA1Auto, "SA1")
                    
                    MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto )
                    
                    If lMsErroAuto 

                        cLogExecAuto := MostraErro() 
                    Else
            
                        cCodCli  := SA1->A1_COD
                        cLojaCli := SA1->A1_LOJA

                        If nQtdPV <= nQtdExibePV   
                        
                            FWAlertInfo("Cliente incluído com sucesso!" + ENTER + ENTER + "Cliente: " + CCodcli + " / " + cLojaCli )
                        EndIf


                        IncClienteCFGTrib( cCodCli, cLojaCli )

                        lRetorno  := .T.
                    EndIf

                Else

                    FwAlertWarning( cErrorMessage )
                EndIf
            Else

                FWAlertError( "JSON Errado")
            EndIf
        case nStatus >= 300  .and.  nStatus <= 399

            FwAlertWarning( cHTTPCode )
        case nStatus >= 400  .and.  nStatus <= 499            

            FwAlertWarning( cHTTPCode )
        case nStatus >= 500  .and.  nStatus <= 599

            FwAlertWarning( cHTTPCode )
        end case
     EndIf

    // FWAlertInfo( "Integração com sucesso" )

    oLinx:GravaLog( cIdInteg, cDataEnv, cHorEnv, cDataRec, cHorRec, cJsonEnv, cRetorno, cTabela, nRecno, ;
                    cURLBase + cPath, "POST", FunName(), lError, cHTTPCode, cErrorMessage, cLogExecAuto )     

FreeObj(oJsonCellPhone)
FWFreeObj(oLinx)    
FreeObj(oJson)
FreeObj(oRestClient)

Return lRetorno

/*

*/
Static Function ClienteJaExiste( cSA1ChaveUnica, cCodCli, cLojaCli, lBloqueado, cTipoCli )
Local lRetorno  := .T.
Local cAliasSA1 := GetNextAlias()
Local nQtdreg   := 0

    // Observar os parametros  MV_VALCNPJ e MV_VALCPF  -  como fica nesses casos

    BeginSql Alias cAliasSA1

       SELECT
              SA1.A1_COD,
              SA1.A1_LOJA,
              SA1.A1_CGC,
              SA1.A1_MSBLQL,
              SA1.R_E_C_N_O_, 
              SA1.A1_PESSOA
         FROM
              %Table:SA1% SA1
        WHERE 1 = 1
          AND SA1.A1_FILIAL = %xFilial:SA1%
          AND SA1.A1_CGC = %Exp:cSA1ChaveUnica%
          AND SA1.%NotDel%
        ORDER BY %Order:SA1%
    EndSql

	cQuery := GetLastQuery()[2]	
	count to nQtdReg

    If nQtdReg <= 0

        // Não tem cliente cadastrado
        lRetorno := .F.
    Else

        (cAliasSA1)->(dbGoTop())
        lBloqueado := (cAliasSA1)->(A1_MSBLQL) == "2"
        cCodCli    := (cAliasSA1)->(A1_COD)
        cLojaCli   := (cAliasSA1)->(A1_LOJA)
        cTipoCli   := (cAliasSA1)->(A1_PESSOA)
    EndIf

    (cAliasSA1)->(dbCloseArea())

Return lRetorno 

/*
   
*/
Static Function MyMATA410ExeAuto( oJson, cCodCli, cLojaCli, nQtdItems, nQtdPV )
Local aCabec  := {}
Local aLinha  := {}
Local aItens  := {}
Local nCntFor := 1

// Variaveis para o  GravaLOG
Local cDataEnv         := Date()
Local cHorEnv          := Time() //FWTimeStamp(5)
Local cDataRec         := ""
Local cHorRec          := ""
Local cTabela          := "SC5"
Local nRecno           := 0
Local cIdInteg         := ""
Local cRetorno         := ""
Local cLogExecAuto     := ""
Local cURLBase         := ""
Local cPath            := ""
Local cHTTPCode        := ""
Local cErrorMessage    := ""

Local oLinx            := FATBCAIntegracaoLinx():New()

Local lNewKIT          := SuperGetMV( "ES_NEWKIT", .F., .F. )

Local cAtualRisco      := ""
Local cTipoPessoa      := ""

Local nCntFor1         := 1

Local nKITAmountItem   := 0
Local nAmountItem      := 0

Local cLandmark        := ""

Local nQtdExibePV      := SuperGetMV( "ES_EXIBEPV", .F., 10 )

Local cItem            := StrZero( 0, TamSX3("C6_ITEM")[1] )

Private lMsHelpAuto    := .T.
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.

    // 
    cLandmark := ""
    AnalisaEnderecoEntrega( oJson, cCodCli, cLojaCli, @cAtualRisco, @cTipoPessoa, @cLandmark )

    If cTipoPessoa == "F"
    
        AtualizaRiscoCliente( cCodCli, cLojaCli, "A" )
    else
        
        AtualizaRiscoCliente( cCodCli, cLojaCli, "E" )
    EndIf

    // Dados Frete
    cCarrierName         := oJson:GetJsonObject( 'DeliveryMethods' )[1]:GetJsonText( 'CarrierName' )
    cDeliveryMethodAlias := oJson:GetJsonObject( 'DeliveryMethods' )[1]:GetJsonText( 'DeliveryMethodAlias' )
    nAmount              := Val( oJson:GetJsonObject( 'DeliveryMethods' )[1]:GetJsonText( 'Amount' ) )
    //nAmount              := Val( oJson:GetJsonObject( 'DeliveryMethods' ):GetJsonText( 'DeliveryAmount' ) )    
    cIdDeliveryMethod    := oJson:GetJsonObject( 'DeliveryMethods' )[1]:GetJsonText( 'DeliveryMethodID' )
    nDeliveryAmount      := oJson:GetJsonObject( 'DeliveryAmount' )

    // Teansportadora
    // poderiamos fazer uma requisição a API de trsnportadora e pegar pelo CNPJ e buscar no SA4
        // não rolou essa ideia
        // Vamos mudar pra usar o  CNPJ pelo IntegrationID
    cTranspIntegrationID := oJson:GetJsonObject( 'DeliveryMethods' )[1]:GetJsonText( 'IntegrationID' )    
    cTransportadora      := GetAdvFVal( "SA4", "A4_COD", FWxFilial("SA4") + cTranspIntegrationID, 3, "" )

    // Forma de Pagamento
    cPaymentMethodID  := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonText( 'PaymentMethodID' )
    cAlias            := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonObject( 'PaymentInfo' ):GetJsonText( 'Alias' )
    cPaymentType      := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonObject( 'PaymentInfo' ):GetJsonText( 'PaymentType' )

    // Dados do vendedor
    /*
        cVendIntegrationID   := oJson:GetJsonObject( 'SalesRepresentative' ):GetJsonText( 'SalesRepresentativeID' )    
        cVendedor            := GetAdvFVal( "SA3", "A3_COD", FWxFilial("SA3") + cVendIntegrationID, 9, "" )
        If Vazio( cVendedor )

            cVendedor   := SuperGetMV( "ES_LINXSA4", .F., "000156" )
        EndIF
    */
    cSalesRepresentative := oJson:GetJsonObject( 'SalesRepresentative' ):GetJsonText( 'SalesRepresentativeID' )
    if NaoVazio( cSalesRepresentative )

        cVendedor := GetAdvFVal( "SA3", "A3_COD", FWxFilial("SA3") + cSalesRepresentative, 9, "000156", .T. )
    EndIf

    // Dados chumbando por enquanto
    cTabPreco    := SuperGetMV( "ES_LINXDA1", .F., "007"    )
    cCondPagto   := SuperGetMV( "ES_LINXSE4", .F., "007"    )    
    cNaturFinan  := SuperGetMV( "ES_LINXSED", .F., "111109" ) 

    // Inicio ExecAuto
    aAdd( aCabec,{"C5_FILIAL"  , FwCodFil()	    					    , Nil} )		
    aAdd( aCabec,{"C5_TIPO"    , "N"								    , Nil} )
    aAdd( aCabec,{"C5_CLIENTE" , PadR( cCodCli , TamSX3("A1_COD")[01] ) , Nil} )
    aAdd( aCabec,{"C5_LOJACLI" , PadR( cLojaCli, TamSX3("A1_LOJA")[01]) , Nil} )
    aAdd( aCabec,{"C5_TABELA"  , cTabPreco							    , Nil} )
    aAdd( aCabec,{"C5_VEND1"   , cVendedor							    , Nil} )
    aAdd( aCabec,{"C5_CONDPAG" , cCondPagto							    , Nil} )
    aAdd( aCabec,{"C5_NATUREZ" , cNaturFinan    					    , Nil} )

    If nDeliveryAmount > 0  

        aAdd( aCabec,{"C5_TRANSP"  , cTransportadora 					    , Nil} )
        aAdd( aCabec,{"C5_TPFRETE" , "C"     					            , Nil} )
        aAdd( aCabec,{"C5_FRETE"   , nAmount 					            , Nil} )
    Else

        aAdd( aCabec,{"C5_TRANSP"  , "      " 					            , Nil} )
        aAdd( aCabec,{"C5_TPFRETE" , "C"     					            , Nil} )
        aAdd( aCabec,{"C5_FRETE"   , 0 					                    , Nil} )
    EndIf
    
    If SuperGetMV ( "ES_LINXWMS", .F., .T. )  == .T.

        aAdd( aCabec,{"C5_INTWMS"  , "S" 					                , Nil} )
    Else
    
        aAdd( aCabec,{"C5_INTWMS"  , "N" 					                , Nil} )    
    EndIf  

    // 20240621 - Eder
    aAdd( aCabec,{"C5_OBSNFSE" , cLandmark                                  , Nil} )

    // Dados pra idenficicar se é  compra  pela  loja  ou  marketplace
    lCreatedChannel   := Alltrim(oJson:GetJsonObject( 'CreatedChannel' )) == MARKET_PLACE  // "Hub"  ou  "WebSite"
    lMarketPlaceBrand := Upper(AllTrim(oJson:GetJsonObject( 'MarketPlaceBrand' ))) == "STORE"
    lWebSiteID        := oJson:GetJsonObject( 'WebSiteID' ) == 21 // 21 - MarketPlace  e  1 - Loja Principal
    lWebSiteName      := oJson:GetJsonObject( 'WebSiteName' ) != "Loja Principal"  // "MarketplaceOut"
    nTamNroPVLinx     := Len( oJson:GetJsonObject( 'OrderNumber' ) ) > 7  
    cMarketPlaceBrand := AllTrim(Upper(oJson:GetJsonObject( 'MarketPlaceBrand' )))

    If lCreatedChannel
    
        aAdd( aCabec, {"C5_OBSEXPE" , "Pedido vindo e-Commerce LINX" + CHR(10)+CHR(13) + cMarketPlaceBrand, Nil} )
    ElseIf  !lCreatedChannel

        aAdd( aCabec, {"C5_OBSEXPE" , "Pedido vindo e-Commerce LINX", Nil} )
    EndIf

    // Amarração com o campo de usuario  Forma de Pagamento no PV
    do case
    case cPaymentType == FORMAPAGTO_BOLETO

        // 20240626 - Ajustado com Eder
        aAdd( aCabec,{"C5_FORPG", "R$" 					                , Nil} )
    case cPaymentType == FORMAPAGTO_CARTAO_CREDITO

        aAdd( aCabec,{"C5_FORPG", "CC" 					                , Nil} )
    case cPaymentType == FORMAPAGTO_PIX

        aAdd( aCabec,{"C5_FORPG", "R$" 					                , Nil} )
    case lCreatedChannel

        aAdd( aCabec,{"C5_FORPG", "DC" 					                , Nil} )
    otherwise

        aAdd( aCabec,{"C5_FORPG", "  " 					                , Nil} )    
    endcase

    // FWVetByDic( aCabec, "SC5" )

    // Monta o  vetor  pra  SC6  principalmente para os  descontos
    For nCntFor := 1 To nQtdItems

        cBundleKitDiscount := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'BundleKitDiscount' )
        cCatalogItemType   := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'CatalogItemType' )

        // Se bloco lido do JSON é  um  KIT  e  o SKU  é um  KIT
        If cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_KIT

            // Pego o preço do KIT e não do item do KIT
            nQtdAmountItem    := Len( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' ) )
            nKITAmountItem    := 0
            For nCntFor1 := 1 to nQtdAmountItem
            
                lAmountPIX := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Reference' ) == "4"

                // Efetuar uma conferencia apenas para compras PIX
                If lAmountPIX  .and.  cPaymentType == FORMAPAGTO_PIX
            
                    nKITAmountItem := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Amount' ) )
                EndIf
            Next nCntFor1
        ElseIf cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_PRODUTO // Se bloco lido do JSON é  um  KIT  e  o SKU  é um  produto  do  KIT

            nPrice          := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Price' ) )
            nQty            := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Qty' ) )
            //nDiscountAmount := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'DiscountAmount' ) )
            nDiscountAmount := oJson:GetJsonObject( 'DiscountAmount' )

            cProductID := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'ProductID' )
            cSkuID     := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'SkuID' )

        ElseIf cBundleKitDiscount != PRODUTO_TIPO_KIT    // Se  for  apenas  produto / SKU  normal, ou seja,  nao é um produto de um KIT

            nPrice     := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Price' ) )
            nQty       := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Qty' ) )

            /*
                se  o  desconto  é no pedido  é assim:  nDiscountAmount := oJson:GetJsonObject( 'DiscountAmount' )
                se  o  desconto  é no item    é sssim   nDiscountAmount := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'DiscountAmount' ) )

                pendente com a Natalia e Eder: vai ter desconto por item e por pedido ?
            */
            nDiscountAmount := oJson:GetJsonObject( 'DiscountAmount' )

            nQtdAmountItem    := Len( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' ) )
            nAmountItem       := 0
            For nCntFor1 := 1 to nQtdAmountItem
            
                lAmountPIX := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Reference' ) == "4"

                // Efetuar uma conferencia apenas para compras PIX
                If lAmountPIX  .and.  cPaymentType == FORMAPAGTO_PIX
            
                    nAmountItem := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Amount' ) )
                EndIf
            Next nCntFor1                
        EndIf

        // Quando é  totalmente  KIT  não  leva pro Protheus
           // Mudei o codigo porque tinha um  "loop"  antes
        If !( cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_KIT )
            cCodProd  := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'SKU' )

            // Mesma  regra que vem do  ZOHO
            CalculaIPI( @nPrice, cCodProd  )

            cTipoOper := SuperGetMV( "ES_LINXSFM", .F., "01"  )
            // cTES      := SuperGetMV( "ES_LINXSF4", .F., "570" )  //--> Vai ser por  TES Inteligente            
            cItem     := Soma1(cItem)

            aLinha := {}
            aAdd( aLinha, {"C6_ITEM"   , cItem	 , Nil} )
            aAdd( aLinha, {"C6_PRODUTO", cCodProd, Nil} )
            aAdd( aLinha, {"C6_QTDVEN" , nQty 	 , Nil} )
            aAdd( aLinha, {"C6_QTDLIB" , nQty	 , Nil} )
            aAdd( aLinha, {"C6_PRCVEN" , nPrice	 , Nil} )
            aAdd( aLinha, {"C6_OPER"   , cTipoOper, Nil} )
            // 
            If cBundleKitDiscount != PRODUTO_TIPO_KIT  
                
                If  nAmountItem > 0

                    aAdd( aLinha, {"C6_VALDESC"   , nAmountItem /*+ nDiscountAmount*/, Nil} )
                ElseIf nDiscountAmount > 0   .and.  .F.  // 

                    aAdd( aLinha, {"C6_VALDESC"   , nDiscountAmount, Nil} )
                EndIf
            ElseIf cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_PRODUTO  .and.  nKITAmountItem > 0

                aAdd( aLinha, {"C6_VALDESC"   , nKITAmountItem /*+ nDiscountAmount*/, Nil} )
            EndIf            

            If nDiscountAmount > 0

                aAdd( aCabec,{"C5_DESCONT", nDiscountAmount, Nil} )    
                FWVetByDic( aCabec, "SC5" )
            EndIf

            aAdd( aItens, aLinha )			
        EndIf
    Next nCntFor

    // se o   nDiscountAmount  > 0
    // altero  o  C6_VALDESC   somando o  nDiscountAmount   no  primeiro  item



    // FWVetByDic( aItens, "SC6" )
    VarInfo( "SC5", aCabec )
    VarInfo( "SC6", aItens )

    // 20240626 - Alinhado com Eder
    BEGIN TRANSACTION

        MSExecAuto( {|x,y,z| MATA410(x,y,z)}, aCabec, aItens, 3 )	

    END TRANSACTION

    cHorRec := Time() // FWTimeStamp(5)

    If lMsErroAuto

        GetAutoGRLog()        
        cLogExecAuto := MostraErro()
    Else   
    
        If !Empty( SC5->C5_NUM  )

            cNroPVLinx := oJson:GetJsonObject( 'OrderNumber' )
	        
            If SC5->(FieldPos("C5_ZIDLINX")) 
            
                RecLock("SC5", .F. )
                SC5->C5_ZIDLINX := cNroPVLinx
                SC5->(MsUnLock())
            EndIf
        EndIf

        // Volta o risco que estava antes
        AtualizaRiscoCliente( cCodCli, cLojaCli, cAtualRisco )

        If nQtdPV <= nQtdExibePV            

            FWAlertInfo( "Integração do pedido de venda realizado com sucesso" + ;
                        ENTER + ENTER + "Nro Pedido LINX: " + cNroPVLinx + ; 
                        ENTER + ENTER + "Nro Pedido ERP : " + SC5->C5_NUM )

            FWMsgRun(, {|oSay| LNXQueueItems() }, "Aguarde", "Atualizando Status do Pedido na Plataform do LINX......")                     

            /*
                Implmentado no  PE_FISENVNFE.PRW

                // Aguardando retorno do chamado  https://centraldeatendimento.totvs.com/hc/pt-br/requests/19469224
                cInstallments  := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonText( 'Installments' )

                If cPaymentType == FORMAPAGTO_CARTAO_CREDITO  .and.  cInstallments <> "1"
                
                    FWMsgRun(, {|oSay| LINXTitReceberCC() }, "Aguarde", "Criando os titulos no financeiro relativo as parcelas do cartão de crédito......")                     
                EndIf
            */
        EndIf
    EndIf

    oLinx:GravaLog( cIdInteg, cDataEnv, cHorEnv, cDataRec, cHorRec, cJsonEnv, cRetorno, cTabela, nRecno, ;
                    cURLBase + cPath, "POST", FunName(), lError, cHTTPCode, cErrorMessage, cLogExecAuto )   

FreeObj( oLinx )

Return .T.

/*
    Atualiza Fila de Integração

*/
Static Function LNXQueueItems()
Local lRetorno := .T.

    // FwAlertInfo( "Atualização do Stuatus do Pedido na Fila de Integração!" + ENTER + ENTER + "Em desenvolvimento....")
    
Return lRetorno


/*
    Cria os titulos no financeiro relativo as parcelas do cartão de crédito

*/
Static Function LINXTitReceberCC()
Local lRetorno := .T.

    // FwAlertInfo( "Criando os titulos no financeiro relativo as parcelas do cartão de crédito!" + ENTER + ENTER + "Em desenvolvimento....")
    
Return lRetorno


/*
    Atualiza Endereco de Entrega vindo no pedido de venda
    
    Criou um novo cliente, mas o endereço de entrega é diferente do endereço principal
    Vale o Endereço de entrega

    Agora se o cliente já exite, mas mudou o endereço de entrega,  tem que ajustar também o endereço principal


    Observei que tá faltando atualizar o  campo  Bairro
    Tem que ver  TODOS  os campos


    Tava bloquenado por causa da  condição de paamento  039  que tá no pronto de entrada
*/
Static Function AnalisaEnderecoEntrega( oJson, cCodCli, cLojaCli, cAtualRisco, cTipoPessoa, cLandmark )
Local lRetorno      := .T.
Local nCntFor       := 0
Local oModel        := Nil
Local cCodMun       := ""
Local cNotesAddress := ""

DEFAULT cLandmark   := ""

    // Atualmente estou alterando diretamente,  tendo mudado ou não e somenete os campos do endereço
    SA1->(dbSelectArea("SA1"))
    If SA1->( MsSeek( FWxFilial("SA1") + cCodCli + cLojaCli ) )

        cAtualRisco := SA1->A1_RISCO
        cTipoPessoa := SA1->A1_PESSOA

        oModel := FwLoadModel("CRMA980")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()            

        nQtdEndereço      := Len( oJson:GetJsonObject( 'Addresses' ) )

        For nCntFor = 1 to nQtdEndereço 

            cLineAddress      := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'AddressLine' )
            cCity             := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'City' )
            cComplem          := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'Name' )
            cNeighBourHood    := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'Neighbourhood' )
            cNumber           := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'Number' )
            cPostalCode       := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'PostalCode' )
            cState            := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'State' )

            cLineAddress      := Upper( NoAcento( cLineAddress ) )
            cCity             := Upper( NoAcento( cCity ) )
            cComplem          := Upper( NoAcento( cComplem ) )
            cNeighBourHood    := Upper( NoAcento( cNeighBourHood ) )
            cState            := Upper( NoAcento( cState ) )

            cCodMun  := GetAdvFVal( "CC2", "CC2_CODMUN", FWxFilial("CC2") + cState + cCity, 4, "" )

            cAddressType      := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'AddressType' )
            cNotesAddress     := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'AddressNotes' )

            If cAddressType == ENDERECO_COBRANCA

                oModel:SetValue("SA1MASTER","A1_ENDCOB" , cLineAddress + ", " + cNumber )
                oModel:SetValue("SA1MASTER","A1_CEPC"   , cPostalCode                   )
                oModel:SetValue("SA1MASTER","A1_ESTC"   , cState                        )
                oModel:SetValue("SA1MASTER","A1_MUNC"   , cCity                         ) 
                oModel:SetValue("SA1MASTER","A1_COD_MUN", cCodMun                       )    
                oModel:SetValue("SA1MASTER","A1_COMPLEC", cNotesAddress                 )
                oModel:SetValue("SA1MASTER","A1_BAIRROC" , cNeighBourHood               )                                                
            ElseIf cAddressType == ENDERECO_ENTREGA

                cLandmark := oJson:GetJsonObject( 'Addresses' )[nCntFor]:GetJsonText( 'Landmark' )
                If AllTrim(Upper(cLandmark)) == "NULL"

                    cLandmark := ""
                EndIf

                oModel:SetValue("SA1MASTER","A1_ENDENT" , cLineAddress + ", " + cNumber )
                oModel:SetValue("SA1MASTER","A1_CEPE"   , cPostalCode                   )
                oModel:SetValue("SA1MASTER","A1_ESTE"   , cState                        )
                oModel:SetValue("SA1MASTER","A1_MUNE"   , cCity                         ) 
                oModel:SetValue("SA1MASTER","A1_CODMUNE", cCodMun                       )    
                oModel:SetValue("SA1MASTER","A1_COMPENT", cNotesAddress                 )                              
                oModel:SetValue("SA1MASTER","A1_BAIRROE", cNeighBourHood                )   

                // Endereço Principal pelo enderço de entrega
                oModel:SetValue("SA1MASTER","A1_END"    , cLineAddress + ", " + cNumber )
                oModel:SetValue("SA1MASTER","A1_CEP"    , cPostalCode                   )
                oModel:SetValue("SA1MASTER","A1_EST"    , cState                        )
                oModel:SetValue("SA1MASTER","A1_MUN"    , cCity                         ) 
                oModel:SetValue("SA1MASTER","A1_COD_MUN", cCodMun                       ) 
                oModel:SetValue("SA1MASTER","A1_COMPLEM", cNotesAddress                 ) 
                oModel:SetValue("SA1MASTER","A1_BAIRRO" , cNeighBourHood                )                
            EndIf            
        Next nCntFor

        If oModel:VldData()

            oModel:CommitData()
            TMSLogMSg( "INFO", "MAWSLNX20 - Registro Alterado: " + cCodCli + " - " + cLojaCli )
        Else

            VarInfo( "Erro ao alterar", oModel:GetErrorMessage() )

            // Gravar no arquivo de LOG ( SZ0 )
        EndIf

        oModel:DeActivate()
        oModel:Destroy()
        oModel := NIL
    EndIf

Return lRetorno


/*
    Atualiza Endereco de Entrega vindo no pedido de venda

    Isso vale tanto pra LINX como pra  ZOHO

    FISA164
    https://tdn.totvs.com/pages/releaseview.action?pageId=788607214

*/
Static Function AtualizaRiscoCliente( cCodCli, cLojaCli, cRisco )
Local lRetorno := .T.
Local oModel   := Nil

DEFAULT cRisco := "A"

    // Atualmente estou alterando diretamente,  tendo mudado ou não e somenete os campos do endereço
    SA1->(dbSelectArea("SA1"))
    If SA1->( MsSeek( FWxFilial("SA1") + cCodCli + cLojaCli ) )

        oModel := FwLoadModel("CRMA980")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()            

        oModel:SetValue("SA1MASTER", "A1_RISCO", cRisco )

        If oModel:VldData()

            oModel:CommitData()
            TMSLogMSg( "INFO", "MAWSLNX20 - Registro Alterado: " + cCodCli + " - " + cLojaCli )
        Else

            VarInfo( "Erro ao alterar", oModel:GetErrorMessage() )

            // Gravar no arquivo de LOG ( SZ0 )
        EndIf

        oModel:DeActivate()
        oModel:Destroy()
        oModel := NIL
    EndIf

Return lRetorno

/*
  // Tem que lembrar que são duas tabelas:  F20  e  F22
  // Podendo usar o FWMVCRotAuto(ModelDef(),"DA0",3,{{"OMSA010_DA0",aCabec},{"OMSA010_DA1",aItens}})
*/
Static Function CFGTribCliente(cCliFor, cLoja)
Local oModel as object
Local lOk := .F.
Local cCodPerfil := "IS_IMP"
Local cTipoPart := "2"
Local cTipoPerf := "2"

    oModel := FwLoadModel("FISA164") // carrego o modelo da rotina
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate() // ativo o modelo
 
    //Adiciona uma nova linha no grid
    oModel:GetModel("FISA164PARTICIPANTE"):AddLine()
    oModel:SetValue("FISA164PARTICIPANTE", "F22_CODIGO", cCodPerfil)
    oModel:SetValue("FISA164PARTICIPANTE", "F22_TPPART", cTipoPart)
    oModel:SetValue("FISA164PARTICIPANTE", "F22_CLIFOR", cCliFor)
    oModel:SetValue("FISA164PARTICIPANTE", "F22_LOJA"  , cLoja)
    oModel:SetValue("FISA164PARTICIPANTE", "F22_TIPOPF", cTipoPerf)
 
    If oModel:VldData()

        oModel:CommitData()
        lOk := .T.
    Else

        VarInfo("",oModel:GetErrorMessage())
    EndIf

    oModel:DeActivate()

Return lOk

/*
    Calcula IPI igual ao ZOHO  por  ITEM!!!
    Sempre,  sempre  considerando que o valor que tá no LINx está com o IPI
    Como é o processo de  "tabela de preço"  para LINX ?
    Somnte Origem 1

*/
Static Function CalculaIPI( nPrice, cCodProd  )
Local lRetorno     := .T.
Local nOldPrice    := nPrice
Local nPercIPI     := GetAdvFVal( "SB1", "B1_IPI", FWxFilial("SB1") + cCodProd, 1, 0 )
Local cOrigem      := GetAdvFVal( "SB1", "B1_ORIGEM", FWxFilial("SB1") + cCodProd, 1, 0 )
Local nVlrLINX     := nPrice
Local nVlrProtheus := nPrice

    /*
        =(B7)/(1+D7)
        B7 = 100
        D7 = 10
        =K14 / ( 1 + (10 / 100 ) )
        Valor pro PRotheus := Valor vindo do LINX / ( 1 + ( Percentual IPI / 100 ) )
    */

    If cOrigem == "1"  .and.  nPercIPI > 0

        nVlrProtheus := ( nVlrLINX ) / ( 1 + ( nPercIPI / 100 ) )

        nPrice := Round( nVlrProtheus, 2 )
    EndIf

Return lRetorno

/*

*/
Static Function IncClienteCFGTrib( cCodCli, cLojaCli )
Local lRetorno := .T.
Local aArea := FWGetArea()

    F22->(dbSelectArea("F22"))
    F22->(dbSetOrder(1))
    If F22->( !MsSeek( FWxFilial( "F22" ) + "IS_IMP" + "2" + cCodCli + cLojaCli ) )

        RecLock( "F22", .T. )
        F22_FILIAL := FwxFilial("F22")
        F22_CODIGO := "IS_IMP"
        F22_TPPART := "2"
        F22_CLIFOR := cCodCli
        F22_LOJA   := cLojaCli
        F22_TIPOPF := "02"
        F22->( MsUnLock("F22"))
    EndIf

FWRestArea( aArea )
Return lRetorno

/*
   Regras  não  mais usadas
*/
Static Function TratamentoKIT()

    If  lNewKIT

        For nCntFor := 1 To nQtdItems

            cBundleKitDiscount := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'BundleKitDiscount' )
            cCatalogItemType   := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'CatalogItemType' )

            // Se bloco lido do JSON é  um  KIT  e  o SKU  é um  KIT
            If cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_KIT

                // Pego o preço do KIT e não do item do KIT
                // nPriceKit := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Price' ) )
                // nQtyKit   := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Qty' ) )

                // feio :-(  esse codigo,  mas temporario por enquanto....  que fica pra sempre  :-) :-)

                nQtdAmountItem    := Len( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' ) )
                nKITAmountItem    := 0
                For nCntFor1 := 1 to nQtdAmountItem
                
                    lAmountPIX := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Reference' ) == "4"

                    // Efetuar uma conferencia apenas para compras PIX
                    If lAmountPIX  .and.  cPaymentType == FORMAPAGTO_PIX
                
                        nKITAmountItem := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Amount' ) )
                    EndIf
                Next nCntFor1

                // Pula  dados de  KIT, s eja  produto  ou  SKU  tipo  KIT
                Loop
            EndIf            

            cItem := Soma1(cItem)

            // Se bloco lido do JSON é  um  KIT  e  o SKU  é um  produto  do  KIT
            If cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_PRODUTO

                nPrice          := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Price' ) )
                nQty            := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Qty' ) )
                nDiscountAmount := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'DiscountAmount' ) )

                cProductID := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'ProductID' )
                cSkuID     := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'SkuID' )

            ElseIf cBundleKitDiscount != PRODUTO_TIPO_KIT    // Se  for  apenas  produto / SKU  normal, ou seja,  nao é um produto de um KIT

                nPrice     := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Price' ) )
                nQty       := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Qty' ) )
                // nDiscountAmount := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'DiscountAmount' ) )
                nDiscountAmount := oJson:GetJsonObject( 'DiscountAmount' )

                nQtdAmountItem    := Len( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' ) )
                nAmountItem       := 0
                For nCntFor1 := 1 to nQtdAmountItem
                
                    lAmountPIX := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Reference' ) == "4"

                    // Efetuar uma conferencia apenas para compras PIX
                    If lAmountPIX  .and.  cPaymentType == FORMAPAGTO_PIX
                
                        nAmountItem := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonObject( 'Properties' )[nCntFor1]:GetJsonText( 'Amount' ) )
                    EndIf
                Next nCntFor1                
            EndIf
            cCodProd  := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'SKU' )//"186-0106"   

            
            // Mesma  regra que vem do  ZOHO
            CalculaIPI( @nPrice, cCodProd  )

            // Chumbados por enquanto
            cTipoOper := SuperGetMV( "ES_LINXSFM", .F., "01"  )
            cTES      := SuperGetMV( "ES_LINXSF4", .F., "570" )

            aLinha := {}
            aAdd( aLinha, {"C6_ITEM"   , cItem	 , Nil} )
            aAdd( aLinha, {"C6_PRODUTO", cCodProd, Nil} )
            aAdd( aLinha, {"C6_QTDVEN" , nQty 	 , Nil} )
            aAdd( aLinha, {"C6_QTDLIB" , nQty	 , Nil} )
            aAdd( aLinha, {"C6_PRCVEN" , nPrice	 , Nil} )
            //aAdd( aLinha, {"C6_TOTAL"  , nPrice * nQty	 , Nil} )
            aAdd( aLinha, {"C6_OPER"   , cTipoOper, Nil} )
            //aAdd( aLinha, {"C6_TES"	   , cTES	 , Nil} )

            // PaymentTaxAmount   ???
            /*
            If nPaymentTaxAmount > 0

                aAdd( aLinha, {"C6_VALDESC"   , nPaymentTaxAmount, Nil} )
            EndIf

            If nAmountItem > 0

                aAdd( aLinha, {"C6_VALDESC"   , nAmountItem, Nil} )
            EndIf
            nAmountItem := 0

            // Analisar isso:  desconto vai sobrescrever 
            If .F.  .and.  cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_PRODUTO

                aAdd( aLinha, {"C6_VALDESC"   , nDiscountAmount, Nil} )
            EndIf
            If nAmountItem > 0

                aAdd( aLinha, {"C6_VALDESC"   , nAmountItem, Nil} )
            EndIf
            nAmountItem := 0
            */

            // 
            If cBundleKitDiscount != PRODUTO_TIPO_KIT  
                
                If  nAmountItem > 0

                    aAdd( aLinha, {"C6_VALDESC"   , nAmountItem, Nil} )
                ElseIf nDiscountAmount > 0   // 

                    aAdd( aLinha, {"C6_VALDESC"   , nDiscountAmount, Nil} )
                EndIf
            ElseIf cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_PRODUTO  .and.  nKITAmountItem > 0

                aAdd( aLinha, {"C6_VALDESC"   , nKITAmountItem, Nil} )
            EndIf            

            aAdd( aItens, aLinha )			
        Next nCntFor
    Else

        For nCntFor := 1 To nQtdItems

            cBundleKitDiscount := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'BundleKitDiscount' )
            cCatalogItemType   := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'CatalogItemType' )

            If cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_KIT

                // Pego o preço do KIT e não do item do KIT
                nPriceKit := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Price' ) )
                nQtyKit   := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Qty' ) )

                // feio :-(  esse codigo,  mas temporario por enquanto....  que fica pra sempre  :-) :-)
                Loop
            EndIf
            
            cItem := Soma1(cItem)

            If cBundleKitDiscount == PRODUTO_TIPO_KIT  .and.  cCatalogItemType == CATALOGO_TIPO_PRODUTO

                nPrice := nPriceKit
                nQty   := nQtyKit
            Else

                nPrice     := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Price' ) )
                nQty       := Val( oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'Qty' ) )
            EndIf
            cCodProd  := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'SKU' )//"186-0106"   


            CalculaIPI( @nPrice, cCodProd  )

            cProductID := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'ProductID' )
            cSkuID     := oJson:GetJsonObject( 'Items' )[nCntFor]:GetJsonText( 'SkuID' )

            nPaymentTaxAmount := Abs( oJson:GetJsonObject( 'PaymentTaxAmount' ) )

            aLinha := {}
            aAdd( aLinha, {"C6_ITEM"   , cItem	 , Nil} )
            aAdd( aLinha, {"C6_PRODUTO", cCodProd, Nil} )
            aAdd( aLinha, {"C6_QTDVEN" , nQty 	 , Nil} )
            aAdd( aLinha, {"C6_QTDLIB" , nQty	 , Nil} )
            aAdd( aLinha, {"C6_PRCVEN" , nPrice	 , Nil} )
            //aAdd( aLinha, {"C6_TOTAL"  , nPrice * nQty	 , Nil} )
            aAdd( aLinha, {"C6_OPER"   , cTipoOper, Nil} )
            //aAdd( aLinha, {"C6_TES"	   , cTES	 , Nil} )

            If nPaymentTaxAmount > 0

                aAdd( aLinha, {"C6_VALDESC"   , nPaymentTaxAmount, Nil} )
            EndIf

            aAdd( aItens, aLinha )			
        Next nCntFor
    EndIf

Return lRetorno

