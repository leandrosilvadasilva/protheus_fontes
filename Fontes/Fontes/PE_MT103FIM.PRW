#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include 'Totvs.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MT100GE2    � Autor � Ednei Silva	    � Data �18/07/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta uma tela para Informar o Motivo da Devolucao         ���
���          � 									                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MAHOPITALAR / Faturamento                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
#define DS_MODALFRAME   128
User Function MT103FIM()

Local 	nLinha	  := 010
Local 	lEdita	  := .F.
Local 	oCodDev
Local 	oDescDev
Local 	aArea     := GetArea()
Local 	aAreaSE2  := SE2->(GetArea())
Local 	aAreaSD1  := SD1->(GetArea())
Local 	aAreaSF1  := SF1->(GetArea())
//PRIVATE nTIPO := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_TIPO' }))
//PRIVATE nDoc  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_DOC' }))
//PRIVATE nMot  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_ZMOTDEV' }))
//PRIVATE nDes  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_ZDESMOT' }))

Local aAreaSB1  := SB1->(GetArea()) // IATAN EM 27/02/2024
Local aAreaSA2  := SA2->(GetArea()) // IATAN EM 27/02/2024
Local aAreaSD2  := SD2->(GetArea()) // IATAN EM 27/02/2024
//IATAN EM 27/02/2024
Local _aPreNF := {}


Private cCodDev	  := SPACE(4)
Private cDesDev	  := SPACE(50)
Private oDlg01
Private lGrava	  := .F.


	//IDENTIFICAR SE EST� VINDO VIA INTEGRA��O WMS
	IF ISINCALLSTACK("U_DEVOLUCAO") .OR. ISINCALLSTACK("U_DEV2")
		RETURN
	ENDIF

	//IATAN EM 27/02/2024 - INTEGRA��O DA NOTA DE "RETORNO DE ATIVO PARA A MA"
	IF RIGHT(ALLTRIM(SD1->D1_COD), 3) == "IMB" .AND. inclui == .T.
		
		WHILE !SD1->( EOF() ) .AND. SD1->D1_FILIAL == SF1->F1_FILIAL .AND. SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. SD1->D1_EMISSAO == SF1->F1_EMISSAO .AND. SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA
			// FOR�A A INTEGRA��O DA NOTA DE ENTRADA PARA O WMS COM CARACTERISTICAS ESPECIAIS PARA O ATIVO
			POSICIONE("SB1", 1, XFILIAL("SB1")+SD1->D1_COD, "B1_COD")
			AADD(_aPreNF,{{"FILIAL", "01"+SD1->D1_FILIAL},;
						{"NUMDOC", SD1->D1_DOC},;
						{"SERIEDOC", SD1->D1_SERIE},;
						{"EMISSAO" , SF1->F1_EMISSAO},;
						{"NROITEM" , SD1->D1_ITEM},;
						{"CODITEM" , SD1->D1_COD},;
						{"DESCITEM", SB1->B1_DESC},;  
						{"REFERENCIA", SD1->D1_COD},; //Opcional
						{"TAMANHO"   , ""},;   // Opcional
						{"CODFORNEC" , SF1->F1_FORNECE+SF1->F1_LOJA},;
						{"NOMEFORNEC", SA2->A2_NOME},;  
						{"CODFABRIC" , ""},;  //Opcional  
						{"NOMEFABRIC", ""},; //Opcional
						{"QTDE"      , SD1->D1_QUANT},;
						{"DOCSTATUS" , "O"},;  // O: Aberto, C: Fechado 
						{"TIPO"      , ""},;      //Opcional
						{"DATAFABRIC", SD1->D1_DFABRIC},;      //Opcional
						{"DATAVALID" , SD1->D1_DTVALID},;      //Opcional
						{"LOTE"      , SD1->D1_LOTECTL},;    //Opcional 
						{"CARDCODESAIDA"  , SF1->F1_FORNECE+SF1->F1_LOJA},;    //SOMENTE PARA ATIVO
						{"SERIALSAIDA"    , SD1->D1_NFORI},;    //SOMENTE PARA ATIVO
						{"LINENUMSAIDA"   , SD1->D1_ITEMORI},;    //SOMENTE PARA ATIVO
						{"TIPONFE"   , 1},;    //SOMENTE PARA ATIVO
						{"IMOBILIZADO", .T.};    //Opcional - SOLICITADO POR GABRIEL EM CALL DIA 23/11/2023
			})	
		
			SD1->(DBSKIP())

		ENDDO
		//U_MAPWMS05(_aPreNF)
		//IATAN EM 23/04/2024
		retorno := U_MAPWMS05(_aPreNF)

		IF retorno[1] == .T.
			//alert("SUCESSO NO ENVIO AO WMS")
		ELSE
			IF !ISBLIND()
				ALERT("ERRO NO ENVIO AO WMS.")
				ALERT(retorno[2])
			ENDIF
		ENDIF
	
	ELSE

		//IATAN EM 11/08/2022
		IF  SF1->F1_TIPO<>'D' .AND. SF1->F1_EST == 'EX'
				U_ENVWMS() // ENVIA A NOTA DE IMPORTA��O PARA O WMS
		ENDIF



		IF EMPTY(SF1->F1_ZMOTDEV) .and. SF1->F1_TIPO='D'

		Define MsDialog oDlg01 Title "Motivo da Devolucao"  From 000,000 To 250, 730 Pixel Style DS_MODALFRAME

		@ nLinha + 002, 010 Say OemToAnsi("Motivo Devolucao") Of oDlg01 Pixel

		@ nLinha, 055 MsGet oCodDev  Var cCodDev of oDlg01  Pixel F3 "Z40" Valid (!Vazio() .and. A010ValMot(cCodDev))
		@ nLinha, 100 MsGet oDescDev Var cDesDev of oDlg01  Pixel When lEdita  Size 261, 012
		nLinha += 018

		@ 080, 330 Button 'Ok'		Size 030,015 Of oDlg01 Pixel Action (Grava())
		//	@ nLinha, 290 Button 'Cancelar'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )

		@ 110 + 002, 010 Say OemToAnsi("* � obrigat�rio informar o motivo de devolu��o para este tipo de documento") Of oDlg01 Pixel

		oDlg01:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.



		Activate MsDialog oDlg01 Centered

		ENDIF

	ENDIF

