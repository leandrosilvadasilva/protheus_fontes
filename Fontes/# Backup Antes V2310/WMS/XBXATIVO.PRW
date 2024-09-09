#INCLUDE "Protheus.ch"
 
User Function XBXATIVO()

    
Local aArea := GetArea()
Local cBase := "0000000005"
Local cItem := "0001"
Local cTipo := "01"
Local cTpSaldo := "1"
Local cBaixa := "0"
Local nQtdAtu := 1
Local nQtdBaixa := 1
Local cMotivo := "08"
Local cMetDepr
Local cNumNF := ""
Local cSerieNF := ""
Local nValNF := 0
 
Local aCab := {}
Local aAtivo := {}
Local aParam := {}
 
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.


    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" 

cMetDepr := GetMV('MV_ATFDPBX')

aCab := { {"FN6_FILIAL" ,XFilial("FN6") ,NIL},;
{"FN6_CBASE" ,cBase ,NIL},;
{"FN6_CITEM" ,cItem ,NIL},;
{"FN6_MOTIVO" ,cMotivo ,NIL},;
{"FN6_BAIXA" ,100 ,NIL},;
{"FN6_QTDBX" ,nQtdBaixa ,NIL},;
{"FN6_DTBAIX" ,dDatabase ,NIL},;
{"FN6_DEPREC" ,cMetDepr ,NIL}}
 
aAtivo := {{"N3_FILIAL" ,XFilial("SN3") ,NIL},;
{"N3_CBASE" ,cBase ,NIL},;
{"N3_ITEM" ,cItem ,NIL},;
{"N3_TIPO" ,cTipo ,NIL},;
{"N3_BAIXA" ,cBaixa ,NIL},;
{"N3_TPSALDO" ,cTpSaldo ,NIL}}
 
//Array contendo os parametros do F12
aAdd( aParam, {"MV_PAR01", 1} ) //Pergunta 01 - Mostra Lanc. Contab? 1 = Sim ; 2 = Não
aAdd( aParam, {"MV_PAR02", 2} ) //Pergunta 02 - Aglutina Lancamento Contabil ? 1 = Sim ; 2 = Não
aAdd( aParam, {"MV_PAR03", 1} ) //Pergunta 03 - Contabaliza On-Line? 1 = Sim ; 2 = Não
aAdd( aParam, {"MV_PAR04", 2} ) //Pergunta 04 - Visualização ? 2 = Tipos de Ativos   // deve se usar obrigatoriamente o número 2
 

MsExecAuto({|a,b,c,d,e,f|ATFA036(a,b,c,d,e,f)},aCab,aAtivo,3,,.T./*lBaixaTodos*/,aParam)
If lMsErroAuto
MostraErro()

EndIf

 
RestArea(aArea)
 
    RESET ENVIRONMENT

Return
