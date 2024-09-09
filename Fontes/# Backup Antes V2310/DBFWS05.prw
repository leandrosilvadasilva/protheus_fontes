#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//ÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ
//Â   EXEMPLO DE URL: http://localhost:8080/clientes/aURLParms[1]/aURLParms[2]         Â
//ÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ
//Â - Essa função foi desenvolvida para retornar os clientes atraves do código do	   Â
//Â cliente + loja do cliente                                                          Â
//ÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ
//Â - PARAMETROS 																	   Â
//Â - -------------------------------------------------------------------------------- Â
//Â - PARAMETRO 1 DA URI (É O CODIGO DO CLIENTE + LOJA )							   Â
//Â - PARAMETRO 2 DA URI (É O CODIGO DO ULTIMO REGISTRO RETORNADO {DEFAULT É 1} )      Â
//Â - -------------------------------------------------------------------------------- Â
//Â - OBS : 																		   Â
//Â 	   A CONSULTA RETORNARÁ NO MAX 500 REGISTROS POR VEZ, CASO NÃO SEJA INFORMADO  Â
//Â NENHUM PARAMETRO, A CONSULTA RETORNARA NAO RETORNARA NENHUM 					   Â
//ÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ


WSRESTFUL produtos DESCRIPTION "Classe para os Produtos utilizados pela assistencia

WSDATA count AS INTEGER
WSDATA startIndex AS INTEGER


WSMETHOD GET DESCRIPTION "Envia lista de produtos" WSSYNTAX "/produtos || /produtos/{id}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE startIndex, count WSSERVICE produtos
	
	LOCAL 	i
	LOCAL   sQry   		:= ""
	LOCAL 	RetProd  	:= {}
	LOCAL 	cProd		:= ""
	

	VarInfo( "=======>>>> 1", .T.)
	VarInfo( "=======>>>> 2", .F.)

	//DEFINE O TIPO DE ROTORNO
	::SetContentType("application/json")
	
	
	//ÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ
	//Â VERIFICA SE HÁ APENAS UM PARAMETRO, POISE HOUVER DOIS PRECISA RESULTAR OS PROXIMOS   Â
	//Â DO CADASTRO DE PRODUTO APARTIR DO SEGUNDO PARAMETRO DA URI                           Â
	//ÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ



	cTmpAlias := GetNextAlias()	
	/*select B1_COD, B1_DESC, B2_QATU, A2_COD, A2_NOME, A2_CASSIST, A2_ARMASSI
	From SB1010 SB1 , SB2010 SB2 , SA2010 SA2
	where SB1.D_E_L_E_T_ = ''
	and SB2.D_E_L_E_T_ = ''
	and SA2.D_E_L_E_T_ = ''
	and SB2.B2_COD = SB1.B1_COD
	and SB2.B2_LOCAL = A2_ARMASSI
	and SB1.B1_PROASSI = 'S'
	and SA2.A2_CASSIST = '1'*/
	
	sQry  := ""
	sQry  += "select B1_COD, B1_DESC, B2_QATU "
	sQry  += "From "+ RetSqlName("SB1")+" SB1 , "+ RetSqlName("SB2")+" SB2 "
	sQry  += "where SB1.D_E_L_E_T_ = '' "
	sQry  += "and SB2.D_E_L_E_T_ = '' "
	sQry  += "and SB2.B2_COD = SB1.B1_COD "
	
	VarInfo( "=======>>>> 3", .T.)
	VarInfo( "=======>>>> 4", .F.)
	VarInfo( "=======>>>> 5", sQry)	
	
	If Len(::aURLParms) = 1 // apenas com o numero da assistenci 
	
		sQry  += "and SB1.B1_COD = '"+alltrim(::aURLParms[1])+"'"
	
	
	ElseIf Len(::aURLParms) == 2 // com parametro de assistenci e código de produto especifico
		

		sQry  += "and SB1.B1_COD = '"+alltrim(::aURLParms[2])+"'"
		
	Else
		::SetResponse('{"cod_erro":102, "desc_erro":"parametros incorretos!"}')
	
	
	Endif
	
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,sQry),cTmpAlias,.F.,.T.)
	
	Count to _nRec
	(cTmpAlias)->(dbgoTop())

	VarInfo( "=======>>>> 6", .T.)
	VarInfo( "=======>>>> 7", .F.)

	If _nRec > 0
		
		DEFAULT ::startIndex := 1
		
		::SetResponse('[')
		i:=1
		Do While !(cTmpAlias)->(EOF())
			
			
			If i > ::startIndex
				::SetResponse(',')
			EndIf
			
			cProd	:= ""
			cProd	:= StrTran((cTmpAlias)->B1_DESC, '""', '')
			cProd	:= StrTran((cTmpAlias)->B1_DESC, '"', '')
			
			sJson   :=''
			sJson 	+='{'
			sJson 	+='"codigo": "'+Alltrim((cTmpAlias)->B1_COD ) +'",'
			sJson 	+='"descricao": "'+Alltrim(cProd) +'",'
			sJson 	+='"quantidade": "'+Alltrim(str((cTmpAlias)->B2_QATU) ) +'"'
			
			sJson 	+='}'
			
			::SetResponse( sJson )
			
			(cTmpAlias)->(DbSkip())
			i++
		Enddo
		::SetResponse(']')
	Else
		::SetResponse('{"cod_erro":101, "desc_erro":"Nenhum produto encontrado"}')
	ENdif
	(cTmpAlias)->(DbCloseArea())
	
	
Return .T.


