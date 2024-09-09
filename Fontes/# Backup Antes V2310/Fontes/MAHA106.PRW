#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "XMLXFUN.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ Ednei Silva          Data ณ 17/07/18    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta XML para o Site							          บฑฑ
ฑฑบ  		 ณ 							                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function ExportaXML()
Local cArqLocal := ""
Local cXML      := ""
Local nHdl      := 0




cQuery:=" SELECT    "
cQuery+=" B1_COD,     "
cQuery+=" B1_DESC,    "
cQuery+=" B1_GRUPO,   "
cQuery+=" BM_DESC,    "
cQuery+=" B1_MARCA,   "
cQuery+=" B1_DESCMAR, "
cQuery+=" DA1_PRCVEN, "
cQuery+=" REPLACE((ISNULL( CONVERT( VARCHAR(8000), CONVERT(VARBINARY(8000), B1_FICHATE)),'')),'/','') AS MEMO "
cQuery+=" FROM " + RetSQLName("SB1") + " SB1 "
cQuery+=" INNER JOIN " + RetSQLName("DA1") + " DA1 ON (DA1.DA1_CODPRO= SB1.B1_COD) "
cQuery+=" INNER JOIN " + RetSQLName("SBM") + " SBM ON (SB1.B1_GRUPO= SBM.BM_GRUPO) "
cQuery+=" WHERE "
cQuery+=" DA1.DA1_CODTAB='007' "
cQuery+=" AND DA1.D_E_L_E_T_<>'*' "
cQuery+=" AND SB1.D_E_L_E_T_<>'*' "
cQuery+=" AND SBM.D_E_L_E_T_<>'*' "

cQuery := ChangeQuery(cQuery)
MemoWrite("Produto_Site.SQL",cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .T., .T.)
TcSetField( "TRB1", "DA1_PRCVEN" , TamSX3("AO4_NVESTN")[3] , TamSX3("AO4_NVESTN")[1] , TamSX3("AO4_NVESTN")[2] )
DbSelectArea('TRB1')

If TRB1->(!Eof())
	
	//DbSelectArea("SB1")
    //SB1->(dbSetOrder(1))
	//Nome do Arquivo
	cArqLocal := "ProdutoSite.XML"//
	//Cria uma arquivo vazio em disco
	nHdl := Fcreate("\Data\"+cArqLocal)
	cXML := '<?xml version="1.0" encoding="UTF-8" ?>'
	//...Aqui fica o corpo do XML
	cXML += '<Produtos>'
	Do While TRB1->(!Eof())
				// Produto
	  	//SB1->(dbSeek( xFilial("SB1")+TRB1->B1_COD, .F. ))	
	    MemoWrite("Produto_Site.SQL",TRB1->B1_COD)
		cXml += '<Codigo Id="'+AllTrim(TRB1->B1_COD)+'">'
	   	cXml += '<Descricao>'+EncodeUTF8( _NoTags( AllTrim(TRB1->B1_DESC) ) )+'</Descricao>'
	    cXML += '<Grupo>'+EncodeUTF8( _NoTags( AllTrim(TRB1->B1_GRUPO) ) )+'</Grupo>'
	    cXML += '<DesGrupo>'+EncodeUTF8( _NoTags( AllTrim(TRB1->BM_DESC) ) )+'</DesGrupo>'
	  	cXML += '<Marca>'+EncodeUTF8( _NoTags( AllTrim(TRB1->B1_MARCA) ) )+'</Marca>'
	  	cXML += '<DesMarca>'+EncodeUTF8( _NoTags( AllTrim(TRB1->B1_DESCMAR) ) )+'</DesMarca>'
	  //  cXML += '<Preco>'+Transform(TRB1->DA1_PRCVEN,"@R 999,999,999.99")+'</Preco>'
	  // 	cXML += '<DtAtualizacao>'+dToC(date())+'</DtAtualizacao>'
	  // 	cXML += '<Texto>'+EncodeUTF8( _NoTags( TRB1->MEMO ) )+'</Texto>'
	 //	cXML += '</Codigo>'
			
		dbSkip()
		
	endDo
	cXML += '</Produtos>'
	//Fun็ใo escreve no arquivo TXT.
	FWRITE(nHdl,cXML)
	//Fecha o arquivo em disco
	FCLOSE(nHdl)
	
	//Copia o arquivo da pasta \DATA\ do protheus para a maquina local.
	If CpyS2T( "\Data\"+cArqLocal, "C:\temp\", .F. )
		//Excluir arquivo em disco da pasta \DATA\ para nใo ocupar espa็o do servidor
		If FERASE("\Data\"+cArqLocal) == -1
			MsgStop('Falha na dele็ใo do Arquivo')
		Else
			//Apresenta mensagem informando que foi exportado
			MSGALERT("Arquivos exportados com sucesso.", "Exporta็ใo")//"Arquivos exportados com sucesso." - "Exporta็ใo"
		EndIf
	Else
		MsgStop('Nใo foi possํvel copiar o arquivo')
	EndIf
TRB1->(DbCloseArea())
//SB1->(DbCloseArea())
endif

Return


