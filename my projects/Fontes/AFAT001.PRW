#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH" 
#include "Protheus.ch"
#include "topconn.ch"
#Include "TOTVS.ch" 


/*
    Data.: 27/12/2022
    Autor.: Iatan Santos
    Solicitação.: Iatan / Iolete
    Departamento.: Faturamento
    Finalidade.: Contemplar a alteração de numeração de notas exclusivamente da série "A2" ( Notas de serviço )
*/


User Function AFAT001

    Local mensagem := ''
    Local serie    := ''
    Local ultimaNota

    IF CFILANT == '0101'
        serie = "A2"
    ELSEIF CFILANT == '0102'
        serie = "A1"
    ELSEIF CFILANT == '0103'
        serie = "A3"
    ELSEIF CFILANT == '0105'
        serie = "A7"
    ELSEIF CFILANT == '0106'
        serie = "A8"
    ELSEIF CFILANT == '0107'
        serie = "A9"            
    ENDIF

    ultimaNota := getUltimaNota(serie)
    mensagem := "Última nota emitida = " + ultimaNota + ". Deseja seguir com a correção da numeração ?"

    IF FWAlertYesNo(mensagem, "Alteração de Numeração de Notas - Série '" + serie + "'")
            limpaSF3(ultimaNota, serie)
            limpaSFT(ultimaNota, serie)
            limpaSD9(ultimaNota, serie)
            FWAlertSuccess("Numeração Corrigida", "Alteração de Numeração de Notas - Série '" + serie + "'")
    ENDIF

Return


Static Function getUltimaNota(serie)

    Local cQry
    Local retorno 

    cQry := " SELECT MAX(F2_DOC) AS ULTIMA FROM SF2010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND F2_FILIAL = '" + CFILANT + "' AND F2_SERIE = '" + serie + "' "

	TCQuery cQry New Alias "QRY_SF2"
	
	QRY_SF2->(DbGoTop())

	While ! QRY_SF2->(Eof())

        retorno := QRY_SF2->ULTIMA

		QRY_SF2->(DbSkip())
	EndDo

	QRY_SF2->(DbCloseArea())

return retorno



Static Function limpaSF3(ultimaNota, serie)

    Local cQry

    cQry := " SELECT * FROM SF3010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND F3_FILIAL = '" + CFILANT + "' AND F3_SERIE = '" + serie + "' AND F3_NFISCAL > '" + ultimaNota + "' "

	TCQuery cQry New Alias "QRY_SF3"
	
	QRY_SF3->(DbGoTop())

	While ! QRY_SF3->(Eof())

        SF3->( DBGOTO(QRY_SF3->R_E_C_N_O_) )
        RecLock("SF3", .F.)
            SF3->(dbDelete())
        SF3->( MsUnLock() )

		QRY_SF3->(DbSkip())
	EndDo

	QRY_SF3->(DbCloseArea())

return


Static Function limpaSFT(ultimaNota, serie)

    Local cQry

    cQry := " SELECT * FROM SFT010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND FT_FILIAL = '" + CFILANT + "' AND FT_SERIE = '" + serie + "' AND FT_NFISCAL > '" + ultimaNota + "' "

	TCQuery cQry New Alias "QRY_SFT"
	
	QRY_SFT->(DbGoTop())

	While ! QRY_SFT->(Eof())

        SFT->( DBGOTO(QRY_SFT->R_E_C_N_O_) )
        RecLock("SFT", .F.)
            SFT->(dbDelete())
        SFT->( MsUnLock() )

		QRY_SFT->(DbSkip())
	EndDo

	QRY_SFT->(DbCloseArea())

return


Static Function limpaSD9(ultimaNota, serie)

    Local cQry

    cQry := " SELECT * FROM SD9010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND D9_FILIAL = '" + CFILANT + "' AND D9_SERIE = '" + serie + "' AND D9_DOC > '" + ultimaNota + "' "

	TCQuery cQry New Alias "QRY_SD9"
	
	QRY_SD9->(DbGoTop())

	While ! QRY_SD9->(Eof())

        SD9->( DBGOTO(QRY_SD9->R_E_C_N_O_) )
        RecLock("SD9", .F.)
            SD9->D9_DTUSO   := CTOD(SPACE(8))
            SD9->D9_HORA    := ''
            SD9->D9_USUARIO := ''
            SD9->D9_MOTIVO  := ''
            SD9->D9_NSU     := ''
            SD9->D9_CNPJ    := ''
            SD9->D9_FILORI  := ''
        SD9->( MsUnLock() )

		QRY_SD9->(DbSkip())
	EndDo

	QRY_SD9->(DbCloseArea())

return


