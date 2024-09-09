#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include 'Totvs.ch'

//IATAN EM 05/09/2023 
//ATENDENDO AO CHAMADO #10469

USER FUNCTION SD1EIC()

    Local _nX         := 0

    Local basePIS     := 0
    Local baseCOFINS  := 0
    Local baseICMS    := 0

    Local aliqPIS     := 0
    Local aliqCOFINS  := 0
    Local aliqICMS    := 0

    Local valorPIS    := 0
    Local valorCOFINS := 0
    Local valorICMS   := 0

    Local posEIC      := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_CONHEC"})
    Local posProduto  := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_COD"})
    Local posItem     := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_ITEM"})

    Local posBpis     := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_BASEPIS"})
    Local posBcofins  := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_BASECOF"})
    Local posBicms    := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_BASEICM"})

    Local posApis     := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_ALQPIS"})
    Local posAcofins  := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_ALQCOF"})
    Local posAicms    := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_PICM"})

    Local posVpis     := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_VALPIS"})
    Local posVcofins  := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_VALCOF"})
    Local posVicms    := ASCAN(aHeader,{|x| upper(alltrim(x[2]))=="D1_ICMSRET"})

    Local aArea := GETAREA()

    IF ALTERA == .T. .AND. ISINCALLSTACK( "MATA103" )

        For _nX := 1 to len(aCols)

            IF !EMPTY(ALLTRIM( aCols[_nX][posEIC] )) .AND. xFilial("SD1") == '0101' // CONHECIMENTO DE IMPORTAÇÃO
                // BUSCA DADOS DE IMPOSTOS DO EIC / TRATAMENTO SOMENTE PARA FILIAL 0101 DEVIDO AO TRATAMETNO DE CALCULO DE IMPOSTOS SER DIFERENTE NESSA FILIAL

                getImpostosEIC( aCols[_nX][posEIC], aCols[_nX][posProduto], aCols[_nX][positem], @basePIS, @baseCOFINS, @baseICMS, @aliqPIS, @aliqCOFINS, @aliqICMS, @valorPIS, @valorCOFINS, @valorICMS )
                
                aCols[_nX][posBpis]     := basePIS
                aCols[_nX][posBcofins]  := baseCOFINS
                aCols[_nX][posBicms]    := baseICMS
                
                aCols[_nX][posApis]     := aliqPIS
                aCols[_nX][posAcofins]  := aliqCOFINS
                aCols[_nX][posAicms]    := aliqICMS

                aCols[_nX][posVpis]     := valorPIS
                aCols[_nX][posVcofins]  := valorCOFINS
                aCols[_nX][posVicms]    := valorICMS
               
        
            ENDIF    

        Next

    ENDIF
    
    RESTAREA( aArea )

RETURN


Static Function getImpostosEIC( codigo, produto, item, basePIS, baseCOFINS, baseICMS, aliqPIS, aliqCOFINS, aliqICMS, valorPIS, valorCOFINS, valorICMS)

    Local cQry := ''

    cQry := " SELECT * "
    cQry += " FROM SWN010  "
    cQry += " WHERE D_E_L_E_T_ <> '*' AND WN_HAWB = '" + codigo + "' "
    cQry += "       AND WN_PRODUTO = '" + produto + "' "
    cQry += "       AND WN_ITEM = '" + item + "' "

    dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQry ),"_EIC",.T.,.T. )

  While (_EIC->(!EOF()))

    basePIS     := _EIC->WN_BASPIS
    baseCOFINS  := _EIC->WN_BASCOF
    baseICMS    := _EIC->WN_BASEICM

    aliqPIS     := _EIC->WN_PERPIS
    aliqCOFINS  := _EIC->WN_PERCOF
    aliqICMS    := _EIC->WN_ICMS_A

    valorPIS    := _EIC->WN_VLRPIS
    valorCOFINS := _EIC->WN_VLRCOF
    valorICMS   := _EIC->WN_VALICM

    _EIC->(DbSkip())

  EndDo

  _EIC->(DBCloseArea())

Return
