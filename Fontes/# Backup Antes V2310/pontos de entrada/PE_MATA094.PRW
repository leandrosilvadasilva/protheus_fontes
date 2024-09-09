#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"  

#DEFINE INCLUSAO    3
#DEFINE ALTERACAO   4
#DEFINE EXCLUSAO    5
#DEFINE COPIA       3

Static __LogTela    := NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980
Ponto de Entrada do Cadastro de Clientes (MVC)

@param      Não há
@return     Vários. Dependerá de qual PE está sendo executado.
@author 	Faturamento
@version	12.1.17 / Superior
@since		Mai/2021
/*/
//-------------------------------------------------------------------
User Function MATA094() 
Local aParam     := PARAMIXB
Local lRet       := .T.
Local lIsGrid    := .F.
Local cIDPonto   := ''
Local cIDModel   := ''
Local oObj       := NIL
Local cObs       := ""  AS CHARACTER
Local lTemObs    := .T. AS BOOLEAN 

Local oModel     := NIL
Local oModelSCR  := NIL

If aParam <> NIL

    oObj        := aParam[1]
    cIDPonto    := aParam[2]
    cIDModel    := aParam[3]
    lIsGrid     := (Len(aParam) > 3)

    __LogTela   := SuperGetMV( "MA_LOGPEMVC", .F., .F. )    
    If __LogTela
    
        ShwParam(aParam)
    EndIf

    If cIDPonto == 'FORMPOS'

        If __LogTela
        
            ApMsgInfo("Dados da chamadda do MVC'" + cIDPonto + "')." + CRLF + "ID " + cIDModel)
        EndIf

        oModel  := FWModelActive()
        oModelSCR := FWModelActive()

        cObs    := oModelSCR:AALLSUBMODELS[1]:ADATAMODEL[1][10][2]
        lTemObs := Len( AllTrim( cObs )) == 0   

        If lTemObs .and. .F.

            //FwAlertInfo( "Favor preencher o campo Observação", "Campo observação é obrigatorio")   
            lRet:= .F.
        EndIf

        //FreeObj( oModelSCR )
    EndIf
EndIf
    
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ShwParamM->CR_OBS
Exibe os parâmetros do Ponto de Entrada do Cadastro de Clientes (MVC)
@param      aParam
@return     NIL
@author 	Faturamento
@version	12.1.17 / Superior
@since		Mai/2021
/*/
//-------------------------------------------------------------------
Static Function ShwParam(aParam)
Local nInd          := 1
Local cAuxMsg       := ''
Local cAuxMsg2      := ''
Local cSeparador    := Repl('-', 40)
Local cMsg          := Iif( !(aParam[2] $ 'FORMPRE//FORMPOS//FORMCOMMITTTSPRE//FORMCOMMITTTSPOS'),;
                            'OPERATION = ' + AllTrim(Str(aParam[01]:NOPERATION)) + CRLF,;
                            '')

For nInd := 1 to Len(aParam)

    cAuxMsg     := ''
    cAuxMsg2    := ''

    If ValType(aParam[nInd]) == 'U'

        cAuxMsg2         := '= ' + ' NIL'
    ElseIf ValType(aParam[nInd]) == 'O'

        cAuxMsg2         := ' (OBJETO)'
    ElseIf ValType(aParam[nInd]) == 'C'

        cAuxMsg2         := "= '" + aParam[nInd] + "'"
    ElseIf ValType(aParam[nInd]) == "N"

        cAuxMsg2         := '= ' + AllTrim(Str(aParam[nInd]))
    ElseIf ValType(aParam[nInd]) == "D"

        cAuxMsg2         := '= ' + DtoC(aParam[nInd])
    ElseIf ValType(aParam[nInd]) == 'L'

        cAuxMsg2         := '= ' + If(aParam[4], '.T.', '.F.')
    EndIf

    If nInd == 2

        cAuxMsg        := 'IDPonto (Evento)'
    ElseIf nInd == 3

        cAuxMsg        := 'IDModelo'
    ElseIf (nInd == 4 .OR. nInd == 5 .OR. nInd == 6)

        If aParam[2] == 'FORMPRE'
            If nInd == 4

                cAuxMsg    := 'Evento'
            ElseIf nInd == 5
            
                cAuxMsg    := 'Campo'
            ElseIf nInd == 6 .AND. aParam[4] == 'SETVALUE'

                cAuxMsg    := 'Conteúdo'
            EndIf
        ElseIf (aParam[2] $ 'FORMCOMMITTTSPRE//FORMCOMMITTTSPOS') .AND. nInd == 6

            cAuxMsg        := 'Conteúdo'
        EndIf
    EndIf

    cMsg    += 'PARAMIXB[' + StrZero(nInd,2) + '] => ' + If(!Empty(cAuxMsg),cAuxMsg + ' ', '') + cAuxMsg2 + CRLF

Next nInd

If __LogTela

    ApMsgInfo("Segue a descrição dos parâmetros recebidos no PE CRMA980 MVC conforme o 'IDPonto' que está sendo executado no momento:" +;
              CRLF + CRLF +;
              cMsg)
Else

    ConOut(cMsg + cSeparador)
EndIf

Return NIL


