//Bibliotecas
#Include "Protheus.ch"

 /*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120TEL                                                                                              |
 | Desc:  Ponto de Entrada para adicionar campos no cabeçalho do pedido de compra                               |
 | Link:  http://tdn.totvs.com/display/public/mp/MT120TEL                                                       |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] 
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local nRecPC    := PARAMIXB[5]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
    Local oXObsAux
    Public cXObsAux := ""

    AAdd( aTitles, 'Outros' )

    //Define o conteúdo para os campos
    SC7->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXObsAux := CriaVar("C7_ZOBS",.F.)
    Else
        cXObsAux := SC7->C7_ZOBS
    EndIf
 
    //Criando na janela o campo OBS
    @ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_ZOBS")) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 MSGET oXObsAux VAR cXObsAux SIZE 100, 006 OF oDlg COLORS 0, 16777215  PIXEL
    oXObsAux:bHelp := {|| ShowHelpCpo( "C7_ZOBS", {GetHlpSoluc("C7_ZOBS")[1]}, 5  )}
 
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXObsAux:lActive := .F.
    EndIf
 
    RestArea(aArea)
Return

User Function MT120FOL( )
 
    Local aArea     := GetArea()
    Local nOpcx    := PARAMIXB[1]
    Local aPosGet := PARAMIXB[2]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
    Local oXObsFor
    Public cXObsFor := ""
     
    //Define o conteúdo para os campos
    If nOpcx == 3
        cXObsFor := CriaVar("C7_ZFORMAP",.F.)
    Else
        cXObsFor := SC7->C7_ZFORMAP
    EndIf
 
    //Criando na janela o campo OBS
    @ 006,aPosGet[3,1] SAY Alltrim(RetTitle("C7_ZFORMAP")) OF oFolder:aDialogs[7] PIXEL SIZE 070,009 
    oXObsFor := TMultiget():Create(oFolder:aDialogs[7],{|u|if(Pcount()>0,cXObsFor:=u,cXObsFor)},005,aPosGet[3,2]-100,150,050,,,,,,.T.)
    oXObsFor:bHelp := {|| ShowHelpCpo( "C7_ZFORMAP", {GetHlpSoluc("C7_ZFORMAP")[1]}, 5  )}
 
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXObsFor:lActive := .F.
    EndIf
  
    RestArea(aArea)
 
Return Nil 

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MTA120G2                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações no pedido de compra a cada item (usado junto com MT120TEL)   |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=6085572                                          |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function MTA120G2()
    Local aArea := GetArea()
 
    //Atualiza a descrição, com a variável pública criada no ponto de entrada MT120TEL
    If Type("cXObsAux") != "U" .AND. Type("cXObsFor") != "U"
        SC7->C7_ZOBS := cXObsAux
        SC7->C7_ZFORMAP := cXObsFor
    Endif
    RestArea(aArea)
Return
