#Include 'Protheus.ch'
#include "tbiconn.ch"
 
 
//Inclusão de títulos a receber com desdobramento sem rastreio
User Function DESDOBR()
    Local aTitulo       := {}
/*
    Local cPrefixo      := "TST" //Prefixo utilizado
    Local cNumTitulo
    Local cCliente      := "000001" //Código do cliente
    Local cLoja         := "0001" //Loja
    Local cTipo         := "NF" //Tipo do título
    Local cNatureza     := "111109    " //Natureza utilizada
*/

Local cNumTitulo := GetSX8Num("SE1","E1_NUM")
Local cNatureza  := SuperGetMV( "ES_LINXCC1", .F., "111109" )
Local cCliente   := SuperGetMV( "ES_LINXCC2", .F., "000001" /*aSE1Linx[6]*/ )
Local cLojaCli   := SuperGetMV( "ES_LINXCC3", .F., "0001"   /*aSE1Linx[7]*/ )
Local cTipo      := SuperGetMV( "ES_LINXCC4", .F., "CC"     /*aSE1Linx[5]*/ )
Local cPrefixo   := SuperGetMV( "ES_LINXCC4", .F., "LNX"    /*aSE1Linx[1]*/ )

    PRIVATE lMsErroAuto := .F.
 
    //Numeracao do titulo destino (opcional)
    cNumTitulo := GetSX8Num("SE1","E1_NUM")
 
    dbSelectArea("SE1")
    dbSetOrder(2)
 
    If MsSeek(xFilial("SE1")+cCliente+cLojaCli)
        begin transaction
            aTitulo := {{"E1_PREFIXO" , cPrefixo     ,Nil},;
                {"E1_NUM"     , cNumTitulo  ,Nil},;
                {"E1_PARCELA" , " "      ,Nil},;
                {"E1_TIPO"    , cTipo     ,Nil},;
                {"E1_NATUREZ" , cNatureza    ,Nil},;
                {"E1_CLIENTE" , PADR(cCliente,TamSx3("E1_CLIENTE")[1]) ,Nil},;
                {"E1_LOJA"    , PADR(cLojaCli,TamSx3("E1_LOJA")[1])       ,Nil},;
                {"E1_EMISSAO" , dDataBase,Nil},;
                {"E1_VENCTO"  , dDataBase,Nil},;
                {"E1_VENCREA" , dDataBase,Nil},;
                {"E1_VALOR"   , 1000 ,Nil },;
                {"E1_DESDOBR"   ,"S" ,Nil }}
 
            aAdd(aTitulo,{"AUTHISTDSD","SEM RASTREIO",Nil}) //Historico
            aAdd(aTitulo,{"AUTNPARDSD",12,Nil}) // Numero de parcelas
            aAdd(aTitulo,{"AUTTOPADSD","T",Nil}) // Valor T = TOTAL ou P = PARCELA
            aAdd(aTitulo,{"AUTPERIDSD",30,Nil}) // Periodo
 
 			VarInfo( "aTitulo", aTitulo ) 
            MSExecAuto({|x,y,z| Fina040(x,y,z)},aTitulo,3)
 
            If lMsErroAuto
                MostraErro()
            Else
                conout("Titulo incluído com sucesso") 
            Endif
        End transaction  
    EndIf  
 
Return
