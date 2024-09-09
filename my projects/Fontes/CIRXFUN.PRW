//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} PutSX1
FunÁ„o para criar Grupo de Perguntas
@author Atilio
@since 09/06/2017
@version 1.0
@type function
    @param cGrupo,    characters, Grupo de Perguntas       (ex.: X_TESTE)
    @param cOrdem,    characters, Ordem da Pergunta        (ex.: 01, 02, 03, ...)
    @param cTexto,    characters, Texto da Pergunta        (ex.: Produto De, Produto AtÈ, Data De, ...)
    @param cMVPar,    characters, MV_PAR?? da Pergunta     (ex.: MV_PAR01, MV_PAR02, MV_PAR03, ...)
    @param cVariavel, characters, Vari·vel da Pergunta     (ex.: MV_CH0, MV_CH1, MV_CH2, ...)
    @param cTipoCamp, characters, Tipo do Campo            (C = Caracter, N = NumÈrico, D = Data)
    @param nTamanho,  numeric,    Tamanho da Pergunta      (M·ximo de 60)
    @param nDecimal,  numeric,    Tamanho de Decimais      (M·ximo de 9)
    @param cTipoPar,  characters, Tipo do Par‚metro        (G = Get, C = Combo, F = Escolha de Arquivos, K = Check Box)
    @param cValid,    characters, ValidaÁ„o da Pergunta    (ex.: Positivo(), u_SuaFuncao(), ...)
    @param cF3,       characters, Consulta F3 da Pergunta  (ex.: SB1, SA1, ...)
    @param cPicture,  characters, M·scara do Par‚metro     (ex.: @!, @E 999.99, ...)
    @param cDef01,    characters, Primeira opÁ„o do combo
    @param cDef02,    characters, Segunda opÁ„o do combo
    @param cDef03,    characters, Terceira opÁ„o do combo
    @param cDef04,    characters, Quarta opÁ„o do combo
    @param cDef05,    characters, Quinta opÁ„o do combo
    @param cHelp,     characters, Texto de Help do par‚metro
    @obs FunÁ„o foi criada, pois a partir de algumas versies do Protheus 12, a funÁ„o padr„o PutSX1 n„o funciona (por medidas de seguranÁa)
    @example Abaixo um exemplo de como criar um grupo de perguntas
