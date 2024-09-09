#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"  


USER FUNCTION  MTA450I()  

	Local retorno 
	Local mensagem := ""

	conout("zoho MTA450I -- 1")

	//IATAN EM 25/08/2022
	IF U_checkOper(SC5->C5_FILIAL, SC5->C5_NUM) == .T.
		//alert("PEDIDOS COM OPERACAO 15 E 22 NAO SERAO INTEGRADOS")
	ELSE
		//IATAN EM 14/07/2022 - MANDA O PEDIDO PARA O WMS
		//U_MAPWMS07( SC5->(RECNO()), "")
		//IATAN EM 22/06/2023
		conout("zoho MTA450I -- 2")
		retorno := U_MAPWMS07( SC5->(RECNO()), @mensagem)
		conout("zoho MTA450I -- 3")
		IF retorno == .T. .AND. !EMPTY(ALLTRIM(mensagem))
			RecLock("SC5",.F.)
			SC5->C5_XWMS	:= "S"  
			SC5->C5_XMSGWMS	:= mensagem
			SC5->( MsUnlock() )
			conout("zoho MTA450I -- 4")
			//alert("INTEGRADO COM SUCESSO")
		ENDIF		
	ENDIF

	//Iatan em 07/07/2022
	//VERIFICA SE O PEDIDO ESTÁ APTO A SER FATURADO AUTOMATICAMENTE APÓS A LIBERAÇÃO DE CRÉDITO
	//U_xFaturar(SC9->C9_FILIAL, SC9->C9_PEDIDO)

RETURN
