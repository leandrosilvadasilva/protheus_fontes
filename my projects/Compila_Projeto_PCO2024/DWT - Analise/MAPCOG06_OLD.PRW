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
Local nParPCOG04 := GetNewPar("MA_PCOTP7", 0  )           //# configuração do tempo em minutos para execução do update.
Local cParPCOG04 := GetNewPar("MA_PCOGP7", "00:00:00" )   //# variável contendo o ultimo horario em que foi realizado o processamento.

Default aParam := {"01","0101"}

//#prepara o ambiente se .F. é via JOB
/*If !IsBLind()
    lResetEnvironment := .T.
    PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO 'PCO'
    
Endif*/

//#valida e verifica se já se passaram os minutos até o próximo processamento
If lParPCOSC7
    
    //# procsso de inclusão de NF por item, efetua baixa do pedido de compras, altera o status para 1=lançamento inativo, porém continua como EM o PC.
    If      sprocesso $ "0000540102/0000540502/0000540902" 

        //# se tem pedido com o status de desabilitado
        cKeySCH := "SCH"+sc7->(xFilial())+sd1->d1_pedido+sd1->d1_itempc
        cKeySC7 := "SC7"+sc7->(xFilial())+sd1->d1_pedido+sd1->d1_itempc

        Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ
        If Akd->(DbSeek(xFilial()+cKeySCH))
            While Substr(cKeySC7,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
                If Reclock("AKD",.F.)
                    akd->akd_status := "2"//# bloqueia o pedido de compras 1=Aprovado;2=Invalido;3=Estornado
                    akd->(MsUnlock())
                Endif
                akd->(DbSkip())
            Enddo
        Endif

        If Akd->(Dbseek(xFilial()+cKeySC7))
            While Substr(cKeySC7,1,Len(cKeySC7)) == Substr(akd->akd_chave,1,Len(cKeySC7)) .And. akd->(!eof())
                If Reclock("AKD",.F.)
                    akd->akd_status := "2"//# bloqueia o pedido de compras 1=Aprovado;2=Invalido;3=Estornado
                    akd->(MsUnlock())
                Endif
                akd->(DbSkip())
            Enddo
        Endif    
        
        PutMv("MA_PCOGP4", cTimeCur)

    Elseif  sprocesso $ "0000541501" 

        //# se tem pedido com o status de desabilitado
        cKeySCH := "SCH"+sc7->(xFilial())+sc7->c7_num+sc7->c7_item
        cKeySC7 := "SC7"+sc7->(xFilial())+sc7->c7_num+sc7->c7_item

        Akd->(DbSetOrder(10))//#AKD_FILIAL+AKD_CHAVE+AKD_SEQ
        If Akd->(DbSeek(xFilial()+cKeySCH))
            While Substr(cKeySC7,1,Len(cKeySCH)) == Substr(akd->akd_chave,1,Len(cKeySCH)) .And. akd->(!eof())
                If Reclock("AKD",.F.)
                    akd->akd_status := "2"//# bloqueia o pedido de compras 1=Aprovado;2=Invalido;3=Estornado
                    akd->(MsUnlock())
                Endif
                akd->(DbSkip())
            Enddo
        Endif

        If Akd->(Dbseek(xFilial()+cKeySC7))
            While Substr(cKeySC7,1,Len(cKeySC7)) == Substr(akd->akd_chave,1,Len(cKeySC7)) .And. akd->(!eof())
                If Reclock("AKD",.F.)
                    akd->akd_status := "2"//# bloqueia o pedido de compras 1=Aprovado;2=Invalido;3=Estornado
                    akd->(MsUnlock())
                Endif
                akd->(DbSkip())
            Enddo
        Endif    
        
        PutMv("MA_PCOGP4", cTimeCur)

    Else

        //# esta parte do programa, trata os lançamento AK8_CODIGO 000052
        //# reprocesamento dos pedidos sem RATEIO - Bloqueados 
        cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'PC' from " + RetSqlName("AKD") + " a "
        cquery += " inner join " + RetSqlName("SC7") + " s on a.AKD_FILIAL = s.C7_FILIAL And s.C7_EMISSAO > '" + cDataCorte + "' "
        cquery += " And SUBSTRING(a.AKD_CHAVE,8,6) = s.C7_NUM "
        cquery += " And s.C7_ITEM = SUBSTRING(a.AKD_CHAVE,14,4) "
        cquery += " And s.D_E_L_E_T_ = ' ' "
        cquery += " And SUBSTRING(a.AKD_CHAVE,1,3) = 'SC7' And s.C7_CONAPRO = 'B' And a.AKD_PROCES = '000052' And a.AKD_ITEM = '01' "
        nretorno := TcSqlexec(cquery)

        //#
        If nretorno # 0 
            MsgStop("Erro de execução do procesamento de integração SC7 x PCO. QRY1")
        Endif 
        
        //# reprocesamento dos pedidos sem RATEIO - Liberados
        cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'EM' from " + RetSqlName("AKD") + " a "
        cquery += " inner join " + RetSqlName("SC7") + " s on a.AKD_FILIAL = s.C7_FILIAL And s.C7_EMISSAO > '" + cDataCorte + "' "
        cquery += " And SUBSTRING(a.AKD_CHAVE,8,6) = s.C7_NUM "
        cquery += " And s.C7_ITEM = SUBSTRING(a.AKD_CHAVE,14,4) "
        cquery += " And s.D_E_L_E_T_ = ' ' "
        cquery += " And SUBSTRING(a.AKD_CHAVE,1,3) = 'SC7' And s.C7_CONAPRO = 'L' And a.AKD_PROCES = '000052' And a.AKD_ITEM = '01' "
        nretorno := TcSqlexec(cquery)

        If nretorno # 0 
            MsgStop("Erro de execução do procesamento de integração SC7 x PCO. QRY2")
        Endif 

        //# reprocesamento dos pedidos com RATEIO - Liberados
        cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'EM' from " + RetSqlName("AKD") + " a "
        cquery += "inner join " + RetSqlName("SC7") + " s on a.AKD_FILIAL = s.C7_FILIAL And s.C7_EMISSAO > '" + cDataCorte + "' "
        cquery += "And SUBSTRING(a.AKD_CHAVE,8,6) = s.C7_NUM   "
        cquery += "And s.C7_ITEM = SUBSTRING(a.AKD_CHAVE,24,4) "
        cquery += "And s.D_E_L_E_T_ = ' ' "
        cquery += "And SUBSTRING(a.AKD_CHAVE,1,3) = 'SCH' And s.C7_CONAPRO = 'L' And a.D_E_L_E_T_ = ' ' And a.AKD_PROCES = '000052' And a.AKD_ITEM = '08' "
        nretorno := TcSqlexec(cquery)

        If nretorno # 0 
            MsgStop("Erro de execução do procesamento de integração SC7 x PCO. QRY3")
        Endif 
        
        //# reprocesamento dos pedidos com RATEIO - Bloqueados
        cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'PC' from " + RetSqlName("AKD") + " a "
        cquery += "inner join " + RetSqlName("SC7") + " s on a.AKD_FILIAL = s.C7_FILIAL And s.C7_EMISSAO > '" + cDataCorte + "' "
        cquery += "And SUBSTRING(a.AKD_CHAVE,8,6) = s.C7_NUM   "
        cquery += "And s.C7_ITEM = SUBSTRING(a.AKD_CHAVE,24,4) "
        cquery += "And s.D_E_L_E_T_ = ' ' "
        cquery += "And SUBSTRING(a.AKD_CHAVE,1,3) = 'SCH' And s.C7_CONAPRO = 'B' And a.D_E_L_E_T_ = ' ' And a.AKD_PROCES = '000052' And a.AKD_ITEM = '08' "
        nretorno := TcSqlexec(cquery)

        If nretorno # 0 
            MsgStop("Erro de execução do procesamento de integração SC7 x PCO. QRY4")
        Endif 
        
        PutMv("MA_PCOGP4", cTimeCur)

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
