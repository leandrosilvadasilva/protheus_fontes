#INCLUDE "TOTVS.CH"

Function U_MAIPIBASEICMS()
Local aArea       := FWGetArea()
Local cOrigem     := ""
Local cTipoCli    := ""

Local nPosProd    := Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" } )
Local cProduto    := aCols[ n, nPosProd ]

Local nPosTES     := Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_TES" } )
Local cTes        := aCols[ n, nPosTES ]
Local cAntTes     := cTes

Local nPosOper    := Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_OPER" } )
Local cOper       := aCols[ n, nPosOper ]

Local lIPIICMS    := SuperGETMV( "ES_IPIICMS", .F., .T. )
Local lEnviroment := SuperGETMV( "ES_ICMSIPI", .F., .T. )
Local lAmbiente   := .T.
Local cEnviroment := AllTrim( GetEnvServer() )

    If lEnviroment

        If !cEnviroment $ "HOMOLOGACAO/TI"

            lAmbiente := .F.
        EndIf
    EndIF

    // Liga e desliga o IPI na Base do ICMS  e  é o ambiente pra ter ess funcionaldiade
    If lIPIICMS  .and.  lAmbiente
        /*
        MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")
        a:=0
        MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES","RS","1")
        a:=0
        MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES","F","RS","1")
        a:=0
        */

        cOrigem  := GetAdvFVal( "SB1", "B1_ORIGEM", FWxFilial("SB1") + cProduto, 1, "" )
        cTipoCli := M->C5_TIPOCLi

        If cOper $ "01/15/26"  .and.  cOrigem $  "1/6"  .and.  cTipoCli == "F"

            cTes := MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),cProduto,"C6_TES","F",,cOrigem)

            If Vazio( cTes )

                cTes := cAntTes
            EndIf
        EndIf
    EndIf

FWRestArea( aArea )
Return cTes

