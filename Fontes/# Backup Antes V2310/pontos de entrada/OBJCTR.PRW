USER FUNCTION OBJCTR(filial, contrato)

    Local aAreaCN9 := CN9->( GETAREA() )
    Local retorno := ''
    
    POSICIONE("CN9", 1, filial+ALLTRIM(contrato), "CN9_FILIAL")
    retorno := MSMM(CN9->CN9_CODOBJ, 200)

    RESTAREA( aAreaCN9 )

RETURN retorno
