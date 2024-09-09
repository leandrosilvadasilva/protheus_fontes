#INCLUDE 'TOTVS.ch'


//IATAN EM 07/11/2023
//CHAMADO #11100

User Function MT110APV 

    Local retorno := .T.
    Local sql 
    Local aAreaCTT := CTT->( GETAREA() )
    Local msg := ''

    sql := "SELECT DISTINCT C1_CC FROM SC1010 WHERE D_E_L_E_T_ <> '*' AND C1_FILIAL = '" + SC1->C1_FILIAL + "' AND C1_NUM = '" + SC1->C1_NUM + "' " 

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,sql ),"_SC1",.T.,.T. )
  
    While (_SC1->(!EOF()))
        POSICIONE("CTT", 1, XFILIAL("CTT")+_SC1->C1_CC, "CTT_CUSTO")
        IF ALLTRIM(RETCODUSR()) $ ALLTRIM(CTT->CTT_XAPROV)
            // USUÁRIO PERMITIDO PARA APROVAR ESTE CENTRO DE CUSTO
        ELSE
            retorno := .F.
            msg := msg + ALLTRIM(SC1->C1_CC) + ", "
        ENDIF
        _SC1->(DbSkip())
    End
    _SC1->(DBCloseArea())

    RESTAREA( aAreaCTT )

    IF retorno == .F.
        ALERT("Usuário sem premissão para aprovar os seguintes centros de custo.: " + SUBSTR(msg, 1, LEN(msg)-1) )
    ENDIF
    
Return retorno
