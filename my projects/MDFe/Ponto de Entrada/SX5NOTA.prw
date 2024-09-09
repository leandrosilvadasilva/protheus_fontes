#Include "Protheus.ch"

/*/{Protheus.doc} SX5NOTA
description
@type function
@version  
@author dwt.eudinei
@since 26/11/2023
@return variant, return_description
/*/
User Function SX5NOTA()

	Local _cFilial  := Paramixb[1]  //Filial
    //Local _cTabela  := Paramixb[2]  //Tabela da SX5
    Local _cChave   := Paramixb[3]  //Chave da Tabela na SX5
    Local _lRet     := .F.

    if IsInCallStack("SPEDMDFE") 

        If Alltrim(_cFilial) == "0101" .And. Alltrim(_cChave) == "21"
            _lRet := .T.
        Endif
        If Alltrim(_cFilial) == "0102" .And. Alltrim(_cChave) == "22"
            _lRet := .T.
        Endif
        If Alltrim(_cFilial) == "0103" .And. Alltrim(_cChave) == "23"
            _lRet := .T.
        Endif
        If Alltrim(_cFilial) == "0104" .And. Alltrim(_cChave) == "24"
            _lRet := .T.
        Endif
        If Alltrim(_cFilial) == "0105" .And. Alltrim(_cChave) == "25"
            _lRet := .T.
        Endif
        If Alltrim(_cFilial) == "0106" .And. Alltrim(_cChave) == "26"
            _lRet := .T.
        Endif
        If Alltrim(_cFilial) == "0107" .And. Alltrim(_cChave) == "27"
            _lRet := .T.
        Endif
    Else
        If Alltrim(_cFilial) == "0101" .And. Alltrim(_cChave) == "21"
            _lRet := .F.
        ElseIf Alltrim(_cFilial) == "0102" .And. Alltrim(_cChave) == "22"
            _lRet := .F.
        ElseIf Alltrim(_cFilial) == "0103" .And. Alltrim(_cChave) == "23"
            _lRet := .F.
        ElseIf Alltrim(_cFilial) == "0104" .And. Alltrim(_cChave) == "24"
            _lRet := .F.
        ElseIf Alltrim(_cFilial) == "0105" .And. Alltrim(_cChave) == "25"
            _lRet := .F.
        ElseIf Alltrim(_cFilial) == "0106" .And. Alltrim(_cChave) == "26"
            _lRet := .F.
        ElseIf Alltrim(_cFilial) == "0107" .And. Alltrim(_cChave) == "27"
            _lRet := .F.
        else
            _lRet := .T.    
        Endif   
    Endif
Return _lRet
