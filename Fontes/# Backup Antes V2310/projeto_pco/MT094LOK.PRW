#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} MT094LOK.prw
    Ponto de entrada após a liberação do pedido de compras.
    @type  Function
    @author peterson | compila.com.br
    @since 31/12/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MT094LOK()

Local lGetPar := GetNewPar("MA_PCOSC7", .F.)

//#verifica se existe a integração com o PCO
cKeySCH := "SCH"+sc7->(xFilial())+SC7->c7_num
cKeySC7 := "SC7"+sc7->(xFilial())+SC7->c7_num

If lGetPar .And. ProcName(2) == "A94EXLIBER"
    Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ
    If Akd->(DbSeek(xFilial()+cKeySCH))
        While Substr(cKeySC7,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
            If Reclock("AKD",.F.)
                akd->akd_tpsald := "EM"
                akd->(MsUnlock())
            Endif
            akd->(DbSkip())
        Enddo
    Endif

    If Akd->(Dbseek(xFilial()+cKeySC7))
        While Substr(cKeySC7,1,Len(cKeySC7)) == Substr(akd->akd_chave,1,Len(cKeySC7)) .And. akd->(!eof())
            If Reclock("AKD",.F.)
                akd->akd_tpsald := "EM"
                akd->(MsUnlock())
            Endif
            akd->(DbSkip())
        Enddo
    Endif   

Endif

Return
