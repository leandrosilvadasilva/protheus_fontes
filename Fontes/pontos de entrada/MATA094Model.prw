#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} nomeFunction
    Ponto de entrada disparado pela tela de aprovação de documentos MATA094
    Este ponto de entrada MVC pode ser manipulado conforme eventos desejedos
    @type  Function
    @author user
    @since 31/12/2022 | 19/12/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MATA094()

Local aParam := PARAMIXB
Local lReturn := .T.
Local oObj := ""
Local cIdPonto := ""
Local cIdModel := ""
Local lIsGrid := .F.
Local nLinha := 0
Local nQtdLinhas := 0
Local cMsg := ""
Local nOp
Local cKeySCH, cKeySC7
Local lGetPar := GetNewPar("MA_PCOAPR", .T.)

If (aParam <> NIL)
    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]
    lIsGrid    := (Len(aParam) > 3)
Endif

nOpc := oObj:GetOperation()

//#gravação após gravação total do modelo e commit no banco de dados 
If cIdPonto == "MODELPOS"//"MODELCOMMITNTTS" .And. lGetPar//#"MODELCOMMITNTTS"

    If !empty(scr->cr_datalib)
        //#verifica se existe a integração com o PCO
        cKeySCH := "SCH"+sc7->(xFilial())+SC7->c7_num
        cKeySC7 := "SC7"+sc7->(xFilial())+SC7->c7_num

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

Elseif cIdPonto == "FORMCOMMITTTSPOS"

    If !empty(scr->cr_datalib)
        //#verifica se existe a integração com o PCO
        cKeySCH := "SCH"+sc7->(xFilial())+SC7->c7_num
        cKeySC7 := "SC7"+sc7->(xFilial())+SC7->c7_num

        Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ
        If Akd->(DbSeek(xFilial()+cKeySCH))
            While Substr(cKeySC7,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
                If Reclock("AKD",.F.)
                    akd->akd_tpsald := "EM" //#saldo empenhado para os pedidos liberados
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

Endif

Return lReturn
