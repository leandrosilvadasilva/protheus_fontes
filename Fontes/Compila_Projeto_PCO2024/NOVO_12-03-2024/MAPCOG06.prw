#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include 'parmtype.ch'
#include "fileio.ch"
#include "fwmvcdef.ch"
#include "tbiconn.ch"
#include "shell.ch"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} MAPCOG06
    Função para converter saldo PC (pedido colocado) para EM (saldo empenhado)
    Executa de 10 em 10 minutos por default ou conforme parametro MA_PCOTP4
    Este programa é executado pelo processo 000055 da AKC
    @type  Function
    @author peterson aquino | compila.com.br
    @since 30/11/2023
    @version version
    @param sprocesso = deverá vir com o código do processo referencia da tabela AKC
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MAPCOG06(sprocesso)

Local cquery := "", lResetEnvironment := .F.
Local cDataCorte := '20230101'//#DtoS(date()-90) //#90 dias anteriores a data atual, só serão considerados pedidos de 2023
Local cTimeCur := Time()

Local lParPCOSC7 := GetNewPar("MA_PCOSC7", .F.)           //# habilita ou desabilita a execução deste programa.
Local nParPCOG04 := GetNewPar("MA_PCOTP7", 1  )           //# configuração do tempo em minutos para execução do update.
Local cParPCOG04 := GetNewPar("MA_PCOGP7", "00:00:00" )   //# variável contendo o ultimo horario em que foi realizado o processamento.

Default aParam := {"01","0101"}

//#prepara o ambiente se .F. é via JOB
/*If !IsBLind()
    lResetEnvironment := .T.
    PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO 'PCO'
    
Endif*/

If lParPCOSC7
    
    //# procsso de inclusão de NF por item, efetua baixa do pedido de compras, altera o status para 1=lançamento inativo, porém continua como EM o PC.
    If      sprocesso $ "0000540102/0000540502/0000540902" 

        //# se tem pedido com o status de desabilitado
        cKeySCH := "SCH"+sc7->(xFilial())+sd1->d1_pedido
        cKeySC7 := "SC7"+sc7->(xFilial())+sd1->d1_pedido

        Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ
        If Akd->(DbSeek(xFilial()+cKeySCH))
            While Substr(cKeySCH,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
                If akd->akd_status # "2"
                    If Reclock("AKD",.F.)
                        akd->akd_status := "2"  //# bloqueia por ter sido realizado
                        akd->akd_tpsald := "RE" //# alterar para realizado
                        akd->(MsUnlock())
                    Endif
                Endif
                akd->(DbSkip())
            Enddo
        Endif

        If Akd->(Dbseek(xFilial()+cKeySC7))
            While Substr(cKeySC7,1,Len(cKeySC7)) == Substr(akd->akd_chave,1,Len(cKeySC7)) .And. akd->(!eof())
                If akd->akd_status # "2"
                    If Reclock("AKD",.F.)
                        akd->akd_status := "2"  //# bloqueia por ter sido realizado
                        akd->akd_tpsald := "RE" //# alterar para realizado
                        akd->(MsUnlock())
                    Endif
                Endif
                akd->(DbSkip()) 
            Enddo
        Endif    
        
        //# PutMv("MA_PCOGP4", cTimeCur)

    Elseif  sprocesso $ "0000541502"

        //# se tem pedido com o status de desabilitado
        cKeySCH := "SCH"+sc7->(xFilial())+sc7->c7_num
        cKeySC7 := "SC7"+sc7->(xFilial())+sc7->c7_num

        Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ
        If Akd->(DbSeek(xFilial()+cKeySCH))
            While Substr(cKeySCH,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
                If akd->akd_status # "2"
                    If Reclock("AKD",.F.)
                        akd->akd_status := "2"  //# bloqueia por ter sido realizado
                        akd->akd_tpsald := "RE" //# alterar para realizado
                        akd->(MsUnlock())
                    Endif
                Endif
                akd->(DbSkip())
            Enddo
        Endif

        If Akd->(Dbseek(xFilial()+cKeySC7))
            While Substr(cKeySC7,1,Len(cKeySC7)) == Substr(akd->akd_chave,1,Len(cKeySC7)) .And. akd->(!eof())
                If akd->akd_status # "2"
                    If Reclock("AKD",.F.)
                        akd->akd_status := "2"  //# bloqueia por ter sido realizado
                        akd->akd_tpsald := "RE" //# alterar para realizado
                        akd->(MsUnlock())
                    Endif
                Endif
                akd->(DbSkip())
            Enddo
        Endif    

        //# PutMv("MA_PCOGP4", cTimeCur)
    Elseif sprocesso $ "0000520901"

        //# se tem pedido com o status de desabilitado
        cKeySCH := "SCH"+sc7->(xFilial())+sc7->c7_num
        cKeySC7 := "SC7"+sc7->(xFilial())+sc7->c7_num

        Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ
        If Akd->(DbSeek(xFilial()+cKeySCH))
            While Substr(cKeySCH,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
                If Reclock("AKD",.F.)
                    akd->akd_status := "1" //# retorna pedido para PC
                    akd->akd_tpsald := "PC"
                    akd->(MsUnlock())
                Endif
                akd->(DbSkip())
            Enddo
        Endif

        If Akd->(Dbseek(xFilial()+cKeySC7))
            While Substr(cKeySC7,1,Len(cKeySC7)) == Substr(akd->akd_chave,1,Len(cKeySC7)) .And. akd->(!eof())
                If Reclock("AKD",.F.)
                    akd->akd_status := "1"
                    akd->akd_tpsald := "PC"
                    akd->(MsUnlock())
                Endif
                akd->(DbSkip())
            Enddo
        Endif   

    Endif

Endif

/*If lResetEnvironment
    RESET ENVIRONMENT 

Endif*/

Return 




/*/{Protheus.doc} flMinutes
    Função criada para calcular a diferença entre o horário atual e uma variavel contendo um ultimo horário de processamento
    @type  Function
    @author user
    @since 15/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function flMinutes(cTimeCur, cLastProc, nLimit)

Local lReturn := .F.
Local nTimeCur  := (Val(Substr(cTimeCur,1,2)) * 60)  + Val(Substr(cTimeCur,4,2))
Local nLastProc := (Val(Substr(cLastProc,1,2)) * 60) + Val(Substr(cLastProc,4,2))

If Abs(nTimeCur - nLastProc) >= nLimit
    lReturn := .T.
Endif

Return lReturn
