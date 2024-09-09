#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

USER FUNCTION REST002

Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+'Divergencias_Digitacao.xls'

Local cQry

Local geracao := 'Geração.:' + dToC(date()) + Space(1) + Time()

Private cPerg := "REST002"

    PERGUNTE(CPERG,.T.)

    geracao := geracao 

 //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
    
    //Aba 01
    oFWMsExcel:AddworkSheet("DIGITACOES") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
        oFWMsExcel:AddTable("DIGITACOES",geracao)
        //Criando Colunas
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Cod Produto",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Descrição Produto",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Lote",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Tipo Produto",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Grupo Produto",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"UM Produto",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Armazem",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Documento",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Quantidade Inventariada ( SB7 )",1,2) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Quantidade na Data do Inventario ( SB8 )",1,2) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Diferença Quantidade",1,2) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Diferença Valor",1,3) //1 = Modo Texto
        oFWMsExcel:AddColumn("DIGITACOES",geracao,"Quantidade ( SB2 )",1,2) //1 = Modo Texto

    cQry:=" "

    cQry+="  SELECT B2_FILIAL, B1_COD, B2_LOCAL, B2_QATU, B8_SALDO, CASE WHEN B7_QUANT IS NULL THEN 0 ELSE B7_QUANT END AS B7_QUANT, "
    cQry+="         B8_LOTECTL, B8_DTVALID, B2_CM1, "
    cQry+="         B1_DESC, B1_TIPO, B1_UM, B1_GRUPO, B1_FABRIC, B1_ENDFABR, B7_DOC "
    cQry+="  FROM SB2010 SB2 INNER JOIN SB1010 SB1 ON B1_COD = B2_COD "
    cQry+="                  LEFT JOIN SB8010 SB8 ON SB8.D_E_L_E_T_ <> '*' AND B8_FILIAL = B2_FILIAL AND B8_PRODUTO = B2_COD AND B8_LOCAL = B2_LOCAL "
    cQry+="  				 LEFT JOIN SB7010 SB7 ON SB7.D_E_L_E_T_ <> '*' AND B7_FILIAL = B8_FILIAL AND B7_COD = B8_PRODUTO AND B7_LOCAL = B8_LOCAL AND B7_LOTECTL = B8_LOTECTL AND B7_DATA >= '" + DTOS(MV_PAR09) + "' AND B7_DATA <= '" + DTOS(MV_PAR10) + "' "
    cQry+="  WHERE SB2.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' 
    cQry += "      AND B1_COD >= '" + MV_PAR01 + "' AND B1_COD <= '" + MV_PAR02 + "' "
    cQry += "      AND B1_TIPO >= '" + MV_PAR03 + "' AND B1_TIPO <= '" + MV_PAR04 + "' "
    cQry += "      AND B2_LOCAL >= '" + MV_PAR05 + "' AND B2_LOCAL <= '" + MV_PAR06 + "' "
    cQry += "      AND B1_GRUPO >= '" + MV_PAR07 + "'AND B1_GRUPO <= '" + MV_PAR08 + "' "
    cQry += "      AND B2_COD IN ( SELECT DISTINCT B7_COD FROM SB7010 WHERE D_E_L_E_T_ <> '*' AND B7_DATA >= '" + DTOS(MV_PAR09) + "' AND B7_DATA <= '" + DTOS(MV_PAR10) + "' ) "
    //cQry += "      AND B2_QATU <> 0  "
    cQry+="  ORDER BY B2_FILIAL, B2_COD, B2_LOCAL, B8_LOTECTL "


	TCQuery cQry New Alias "QRY_DIG"
	
	QRY_DIG->(DbGoTop())
	While ! QRY_DIG->(Eof())


            oFWMsExcel:AddRow("DIGITACOES",geracao,{ ALLTRIM(QRY_DIG->B1_COD), ALLTRIM(QRY_DIG->B1_DESC), QRY_DIG->B8_LOTECTL, ;
                                                     QRY_DIG->B1_TIPO, QRY_DIG->B1_GRUPO, QRY_DIG->B1_UM, ;
                                                     QRY_DIG->B2_LOCAL, QRY_DIG->B7_DOC, QRY_DIG->B7_QUANT, ;
                                                     QRY_DIG->B8_SALDO, ;
                                                     (QRY_DIG->B7_QUANT - QRY_DIG->B8_SALDO), ;
                                                     ((QRY_DIG->B7_QUANT - QRY_DIG->B8_SALDO) * QRY_DIG->B2_CM1 ), ;
                                                     QRY_DIG->B2_QATU } )
		QRY_DIG->(DbSkip())
	EndDo



//Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas


Return

