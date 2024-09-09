
user function GRPAPEC()

Local aEntCtb := PARAMIXB[1]
Local lEntCtb := PARAMIXB[2]
Local cTpDoc := PARAMIXB[3]
Local aRetApv := {}
Local aAreaSY1 := SY1->( GETAREA() )


    grupo := posicione("SY1",3,xFILIAL("SY1")+RETCODUSR(),"Y1_GRAPROV") // verifica o grupo do comprador

    IF ALLTRIM(grupo) == '99999A' .OR. ALLTRIM(grupo) == '99999B'
        RESTAREA( aAreaSY1 )
        RETURN {grupo,''}
    ENDIF


RESTAREA( aAreaSY1 )
Return aRetApv
