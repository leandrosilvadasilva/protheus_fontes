#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include 'parmtype.ch'
#include "fileio.ch"
#include "fwmvcdef.ch"
#include "tbiconn.ch"
#include "shell.ch"
#include "fileio.ch"

/*/{Protheus.doc} User Function SF1100E
    Ponto de entrada na exclusão da NF de entrada. Em caso de NF com pedidos de compras, fará o retorno do pedido para EM=Empenhado Novamente
    O ponto de entrada na exclusão, faz com que após exclusão da NF, o sistema verifique a existência de AKD para o pedido amarrado a NF, caso exista, 
    volta a AKD pra lançamento válido, com status = 2. Com isso, restaura o saldo empenhado para o dashboard.
    @type  Function
    @author user
    @since 21/12/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function SF1100E()
    Local cquery, cAliasSd1 := GetNextAlias()
    Local lParPCOSC7 := GetNewPar("MA_PCOSC7", .F.)           //# habilita ou desabilita a execução deste programa.

    If !lParPCOSC7
        Return 
    Endif

    cquery := "select distinct D1_PEDIDO, D1_ITEMPC from " + RetSqlName("SD1") + " as sd1 where D1_DOC = '" + F1_DOC + "' And D1_FORNECE = '" + sf1->F1_FORNECE 
    cquery += "' And D1_SERIE = '" + sf1->f1_serie + "' And D1_FILIAL = '" + sf1->f1_filial + "' And D1_DTDIGIT = '" + DtoS(sf1->f1_dtdigit) + "' "
    cquery += "And sd1.D_E_L_E_T_ = '*' "
    TcQuery cquery new alias (cAliasSd1)

    While (cAliasSd1)->(!eof())
        cquery := "Update " + RetSqlName("AKD") + " set AKD_STATUS = '1' From " + RetSqlName("AKD") + " a "
        cquery += "Where a.D_E_L_E_T_ = ' ' And AKD_STATUS = '2' And Substring(AKD_CHAVE,1,3) = 'SC7' And Substring(AKD_CHAVE,4,4) = '" + xFilial("AKD") + "' "
        cquery += "And Substring(AKD_CHAVE,8,6) = '" + (cAliasSD1)->d1_pedido + "' And Substring(AKD_CHAVE,14,4) = '" + (cAliasSd1)->d1_itempc + "' "

        nretorno := TcSqlExec(cquery)
        
        (cAliasSd1)->(dbSkip())
    Enddo
    If Select((cAliasSd1)) > 0
        (cAliasSd1)->(dbCloseArea())
    Endif
Return 