RestArea(aAreaSE2)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaSB1)
RestArea(aAreaSA2)
RestArea(aAreaSD2)
RestArea(aArea)
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A010ValMot � Autor �   Ednei Silva    	� Data �18/07/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida��o do Motivo		                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  A010ValMot()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� _cMotivo - Motivo da Devolucao			                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function A010ValMot(_cMotivo)

lRet := .T.

If !Empty(_cMotivo)
	
	DbSelectArea("Z40")
	DbSetOrder(1)
	
	If	DbSeek(xFilial("Z40")+_cMotivo)
		cDesDev  := Z40->Z40_DESCRI
		lGrava   := .T.
	Else
		
		Aviso("AVISO","Motivo de Devoluc�o n�o cadastrada!", { "Sair" }, 2)
		lRet := .F.
		
	EndIf
	
EndIf

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Grava � Autor �   Ednei Silva    		� Data �18/07/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao �Grava o motivo de devolucao no cabecalho da nota			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  Grava()         	                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 											                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Grava()

If	lGrava
	RecLock('SF1',.F.)
	   SF1->F1_ZMOTDEV := cCodDev
	   SF1->F1_ZDESMOT := cDesDev
	SF1->(MsUnlock())
	
	MsgInfo("Dados gravados com sucesso!","Informa��o!")
	oDlg01:End()
Else
	MsgInfo("Selecione um motivo de devolucao!","Informa��o!")
EndIf

Return ()

