#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch"
#Include "RESTFUL.CH"
#include 'shell.ch'

/*
    IATAN EM 29/09/2022 - chamada de rotina de geração de pdf via chedule do protheus
*/
USER FUNCTION SCH_PDF()

    Local cCommand := "D:\Totvs\Protheus\bin\smartclient\smartclient.exe -q -p=u_GERADANFE -c=PDF -e=PRODUCAO -m -l=1 "
    Local lWait  := .F.
    Local cPath     := "C:\temp\"

    CONOUT("INICIANDO PDF FILIAL 0101")

    WaitRunSrv( @cCommand , @lWait , @cPath )


RETURN

//IATAN EM 21/02/2023 - SEPARAR A GERAÇÃO DO PDF PARA AUMENTAR A PERFORMANCE
USER FUNCTION PDF2()

    Local cCommand := "D:\Totvs\Protheus\bin\smartclient2\smartclient.exe -q -p=u_GRDANFE2 -c=PDF -e=PRODUCAO -m -l=1 "
    Local lWait  := .F.
    Local cPath     := "C:\temp2\"

    CONOUT("INICIANDO PDF DEMAIS FILIAIS")

    WaitRunSrv( @cCommand , @lWait , @cPath )


RETURN

/*
    IATAN EM 24/07/2022 - ARQUIVO RESPONSÁVEL POR GERAR PDF E XML VIA JOB
*/
USER FUNCTION GERADANFE()
    
    Local _cQry     := ''
    Local resposta
    Local gerandoDanfe := .T.
    Local arrInfo := GetUserInfoArray(.T.)
    Local contador := 0
    Local nX := 1

    Local aAnexoBol   :={}
    Local aAnexoDanfe := {}


    FOR nX := 1 TO LEN(arrInfo)
        IF ALLTRIM(arrInfo[nX][5]) == "U_GERADANFE"
            //ENCERRA CONEXÕES ABERTAS A MAIS DE 5 MIN
            IF arrInfo[nX][8] >= "00:05:00"
                CONOUT("**********ATENCAO**********")
                CONOUT("ENCERRANDO CONEXÃO ( THREAD ID ).: "+CVALTOCHAR(arrInfo[nX][3]))
                CONOUT("**********ATENCAO**********")
                KillUser( arrInfo[nX][1],; //UserName
                          arrInfo[nX][2],; //ComputerName
                          arrInfo[nX][3],; //ThreadId
                          arrInfo[nX][4])  //ServerName
            ELSE
                contador++
            ENDIF

        ENDIF
    NEXT nX
     
    IF contador > 1 // 1 = THREAD ATUAL
        CONOUT("--->> SAINDO DA ROTINA POIS ESTA JA ESTA SENDO EXECUTADA EM OUTRO THREAD<<---")
        RETURN
    ENDIF


    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" 


    xDiasPDF  := GETMV("MV_XDPDF")

    _cQry := " SELECT DISTINCT C5_NUM, STATUS, F2_XSTATUS, F2_FILIAL, SF2.R_E_C_N_O_ , F2_XSTATUS, F2_CHVNFE, F2_DOC, F2_SERIE, SF3.R_E_C_N_O_ AS SF3_RECNO "
    _cQry += " FROM SF2010 SF2 WITH (NOLOCK) INNER JOIN SD2010 SD2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE  "
    _cQry += "                                          AND F2_LOJA = D2_LOJA  AND F2_ESPECIE = 'SPED' AND F2_EMISSAO >= '20220822' AND F2_CHVNFE <> '' "
    _cQry += "                 INNER JOIN SC5010 SC5 WITH (NOLOCK) ON C5_FILIAL = D2_FILIAL AND C5_CLIENTE = D2_CLIENTE AND C5_LOJACLI = D2_LOJA AND C5_NUM = D2_PEDIDO "
//IATAN EM 16/05/2023    
//    _cQry += " 				INNER JOIN SPED050 SPED WITH (NOLOCK) ON CAST(F2_DOC AS INT) = DOC_ID AND F2_SERIE = CAST(DOC_SERIE AS VARCHAR) AND DATE_NFE = F2_EMISSAO "
    _cQry += " 				INNER JOIN SPED050 SPED WITH (NOLOCK) ON CAST(F2_DOC AS INT) = DOC_ID AND F2_SERIE = CAST(DOC_SERIE AS VARCHAR) "
    _cQry += " 				INNER JOIN SF3010 SF3 WITH (NOLOCK) ON F3_FILIAL = F2_FILIAL AND F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F3_CLIEFOR = F2_CLIENTE AND F3_LOJA = F2_LOJA AND F3_EMISSAO = F2_EMISSAO AND F3_ESPECIE = F2_ESPECIE AND SUBSTRING(F3_CFO,1,1) >= '5' "
    _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' AND SF3.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*' AND SPED.D_E_L_E_T_ <> '*'  "
    _cQry += "       AND F2_XSTATUS <> STATUS AND F2_FILIAL = '0101' AND F2_EMISSAO >= '" + DTOS(dDataBase-xDiasPDF) + "'"
    _cQry += "       AND F3_CODRSEF = '100' " // IATAN EM 11/04/2024
//    _cQry += "       AND F2_DOC = '000073982' "
    //iatan em 22/04/2024 - foi necessário pois a série NSM não é transmitida para a Sefaz
    _cQry += "   UNION ALL "
    _cQry += "   SELECT DISTINCT C5_NUM, '6' AS STATUS, F2_XSTATUS, F2_FILIAL, SF2.R_E_C_N_O_ , F2_XSTATUS, F2_CHVNFE, F2_DOC, F2_SERIE, SF3.R_E_C_N_O_ AS SF3_RECNO  "
    _cQry += "   FROM SF2010 SF2 WITH (NOLOCK) INNER JOIN SD2010 SD2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE   "
    _cQry += "                                            AND F2_LOJA = D2_LOJA  AND (F2_ESPECIE = 'SPED' OR F2_SERIE = 'NSM' ) AND F2_EMISSAO >= '20220822' AND ( F2_CHVNFE <> '' OR F2_SERIE = 'NSM' )  "
    _cQry += " 				  INNER JOIN SC5010 SC5 WITH (NOLOCK) ON C5_FILIAL = D2_FILIAL AND C5_CLIENTE = D2_CLIENTE AND C5_LOJACLI = D2_LOJA AND C5_NUM = D2_PEDIDO  "
    _cQry += "                   INNER JOIN SF3010 SF3 WITH (NOLOCK) ON F3_FILIAL = F2_FILIAL AND F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F3_CLIEFOR = F2_CLIENTE AND F3_LOJA = F2_LOJA AND F3_EMISSAO = F2_EMISSAO AND F3_ESPECIE = F2_ESPECIE AND ( SUBSTRING(F3_CFO,1,1) >= '5'  OR F2_SERIE = 'NSM' ) "
    _cQry += "   WHERE SF2.D_E_L_E_T_ <> '*' AND SF3.D_E_L_E_T_ <> '*' AND F2_FILIAL = '0101' AND F2_SERIE = 'NSM' AND F2_XSTATUS = '' AND F2_EMISSAO >= '" + DTOS(dDataBase-xDiasPDF) + "'"
    _cQry += "   ORDER BY C5_NUM "

    //IATAN EM 11/10/2022 - CHANGEQUERY NÃO FUNCIONA COM WITH (NOLOCK)
    //_cQry := ChangeQuery(_cQry) 
        dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SF2",.T.,.T. )
    
    While (_SF2->(!EOF()))

        CFILANT := _SF2->F2_FILIAL

        //POSICIONO NA SC5 PORQUE O MAPWMS11 ESPERA QUE A SC5 ESTEJA POSICIONADA
        DbSelectArea("SC5")
        SC5->(DbSetOrder(1))
        SC5->(DbSeek(_SF2->F2_FILIAL + _SF2->C5_NUM))

        SF2->(DBGOTO( _SF2->R_E_C_N_O_ ))
        
        IF SF2->F2_XSTATUS <> cValToChar(_SF2->STATUS)


            //U_MAPWMS07( SC5->( Recno() ) )
            CONOUT("Iniciando processo NF = " + SF2->F2_DOC)
            RECLOCK("SC5", .F.)
                SC5->C5_XWMS := 'S'
            SC5->(MsUnlock())

            CONOUT("Inicio = MANDANDO PEDIDO PARA WMS.: " + _SF2->F2_FILIAL + _SF2->C5_NUM)

            resposta := U_MAPWMS11( _SF2->R_E_C_N_O_ )