/*/
 
User Function PutSX1(cGrupo, cOrdem, cTexto, cMVPar, cVariavel, cTipoCamp, nTamanho, nDecimal, cTipoPar, cValid, cF3, cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, cHelp, cGrpSXG, cCnt01 )
    Local aArea       := GetArea()
    Local cChaveHelp  := ""
    Local nPreSel     := 0
    Default cGrupo    := Space(10)
    Default cOrdem    := Space(02)
    Default cTexto    := Space(30)
    Default cMVPar    := Space(15)
    Default cVariavel := Space(6)
    Default cTipoCamp := Space(1)
    Default nTamanho  := 0
    Default nDecimal  := 0
    Default cTipoPar  := "G"
    Default cValid    := Space(60)
    Default cF3       := Space(6)
    Default cPicture  := Space(40)
    Default cDef01    := Space(15)
    Default cDef02    := Space(15)
    Default cDef03    := Space(15)
    Default cDef04    := Space(15)
    Default cDef05    := Space(15)
    Default cHelp     := ""
    Default cGrpSXG   := ""		// tratamento inserido por Luciano CorrÍa em 06/07/18
    Default cCnt01    := ""		// tratamento inserido por Luciano CorrÍa em 03/11/18 - Perguntas do tipo Range
     
    //Se tiver Grupo, Ordem, Texto, Par‚metro, Vari·vel, Tipo e Tamanho, continua para a criaÁ„o do par‚metro
    If !Empty(cGrupo) .And. !Empty(cOrdem) .And. !Empty(cTexto) .And. !Empty(cMVPar) .And. !Empty(cVariavel) .And. !Empty(cTipoCamp) .And. nTamanho != 0
         
        //DefiniÁ„o de vari·veis
        cGrupo     := PadR(cGrupo, 10, " ")           //Adiciona espaÁos a direita para utilizaÁ„o no DbSeek
        cChaveHelp := "P." + AllTrim(cGrupo) + AllTrim(cOrdem) + "."  //Define o nome da pergunta
        cMVPar     := Upper(cMVPar)                                   //Deixa o MV_PAR tudo em mai?sculo
        nPreSel    := Iif(cTipoPar == "C", 1, 0)                      //Se for Combo, o prÈ-selecionado ser· o Primeiro
        cDef01     := Iif(cTipoPar == "F", "56", cDef01)              //Se for File, muda a definiÁ„o para ser tanto Servidor quanto Local
        nTamanho   := Iif(nTamanho > 60, 60, nTamanho)                //Se o tamanho for maior que 60, volta para 60 - LimitaÁ„o do Protheus
        nDecimal   := Iif(nDecimal > 9,  9,  nDecimal)                //Se o decimal for maior que 9, volta para 9
        nDecimal   := Iif(cTipoPar <> "N", nDecimal, 0)               //Se n„o for par‚metro do tipo numÈrico, ser· 0 o Decimal
        cTipoCamp  := Upper(cTipoCamp)                                //Deixa o tipo do Campo em mai?sculo
        cTipoCamp  := Iif(! cTipoCamp $ 'C;D;N;', 'C', cTipoCamp)     //Se o tipo do Campo n„o estiver entre Caracter / Data / NumÈrico, ser· Caracter
        cTipoPar   := Upper(cTipoPar)                                 //Deixa o tipo do Par‚metro em mai?sculo
        cTipoPar   := Iif(Empty(cTipoPar), 'G', cTipoPar)             //Se o tipo do Par‚metro estiver em branco, ser· um Get
        nTamanho   := Iif(cTipoPar == "C", 1, nTamanho)               //Se for Combo, o tamanho ser· 1
     
        DbSelectArea('SX1')
        SX1->(DbSetOrder(1)) // Grupo + Ordem
     
        //Se n„o conseguir posicionar, a pergunta ser· criada
        If ! SX1->(DbSeek(cGrupo + cOrdem))
            RecLock('SX1', .T.)
                X1_GRUPO   := cGrupo
                X1_ORDEM   := cOrdem
                X1_PERGUNT := cTexto
                X1_PERSPA  := cTexto
                X1_PERENG  := cTexto
                X1_VAR01   := cMVPar
                X1_VARIAVL := cVariavel
                X1_TIPO    := cTipoCamp
                X1_TAMANHO := nTamanho
                X1_DECIMAL := nDecimal
                X1_GSC     := cTipoPar
                X1_VALID   := cValid
                X1_F3      := cF3
                X1_PICTURE := cPicture
                X1_DEF01   := cDef01
                X1_DEFSPA1 := cDef01
                X1_DEFENG1 := cDef01
                X1_DEF02   := cDef02
                X1_DEFSPA2 := cDef02
                X1_DEFENG2 := cDef02
                X1_DEF03   := cDef03
                X1_DEFSPA3 := cDef03
                X1_DEFENG3 := cDef03
                X1_DEF04   := cDef04
                X1_DEFSPA4 := cDef04
                X1_DEFENG4 := cDef04
                X1_DEF05   := cDef05
                X1_DEFSPA5 := cDef05
                X1_DEFENG5 := cDef05
                X1_PRESEL  := nPreSel
                X1_GRPSXG  := cGrpSXG		// tratamento inserido por Luciano Correa em 06/07/18
                X1_CNT01   := cCnt01		// tratamento inserido por Luciano Correa em 06/07/18
                 
                //Se tiver Help da Pergunta
                If !Empty(cHelp)
                    X1_HELP    := ""
                     
                    fPutHelp(cChaveHelp, cHelp)
                EndIf
            SX1->(MsUnlock())
        EndIf
    EndIf
     
    RestArea(aArea)
Return
 
/*---------------------------------------------------*
 | FunÁ„o: fPutHelp                                  |
 | Desc:   FunÁ„o que insere o Help do Parametro     |
 *---------------------------------------------------*/
 
Static Function fPutHelp(cKey, cHelp, lUpdate)
    Local cFilePor  := "SIGAHLP.HLP"
    Local cFileEng  := "SIGAHLE.HLE"
    Local cFileSpa  := "SIGAHLS.HLS"
    Local nRet      := 0
    Default cKey    := ""
    Default cHelp   := ""
    Default lUpdate := .F.
     
    //Se a Chave ou o Help estiverem em branco
    If Empty(cKey) .Or. Empty(cHelp)
        Return
    EndIf
     
    //**************************** PortuguÍs
    nRet := SPF_SEEK(cFilePor, cKey, 1)
     
    //Se n„o encontrar, ser· inclus„o
    If nRet < 0
        SPF_INSERT(cFilePor, cKey, , , cHelp)
     
    //Sen„o, ser· atualizaÁ„o
    Else
        If lUpdate
            SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** InglÍs
    nRet := SPF_SEEK(cFileEng, cKey, 1)
     
    //Se n„o encontrar, ser· inclus„o
    If nRet < 0
        SPF_INSERT(cFileEng, cKey, , , cHelp)
     
    //Sen„o, ser· atualizaÁ„o
    Else
        If lUpdate
            SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** Espanhol
    nRet := SPF_SEEK(cFileSpa, cKey, 1)
     
    //Se n„o encontrar, ser· inclus„o
    If nRet < 0
        SPF_INSERT(cFileSpa, cKey, , , cHelp)
     
    //Sen„o, ser· atualizaÁ„o
    Else
        If lUpdate
            SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
        EndIf
    EndIf
Return
