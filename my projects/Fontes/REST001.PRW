#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
    Data.: 29/10/2022
    Autor.: Iatan Santos
    Solicitação.: Iatan - Relatório de apoio para o chamado #6240
*/


USER FUNCTION REST001

    MSGRUN("Gerando Relatório","Aguarde ... Gerando Relatorio",  {|| AREST01() } )

RETURN



STATIC FUNCTION AREST01

Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+'ESTOQUE04.xls'

Local geracao := 'Geração.:' + dToC(date()) + Space(1) + Time()

PERGUNTE("AREST01A", .T.)

 //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
    
    //Aba 01
    oFWMsExcel:AddworkSheet("ESTOQUE04") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
        oFWMsExcel:AddTable("ESTOQUE04",geracao)
        //Criando Colunas
        oFWMsExcel:AddColumn("ESTOQUE04",geracao,"Filial",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("ESTOQUE04",geracao,"Código",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("ESTOQUE04",geracao,"Descrição",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("ESTOQUE04",geracao,"Armazem",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("ESTOQUE04",geracao,"Qtd Atual (SB2)",1,2) //1 = Modo Texto
        oFWMsExcel:AddColumn("ESTOQUE04",geracao,"CM Atual (SB2)",1,3) //1 = Modo Texto
        oFWMsExcel:AddColumn("ESTOQUE04",geracao,"CM Últ. Fechamento (SB9)",1,3) //1 = Modo Texto

    cQry:=" "

    cQry+="   SELECT B2_FILIAL, B2_COD, B1_DESC, B2_LOCAL, B2_QATU, B2_CM1, "
    cQry+="          (  "
    cQry+="   	     SELECT B9_VINI1  "
    cQry+="   	     FROM SB9010  "
    cQry+="   		 WHERE D_E_L_E_T_ <> '*' AND B9_FILIAL = SB2.B2_FILIAL AND B9_COD = SB2.B2_COD AND B9_LOCAL = '04'  "
    cQry+="   	           AND B9_DATA = (  "
    cQry+="   								SELECT MAX(B9_DATA) FROM SB9010 WHERE D_E_L_E_T_ <> '*' AND B9_FILIAL = SB2.B2_FILIAL AND B9_COD = SB2.B2_COD AND B9_LOCAL = '04'  "
    cQry+="   			                 )  "
    cQry+="          ) AS CM_FECH "
    cQry+="   FROM SB2010 SB2 INNER JOIN SB1010 SB1 ON B1_COD = B2_COD "
    cQry+="   WHERE SB2.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' "
    cQry+="         AND B2_LOCAL >= '" + MV_PAR01 + "' AND B2_LOCAL <= '" + MV_PAR02 + "' "
    cQry+="   ORDER BY 1, 2   "

	TCQuery cQry New Alias "QRY_CM"

	QRY_CM->(DbGoTop())
	While ! QRY_CM->(Eof())

        oFWMsExcel:AddRow("ESTOQUE04",geracao,{ QRY_CM->B2_FILIAL, QRY_CM->B2_COD, ALLTRIM(QRY_CM->B1_DESC),;
                                                QRY_CM->B2_LOCAL, QRY_CM->B2_QATU, QRY_CM->B2_CM1,;
                                                QRY_CM->CM_FECH } )
		QRY_CM->(DbSkip())
	EndDo

	QRY_CM->(DbCloseArea())

//Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas


Return
