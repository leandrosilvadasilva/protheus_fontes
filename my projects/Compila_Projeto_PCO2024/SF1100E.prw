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
    Ponto de entrada na exclusão da NF de entrada. 
    Caso a NF tenha pedido de compras localiza o lançamento do pedido na AKD que estava desabilitado AKD_STATUS = '2' e reabilita.
    Restaurando o saldo empenhado para o dashboard.
    @type  Function
    @author peterson | compila.com.br
    @since 21/12/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function SF1100E()

Local aArea := GetArea()
Local cquery, cAliasSd1 := GetNextAlias()
Local lParPCOSC7 := GetNewPar("MA_PCOSC7", .F.)           //# habilita ou desabilita a execução deste programa.

If !lParPCOSC7
    Return 
Endif

cquery := "select distinct D1_FILIAL, D1_PEDIDO from " + RetSqlName("SD1") + " as sd1 where D1_DOC = '" + sf1->F1_DOC + "' And D1_FORNECE = '" + sf1->F1_FORNECE 
cquery += "' And D1_SERIE = '" + sf1->f1_serie + "' And D1_FILIAL = '" + sf1->f1_filial + "' And D1_DTDIGIT = '" + DtoS(sf1->f1_dtdigit) + "' "
cquery += "And sd1.D_E_L_E_T_ = '*' "
TcQuery cquery new alias (cAliasSd1)

While (cAliasSd1)->(!eof())

    //# localiza registros da AKD
    cKeySCH := "SCH"+(cAliasSd1)->d1_filial+(cAliasSd1)->d1_pedido
    cKeySC7 := "SC7"+(cAliasSd1)->d1_filial+(cAliasSd1)->d1_pedido

    Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ

    If Akd->(DbSeek(xFilial()+cKeySCH))
        While Substr(cKeySCH,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
            If Reclock("AKD",.F.)
                akd->akd_status := "1"
                akd->(MsUnlock())
            Endif
            akd->(DbSkip())
        Enddo
    Endif

    If Akd->(Dbseek(xFilial()+cKeySC7))
        While Substr(cKeySC7,1,Len(cKeySC7)) == Substr(akd->akd_chave,1,Len(cKeySC7)) .And. akd->(!eof())
            If Reclock("AKD",.F.)
                akd->akd_status := "1"
                akd->(MsUnlock())
            Endif
            akd->(DbSkip())
        Enddo
    Endif        
   
    (cAliasSd1)->(dbSkip())

Enddo

If Select((cAliasSd1)) > 0
    (cAliasSd1)->(dbCloseArea())
Endif

RestArea(aArea)

Return 

