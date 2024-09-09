
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include 'Totvs.ch'

/*
    IATAN EM 12/07/2022
    USER FUNCTION DEFINIDA PARA RETORNAR O NÚMERO DA SÉRIE DA NOTA 
    BASEADO NAS REGRAS QUE FORAM PASSADAS

    REGRA SOMENTE PARA VENDAS PORQEU EM DEVOLUÇÕES DEVO BUSCAR A SÉRIE DA NOTA DE ORIGEM (SD2)
*/

User Function getSerie(filial, operacao)

    Local serie := ''

    IF filial == '0101'
        
        IF operacao $ '19-27'
            serie := 'NSM'
        ELSEIF operacao $ '14-15-21'
            serie := '6  '
        ELSE 
            serie := '4  '
        ENDIF

    ELSEIF filial == '0102'

        IF operacao $ '19-27'
            serie := 'NSM'
        ELSE 
            serie := '1  '
        ENDIF

    ELSEIF filial == '0103'

        IF operacao $ '19-27'
            serie := 'NSM'
        ELSE 
            serie := '3  '
        ENDIF

    ELSEIF filial == '0104'

        IF operacao $ '19-27'
            serie := 'NSM'
        ELSE 
            serie := '5  '
        ENDIF

    ELSEIF filial == '5001'

        IF operacao $ '19-27'
            serie := 'NSM'
        ELSE 
            serie := '5  '
        ENDIF
    ELSEIF filial == '0105'

        IF operacao $ '19-27'
            serie := 'NSM'
        ELSE 
            serie := '7  '
        ENDIF       
    ELSEIF filial == '0106'

        IF operacao $ '19-27'
            serie := 'NSM'
        ELSE 
            serie := '8  '
        ENDIF
    ELSEIF filial == '0107'

        IF operacao $ '19-27'
            serie := 'NSM'
        ELSE 
            serie := '9  '
        ENDIF    
    ENDIF

RETURN serie
