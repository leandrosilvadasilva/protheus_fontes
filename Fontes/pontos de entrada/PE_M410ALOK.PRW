User Function M410ALOK()

    Local retorno := .T.

    IF SC5->C5_XWMS == 'S'
        IF !isBlind()
            IF RetCodUsr() $ GETMV("MV_XALTPED")
                // Usuarios deste parametro podem alterar pedidos apos integradaos
            ELSE
                Aviso("Aten��o", "Pedido n�o pode ser alterado pois j� foi integrado com o WMS. ", {"OK"},3)
                retorno := .F.
            ENDIF
        ENDIF
    ENDIF

Return retorno
