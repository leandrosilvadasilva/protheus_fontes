#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include 'parmtype.ch'
#include "fileio.ch"
#include "fwmvcdef.ch"
#include "tbiconn.ch"
#include "shell.ch"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} MAPCOG04
    Função para alterar o saldo de EMPENHADO para REALIZADO,
    Executa de 30 em 30 minutos.
    @type  Function
    @author peterson aquino | compila.com.br
    @since 07/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    
    Alteracoes Realizadas desde a Estruturacao Inicial

	Data                        Programador                          Motivo
    29/05/2023                  Davidson Carvalho                   #8950/Compilação ambiente TI OFC 
     /*/
User Function MAPCOG04()

Local cquery := "", lResetEnvironment := .F.
Local cDataCorte := '20230101'//#DtoS(date()-90) //#90 dias anteriores a data atual, só serão considerados pedidos de 2023
Local cParPCOG04 := "", cTimeCur := Time()

Default aParam := {"01","0101"}

//#prepara o ambiente se .F. é via JOB
/*If !IsBLind()
    lResetEnvironment := .T.
    PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO 'PCO'
    
Endif*/

lParPCOSC7 := GetNewPar("MA_PCOSC7", .F.)           //# habilita ou desabilita a execução deste programa.
nParPCOG04 := GetNewPar("MA_PCOTP4", 10 )           //# configuração do tempo em minutos para execução do update.
cParPCOG04 := GetNewPar("MA_PCOGP4", "00:00:00" )   //# variável contendo o ultimo horario em que foi realizado o processamento.

//#valida e verifica se já se passaram os minutos até o próximo processamento
If flMinutes(cTimeCur, cParPCOG04, nParPCOG04) .And. lParPCOSC7

    //# reprocesamento dos pedidos sem RATEIO - Bloqueados 
    cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'EM' from " + RetSqlName("AKD") + " a "
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
    cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'RE' from " + RetSqlName("AKD") + " a "
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
    cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'RE' from " + RetSqlName("AKD") + " a "
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
    cquery := "update " + RetSqlName("AKD") + " set AKD_TPSALD = 'EM' from " + RetSqlName("AKD") + " a "
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

/*
If lResetEnvironment
    RESET ENVIRONMENT 

Endif*/

Return 




/*/{Protheus.doc} flMinutes
    Função criada para calcular a diferença entre o hiorário atual e uma variavel contendo um ultimo horário de processamento
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