//            VARINFO("RESPOSTA.:::", resposta)
            CONOUT("Termino = MANDANDO PEDIDO PARA WMS.: " + _SF2->F2_FILIAL + _SF2->C5_NUM)
            IF LEN(resposta) >= 2
                // "Nenhuma carga do pedido" incluída em 21/07/2022 pois segundo Gabriel este status é válido
                IF resposta[1] == .T. .OR. "Nenhuma carga do pedido" $ resposta[2]  .OR. "não foi localizado no WMS ou já possuí NFe associada" $ resposta[2]  

                    SF2->(DBGOTO( _SF2->R_E_C_N_O_ ))
                    RECLOCK("SF2", .F.)
                        SF2->F2_XSTATUS := cValToChar(_SF2->STATUS)
                    SF2->(MsUnlock())

                    SF2->(DBGOTO( _SF2->R_E_C_N_O_ ))
                    SF3->(DBGOTO( _SF2->SF3_RECNO ))
                    //IATAN EM 08/10/2022 - MUDARAM O CAMINHO DA GERAÇÃO DO PDF AO MUDAR O SERVIDOR PARA CLOUD
                    IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".pdf") .OR. FILE("\pdf_wms\"+"xml\"+SF2->F2_CHVNFE+".xml")
                        CONOUT("******CHAVE JA EXISTE*****-->"+SF2->F2_CHVNFE)
                    ELSE
                        CONOUT("ENTRANDO NA GERAÇÃO DA DANFE.: " + _SF2->F2_FILIAL + _SF2->F2_DOC)
                        u_wGerDanfe(_SF2->F2_CHVNFE, _SF2->F2_DOC, _SF2->F2_SERIE, "\pdf_wms\", '', 2)
                        CONOUT("SAINDO DA GERAÇÃO DA DANFE.: " + _SF2->F2_FILIAL + _SF2->F2_DOC)
                        //IATAN EM 12/10/2022 - CÓPIA DOS ARQUIVOS VAI OCORRER VIA SCRIPT AGENDADO A CADA 5 SEG
                        //IATAN EM 18/02/2023 - COPIA NÃO É MAIS NECESSÁRIA APÓS MIGRAR O WMS PARA NUVEM
                        /*
                        CONOUT(" ... COPIANDO ARQUIVOS PARA PASTA REMOTA ... ")

                        IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".rel")
                            CONOUT(" ... ESPERANDO 2 SEGUNDOS PARA CONVERTER PDF ... ")
                            //SLEEP(2000) // PAUSA DE 2 SEGUNDOS
                        ENDIF
                        IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".pdf")
                            WAITRUNSRV( "XCOPY D:\Totvs\Protheus_data\pdf_wms\pdf\"+SF2->F2_CHVNFE+".pdf \\192.168.11.61\arquivos\PUBLICO\PDF_NFS\pdf", .F., "c:\temp" )    
                        ENDIF

                        IF FILE("\pdf_wms\"+"boleto\"+SF2->F2_CHVNFE+".rel")
                            CONOUT(" ... ESPERANDO 2 SEGUNDOS PARA CONVERTER BOLETO ... ")
                            //SLEEP(2000) // PAUSA DE 2 SEGUNDOS
                        ENDIF
                        IF FILE("\pdf_wms\"+"boleto\"+SF2->F2_CHVNFE+".pdf")
                            WAITRUNSRV( "XCOPY D:\Totvs\Protheus_data\pdf_wms\boleto\"+SF2->F2_CHVNFE+".pdf \\192.168.11.61\arquivos\PUBLICO\PDF_NFS\boleto", .F., "c:\temp" )    
                        ENDIF
                        CONOUT(" ... TERMINO COPIA ARQUIVOS PARA PASTA REMOTA ... ")
                        */
                        //Iatan em 30/10/2022 - Incluir o envio de email para os pedidos faturados via wms
                        //eNFeOPME(SF2->F2_DOC,SF2->F2_SERIE,_SF2->C5_NUM,"????",'opme@mahospitalar.com.br',SF2->F2_CLIENTE,SF2->F2_LOJA,NIL,cPvFil,cPv)

                        //IATAN EM 07/02/2023
                        aAnexoBol   := {}
                        aAnexoDanfe := {}
                        CONOUT("ENTRANDO NOS ANEXOS .: " + _SF2->F2_FILIAL + _SF2->F2_DOC)
                        //IATAN EM 24/01/2023
                        IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".pdf")
                            aAdd(aAnexoDanfe, "\pdf_wms\pdf\"+SF2->F2_CHVNFE+".pdf") 
                        ENDIF
                        IF FILE("\pdf_wms\"+"boleto\"+SF2->F2_CHVNFE+".pdf")
                            aAdd(aAnexoBol, "\pdf_wms\boleto\"+SF2->F2_CHVNFE+".pdf") 
                        ENDIF
                        IF FILE("\pdf_wms\"+"xml\"+SF2->F2_CHVNFE+".xml")
                            aAdd(aAnexoDanfe, "\pdf_wms\xml\"+SF2->F2_CHVNFE+".xml") 
                        ENDIF
                        CONOUT("SAÍNDO DOS ANEXOS .: " + _SF2->F2_FILIAL + _SF2->F2_DOC)
                        //IATAN EM 07/02/2023
                        CONOUT("ENVIANDO EMAIL .: " + _SF2->F2_FILIAL + _SF2->F2_DOC)
                        IF LEN(aAnexoDanfe) > 0
                            envEmail(aAnexoDanfe, SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE)
                        ENDIF
                        CONOUT("SAINDO DO ENVIO EMAIL .: " + _SF2->F2_FILIAL + _SF2->F2_DOC)

                        //IATAN EM 26/09/2023 - VALIDAR SE OS ARQUIVOS PDF ESTÃO CORROMPIDOS
                        //RETIRADO EM 28/09/2023 POIS NÃO DEU MUITO CERTO A IMPLEMENTAÇÃO
                        //U_VALIDA_PDF(_SF2->F2_CHVNFE, _SF2->F2_DOC, _SF2->F2_SERIE )


                    ENDIF


                ELSE 
                    CONOUT("******ERRO MAPWMS11*****-->"+resposta[2])
                ENDIF
            ENDIF

        ENDIF
        //FALTA INTEGRAR AS NOTAS DE ENTRADA
        //U_MAPWMS16( _SF1->R_E_C_N_O_ )

        //IATAN EM 11/01/2024 - INTEGRAR A NOTA DE ENTRADA NÃO FISCAL DO ATIVO VINCULADA Á NOTA 
        INTEGRA_ATIVO(_SF2->F2_FILIAL, _SF2->F2_DOC, _SF2->F2_SERIE)


        _SF2->(DbSkip())

    End
    _SF2->(DBCloseArea())

    CONOUT("***FINALIZANDO PROCESSO***")


RESET ENVIRONMENT  

RETURN

/*
    IATAN EM 21/02/2023 - SEPARAÇÃO DA GERAÇÃO DOS ARQUIVOS PARA MELHORIA DE PERFORMANCE
*/
USER FUNCTION GRDANFE2()
    Local _cQry     := ''
    Local resposta
    Local gerandoDanfe := .T.
    Local arrInfo := GetUserInfoArray()
    Local contador := 0
    Local nX := 1

    Local aAnexoBol   :={}
    Local aAnexoDanfe := {}

    FOR nX := 1 TO LEN(arrInfo)
        IF ALLTRIM(arrInfo[nX][5]) == "U_GRDANFE2"
            //ENCERRA CONEXÕES ABERTAS A MAIS DE 5 MIN
            IF arrInfo[nX][8] >= "00:05:00"
                CONOUT("**********ATENCAO**********")
                CONOUT("ENCERRANDO CONEXÃO ( THREAD ID ).: "+CVALTOCHAR(arrInfo[nX][3]))
                CONOUT("**********ATENCAO**********")
                KillUser( arrInfo[nX][1],; //UserName
                          arrInfo[nX][2],; //ComputerName
                          arrInfo[nX][3],; //ThreadId
                          arrInfo[nX][4])  //ServerName
            ELSE
                contador++
            ENDIF

        ENDIF
    NEXT nX

    IF contador > 1 // 1 = THREAD ATUAL
        CONOUT("--->> SAINDO DA ROTINA POIS ESTA JA ESTA SENDO EXECUTADA EM OUTRO THREAD<<---")
        RETURN
    ENDIF

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" 

    xDiasPDF  := GETMV("MV_XDPDF")

    _cQry := " SELECT DISTINCT C5_NUM, STATUS, F2_XSTATUS, F2_FILIAL, SF2.R_E_C_N_O_ , F2_XSTATUS, F2_CHVNFE, F2_DOC, F2_SERIE, SF3.R_E_C_N_O_ AS SF3_RECNO, F2_EST AS F1_EST "
    _cQry += " FROM SF2010 SF2 WITH (NOLOCK) INNER JOIN SD2010 SD2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE  "
    _cQry += "                                          AND F2_LOJA = D2_LOJA  AND F2_ESPECIE = 'SPED' AND F2_EMISSAO >= '20220822' AND F2_CHVNFE <> '' "
    _cQry += "                 INNER JOIN SC5010 SC5 WITH (NOLOCK) ON C5_FILIAL = D2_FILIAL AND C5_CLIENTE = D2_CLIENTE AND C5_LOJACLI = D2_LOJA AND C5_NUM = D2_PEDIDO "
//IATAN EM 16/05/2023
//    _cQry += " 				INNER JOIN SPED050 SPED WITH (NOLOCK) ON CAST(F2_DOC AS INT) = DOC_ID AND F2_SERIE = CAST(DOC_SERIE AS VARCHAR) AND DATE_NFE = F2_EMISSAO "
    _cQry += " 				INNER JOIN SPED050 SPED WITH (NOLOCK) ON CAST(F2_DOC AS INT) = DOC_ID AND F2_SERIE = CAST(DOC_SERIE AS VARCHAR)  "
    _cQry += " 				INNER JOIN SF3010 SF3 WITH (NOLOCK) ON F3_FILIAL = F2_FILIAL AND F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F3_CLIEFOR = F2_CLIENTE AND F3_LOJA = F2_LOJA AND F3_EMISSAO = F2_EMISSAO AND F3_ESPECIE = F2_ESPECIE AND SUBSTRING(F3_CFO,1,1) >= '5' "
    _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*' AND SPED.D_E_L_E_T_ <> '*'  "
    _cQry += "       AND F3_CODRSEF = '100' " // IATAN EM 11/04/2024
    _cQry += "       AND F2_XSTATUS <> STATUS AND F2_FILIAL <> '0101'  AND F2_EMISSAO >= '" + DTOS(dDataBase-xDiasPDF) + "'"

    _cQry += "     UNION ALL "

    _cQry += "  SELECT DISTINCT '' AS C5_NUM, STATUS, F1_XSTATUS, F1_FILIAL, SF1.R_E_C_N_O_ , F1_XSTATUS, F1_CHVNFE, F1_DOC, F1_SERIE, 0 AS SF3_RECNO, F1_EST   "
//IATAN EM 16/05/2023
//    _cQry += "  FROM SF1010 SF1 WITH (NOLOCK) INNER JOIN SPED050 SPED WITH (NOLOCK) ON SPED.D_E_L_E_T_ <> '*' AND DOC_CHV = F1_CHVNFE AND DATE_NFE = F1_EMISSAO   "
    _cQry += "  FROM SF1010 SF1 WITH (NOLOCK) INNER JOIN SPED050 SPED WITH (NOLOCK) ON SPED.D_E_L_E_T_ <> '*' AND DOC_CHV = F1_CHVNFE AND F1_CHVNFE <> '' "
    _cQry += "  WHERE SF1.D_E_L_E_T_ <> '*' AND STATUS = '6' "
    _cQry += "        AND F1_EMISSAO >= '" + DTOS(dDataBase-xDiasPDF) + "'  AND F1_XSTATUS <> STATUS AND ( F1_TIPO = 'B' OR F1_EST = 'EX' ) "

    //iatan em 22/04/2024 - foi necessário pois a série NSM não é transmitida para a Sefaz
    _cQry += "   UNION ALL "
    _cQry += "   SELECT DISTINCT C5_NUM, '6' AS STATUS, F2_XSTATUS, F2_FILIAL, SF2.R_E_C_N_O_ , F2_XSTATUS, F2_CHVNFE, F2_DOC, F2_SERIE, SF3.R_E_C_N_O_ AS SF3_RECNO, F2_EST AS F1_EST  "
    _cQry += "   FROM SF2010 SF2 WITH (NOLOCK) INNER JOIN SD2010 SD2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE   "
    _cQry += "                                            AND F2_LOJA = D2_LOJA  AND (F2_ESPECIE = 'SPED' OR F2_SERIE = 'NSM' ) AND F2_EMISSAO >= '20220822' AND ( F2_CHVNFE <> '' OR F2_SERIE = 'NSM' )  "
    _cQry += " 				  INNER JOIN SC5010 SC5 WITH (NOLOCK) ON C5_FILIAL = D2_FILIAL AND C5_CLIENTE = D2_CLIENTE AND C5_LOJACLI = D2_LOJA AND C5_NUM = D2_PEDIDO  "
    _cQry += "                   INNER JOIN SF3010 SF3 WITH (NOLOCK) ON F3_FILIAL = F2_FILIAL AND F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F3_CLIEFOR = F2_CLIENTE AND F3_LOJA = F2_LOJA AND F3_EMISSAO = F2_EMISSAO AND F3_ESPECIE = F2_ESPECIE AND ( SUBSTRING(F3_CFO,1,1) >= '5'  OR F2_SERIE = 'NSM' ) "
    _cQry += "   WHERE SF2.D_E_L_E_T_ <> '*' AND SF3.D_E_L_E_T_ <> '*' AND F2_SERIE = 'NSM' AND F2_FILIAL <> '0101' AND F2_XSTATUS = '' AND F2_EMISSAO >= '" + DTOS(dDataBase-xDiasPDF) + "'"

    _cQry += "  ORDER BY C5_NUM "

    //IATAN EM 11/10/2022 - CHANGEQUERY NÃO FUNCIONA COM WITH (NOLOCK)
    //_cQry := ChangeQuery(_cQry) 
        dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SF2X",.T.,.T. )
    
    While (_SF2X->(!EOF()))


        CFILANT := _SF2X->F2_FILIAL

        IF EMPTY(ALLTRIM(_SF2X->C5_NUM))

            SF1->(DBGOTO( _SF2X->R_E_C_N_O_ ))
            RECLOCK("SF1", .F.)
                SF1->F1_XSTATUS := cValToChar(_SF2X->STATUS)
            SF1->(MsUnlock())

            IF ALLTRIM(_SF2X->F1_EST) == 'EX'

                u_wGerDanfe(_SF2X->F2_CHVNFE, _SF2X->F2_DOC, _SF2X->F2_SERIE, "\pdf_wms\", '', 1)
                aAnexoBol   := {}
                aAnexoDanfe := {}

                IF FILE("\pdf_wms\"+"pdf\"+_SF2X->F2_CHVNFE+".pdf")
                    aAdd(aAnexoDanfe, "\pdf_wms\pdf\"+_SF2X->F2_CHVNFE+".pdf") 
                ENDIF
                IF FILE("\pdf_wms\"+"xml\"+_SF2X->F2_CHVNFE+".xml")
                    aAdd(aAnexoDanfe, "\pdf_wms\xml\"+_SF2X->F2_CHVNFE+".xml") 
                ENDIF

                //IATAN EM 07/02/2023
                IF LEN(aAnexoDanfe) > 0
                    _cHTML := ''
                    _cHTML += ' <table> '
	                _cHTML += ' <tbody> '
		            _cHTML += ' <tr> '
			        _cHTML += '     <td colspan="2"> '
			        _cHTML += '      <p>Esta mensagem refere-se a Nota Fiscal Eletr&ocirc;nica Nacional de serie/n&uacute;mero [' + _SF2X->F2_SERIE + '/' + _SF2X->F2_DOC + '] emitida para:</p> '
			        _cHTML += '      </td> '
		            _cHTML += ' </tr> '
		            _cHTML += ' <tr> '
			        _cHTML += ' <td>Raz&atilde;o Social:</td> '
			        _cHTML += ' <td> '

                    SF1->( DBGOTO( _SF2X->R_E_C_N_O_ ) )
                    POSICIONE("SA2", 1, XFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA, "A2_NOME" )

			        _cHTML += ' <p>[ ' + ALLTRIM(SA2->A2_NOME) + ' ]</p> '
			        _cHTML += ' </td> '
		            _cHTML += ' </tr> '
		            _cHTML += ' <tr> '
			        _cHTML += '     <td colspan="2">Para verificar a autoriza&ccedil;&atilde;o da SEFAZ referente &agrave; nota acima mencionada, acesse o sitio <a href="https://nam10.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.nfe.fazenda.gov.br%2Fportal&amp;data=05%7C01%7Cdaniele.ribeiro%40mahospitalar.com.br%7C5c5cff23660e44d3da2208da9691832c%7C7eb3d2bcb8144120a0d3f9b672f01baa%7C0%7C0%7C637987851964911720%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&amp;sdata=uOhtYKNzs9ettdiZzpBDCv%2Bw8LGgL5fnnn0Wy2oe1CA%3D&amp;reserved=0" rel="noreferrer noopener" target="_blank" title="https://nam10.safelinks.protection.outlook.com/?url=http%3a%2f%2fwww.nfe.fazenda.gov.br%2fportal&amp;data=05%7c01%7cdaniele.ribeiro%40mahospitalar.com.br%7c5c5cff23660e44d3da2208da9691832c%7c7eb3d2bcb8144120a0d3f9b672f01baa%7c0%7c0%7c637987851964911720%7cunknown%7ctwfpbgzsb3d8eyjwijoimc4wljawmdailcjqijoiv2lumziilcjbtii6ik1hawwilcjxvci6mn0%3d%7c3000%7c%7c%7c&amp;sdata=uohtyknzs9ettdizzpbdcv%2bw8lggl5fnnn0wy2oe1ca%3d&amp;reserved=0"> http://www.nfe.fazenda.gov.br/portal</a></td> '
		            _cHTML += ' </tr> '
		            _cHTML += ' <tr> '
			        _cHTML += '     <td>Chave de acesso:&nbsp;<br /> '
			        //_cHTML += '     Protocolo:</td> '
			        _cHTML += '     <td> '
			        _cHTML += '     <p>[NFe' + _SF2X->F2_CHVNFE + ']<br /> '
			        //_cHTML += '     [342220190268335]</p> '
			        _cHTML += '     </td> '
		            _cHTML += ' </tr> '
		            _cHTML += ' <tr> '
			        _cHTML += ' <td colspan="2">Este e-mail foi enviado automaticamente pelo&nbsp;Sistema de Nota Fiscal Eletr&ocirc;nica (NF-e) da&nbsp;MONTEIRO ANTUNES INSUMOS HOSPITALARES SOCIEDADE ANONIMA</td> '
		            _cHTML += ' </tr> '
		            _cHTML += ' <tr> '
			        _cHTML += ' <td colspan="2"> '
			        _cHTML += ' <p><em><u>powered by TotvsServices - Totvs S/A</u></em></p> '
			        _cHTML += ' </td> '
		            _cHTML += ' </tr> '
	                _cHTML += ' </tbody> '
                    _cHTML += ' </table> '

                    zEnvMail( 'importacao-ma@mahospitalar.com.br, iatan.santos@dwtti.com.br', 'Workflow Importação', _cHtml, aAnexoDanfe, .F., .T.)

                ENDIF

            ELSE
                CONOUT("CHAMANDO MAPWMS16 - NF " + SF1->F1_DOC)
                IF ALLTRIM(SF1->F1_SERIE) == 'IMB' // NOTA DE ENTRADA DE ATIVO - ESTA É A PRIMEIRA NOTA. A NOTA DE GERAÇÃO DO ATIVO
                    INTEGRA_ATIVO(_SF2X->F2_FILIAL, _SF2X->F2_DOC, _SF2X->F2_SERIE)
                ELSEIF retornoAtivo(_SF2X->F2_FILIAL, _SF2X->F2_DOC, _SF2X->F2_SERIE)
                    // TRATAMENTOS REALIZADOS DENTRO DO FONTE ACIMA DE retornoAtivo()
                ELSE
                    //INTEGRAR AS NOTAS DE ENTRADA NORMAIS
                    U_MAPWMS16( _SF2X->R_E_C_N_O_ )
                ENDIF
            ENDIF

        ELSE
            //POSICIONO NA SC5 PORQUE O MAPWMS11 ESPERA QUE A SC5 ESTEJA POSICIONADA
            DbSelectArea("SC5")
            SC5->(DbSetOrder(1))
            SC5->(DbSeek(_SF2X->F2_FILIAL + _SF2X->C5_NUM))

            SF2->(DBGOTO( _SF2X->R_E_C_N_O_ ))

            IF SF2->F2_XSTATUS <> cValToChar(_SF2X->STATUS)


                //U_MAPWMS07( SC5->( Recno() ) )

                RECLOCK("SC5", .F.)
                    SC5->C5_XWMS := 'S'
                SC5->(MsUnlock())

                CONOUT("MANDANDO PEDIDO PARA WMS.: " + _SF2X->F2_FILIAL + _SF2X->C5_NUM)

                resposta := U_MAPWMS11( _SF2X->R_E_C_N_O_ )
                VARINFO("RESPOSTA.:::", resposta)
                IF LEN(resposta) >= 2
                    // "Nenhuma carga do pedido" incluída em 21/07/2022 pois segundo Gabriel este status é válido
                    IF resposta[1] == .T. .OR. "Nenhuma carga do pedido" $ resposta[2]  .OR. "não foi localizado no WMS ou já possuí NFe associada" $ resposta[2]  

                        SF2->(DBGOTO( _SF2X->R_E_C_N_O_ ))
                        RECLOCK("SF2", .F.)
                            SF2->F2_XSTATUS := cValToChar(_SF2X->STATUS)
                        SF2->(MsUnlock())

                        SF2->(DBGOTO( _SF2X->R_E_C_N_O_ ))
                        SF3->(DBGOTO( _SF2X->SF3_RECNO ))
                        //IATAN EM 08/10/2022 - MUDARAM O CAMINHO DA GERAÇÃO DO PDF AO MUDAR O SERVIDOR PARA CLOUD
                        IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".pdf") .OR. FILE("\pdf_wms\"+"xml\"+SF2->F2_CHVNFE+".xml")
                            CONOUT("******CHAVE JA EXISTE*****-->"+SF2->F2_CHVNFE)
                        ELSE
                            u_wGerDanfe(_SF2X->F2_CHVNFE, _SF2X->F2_DOC, _SF2X->F2_SERIE, "\pdf_wms\", '', 2)

                            //IATAN EM 12/10/2022 - CÓPIA DOS ARQUIVOS VAI OCORRER VIA SCRIPT AGENDADO A CADA 5 SEG
                            //IATAN EM 18/02/2023 - COPIA NÃO É MAIS NECESSÁRIA APÓS MIGRAR O WMS PARA NUVEM
                            /*
                            CONOUT(" ... COPIANDO ARQUIVOS PARA PASTA REMOTA ... ")

                            IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".rel")
                                CONOUT(" ... ESPERANDO 2 SEGUNDOS PARA CONVERTER PDF ... ")
                                //SLEEP(2000) // PAUSA DE 2 SEGUNDOS
                            ENDIF
                            IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".pdf")
                                WAITRUNSRV( "XCOPY D:\Totvs\Protheus_data\pdf_wms\pdf\"+SF2->F2_CHVNFE+".pdf \\192.168.11.61\arquivos\PUBLICO\PDF_NFS\pdf", .F., "c:\temp" )    
                            ENDIF

                            IF FILE("\pdf_wms\"+"boleto\"+SF2->F2_CHVNFE+".rel")
                                CONOUT(" ... ESPERANDO 2 SEGUNDOS PARA CONVERTER BOLETO ... ")
                                //SLEEP(2000) // PAUSA DE 2 SEGUNDOS
                            ENDIF
                            IF FILE("\pdf_wms\"+"boleto\"+SF2->F2_CHVNFE+".pdf")
                                WAITRUNSRV( "XCOPY D:\Totvs\Protheus_data\pdf_wms\boleto\"+SF2->F2_CHVNFE+".pdf \\192.168.11.61\arquivos\PUBLICO\PDF_NFS\boleto", .F., "c:\temp" )    
                            ENDIF
                            CONOUT(" ... TERMINO COPIA ARQUIVOS PARA PASTA REMOTA ... ")
                            */
                            //Iatan em 30/10/2022 - Incluir o envio de email para os pedidos faturados via wms
                            //eNFeOPME(SF2->F2_DOC,SF2->F2_SERIE,_SF2->C5_NUM,"????",'opme@mahospitalar.com.br',SF2->F2_CLIENTE,SF2->F2_LOJA,NIL,cPvFil,cPv)

                            //IATAN EM 07/02/2023
                            aAnexoBol   := {}
                            aAnexoDanfe := {}

                            //IATAN EM 24/01/2023
                            IF FILE("\pdf_wms\"+"pdf\"+SF2->F2_CHVNFE+".pdf")
                                aAdd(aAnexoDanfe, "\pdf_wms\pdf\"+SF2->F2_CHVNFE+".pdf") 
                            ENDIF
                            IF FILE("\pdf_wms\"+"boleto\"+SF2->F2_CHVNFE+".pdf")
                                aAdd(aAnexoBol, "\pdf_wms\boleto\"+SF2->F2_CHVNFE+".pdf") 
                            ENDIF
                            IF FILE("\pdf_wms\"+"xml\"+SF2->F2_CHVNFE+".xml")
                                aAdd(aAnexoDanfe, "\pdf_wms\xml\"+SF2->F2_CHVNFE+".xml") 
                            ENDIF

                            //IATAN EM 07/02/2023
                            IF LEN(aAnexoDanfe) > 0
                                envEmail(aAnexoDanfe, SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE)
                            ENDIF


                        ENDIF


                    ELSE 
                        CONOUT("******ERRO MAPWMS11*****-->"+resposta[2])
                    ENDIF
                ENDIF
            ENDIF
        ENDIF

                //IATAN EM 11/01/2024 - INTEGRAR A NOTA DE ENTRADA NÃO FISCAL DO ATIVO VINCULADA Á NOTA 
        //CONOUT("INTEGRA_ATIVO")
        //INTEGRA_ATIVO(_SF2X->F2_FILIAL, _SF2X->F2_DOC, _SF2X->F2_SERIE)

        _SF2X->(DbSkip())

    End
    _SF2X->(DBCloseArea())


RESET ENVIRONMENT 

RETURN



/*
    Iatan em 24/01/2023 - Enviar email com danfe e boleto
*/
Static Function envEmail(aAnexo, filial, documento, serie)

    Local cEmail  := ''
    Local cTipo   := ''
    Local cEmaSol := ''
    Local cQueryZ := ''


    cQueryZ:=""   
    cQueryZ+=" select D2_PEDIDO, "
    cQueryZ+=" D2_FILIAL, "
    cQueryZ+=" D2_TES, "
    cQueryZ+=" D2_EMISSAO, "
    cQueryZ+=" D2_GRUPO, "
    cQueryZ+=" C5_NUM, "
    cQueryZ+=" C5_FILIAL, "
    cQueryZ+=" C5_VEND1,  "
    cQueryZ+=" A3_EMAIL, "
    cQueryZ+=" C5_ZCLIRET, "
    cQueryZ+=" C5_ZLOJRET, "
    cQueryZ+=" SA1.A1_COD,  "
    cQueryZ+=" SA1.A1_LOJA,  "
    cQueryZ+=" SA1.A1_EMAIL,  "
    cQueryZ+=" SA1.A1_ZEMAOPM  "	   
    cQueryZ+=" from SD2010 SD2 " 
    cQueryZ+=" Inner Join SC5010 SC5 ON ( SD2.D2_PEDIDO=SC5.C5_NUM AND SD2.D2_FILIAL=SC5.C5_FILIAL) "
    cQueryZ+=" Inner Join SA3010 SA3 ON ( SC5.C5_VEND1=SA3.A3_COD) "
    cQueryZ+=" Inner Join SA1010 SA1 ON ( SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA ) "
    cQueryZ+=" WHERE       "
    cQueryZ+=" SD2.D_E_L_E_T_<>'*' "
    cQueryZ+=" AND  SC5.D_E_L_E_T_<>'*' "
    cQueryZ+=" AND  SC5.D_E_L_E_T_<>'*' "
    cQueryZ+=" AND  SD2.D2_FILIAL='" + filial  + "'"
    cQueryZ+=" AND  SD2.D2_DOC='" + documento  + "'"
    cQueryZ+=" AND  SD2.D2_SERIE='" +  serie  + "'"
    cQueryZ := ChangeQuery(cQueryZ)			
        
    dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
    dbSelectArea(cArea)

    cTipo:=''
    cEmaSol:=''

    IF (cArea)->D2_TES $ AllTrim(GETMV("ES_TESOPME"))
        cTipo:='remessa'
    else
        cTipo:='faturamento'
    Endif

    IF  cRetNat((cArea)->C5_NUM,(cArea)->C5_FILIAL) $ '111102/111214'
        
        cEnv:='O'                                    // envia para opme@mahospitalar.com.br - no zGerDanfe
        cEmaSol:=cEcliRet( (cArea)->C5_ZCLIRET,(cArea)->C5_ZLOJRET)
        cEmail := (cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol
        //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM) 

    Elseif cRetNat((cArea)->C5_NUM,(cArea)->C5_FILIAL) $ '111101'

        If  AllTrim((cArea)->D2_GRUPO) $ '2810,2820,2830,2840,2850,2860,2870,2250'
        
            cEnv:='O'                                    // envia para opme@mahospitalar.com.br - no zGerDanfe
            cEmaSol:=cEcliRet( (cArea)->C5_ZCLIRET,(cArea)->C5_ZLOJRET)
            cEmail := (cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol
            //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM) 
        else
            cEnv:=''                                    // não envia mensagem consignado
            cEmail := (cArea)->A1_EMAIL
            //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_EMAIL,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM) 
        Endif
        
    Elseif cRetNat((cArea)->C5_NUM,(cArea)->C5_FILIAL) == '811101' 

        cTipo   := 'remessa'                         // essa natureza Ã© sÃ³ remessa independente das TES
        If  AllTrim((cArea)->D2_GRUPO) $ '2810,2820,2830,2840,2850,2860,2870,2250'

            cEnv:='O'                                    // envia para opme@mahospitalar.com.br - no zGerDanfe
            cEmaSol:=cEcliRet( (cArea)->C5_ZCLIRET,(cArea)->C5_ZLOJRET)
            cEmail := (cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol
            //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM) 

        Else
            IF (cArea)->D2_TES $ AllTrim(GETMV("ES_TESOPME"))
                
                cEnv:='S'                                    // NAO envia para opme@mahospitalar.com.br - no zGerDanfe
                cEmail := (cArea)->A1_EMAIL
                //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo, (cArea)->A1_EMAIL ,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM)    

            else
                cEnv:=''                                    // não envia mensagem consignado
                cEmail := (cArea)->A1_EMAIL
                //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_EMAIL,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM) 
            Endif

        Endif

    ElseIf AllTrim((cArea)->D2_GRUPO) $ '2810,2820,2830,2840,2850,2860,2870,2250'

            cEnv:='O'                                    // envia para opme@mahospitalar.com.br - no zGerDanfe
            cEmaSol:=cEcliRet( (cArea)->C5_ZCLIRET,(cArea)->C5_ZLOJRET)
            cEmail := (cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol
            //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_ZEMAOPM +';'+(cArea)->A3_EMAIL+';'+cEmaSol,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM) 

    ElseIf (cArea)->D2_TES $ AllTrim(GETMV("ES_TESOPME"))
                
            cEnv:='S'                                    // NAO envia para opme@mahospitalar.com.br - no zGerDanfe
            cEmail :=  (cArea)->A1_EMAIL
            //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo, (cArea)->A1_EMAIL ,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM)    
    Else
            cEnv:=''                                    // não envia mensagem consignado
            cEmail := (cArea)->A1_EMAIL
            //u_zGerDanfe(cNota,cSerie,cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_EMAIL,(cArea)->A1_COD,(cArea)->A1_LOJA,cEnv,(cArea)->C5_FILIAL,(cArea)->C5_NUM) 

    EndIf


    If cEnv='S' .or. cEnv='O'

        IF  cEnv == 'O'
            eNFeOPME( SF2->F2_DOC, SF2->F2_SERIE, (cArea)->C5_NUM, cTipo, 'opme@mahospitalar.com.br;'+cEmail, SF2->F2_CLIENTE, SF2->F2_LOJA, aAnexo, SF2->F2_FILIAL, (cArea)->C5_NUM)
        Else
            eNFeOPME( SF2->F2_DOC, SF2->F2_SERIE, (cArea)->C5_NUM, cTipo, cEmail, SF2->F2_CLIENTE, SF2->F2_LOJA, aAnexo, SF2->F2_FILIAL, (cArea)->C5_NUM)
        Endif
    endif 


    (cArea)->( dbCloseArea() )



Return



static  Function  eNFeOPME(cNota,cSerie,cPedido,cTipo,cEmail,cCliente,cLoja,aAnexo,cPvFilial,cPvend)

Local _cHTML    := ""
_cHTML:=' <html> '
_cHTML+=' <head>
_cHTML+=' <meta charset="windows-1252"> '
_cHTML+=' <meta charset="UTF-8"> '
_cHTML+=' <style> '
_cHTML+=' body{ '
_cHTML+=' width:  			700px; '
_cHTML+="		font:			normal normal normal 14px 'open sans', sans-serif; "
_cHTML+='	} '
_cHTML+='	h1 { '
_cHTML+="		font: 			normal normal normal 22px 'open sans', sans-serif; "
_cHTML+='		color: 			rgb(0, 136, 203); '
_cHTML+='		padding-top: 	3px; '
_cHTML+='		padding-bottom:	3px; '
_cHTML+='	}'

_cHTML+='	h2 {'
_cHTML+="		font: 			normal normal normal 14px 'open sans', sans-serif;"
_cHTML+='	}'

_cHTML+='	table{ "
_cHTML+="		font:			normal normal normal 14px 'open sans', sans-serif;'
_cHTML+='		text-align: 	left '
_cHTML+='		border-width: 	0px; '

_cHTML+='	}'

_cHTML+='	thead{'
_cHTML+="		font:			normal normal normal 14px 'open sans', sans-serif; "
_cHTML+='		background:		Gray;  '
_cHTML+='		color:			White; '
_cHTML+='		text-align: 	left;  '
_cHTML+='		border-width: 	0px;   '
_cHTML+='	}'

_cHTML+='	.grid{ '
_cHTML+='		border-top: 	solid rgb(0, 136, 203) 2px; '
_cHTML+='		padding-top:	10px; '
_cHTML+='		padding-bottom:	5px;  '
_cHTML+='		margin-top:		10px; '
_cHTML+='	} '
_cHTML+='      </style> '
_cHTML+=' </head>  '

_cHTML+=' <body> '
_cHTML+=' <div styele='+'"width:700px;font:normal normal normal 14px '+"'open sans', sans-serif;"+'">'
_cHTML+=' <h1 style='+'"font:normal normal normal 22px'+" 'open sans', sans-serif; color:rgb(0,136,203);padding-top: 	3px;padding-bottom:	3px;"+'">'
_cHTML+=' Nota Fiscal '
_cHTML+=' </h1> '

_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(54,54,54);"+'">'+"Ol&aacute;!</h2>"
_cHTML+=' <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(79,79,79);"+'">'+"Segue em anexo a NF de " +AllTrim(cTipo)+" de consignado! </h2>"
_cHTML+=' <!-- Cabeçalho do Titulos --> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0,136,203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+=' 		<td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0,136,203);"+'">'+"Documento - Serie</h2> </td>"	
_cHTML+='	</tr> '
_cHTML+='	<tr> '
_cHTML+='       <td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(79,79,79);"+'">'+AllTrim(cNota)+' - '+AllTrim(cSerie)+" </h2> </td>"
_cHTML+='	</tr> '
_cHTML+='	</table> '
_cHTML+=' <div class="grid" style="border-top:solid rgb(0,136,203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' </div> '
_cHTML+=' <table style='+'"width:450px;font:normal normal normal 14px '+"'open sans', sans-serif;text-align:leftborder-width:0px;"+'">'
_cHTML+='	<tr> '
_cHTML+=' 		<td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(0,136,203);"+'">'+"Dados adicionais</h2> </td>"	
_cHTML+='	</tr> '
_cHTML+='	<tr> '
_cHTML+='  <td> <h2 style='+'"font:normal normal normal 16px '+"'open sans', sans-serif; color:rgb(79,79,79);"+'">'+U_cInfOPME(cPvFilial,cPvend)+" </h2> </td>"
_cHTML+='	</tr> '
_cHTML+='	</table> ' 
_cHTML+=' <div class="grid" style="border-top:solid rgb(0,136,203) 2px; padding-top:10px;padding-bottom:5px;margin-top:10px;"> '
_cHTML+=' </div> '
_cHTML+='   </body>'
_cHTML+='   </html>'
//memowrite("C:\relato\EmailClienteOPME.html",_cHTML)


//zEnvMail('ednei.silva@mahospitalar.com.br;barbara.monardes@mahospitalar.com.br', 'Workflow OPME', _cHTML, {}, .F., .T.)
//zEnvMail(cEmail, 'Workflow OPME', _cHTML, aAnexo, .F., .T.)
zEnvMail( cEmail, 'Workflow OPME', _cHTML, aAnexo, .F., .T.)
Return

static Function zEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := Nil
    Local oSrv         := Nil
    Local nRet         := 0
    Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
    Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
    Local cPass        := Alltrim(GetMV("MV_RELPSW"))
    Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
    Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
    Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
    Local nTimeOut     := GetMV("MV_RELTIME")
    Local cLog         := ""
    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .F.
    Default lUsaTLS    := .F.
 
    //Se tiver em branco o destinatário, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
 
    If lRet
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
 
        //Define os atributos da mensagem
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo
 
        //Percorre os anexos
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo existir
            If File(aAnexos[nAtual])
 
                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
                EndIf
 
            //Senao, acrescenta no log
            Else
                cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
            EndIf
        Next
 
        //Cria servidor para disparo do e-Mail
        oSrv := tMailManager():New()
 
        //Define se irá utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
 
        //Inicializa conexão
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
 
        If lRet
            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            If nRet != 0
                cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
            EndIf
 
            //Conecta no servidor
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
 
            If lRet
                //Realiza a autenticação do usuário e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
 
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
 
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
 
    //Se tiver log de avisos/erros
    If !Empty(cLog)
        cLog := "zEnvMail - "+dToC(Date())+ " " + Time() + CRLF + ;
            "Funcao - " + FunName() + CRLF + CRLF +;
            "Existem mensagens de aviso: "+ CRLF +;
            cLog
        ConOut(cLog)
 
        //Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
        If lMostraLog .And. ! IsBlind()
            Aviso("Log", cLog, {"Ok"}, 2)
        EndIf
    EndIf
 
    RestArea(aArea)
Return lRet


Static Function cRetNat( cPedido,cFilPed)
Local cNatRet    := ""
Local cAliasTMP3 := 'TMP3'

BeginSql Alias cAliasTMP3
	SELECT C5_NATUREZ 
	FROM %Table:SC5% SC5 
	WHERE C5_FILIAL = %Exp:cFilPed%
	  AND C5_NUM    = %Exp:cPedido%
	  AND SC5.%notdel%
EndSql

cNatRet  := AllTrim((cAliasTMP3)->C5_NATUREZ )

(cAliasTMP3)->( dbCloseArea() )
Return( cNatRet )

// Email do cliente solicitante do retorno
Static Function cEcliRet( cCliente,cLoja)
Local cEmail     := ""
Local cAliasTMP4 := 'TMP4'

BeginSql Alias cAliasTMP4
	SELECT A1_ZEMAOPM 
	FROM %Table:SA1% SA1 
	WHERE A1_COD     = %Exp:cCliente%
	  AND A1_LOJA    = %Exp:cLoja%
	  AND SA1.%notdel%
EndSql

cEmail  := AllTrim((cAliasTMP4)->A1_ZEMAOPM)

(cAliasTMP4)->( dbCloseArea() )
Return( cEmail )



USER FUNCTION TSTX()

    Private BFILTRABRW := .F.

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" 

    xDiasPDF  := GETMV("MV_XDPDF")

    _cQry := " SELECT * "
    _cQry += " FROM SF2010 SF2 WITH (NOLOCK) LEFT JOIN SPED050 SPED WITH (NOLOCK) ON CAST(F2_DOC AS INT) = DOC_ID AND F2_SERIE = CAST(DOC_SERIE AS VARCHAR)  "
    _cQry += "  WHERE SF2.D_E_L_E_T_ <> '*' "
    _cQry += " 	   AND F2_FILIAL = '0101' AND F2_EMISSAO >= '" + DTOS(dDataBase-xDiasPDF) + "'"
    _cQry += " 	   AND F2_ESPECIE = 'SPED' AND F2_CHVNFE = '' AND F2_SERIE = '6  ' "



    dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SFXX",.T.,.T. )
    
    While (_SFXX->(!EOF()))


        CFILANT := _SFXX->F2_FILIAL

        //validaAutoNfe( "1", "01", cFilAnt, "6  ", nil, 1 )
        SpedNFeTrf("SF2", _SFXX->F2_SERIE, _SFXX->F2_DOC, _SFXX->F2_DOC, "000001", "1", "1",nil,nil,nil,nil,nil,nil)

        _SFXX->(DbSkip())

    End
    _SFXX->(DBCloseArea())


    RESET ENVIRONMENT

RETURN 

Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "AUTONFE   ",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam




Static Function INTEGRA_ATIVO(filial, nota, serie)

	Local aLinha    := {}  
    Local _aPreNF := {}
	Local cNum := ''
    Local encontrou := .F.
    Local lojaFor   := "00"+RIGHT( CFILANT, 2)

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

  _cQry := " SELECT *  "
  _cQry += " FROM SF1010 SF1 INNER JOIN SD1010 SD1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA "
  _cQry += " WHERE SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "
  _cQry += "        AND F1_FILIAL = '" + filial + "' "
  _cQry += "        AND F1_XSTATUS = '' "
  _cQry += "        AND F1_SERIE = 'IMB' "
  _cQry += "        AND F1_FORNECE = '000052' "
  _cQry += "        AND F1_XNUMAT = '" + nota + "' "
  _cQry += "        AND F1_XSERAT = '" + serie + "' "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_IMB",.T.,.T. )
  
	aCabec := {}
	aItens := {}
	
	While (_IMB->(!EOF()))

        encontrou := .T.

        POSICIONE("SB1", 1, XFILIAL("SB1")+_IMB->D1_COD, "B1_DESC")
        POSICIONE("SA2", 1, XFILIAL("SA2")+"000052"+"0001", "A2_NOME")

      	// PARA INTEGRAÇÃO COM WMS
        _sNomeGrupo := Alltrim(Posicione("SBM", 1, xFilial("SBM")+SB1->B1_GRUPO, "BM_DESC"))
        _sNomeSecao := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"02"+SB1->B1_TIPO, "X5_DESCRI"))
        _sNomeLinha := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"ZX"+SB1->B1_MARCA, "X5_DESCRI"))

        _aItens := {{"CODITEM",SB1->B1_COD},;
                    {"NOMEITEM",SB1->B1_DESC},;
                    {"TIPO","F"},;
                    {"CODBAR",SB1->B1_CODBAR},;
                    {"CODGRP",SB1->B1_GRUPO},;
                    {"NOMEGRP",_sNomeGrupo},;
                    {"UM",SB1->B1_UM},;
                    {"ULTCOMPRA", SB1->B1_UPRC},;
                    {"NCM",SB1->B1_POSIPI},;
                    {"ATIVO",IIF(SB1->B1_MSBLQL <> '1',.T.,.F.)},;                            
                    {"CODSEC",SB1->B1_TIPO},;
                    {"NOMESEC",_sNomeSecao},;
                    {"CODLN",SB1->B1_MARCA},;
                    {"RMS",SB1->B1_NRANVIS},;
                    {"CARDNAMEFAB",SB1->B1_FABRIC},;
                    {"CARDCODADD",SB1->B1_ENDFABR},;
                    {"NOMELN",_sNomeLinha},;
                    {"IMOBILIZADO",.T.};
                    }

        retorno := U_MAPWMS02(_aItens)

		//SALVA OS ITENS DE DOCUMENTO DE SAÍDA
        AADD(_aPreNF,{{"FILIAL", "01"+_IMB->D1_FILIAL},;
                    {"NUMDOC", _IMB->D1_DOC},;
                    {"SERIEDOC", "IMB"},;
                    {"EMISSAO" , STOD(_IMB->F1_EMISSAO)},;
                    {"NROITEM" , _IMB->D1_ITEM},;
                    {"CODITEM" , _IMB->D1_COD},;
                    {"DESCITEM", SB1->B1_DESC},;  
                    {"REFERENCIA", _IMB->D1_COD},; //Opcional
                    {"TAMANHO"   , ""},;   // Opcional
                    {"CODFORNEC" , "000052" + lojaFor},;
                    {"NOMEFORNEC", SA2->A2_NOME},;  
                    {"CODFABRIC" , ""},;  //Opcional  
                    {"NOMEFABRIC", ""},; //Opcional
                    {"QTDE"      , _IMB->D1_QUANT},;
                    {"DOCSTATUS" , "O"},;  // O: Aberto, C: Fechado 
                    {"TIPO"      , ""},;      //Opcional
                    {"DATAFABRIC", STOD(_IMB->D1_DFABRIC)},;      //Opcional
                    {"DATAVALID" , STOD(_IMB->D1_DTVALID)},;      //Opcional
                    {"LOTE"      , _IMB->D1_LOTECTL},;    //Opcional 
                    {"CARDCODESAIDA"  , getClienteOrigem(_IMB->D1_FILIAL, nota, serie)},;    //SOMENTE PARA ATIVO
                    {"SERIALSAIDA"    , nota},;    //SOMENTE PARA ATIVO
                    {"LINENUMSAIDA"   , _IMB->D1_ITEM},;    //SOMENTE PARA ATIVO
                    {"PEDIDO"   , getPedido(_IMB->D1_FILIAL, nota, serie)},;    //SOMENTE PARA ATIVO
                    {"IMOBILIZADO", .T.};    //Opcional - SOLICITADO POR GABRIEL EM CALL DIA 23/11/2023
        })

		aadd(aItens,aLinha)  
		aLinha := {}

	    _IMB->(DbSkip())
	End
	_IMB->(DBCloseArea())
    
    IF encontrou == .T.
        CONOUT("CHAMOU MAPWMS05")
        U_MAPWMS05(_aPreNF)
    ENDIF

Return


Static Function getClienteOrigem(filial, nota, serie)

    Local retorno := ""

  _cQry := " SELECT *  "
  _cQry += " FROM SF2010 SF2  "
  _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' "
  _cQry += "        AND F2_FILIAL = '" + filial + "' "
  _cQry += "        AND F2_DOC = '" + nota + "'"
  _cQry += "        AND F2_SERIE = '" + serie + "' "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_CLI",.T.,.T. )
  
	
	While (_CLI->(!EOF()))

        retorno := _CLI->F2_CLIENTE+_CLI->F2_LOJA

	    _CLI->(DbSkip())
	End
	_CLI->(DBCloseArea())

Return retorno


Static Function getPedido(filial, nota, serie)

    Local retorno := ""

  _cQry := " SELECT DISTINCT D2_PEDIDO  "
  _cQry += " FROM SD2010 SD2  "
  _cQry += " WHERE SD2.D_E_L_E_T_ <> '*' "
  _cQry += "        AND D2_FILIAL = '" + filial + "' "
  _cQry += "        AND D2_DOC = '" + nota + "'"
  _cQry += "        AND D2_SERIE = '" + serie + "' "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_CLI",.T.,.T. )
  
	
	While (_CLI->(!EOF()))

        retorno := _CLI->D2_PEDIDO

	    _CLI->(DbSkip())
	End
	_CLI->(DBCloseArea())

Return retorno




Static Function RETORNOATIVO(filial, nota, serie)

	Local aLinha    := {}  
    Local _aPreNF := {}
    Local encontrou := .F.
    Local lojaFor   := "00"+RIGHT( CFILANT, 2)

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

  _cQry := " SELECT *  "
  _cQry += " FROM SF1010 SF1 INNER JOIN SD1010 SD1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA "
  _cQry += " WHERE SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "
  _cQry += "        AND F1_FILIAL = '" + filial + "' "
  _cQry += "        AND F1_DOC = '" + nota + "' "
  _cQry += "        AND F1_SERIE = '" + serie + "' "
  _cQry += "        AND D1_COD LIKE '%IMB' "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_IMB",.T.,.T. )
  
	aCabec := {}
	aItens := {}
	
	While (_IMB->(!EOF()))

        encontrou := .T.

        POSICIONE("SB1", 1, XFILIAL("SB1")+_IMB->D1_COD, "B1_DESC")
        POSICIONE("SA2", 1, XFILIAL("SA2")+"000052"+"0001", "A2_NOME")

      	// PARA INTEGRAÇÃO COM WMS
        _sNomeGrupo := Alltrim(Posicione("SBM", 1, xFilial("SBM")+SB1->B1_GRUPO, "BM_DESC"))
        _sNomeSecao := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"02"+SB1->B1_TIPO, "X5_DESCRI"))
        _sNomeLinha := Alltrim(Posicione("SX5", 1, xFilial("SX5")+"ZX"+SB1->B1_MARCA, "X5_DESCRI"))

        _aItens := {{"CODITEM",SB1->B1_COD},;
                    {"NOMEITEM",SB1->B1_DESC},;
                    {"TIPO","F"},;
                    {"CODBAR",SB1->B1_CODBAR},;
                    {"CODGRP",SB1->B1_GRUPO},;
                    {"NOMEGRP",_sNomeGrupo},;
                    {"UM",SB1->B1_UM},;
                    {"ULTCOMPRA", SB1->B1_UPRC},;
                    {"NCM",SB1->B1_POSIPI},;
                    {"ATIVO",IIF(SB1->B1_MSBLQL <> '1',.T.,.F.)},;                            
                    {"CODSEC",SB1->B1_TIPO},;
                    {"NOMESEC",_sNomeSecao},;
                    {"CODLN",SB1->B1_MARCA},;
                    {"RMS",SB1->B1_NRANVIS},;
                    {"CARDNAMEFAB",SB1->B1_FABRIC},;
                    {"CARDCODADD",SB1->B1_ENDFABR},;
                    {"NOMELN",_sNomeLinha},;
                    {"IMOBILIZADO",.T.};
                    }

        retorno := U_MAPWMS02(_aItens)

		//SALVA OS ITENS DE DOCUMENTO DE SAÍDA
        AADD(_aPreNF,{{"FILIAL", "01"+_IMB->D1_FILIAL},;
                    {"NUMDOC", _IMB->D1_DOC},;
                    {"SERIEDOC", _IMB->D1_SERIE},;
                    {"EMISSAO" , STOD(_IMB->F1_EMISSAO)},;
                    {"NROITEM" , _IMB->D1_ITEM},;
                    {"CODITEM" , _IMB->D1_COD},;
                    {"DESCITEM", SB1->B1_DESC},;  
                    {"REFERENCIA", _IMB->D1_COD},; //Opcional
                    {"TAMANHO"   , ""},;   // Opcional
                    {"CODFORNEC" , _IMB->D1_FORNECE+_IMB->D1_LOJA},;
                    {"NOMEFORNEC", POSICIONE("SA1", 1, XFILIAL("SA1")+_IMB->D1_FORNECE+_IMB->D1_LOJA, "A1_NOME")},;  
                    {"CODFABRIC" , ""},;  //Opcional  
                    {"NOMEFABRIC", ""},; //Opcional
                    {"QTDE"      , _IMB->D1_QUANT},;
                    {"DOCSTATUS" , "O"},;  // O: Aberto, C: Fechado 
                    {"TIPO"      , ""},;      //Opcional
                    {"DATAFABRIC", STOD(_IMB->D1_DFABRIC)},;      //Opcional
                    {"DATAVALID" , STOD(_IMB->D1_DTVALID)},;      //Opcional
                    {"LOTE"      , _IMB->D1_LOTECTL},;    //Opcional 
                    {"CARDCODESAIDA"  , _IMB->D1_FORNECE+_IMB->D1_LOJA},;    //SOMENTE PARA ATIVO
                    {"SERIALSAIDA"    , nota},;    //SOMENTE PARA ATIVO
                    {"LINENUMSAIDA"   , _IMB->D1_ITEM},;    //SOMENTE PARA ATIVO
                    {"PEDIDO"   , ""},;    //SOMENTE PARA ATIVO
                    {"IMOBILIZADO", .T.};    //Opcional - SOLICITADO POR GABRIEL EM CALL DIA 23/11/2023
        })

		aadd(aItens,aLinha)  
		aLinha := {}

	    _IMB->(DbSkip())
	End
	_IMB->(DBCloseArea())
    
    IF encontrou == .T.
        CONOUT("CHAMOU MAPWMS05")
        U_MAPWMS05(_aPreNF)
    ENDIF

Return encontrou
