#INCLUDE "SPEDNFE.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#DEFINE TAMMAXXML  GetNewPar("MV_XMLSIZE",400000) 
#DEFINE VBOX       080
#DEFINE HMARGEM    030

Static cTipoNfe := ""
static __cDocChv
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPEDNFe   ³ Autor ³ Eduardo Riera         ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de transmissao da Nota fiscal eletronica           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function SPEDNFe()

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nVezes    := 0
cTipoNfe := ""

PRIVATE lBtnFiltro:= .F.

If SM0->M0_ESTCOB == "RJ" .And.;
	(ExistFunc("STBHomolPaf") .And. STBHomolPaf()) .And.;
 	(SuperGetMV("MV_LJPAFEC",,.F.) .Or. (ExistFunc("LjNfPafEcf") .And. LjNfPafEcf(SM0->M0_CGC)))

	MsgAlert("Função não permitida para este estado")
	lRetorno := .F.
EndIf

While lRetorno
	lBtnFiltro:= .F.
    lRetorno := SpedNfe2(nVezes==0)
    nVezes++
    If !lBtnFiltro
    	Exit
    EndIf
EndDo
RestArea(aArea)
Return Nil

Static Function SPEDNFe2(lInit,cAlias)

Local aCores        := {}
Local aIndArq       := {}
Local aParam        := {}
Local aPerg         := {}
Local aPerg2        := {}

Local cEvento		:= ""
Local cParCLeRem    := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDCLEREM"
Local cParamEven	:= SM0->M0_CODIGO+SM0->M0_CODFIL
Local cRotina       := ""
Local cUF			:= Upper(Left(LTrim(SM0->M0_ESTENT),2))
Local cURL       	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cUseAlias		:= "SF2"
local cError	:= ""
Local lEntAtiva     := .T.
Local lEvento		:= .F.
Local lRetorno      := .T.
Local lVerPerg 		:= .T.
Local cGrupo		:= FWGrpCompany()		//Retorna o grupo
Local cFil 		:= FWCodFil()			//Retorna o código da filial
Local cCondAgro	    := ""
Local aCoresAux		:= {}

Private lSdoc     := TamSx3("F2_SERIE")[1] == 14

Private aFilBrw     := {}
Private aParamVeic  := {}
Private aPergCle    := {}
Private aPergEvento := {}
Private aRotina     := {}

Private bFiltraBrw

Private lRedefVeic	:= .F.
Private lVeicOK		:= .T.
Private lUsaColab		:= UsaColaboracao("1")
Private cUSACOLAB		:= GetNewPar("MV_SPEDCOL","N")
Private cDOCSCOL		:= GetNewPar("MV_DOCSCOL","")

Private cCondicao  	:= ""
Private cCondQry   	:= ""
Private cIdEnt		:= ""
Private cCadastro  	:= ""
Private cVersaoTSS	:= ""

if lUsaColab .And. AliasIndic("CKQ") .And. AliasIndic("CKO") .And. AliasIndic("CKP") .And. !(RetSqlName("CKO") == "CKOCOL")
 	MsgInfo("A tabela CKO deve ser única para todas as empresas do sistema, desta forma o campo X2_ARQUIVO na SX2 deve estar preenchido obrigatoriamentecom o conteúdo CKOCOL, para que a importação de arquivos funcione corretamente.")	
endif

if !lUsaColab
	cIdEnt := GetIdEnt()
	cVersaoTSS	:= getVersaoTSS()
	if Upper(cUSACOLAB) $ "S" .And. ("0" $ cDOCSCOL .Or. "1" $ cDOCSCOL)
		cCadastro	:= 	STR0001 + " - TOTVS Colaboração 1.0 " + " - Entidade : " + cIdEnt+" - TSS: "+ cVersaoTSS
	Else
	cCadastro  	:= STR0001 + " - Entidade : " + cIdEnt+" - TSS: "+ cVersaoTSS  //"Monitoramento da NFe-SEFAZ"
	Endif
else
	cCadastro	:= 	STR0001 + " - TOTVS Colaboração 2.0"
endif





if( !lUsaColab )

	//Obtem a versao do TSS - Totvs Services SPED
	cVersaoTSS := getVersaoTSS(@cError)

	lOk := empty(cError)

else
	cVersaoTSS := "Colab2.0"
endif

aRotina := MenuDef(,cVersaoTSS)


// SERVICO A SER UTILIZADO- Nfe/Cle/CCe|
aadd(aPerg2,{2,STR0008,"1-NFe      ",{"1-NFe","2-CLe","3-CCe","4-Reg Saida"},120,".T.",.T.,".T."})

lVerPerg := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
//³                        Agroindustria                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("OGXUtlOrig") //Encontra a função
	If OGXUtlOrig() // Retorna se tem integração com Agro/originação modulo 67
		If FindFunction("AGRXPERGROM")
			lVerPerg := AGRXPERGROM()
		EndIf
	EndIf
Endif

If lVerPerg
	If !ParamBox(aPerg2,STR0223,,,,,,,,"TOTVSSPED",.T.,)//"TOTVS Services SPED - NFe/CLe/CCe"
		Return Nil
	EndIf
EndIf


//Verifica se o serviço foi configurado - Somente o Adm pode configurar
If lInit .And. !lUsaColab
	If (!IsReady() .Or. !IsReady(,2))
		If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
			SpedNFeCFG()
		Else
			HelProg(,"FISTRFNFe")
		EndIf
	EndIf
	lEntAtiva := SpedEntAtiv()
EndIf


If Substr(MV_PAR01,1,1) == "1"	//NFe
	aRotina   := MenuDef("1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem das perguntas                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aPerg,{2,STR0075,PadR("",Len("2-Entrada")),{STR0076,STR0077},120,".T.",.T.,".T."}) //"Tipo de NFe"###"1-Saída"###"2-Entrada"
	aadd(aPerg,{2,STR0082,PadR("",Len("5-Não Transmitidas")),{STR0084,STR0083,STR0110,STR0111,STR0112},120,".T.",.T.,".T."}) //"Filtra"###"1-Autorizadas"###"2-Sem filtro"###"3-Não Autorizadas"###"4-Transmitidas"###"5-Não Transmitidas"
	aadd(aPerg,{1,STR0010,PadR("",Len(If(lSdoc,SF2->F2_SDOC,SF2->F2_SERIE))),"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"

	If lUsaColab .Or. ( lEntAtiva .And. (!lInit .Or. IsReady()) )

		lVerPerg := .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		//³                        Agroindustria                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FindFunction("OGXUtlOrig") //Encontra a função
			If OGXUtlOrig() // Retorna se tem integração com Agro/originação modulo 67
				If FindFunction("AGRFILNFE")
					cCondAgro +=  AGRFILNFE()
					
					If !Empty(cCondAgro)
						lVerPerg := .F.
					EndIf
				EndIf
			EndIf
		Endif

		If lVerPerg
			If !ParamBox(aPerg,"SPED - NFe",,,,,,,,"SPEDNFE"+cGrupo+cFil,.T.,.F.)
				lRetorno := .F.
			EndIf
		EndIf

		If lRetorno
			cTipoNfe	:= If(Substr(MV_PAR01,1,1) == "2","ENTRADA","SAIDA")
			If SubStr(MV_PAR01,1,1) == "1" // nota de saída
				aCores    := {{"F2_FIMP==' ' .AND. AllTrim(F2_ESPECIE)=='SPED'",'DISABLE' },;	//NF não transmitida
							  {"F2_FIMP=='S'",'ENABLE'},;									//NF Autorizada
							  {"F2_FIMP=='T'",'BR_AZUL'},;									//NF Transmitida
							  {"F2_FIMP=='D'",'BR_CINZA'},;									//NF Uso Denegado
							  {	"F2_FIMP=='N'",'BR_PRETO'}}									//NF nao autorizada
				
				If ExistBlock("FISLEGNFE")
					aCoresAux := ExecBlock("FISLEGNFE", .F., .F., {aCores, cTipoNfe})
					If ValType(aCoresAux) == "A"
						aCores := aCoresAux
					EndIf
				EndIf				  
				 		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se vai utilizar o filtro mbrowse ou o filtro recebido                        ³
				// ExistBlock("FISFILNFE") - Ponto de entrada que retorna um filtro                      ³
				// FindFunction("AGRFILNFE") - Integração com agro/originação modulo 67, retorna filtro  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF ExistBlock("FISFILNFE") .or. ( FindFunction("OGXUtlOrig") .and. OGXUtlOrig() .and.  FindFunction("AGRFILNFE") )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realiza a Filtragem                                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"
					If !Empty(MV_PAR03)
						If lSdoc
							cCondicao += ".AND.F2_SDOC=='"+MV_PAR03+"'"
						Else
							cCondicao += ".AND.F2_SERIE=='"+MV_PAR03+"'"
						EndIf
					EndIf
					If SubStr(MV_PAR02,1,1) == "1" //"1-NF Autorizada"
						cCondicao += ".AND. F2_FIMP$'S' "
					ElseIf SubStr(MV_PAR02,1,1) == "3" //"3-Não Autorizadas"
						cCondicao += ".AND. F2_FIMP$'N' "
					ElseIf SubStr(MV_PAR02,1,1) == "4" //"4-Transmitidas"
						cCondicao += ".AND. F2_FIMP$'T' "
					ElseIf SubStr(MV_PAR02,1,1) == "5" //"5-Não Transmitidas"
						cCondicao += ".AND. F2_FIMP$' ' "
					EndIf
					If ExistBlock("FISFILNFE")
						cCondicao := ExecBlock("FISFILNFE",.F.,.F.)
					EndIf
	
					lVerPerg := .T.
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
					//³                        Agroindustria                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FindFunction("OGXUtlOrig") //Encontra a função
						If OGXUtlOrig() // Retorna se tem integração com Agro/originação modulo 67
							If FindFunction("AGRFILNFE")
								cCondicao +=  cCondAgro
							EndIf
						EndIf
					Endif
	
					aFilBrw		:=	{'SF2',cCondicao}
					bFiltraBrw := {|| FilBrowse("SF2",@aIndArq,@cCondicao) }
					Eval(bFiltraBrw)
					//Acrescenta mensagem para o usuario
					MensPadrao()
					mBrowse( 6, 1,22,75,"SF2",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,,,,,,IIf(IsInCallStack( "OGA250" ), {|oBrowse| oBrowse:SetMainProc("SPEDNFE")}, Nil) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Restaura a integridade da rotina                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SF2")
					RetIndex("SF2")
					dbClearFilter()
					aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})
				
				
				else
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realiza a filtragem dos parâmetros e compatibiliza com a filtragem via mbrowse()³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCondicao := "F2_FILIAL='"+xFilial("SF2")+"'"
					If !Empty(MV_PAR03)
						If lSdoc
							cCondicao += " AND F2_SDOC='"+MV_PAR03+"'"
						Else
							cCondicao += " AND F2_SERIE='"+MV_PAR03+"'"
						EndIf
					EndIf
					if SubStr(MV_PAR02,1,1) == "1" //"1-NF Autorizada"
						cCondicao += " AND  F2_FIMP LIKE 'S' "
					ElseIf SubStr(MV_PAR02,1,1) == "3" //"3-Não Autorizadas"
						cCondicao += " AND  F2_FIMP LIKE 'N' "
					ElseIf SubStr(MV_PAR02,1,1) == "4" //"4-Transmitidas"
						cCondicao += " AND F2_FIMP LIKE 'T' "
					ElseIf SubStr(MV_PAR02,1,1) == "5" //"5-Não Transmitidas"
						cCondicao += " AND F2_FIMP LIKE ' ' "
					EndIf

	
					lVerPerg := .T.
	
					//Acrescenta mensagem para o usuario
					MensPadrao()
					mBrowse( 6, 1,22,75,"SF2",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,cCondicao,,,,,IIf(IsInCallStack( "OGA250" ), {|oBrowse| oBrowse:SetMainProc("SPEDNFE")}, Nil) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Restaura a integridade da rotina                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SF2")
					RetIndex("SF2")
				endif
					
			
			Else // nota de entrada
				If SF1->(FieldPos("F1_FIMP"))>0
					aCores    := {{"F1_FIMP==' ' .AND. AllTrim(F1_ESPECIE)=='SPED'",'DISABLE' },;	//NF não transmitida
								  {"F1_FIMP=='S'",'ENABLE'},;									//NF Autorizada
								  {"F1_FIMP=='T'",'BR_AZUL'},;									//NF Transmitida
								  {"F1_FIMP=='D'",'BR_CINZA'},;									//NF Uso Denegado
								  {"F1_FIMP=='N'",'BR_PRETO'}}									//NF nao autorizada
					
					If ExistBlock("FISLEGNFE")
						aCoresAux := ExecBlock("FISLEGNFE", .F., .F., {aCores, cTipoNfe})
						If ValType(aCoresAux) == "A"
							aCores := aCoresAux
						EndIf
					EndIf
				Else
					aCores := Nil
				EndIf
				if len(aRotina) > 12
					aRotina[13] := {"", ""		,0,2,0 ,NIL}
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se vai utilizar o filtro mbrowse ou o filtro recebido                        ³
				// ExistBlock("FISFILNFE") - Ponto de entrada que retorna um filtro                      ³
				// FindFunction("AGRFILNFE") - Integração com agro/originação modulo 67, retorna filtro  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF ExistBlock("FISFILNFE") .or. ( FindFunction("OGXUtlOrig") .and. OGXUtlOrig() .and.  FindFunction("AGRFILNFE") )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realiza a Filtragem                                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCondicao := "F1_FILIAL=='"+xFilial("SF1")+"' .AND. "
					cCondicao += "F1_FORMUL=='S'"
					If !Empty(MV_PAR03)
						If lSdoc
							cCondicao += ".AND.F1_SDOC=='"+MV_PAR03+"'"
						Else
							cCondicao += ".AND.F1_SERIE=='"+MV_PAR03+"'"
						EndIf
					EndIf
					If SubStr(MV_PAR02,1,1) == "1" .And. SF1->(FieldPos("F1_FIMP"))>0 //"1-NF Autorizada"
						cCondicao += ".AND. F1_FIMP$'S' "
					ElseIf SubStr(MV_PAR02,1,1) == "3" .And. SF1->(FieldPos("F1_FIMP"))>0 //"3-Não Autorizadas"
						cCondicao += ".AND. F1_FIMP$'N' "
					ElseIf SubStr(MV_PAR02,1,1) == "4" .And. SF1->(FieldPos("F1_FIMP"))>0 //"4-Transmitidas"
						cCondicao += ".AND. F1_FIMP$'T' "
					ElseIf SubStr(MV_PAR02,1,1) == "5" .And. SF1->(FieldPos("F1_FIMP"))>0 //"5-Não Transmitidas"
						cCondicao += ".AND. F1_FIMP$' ' "
					EndIf
					If ExistBlock("FISFILNFE")
						cCondicao := ExecBlock("FISFILNFE",.F.,.F.)
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
					//³                        Agroindustria                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FindFunction("OGXUtlOrig") //Encontra a função
						If OGXUtlOrig() // Retorna se tem integração com Agro/originação modulo 67
							If FindFunction("AGRFILNFE")
								cCondicao +=  cCondAgro
							EndIf
						EndIf
					Endif
	
					aFilBrw		:=	{'SF1',cCondicao}
					bFiltraBrw := {|| FilBrowse("SF1",@aIndArq,@cCondicao) }
					Eval(bFiltraBrw)
					//Acrescenta mensagem para o usuario
					MensPadrao()
					mBrowse( 6, 1,22,75,"SF1",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,,,,,,IIf(IsInCallStack( "OGA250" ), {|oBrowse| oBrowse:SetMainProc("SPEDNFE")}, Nil))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Restaura a integridade da rotina                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SF1")
					RetIndex("SF1")
					dbClearFilter()
					aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})
				else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realiza a Filtragem                                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCondicao := "F1_FILIAL = '"+xFilial("SF1")+"' AND "
					cCondicao += "F1_FORMUL = 'S'"
					If !Empty(MV_PAR03)
						If lSdoc
							cCondicao += " AND F1_SDOC = '"+MV_PAR03+"'"
						Else
							cCondicao += " AND F1_SERIE = '"+MV_PAR03+"'"
						EndIf
					EndIf
					If SubStr(MV_PAR02,1,1) == "1" .And. SF1->(FieldPos("F1_FIMP"))>0 //"1-NF Autorizada"
						cCondicao += " AND F1_FIMP LIKE 'S' "
					ElseIf SubStr(MV_PAR02,1,1) == "3" .And. SF1->(FieldPos("F1_FIMP"))>0 //"3-Não Autorizadas"
						cCondicao += " AND F1_FIMP LIKE 'N' "
					ElseIf SubStr(MV_PAR02,1,1) == "4" .And. SF1->(FieldPos("F1_FIMP"))>0 //"4-Transmitidas"
						cCondicao += " AND F1_FIMP LIKE 'T' "
					ElseIf SubStr(MV_PAR02,1,1) == "5" .And. SF1->(FieldPos("F1_FIMP"))>0 //"5-Não Transmitidas"
						cCondicao += " AND F1_FIMP LIKE ' ' "
					EndIf
					
	
					//Acrescenta mensagem para o usuario
					MensPadrao()
					mBrowse( 6, 1,22,75,"SF1",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,cCondicao,,,,,IIf(IsInCallStack( "OGA250" ), {|oBrowse| oBrowse:SetMainProc("SPEDNFE")}, Nil))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Restaura a integridade da rotina                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SF1")
					RetIndex("SF1")
					cTipoNFE := ""
				endif
			EndIf
		EndIf
	Else
		HelProg(,"FISTRFNFe")
		lRetorno := .F.
	EndIf

ElseIf Substr(MV_PAR01,1,1) == "2"	//CLe
	dbSelectArea('SF2')
	dbSelectArea('DA3')
	dbSelectArea('SX5')
	If (SF2->(FieldPos('F2_CLEOK')) > 0 .And.SF2->(FieldPos('F2_CHVCLE')) > 0 .And. SF2->(FieldPos('F2_IDCLE')) > 0;
	                                .And. DA3->(FieldPos('DA3_TIPTRA')) > 0 .And. SX5->(MsSeek(xFilial('SX5')+'78')).And. GetInfoFunc('CLIENTWSCLE.PRW',"P")[1])

		cCadastro:= STR0224 + " - Entidade : " + cIdEnt//"Monitoramento da CLe-SEFAZ"
		aRotina   := MenuDef("2")
	   	aadd(aPergCle,{2,STR0296,PadR("",Len(STR0319)),{STR0225,STR0319,STR0320},100,".T.",.F.,".T."})//"Status"1-Capeada,2-Nao capeada,3-Todas
	   	aadd(aPergCle,{1,STR0226,Space(TAMSX3("F2_EST"		)[1]),,,"12"	,,30,.T.})//"UF destino"
	   	aadd(aPergCle,{1,STR0227,Space(TAMSX3("F2_DOC"		)[1]),,,		,,50,.F.})//"Nota de"
	   	aadd(aPergCle,{1,STR0228,Space(TAMSX3("F2_DOC"		)[1]),,,		,,50,.F.})//"Nota Ate"

		If lSdoc
			aadd(aPergCle,{1,STR0229,Space(TAMSX3("F2_SDOC"	)[1]),,,		,,30,.F.})//"Serie de"
		   	aadd(aPergCle,{1,STR0230,Space(TAMSX3("F2_SDOC"	)[1]),,,		,,30,.F.})//"Serie Até"
		Else
	   		aadd(aPergCle,{1,STR0229,Space(TAMSX3("F2_SERIE"	)[1]),,,		,,30,.F.})//"Serie de"
		   	aadd(aPergCle,{1,STR0230,Space(TAMSX3("F2_SERIE"	)[1]),,,		,,30,.F.})//"Serie Até"
		EndIF

	   	aadd(aPergCle,{1,STR0231,Space(TAMSX3("F2_VEICUL1"	)[1]),,,"DA3"	,,50,.F.})//"Veículo"
	   	aadd(aPergCle,{1,STR0232,Space(TAMSX3("F2_VEICUL2"	)[1]),,,"DA3"	,,50,.F.})//"Carreta"
	   	aadd(aPergCle,{1,STR0233,Space(TAMSX3("F2_VEICUL3"	)[1]),,,"DA3"	,,50,.F.})//"Carreta2"
	   	aadd(aPergCle,{2,STR0234,Padr("",Len(STR0235)),{STR0235,STR0236},50,".T.",.F.,".T."})//"Trans.Indefinido" "1-Sim"   "2-Nao"

		aCores	:={	{"F2_IDCLE	== '"+Space(TAMSX3("F2_IDCLE"	)[1])+"'.And. F2_VEICUL1=='"+Space(TAMSX3("F2_VEICUL1")[1])+"'",'DISABLE' },;
					{"F2_IDCLE	<> '"+Space(TAMSX3("F2_IDCLE"	)[1])+"'",'ENABLE'},;
					{"F2_VEICUL1<> '"+Space(TAMSX3("F2_VEICUL1"	)[1])+"'",'BR_AZUL'}}

		If lEntAtiva .And. (!lInit .Or. IsReady())
			If ParamBox(aPergCle,STR0237,@aParam,{||If(EXISTCPO("SX5","12"+MV_PAR02),lRet:=.T.,lRet:=.F.),lRet},,,780,1024,,cParCLeRem,.T.,)//"Capa de Lote"//{||If(EXISTCPO("SX5","12"+MV_PAR02),lRet:=.F.,lRet:=.F.),lRet}
				cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"' .And. "
				cCondicao += "F2_CHVNFE<>'"+Space(TAMSX3("F2_CHVNFE")[1])+"' "
				If Substr(MV_PAR01,1,1) == "1"
					cCondicao+=".And. F2_IDCLE <> '"+Space(TAMSX3("F2_IDCLE")[1])+"' "
					cCondQry+="AND F2_IDCLE <> '' "
				ElseIf Substr(MV_PAR01,1,1) == "2"
					cCondicao+=".And. F2_IDCLE == '"+Space(TAMSX3("F2_IDCLE")[1])+"' "
					cCondQry+="AND F2_IDCLE		= '' "
				EndIf
				If !Empty(MV_PAR02)
					cCondicao+=".And. F2_EST	== '"+MV_PAR02+"' "
					cCondQry+="AND F2_EST		 = '"+MV_PAR02+"' "
				EndIF
				If !Empty(MV_PAR03)
					cCondicao+=".And. F2_DOC	>= '"+MV_PAR03+"' "
					cCondQry+="AND F2_DOC		>= '"+MV_PAR03+"' "
				EndIF
				If !Empty(MV_PAR04)
					cCondicao+=".And. F2_DOC	<= '"+MV_PAR04+"' "
					cCondQry+="AND F2_DOC		<= '"+MV_PAR04+"' "
				EndIF

				If lSdoc
					If !Empty(MV_PAR05)
						cCondicao+=".And. F2_SDOC	>= '"+MV_PAR05+"' "
						cCondQry+="AND F2_SDOC		>= '"+MV_PAR05+"' "
					EndIF
					If !Empty(MV_PAR06)
						cCondicao+=".And. F2_SDOC	<= '"+MV_PAR06+"' "
						cCondQry+="AND F2_SDOC		<= '"+MV_PAR06+"' "
					EndIF
				Else
					If !Empty(MV_PAR05)
						cCondicao+=".And. F2_SERIE	>= '"+MV_PAR05+"' "
						cCondQry+="AND F2_SERIE		>= '"+MV_PAR05+"' "
					EndIF
					If !Empty(MV_PAR06)
						cCondicao+=".And. F2_SERIE	<= '"+MV_PAR06+"' "
						cCondQry+="AND F2_SERIE		<= '"+MV_PAR06+"' "
					EndIF
				EndIf

				If Substr(MV_PAR10,1,1) =="1" .And. !Empty(MV_PAR07)
					cAbre:="("
					cFecha:=")"
				Else
					cAbre:=""
					cFecha:=""
				EndIf

				If !Empty(MV_PAR07)
					cCondicao+=".And. "+cAbre+"F2_VEICUL1	== '"+MV_PAR07+"' "
					cCondQry+="AND "+cAbre+"F2_VEICUL1	= '"+MV_PAR07+"' "
				EndIF
				If !Empty(MV_PAR08)
					cCondicao+=".And. F2_VEICUL2	== '"+MV_PAR08+"' "
					cCondQry+="AND F2_VEICUL2		= '"+MV_PAR08+"' "
				EndIF
				If !Empty(MV_PAR09)
					cCondicao+=".And. F2_VEICUL3	== '"+MV_PAR09+"' "
					cCondQry+="AND F2_VEICUL3		= '"+MV_PAR09+"' "
				EndIF
				If Substr(MV_PAR10,1,1) =="1" .And. !Empty(MV_PAR07)
					cCondicao+=".OR. (F2_VEICUL1 ==	'"+Space(TAMSX3("F2_VEICUL1")[1])+;
					         "' .And. F2_VEICUL2 == '"+Space(TAMSX3("F2_VEICUL2")[1])+;
					         "' .And. F2_VEICUL3 == '"+Space(TAMSX3("F2_VEICUL3")[1])+"')"+cFecha"
					cCondQry+="OR (F2_VEICUL1 ='' AND F2_VEICUL2 = '' AND F2_VEICUL3 = '')"+cFecha"

				ElseIf Substr(MV_PAR10,1,1) =="2"
					cCondicao+=".And. F2_VEICUL1 <>	'"+Space(TAMSX3("F2_VEICUL1")[1])+"'"
					cCondQry+="AND F2_VEICUL1 <> ''"
				EndIF
				aFilBrw		:=	{'SF2',cCondicao}
				bFiltraBrw := {|| FilBrowse("SF2",@aIndArq,@cCondicao) }
				Eval(bFiltraBrw)

				MarkBrow("SF2","F2_CLEOK","F2_IDCLE <> '"+Space(TAMSX3("F2_IDCLE")[1])+"'",,.F.,GetMark(,"SF2","F2_CLEOK"),,,,,,,,,aCores)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Restaura a integridade da rotina                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF2")
			RetIndex("SF2")
			dbClearFilter()
			aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})
		Else
			HelProg(,"FISTRFNFe")
			lRetorno := .F.
		EndIf
	Else
		MsgInfo("Não disponível.Para utilização desta rotina, deverá ser aplicado o pacote de atualização conforme o Boletim técnico.")
	EndIf

ElseIf Substr(MV_PAR01,1,1) $ "3|4"	//CCe-Registro de saida


	cUseAlias := If(Substr(MV_PAR01,1,1) == "2","SF1","SF2")//Verifica Se é entrada

	If Substr(MV_PAR01,1,1) == "3"	//CCe
		if lUsaColab
			cCadastro	:= STR0344 + " - TOTVS Colaboção 2.0" //"Monitoramento da CCe-SEFAZ"
		else
			cCadastro	:= STR0344 + " - Entidade : " + cIdEnt		//"Monitoramento da CCe-SEFAZ"
		endif
		aRotina		:= MenuDef("3")

		cparamEven += "SPEDCCE"

	    lEvento:=SF2->(FieldPos("F2_EVENFLG")) > 0 .And. SF2->(FieldPos("F2_IDCCE")) > 0 .And. SF1->(FieldPos("F1_EVENFLG")) > 0 .And. SF1->(FieldPos("F1_IDCCE")) > 0

		aadd(aPergEvento,{2,STR0075,PadR("",Len("2-Entrada")),{STR0076,STR0077},120,".T.",.T.,".T."}) //"Tipo de NFe"###"1-Saída"###"2-Entrada
		aadd(aPergEvento,{1,STR0010,PadR("",Len(If(lSdoc,SF2->F2_SDOC,SF2->F2_SERIE))),"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"

		cEvento:="3"
	ElseIf Substr(MV_PAR01,1,1) == "4"	//Regsitro de Saida

		cCadastro	:= STR0388 + " - Entidade : " + cIdEnt//"Monitoramento do Registro de Saída"

		aRotina		:= MenuDef("4")

		cParamEven += "SPEDREGS"

	    lEvento:=SF2->(FieldPos("F2_FLAGRGS")) > 0 .And. SF2->(FieldPos("F2_IDRGS")) > 0 .And. SF2->(FieldPos("F2_CODRGS")) > 0 .And. SF1->(FieldPos("F1_FLAGRGS")) > 0 .And. SF1->(FieldPos("F1_IDRGS")) > 0  .And. SF1->(FieldPos("F1_CODRGS")) > 0

	   	aadd(aPergEvento,{2,STR0075,PadR("",Len("2-Entrada")),{STR0076,STR0077},120,".T.",.T.,".T."}) //"Tipo de NFe"###"1-Saída"###"2-Entrada
		aadd(aPergEvento,{1,STR0010,PadR("",TAMSX3(If(lSdoc,Substr(cUseAlias,2)+"_SDOC",Substr(cUseAlias,2)+"_SERIE"))[1]),"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"

		cEvento:="4"
	EndIf

	If lEvento

		If ( lUsaColab .And. cEvento == "3" ) .Or. ( lEntAtiva .And. (!lInit .Or. IsReady()) )
			If ParamBox(aPergEvento,If(cEvento == "4",STR0392,STR0345),,,,,,,,cParamEven,.T.,)

				cTipoNfe	:= If(Substr(MV_PAR01,1,1) == "2","ENTRADA","SAIDA")
				cUseAlias	:= If(Substr(MV_PAR01,1,1) == "2","SF1","SF2")
				cCondicao	:= Substr(cUseAlias,2)+"_FILIAL=='"+xFilial(cUseAlias)+"' .And. "+Substr(cUseAlias,2)+"_FIMP$'S' .And. !Empty("+Substr(cUseAlias,2)+"_CHVNFE) "
				cCondQry	+= Substr(cUseAlias,2)+"_FILIAL='"+xFilial(cUseAlias)+"'  AND "+Substr(cUseAlias,2)+"_FIMP='S' AND "+Substr(cUseAlias,2)+"_CHVNFE <> ' '"

				If lSdoc
					cCondicao	+= " .And. "+Substr(cUseAlias,2)+"_SDOC=='"+MV_PAR02+"'"
					cCondQry	+= " AND "  +Substr(cUseAlias,2)+"_SDOC='"+MV_PAR02+"'"
				Else
					cCondicao	+= " .And. "+Substr(cUseAlias,2)+"_SERIE=='"+MV_PAR02+"'"
					cCondQry	+= " AND "  +Substr(cUseAlias,2)+"_SERIE='"+MV_PAR02+"'"
				EndIF

				aFilBrw		:= {cUseAlias,cCondicao}
				bFiltraBrw	:= {|| FilBrowse(cUseAlias,@aIndArq,@cCondicao) }
				Eval(bFiltraBrw)

				If cEvento == "3"
						aCores := {	{Substr(cUseAlias,2)+"_EVENFLG == '1'",'ENABLE'},;	//NF vinculada
									{Substr(cUseAlias,2)+"_EVENFLG $ ' 2'",'BR_CINZA'}}	//NF nao vinculada

					mBrowse( 6, 1,22,75,cUseAlias,,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,,,,,,IIf(IsInCallStack( "OGA250" ), {|oBrowse| oBrowse:SetMainProc("SPEDNFE")}, Nil))
				ElseIf 	cEvento == "4"

					aCores := {	{Substr(cUseAlias,2)+"_CODRGS =='" +Space(TAMSX3(Substr(cUseAlias,2)+"_CODRGS")[1])+"'",'DISABLE'},;	//NFe nao vinculada
								{Substr(cUseAlias,2)+"_CODRGS == 'T'","BR_AZUL"		},;	//Evento transmitido
								{Substr(cUseAlias,2)+"_CODRGS == 'N'","BR_CINZA"	},; //Evento Rejeitado
								{Substr(cUseAlias,2)+"_CODRGS == 'S'","ENABLE"		},;//NFe vinculada
								{Substr(cUseAlias,2)+"_CODRGS == 'M'","BR_LARANJA"	},;//Cancelamento transmitido
								{Substr(cUseAlias,2)+"_CODRGS == 'R'","BR_PRETO"	},;//Cancelamento rejeitado
								{Substr(cUseAlias,2)+"_CODRGS == 'C'","BR_AMARELO"	}}//Cancelamento autorizado

					If cUF <> "MG"
						MsgAlert(STR0396+cUF)
					Else
						MarkBrow(cUseAlias,Substr(cUseAlias,2)+"_FLAGRGS",Substr(cUseAlias,2)+"_CODRGS $'T|S|M|R'",,.F.,GetMark(,cUseAlias,Substr(cUseAlias,2)+"_FLAGRGS"),,,,,,,,,aCores)
					EndIF
				EndIF

				// Restaura a integridade da rotina                                ³
				dbSelectArea(cUseAlias)
				RetIndex(cUseAlias)

				dbClearFilter()
				aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})

			Else
				lRetorno := .F.
			EndIf
		Else
			HelProg(,"FISTRFNFe")
			lRetorno := .F.
		EndIf
	Else

		If Substr(MV_PAR01,1,1) == "3"	//CCe
			Aviso("SPED",STR0371,{STR0114},3) //"Execute o compatibilizador (NFE10R106) para Carta de Correção Eletrônica - CC-e !!!"
		ElseIf 	Substr(MV_PAR01,1,1) == "4"	//Registro de Saida
			Aviso("SPED",STR0391,{STR0114},3) //"Execute o compatibilizador para o registro de saida"
		EndIF

	Endif

EndIf
Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SpedNfeLeg³Autor  ³ Eduardo Riera         ³ Data ³02.08.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNfeLeg()
Local aLegenda := {}
				aCores    := {{"F1_FIMP==' ' .AND. AllTrim(F1_ESPECIE)=='SPED'",'DISABLE' },;	//NF não transmitida
							  {"F1_FIMP=='S','ENABLE'"},;									//NF Autorizada
							  {"F1_FIMP=='T','BR_AZUL'"},;									//NF Transmitida
							  {"F1_FIMP=='D','BR_CINZA'"},;									//NF Uso Denegado
							  {"F1_FIMP=='N','BR_PRETO'"}}									//NF nao autorizada

Aadd(aLegenda, {"ENABLE"    ,STR0078}) //"NF autorizada"
Aadd(aLegenda, {"DISABLE"   ,STR0079}) //"NF não transmitida"
Aadd(aLegenda, {"BR_AZUL"   ,STR0080}) //"NF Transmitida"
Aadd(aLegenda, {"BR_PRETO"  ,STR0081})	//"NF nao autorizada"
Aadd(aLegenda, {"BR_CINZA"  ,STR0138})	//"NF Uso Denegado"
BrwLegenda(cCadastro,STR0117,aLegenda) //"Legenda"

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef(cRotina,cVersaoTSS)

Local lInutili  := SuperGetMv("MV_INUTILI", .F., .F.)

Local aRotina2  := { {STR0002,"SpedNFe1Mnt()",0,3},; //"Faixa"
                     {STR0003,"SpedNFe2Mnt",0,3},; //"Tempo"
                     {STR0099,"SpedNFe3Mnt",0,3},; //"Estatísticas"
                     {STR0107,"SpedNfe4Mnt",0,2},; //"Consulta NFe"
                     {STR0140,"SpedNfe5Mnt",0,3}}

Local aRotina3  := {}

Local cError	 := ""
Local xRotina4	 := {}
Local nLjDnfNF	 := SuperGetMv("MV_LJDNFNF", , 0)

Local lConf		 := FunName() == "CFGA530"
Local nI		 := 0
Local nX		 := 0
Local aRotMenu	 := {}

If !Empty( GetNewPar("MV_NFCEURL","") )
	aRotina3  := { {"Nfe","SpedNFePar",0,3},; 		//"Parametros - Nfe"
					{"CTeOS","SpedNFePar('67')",0,3},; //"Parametros - CteOs"
                    {"Eventos","SpedCCePar()",0,3}}	//"Parametros - Eventos"
else
	aRotina3  := { {"Nfe","SpedNFePar",0,3},; 		//"Parametros - Nfe"
					{"NFCe","SpedNFePar('65')",0,3},; //"Parametros - NFCe"
					{"CTeOS","SpedNFePar('67')",0,3},; //"Parametros - CteOs"
					{"Eventos","SpedCCePar()",0,3}}	//"Parametros - Eventos"
endif

Default cRotina		:= "0"
Default cVersaoTSS 	:=""
Private aRotina		:= {}
Private lUsaColab	:= UsaColaboracao("1")

If ExistFunc("U_IMPDNFLJ") .And. ExistFunc("U_LJDNFNFE") .And. nLjDnfNF > 0
	xRotina4 := {	{"Imp. Padrão"		, "SpedDanfe()"	, 0, 3 }	,;
					{"Imp. Não-Fiscal"	, "SpedDanfe(1)", 0, 3 }	}
Else
	xRotina4 := "SpedDanfe()"
EndIf

//Apenas monitor de documentos via TOTVS Colab
if lUsaColab
	aRotina2  :={	{STR0002,"SpedNFe1Mnt()",0,2},; //"Faixa"
					{STR0003,"SpedNFe2Mnt()",0,2},; //"Tempo"
					{STR0107,"SpedNfe4Mnt",0,2}} //"Consulta NFe"
endif

/////////////////////////////////////////////////////////////////
//Trecho incluso para que a especificidade da rotina de definição de previlegios do configurador(CFGA530),
// consiga trazer todas as opções de menu possiveis no tocante ao tipo de documento -->(cRotina)
If lConf .And. ProcName(1) != "MENUDEF"//Como chamo recursivamente a rotina Menudef(Alltrim(Str(nI))) preciso verificar se o menudef ja esta na pilha de chamadas	
	For nI := 1 To 4 //Hoje existem 4 opções de tipo de documento		
		aRotMenu :=  Menudef(Alltrim(Str(nI))) //Alimento aRotMenu com os menus do tipo de Nota

		If nI == 1 //Se for a primeira passada ja alimento a variavel aRotina pois nao ha porque verificar repetidos
			aRotina :=  aRotMenu
		Else
			For nX := 1 To Len(aRotMenu) 
				//Nao alimento aRotina com menus repetidos
				If !(aScan(aRotina,{ |x| x[1] == aRotMenu[nX][1] .And. IIF(Valtype(x[2]) != "A", x[2] == aRotMenu[nX][2], .F.) }) > 0)
					aAdd(aRotina, aRotMenu[nX] )
				EndIf
			Next nX
		EndIf			
	Next nI
Else

	If cRotina $ "0|1"	//NFe
		if lUsaColab
			aRotina := { {STR0004,"PesqBrw"       	,0,1,0,.F.},;  //"Pesquisar"
						{SubStr(STR0006,1,1)+"&"+SubStr(STR0006,2),aRotina3    ,0,3,0 ,NIL},; //"Parâmetros"
						{STR0008,"SpedNFeRemessa"	,0,3,0 ,NIL},; //"Transmissão"
						{"DANFE",xRotina4     		,0,2,0 ,NIL},; //DANFE
						{STR0009,aRotina2        	,0,3,0 ,NIL},; //"Monitor"
						{STR0109,"SpedVisualDoc"	,0,2,0 ,NIL},; //"Visualiza Doc."
						{STR0113,"SpedFiltro"	 	,0,3,0 ,NIL},; //"Filtro"
						{STR0116,"SpedExport(1)"   	,0,2,0 ,NIL},; //"Exportar"
						{STR0117,"SpedNfeLeg"    	,0,3,0 ,NIL}}  //"Legenda"
		else

			cVersaoTSS := getVersaoTSS(@cError)

			If cVersaoTSS >= "12.1.017"
				AADD( aRotina3, {"Cont. Autom.","SpedContAutoPar()",0,3})
			Endif

			aRotina := { {STR0004,"PesqBrw"       	,0,1,0,.F.},;  //"Pesquisar"
						{STR0005,"SpedNFeCfg"    	,0,3,0 ,NIL},; //"Wiz.Config."
						{SubStr(STR0006,1,1)+"&"+SubStr(STR0006,2),aRotina3    ,0,3,0 ,NIL},; //"Parâmetros"
						{STR0007,"SpedNFeStatus" 	,0,3,0 ,NIL},; //"Status SEFAZ"
						{STR0008,"SpedNFeRemessa"	,0,3,0 ,NIL},; //"Transmissão"
						{STR0222,"SpedConsCad"	 	,0,2,0 ,NIL},; //"Contribuinte"
						{"DANFE",xRotina4	     	,0,2,0 ,NIL},;
						{STR0009,aRotina2        	,0,3,0 ,NIL},; //"Monitor"
						{STR0109,"SpedVisualDoc"	,0,2,0 ,NIL},; //"Visualiza Doc."
						{STR0113,"SpedFiltro"	 	,0,3,0 ,NIL},; //"Filtro"
						{STR0116,"SpedExport(1)"   	,0,2,0 ,NIL},; //"Exportar"
						{STR0117,"SpedNfeLeg"    	,0,3,0 ,NIL}}  //"Legenda"
		endif

		If lInutili .And. ( Empty(cTipoNfe) .Or. cTipoNfe == 'SAIDA')
			AADD(aRotina, {STR0196, "SpedNFeInut", 0, 2, 0, NIL}) // "Inutilização"
		EndIf

		If ExistBlock("FISTRFNFE")//Nf-e
			ExecBlock("FISTRFNFE",.F.,.F.)
		EndIf

	ElseIf cRotina == "2"	//CLe
		aRotina := {{STR0004,"PesqBrw"       	,0,1,0,.F.},;  //"Pesquisar"
					{STR0005,"SpedNFeCfg"    	,0,3,0 ,NIL},; //"Wiz.Config."
					{STR0006,"SpedCLePar"    	,0,3,0 ,NIL},; //"Parâmetros"
					{STR0238,"SpedCLeRemessa"	,0,2,0 ,NIL},; //"Gerar CLe"
					{STR0009,"SpedCLeMnt"   	,0,2,0 ,NIL},; //"Monitor"
					{STR0109,"SpedVisualDoc" 	,0,2,0 ,NIL},; //"Visualiza Doc."
					{STR0117,"SpedCLeLeg"    	,0,3,0 ,NIL}}  //"Legenda"

	ElseIf cRotina == "3"	//CCe
		if lUsaColab
			aRotina := {{STR0004,"PesqBrw"       ,0,1,0,.F.},; //"Pesquisar"
						{STR0006,"SpedCCePar()"  ,0,3,0 ,NIL},; //"Parâmetros"
						{STR0008,"SpedCCeRemessa",0,3,0 ,NIL},; //"Transmissao"
						{STR0009,"SpedCCeMnt"    ,0,3,0 ,NIL},; //"Monitor"
						{STR0116,"SpedExport(2)" ,0,2,0 ,NIL},; //"Exportar."
						{STR0109,"SpedVisualDoc" ,0,2,0 ,NIL},; //"Visualiza Doc."
						{STR0113,"SpedFiltro"	 ,0,3,0 ,NIL},; //"Filtro"
						{STR0117,"SpedCCeLeg"    ,0,3,0 ,NIL}} //"Legenda"
		else
			aRotina := {{STR0004,"PesqBrw"       ,0,1,0,.F.},; //"Pesquisar"
						{STR0005,"SpedNFeCfg"    ,0,3,0 ,NIL},; //"Wiz.Config."
						{STR0006,"SpedCCePar()"  ,0,3,0 ,NIL},; //"Parâmetros"
						{STR0008,"SpedCCeRemessa",0,3,0 ,NIL},; //"Transmissao"
						{STR0009,"SpedCCeMnt"    ,0,3,0 ,NIL},; //"Monitor"
						{STR0116,"SpedExport(2)" ,0,2,0 ,NIL},; //"Exportar."
						{STR0109,"SpedVisualDoc" ,0,2,0 ,NIL},; //"Visualiza Doc."
						{STR0113,"SpedFiltro"	 ,0,3,0 ,NIL},; //"Filtro"
						{STR0117,"SpedCCeLeg"    ,0,3,0 ,NIL}} //"Legenda"
		endif

		//-- Inclui Rotinas Específicas No Menu Da CCe
		If ExistBlock("NFEMNUCC")
			aRotAdic := ExecBlock("NFEMNUCC",.F.,.F.)
			If ValType(aRotAdic) == "A"
				aEval(aRotAdic,{|x| aAdd(aRotina,x)})
			EndIf
		EndIf
	ElseIf cRotina == "4"
		aRotina := {{STR0004,"PesqBrw"       ,0,1,0,.F.},; //"Pesquisar"
					{STR0005,"SpedNFeCfg"    ,0,3,0 ,NIL},; //"Wiz.Config."
					{STR0008,"SpedRGSRemessa",0,3,0 ,NIL},; //"Transmissao"
					{STR0009,"SpedRGSMnt"    ,0,3,0 ,NIL},; //"Monitor"
					{STR0109,"SpedVisualDoc" ,0,2,0 ,NIL},; //"Visualiza Doc."
					{STR0117,"SpedRGSLeg"    ,0,3,0 ,NIL},; //"Legenda"
					{STR0394,"SpedCancRGS"	,0,2,0 ,NIL}} //"Cancelamento

		If cVersaoTSS < "2.07"
			aadd(aRotina,{STR0006,"SpedCCePar()"    ,0,3,0 ,NIL}) //"Parâmetros"
		EndIf
	EndIf

EndIf

Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedDanfe ³ Autor ³Eduardo Riera          ³ Data ³27.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de chamada do WS de impressao da DANFE               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedDanfe(nTipo)

Local cIdEnt 		:= ""
Local aIndArq   	:= {}
Local oDanfe
Local nHRes  		:= 0
Local nVRes  		:= 0
Local nDevice
Local cFilePrint	:= ""
Local oSetup
Local aDevice  		:= {}
Local cSession  	:= GetPrinterSession()
Local nRet 			:= 0
Local lUsaColab		:= UsaColaboracao("1")

Default nTipo		:= 0

If findfunction("U_DANFE_V")
	nRet := U_Danfe_v()
Elseif findfunction("U_DANFE_VI") // Incluido esta validação pois o cliente informou que não utiliza o DANFEII
	nRet := U_Danfe_vi()
EndIf

AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6

cIdEnt := GetIdEnt(lUsaColab)

cFilePrint := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")

nLocal       	:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nOrientation 	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
cDevice     	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nPrintType      := aScan(aDevice,{|x| x == cDevice })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajuste no pergunte NFSIGW                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AjustaSX1()

If IsReady(,,,lUsaColab)
	dbSelectArea("SF2")
	RetIndex("SF2")
	dbClearFilter()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nRet >= 20100824

		If nTipo <> 1
			lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
			oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)

			// ----------------------------------------------
			// Cria e exibe tela de Setup Customizavel
			// OBS: Utilizar include "FWPrintSetup.ch"
			// ----------------------------------------------
			//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
			nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
			If ( !oDanfe:lInJob )
				oSetup := FWPrintSetup():New(nFlags, "DANFE")
				// ----------------------------------------------
				// Define saida
				// ----------------------------------------------
				oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
				oSetup:SetPropert(PD_ORIENTATION , nOrientation)
				oSetup:SetPropert(PD_DESTINATION , nLocal)
				oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
				oSetup:SetPropert(PD_PAPERSIZE   , 2)

				If ExistBlock( "SPNFESETUP" )
					Execblock( "SPNFESETUP" , .F. , .F. , {oDanfe, oSetup} )
				Endif
			EndIf

			// ----------------------------------------------
			// Pressionado botão OK na tela de Setup
			// ----------------------------------------------
			If oSetup:Activate() == PD_OK // PD_OK =1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Salva os Parametros no Profile             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
				fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
				fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

				// Configura o objeto de impressão com o que foi configurado na interface.
				oDanfe:setCopies( val( oSetup:cQtdCopia ) )

				If oSetup:GetProperty(PD_ORIENTATION) == 1
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Danfe Retrato DANFEII.PRW                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 				iif (findfunction("u_PrtNfeSef"), u_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint ,/*lIsLoja*/ ) ,;
		  				Help(NIL, NIL, "RDMAKE", NIL, "Fonte de impressão de DANFE não compilado !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse o portal do cliente baixe os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente"}))
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Danfe Paisagem DANFEIII.PRW                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	 				iif (findfunction("u_DANFE_P1"), u_DANFE_P1(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/ ) ,;
		  				Help(NIL, NIL, "RDMAKE", NIL, "Fonte de impressão de DANFE não compilado !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse o portal do cliente baixe os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente"}))
				EndIf

			Else
				MsgInfo("Relatório cancelado pelo usuário.")
				Pergunte("NFSIGW",.F.)
				if len(aFilBrw) > 0
					bFiltraBrw := {|| FilBrowse(aFilBrw[1],@aIndArq,@aFilBrw[2])}
					Eval(bFiltraBrw)
				endif
				Return
			Endif
		ElseIf nTipo == 1
	 		iif (findfunction("u_PrtNfeSef"), U_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ , , , ,/*lIsLoja*/, 1 ) ,;
		  		Help(NIL, NIL, "RDMAKE", NIL, "Fonte de impressão de DANFE não compilado !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse o portal do cliente baixe os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente"}))
		EndIf

	Else
	 	iif (findfunction("u_PrtNfeSef"), u_PrtNfeSef(cIdEnt) ,;
		  Help(NIL, NIL, "RDMAKE", NIL, "Fonte de impressão de DANFE não compilado !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse o portal do cliente baixe os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente"}))
	EndIf

	Pergunte("NFSIGW",.F.)
	if len(aFilBrw) > 0
		bFiltraBrw := {|| FilBrowse(aFilBrw[1],@aIndArq,@aFilBrw[2])}
		Eval(bFiltraBrw)
	endif
EndIf
oDanfe := Nil
oSetup := Nil

//Limpa arquivos temporarios .rel da pasta MV_RELT
SpedCleRelt()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFeRem³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFeRemessa()

SpedNFeRe2()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFeRe2³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED - utilizada em personalizacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie da NF                                          ³±±
±±³          ³ExpC2: Nota inicial                                         ³±±
±±³          ³ExpC3: Nota final                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFeRe2(cSerie,cNotaIni,cNotaFim,lCTe,lRetorno)

Local aArea       	:= GetArea()
Local aPerg       	:= {}
Local aParam      	:= {Space(If(TamSx3("F2_SERIE")[1] == 14,TamSx3("F2_SDOC")[1],TamSx3("F2_SERIE")[1])),Space(TamSx3("F2_DOC")[1]),Space(TamSx3("F2_DOC")[1]),CtoD(""),CtoD("")}
Local aTexto      	:= {}
Local aXML        	:= {}
local aAutoCfg      := {}
local bCaution      := {|| }
local cMsgCont := ""
local cError	  		:= ""
Local cRetorno    	:= ""
Local cIdEnt      	:= ""
Local cModalidade 	:= ""
Local cAmbiente   	:= ""
Local cVersao     	:= ""
Local cVersaoCTe  	:= ""
Local cVersaoMDFe := ""
Local cVersaoDpec 	:= ""
Local cMonitorSEF 	:= ""
Local cSugestao   	:= ""
Local cConteudo   	:= ""
Local cParNfeRem  	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
Local cURL        	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
//Local cUsaColab   := GetNewPar("MV_SPEDCOL","N")//Usa TC 1.0
Local cUSERNEOG   := GetNewPar("MV_USERCOL","") //Usuario TC 1.0
Local cPASSWORD   := GetNewPar("MV_PASSCOL","") //Senha TC 1.0
Local cCONFALL    := GetNewPar("MV_CONFALL","N")//Confirma recebimento de documentos TC 1.0
Local cDOCSCOL    := GetNewPar("MV_DOCSCOL","0")//Configura tipo de documento via TC 1.0
Local cVersTSS    := ""
local cCaution    := ""
Local nRetCol     := GetNewPar("MV_NRETCOL",10)//Configura o tamanho do lote recebimento via TC 1.0
Local nAmbCTeC    := GetNewPar("MV_AMBICOL",2)//Configura ambiente do documento via TC 1.0
Local nAmbNFeC    := GetNewPar("MV_AMBCTEC",2)//Configura ambiente do documento via TC 1.0
Local dDataDe     := CtoD("  /  /    ")
Local dDataAte    := CtoD("  /  /    ")
Local nX          := 0

Local lOk         := .T.
Local lUsaColab   := .F.
Local lSdoc       := TamSx3("F2_SERIE")[1] == 14

Local oWizard
Local cModel      := "55"

Local lNfeCancEven:= GetNewPar("MV_NFECAEV",.T.)	//-- Cancelamento de NF-e por Evento
local oTBitmap1

Private oWS       := Nil


Default lCTe      := .F.
Default lRetorno  := .F.
If lCTE
	cModel:= "57"
EndIf

if cModel <> "65"
	lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )
endif

If cSerie == Nil
	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfeRem,aPerg,1,aParam[01]),If(lSdoc,TamSx3("F2_SDOC")[1],TamSx3("F2_SERIE")[1]))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfeRem,aPerg,2,aParam[02]),TamSx3("F2_DOC")[1])
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfeRem,aPerg,3,aParam[03]),TamSx3("F2_DOC")[1])
Else
	MV_PAR01 := aParam[01] := cSerie
	MV_PAR02 := aParam[02] := cNotaIni
	MV_PAR03 := aParam[03] := cNotaFim
EndIf

aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.})	//"Nota fiscal final"

If lSdoc
	MV_PAR04 := aParam[04] := ParamLoad(cParNfeRem,aPerg,4,aParam[04])
	MV_PAR05 := aParam[05] := ParamLoad(cParNfeRem,aPerg,5,aParam[05])

	aadd(aPerg,{1,"Dt. Emissão De"	,aParam[04],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"
	aadd(aPerg,{1,"Dt. Emissão Até"	,aParam[05],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"
EndIf

If IsReady(,,,lUsaColab)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt(lUsaColab)

	If !Empty(cIdEnt)
		If lUsaColab

			lOk := ColParValid(Iif(lCte,"CTE","NFE"),@cRetorno)

			if lOk
				lNFeCancEven	:= .T.
				If lCTE
					cAmbiente		:= ColGetPar("MV_AMBCTE","")
					cVersaoCte		:= ColGetPar("MV_VERCTE","")
					cModalidade	:= ColGetPar("MV_MODCTE","")

					cMonitorSEF += "- CTe"+CRLF
					cMonitorSEF += STR0017+cVersaoCte+CRLF	//"Versao do layout: "
				else
					cAmbiente		:= ColGetPar("MV_AMBIENT","")+" - " +ColDescOpcao("MV_AMBIENT", ColGetPar("MV_AMBIENT","") )
					cVersao		:= ColGetPar("MV_VERSAO","")
					cVersaoDpec	:= ColGetPar("MV_VERDPEC","")
					cModalidade	:= ColGetPar("MV_MODALID","")+" - " +ColDescOpcao("MV_MODALID", ColGetPar("MV_MODALID","") )

					cMonitorSEF += "- NFe"+CRLF
					cMonitorSEF += STR0017+cVersao+CRLF	//"Versao do layout: "

				endif

			else
				Aviso("SPED","Execute a funcionalidade Parâmetros, antes de utilizar esta opção!"+CRLF+cRetorno,{STR0114},3) //"Execute a funcionalidade Parâmetros, antes de utilizar esta opção!"
			endif
		else

			//Ambiente
			cAmbiente := getCfgAmbiente(@cError, cIdEnt, cModel)
			lOk := empty(cError)


			//Versao de Release do TSS
			If lOk
				cVersaoTSS := getVersaoTSS(@cError)
				lOk := empty(cError)
			EndIf


			//Cofiguração de  parâmetros(SEFAZ TSS ou TOTVS Colaboracao)
			If lOk .And. cVersaoTSS >= "1.35"
				setCfgParamSped(/*cError*/, /*cIdEnt*/, /*nAMBIENTE*/,/*nMODALIDADE*/, /*cVERSAONFE*/,/*cVERSAONSE*/,;
								 /*cVERSAODPEC*/,/*cVERSAOCTE*/, /*cNFEDISTRDANFE*/,/*cNFEENVEPEC*/,cModel)
			EndIf


			// obtem a Modalidade
			If lOk
				cModalidade    := getCfgModalidade(@cError, cIdEnt, cModel)
				lOk := empty(cError)

			EndIf


			//Obtem a Versao de trabalho da NFe
			If lOk
				cVersao        := getCfgVersao(@cError, cIdEnt, cModel )
				lOk := empty(cError)

			EndIf

			// Obtem a Versao de trabalho da CTe
			If lOk
				cVersaoCTe     := getCfgVersao(@cError, cIdEnt, "57" )
				lOk := empty(cError)

			EndIf

			// Obtem a Versao de trabalho da MDFe
			If lOk .And. findfunction ("getCfgMdfe") .And. nModulo <> 43
				cVersaoMDFe     :=  getCfgMdfe(@cError)[5]
				lOk := empty(cError)

			EndIf
			//Obtem a Versao de trabalho do Dpec NFe
			If lOk
				cVersaoDpec	   := getCfgVerDpec(@cError, cIdEnt)
				lOk := empty(cError)

			EndIf

			//Configura a Versao de trabalho do Epec CTe
			If lOk
				If cModel == "57"
					getCfgEpecCte()
				EndIf
			EndIf


			//Verifica o status na SEFAZ
			If lOk .And. !lUsaColab
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
				lOk := oWS:MONITORSEFAZMODELO()
				If lOk
					aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
					For nX := 1 To Len(aXML)
						// NFC-e tem um metodo de remessa especifico REMESSA3
						If aXML[nX]:cModelo == "65"		//NFC-e
							Loop
						Endif
						Do Case
							Case aXML[nX]:cModelo == "55"
								cMonitorSEF += "- NFe"+CRLF
								cMonitorSEF += STR0017+cVersao+CRLF	//"Versao do layout: "
								If !Empty(aXML[nX]:cSugestao)
									cSugestao += STR0125+"(NFe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
								EndIf

							    //Consulta configuração de contingência automática no TSS
							    if( getCfgAutoCont( "0", cIdEnt, cModel, , , @aAutoCfg ) )

							        if( aAutoCfg[1] == "1")

							            cModalidade :=  getCfgModalidade(cError, cIdEnt, cModel, , .T.)

							            cMsgCont := CRLF + CRLF + space(20) + "Habilitada contingência automática para Modalidade " + getDescMod(aAutoCfg[2])
							            cCaution := CRLF + space(21) + STR0019

		                                bCaution := {|oObj| if(oTBitmap1 == nil, oTBitmap1 := TBitmap():New(02,29,260,184,,"UpdWarning.png",.T.,oObj, {||},,.F.,.F.,,,.F.,,.T.,,.F.), oTBitmap1:refresh()) , .T.}

							        else
							            cCaution := STR0019
							            cMsgCont := STR0020
							            bCaution := {||}
							        endif

							    endif

							Case aXML[nX]:cModelo == "57"
								cMonitorSEF += "- CTe"+CRLF
								cMonitorSEF += STR0017+cVersaoCTe+CRLF	//"Versao do layout: "
								If !Empty(aXML[nX]:cSugestao)
									cSugestao += STR0125+"(CTe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
								EndIf
							Case aXML[nX]:cModelo == "58"
								cMonitorSEF += "- MDFe"+CRLF
								cMonitorSEF += STR0017+cVersaoMDFe+CRLF	//"Versao do layout: "
								If !Empty(aXML[nX]:cSugestao)
									cSugestao += STR0125+"(MDFe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
								EndIf
						EndCase
						cMonitorSEF += Space(6)+STR0129+": "+aXML[nX]:cVersaoMensagem+CRLF //"Versão da mensagem"
						cMonitorSEF += Space(6)+STR0120+": "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF //"Código do Status"
		                cMonitorSEF += Space(6)+STR0121+": "+aXML[nX]:cUFOrigem //"UF Origem"
		                If !Empty(aXML[nX]:cUFResposta)
			                cMonitorSEF += "("+aXML[nX]:cUFResposta+")"+CRLF //"UF Resposta"
			   			Else
			   				cMonitorSEF += CRLF
			   			EndIf
		                If aXML[nX]:nTempoMedioSEF <> Nil
							cMonitorSEF += Space(6)+STR0071+": "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF //"Tempo de espera"
						EndIf
						If !Empty(aXML[nX]:cMotivo)
							cMonitorSEF += Space(6)+STR0123+": "+aXML[nX]:cMotivo+CRLF //"Motivo"
						EndIf
						If !Empty(aXML[nX]:cObservacao)
							cMonitorSEF += Space(6)+STR0124+": "+aXML[nX]:cObservacao+CRLF //"Observação"
						EndIf
					Next nX
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Interface                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((lOk .or. (empty(cError) .and. substr(cModalidade, 1,1) == "2") ) .And. (!lCTe))
			aadd(aTexto,{})
			If lUsaColab
				aTexto[1] := STR0496+" " //"Esta rotina tem como objetivo auxilia-lo na geração do arquivo da Nota Fiscal eletrônica para transmissão via TOTVS Colaboração."
				aTexto[1] += STR0494+CRLF+CRLF //"Neste momento o sistema, está operando com a seguinte configuração: "
				cVersTSS 	:= " TC2.0 "//"Vesão - TSS ou TC2.0"
			Else
				aTexto[1] := STR0013+" " 		//"Esta rotina tem como objetivo auxilia-lo na transmissão da Nota Fiscal eletrônica para o serviço Totvs Services SPED. "
				aTexto[1] += STR0014+CRLF+CRLF //"Neste momento o Totvs Services SPED, está operando com a seguinte configuração: "
				cModalidade    := getCfgModalidade(@cError, cIdEnt, cModel,cModalidade)
				cVersTSS		:= " TSS: " + getVersaoTSS()
			EndIf

			aTexto[1] += STR0015+cAmbiente+CRLF //"Ambiente: "
			aTexto[1] += STR0016+cModalidade+CRLF	//"Modalidade de emissão: "
			aTexto[1] += STR0037+cVersTSS+CRLF	//"Vesão - TSS ou TC2.0"
			If !Empty(cSugestao)
				aTexto[1] += CRLF
				aTexto[1] += cSugestao
				aTexto[1] += CRLF
			EndIf
			aTexto[1] += cMonitorSEF

			aadd(aTexto,{})


			//"Assistente de transmissão da Nota Fiscal Eletrônica - Panel 1"
	 		oWizard := APWizard():New( cCaution,cMsgCont,STR0018,aTexto[1] ,{|| btmCaution(oTBitmap1, .F.) }, {|| .T.},.F., ,  )
 			@ 010,010 GET aTexto[1] MEMO SIZE 280, 125 READONLY PIXEL OF oWizard:oMPanel[1]


			//Mensagem de Notifocação de entrada em contingencia
			eval(bCaution, oWizard:oHeaderTitle)

			CREATE PANEL oWizard  ;
				HEADER STR0018 ;//"Assistente de transmissão da Nota Fiscal Eletrônica"
				MESSAGE ""	;
				BACK {|| btmCaution(oTBitmap1, .T.)} ;
				NEXT {|| ParamSave(cParNfeRem,aPerg,"1"),Processa({|lEnd| cRetorno := SpedNFeTrf(aArea[1],aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,,,aParam[04],aParam[05])}),aTexto[02]:= cRetorno,.T.} ;
				PANEL
		    ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,oWizard:oMPanel[2],cParNfeRem,.T.,.T.)

			CREATE PANEL oWizard  ;
				HEADER STR0018;//"Assistente de configuração da Nota Fiscal Eletrônica"
				MESSAGE "";
				BACK {|| .T.} ;
				FINISH {|| .T.} ;
				PANEL
			@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
			ACTIVATE WIZARD oWizard CENTERED
		ElseIf (lCTe) .And. (lOk)
			SpedNFeTrf(aArea[1],aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersaoCTe,.T., lCTe,,aParam[04],aParam[05])
		else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) + CRLF + cError,{STR0114},3)
		EndIf
		lRetorno := lOk
	Else
			lRetorno := .F.
	EndIf
Else
	If (!lCTe)
		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	Else
		lRetorno := .F.
	EndIf
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFeTrf³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Mensagem de retorno                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela da Mbrowse                           ³±±
±±³          ³ExpC2: Serie                                                ³±±
±±³          ³ExpC3: Nota inicial                                         ³±±
±±³          ³ExpC4: Nota final                                           ³±±
±±³          ³ExpC5: Id da entidade empresarial                           ³±±
±±³          ³ExpC6: Ambiente de emissao da NFe                           ³±±
±±³          ³ExpC7: Modalidade de emissao da NFe                         ³±±
±±³          ³ExpC8: Versa da NFe                                         ³±±
±±³          ³ExpL9: Controle de encerramento                             ³±±
±±³          ³ExpL10: Controle de execucao em Job                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFeTrf(cAlias,cSerie,cNotaIni,cNotaFim,cIDEnt,cAmbiente,cModalidade,cVersao,lEnd,lCte,lAuto,dDataDe,dDataAte,lAutomato)

Local aArea			:= GetArea()
Local aNotas		:= {}
Local aNotasOri		:= {}
Local aRetNotas		:= {}
Local aXml			:= {}
Local aNfCup		:= {{"",CTOD("  /  /  "),"","","","","",""}} // Array com as Notas sobre cupom
Local aMotivoCont	:= {}
Local aInfnota		:= {}
Local aValNFe		:= {}
Local aRetCol		:= {}
Local aErro		    := {}

Local cRetorno		:= ""
Local cAliasSF3		:= "SF3"
Local cAliasSF1		:= "SF1"
Local cWhere		:= ""
Local cErro			:= ""
Local cErroScan  	:= ""
Local cHoraIni		:= Time()
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cNfCup		:= "CF/SERIE:" // Identifica que eh Nf sobre Cup
Local cFsimpFat		:= "F - Simples Faturamento"						// Identifica se é Nf sobre Cupom Nova validação Lj.
Local cModeloNF	:= ""

Local cGrupo		:= FWGrpCompany()		//Retorna o grupo
Local cFil 		    := FWCodFil()			//Retorna o código da filial
Local cAviso		:= ""
Local cMsgErr		:= ""
Local cXmlConEsp	:= ""
Local dDataIni		:= Date()

Local lQuery		:= .F.
Local lRetorno		:= .T.
Local lTMSCTe		:= SuperGetMv( "MV_TMSCTE", .F., .F. )
Local lMvColESP	:= SuperGetMv( "MV_COLESP", .F., .F. )
Local lFISVALNFE	:= ExistBlock("FISVALNFE")
Local lTermScan     := .F.
Local lRetCons		:= .F.
Local lErro			:= .F.
Local lNaoErro		:= .F.
Local lUsaColab   	:= .F.
Local lSdoc       	:= TamSx3("F2_SERIE")[1] == 14
Local cVersaoTSS		:= ""
Local cError    		:= ""

Local nX			:= 0
Local nY			:= 0
Local nNFes			:= 0
Local nXmlSize		:= 0
Local nPosAux		:= 0 // Posicao auxiliar
Local nTemp			:= 0
Local nZ			:= 0
Local nNFtrans		:= 0
Local cCampos 		:= ""
Local cSerId 		:= ""

Local oWs
Local oDoc
Local cErroEsp	:= ""
Local lEspelho	:= .F.

Default lCTe		:= .F.
Default lAuto		:= .F.
Default dDataDe		:= CtoD("")
Default dDataAte	:= CtoD("")
Default lAutomato := .F.

cModeloNF := IIF(lCte,"57","55")
lUsaColab   := UsaColaboracao( IIF(lCte,"2","1") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina caso exista filtro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!lCTe)
	dbSelectArea(cAlias)
	dbClearFilter()
	RetIndex(cAlias)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o array    aInfnota                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aInfnota,cSerie)
aadd(aInfnota,cNotaIni)
aadd(aInfnota,cNotaFim)

If lSdoc .And. !Empty(dDataDe) .And. !Empty(dDataAte)
	aadd(aInfnota,dDataDe)
	aadd(aInfnota,dDataAte)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa parametros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAmbiente   := SubStr(cAmbiente,1,1)
cModalidade := SubStr(cModalidade,1,1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cancela as notas do dia anterior                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto
	SpedNFeCan(cEmpAnt,cFilAnt,cIdEnt,cAmbiente,cModalidade,cVersao,aInfnota,lCTe)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as notas fiscais do dia                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem as informacoes de contigencia                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModalidade$"2,3,5,7" .And. !lUsaColab

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Contingencia SCAN - Quando a serie da NFe for menor que 900-999 ³
	//³	nao realiza transmissao e nao grava nas tabelas do SPED		    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModalidade = "3"
		If Alltrim(SubStr(cSerie,1,3)) < "900"
			lTermScan	:= .T.
			lRetorno	:= .F.
		EndIf
	EndIf

	oWs2 := WsSpedCfgNFe():New()
	oWS2:cUSERTOKEN := "TOTVS"
	oWS2:cID_ENT    := cIdEnt
	oWS2:dDATEINIC  := SToD("  /  /    ")
	oWS2:dDATEFIM   := SToD("  /  /    ")
	oWS2:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS2:GetDateCont()
	If Type("oWS2:oWSGETDATECONTRESULT")=="O" .And. Type("oWS2:oWSGETDATECONTRESULT:OWSGETCONT")=="A" .And. Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)>0
		aAdd(aMotivoCont,AllTrim(oWS2:oWSGETDATECONTRESULT:OWSGETCONT[Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)]:CXMOTIVO))
		aAdd(aMotivoCont,oWS2:oWSGETDATECONTRESULT:OWSGETCONT[Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)]:DDATEINIC)
		aAdd(aMotivoCont,AllTrim(oWS2:oWSGETDATECONTRESULT:OWSGETCONT[Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)]:CTIMEINIC))
	EndIf
EndIf
If (!lCTe) .And. !lTermScan
    If !lAuto
		ProcRegua(Val(cNotaFim)-Val(cNotaIni)+1)
	EndIf

	if(lAuto .and. val(cNotaFim) - val(cNotaIni) > 50 )
		cNotaIni := alltrim(cNotaIni)
		cNotaFim := strzero(val(cNotaIni) + 50, len(cNotaIni))
		cNotaIni := strzero(val(cNotaIni), len(cNotaIni))
	endif
	conout("transmitindo notas de: " + cNotaIni + " a: " + cNotaFim )
	//---------------Tratamento para Transmisso de notas de Entrada sem SF3 --------------------//
	If SF1->(FieldPos("F1_STATUS"))>0
		dbSelectArea("SF1")
		dbSetOrder(1)
		#IFDEF TOP
			cWhere := "%( (SF1.F1_FORMUL='S' And SF1.F1_STATUS='C')) AND"
			cAliasSF1 := GetNextAlias()
			lQuery    := .T.

			If lSdoc
				cCampos += ", SF1.F1_SDOC"
				cSerie := Padr(cSerie,TamSx3("F3_SDOC")[1])

				If !Empty(dDataDe) .And. !Empty(dDataAte)
					cWhere += " SF1.F1_SDOC = '"+ SubStr(cSerie,1,3) + "' AND (SF1.F1_EMISSAO >= '"+ DtoS(dDataDe) + "' AND SF1.F1_EMISSAO <= '"+ DtoS(dDataAte) + "') %"
				Else
					cWhere += " SF1.F1_SDOC = '"+ SubStr(cSerie,1,3) + "'%"
				EndIf

			Else
				cSerie := Padr(cSerie,TamSx3("F3_SERIE")[1])
				cWhere += " SF1.F1_SERIE = '"+ cSerie + "'%"
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos que serao adicionados a query somente se existirem na base³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cCampos)
				cCampos := "%%"
			Else
				cCampos := "% " + cCampos + " %"
			Endif

			BeginSql Alias cAliasSF1

			COLUMN F1_EMISSAO AS DATE

			SELECT	F1_FILIAL,F1_EMISSAO,F1_NFeLETR,F1_FORMUL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_ESPECIE,F1_STATUS
				%Exp:cCampos%
			FROM
				%Table:SF1% SF1
			WHERE
				SF1.F1_FILIAL = %xFilial:SF1% AND
				SF1.F1_DOC >= %Exp:cNotaIni% AND
				SF1.F1_DOC <= %Exp:cNotaFim% AND
				%Exp:cWhere% AND
				SF1.%notdel%
			EndSql
			cWhere := ".T."
		#ELSE
			MsSeek(xFilial("SF1")+cNotaIni+cSerie,.T.)
		#ENDIF
		cWhere := "(F1_FORMUL='S' .And. F1_STATUS='C')"
	EndIf

	If lSdoc
		cSerId := (cAliasSF1)->F1_SDOC
	Else
		cSerId := (cAliasSF1)->F1_SERIE
	EndIf

	While !Eof() .And. xFilial("SF1") == (cAliasSF1)->F1_FILIAL .And.;
		cSerId == cSerie .And.;
		(cAliasSF1)->F1_DOC >= cNotaIni .And.;
		(cAliasSF1)->F1_DOC <= cNotaFim
	    /*
	    +------------------------------------------------------+
		|PONTO DE ENTRADA PARA VALIDAÇÃO DA TRANSMISSAO DA NOTA|
		+------------------------------------------------------+
		*/
		If lFISVALNFE
			aValNFe:={}
			Aadd(aValNFe,"E")
			Aadd(aValNFe,(cAliasSF1)->F1_FILIAL)
			Aadd(aValNFe,(cAliasSF1)->F1_EMISSAO)
			Aadd(aValNFe,(cAliasSF1)->F1_DOC)
			Aadd(aValNFe,(cAliasSF1)->F1_SERIE)
			Aadd(aValNFe,(cAliasSF1)->F1_FORNECE)
			Aadd(aValNFe,(cAliasSF1)->F1_LOJA)
			Aadd(aValNFe,(cAliasSF1)->F1_ESPECIE)
			Aadd(aValNFe,(cAliasSF1)->F1_FORMUL)
			If !ExecBlock("FISVALNFE",.F.,.F.,aValNFe)
				dbSelectArea(cAliasSF1)
				dbSkip()

				If lSdoc
					cSerId := (cAliasSF1)->F1_SDOC
				Else
					cSerId := (cAliasSF1)->F1_SERIE
				EndIf

				Loop
			EndIf
		EndIf

		dbSelectArea(cAliasSF1)
		If ((cAliasSF1)->F1_FORMUL=="S") .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC})==0 .And. (cAliasSF1)->F1_STATUS='C'

		If !lAuto
			IncProc("(1/2) "+STR0022+(cAliasSF1)->F1_DOC) //"Preparando nota: "
		EndIf
			If (AModNot((cAliasSF1)->F1_ESPECIE)$"55,57" .Or. cAmbiente=="2") .And. &cWhere
				aadd(aNotas,{})
				nX := Len(aNotas)
				aadd(aNotas[nX],"0")
				aadd(aNotas[nX],(cAliasSF1)->F1_EMISSAO)
				aadd(aNotas[nX],(cAliasSF1)->F1_SERIE)
				aadd(aNotas[nX],(cAliasSF1)->F1_DOC)
				aadd(aNotas[nX],(cAliasSF1)->F1_FORNECE)
				aadd(aNotas[nX],(cAliasSF1)->F1_LOJA)
				aadd(aNotas[nX],aMotivoCont)
				aadd(aNotas[nX], SF1->F1_CHVNFE)
				If !lAuto
					aadd(aNotasOri,{})
					nX := Len(aNotasOri)

					aadd(aNotasOri[nX],(cAliasSF1)->F1_DOC)
					aadd(aNotasOri[nX],(cAliasSF1)->F1_SERIE)
				EndIf
				If lUsaColab
					aadd(aNotas[nX])		// Sera add o XML do Rdmake NF Entrada
				EndIf
			EndIf
		EndIf
		dbSelectArea(cAliasSF1)
		dbSkip()

		If lSdoc
			cSerId := (cAliasSF1)->F1_SDOC
		Else
			cSerId := (cAliasSF1)->F1_SERIE
		EndIf

	EndDo
	If lQuery
		dbSelectArea(cAliasSF1)
		dbCloseArea()
		dbSelectArea("SF1")
	EndIf

	//-----------------------------------------------------------------//
EndIf
dbSelectArea("SF3")
dbSetOrder(5)
#IFDEF TOP
	lQuery    	:= .T.
	cAliasSF3	:= GetNextAlias()
	cQuery 		:= retQueryTrans( .F., cNotaIni, cNotaFim, cSerie , cModeloNF  )
	cQuery 		:= ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasSF3, .F., .T.)

	TcSetField(cAliasSF3,"F3_ENTRADA","D",08,0)
	TcSetField(cAliasSF3,"F3_DTCANC","D",08,0)
#ELSE
	MsSeek(xFilial("SF3")+cSerie+cNotaIni,.T.)
#ENDIF
cWhere := "((SubStr(F3_CFO,1,1) < '5' .AND. F3_FORMUL='S') .OR. (SubStr(F3_CFO,1,1) >= '5'))"

If lSdoc
	cSerId := (cAliasSF3)->F3_SDOC
Else
	cSerId := (cAliasSF3)->F3_SERIE
EndIf

While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
	cSerId == cSerie .And.;
	(cAliasSF3)->F3_NFISCAL >= cNotaIni .And.;
	(cAliasSF3)->F3_NFISCAL <= cNotaFim
    /*
    +------------------------------------------------------+
	|PONTO DE ENTRADA PARA VALIDAÇÃO DA TRANSMISSAO DA NOTA|
	+------------------------------------------------------+
	*/
	If lFISVALNFE
		aValNFe:={}
		Aadd(aValNFe,IF((cAliasSF3)->F3_CFO < "5","E","S"))
		Aadd(aValNFe,(cAliasSF3)->F3_FILIAL)
		Aadd(aValNFe,(cAliasSF3)->F3_ENTRADA)
		Aadd(aValNFe,(cAliasSF3)->F3_NFISCAL)
		Aadd(aValNFe,(cAliasSF3)->F3_SERIE)
		Aadd(aValNFe,(cAliasSF3)->F3_CLIEFOR)
		Aadd(aValNFe,(cAliasSF3)->F3_LOJA)
		Aadd(aValNFe,(cAliasSF3)->F3_ESPECIE)
		Aadd(aValNFe,(cAliasSF3)->F3_FORMUL)
		If !ExecBlock("FISVALNFE",.F.,.F.,aValNFe)
			dbSelectArea(cAliasSF3)
			dbSkip()

			If lSdoc
				cSerId := (cAliasSF3)->F3_SDOC
			Else
				cSerId := (cAliasSF3)->F3_SERIE
			EndIf

			Loop
		EndIf
	EndIf

	dbSelectArea(cAliasSF3)
	If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL})==0 .And. ;
		( Val( (cAliasSF3)->F3_NFISCAL ) >= Val( cNotaIni ) .And. Val ( (cAliasSF3)->F3_NFISCAL ) <= Val( cNotaFim ) )

		If (!lCTe) .And. !lAuto
			IncProc("(1/2) "+STR0022+(cAliasSF3)->F3_NFISCAL) //"Preparando nota: "
		EndIf

		If (AModNot((cAliasSF3)->F3_ESPECIE)$"55,57" .Or. cAmbiente=="2") .And. Empty((cAliasSF3)->F3_DTCANC);
			.And. &cWhere
			If !AModNot((cAliasSF3)->F3_ESPECIE)$"59,60,65"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de Nota Fiscal sobre cupom (SIGALOJA)³
				//³busca os dados do registro original.         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( cNfCup $ (cAliasSF3)->F3_OBSERV .or. ( cFsimpFat $ (cAliasSF3)->F3_OBSERV ) ) //.AND. !LjAnalisaLeg(53)[1]
					LjVerNfCup(@aNotas		,cAliasSF3,@aNfCup,.T.,;
								aMotivoCont	)
					//Grava doc Original da Transmissão da NF-e
					aadd(aNotasOri,{})
					nX := Len(aNotasOri)

					aadd(aNotasOri[nX],(cAliasSF3)->F3_NFISCAL)
					aadd(aNotasOri[nX],(cAliasSF3)->F3_SERIE)
				Else
					aadd(aNotas,{})
					nX := Len(aNotas)
					aadd(aNotas[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
					aadd(aNotas[nX],(cAliasSF3)->F3_ENTRADA)
					aadd(aNotas[nX],(cAliasSF3)->F3_SERIE)
					aadd(aNotas[nX],(cAliasSF3)->F3_NFISCAL)
					aadd(aNotas[nX],(cAliasSF3)->F3_CLIEFOR)
					aadd(aNotas[nX],(cAliasSF3)->F3_LOJA)
					aadd(aNotas[nX],aMotivoCont)
					
					SF2->( dbSetOrder(1) )
					if( SF2->(MsSeek(xFilial("SF2")+ (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA,.T.)) )
						aadd(aNotas[nX], SF2->F2_CHVNFE)
					endif
					
					If !lAuto
						aadd(aNotasOri,{})
						nX := Len(aNotasOri)
						aadd(aNotasOri[nX],(cAliasSF3)->F3_NFISCAL)
						aadd(aNotasOri[nX],(cAliasSF3)->F3_SERIE)
					EndIf
					If lUsaColab
						aadd(aNotas[nX])		// Sera add o XML do Rdmake NF Saida
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectArea(cAliasSF3)
	dbSkip()

	If lSdoc
		cSerId := (cAliasSF3)->F3_SDOC
	Else
		cSerId := (cAliasSF3)->F3_SERIE
	EndIf

EndDo
If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
	dbSelectArea("SF3")
EndIf
If (!lCTe) .And. !lAuto
	ProcRegua(Len(aNotas))
EndIf

If lAuto
	NfeVldAuto(@aNotas,cAlias)
EndIf

If lUsaColab
	oDoc := ColaboracaoDocumentos():new()
	oDoc:cModelo 	:= IIF(lCTE,"CTE","NFE")
	oDoc:cTipoMov	:= "1"
Else
	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
EndIf
For nX := 1 To Len(aNotas)

	cXmlConEsp	:= ""

	if( len(aNotas[nX]) < 8 )
		aadd(aNotas[nX],"")
	endif
	setDocChv(aNotas[nX][8])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	//³                        Agroindustria                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("OGXUtlOrig") //Encontra a função
		If OGXUtlOrig() // Retorna se tem integração com Agro/originação modulo 67
			If FindFunction("AGRXVALNFE") .AND. !AGRXVALNFE(aNotas[nX][3],aNotas[nX][4], @aErro)
				LOOP //não faz a transmissão da NF
			EndIf
		EndIf
	EndIf

	If lUsaColab

		oDoc:cIdErp	:= aNotas[nX][3]+ aNotas[nX][4]+cGrupo+cFil
		lErro := .F.

		lRetCons := oDoc:consultar()

		If lRetCons
			If !Empty(oDoc:cXMLRet)
				cXml	:= oDoc:cXMLRet
			Else
				cXml	:= oDoc:cXml
			EndIf
			aDados := ColDadosNf(1,IIF(lCTE,"57","55"))
			aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)

			If len(aDadosXml) > 0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Validacao para verificar se a NF ja foi autorizada e nao permitir a retransmissao ³
				//³ OU a NF foi retornada que a operacao esta em contingencia                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  ( ColMsgSefaz(oDoc:cModelo,aDadosXml[1]) .And. !Empty(aDadosXml[3]) ) .OR. ( aDadosXml[1]="1" .And. Empty(aDadosXml[3]) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida se o documento tem Protocolo, caso nao tenha significa que eh Contingencia³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( aDadosXml[3] )
						cMsgErr := ColGetErro(21)[2]
					Else
						cMsgErr := ColGetErro(22)[2]
					EndIf
					lErro := .T.

				ElseIf oDoc:cCdStatDoc == "1"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida se o documento ja foi Enviado	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cMsgErr := ColGetErro(4)[2]
					lErro := .T.
				EndIf

				If lErro
					aAdd( aErro , {} )
					aAdd( aErro[Len(aErro)] , .T. )	         //Tem erro
					aAdd( aErro[Len(aErro)] , aNotas[nX][4] ) 	//NF
					aAdd( aErro[Len(aErro)] , aNotas[nX][3] ) 	//Serie
					aAdd( aErro[Len(aErro)] , cMsgErr ) 		//Motivo
				endif

			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso seja SCAN, e a Serie da NFe for menor que 900-999 nao eh transmitida NFe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTermScan .And. ( !(Len(aErro) > 0) .Or. !lRetCons )
		If (!lCTe) .And. !lAuto
			IncProc("(2/2) "+STR0023+aNotas[nX][4]) //"Transmitindo XML da nota: "
		EndIf

		//-- Parametro do
		If lTMSCTe .And. lCTe
			If ExistBlock("XmlCte3",,.T.)
				aXml := ExecBlock("XmlCte3",.F.,.F.,{aNotas[nX], cAmbiente, cVersao, cModalidade, TZoneUTC(cIdEnt)})
			EndIf
		Else
			If (Empty (aNfCup))
				nTemp := aScan( aNotasOri, { | x | x[1] == aNotas[nX][4] .and. x[2] == aNotas[nX][3] } )
			Else
				nTemp := nX
			EndIf
			if nTemp < 1
				loop
			endif
			If !lAuto
				aXml	:= ExecBlock("XmlNFeSef",.F.,.F.,{aNotas[nX],cVersao,cAmbiente,aNotasOri[nTemp]})
			ElseIf lAuto .and. lUsaColab													 //  nNF			Serie
				aXml	:= ExecBlock("XmlNFeSef",.F.,.F.,{aNotas[nX],cVersao,cAmbiente,{aNotas[nX][4],aNotas[nX][3]}})
			Else
				aXml	:= ExecBlock("XmlNFeSef",.F.,.F.,{aNotas[nX],cVersao,cAmbiente,{"",""}})
			EndIf
		EndIf

		If aXML <> Nil
			nXmlSize2 := Len(aXML[2])

			nPosAux := Ascan( aNfCup,{|x| x[7] == aNotas[nX][3] .AND. x[8] == aNotas[nX][4]})

			If nPosAux > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso encontre alguma Nf sobre cupom volta a numeração³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjVerNfCup(@aNotas[nX], NIL , aNfCup[nPosAux] , .F. )
			EndIf

			If  Len(aXML)==4 .And.!Empty (aXML[3]) .And. !Empty (aXML[4])
				aNotas[nX][4]:= aXML[3]
				aNotas[nX][3]:= aXML[4]
				If ( lUsaColab .And. !Empty (aXML[2]) )
					aNotas[nX][8] := aXML[2]
				EndIf

		   	EndIF

			If !Empty(aXML[2]) .And. nXmlSize2 <= TAMMAXXML
				If nXmlSize + Len(aXML[2]) <= TAMMAXXML
					nY++
					nNFes++
					nXmlSize += Len(aXML[2])
					If lUsaColab			//   ID ERP(Serie+NF+Emp+Fil)      Erro     XML		 Entr/Saida	    Serie				NF				Cliente		   Loja							 Retorno da Transmissao

						lRetorno := XMLRemCol(aXml[4]+aXml[3]+cGrupo+cFil , @cErro , aXml[2] , aNotas[nX][1] , aNotas[nX][3] , aNotas[nX][4] , aNotas[nX][5] , aNotas[nX][6] , @nXmlSize , nY , @aRetCol, @cXmlConEsp)

						If lRetorno .And. lMvColESP
							lEspelho := XmlColEsp(aNotas[nX][4],aNotas[nX][3],aNotas[nX][5],aNotas[nX][6],aXml[4]+aXml[3]+cGrupo+cFil,cXmlConEsp,@cErroEsp)
							If !lEspelho
								cErro += cErroEsp + CRLF + CRLF
							EndIf
						EndIf

					Else
						aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())

						aadd(aRetNotas,aNotas[nX])

						oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cID := aNotas[nX][3]+aNotas[nX][4]
						oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cXML:= aXML[2]
					EndIf
				Else
					If lUsaColab			//   ID ERP(Serie+NF+Emp+Fil)      Erro     XML		 Entr/Saida	    Serie				NF				Cliente		   Loja							 Retorno da Transmissao

						lRetorno := XMLRemCol(aXml[4]+aXml[3]+cGrupo+cFil , @cErro , aXml[2] , aNotas[nX][1] , aNotas[nX][3] , aNotas[nX][4] , aNotas[nX][5] , aNotas[nX][6] , @nXmlSize , nY , @aRetCol, @cXmlConEsp)

						If lRetorno .And. lMvColESP
							lEspelho := XmlColEsp(aNotas[nX][4],aNotas[nX][3],aNotas[nX][5],aNotas[nX][6],aXml[4]+aXml[3]+cGrupo+cFil,cXmlConEsp,@cErroEsp)
							If !lEspelho
								cErro += cErroEsp + CRLF + CRLF
							EndIf
						EndIf
					Else
						lRetorno := XMLRemessa(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL,lAuto,aXml[4]+aXml[3]+cGrupo+cFil)
						If !lRetorno
							Exit
						EndIf
						nX -- //- Diminui o contador para que seja pego a nota corrente
						Loop
					EndIf
				EndIF
			ElseIf !Empty(aXML[2]) .And. nXmlSize2 > TAMMAXXML
				If !lAuto
					Aviso("SPED",STR0149+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+STR0150+aNotas[nX][4]+" / "+aNotas[nX][3],{STR0114},3)
				Else
					If !lAutomato
						Conout("SPED",STR0149+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+STR0150+aNotas[nX][4]+" / "+aNotas[nX][3],{STR0114},3)
					Else
			   			If FindFunction("GetParAuto")
							aRetAuto	 := GetParAuto("AUTONFETestCase")
							aRetAuto[5]:= .F.
							aRetAuto[6]:="SPED "+STR0149+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+STR0150+aNotas[nX][4]+" / "+aNotas[nX][3]
							aRetAuto[7]:=nXmlSize2
							aRetAuto[8]:=TAMMAXXML
						EndIf
						Conout("SPED",STR0149+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+STR0150+aNotas[nX][4]+" / "+aNotas[nX][3],{STR0114},3)
					EndIf
				EndIf
				nXmlSize2 := 0
			EndIf
			If  lMvColESP .And. nNFes > 0 .And. !lUsaColab
				XMLRemessa(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL,lAuto,aXml[4]+aXml[3]+cGrupo+cFil)
			ElseIf ((nY >=50 .Or. nX == Len(aNotas) .Or. nXmlSize>=TAMMAXXML) .And. nNFes > 0) .And. !lUsaColab
				XMLRemessa(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL,lAuto,aXml[4]+aXml[3]+cGrupo+cFil)
			EndIf
		EndIf
	EndIf
Next nX

If lUsaColab

	If ( Len(aErro) > 0 )
		For nZ	:= 1 to Len(aErro)
			If aErro[nZ][1] == .T.	//Retornado .T. no caso tem erro.
				cErro += "NFe:    " + aErro[nZ][2] + CRLF +;
					      "Série:  " + SubStr(aErro[nZ][3],1,3) + CRLF +;
				    	  "Motivo: " + aErro[nZ][4] + CRLF + CRLF
				lErro := .T.
			EndIf
		Next nZ
		nZ	:= 0
	EndIf
	If ( Len(aRetCol) > 0 )
		For nZ := 1 to Len(aRetCol)

			If aRetCol[nZ][1] == .F.	//Retornado .F. no caso tem erro, pois o .T. eh qdo o documento foi processado com sucesso.
				cErro += "NFe:    " + aRetCol[nZ][3] + CRLF +;
					      "Série:  " + SubStr(aRetCol[nZ][2],1,3) + CRLF +;
					      "Motivo: " + aRetCol[nZ][6] + CRLF + CRLF
				lErro := .T.
			Else
				lNaoErro := .T.
				nNFtrans ++
			EndIf
		Next nZ
	EndIf

	If ( lNaoErro .And. lErro )
		cRetorno := STR0491+CRLF 		//"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += STR0492+CRLF+CRLF //"Verifique se os arquivos foram processados e autorizados na SEFAZ via TOTVS Colaboração, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
		cRetorno += STR0028+AllTrim(Str(nNFtrans,18))+STR0029+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
		//Erro na geracao
		cRetorno += "---------------------------------------------------------------------------------------------------------------------------" + CRLF
		cRetorno += STR0490+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += STR0024+CRLF+CRLF 	//"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
	ElseIf lErro
		cRetorno := STR0490+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += STR0024+CRLF+CRLF 	//"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
	Else
		cRetorno := STR0491+CRLF 		//"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += STR0492+CRLF+CRLF //"Verifique se os arquivos foram processados e autorizados na SEFAZ via TOTVS Colaboração, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
		cRetorno += STR0028+AllTrim(Str(nNFtrans,18))+STR0029+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
	EndIf
	lErro := .F.
Else
	If lRetorno
		cRetorno := STR0026+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
		cRetorno += STR0027+CRLF+CRLF //"Verifique se as notas foram autorizadas na SEFAZ, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
		cRetorno += STR0028+AllTrim(Str(nNFes,18))+STR0029+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
	Else
		cRetorno := STR0030+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Contingencia SCAN - Exibe mensagem que nao foi transmitida NFe  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModalidade = "3" .And. !lUsaColab
	cErroScan   := STR0079+": "+ "Série utilizada fora da faixa permitida no Ambiente SCAN (900-999)"
	cErroScan += cErroScan+CRLF+CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibicao do range de NFe nao transmitidas						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aNotas)

		cRetorno += "Segue abaixo a NF-e não transmitida: "  	+CRLF
		cRetorno += STR0249 + ": " + SubStr(aNotas[nX][3],1,3) 	+CRLF 		//"Serie"
		cRetorno += STR0049 + ": " + aNotas[nX][4] 				+CRLF+CRLF //"NF"

	Next nX


Else
	cRetorno += cErro + cErroScan
EndIf


If (!lCTe) .And. !lAuto
	IF VALTYPE(bFiltraBrw) == "B"
		Eval(bFiltraBrw)
	ENDIF
EndIf
RestArea(aArea)

Return(cRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFePar³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Parametriza o  Totvs Services para a nota fiscal eletronica ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFePar( cModel )

Local oWs
Local aPerg  := {}
Local aParam := {"","","",0}
Local aCombo1:= {}
Local aCombo2:= {}
Local aCombo3:= {}
Local aCombo4:= {}
Local aCombo5:= {}
Local aCombo6:= {}
Local aCombo7:= {}
local aCfgEpec:= {}
Local cCombo1:= ""
Local cCombo2:= ""
Local cCombo3:= ""
Local cCombo4:= ""
Local cCombo5:= ""
Local cCombo6:= ""
Local cCombo7:= ""
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
local cError := ""
Local nTempo := 0
Local nX     := 0
Local cParNfePar := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEPAR"
Local cAvisoCont := Space(1000)
Local nOpcCont   := 0
Local lAdminNfe  := GetNewPar("MV_ADMNFE",.T.)
Local lUsaColab	:= .F.
local lPSW		:= .F.
Local cVersaoCTe := ""
Local cVerCTeOS  := ""

Default cModel	 := "55"

If !(cModel $ "65|67")
	cModel := IIf (FunName()$"SPEDCTE,TMSA200,TMSA500,TMSAE70,TMSA050","57","55")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da NFCe para o Loja                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModel == "65"
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
EndIf
//Ambiente
aadd(aCombo1,STR0031) //"1-Produção"
aadd(aCombo1,STR0032) //"2-Homologação"
If cModel == "57" //CT-e
	aadd(aCombo2,STR0033) //"1-Normal"
	aadd(aCombo2,STR0139) //"5-Contingência  EPEC"
	aadd(aCombo2,STR0173) //"7-Contingência FS-DA"
	aadd(aCombo2,STR0457) //"8- Contingencia - SVC-SP"
	aadd(aCombo2,STR0458) //"9- Contingencia - SVC-RS"
ElseIf cModel == "67" //CTeOs
	aadd(aCombo2,STR0033) //"1-Normal"
	aadd(aCombo2,STR0173) //"7-Contingência FS-DA"
	aadd(aCombo2,STR0457) //"8- Contingencia - SVC-SP"
	aadd(aCombo2,STR0458) //"9- Contingencia - SVC-RS"
Else
	aadd(aCombo2,STR0033) //"1-Normal"
	aadd(aCombo2,STR0034) //"2-Contingência off-line"
	aadd(aCombo2,STR0108) //"3-Contingência SCAN"
	aadd(aCombo2,STR0131) //"4-Ambiente Nacional"
	aadd(aCombo2,STR0139) //"5-Contingência DPEC / EPEC"
	aadd(aCombo2,STR0153) //"6-Sefaz Virtual"
	aadd(aCombo2,STR0173) //"7-Contingência FS-DA"

	If cModel == "55"
		aadd(aCombo2,"8-Contingência SVC-AN")
		aadd(aCombo2,"9-Contingência SVC-RS")
	EndIf

	If cModel == "65"
		aadd(aCombo2,"9-Contingencia Off-Line da NFC-e")
	EndIf
Endif

//Versão NFCe
If cModel == "65"
	aadd(aCombo3,"3.00")
	aadd(aCombo3,"3.10")
	aadd(aCombo3,"4.00")
	aadd(aCombo4,"1-Habilitado")
	aadd(aCombo4,"2-Desabilitado")
Else
//Versão NF-E
	aadd(aCombo3,"4.00")
	aadd(aCombo3,"9.99")
//Versão CT-E
	aadd(aCombo4,"2.00")
	aadd(aCombo4,"3.00")
	aadd(aCombo4,"9.99")
//Versão EPEC NFE
	aadd(aCombo5,"1.01")
	aadd(aCombo5,"9.99")
//Versão EPEC CTE
	aadd(aCombo6,"2.00")
	aadd(aCombo6,"3.00")
	aadd(aCombo6,"9.99")
//Versão CTeOS
	aadd(aCombo7,"3.00")
	aadd(aCombo7,"9.99")
Endif

if cModel == "55"
	lUsaColab := UsaColaboracao("1")
elseif cModel == "57"
	lUsaColab := UsaColaboracao("2")
endif


if lUsaColab
	//REALIZA A CONFIGURAÇÃO DOS PARAMETRO DO TOTVS COLABORAÇÃO 3.0
	if ( lAdminNfe .And. PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0 ) .Or. !lAdminNfe
		ColParametros( iif(cModel == "55","NFE","CTE") )
	else
		Help( "", 1, "SEMPERM" )
	endif
else
	lPSW := PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0

	if( !lAdminNfe .or. lPSW)

		If IsReady()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem o codigo da entidade                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cIdEnt := GetIdEnt()


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem o ambiente                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCombo1 := getCfgAmbiente(@cError, cIdEnt, cModel)
			aadd(aPerg,{2,STR0035,cCombo1,aCombo1,120,".T.",.T.,".T."}) //"Ambiente"


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem a modalidade                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCombo2 := PADR(getCfgModalidade(@cError, cIdEnt, cModel),30)
			for nX := 1 to len(aCombo2)
				if (substr(cCombo2,1,1) $ Alltrim (aCombo2[nX]))
				     cCombo2 := Alltrim(aCombo2[nX])
				EXIT
				endif
			next
			aadd(aPerg,{2,STR0036,cCombo2,aCombo2,120,".T.",.T.,".T."}) //"Modalidade"

			If cModel == "67"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtem a versao do CTeOS                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCombo7 := getCfgVersao(@cError, cIdEnt, '67')
				aadd(aPerg,{2,STR0037+" CTeOS",cCombo7,aCombo7,120,".T.",.T.,".T."}) //"Versão CTeOS"
			Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem a versao da NFCe                                           		 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If 	cModel == "65"
					cCombo3 := getCfgVersao(@cError, cIdEnt, cModel)
					aadd(aPerg,{2,STR0037+" NFCe",cCombo3,aCombo3,120,".T.",.T.,".T."}) //"Versão NFCe"
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem a versao do NFe                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCombo3 := getCfgVersao(@cError, cIdEnt, '55')
					aadd(aPerg,{2,STR0037+" NFe",cCombo3,aCombo3,120,".T.",.T.,".T."}) //"Versão NFe"
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento da NFCe para o Loja                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cModel <> "65"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem a versao do CTe                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCombo4 := getCfgVersao(@cError, cIdEnt, '57')
					aadd(aPerg,{2,STR0037+" CTe",cCombo4,aCombo4,120,".T.",.T.,".T."}) //"Versão CTe"


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem a versao do EPEC NFE                                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cModel == "55"
					cCombo5 := getCfgVerDpec(@cError, cIdEnt)
					aadd(aPerg,{2,STR0037+" DPEC",cCombo5,aCombo5,120,".T.",.T.,".T."}) //"Versão EPEC NFE"

					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem a versao do EPEC CTE                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If  cModel == "57"
						aCfgEpec := getCfgEpecCte(@cError, cIdEnt)
						cCombo6 := aCfgEpec[1]
						aadd(aPerg,{2,STR0037+" EPEC",cCombo6,aCombo6,120,".T.",.T.,".T."}) //"Versão EPEC CTE"
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem a contingencia automatica                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCombo4 			:= getCfgContigencia(@cError, cIdEnt, cModel)
					aadd(aPerg,{2,"Contingência Off-Line",cCombo4,aCombo4,120,".T.",.T.,".T."}) //"Contingencia"
				Endif
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem o tempo de espera                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTempo := getCfgEspera(@cError, cIdEnt)
			aadd(aPerg,{1,STR0071,nTempo,"99",".T.","",".T.",30,.F.})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento da NFCe para o Loja                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cModel == "65"
				aParam := {SubStr(cCombo1,1,1),SubStr(cCombo2,1,1),cCombo3,SubStr(cCombo4,1,1),nTempo}
			Else
				If cModel == "57"
					aParam := {SubStr(cCombo1,1,1),SubStr(cCombo2,1,1),cCombo3,cCombo4,cCombo6,nTempo}
				ElseIf cModel == "67"
					aParam := {SubStr(cCombo1,1,1),SubStr(cCombo2,1,1),cCombo7,nTempo}
				Else
					aParam := {SubStr(cCombo1,1,1),SubStr(cCombo2,1,1),cCombo3,cCombo4,cCombo5,nTempo}
				EndIf
			Endif

			cParNfePar += cModel //Complemento o nome do arquivo com o modelo da nota para unificar o arquivo de profile

			If ParamBox(aPerg,"SPED - NFe",aParam,,,,,,,cParNfePar,.T.,.F.)
				lContingencia	:=	Val(aParam[2])==2 .Or. Val(aParam[2])==3 .Or. Val(aParam[2])==5 .Or. Val(aParam[2])==7 .Or. Val(aParam[2])==8 .Or. Val(aParam[2])==9

				If lContingencia .And. Val(cCombo2)<>Val(aParam[2])
					If !(Val(aParam[2])==3)
						while Empty(cAvisoCont) .And. nOpcCont<=1

							if(lAdminNfe .and. lPSW)
								While .T.
									nOpcCont	:=	Aviso("SPED - Motivo da Contingência",@cAvisoCont,{"Confirma","Cancela"},3,,,,.T.)
									If nOpcCont==2
										exit
									ElseIf len(alltrim(cAvisoCont)) >= 15
										exit
									else
										MsgAlert('Informar o motivo da Contingência com mais de 15 caracteres. ')
									endif
								EndDo
							else
								nOpcCont	:=	Aviso("SPED - Motivo da Contingência",@cAvisoCont,{"Confirma","Cancela"},3,,,,.T.)

							endif

						End
						If nOpcCont==2
							//				Aviso("SPED - Motivo da Contingência","A modalidade informada ("+AllTrim(aParam[2])+") não será considerada nas transmissões dos documentos fiscais, pois para que esta modadlidade seja utilizada é necessário se informar o motivo desta alteração, e neste caso não foi informado.",{"Ok"},3)
							Aviso("SPED - Motivo da Contingência","Para a utilização da modalidade ("+AllTrim(aParam[2])+") é obrigatória a descrição do motivo.",{"Ok"},3)
						EndIf
					Else
						Aviso("SPED - Motivo da Contingência SCAN","Contingência SCAN conforme Legislação: NT 2013/007 foi desativada. Verifique qual Contingência disponível para realizar a transmissão do documento.",{"Ok"},3)
					EndIf
				EndIf

				getCfgAmbiente(@cError, cIdEnt, cModel, aParam[1] )

				If (!lContingencia  .Or. (lContingencia .And. nOpcCont==1 .And. !Empty(cAvisoCont)))

					cURL = Padr( GetNewPar("MV_SPEDURL", ""), 250 )
					oWS := WsSpedCfgNFe():New()
					oWS:cUSERTOKEN := "TOTVS"
					oWS:cID_ENT    := cIdEnt
					oWS:nModalidade:= Val(aParam[2])
					oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"

					If cModel $ "65|57|67"
					 	oWS:cModelo	:= cModel
					EndIf

					If cModel $ "57|67"
						//Modalidade Em Contingencia
						getCfgModalidade(@cError, cIdEnt, cModel, aParam[2] )
						oWS:CfgModalidGrv()
					Else
						oWS:CfgModalidGrv()
					Endif
				EndIf

				If cModel == "65"
					//Configura Versao do NFCe
					getCfgVersao(@cError, cIdEnt, cModel, aParam[3])
				ElseIf cModel == "67"
					//Configura Versao do CTeOS
					cVerCTeOS := getCfgVersao(@cError, cIdEnt, "67", aParam[3])
				Else
					//Configura Versao do NFe
					cVersao := getCfgVersao(@cError, cIdEnt, "55", aParam[3])
					//Configura Versao do CTe
					cVersaoCTe := getCfgVersao(@cError, cIdEnt, "57", aParam[4])
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento da NFCe para o Loja                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cModel <> "67"

					If cModel <> "65"

						//Configura Versao Depec
						getCfgVerDpec(@cError, cIdEnt, aParam[5])

					Else
						getCfgContigencia(@cError, cIdEnt, cModel, Left(aParam[4],1) )

					Endif
				EndIf

				If cModel == "65"
					nTempo := aParam[5]
				ElseIf cModel == "67"
					nTempo := aParam[4]
				Else
					nTempo := aParam[6]
				Endif

				getCfgEspera(@cError, cIdEnt, nTempo)

				If (!lContingencia  .Or. (lContingencia .And. nOpcCont==1 .And. !Empty(cAvisoCont)))
					//-- Ct-e ativo.
					If !Empty(cAvisoCont)
						oWS:cUSERTOKEN := "TOTVS"
						oWS:cID_ENT    := cIdEnt
						oWS:nModalidade:= Val(aParam[2])
						oWS:cMotivo    := AllTrim(cAvisoCont)

						oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"

						If cModel $ "65|57|67"
						 	oWS:cModelo	:= cModel
						EndIf

						If cModel $ "57|67"
					   		//Modalidade Em Contingencia
					 		getCfgModalidade(@cError, cIdEnt, cModel, aParam[2] )
					 		oWS:CfgModalidGrv()
					 	Else
							oWS:CfgModalidGrv()
						Endif
					EndIf
				EndIf
				If cModel == "65"
					TSSAtuSX6( aParam )
				EndIf

			EndIf
		Else

			Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

		EndIf
	Elseif(!lPSW)
		Help( "", 1, "SEMPERM" )
	EndIf
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFeSta³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Analisa o Status do Servico da NFe                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFeStatus()

Local oWS
Local oDlg
Local oGet
Local cIdEnt     := ""
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cStatus    := ""
Local cAuditoria := ""
Local aSize      := {}
Local aXML       := {}
Local nX         := 0

If IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt()
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt)
			oWS:= WSNFeSBRA():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
			If oWS:MONITORSEFAZMODELO()
				aSize := MsAdvSize()
				aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
				For nX := 1 To Len(aXML)
					Do Case
						Case aXML[nX]:cModelo == "55"
							cStatus += "- NFe"+CRLF
						Case aXML[nX]:cModelo == "57"
							cStatus += "- CTe"+CRLF
						Case aXML[nX]:cModelo == "58"
							cStatus += "- MDFe"+CRLF
						Case aXML[nX]:cModelo == "65"
							cStatus += "- NFCe"+CRLF
						Case aXML[nX]:cModelo == "67"
							cStatus += "- CTeOs"+CRLF
					EndCase
					cStatus += Space(6)+STR0129+": "+aXML[nX]:cVersaoMensagem+CRLF //"Versão da mensagem"
					cStatus += Space(6)+STR0120+": "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF //"Código do Status"
	                cStatus += Space(6)+STR0121+": "+aXML[nX]:cUFOrigem+CRLF //"UF Origem"
	                If !Empty(aXML[nX]:cUFResposta)
		                cStatus += Space(6)+STR0122+": "+aXML[nX]:cUFResposta+CRLF //"UF Resposta"
		   			EndIf
	                If aXML[nX]:nTempoMedioSEF <> Nil
						cStatus += Space(6)+STR0071+": "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF+CRLF //"Tempo de espera"
					EndIf
					If !Empty(aXML[nX]:cMotivo)
						cStatus += Space(6)+STR0123+": "+aXML[nX]:cMotivo+CRLF+CRLF //"Motivo"
					EndIf
					If !Empty(aXML[nX]:cObservacao)
						cStatus += Space(6)+STR0124+": "+aXML[nX]:cObservacao+CRLF+CRLF //"Observação"
					EndIf
					If !Empty(aXML[nX]:cSugestao)
						cStatus += Space(6)+STR0125+": "+aXML[nX]:cSugestao+CRLF+CRLF //"Sugestão"
					EndIf
					If !Empty(aXML[nX]:cLogAuditoria)
						cAuditoria += aXML[nX]:cLogAuditoria
					EndIf
				Next nX

				DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From 017,000 to (aSize[6]/3),(aSize[5]/2) OF oMainWnd PIXEL
				@ 005,005 GET oGet VAR cStatus OF oDlg SIZE (aSize[3]/2)-005,(aSize[4]/3)-032 PIXEL MULTILINE
				oGet:lReadOnly := .T.
				@ (aSize[4]/3)-022,(aSize[3]/2)-040 BUTTON oBtn1 PROMPT STR0114   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
				@ (aSize[4]/3)-022,(aSize[3]/2)-080 BUTTON oBtn2 PROMPT STR0126   		ACTION (Aviso(STR0126,cAuditoria,{STR0114},3)) OF oDlg PIXEL SIZE 035,011 WHEN !Empty(cAuditoria)//"Detalhes"
				ACTIVATE MSDIALOG oDlg	CENTERED
			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFeCFG³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configura o Totvs Services para a nota fiscal eletronica    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFeCFG( cModel )

Local oWizard
Local oCombo
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cCert     := Space(250)
Local cKey      := Space(250)
Local cModulo   := Space(250)
Local cPassWord := Space(24)
Local cCombo    := ""
Local cSlot     := Space(4)
Local cLabel    := Space(250)
Local cIdHex	:= Space(250)
Local cFunName := FunName() //Retorna o nome do programa em execução a partir do menu do Protheus
Local aTexto    := {}
Local aPerg     := {}
Local aPerg2    := {}
Local aParam    := {}
//Local aParam2   := {}
Local lUsaIdHex := GetNewPar("MV_A3IDHEX",.F.)
Local lUltFunc	:= .T.

Default cModel	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da NFCe para o Loja                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModel == "65"
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

Iif(Alltrim(cFunName) $ "SPEDMANIFE",lUltFunc:=.F.,lUltFunc:=.T.)

aadd(aParam,PadR(SuperGetMv("MV_RELSERV"),250))
If SuperGetMv("MV_RELAUTH",,.F.)
	aadd(aParam,PadR(SuperGetMv("MV_RELACNT",,""),250))
Else
	aadd(aParam,PadR(SuperGetMv("MV_RELFROM",,""),250))
EndIf
aadd(aParam,PadR(SuperGetMv("MV_RELPSW"),250))
aadd(aParam,PadR(SuperGetMv("MV_RELFROM",,""),250))
aadd(aParam,SuperGetMv("MV_RELAUTH",,.F.))
aadd(aParam,PadR("",250))
aadd(aParam,SuperGetMv("MV_RELSSL",,.F.))
aadd(aParam,SuperGetMv("MV_RELTLS",,.F.))
aadd(aParam,.F.) // DANFE por e-mail

aadd(aPerg,{1,STR0085,aParam[1],"",".T.","",".T.",120,.F.})	//"Servidor SMTP"
aadd(aPerg,{1,STR0086,aParam[2],"",".T.","",".T.",120,.F.})	//"Login do e-mail"
aadd(aPerg,{1,STR0087,aParam[3],"",".T.","",".T.",120,.F.})	//"Senha"
aadd(aPerg,{1,STR0090,aParam[4],"",".T.","",".T.",120,.F.})	//"Conta de e-mail"
aadd(aPerg,{4,STR0088,aParam[5],STR0089,040,".T.",.F.})     //"Autenticação"###"Requerida"
aadd(aPerg,{1,STR0128,aParam[6],"",".T.","",".T.",120,.F.})	//"Conta de e-mail de notificação"
aadd(aPerg,{4,STR0182,aParam[7],STR0183,040,".T.",.F.})     //"Utilizar conexão segura?"###"Sim"
aadd(aPerg,{4,STR0412,aParam[8],STR0183,040,".T.",.F.})     //"Utilizar conexão segura TLS?"###"Sim"
aadd(aPerg,{4,STR0413,aParam[9],STR0183,040,".T.",.F.})     //"Enviar DANFE por e-mail?"###"Sim"

//Retirada a configuração do POP pois não é mais utilizado - chamado TTQNKJ
/*aadd(aParam2,PadR(SuperGetMv("MV_RELSERV"),250))
If SuperGetMv("MV_RELAUTH",,.F.)
	aadd(aParam2,PadR(SuperGetMv("MV_RELACNT",,""),250))
Else
	aadd(aParam2,PadR(SuperGetMv("MV_RELFROM",,""),250))
EndIf
aadd(aParam2,PadR(SuperGetMv("MV_RELPSW"),250))
aadd(aParam2,SuperGetMv("MV_RELSSL",,.F.))

aadd(aPerg2,{1,STR0093,aParam2[1],"",".T.","",".T.",120,.F.})	//"Servidor POP"
aadd(aPerg2,{1,STR0086,aParam2[2],"",".T.","",".T.",120,.F.})	//"Login do e-mail"
aadd(aPerg2,{1,STR0087,aParam2[3],"",".T.","",".T.",120,.F.})	//"Senha"
aadd(aPerg2,{4,STR0182,aParam2[4],STR0183,040,".T.",.F.})        //"Utilizar conexão segura?"###"Sim"
*/

If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Interface                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aTexto,{})
	aTexto[1] := STR0038+CRLF //"Esta rotina tem como objetivo ajuda-lo na configuração da integração com o Protheus com o serviço Totvs Services SPED. "
	aTexto[1] += STR0039 //"O primeiro passo é configurar a conexão do Protheus com o serviço."

	aadd(aTexto,{})
	aTexto[2] := STR0040

	DEFINE WIZARD oWizard ;
		TITLE STR0041; //"Assistente de configuração da Nota Fiscal Eletrônica"
		HEADER STR0019; //"Atenção"
		MESSAGE STR0020; //"Siga atentamente os passos para a configuração da nota fiscal eletrônica."
		TEXT aTexto[1] ;
		NEXT {|| .T.} ;
		FINISH {||.T.}

	CREATE PANEL oWizard  ;
		HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
		MESSAGE ""	;
		BACK {|| .F.} ;
		NEXT {|| IsReady(cURL,3,.T.)} ;
		PANEL

	@ 010,010 SAY STR0042 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] //"Informe a URL do servidor Totvs Services"
	@ 025,010 GET cURL SIZE 270,010 PIXEL OF oWizard:oMPanel[2]

	CREATE PANEL oWizard  ;
		HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
		MESSAGE ""	;
		BACK {|| .T.} ;
		NEXT {|| IsCDReady(@oCombo:nAt,@cCert,@cKey,@cPassWord,@cSlot,@cLabel,@cModulo,@cIdHex)} ;
		PANEL

	@ 005,010 SAY STR0095 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o tipo de certificado digital"
	@ 005,105 COMBOBOX oCombo VAR cCombo ITEMS {STR0096,STR0097,STR0132} SIZE 120,010 OF oWizard:oMPanel[3] PIXEL //"Formato Apache(.pem)"###"Formato PFX(.pfx ou .p12)"###"HSM"
	@ 020,010 SAY STR0043 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo do certificado digital"
	@ 030,010 GET cCert SIZE 240,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt <> 3
	TButton():New( 030,250,STR0044,oWizard:oMPanel[3],{||cCert := cGetFile(IIF(oCombo:nAt == 1,STR0045,STR0098),STR0072,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) //"Drive:"###"Arquivos .PEM |*.PEM","Selecione o certificado"
	@ 050,010 SAY STR0046 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo da private key"
	@ 060,010 GET cKey SIZE 240,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 1
	TButton():New( 060,250,STR0044,oWizard:oMPanel[3],{||cKey := cGetFile(STR0045,STR0072,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) // //"Drive:"###"Arquivos .PEM |*.PEM","Selecione o certificado"
	@ 080,010 SAY STR0133 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"Slot do certificado digital"
	@ 080,100 GET cSlot SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3 PICTURE "9999"
	If lUsaIdHex
		@ 095,010 SAY STR0376 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"ID Hex do certificado digital"
		@ 095,100 GET cIdHex SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	Else
		@ 095,010 SAY STR0134 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"Label do certificado digital"
		@ 095,100 GET cLabel SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	EndIF
	@ 110,010 SAY STR0047 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe senha do arquivo digital"
	@ 110,110 GET cPassWord SIZE 060,010 PIXEL OF oWizard:oMPanel[3] PASSWORD
	@ 125,010 SAY STR0135 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo do modulo HSM"
	@ 125,120 GET cModulo SIZE 100,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	//TButton():New( 125,250,STR0044,oWizard:oMPanel[3],{||cKey := cGetFile(STR0136,STR0137,0,"",.T.,GETF_ONLYSERVER),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) // //"Drive:"###"Arquivos .DLL |*.DLL","Selecione o modulo"

    If lUltFunc
		CREATE PANEL oWizard  ;
			HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
			MESSAGE ""	;
			BACK {|| oWizard:SetPanel(2),.T.} ;
			NEXT {|| IsMailReady(1,aParam[1],aParam[2],aParam[3],aParam[4],aParam[5],aParam[6],aParam[7],aParam[8],aParam[9])} ;
			PANEL

		ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,oWizard:oMPanel[4],"SPEDNFESMTP",.T.,.T.)

		//Retirada a configuração do POP pois não é mais utilizado - chamado TTQNKJ
		/*CREATE PANEL oWizard  ;
			HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
			MESSAGE ""	;
			BACK {|| oWizard:SetPanel(2),.T.} ;
			NEXT {|| IsMailReady(2,aParam2[1],aParam2[2],aParam2[3],,,,aParam2[4])} ;
			PANEL

		ParamBox(aPerg2,"SPED - NFe",@aParam2,,,,,,oWizard:oMPanel[5],"SPEDNFEPOP",.T.,.T.)
		*/

		CREATE PANEL oWizard  ;
			HEADER STR0041; //"Assistente de configuração da Nota Fiscal Eletrônica"
			MESSAGE "";
			BACK {|| oWizard:SetPanel(2),.T.} ;
			FINISH {|| lOk := .T.} ;
			PANEL
		@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[5]//alterado panel para 5 pois foi retirado o panel do POP
	Else
		CREATE PANEL oWizard  ;
			HEADER STR0041; //"Assistente de configuração da Nota Fiscal Eletrônica"
			MESSAGE "";
			BACK {|| oWizard:SetPanel(2),.T.} ;
			FINISH {|| lOk := .T.} ;
			PANEL
		@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[4]
	EndIF

	ACTIVATE WIZARD oWizard CENTERED
Else
	Help( "", 1, "SEMPERM" )
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsReady   ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a conexao com a Totvs Sped Services pode ser    ³±±
±±³          ³estabelecida                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: URL do Totvs Services SPED                        OPC³±±
±±³          ³ExpN2: nTipo - 1 = Conexao ; 2 = Certificado             OPC³±±
±±³          ³ExpL3: Exibe help                                        OPC³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTIsReady(cURL,nTipo,lHelp,lUsaColab)
Return(IsReady(cURL,nTipo,lHelp,lUsaColab))

Static Function IsReady(cURL,nTipo,lHelp,lUsaColab)

Local nX       := 0
Local cHelp    := ""
local cError	:= ""
Local oWS
Local lRetorno := .F.
DEFAULT nTipo := 1
DEFAULT lHelp := .F.
DEFAULT lUsaColab := .F.
if !lUsaColab
   If FunName() <> "LOJA701"
   		If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := "MV_SPEDURL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "URL SPED NFe"
			MsUnLock()
			PutMV("MV_SPEDURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Else
		If !Empty(cURL) .And. !PutMV("MV_NFCEURL",cURL)
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := "MV_NFCEURL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "URL de comunicação com TSS"
			MsUnLock()
			PutMV("MV_NFCEURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	EndIf
	//Verifica se o servidor da Totvs esta no ar
	if(isConnTSS(@cError))
		lRetorno := .T.
	Else
		If lHelp
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIf
		lRetorno := .F.
	EndIf


	//Verifica se Há Certificado configurado
	If nTipo <> 1 .And. lRetorno

		if( isCfgReady(, @cError) )
			lRetorno := .T.
		else
			If nTipo == 3
				cHelp := cError

				If lHelp .And. !"003" $ cHelp
					Aviso("SPED",cHelp,{STR0114},3)
					lRetorno := .F.

				EndIf

			Else
				lRetorno := .F.

			EndIf
		endif

	EndIf

	//Verifica Validade do Certificado
	If nTipo == 2 .And. lRetorno
		isValidCert(, @cError)
	EndIf
else
	lRetorno := ColCheckUpd()
	if lHelp .And. !lRetorno .And. !lAuto
		MsgInfo("UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")
	endif
endif

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsCDReady ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o certificado digital foi transferido com suces-³±±
±±³          ³so                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: [1] PEM; [2] PFX                                     ³±±
±±³          ³ExpC2: Certificado digital                                  ³±±
±±³          ³ExpC3: Private Key                                          ³±±
±±³          ³ExpC4: Password                                             ³±±
±±³          ³ExpC5: Slot                                                 ³±±
±±³          ³ExpC6: Label                                                ³±±
±±³          ³ExpC7: Modulo                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function IsCDReady(nTipo,cCert,cKey,cPassWord,cSlot,cLabel,cModulo,cIdHex)

Local oWS
Local cIdEnt   := ""
Local lRetorno := .T.
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)

Default cIdHex := ""

If	FunName() == "LOJA701"
	If !Empty(GetNewPar("MV_NFCEURL",""))
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ((!Empty(cCert) .And. !Empty(cKey) .And. !Empty(cPassWord) .And. nTipo == 1) .Or.;
	(!Empty(cSlot) .And. !Empty(cLabel) .And. !Empty(cPassword) .And. nTipo == 3) .Or.;
	 (!Empty(cSlot) .And. !Empty(cIdHex) .And. !Empty(cPassword) .And. nTipo == 3) .Or.;
	  (!Empty(cCert) .And. !Empty(cPassWord) .And. nTipo == 2)) .Or. !IsReady(,2)

	cIdEnt := AllTrim(GetIdEnt())
	If nTipo <> 3 .And. !File(cCert)
		Aviso("SPED",STR0048,{STR0114},3) //"Arquivo não encontrado"
		lRetorno := .F.
	EndIf
	If nTipo == 1 .And. !File(cKey) .And. lRetorno
		Aviso("SPED",STR0048,{STR0114},3) //"Arquivo não encontrado"
		lRetorno := .F.
	EndIf
	If !Empty(cIdEnt) .And. lRetorno .And. nTipo <> 3
		oWs:= WsSpedCfgNFe():New()
		oWs:cUSERTOKEN   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		oWs:cCertificate := FsLoadTXT(cCert)
		If nTipo == 1
			oWs:cPrivateKey  := FsLoadTXT(cKey)
		EndIf
		oWs:cPASSWORD    := AllTrim(cPassWord)
		oWS:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If IIF(nTipo==1,oWs:CfgCertificate(),oWs:CfgCertificatePFX())
			Aviso("SPED",IIF(nTipo==1,oWS:cCfgCertificateResult,oWS:cCfgCertificatePFXResult),{STR0114},3)
		Else
			lRetorno := .F.
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIf
	EndIf
	If !Empty(cIdEnt) .And. lRetorno .And. nTipo == 3
		oWs:= WsSpedCfgNFe():New()
		oWs:cUSERTOKEN   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		oWs:cSlot        := cSlot
		oWs:cModule      := AllTrim(cModulo)
		oWs:cPASSWORD    := AllTrim(cPassWord)
		If !Empty( cIdHex )
			oWs:cIDHEX      := AllTrim(cIdHex)
			oWs:cLabel      := ""
		Else
			oWs:cIDHEX      := ""
			oWs:cLabel       := cLabel

		EndIf
		If nTipo == 1
			oWs:cPrivateKey  := FsLoadTXT(cKey)
		EndIf
		oWs:cPASSWORD    := AllTrim(cPassWord)
		oWS:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CfgHSM()
			Aviso("SPED",oWS:cCfgHSMResult,{STR0114},3)
		Else
			lRetorno := .F.
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIf
	EndIf
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsMailRead³ Autor ³Eduardo Riera          ³ Data ³18.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a conexao com a Totvs Sped Services pode ser    ³±±
±±³          ³estabelecida - Mail                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tipo de servidor - 1 SMTP ; 2 POP                    ³±±
±±³          ³ExpC2: Servidor                                             ³±±
±±³          ³ExpC3: Login                                                ³±±
±±³          ³ExpC4: Senha                                                ³±±
±±³          ³ExpC5: Conta de envio                                       ³±±
±±³          ³ExpL6: Requer autenticacao                                  ³±±
±±³          ³ExpC7: Email de notificacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsMailReady(nTipo,cServer,cLogin,cSenha,cFrom,lAuth,cAdmin,lSSL,lTLS,lDANFE)

Local oWS
Local lOk      := .F.
Local cIdEnt   := ""
Local cMsg     := ""
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cError   := ""
Local lRetorno := .T.
Local aCFGResult := {}
Local cDanfeEmail := ""

DEFAULT lAuth  := .F.
DEFAULT cLogin := ""
DEFAULT lSSL   := .F.
DEFAULT lTLS   := .F.
DEFAULT lDANFE := .F.


If	FunName() == "LOJA701"
	If !Empty(GetNewPar("MV_NFCEURL",""))
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1
	If (!Empty(AllTrim(cLogin)) .And. !Empty(AllTrim(cSenha)))
		cIdEnt := AllTrim(GetIdEnt())
		If !Empty(AllTrim(cServer))
			If !Empty(cIdEnt)
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN      := "TOTVS"
				oWs:cID_ENT         := cIdEnt
				oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"

				oWs:oWsSMTP                         := SPEDCFGNFE_SMTPSERVER():New()
				oWs:oWsSMTP:cMailServer             := cServer
				oWS:oWsSMTP:cLoginAccount           := cLogin
				oWs:oWsSMTP:cMailPassword           := cSenha
				oWs:oWsSMTP:cMailAccount            := cFrom
				oWs:oWsSMTP:lAuthenticationRequered	:= lAuth
				oWs:oWsSMTP:cMailAdmin              := cAdmin

				If getVersaoTSS() >= "1.14p"
					oWs:oWsSMTP:lSSL := lSSL
				EndIf
				If getVersaoTSS() >= "1.41"
					oWs:OWSSMTP:lTLS 	 := lTLS
				EndIf

				If oWs:CfgSMTPMail()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Configura o envio do .pdf da Danfe mesmo quando não enviado os dados do e-mail ou falha de conexão  	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCFGResult := setCfgparamSped(@cError, cIdEnt, /*nAMBIENTE*/,/*nMODALIDADE*/, /*cVERSAONFE*/,/*cVERSAONSE*/,;
								 /*cVERSAODPEC*/,/*cVERSAOCTE*/,iif( !Empty(cServer),iif(lDANFE, "1", "0")," "),/*cNFEENVEPEC*/)
			    if Len(aCFGResult) >= 16
			    	cDanfeEmail := iif  (aCFGResult[16] == "1","Configuracao para enviar o DANFE por e-mail : .T.","Configuracao para enviar o DANFE por e-mail : .F.")
			    Endif
		//--------------------------------------------------------------------------------------------------------

					Aviso("SPED",oWS:cCfgSMTPMailResult +CRLF+cDanfeEmail,{STR0114},3)
					if !empty(cError)
						lRetorno	:= .T.
						Aviso( "SPED","Houve um erro ao tentar configurar a nota Fiscal Eletrônica: "+cError, {STR0114}, 3 )
					endif
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				EndIf
			EndIf
		Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Configura o envio do .pdf da Danfe mesmo quando não enviado os dados do e-mail ou falha de conexão  	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCFGResult := setCfgparamSped(@cError, cIdEnt, /*nAMBIENTE*/,/*nMODALIDADE*/, /*cVERSAONFE*/,/*cVERSAONSE*/,;
							 /*cVERSAODPEC*/,/*cVERSAOCTE*/,iif( !Empty(cServer),iif(lDANFE, "1", "0")," "),/*cNFEENVEPEC*/)
				if Len(aCFGResult) >= 16
			    	cDanfeEmail := iif  (aCFGResult[16] == "1","Configuracao para enviar o DANFE por e-mail : .T.","Configuracao para enviar o DANFE por e-mail : .F.")
			    Endif
		//--------------------------------------------------------------------------------------------------------
			oWs:= WsSpedCfgNFe():New()
			oWs:cUSERTOKEN      := "TOTVS"
			oWs:cID_ENT         := cIdEnt
			oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"

			If oWs:GetSMTPMail()
				DEFAULT oWS:oWSGETSMTPMAILRESULT:cMailAdmin := ""
				cMsg := STR0092+CRLF+CRLF//"O Servidor de SMTP do Totvs Sped não foi configurado"
				cMsg += STR0085+": "+oWS:oWSGETSMTPMAILRESULT:cMAILSERVER+CRLF
				cMsg += STR0086+": "+oWS:oWSGETSMTPMAILRESULT:cLOGINACCOUNT+CRLF
				cMsg += STR0087+": "+oWS:oWSGETSMTPMAILRESULT:cMAILPASSWORD+CRLF
				cMsg += STR0090+": "+oWS:oWSGETSMTPMAILRESULT:cMAILACCOUNT+CRLF
				cMsg += STR0088+": "+IIF(oWS:oWSGETSMTPMAILRESULT:lAUTHENTICATIONREQUERED,".T.",".F.")+CRLF
				cMsg += STR0128+": "+oWS:oWSGETSMTPMAILRESULT:cMailAdmin+CRLF

				If getVersaoTSS() >= "1.14p"
					cMsg += STR0182+": "+Iif(oWs:oWSGETSMTPMAILRESULT:lSSL, ".T.", ".F.")+CRLF
				EndIf
				If getVersaoTSS() >= "1.41"
					cMsg += STR0412+": "+Iif(oWs:oWSGETSMTPMAILRESULT:lTLS, ".T.", ".F.")+CRLF
				EndIf
				cMsg += cDanfeEmail +CRLF

				Aviso("SPED",cMsg,{STR0114},3)
			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
			EndIf
		EndIf
	EndIf
Else
	//Retirada a configuração do POP pois não é mais utilizado - chamado TTQNKJ
	/*cIdEnt := AllTrim(GetIdEnt())
	If !Empty(AllTrim(cServer))
		If !Empty(cIdEnt)
			oWs:= WsSpedCfgNFe():New()
			oWs:cUSERTOKEN      := "TOTVS"
			oWs:cID_ENT         := cIdEnt
			oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"

			oWs:oWsPOP                         := SPEDCFGNFE_POPSERVER():New()
			oWs:oWsPOP:cMailServer             := cServer
			oWs:oWsPOP:cLoginAccount           := cLogin
			oWs:oWsPOP:cMailPassword           := cSenha

			If getVersaoTSS() >= "1.14p"
				oWs:oWsPOP:lSSL := lSSL
			EndIf

			If oWs:CfgPOPMail()
				Aviso("SPED",oWS:cCfgPOPMailResult,{STR0114},3)
			Else
				lRetorno := .F.
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
			EndIf
		EndIf
	Else
		oWs:= WsSpedCfgNFe():New()
		oWs:cUSERTOKEN      := "TOTVS"
		oWs:cID_ENT         := cIdEnt
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"

		If oWs:GetPOPMail()
			cMsg := STR0094+CRLF+CRLF//"O Servidor de POP do Totvs Sped não foi configurado"
			cMsg += STR0093+": "+oWS:oWSGETPOPMAILRESULT:cMAILSERVER+CRLF
			cMsg += STR0086+": "+oWS:oWSGETPOPMAILRESULT:cLOGINACCOUNT+CRLF
			cMsg += STR0087+": "+oWS:oWSGETPOPMAILRESULT:cMAILPASSWORD+CRLF

			If getVersaoTSS() >= "1.14p"
				cMsg += STR0182+": "+Iif(oWs:oWSGETPOPMAILRESULT:lSSL, ".T.", ".F.")+CRLF
			EndIf

			Aviso("SPED",cMsg,{STR0114},3)
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIf
	EndIf
	*/
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RetIdEnti(lUsaColab)
default lUsaColab	:= UsaColaboracao("1")
Return(GetIdEnt(lUsaColab))
Static Function GetIdEnt(lUsaColab)

local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab

	cIdEnt := getCfgEntidade(@cError)

	if(empty(cIdEnt))
		Aviso("SPED", cError, {STR0114}, 3)

	endif

else
	if !( ColCheckUpd() )
		Aviso("SPED","UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{STR0114},3)
	else
		cIdEnt := "000000"
	endif
endIf

Return(cIdEnt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFe1Mn³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento da NFe - por faixa                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 27/03/09 ³ Adalberto     ³A rotina SpedNFe6Mnt antiga SpedNFe1Mnt,sera³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´chamada tanto pelo fonte SPEDNFE quando pelo³±±
±±³                          ³TMSA200. Quando a rotina eh chamada pelo    ³±±
±±³                          ³SPEDNFE, a funcao recebe internamente os    ³±±
±±³                          ³parametros:cAlias, nReg, nOpc, aStruct e re-³±±
±±³                          ³cebe de forma explicita os parametros:      ³±±
±±³                          ³cSerie,cNotaIni,cNotaFim, lCTe quando chama-³±±
±±³                          ³da pelo TMSA200.                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFe1Mnt( cModel )

Local lCTE:=  IIf (FunName()$"SPEDCTE,TMSA200,TMSAE70,TMSA500",.T.,.F.)
Local lNFCE:= IIf (FunName()$"LOJA701",.T.,.F.)
Default cModel := ""

	SpedNFe6Mnt(,,,lCTE,,cModel)
Return

Function SpedNFe6Mnt(cSerie,cNotaIni,cNotaFim, lCTe, lMDFe, cModel,lTMS, lAutoColab,lExibTela,lUsaColab,lNFCE)

Local cIdEnt   := ""
local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local aPerg    := {}
Local aParam   := {Space(Len(SerieNfId("SF2",2,"F2_SERIE"))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),CtoD(""),CtoD("")}
Local aSize    := {}
Local aObjects := {}
Local aListBox := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
Local lOK        := .F.
Local dDataDe		:= CtoD("")
Local dDataAte	:= CtoD("")
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14

Default cSerie   := ''
Default cNotaIni := ''
Default cNotaFim := ''
Default lCTe     := .F.
Default lMDFe    := .F.
Default cModel	 := ""
default lTMS     := .F.
Default lAutoColab := .F.
Default lExibTela := .F. // Não exibe se Falso
Default lUsaColab := .F.
Default lNFCE	:= IIf (FunName()$"LOJA701",.T.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da NFCe para o Loja                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModel == "65"
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
EndIf

lUsaColab := UsaColaboracao( IIF(lCte,"2",IIF(lMDFe,"5",IIF(lNFCE,,"1"))))
if lUsacolab .And. Empty(cModel)
	cModel := Iif(lCte,"57",iif(lMDFe,"58","55"))
endif

If !lAutoColab
aadd(aPerg,{1,Iif(lMDFe,STR0249,STR0010),aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,Iif(lMDFe,STR0459,STR0011),aParam[02],"",".T.","",".T.",30,.T.}) //"Nota fiscal inicial"
aadd(aPerg,{1,Iif(lMDFe,STR0460,STR0012),aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])
EndIF

If lSdoc
	aadd(aPerg,{1,"Dt. Emissão De"	,aParam[04],"@R 99/99/9999",".T.","",".T.",50,.F.}) 			//"Data de Emissão"
	aadd(aPerg,{1,"Dt. Emissão Até"	,aParam[05],"@R 99/99/9999",".T.","",".T.",50,.F.}) 			//"Data de Emissão"

	dDataDe := aParam[04] := ParamLoad(cParNfeRem,aPerg,4,aParam[04])
	dDataAte := aParam[05] := ParamLoad(cParNfeRem,aPerg,5,aParam[05])
EndIf

If IsReady( ,,,lUsaColab )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt( lUsaColab )
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt)
			If lAutoColab
				aParam[01] := cSerie
				aParam[02] := cNotaIni
				aParam[03] := cNotaFim
				lOK        := .T.
			Else
			If (lCTe) .And. !Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim)
				aParam[01] := cSerie
				aParam[02] := cNotaIni
				aParam[03] := cNotaFim
				lOK        := .T.
			ElseIf (lMDFe) .And. !Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim)
				aParam[01] := cSerie
				aParam[02] := cNotaIni
				aParam[03] := cNotaFim
				lOK        := .T.
			Else
					IF (lExibTela)
						aParam[01] := cSerie
						aParam[02] := cNotaIni
						aParam[03] := cNotaFim
						lOK        := .T.
					Else
				lOK        := ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,cParNfeRem,.T.,.T.)
				cSerie   := aParam[01]
				cNotaIni := aParam[02]
				cNotaFim := aParam[03]
					EndIF
			EndIf

			If lSdoc
				dDataDe  := aParam[04]
				dDataAte := aParam[05]
				GetFiltroF3(@aParam,,dDataDe,dDataAte)
			EndIF
			EndIF
			If (lOK)
				If lMDFe .And. !lUsaColab
					aListBox := WsMDFeMnt(cIdEnt,cSerie,cNotaIni,cNotaFim,.T.)
				Else
					aListBox := getListBox(cIdEnt, cUrl, aParam, 1, cModel, lCte, .T., lMDFe, lTMS,lUsaColab)
				EndIf
				If !Empty(aListBox) .And. !lAutoColab
					aSize := MsAdvSize()
					aObjects := {}
					AAdd( aObjects, { 100, 100, .t., .t. } )
					AAdd( aObjects, { 100, 015, .t., .f. } )

					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )

					DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

					If Len(aListBox[1]) >= 10
						@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "",STR0049,STR0035,STR0036,STR0050,STR0051,STR0052,STR0053, "Tentativas", "Observacao"; //"NF"###"Ambiente"###"Modalidade"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"Tempo SEF"
							SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					Else
						@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "",STR0049,STR0035,STR0036,STR0050,STR0051,STR0052,STR0053; //"NF"###"Ambiente"###"Modalidade"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"Tempo SEF"
							SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					EndIf		
					oListBox:SetArray( aListBox )
					If Len(aListBox[1]) >= 10
						oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ],aListBox[ oListBox:nAT,6 ],aListBox[ oListBox:nAT,7 ],aListBox[ oListBox:nAT,8 ],aListBox[ oListBox:nAT,10 ],aListBox[ oListBox:nAT,11 ] } }
					Else
						oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ],aListBox[ oListBox:nAT,6 ],aListBox[ oListBox:nAT,7 ],aListBox[ oListBox:nAT,8 ] } }
					EndIf	

					@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT STR0114   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
					@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT STR0054   		ACTION (Bt2NFeMnt(aListBox[oListBox:nAT][09])) OF oDlg PIXEL SIZE 035,011 //"Mensagens"
					@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT STR0055   		ACTION (Bt3NFeMnt(cIdEnt,aListBox[ oListBox:nAT,2 ],,lUsaColab,cModel)) OF oDlg PIXEL SIZE 035,011 //"Rec.XML"
					If lMDFe .And. !lUsaColab
						@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT STR0118 	ACTION (aListBox := WsMDFeMnt(cIdEnt,cSerie,cNotaIni,cNotaFim,.T.),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					Else
						@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT STR0118 	ACTION (aListBox := getListBox(cIdEnt, cUrl, aParam, 1, cModel, lCte, .T., lMDfe, lTMS,lUsaColab),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					EndIf
					@ aPosObj[2,1],aPosObj[2,4]-200 BUTTON oBtn4 PROMPT STR0115  		ACTION (Bt3NFeMnt(cIdEnt,aListBox[ oListBox:nAT,2 ],2,lUsaColab,cModel)) OF oDlg PIXEL SIZE 035,011 //"Schema"
					ACTIVATE MSDIALOG oDlg
				EndIf
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

//Foi colocada outra vez a funcao WsNFeMnt, enquanto o projeto autonfe nao esta terminado pois isso utilizar a funcao getListBox
Static Function WsNFeMnt(cIdEnt,nModelo,aParam,lCTe,lMsg,cModel)

Local aListBox	:= {}
Local aMsg		:= {}
Local aXML		:= {}
Local aNotas	:= {}

Local nX		:= 0
Local nY		:= 0
Local nSX3SF2	:= TamSx3("F2_DOC")[1]
Local nLastXml	:= 0
Local nSFTIndex	:= 0
Local nSFTRecno	:= 0
Local nSF3Index	:= 0
Local nSF3Recno	:= 0

Local lOk		:= .T.
Local lUsaColab := .F.

Local oOk		:= LoadBitMap(GetResources(), "ENABLE")
Local oNo		:= LoadBitMap(GetResources(), "DISABLE")
Local oWS
Local oRetorno

Local 	cTextInut	:= GetNewPar("MV_TXTINUT","")
Local 	cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local 	lCTECan	:= GetNewPar( "MV_CTECAN", .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
Local 	cModalidade:= ""
Local 	cChaveF3	:= ""
Local 	cChaveFT	:= ""
Local 	cTipoMov	:= ""
Local 	cSerChv	:= ""
Local	cNfChv		:= ""
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
Local cMV_INTTAF  	:= GetNewPar( 'MV_INTTAF', 'N' ) //Verifica se o parâmetro da integração online esta como 'S'
Local lTafKey     	:= SFT->( ColumnPos( 'FT_TAFKEY' ) ) > 0
Local lIntegTaf   	:= ( cMV_INTTAF == 'S' .and. lTafKey )
Local lTAFVldAmb	:= ExistFunc( 'TAFVldAmb' ) .And. TAFVldAmb( '1' ) .And. ExistFunc( 'DocFisxTAF' ) //Valida se o cliente habilitou a integração nativa Protheus x TAF

Private 	oXml
Default 	lCTe   := .F.
Default	lMsg   := .T.
Default 	cModel := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da NFCe para o Loja                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModel == "65"
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif
If cModel <> "65"
	lUsaColab	:= UsaColaboracao( IIF(lCte,"2","1") )
EndIf

if lUsaColab
	Aviso("SPED","Para utilização do TOTVS Colaboração atualizar o AutoNFseBusiness.",{STR0114},3)
else
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN    := "TOTVS"
	oWS:cID_ENT       := cIdEnt
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

	If cModel == "65"
		oWS:cModelo   := cModel
	Endif

	If nModelo == 1
		oWS:cIdInicial    := aParam[01]+aParam[02]
		oWS:cIdFinal      := aParam[01]+aParam[03]
		lOk := oWS:MONITORFAIXA()
		oRetorno := oWS:oWsMonitorFaixaResult
	Else
		If VALTYPE(aParam[01]) == "N"
			oWS:nIntervalo := Max((aParam[01]),60)
		Else
			oWS:nIntervalo := Max(Val(aParam[01]),60)
		EndIf
		lOk := oWS:MONITORTEMPO()
		oRetorno := oWS:oWsMonitorTempoResult
	EndIf
endif
If lOk
	dbSelectArea("SF3")
	dbSetOrder(5)
    For nX := 1 To Len(oRetorno:oWSMONITORNFE)
  		aMsg := {}
 		oXml := oRetorno:oWSMONITORNFE[nX]
 		If Type("oXml:OWSERRO:OWSLOTENFE")<>"U"
			nLastRet := Len(oXml:OWSERRO:OWSLOTENFE)
	 		For nY := 1 To Len(	oXml:OWSERRO:OWSLOTENFE)
 				If oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE<>0
	 				aadd(aMsg,{oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE,oXml:OWSERRO:OWSLOTENFE[nY]:DDATALOTE,oXml:OWSERRO:OWSLOTENFE[nY]:CHORALOTE,;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:NRECIBOSEFAZ,;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:CCODENVLOTE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGENVLOTE,50),;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETRECIBO,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETRECIBO,50),;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE,50)})
				EndIf
				SF3->(dbSetOrder(5))
				If SF3->(MsSeek(xFilial("SF3")+oXml:Cid,.T.))
					nSFTRecno:= SFT->(RECNO())
					nSFTIndex:= SFT->(IndexOrd())
					While !SF3->(Eof()) .And. AllTrim(SF3->(F3_SERIE+F3_NFISCAL))==oXml:Cid
						If SF3->( (Left(F3_CFO,1)>="5" .Or. (Left(F3_CFO,1)<"5" .And. F3_FORMUL=="S")) .And. FieldPos("F3_CODRSEF")<>0)
							RecLock("SF3")
							SF3->F3_CODRSEF:= oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
							//SE FOR UMA NOTA DENEGADA, INFORMA NO CAMPO F3_OBSERV
							If oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE $ RetCodDene()
								SF3->F3_OBSERV := "NF DENEGADA"
							EndIf
						    //SE FOR INUTILIZAÇÃO ALTERA NOS LIVROS FISCAIS
							If !Empty(cTextInut)
							    If Type("oXml:OWSERRO:OWSLOTENFE["+AllTrim(Str(nY))+"]:CMSGRETNFE")<>"U" .And. ("Inutilizacao de numero homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE .Or. "Inutilização de número homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE)
									SF3->F3_OBSERV := ALLTRIM(cTextInut)
								EndIf
							EndIF

							If SF3->F3_FORMUL == "S"
								cTipoMov :=	"E"
							Else
								cTipoMov := "S"
							EndIf

							SFT->(dbSetOrder(1))
							If SFT->(Dbseek(xFilial("SFT")+cTipoMov+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA))
								RecLock("SFT")
								If !Empty(cTextInut)
							    	If Type("oXml:OWSERRO:OWSLOTENFE["+AllTrim(Str(nY))+"]:CMSGRETNFE")<>"U" .And. ("Inutilizacao de numero homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE .Or. "Inutilização de número homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE)
										SFT->FT_OBSERV := ALLTRIM(cTextInut)
									EndIf
								EndIF
							EndIf
							MsUnlock()

							//-- Exclusao CTE somente apos envio e autorizacao da SEFAZ
							If lCTE .And. lCTECan .And. !Empty(SF3->F3_DTCANC)
								DT6->(dbSetOrder(1))
								If	DT6->(MsSeek(xFilial('DT6')+cFilAnt+PadR(SF3->F3_NFISCAL,Len(DT6->DT6_DOC))+SF3->F3_SERIE)) .And. DT6->DT6_STATUS$"B/D"
									RecLock('DT6',.F.)
									If SF3->F3_CODRSEF == '101'
										DT6->DT6_STATUS := 'C'  //Cancelamento SEFAZ Autorizado
									Else
										DT6->DT6_STATUS := 'D'  //Cancelamento SEFAZ Nao Autorizado
									EndIf
									MsUnLock()
								EndIf
							EndIf

						EndIf
						SF3->(dbSkip())
					End
					SFT->(DBSETORDER(nSFTIndex))
					SFT->(DBGOTO(nSFTRecno))
				EndIf

				If ExistBlock("FISMNTNFE")
    				ExecBlock("FISMNTNFE",.f.,.f.,{oXml:Cid,aMsg})
         		Endif

			Next nY

		   	SF3->(DbSetOrder(5))
			If SF3->(MsSeek(xFilial("SF3")+oXml:Cid,.T.))
				nSF3Recno:= SF3->(RECNO())
				nSF3Index:= SF3->(IndexOrd())
				While !SF3->(Eof()) .And. AllTrim(SF3->(F3_SERIE+F3_NFISCAL))==oXml:Cid
					If (SubStr(SF3->F3_CFO,1,1)>="5" .Or. SF3->F3_FORMUL=="S")
						aNotas 	:= {}
						aXml2	:= {}
						aadd(aNotas,{})
						aadd(Atail(aNotas),.F.)
						aadd(Atail(aNotas),IIF(SF3->F3_CFO<"5","E","S"))
						aadd(Atail(aNotas),SF3->F3_ENTRADA)
						aadd(Atail(aNotas),SF3->F3_SERIE)
						aadd(Atail(aNotas),SF3->F3_NFISCAL)
						aadd(Atail(aNotas),SF3->F3_CLIEFOR)
						aadd(Atail(aNotas),SF3->F3_LOJA)
						aXml2 := GetXMLNFE(cIdEnt,aNotas,@cModalidade,Iif(lCTE,"57",""))

						If ( Len(aXml2) > 0 )
							aAdd(aXml,aXml2[1])
						EndIf

						nLastXml := Len(aXml)
					Else
						nLastXml:= Len(aXml)
					EndIf
						SF3->(dbSkip())
				End
				SF3->(DBSETORDER(nSF3Index))
				SF3->(DBGOTO(nSF3Recno))
			EndIf

			//Nota de saida
			dbSelectArea("SF2")
			dbSetOrder(1)

			cSerChv 	:= If (lSdoc,SUBSTR(oXml:Cid,1,14),SUBSTR(oXml:Cid,1,3))
			cNfChv  	:= If(lSdoc,PadR(SUBSTR(oXml:Cid,15,Len(oXml:Cid)),nSX3SF2),PadR(SUBSTR(oXml:Cid,4,Len(oXml:Cid)),nSX3SF2))

			If SF2->(MsSeek(xFilial("SF2")+cNfChv+cSerChv,.T.)) .And. nLastXml > 0 .And. !Empty(aXml)
				If (SF2->(FieldPos("F2_HAUTNFE"))<>0 .And. SF2->(FieldPos("F2_DAUTNFE"))<>0) .And. (Empty(SF2->F2_HAUTNFE) .Or. Empty(SF2->F2_DAUTNFE) .Or. (SF2->(FieldPos("F2_CHVNFE"))>0 .And. Empty(SF2->F2_CHVNFE)))
					RecLock("SF2")
					//SF2->F2_HORA 	:= SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF2->F2_NFELETR := SUBSTR(oXml:Cid,4,9)
					//SF2->F2_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
					//SF2->F2_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF2->F2_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
					SF2->F2_HAUTNFE := IIF(!Empty(aXML[nLastXML][6]),SUBSTR(aXML[nLastXML][6],1,5),"")      //Grava a hora de autorização da nota
					SF2->F2_DAUTNFE	:= IIF(!Empty(aXML[nLastXML][7]),aXML[nLastXML][7],SToD("  /  /    "))  //Grava a data de autorização da nota
					If !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. !oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ "100,101,102,124,"+ RetCodDene() 	//Se o retorno for uma rejeição, grava o F2_FIMP como N e a legenda fica como Não Autorizada(preto) (124 = Autorização DPEC)
						SF2->F2_FIMP := "N"
					ElseIf !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() 					// Atualizar a Leganda para Nf-e denegada
						SF2->F2_FIMP := "D"
					EndIf

					MsUnlock()
				EndIf

				If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. ( !Empty(aXml[nLastXml][1]) .OR. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() )// Inserida verificação do protocolo , antes de gravar a Chave. Para nota denegada deve gravar a chave
					RecLock("SF2")
					SF2->F2_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					MsUnlock()

					//Função para gravação de campos da Nota no modulo Controle de Lojas com Legislação PAF-ECF
					If ExistFunc("STFMMd5NS")
						STFMMd5NS()
					EndIf

					// Grava quando a nota for Transferencia entre filiais
					IF SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
				       SF1->(dbSetOrder(1))
				    	If SF1->(MsSeek(SF2->F2_FILDEST+SF2->F2_DOC+SF2->f2_SERIE+SF2->F2_FORDES+SF2->F2_LOJADES+SF2->F2_FORMDES))
				    		If EMPTY(SF1->F1_CHVNFE)
					    		RecLock("SF1",.F.)
					    		SF1->F1_CHVNFE := SF2->F2_CHVNFE
					    		MsUnlock()
					    	EndIf
				    	Endif
				    EndiF
				EndIf

			  	//Atualizo SF3
				SF3->(dbSetOrder(4))
				cChave := xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE
				If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,.T.))
					Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
						RecLock("SF3",.F.)
						//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() )  // Inserida verificação do protocolo, antes de gravar a Chave. Para nota denegada deve gravar a chave.
							SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()
				    SF3->(dbSkip())
				    EndDo
				EndIf
				//Atualizo SF3
				// Grava quando a nota for Transferencia entre filiais
				IF SF1->(!EOF()) .And. SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
					SF3->(dbSetOrder(4))
					cChave := SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
					If SF3->(MsSeek(SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.))
						Do While cChave == SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
							RecLock("SF3",.F.)
							//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
							//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
							//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
							//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() ) // Inserida verificação do protocolo, antes de gravar a Chave. Para nota denegada deve gravar a chave.
								If EMPTY(SF3->F3_CHVNFE)
									SF3->F3_CHVNFE  := SF2->F2_CHVNFE
								EndIf
							EndIf
							MsUnLock()
					    SF3->(dbSkip())
					    EndDo
					EndIf
				 EndIf

			  	//Atualizo SFT
			  	SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
				If SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))
					Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
						RecLock("SFT",.F.)
						//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SFT->FT_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() ) // Inserida verificação do protocolo, antes de gravar a Chave.
							SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()

						//-----------------------------------------------------------------------------------------
						//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
						//-----------------------------------------------------------------------------------------
						If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
							FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
						EndIf

						SFT->(dbSkip())
			    	EndDo
				EndIf

			  	//Atualizo SFT
				// Grava quando a nota for Transferencia entre filiais
				IF SF1->(!EOF()) .And. SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
				  	SFT->(dbSetOrder(1))
					cChave := SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
					If SFT->(MsSeek(SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
						Do While cChave == SFT->FT_FILIAL+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
							RecLock("SFT",.F.)
							//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
							//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
							//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
							//SFT->FT_CODNFE	:=IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() ) // Inserida verificação do protocolo, antes de gravar a Chave.
								If EMPTY(SFT->FT_CHVNFE)
									SFT->FT_CHVNFE  := SF2->F2_CHVNFE
								Endif
							EndIf
							MsUnLock()

							//-----------------------------------------------------------------------------------------
							//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
							//-----------------------------------------------------------------------------------------
							If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
								FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
							EndIf

							SFT->(dbSkip())
				    	EndDo
					EndIf
				EndIf
			ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)>="5" //Alimenta Chave da NFe Cancelada na F3/FT ao consultar o monitorfaixa
				SF3->(dbSetOrder(4))
				cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
				cChaveFT := xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
				SF3->(dbSeek(cChaveF3,.T.))
				While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
					RecLock("SF3",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene()) // Inserida verificação do protocolo, antes de gravar a Chave.
						SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()
				    SF3->(dbSkip())
			    EndDo

   				SFT->(dbSetOrder(1))
				SFT->(dbSeek(cChaveFT,.T.))
				While !SFT->(Eof()) .And. xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
					RecLock("SFT",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene()) // Inserida verificação do protocolo, antes de gravar a Chave.
						SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()

					//-----------------------------------------------------------------------------------------
					//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
					//-----------------------------------------------------------------------------------------
					If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
						FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
					EndIf

					SFT->(dbSkip())
		    	EndDo
			EndIf

			//Nota de entrada
			dbSelectArea("SF1")
			dbSetOrder(1)

			cSerChv 	:= If (lSdoc,SUBSTR(oXml:Cid,1,14),SUBSTR(oXml:Cid,1,3))
			cNfChv  	:= If(lSdoc,PadR(SUBSTR(oXml:Cid,15,Len(oXml:Cid)),nSX3SF2),PadR(SUBSTR(oXml:Cid,4,Len(oXml:Cid)),nSX3SF2))

			If SF1->(MsSeek(xFilial("SF1")+cNfChv+cSerChv,.T.)) //.And. nLastXml > 0 .And. !Empty(aXml)

					aNotas 	:= {}
					aXml2	:= {}
					aadd(aNotas,{})
					aadd(Atail(aNotas),.F.)
					aadd(Atail(aNotas),"E")
					aadd(Atail(aNotas),SF1->F1_EMISSAO)
					aadd(Atail(aNotas),SF1->F1_SERIE)
					aadd(Atail(aNotas),SF1->F1_DOC)
					aadd(Atail(aNotas),SF1->F1_FORNECEDOR)
					aadd(Atail(aNotas),SF1->F1_LOJA)
					aXml2 := GetXMLNFE(cIdEnt,aNotas,@cModalidade,Iif(lCTE,"57",""))

					If ( Len(aXml2) > 0 )
						aAdd(aXml,aXml2[1])
					EndIf

					nLastXml := Len(aXml)

				//If SF1->(FieldPos("F1_HORA"))<>0 .And. (Empty(SF1->F1_HORA) .OR. Empty(SF1->F1_NFELETR) .Or. Empty(SF1->F1_EMINFE) .Or.Empty(SF1->F1_HORNFE) .Or. Empty(SF1->F1_CODNFE) .Or. (SF1->(FieldPos("F1_CHVNFE"))>0 .And. Empty(SF1->F1_CHVNFE)))
				If (SF1->(FieldPos("F1_HAUTNFE")) <> 0 .And. SF1->(FieldPos("F1_DAUTNFE")) <> 0) .And. (Empty(SF1->F1_HAUTNFE) .Or. Empty(SF1->F1_DAUTNFE) .Or. (SF1->(FieldPos("F1_CHVNFE")) > 0 .And. Empty(SF1->F1_CHVNFE))) .and. len(axml) > 0
					RecLock("SF1")
		   			//SF1->F1_HORA	:= SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF1->F1_NFELETR := SUBSTR(oXml:Cid,4,9)
					//SF1->F1_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
					//SF1->F1_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF1->F1_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
					SF1->F1_HAUTNFE := IIF(!Empty(aXML[nLastXML][6]),SUBSTR(aXML[nLastXML][6],1,5),"")      //Grava a hora de autorização da nota
					SF1->F1_DAUTNFE	:= IIF(!Empty(aXML[nLastXML][7]),aXML[nLastXML][7],SToD("  /  /    "))  //Grava a data de autorização da nota
					If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
					    If (SF1->F1_FORMUL == "S") // So grava a a chave da nota se for formulerio prorpio igual a SIM
						   		SF1->F1_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIF
					EndIf
					If !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. !oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ "100,101,102,124,"+RetCodDene() 	 //Se o retorno for uma rejeição, grava o F2_FIMP como N e a legenda fica como Não Autorizada(preto) (124 = Autorização DPEC)
						SF1->F1_FIMP := "N"
					ElseIf !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene()  					// Atualizar a Leganda para Nf-e denegada
						SF1->F1_FIMP := "D"
					EndIf
					MsUnlock()
				EndIf

				//Atualizo SF3
				SF3->(dbSetOrder(4))
				cChave := xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
				If SF3->(MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.))
					Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
						RecLock("SF3",.F.)
						//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
							If (SF3->F3_FORMUL == "S")
								SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						    Endif
						EndIf
						MsUnLock()
				    SF3->(dbSkip())
				    EndDo
				EndIf

			  	//Atualizo SFT
			  	SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
				If SFT->(MsSeek(xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
					Do While cChave == xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
						RecLock("SFT",.F.)
						//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SFT->FT_CODNFE	:=IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
							If (SFT->FT_FORMUL == "S")
								SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
							Endif
						EndIf
						MsUnLock()

						//-----------------------------------------------------------------------------------------
						//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
						//-----------------------------------------------------------------------------------------
						If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
							FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
						EndIf

						SFT->(dbSkip())
			    	EndDo
				EndIf
			ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)<"5" //Alimenta Chave da NFe Cancelada na F3/FT  ao consultar o monitorfaixa
				SF3->(dbSetOrder(4))
				cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
				cChaveFT := xFilial("SFT")+"E"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
				SF3->(dbSeek(cChaveF3,.T.))
				While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
					RecLock("SF3",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
						SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()
				    SF3->(dbSkip())
			    EndDo

   				SFT->(dbSetOrder(1))
				SFT->(dbSeek(cChaveFT,.T.))
				While !SFT->(Eof()) .And. xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
					RecLock("SFT",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificação do protocolo, antes de gravar a Chave.
						SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()

					//-----------------------------------------------------------------------------------------
					//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
					//-----------------------------------------------------------------------------------------
					If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
						FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
					EndIf

					SFT->(dbSkip())
		    	EndDo
			EndIf
 		EndIf
   			aadd(aListBox,{ IIf(Empty(oXml:cPROTOCOLO) .Or. oXml:OWSERRO:OWSLOTENFE[1]:CCODRETNFE $ RetCodDene(),oNo,oOk),;
			oXml:cID,;
			IIf(oXml:nAMBIENTE==1,STR0056,STR0057),; //"Produção"###"Homologação"
			IIf(oXml:nMODALIDADE==1 .Or. oXml:nMODALIDADE==4 .Or. oXml:nModalidade==6,STR0058,STR0059),; //"Normal"###"Contingência"
			oXml:cPROTOCOLO,;
			PadR(oXml:cRECOMENDACAO,250),;
			oXml:cTEMPODEESPERA,;
			oXml:nTEMPOMEDIOSEF,;
			aMsg})

			aXml 		:= {}
			nLastXml	:= 0
    Next nX
    If Empty(aListBox) .And. lMsg .And. !lCTe
    	Aviso("SPED",STR0106,{STR0114})
    EndIf


ElseIf !lOk .And. !lCTe .And. lMsg
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
EndIf

Return(aListBox)

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WsCteMnt   ³ Autor ³ Andre Godoi          ³ Data ³ 25.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Solicita o Status do documento ao TSS e grava os retornos  ³±±
±±³          ³na tabela DT6                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie do Documento                                   ³±±
±±³          ³ExpC2: Documento Inicial                                    ³±±
±±³          ³ExpC3: Documento Maximo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function WsCteMnt(cSerie, cDocMin, cDocMax, lCTE)

Local aAreaSF2  := SF2->(GetArea())
Local aAreaSF3  := SF3->(GetArea())
Local aAreaSFT  := SFT->(GetArea())
Local nX        := 0
Local nY        := 0
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOk       := .T.
Local oWS
Local oRetorno
Local cNrSerie  := ''
Local cNrDocto  := ''
Local cSitCTE   := ''
Local cIDRCTE   := ''
Local cIdent    := ''
Local lTmsCteAut:= ExistBlock("TMSCTEAUT")
Local aArrayDel := {}
Local lCTECan	  := SuperGetMv( "MV_CTECAN", .F., .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
Local cMV_INTTAF:= GetNewPar( 'MV_INTTAF', 'N' ) //Verifica se o parâmetro da integração online esta como 'S'
Local lTafKey   := SFT->( ColumnPos( 'FT_TAFKEY' ) ) > 0
Local lIntegTaf := ( cMV_INTTAF == 'S' .and. lTafKey )
Local lTAFVldAmb:= ExistFunc( 'TAFVldAmb' ) .And. TAFVldAmb( '1' ) .And. ExistFunc( 'DocFisxTAF' ) //Valida se o cliente habilitou a integração nativa Protheus x TAF
Local cTMSERP   := SuperGetMV("MV_TMSERP",," ")	//-- Condição de integração com ERP (0 - Protheus, 1 - Datasul)
Local lcanAuto  := SuperGetMV("MV_CANAUTO",.T.,.T.)	//-- Controla a transmissão automatica
Local lRtCTeId	:= SuperGetMv( "MV_RTCTEID", .F., .F. ) //-- Habilita o botão Retorno de Status
Local lretUpdCte:= ExistFunc( "retUpdCte" )
Local lretCte   := .T.
Default lCTE    := .T.

Private oXml

If (IsReady())
	cIdEnt := GetIdEnt()
EndIf

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN    := "TOTVS"
oWS:cID_ENT       := cIdEnt
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
oWS:cIdInicial    := cSerie + cDocMin
oWS:cIdFinal      := cSerie + cDocMax

lOk := oWS:MONITORFAIXA()
oRetorno := oWS:oWsMonitorFaixaResult

For nX := 1 To Len(oRetorno:oWSMONITORNFE)
	nY       := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)
	cNrSerie := SubStr(oRetorno:OWSMONITORNFE[nX]:CID,1, TamSx3("DT6_SERIE")[1])
	cNrDocto := SubStr(oRetorno:OWSMONITORNFE[nX]:CID, (TamSx3("DT6_SERIE")[1] + 1), TamSx3("DT6_DOC")[1])

/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//           Estas Msg sao retornadas pelo TSS, no metodo ( Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3))                          //
//	aadd(aMsg,"001 - Emissão de DANFE autorizada")                                                                                         //
//	aadd(aMsg,"002 - Não foi possível assinar a Nfe - entre em contato com o responsável")                                                 //
//	aadd(aMsg,"003 - A Nfe ainda não foi assinada - aguarde a assinatura")                                                                 //
//	aadd(aMsg,"004 - Lote ainda não transmitido, verifique o status da SEFAZ")                                                             //
//	aadd(aMsg,"005 - Lote recusado, verifique o motivo da SEFAZ")                                                                          //
//	aadd(aMsg,"006 - ")                                                                                                                    //
//	aadd(aMsg,"007 - Autorizada operação em contigência")                                                                                  //
//	aadd(aMsg,"008 - Autorizada manutenção da operação em contigência")                                                                    //
//	aadd(aMsg,"009 - Aguardar processamento do lote")                                                                                      //
//	aadd(aMsg,"010 - Lote não autorizado. Corrija o problema e retransmita as notas fiscais eletrônicas")                                  //
//	aadd(aMsg,"011 - Entre em contato com a SEFAZ, verifique a versão de layout suportada e atualize os parâmetros do sistema")            //
//	aadd(aMsg,"012 - Lote não autorizado. Verifique os motivos junto a SEFAZ")                                                             //
//	aadd(aMsg,"013 - NFe não autorizada. Verifique os motivos junto a SEFAZ")                                                              //
//	aadd(aMsg,"014 - NFe não autorizada. Corrija o problema e retransmita as notas fiscais eletrônicas")                                   //
//	aadd(aMsg,"015 - Cancelamento autorizado")                                                                                             //
//	aadd(aMsg,"016 - Cancelamento não transmitido, verifique o status da SEFAZ")                                                           //
//	aadd(aMsg,"017 - Cancelamento não autorizado. Verifique os motivos junto a SEFAZ")                                                     //
//	aadd(aMsg,"018 - Dpec autorizado. Emissão de DANFE autorizada")                                                                        //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
 /*
	100 Autorizado o uso do CT-e
	101 Cancelamento de CT-e homologado
	102 Inutilização de número homologado
	103 Lote recebido com sucesso
	104 Lote processado
	105 Lote em processamento
	106 Lote não localizado
	107 Serviço em Operação
	108 Serviço Paralisado Momentaneamente (curto prazo)
	109 Serviço Paralisado sem Previsão
	110 Uso Denegado
	111 Consulta cadastro com uma ocorrência
	112 Consulta cadastro com mais de uma ocorrência
	128 CT-e anulado pelo emissor
	129 CT-e substituído pelo emissor
	130 Apresentada Carta de Correção Eletrônica – CC-e
	131 CT-e desclassificado pelo Fisco

		0 - Nao Transmitido
		1 - Doc Aguardando
		2 - Doc Autorizado
		3 - Doc Nao Autorizado
		4 - Doc em Contingencia
		5 - Doc com Falha na Comunicacao
*/

	If (!Empty(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO))		//-- Mensagem do TSS.
		cSitCTE := oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
		cCodRet := Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3)
		DT6->(dbSetOrder(1))
		If	DT6->(MsSeek(xFilial('DT6')+cFilAnt+PadR(cNrDocto, Len(DT6->DT6_DOC))+cNrSerie))
		  	If lretUpdCte
		  		lretCte := retUpdCte(cFilAnt,PadR(cNrDocto, Len(DT6->DT6_DOC)),cNrSerie,cSitCTE)
			EndIf
			If lretCte
				RecLock('DT6',.F.)
				cIDRCTE := DT6->DT6_IDRCTE
				DT6->DT6_IDRCTE := cSitCTE
				DT6->DT6_PROCTE := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
	
				If !Empty(cCodRet) .And. !(cCodRet $ '003/002/004/009/016/039')
					DT6->DT6_RETCTE := SubStr(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CCODRETNFE;
											 + " - " +;
											  oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE,1,150)
				Else
					DT6->DT6_RETCTE := SubStr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,150)
				EndIf
				DT6->DT6_AMBIEN := oRetorno:OWSMONITORNFE[nX]:NAMBIENTE	//-- Grava o Ambiente que foi gerado o Doc.
	
				If cCodRet $ '002/016'
					DT6->DT6_SITCTE := StrZero(0,Len(DT6->DT6_SITCTE))		//-- Nao Transmitido
	
				ElseIf cCodRet $ '003/004/009/039'
					DT6->DT6_SITCTE := StrZero(1,Len(DT6->DT6_SITCTE))		//-- Aguardando.....
					If oRetorno:OWSMONITORNFE[nX]:NMODALIDADE == 7
						If Type("aPChvCtg") <> "U" .And. Len(aPChvCtg)>0
							nPos := Ascan(aPChvCtg,{ | e | e[1]+e[2]+e[3] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE })
							If nPos>0
								DT6->DT6_CHVCTG := aPChvCtg[nPos,4]
							EndIf
						EndIf
				 	EndIf
	
				ElseIf cCodRet $ '001/015'
					DT6->DT6_SITCTE := StrZero(2,Len(DT6->DT6_SITCTE))		//-- Autorizado o uso do Cte.
	
				ElseIf cCodRet $ '005/010/011/012/013/014/017/026'
					DT6->DT6_SITCTE := StrZero(3,Len(DT6->DT6_SITCTE))		//-- Nao Autorizado
	
				ElseIf cCodRet $ '007/008'
					DT6->DT6_SITCTE := StrZero(4,Len(DT6->DT6_SITCTE))		//-- Autorizado Contingencia
					If Type("aPChvCtg") <> "U" .And. Len(aPChvCtg)>0
						nPos := Ascan(aPChvCtg,{ | e | e[1]+e[2]+e[3] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE })
						If nPos>0
								DT6->DT6_CHVCTG := aPChvCtg[nPos,4]
						EndIf
					EndIf
				EndIf
	
				MsUnLock()
				//-- Se for reentrega diminui 1 na quantidade de reentregas do documento original
				If DT6->DT6_DOCTMS == StrZero(7,Len(DT6->DT6_DOCTMS)) .And. !Empty(cIDRCTE) .And. cIDRCTE <> "101" .And. cSitCTE == '101' //Cancelamento autorizado
				    aAreaDT6 := DT6->(GetArea())
				    DT6->(dbSetOrder(1))
				    If DT6->(MsSeek(xFilial('DT6')+ DT6->DT6_FILDCO + DT6->DT6_DOCDCO + DT6->DT6_SERDCO)) .And. DT6->DT6_REENTR > 0
					     RecLock("DT6",.F.)
					     DT6->DT6_REENTR := DT6->DT6_REENTR - 1
					     DT6->(MsUnLock())
			    	EndIf
		    		RestArea(aAreaDT6)
		   		EndIf
				If lTmsCteAut
					ExecBlock("TMSCTEAUT",.F.,.F.,{DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, DT6->DT6_SITCTE})
				EndIf
	
				//Nota de saida
	
				dbSelectArea("SF2")
				dbSetOrder(1)	//-- F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
				If SF2->(MsSeek(xFilial("SF2") + DT6->DT6_DOC + DT6->DT6_SERIE + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,.T.)) .And. SF2->F2_CHVNFE != DT6->DT6_CHVCTE
					RecLock("SF2",.F.)
					SF2->F2_CHVNFE := DT6->DT6_CHVCTE
					MsUnlock()
	
					//Função para gravação de campos da Nota no modulo Controle de Lojas com Legislação PAF-ECF
					If !lCTE .And. ExistFunc("STFMMd5NS")
						STFMMd5NS()
					EndIf
				EndIf
	
				//Livros Fiscais
				dbSelectArea("SF3")
				dbSetOrder(4) //-- F3_FILIAL+F3_CLIFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
				If SF3->(MsSeek(xFilial("SF3") + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV + DT6->DT6_DOC +DT6->DT6_SERIE,.T.))
					cChave := xFilial("SF3")+ DT6->DT6_CLIDEV + DT6->DT6_LOJDEV + DT6->DT6_DOC +DT6->DT6_SERIE
					Do While cChave == xFilial("SF3") + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE .And. !SF3->(Eof())
						RecLock("SF3",.F.)
						SF3->F3_CHVNFE  := DT6->DT6_CHVCTE
						SF3->F3_CODRSEF := cSitCTE
						MsUnLock()
	
						//-- Executa integração do Datasul
						If cTMSERP == "1" .And. FindFunction("TMSAE76")
							TMSAE76()
						EndIf
				    SF3->(dbSkip())
				    EndDo
				EndIf
	
				//-- Livro Fiscal por Item de NF
				SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"S"+ DT6->DT6_SERIE + DT6->DT6_DOC + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV
				If SFT->(MsSeek(xFilial("SFT")+"S"+ DT6->DT6_SERIE + DT6->DT6_DOC + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,.T.))
					If SFT->(FieldPos("FT_CHVNFE"))>0  .And. SFT->(FieldPos("FT_CODNFE"))>0
						Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
							RecLock("SFT",.F.)
							SFT->FT_CHVNFE := DT6->DT6_CHVCTE
							SFT->FT_CODNFE := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
							MsUnLock()
	
							//-----------------------------------------------------------------------------------------
							//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
							//-----------------------------------------------------------------------------------------
							If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
								FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
							EndIf
	
							SFT->(dbSkip())
						EndDo
					EndIf
				EndIf
	
				//Exclui o documento automaticamente caso o parâmetro MV_CTECAN esteja habilitado, e o MV_CANAUTO também.
				If lcanAuto
					If lCTECan .And. cSitCTE == '101'
						Aadd(aArrayDel , { DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, "", .T., DT6->DT6_SITCTE })
						TMSA200Exc(aArrayDel, DT6->DT6_LOTNFC, .F., .F., )
					EndIf
				EndIf
	
				If FindFunction ("AvbeGrvCte") .AND. AliasInDic("DL5")
					AvbeGrvCte( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE,DT6->DT6_DATEMI,DT6->DT6_HOREMI,DT6->DT6_IDRCTE,DT6->DT6_DOCTMS, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV)
				EndIF
			EndIf
		EndIf
		If FindFunction ("AvbeGrvCte") .AND. AliasInDic("DL5") .AND. !lCTECan .AND. cSitCTE == '101'
			AvbeGrvCte( cFilAnt, +PadR(cNrDocto, Len(DT6->DT6_DOC)), cNrSerie,,,'101',,,)
		EndIF
	EndIf

Next nX

RestArea(aAreaSF2)
RestArea(aAreaSF3)
RestArea(aAreaSFT)


Return Nil



Static Function Bt2NFeMnt(aMsg)

Local aSize    := MsAdvSize()
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oDlg
Local oListBox
Local oBtn1

If !Empty(aMsg)
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER STR0060,STR0061,STR0062,STR0063,STR0064,STR0065,STR0066,STR0067,STR0068,STR0069; //"Lote"###"Dt.Lote"###"Hr.Lote"###"Recibo SEF"###"Cod.Env.Lote"###"Msg.Env.Lote"###"Cod.Ret.Lote"###"Msg.Ret.Lote"###"Cod.Ret.NFe"###"Msg.Ret.NFe"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
	oListBox:SetArray( aMsg )
	oListBox:bLine := { || { aMsg[ oListBox:nAT,1 ],aMsg[ oListBox:nAT,2 ],aMsg[ oListBox:nAT,3 ],aMsg[ oListBox:nAT,4 ],aMsg[ oListBox:nAT,5 ],aMsg[ oListBox:nAT,6 ],aMsg[ oListBox:nAT,7 ],aMsg[ oListBox:nAT,8 ],aMsg[ oListBox:nAT,9 ],aMsg[ oListBox:nAT,10 ]} }
	@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114         ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011
	ACTIVATE MSDIALOG oDlg
EndIf
Return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} SPEDNFEXML
Função que faz "ponte" (bridge) para a função estática Bt3NFeMnt que existe com mesmo nome em outros fontes

@author Daniel Leme
@since 30/08/2017
@version 1.0

@return	.T.
/*/
Function SPEDNFEXML(cIdEnt,cIdNFe,nTipo,lUsaColab,cModelo,lAutomato,lRetXml,cXmlRet,lCancel)
Return    Bt3NFeMnt(cIdEnt,cIdNFe,nTipo,lUsaColab,cModelo,lAutomato,lRetXml,@cXmlRet,lCancel)

//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt3NFeMnt
Função que faz validação de schema do XML da NFe.

@author Henrique Brugugnoli
@since 26/01/2011
@version 1.0

@param	cIdEnt	Codigo da entidade
		cIdNFe	Id da NFe que será feito a validação de schema

@return	.T.
/*/
//-----------------------------------------------------------------------
Static Function Bt3NFeMnt(cIdEnt,cIdNFe,nTipo,lUsaColab,cModelo,lAutomato,lRetXml,cXmlRet,lCancel)

Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMsg     := ""
Local oWS
Private oDoc		:= Nil

DEFAULT nTipo     := 1
DEFAULT lUsaColab := .F.
DEFAULT cModelo	  := "55"
DEFAULT lAutomato := .F.
DEFAULT lRetXML   := .F. //-- Não exibe a tela, apenas retorna o XML
DEFAULT lCancel   := .T.
DEFAULT cXmlRet   := ""  //-- Quando o argumento lRetXml é verdadeiro, passar este como referência para o retorno

if !lUsaColab

	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:oWSNFEID          := NFESBRA_NFES2():New()
	oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := cIdNfe
	oWS:nDIASPARAEXCLUSAO := 0
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"


	If oWS:RETORNANOTAS()
		If Len(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
			If nTipo == 1
				Do Case
					Case lCancel .And. oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA <> Nil
						If !lAutomato .And. !lRetXml
							Aviso("SPED",oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML,{STR0114},3)
						ElseIf lAutomato
							MemoWrite(GetSrvProfString("RootPath","") + "\baseline\TSSRecXML.xml", oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML)
						ElseIf lRetXml
							cMsg := oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                    		cMsg += oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXMLPROT
						EndIf
					OtherWise
						If !lAutomato .And. !lRetXml
							Aviso("SPED",oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML,{STR0114},3)
						ElseIf lAutomato
							MemoWrite(GetSrvProfString("RootPath","") + "\baseline\TSSRecXML.xml", oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML)
						ElseIf lRetXml
						    cMsg := oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
			     			cMsg += oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
						EndIf
				EndCase
			Else
				cMsg := AllTrim(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML)

				If !Empty(cMsg) .And. !lRetXml
					If !lAutomato
						Aviso("SPED",@cMsg,{STR0114},3,/*cCaption2*/,/*nRotAutDefault*/,/*cBitmap*/,.T.)
					ElseIf lAutomato
						MemoWrite(GetSrvProfString("RootPath","") + "\baseline\TSSSchema.txt", cMsg)
					EndIf
					oWS:= WSNFeSBRA():New()
					oWS:cUSERTOKEN     := "TOTVS"
					oWS:cID_ENT        := cIdEnt
					oWs:oWsNFe:oWSNOTAS:=  NFeSBRA_ARRAYOFNFeS():New()
					aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())
					oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cID := cIdNfe
					oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML:= EncodeUtf8(cMsg)
					oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

					If oWS:Schema()
						If Empty(oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM)
							Aviso("SPED",STR0091,{STR0114})
						Else
							If !lAutomato
								If ( MsgYesNo(STR0343) ) //"Schema com erro. Deseja visualizar as possibilidades que podem ter causado o erro?"
									ViewSchemaMsg( oWS:oWSSCHEMARESULT:oWSNFES4[1]:oWsSchemaMsg:oWsSchemaError )
								Else
									Aviso("SPED",IIF(Empty(oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM),STR0091,oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM),{STR0114},3)
								EndIf
							ElseIf lAutomato
								MemoWrite(GetSrvProfString("RootPath","") + "\baseline\TSSSchemaErro.txt", IIF(Empty(oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM),STR0091,oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM))
							EndIf

						EndIf
					Else
						Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
					EndIf
				ElseIf !Empty(cMsg) .And. lRetXml
				    cMsg := oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
	     			cMsg += oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
				EndIf
			EndIf
		EndIf
	ElseIf !lRetXML
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
	EndIf
Else
	oDoc 			:= ColaboracaoDocumentos():new()
	oDoc:cModelo	:= IIf(cModelo=="55","NFE",IIf(cModelo=="57","CTE",IIf(cModelo=="58","MDF","")))
	oDoc:cTipoMov	:= "1"
	oDoc:cIDERP	:= cIdNFe + FwGrpCompany()+FwCodFil()

	If odoc:consultar()
		If nTipo == 1
			If !Empty(oDoc:cXmlRet)
				If !lRetXml
					Aviso("SPED",DecodeUtf8(oDoc:cXmlRet),{STR0114},3)
				Else
					cMsg := DecodeUtf8(oDoc:cXmlRet)
				EndIf
			ElseIf !lRetXml
				Aviso("SPED",oDoc:cXml,{STR0114},3)
			EndIf

		ElseIf !lRetXml
			Aviso("SPED","Validação de Schema indisponível para TOTVS Colaboração - 2.0",{STR0114},3)
		EndIf
	ElseIf !lRetXml
		Aviso("SPED",oDoc:cCodErr+" - "+oDoc:cMsgErr,{STR0114},3)
	EndIf
	oDoc := Nil
	DelClassIntF()
EndIf

//-- o Argumento cXmlRet deve ser passado como referência
If lRetXml
	cXmlRet := cMsg
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFe2Mn³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento da NFe - por tempo                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFe2Mnt()

Local cIdEnt   := ""
local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local aPerg    := {}
Local aParam   := {"000060"}
Local aSize    := {}
Local aObjects := {}
Local aListBox := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4

Local lCTe		:= (FunName()$"SPEDCTE,TMSA500,TMSA200,TMSAE70,TMSA050")
Local lUsaColab 	:= .F.

lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )

aadd(aPerg,{1,STR0070,aParam[01],"",".T.","",".T.",30,.T.})

aParam[01] := ParamLoad("SPEDNFEMNT",aPerg,1,aParam[01])

If IsReady(,,,lUsaColab)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt(lUsaColab)
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt)

			If ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,"SPEDNFEMNT",.T.,.T.)
				aListBox := getListBox(cIdEnt, cUrl, aParam)
				If !Empty(aListBox)
					aSize := MsAdvSize()
					aObjects := {}
					AAdd( aObjects, { 100, 100, .T., .T. } )
					AAdd( aObjects, { 100, 015, .T., .F. } )

					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )

					DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

					@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "",STR0049,STR0035,STR0036,STR0050,STR0051,STR0052,STR0053; //"NF"###"Ambiente"###"Modalidade"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"Tempo SEF"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					oListBox:SetArray( aListBox )
					oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ],aListBox[ oListBox:nAT,6 ],aListBox[ oListBox:nAT,7 ]} }
					@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114         ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011
					@ aPosObj[2,1],aPosObj[2,4]-060 BUTTON oBtn2 PROMPT STR0054 ACTION (Bt2NFeMnt(aListBox[oListBox:nAT][09])) OF oDlg PIXEL SIZE 028,011 //"Mensagens"
					@ aPosObj[2,1],aPosObj[2,4]-090 BUTTON oBtn3 PROMPT STR0055 ACTION (Bt3NFeMnt(cIdEnt,aListBox[ oListBox:nAT,2 ],,lUsaColab)) OF oDlg PIXEL SIZE 028,011 //"Rec.XML"
					@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn4 PROMPT "Refresh" ACTION (aListBox := getListBox(cIdEnt, cUrl, aParam),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 028,011
					ACTIVATE MSDIALOG oDlg
				EndIf
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3)	 //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFe3Mn³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento da NFe - Estatisticas               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFe3Mnt()

Local cIdEnt   := ""
Local aPerg    := {}
Local aParam   := {dDataBase,dDataBase}
Local aSize    := {}
Local aObjects := {}
Local aListBox := {}
Local aInfo    := {}
Local aPosObj  := {}
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local nX       := 0
Local nY       := 0
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4

aadd(aPerg,{1,STR0100,aParam[01],"",".T.","",".T.",45,.T.}) //"Data inicial"
aadd(aPerg,{1,STR0101,aParam[02],"",".T.","",".T.",45,.T.}) //"Data final"

aParam[01] := ParamLoad("SPEDNFE3MNT",aPerg,1,aParam[01])
aParam[02] := ParamLoad("SPEDNFE3MNT",aPerg,2,aParam[02])

If IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt()
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt)

			If ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,"SPEDNFE3MNT",.T.,.T.)
				oWs:= WsNFeSBra():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cID_ENT      := cIdEnt
				oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
				oWs:dDataInicial := aParam[01]
				oWs:dDataFinal   := aParam[02]
				If oWs:ESTATISTICAS()
					For nX := 1 To Len(oWs:oWSESTATISTICASRESULT:OWSESTATISTICANFE)
						aadd(aListBox,{	IIF(oWs:oWSESTATISTICASRESULT:OWSESTATISTICANFE[nX]:nAmbiente==1,STR0056,STR0057),;
										oWs:oWSESTATISTICASRESULT:OWSESTATISTICANFE[nX]:cServico,;
										Space(005),;
										Space(100),;
										0})
						For nY := 1 To Len(oWs:oWSESTATISTICASRESULT:OWSESTATISTICANFE[nX]:OWSDETALHE:OWSDETALHEESTATISTICANFESEF)
							aadd(aListBox,{	"",;
										"",;
										oWs:oWSESTATISTICASRESULT:OWSESTATISTICANFE[nX]:OWSDETALHE:OWSDETALHEESTATISTICANFESEF[nY]:CCODMSGSEF,;
										oWs:oWSESTATISTICASRESULT:OWSESTATISTICANFE[nX]:OWSDETALHE:OWSDETALHEESTATISTICANFESEF[nY]:CMENSAGEM,;
										oWs:oWSESTATISTICASRESULT:OWSESTATISTICANFE[nX]:OWSDETALHE:OWSDETALHEESTATISTICANFESEF[nY]:NQUANTIDADE})
						Next nY
				    Next nX
				    If Empty(aListBox)
				    	Aviso("SPED",STR0106,{STR0114})
				    EndIf
				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				EndIf
				If !Empty(aListBox)
					aSize := MsAdvSize()
					aObjects := {}
					AAdd( aObjects, { 100, 100, .T., .T. } )
					AAdd( aObjects, { 100, 015, .T., .F. } )

					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )

					DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

					@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER STR0035,STR0102,STR0103,STR0104,STR0105; //"Ambiente"###"Serviço"###"Código"###"Mensagem"###"Transações"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					oListBox:SetArray( aListBox )
					oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ]} }
					@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114         ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011
					ACTIVATE MSDIALOG oDlg
				EndIf
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3)	 //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFe4Mn³ Autor ³Eduardo Riera          ³ Data ³18.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento da NFe - Consulta NFe               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFe4Mnt(cAlias)

Local cIdEnt     := ""
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMensagem  := ""
Local cProtocolo := ""
Local cCodRet		:= ""
Local cAviso		:= ""

Local oWS

Local aParam		:= {}
Local aRetorno	:= {}
Private lUsaColab := UsaColaboracao("1")
If IsReady(,,,lUsaColab)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt(lUsaColab)
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if lUsaColab
			if cAlias=="SF1"
				aadd(aParam,{SF1->F1_SERIE+SF1->F1_DOC})
			else
				aadd(aParam,{SF2->F2_SERIE + SF2->F2_DOC})
			endif

			aRetorno:= colNfeMonProc(aParam, 2, "55", .F., @cAviso)
			cMensagem := ""
			if Len(aRetorno) > 0
				If !Empty (Alltrim (aRetorno[1][5])) .And. !Empty (Alltrim (aRetorno[1][6]))
					If Empty (Alltrim (aRetorno[1][4]))
						cMensagem += "Documento não encontrado.:"+ iif(aRetorno[1][9]<> nil,aRetorno[1][9],"") + CRLF + CRLF
					EndIf
						cMensagem += STR0035+": "+IIf(aRetorno[1][7]==1,STR0056,STR0057)+CRLF //Ambiente: "Produção"###"Homologação"
						cMensagem += STR0068+": "+aRetorno[1][5]+CRLF //Cod.Ret.NFe: Codigo de retorno Sefaz
						cMensagem += STR0069+": "+aRetorno[1][6]+CRLF //Msg.Ret.NFe: Mensagem de retorno Sefaz
						cMensagem += STR0050+": "+aRetorno[1][4]+CRLF //Protocolo: Protocolo

						cProtocolo	:= Alltrim(aRetorno[1][4])
						cCodRet	:= Alltrim(aRetorno[1][5])

				Aviso(STR0107,cMensagem,{STR0114},3)
				Else
					cMensagem+= +CRLF + iif(aRetorno[1][9]<> nil,aRetorno[1][9],"") +CRLF
					Aviso("SPED","Documento não encontrado."+cMensagem,{STR0114},3)
				EndIf
			else
				Aviso("SPED","Documento não encontrado.",{STR0114},3)
			endif
		else
			If !Empty(cIdEnt)
				oWs:= WsNFeSBra():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cID_ENT      := cIdEnt
				oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
				oWs:cNFECONSULTAPROTOCOLOID := IIF(cAlias=="SF1",SF1->F1_SERIE+SF1->F1_DOC,SF2->F2_SERIE+SF2->F2_DOC)
				If oWs:ConsultaProtocoloNfe()
					cMensagem := ""
					If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cVERSAO)
						cMensagem += STR0129+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cVERSAO+CRLF
					EndIf
					cMensagem += STR0035+": "+IIf(oWs:oWSCONSULTAPROTOCOLONFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produção"###"Homologação"
					cMensagem += STR0068+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE+CRLF
					cMensagem += STR0069+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cMSGRETNFE+CRLF
					If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO)
						cMensagem += STR0050+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO+CRLF
					EndIf
					Aviso(STR0107,cMensagem,{STR0114},3)
					cProtocolo := oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO
					cCodRet := oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE

				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				EndIf
			Endif

		EndIf

		//Atualiza tabela
		If !Empty(cProtocolo)
			Do Case
				Case cAlias == "SF1" .And. SF1->(FieldPos("F1_FIMP"))<>0
	   			   RecLock("SF1")
    				   SF1->F1_FIMP := "S"
    				   MsUnlock()
                	Case cAlias == "SF2"
    			   RecLock("SF2")
    			   SF2->F2_FIMP := "S"
    			   MsUnlock()
			EndCase
		EndIf
		If cCodRet $ RetCodDene() // Uso Denegado
			Do Case
				Case cAlias == "SF1" .And. SF1->(FieldPos("F1_FIMP"))<>0
	   			   RecLock("SF1")
    				   SF1->F1_FIMP := "D"
    				   MsUnlock()
                	Case cAlias == "SF2"
    			   RecLock("SF2")
    			   SF2->F2_FIMP := "D"
    			   MsUnlock()
			EndCase
		EndIf

	Else
		Aviso("SPED",STR0021,{STR0114},3)	 //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consulta NF-e atraves da chave                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function SpedNFe5Mnt(cAlias)

Local oDlgKey, oBtnOut, oBtnCon
Local cIdEnt   := ""
Local cChaveNFe := Space(44)

If IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt()
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt)

			DEFINE MSDIALOG oDlgKey TITLE "Consulta NF-e" FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

			@ 12,008 SAY "Informe a Chave de acesso da NF-e: " PIXEL OF oDlgKey
			@ 20,008 MSGET cChaveNFe SIZE 140,10 PIXEL OF oDlgKey

			@ 46,035 BUTTON oBtnCon PROMPT "&Consultar" SIZE 38,11 PIXEL ACTION ConsNFeChave(cChaveNFe,cIdEnt)
			@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()

			ACTIVATE DIALOG oDlgKey CENTERED

		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3)	 //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf


Static Function ConsNFeChave(cChaveNFe,cIdEnt)

Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMensagem:= ""
Local oWS

oWs:= WsNFeSBra():New()
oWs:cUserToken   := "TOTVS"
oWs:cID_ENT    := cIdEnt
ows:cCHVNFE		 := cChaveNFe
oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

If oWs:ConsultaChaveNFE()
	cMensagem := ""
	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
		cMensagem += STR0129+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
	EndIf
	cMensagem += STR0035+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produção"###"Homologação"
	cMensagem += STR0068+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
	cMensagem += STR0069+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
		cMensagem += STR0050+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
	EndIf
    If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL)
		cMensagem += STR0375+": "+oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL+CRLF
	EndIf
	Aviso(STR0107,cMensagem,{STR0114},3)
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FsLoadTxt ³ Autor ³Eduardo Riera          ³ Data ³24.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura de arquivo texto para anexar ao layout    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExC1: Arquivo texto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome do arquivo texto com path                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FsLoadTXT(cFileImp)

Local cTexto		:= ""
local cCopia		:= ""
local cExt			:= ""
Local nHandle		:= 0
Local nTamanho	:= 0

if left(cFileImp, 1) # "\" .And. !IsSrvUnix()
	CpyT2S(cFileImp,"\")
endif

nHandle := FOpen(cFileImp)
nTamanho := Fseek(nHandle,0,FS_END)
FSeek(nHandle,0,FS_SET)
FRead(nHandle,@cTexto,nTamanho)
FClose(nHandle)

SplitPath(cFileImp,/*cDrive*/,/*cPath*/, @cCopia,cExt)
FErase("\"+cCopia+cExt)

Return(cTexto)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFeCan³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de cancelamento da NFe para o Totvs Services SPED    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Empresa                                              ³±±
±±³          ³ExpC2: Filial                                               ³±±
±±³          ³ExpC3: Codigo da Entidade                                   ³±±
±±³          ³ExpC4: Ambiente                                             ³±±
±±³          ³ExpC5: Modalidade                                           ³±±
±±³          ³ExpC6: Versao                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFeCan(cCodEmp,cCodFil,cIdEnt,cAmbiente,cModalidade,cVersao,aInfnota,lCTe)

	Local cUrl	:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
	local lUsaColab 	:= .F.
	Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
	local cModelo		:= "55"
	local lMDfe		:= .F.
	Default lCTe := .F.
	Default aInfnota	:= {}

If lSdoc
	GetFiltroF3(@aInfnota,.T.,aInfnota[4],aInfnota[5])
EndIF

lUsaColab :=  UsaColaboracao( IIF(lCte,"2","1") )
cModelo   := 	IIf(lCte,"57",IIf(lMDfe,"58","55"))
If lCTe
	JobNfeCan(cIdEnt,cAmbiente,cModalidade,cVersao,aInfnota,lCTE)
Else
	MsgRun(STR0130,STR0073,{|| JobNfeCan(cIdEnt,cAmbiente,cModalidade,cVersao,aInfnota)}) //"Aguarde"###"Processando Transmissão NF-e"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as notas fiscais canceladas do dia para atribuir valores ao campo F3_CODRSEF  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCTe
	getListBox(cIdEnt, cUrl, aInfNota, 1, cModelo, lCte,.F.,/*lMDfe*/,/*lTMS*/,lUsaColab)
EndIf

Return

Static Function JobNFeCan(cIdEnt,cAmbiente,cModalidade,cVersao,aInfnota,lCTE)

Local aArea			:= GetArea()
Local aNotas			:= {}
Local aXml				:= {}
Local aNFeCol			:= {}
Local aInfXml 		:= {}

Local cLabelEven		:= ""
Local cIndice			:= ""
Local cAliasSF3		:= "SF3"
Local cWhere			:= ""
Local cURL				:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cModelo			:= "55"
Local cXjust			:= ""
Local cCodRSef		:= ""
Local cRet				:= ""
Local cTpEvento		:= "110111"
Local cErro			:= ""
Local cAviso			:= ""
Local cIdEven			:= ""
Local cSerie			:= ""
Local cNumero			:= ""
Local cMod				:= ""
Local cWhereCupom		:= "CF"

Local dDataCanc		:= Date()

Local lNfeCancEven	:= GetNewPar("MV_NFECAEV",.F.)	//-- Cancelamento de NF-e por Evento
Local lQuery			:= .F.
Local lRetorno		:= .T.
Local lXjust			:= GetNewPar("MV_INFXJUS","") == "S"
Local lCTeXjust		:= SuperGetMv("MV_CTEXJUS", .F., .F.)
Local lCodRSef		:= .F.
Local lEndFis  		:= GetNewPar("MV_SPEDEND",.F.)
Local cUFEnt   		:= IIF(!lEndFis,SM0->M0_ESTCOB,SM0->M0_ESTENT)
Local lCancela		:= .F.
Local lInutiliza		:= .F.

Local lAviso			:= .F.
Local lGera			:= .F.

Local nCancExt 		:= iif ( Empty (GetNewPar("MV_CANCEXT",30)) .OR. GetNewPar("MV_CANCEXT",30) == 0 ,30,GetNewPar("MV_CANCEXT",30))   //-- Cancelamento Extemporâneo
Local nX				:= 0
Local nY				:= 0
Local oWs
Local lCancOk			:= .F.
Local lArqGer			:= .F.
Local lUsaColab		:= .F.
Local lTrfNfeCanc 	:= ExistBlock('TRFNFECANC')
local lNFeCan        := .T.
Default lCTE			:= .F.
lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa parametros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAmbiente   := SubStr(cAmbiente,1,1)
cModalidade := SubStr(cModalidade,1,1)
If lCte
	cModelo := "57"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as notas fiscais canceladas do dia para atribuir valores ao campo F3_CODRSEF  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
getListBox(cIdEnt, cUrl, aInfNota, 1, cModelo, lCte,.F.,/*lMDfe*/,/*lTMS*/,lUsaColab)

dbSelectArea("SF3")
dbSetOrder(5) //F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, F3_IDENTFT,

If SF3->(FieldPos("F3_CODRSEF")) > 0
	lCodRSef := .T.
Else
	lCodRSef := .F.
EndIf

dDataCanc := dDataBase-nCancExt

#IFDEF TOP
	cWhere		:= "%((SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S') OR (SubString(SF3.F3_CFO,1,1) >= '5'))"

	If lCodRSef
		cRet := RetCodDene()
		
		cWhere		+= " AND ( (SF3.F3_ESPECIE <> 'SPED' AND SF3.F3_CODRSEF NOT IN ( "+ cRet+','+"'101','102','151','155'"
		
		If len(alltrim(SM0->M0_CGC)) == 14
			If (alltrim(upper(cUFEnt)) $ "MG|BA|MT")
				cWhere += " ))"
			Else
				cWhere += ",'220'))"
			EndIf	
		Else
			if alltrim(upper(cUFEnt)) $ "MG|BA|MT" 
				cWhere += ",'217','215'))"
			Else
				cWhere += ",'220','217','215'))"
			EndIf	
		EndIf		

		cWhere		+= " OR    (SF3.F3_ESPECIE = 'SPED'  AND SF3.F3_CODRSEF NOT IN ( '110','205','301','302')) )%" 
		cCodRSef	+= "%,F3_CODRSEF%"
	Else
		cCodRSef	+= "%%"
	Endif

	cAliasSF3 := GetNextAlias()
	lQuery    := .T.

	BeginSql Alias cAliasSF3

	COLUMN F3_ENTRADA AS DATE
	COLUMN F3_DTCANC AS DATE


	SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC %Exp:cCodRSef%
			FROM %Table:SF3% SF3
			WHERE
			SF3.F3_FILIAL = %xFilial:SF3% AND
			SF3.F3_ENTRADA >= %Exp:dDataCanc% AND
			SF3.F3_DTCANC  >= %Exp:dDataCanc% AND
			SF3.F3_ESPECIE <> %Exp:cWhereCupom% AND

			%Exp:cWhere% AND
			SF3.%notdel%
	EndSql
	cWhere := ".T."
#ELSE

	cWhere := "((SubString(SF3->F3_CFO, 1, 1) < '5' .And. SF3->F3_FORMUL == 'S') .Or. (SubString(SF3->F3_CFO, 1, 1) >= '5'))"

	If lCodRSef

		cWhere += " .And. ( (SF3->F3_ESPECIE <> 'SPED' .And. SF3->F3_CODRSEF <> '101' .And. SF3->F3_CODRSEF <> '102' .And. SF3->F3_CODRSEF <> '151' .And. SF3->F3_CODRSEF <> '155' "

			If len(alltrim(SM0->M0_CGC)) == 14
				If (cUFEnt $ "MG|BA|MT")
					cWhere += " )"
				Else
					cWhere += " .And. SF3->F3_CODRSEF <> '220')"
				EndIf	
			Else
				If (cUFEnt $ "MG|BA|MT")
					cWhere += " .And. SF3->F3_CODRSEF <> '215'.And. SF3->F3_CODRSEF <> '217')"
				Else
					cWhere += " .And. SF3->F3_CODRSEF <> '220'.And. SF3->F3_CODRSEF <> '215'.And. SF3->F3_CODRSEF <> '217')"
				EndIf	
			endif					

		cWhere += " .Or.  (SF3->F3_ESPECIE = 'SPED'  .And. SF3->F3_CODRSEF <> '110' .And. SF3->F3_CODRSEF <> '205' .And. SF3->F3_CODRSEF <> '301' .And. SF3->F3_CODRSEF <> '302') )" 
	EndIf

	SF3->(dbSetFilter(&("{|| F3_FILIAL == '" + xFilial("SF3") + "' .And. DToS(F3_EMISSAO) >= '" + DToS(dDataBase - 30) + "' .And. DToS(F3_DTCANC) >= '" + DTOS(dDataBase - 30) + "' .And. " + cWhere + "}"),;
	                  "F3_FILIAL == '" + xFilial("SF3") + "' .And. DToS(F3_EMISSAO) >= '" + DToS(dDataBase - 30) + "' .And. DToS(F3_DTCANC) >= '" + DTOS(dDataBase - 30) + "' .And. " + cWhere))
	dbGotop()
#ENDIF
While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL
	dbSelectArea(cAliasSF3)
	If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL})==0
		If (AModNot((cAliasSF3)->F3_ESPECIE)$"55,57" .Or. cAmbiente=="2") .And. &cWhere
			lNFeCan:= .T.
			If (val((cAliasSF3)->F3_SERIE)  > 919 .AND. val((cAliasSF3)->F3_SERIE) < 969) .and. (cAliasSF3)->F3_CODRSEF  <> '100'
				lNFeCan := ConNfeAut(cAliasSF3)	
			Endif
			
			If  lNFeCan
				aadd(aNotas,{})
				nX := Len(aNotas)
				aadd(aNotas[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
				aadd(aNotas[nX],(cAliasSF3)->F3_ENTRADA)
				aadd(aNotas[nX],(cAliasSF3)->F3_SERIE)
				aadd(aNotas[nX],(cAliasSF3)->F3_NFISCAL)
				aadd(aNotas[nX],(cAliasSF3)->F3_CLIEFOR)
				aadd(aNotas[nX],(cAliasSF3)->F3_LOJA)
				If AModNot((cAliasSF3)->F3_ESPECIE)$"55,57"
					aadd(aNotas[nX],AModNot((cAliasSF3)->F3_ESPECIE))
				ElseIf FunName()$"SPEDCTE,TMSA200"
					aadd(aNotas[nX],"57")
				Else
					aadd(aNotas[nX],"55")
				EndIf
				If lCodRSef
					aadd(aNotas[nX], (cAliasSF3)->F3_CODRSEF)
			 	Else
					aadd(aNotas[nX],"")
				Endif
			EndIf
		EndIf
	EndIf
	dbSelectArea(cAliasSF3)
	dbSkip()
EndDo

If lTrfNfeCanc .and. !Empty(aNotas)
	aNotas := ExecBlock("TRFNFECANC",.F.,.F.,{aNotas})
Endif

If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
	dbSelectArea("SF3")
Else
	RetIndex("SF3")
	FErase(cIndice+OrdBagExt())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transmite as NFe canceladas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaColab
	oDoc := ColaboracaoDocumentos():new()
	oDoc:cModelo 	:= IIf(cModelo=="55","NFE",IIf(cModelo=="57","CTE",""))
	oDoc:cTipoMov	:= "1"
Else
	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
EndIf

For nX := 1 To Len(aNotas)
	cModelo := aNotas[nX][7]
	cXjust := ""
	nY++

	If lUsaColab
		//oDoc:cIdErp	:= aNotas[nX][3]+ aNotas[nX][4] + FwGrpCompany() + FwCodFil()

		cSerie		:= aNotas[nX][3]
		cNumero 	:= aNotas[nX][4]
		cMod		:= IIf(cModelo == "55","NFE","CTE")
		cCodSef	:= aNotas[nX][8]

		aInfXml := ColExpDoc(cSerie,cNumero,cMod)

	Else
		aadd(oWs:oWsNFe:oWsNotas:oWSNFES,NFESBRA_NFES():New())
		oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cID := aNotas[nX][3]+aNotas[nX][4]
		If cVersao < "1.11"
			oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= GetUFCode(SM0->M0_ESTCOB)+FsDateConv(aNotas[nX][2],"YYMM")+PADL(ALLTRIM(SM0->M0_CGC),14,"0")+cModelo+StrZero(Val(aNotas[nX][3]),3)+StrZero(Val(aNotas[nX][4]),9)+Inverte(StrZero(Val(aNotas[nX][4]),9))
		Else
			oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= GetUFCode(SM0->M0_ESTCOB)+FsDateConv(aNotas[nX][2],"YYMM")+PADL(ALLTRIM(SM0->M0_CGC),14,"0")+cModelo+StrZero(Val(aNotas[nX][3]),3)+StrZero(Val(aNotas[nX][4]),9)+cModalidade+Inverte(StrZero(Val(SubStr(aNotas[nX][4],2,8)),8))
		EndIf
		oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= 'Id="' +	oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML + Modulo11(oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML) + '"'
	EndIf


	If ( lCodRSef .And. ( empty(allTrim(aNotas[nX][8]))) )

		If lAviso
			cAviso := allTrim ( "Motivo de inutilizacao nota " + aNotas[nX][3] + " " + aNotas[nX][4])
		Else
			cAviso := allTrim ("Motivo de cancelamento nota " + aNotas[nX][3] + " " + aNotas[nX][4])
		EndIf
	Else
		cAviso := allTrim ("Motivo de cancelamento nota " + aNotas[nX][3] + " " + aNotas[nX][4])
	EndIf

	If lUsaColab

		If 	aInfXml[1]	.OR.  aInfXml[11]	/*lInutiliza-Nota na SF3-DTCANC preenchido*/
		if (aInfXml[10])/*lCancela*/ .And. (aInfXml[9]) /*lAutorizado*/
			lAviso	:= .F.
			lInutiliza	:= .F.
			lCancela	:= .T. //pode cancelar
			cAviso := allTrim ( "Motivo de cancelamento nota " + aNotas[nX][3] + " " + aNotas[nX][4])
			cLabelEven:= "Cancelamento de NF-e como Evento"
		Elseif	(aInfXml[11])/*lInutiliza*/ .And. (aInfXml[9]) /*lAutorizado*/
			// "Voce não pode inutilizar uma nota autorizada"
			lInutiliza	:= .F.
				lCancela := .F.
		Elseif	(aInfXml[11])/*lInutiliza*/ .And. (!aInfXml[9]) /*lAutorizado*/
			lAviso := .T.
			lInutiliza	:= .T. //pode inutilizar
				lCancela 	:= .F.
			cAviso := allTrim ( "Motivo de inutilizacao nota " + aNotas[nX][3] + " " + aNotas[nX][4])
			cLabelEven:="Inutilização de NF-e como Evento"
			EndIf


		If ((lCancela .Or. lInutiliza) .And. GetCodRet(aNotas[nX],cModelo) .And. !(aNotas[nX][8] $ "151-101-102-155") )	//Lê o F3_CODRET = T |Se Transmitido não envia|se existir o campo na SF3

			If lXjust
				While .T.
				If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 3,cLabelEven,,, .T.) == 1
						If SpedCCeTexto(cXjust,250)

							lGera := .T.

							Exit
						Else
							Loop
						Endif
					Else
						lGera := .F. // Cancelada a operação sem justifcativa do cancelamento
						Exit
					Endif
				Enddo
			Else
				lGera := .T.
			EndIf


			If lGera
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adicionando no aNFe para manter o padrao das funcoes SpedCCeXml e ColEnvEvento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aNFeCol := {}
				aAdd(aNFeCol,aInfXml[2]) 				//01 - Chave da Nfe
				aAdd(aNFeCol,"")			 				//02 - em branco
				aAdd(aNFeCol,cSerie) 					//03 - Serie
				aAdd(aNFeCol,cNumero) 					//04 - Numero

				oDoc:cNomeArq := "" 		// Limpando o nome do Arq. pois sera criado outro arquivo.

				If lCancela
					cXml := SpedCCeXml( aNFeCol , cXjust , cTpEvento , aInfXml[7] , , , , lCte )
					lArqGer := ColEnvEvento( cMod , aNFeCol , cXml , @cIdEven , @cErro )
					If lArqGer
					lCancOk  := ColAtuTrans( /*cEntSai*/ , cSerie, cNumero ,/*cCliente*/,/*cLoja*/,/*lCTe*/,/*cChvCtg*/,/*nTpEmisCte*/)
					Endif
					lCancela := .F.
				ElseIf lInutiliza
					cXml := ColInutTrans( aNFeCol , cXjust , cModelo )
					lArqGer := ColEnvEvento( cMod , aNFeCol , cXml , nil , @cErro , lInutiliza )
					If lArqGer
					lCancOk    := ColAtuTrans( /*cEntSai*/ , cSerie, cNumero ,/*cCliente*/,/*cLoja*/,/*lCTe*/,/*cChvCtg*/,/*nTpEmisCte*/)
					Endif
					lInutiliza := .F.
				EndIf
			EndIf
		EndIf
	EndIf
		//Monitoramento da nota
		getListBox(cIdEnt, cUrl, aInfNota, 1, cModelo, lCte,.F.,/*lMDfe*/,/*lTMS*/,lUsaColab)
	Else
		If lXjust .and. !(aNotas[nX][8] $ "151-101-102-155") .And. aNotas[nX][7] != "57"
		 	//-- Tratamento do Cancelamento por Evento
			If ( lNfeCancEven .And. !( lCodRSef .And. Empty(AllTrim(aNotas[nX][8])) ) )
				While .T.
					If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 3,"Cancelamento de NF-e como Evento",,, .T.) == 1
						If SpedCCeTexto(cXjust,250)
							oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML += '<xJust>xJust="'+cXjust+'"</xJust>'
							Exit
						Else
							Loop
						Endif
					Else
						Exit
					Endif
				Enddo
			Else
				If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 4,,,, .T.) == 1 .And. !Empty(cXjust)
					oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML += '<xJust>xJust="'+cXjust+'"</xJust>'
				Endif
			Endif
		ElseIf lCTeXjust .And. aNotas[nX][7] = "57"
		 	//-- Tratamento do Cancelamento por Evento
			If ( lNfeCancEven .And. !( lCodRSef .And. Empty(AllTrim(aNotas[nX][8])) ) )
				While .T.
					If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 3,"Cancelamento do CT-e como Evento",,, .T.) == 1
						If SpedCCeTexto(cXjust,250)
							oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML += '<xJust>xJust="'+cXjust+'"</xJust>'
							Exit
						Else
							Loop
						Endif
					Else
						Exit
					Endif
				Enddo
			Else
				If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 4,,,, .T.) == 1 .And. !Empty(cXjust)
					oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML += '<xJust>xJust="'+cXjust+'"</xJust>'
				Endif
			Endif
		ElseIf ExistBlock("FISCANNFE")
			oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML := ExecBlock("FISCANNFE",.F.,.F.,{oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML,aNotas[nX]})
		EndIf
	EndIf
	If nY >=50 .Or. nX == Len(aNotas)
		If !lUsaColab
			If oWs:CancelaNotas()
				oWs:= WsNFeSBra():New()
				oWs:cUserToken := "TOTVS"
				oWs:cID_ENT    := cIdEnt
				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
				oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
				nY := 0
			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	        EndIf
		EndIf
	EndIf
	IF !lUsaColab
	  gravaCodRet( aNotas[nX] ) //Grava na F3_CODRET = T |Transmitido|se existir o campo na SF3
	EndIf

	if( lXjust .and. ExistBlock("NFECANC01") )
		ExecBlock("NFECANC01",.f.,.f.,{cIdEnt, aNotas, cXjust})		
    Endif
	
Next nX

RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as notas fiscais canceladas do dia para atribuir valores ao campo F3_CODRSEF  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
getListBox(cIdEnt, cUrl, aInfNota, 1, cModelo, lCte,.F.,/*lMDfe*/,/*lTMS*/,lUsaColab)

Return(.T.)

Static Function Inverte(uCpo)

Local cCpo	:= uCpo
Local cRet	:= ""
Local cByte	:= ""
Local nAsc	:= 0
Local nI		:= 0
Local aChar	:= {}
Local nDiv	:= 0


Aadd(aChar,	{"0", "9"})
Aadd(aChar,	{"1", "8"})
Aadd(aChar,	{"2", "7"})
Aadd(aChar,	{"3", "6"})
Aadd(aChar,	{"4", "5"})
Aadd(aChar,	{"5", "4"})
Aadd(aChar,	{"6", "3"})
Aadd(aChar,	{"7", "2"})
Aadd(aChar,	{"8", "1"})
Aadd(aChar,	{"9", "0"})

For nI:= 1 to Len(cCpo)
   cByte := Upper(Subs(cCpo,nI,1))
   If (Asc(cByte) >= 48 .And. Asc(cByte) <= 57) .Or. ;	// 0 a 9
   		(Asc(cByte) >= 65 .And. Asc(cByte) <= 90) .Or. ;	// A a Z
   		Empty(cByte)	// " "
	   nAsc	:= Ascan(aChar,{|x| x[1] == cByte})
   	If nAsc > 0
   		cRet := cRet + aChar[nAsc,2]	// Funcao Inverte e chamada pelo rdmake de conversao
	   EndIf
	Else
		// Caracteres <> letras e numeros: mantem o caracter
		cRet := cRet + cByte
	EndIf
Next
Return(cRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedVisual³ Autor ³Marcelo Alexandre      ³ Data ³20.02.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Botao para visualizar documentos de saida                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedVisualDoc(cAlias)

Local aRotRec	:= aClone(aRotina)

If cAlias == "SF2"
	Mc090Visual("SF2",SF2->(RecNo()),1)
ElseIf cAlias == "SF1"
	aRotina[2][1] := OemToAnsi(SubStr(STR0287,2))
	aRotina[2][2] := "A103NFiscal"
	aRotina[2][4] := 2
	A103NFiscal("SF1",SF1->(RecNo()),2)
	aRotina := aClone(aRotRec)
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedFiltro³ Autor ³Marcelo Alexandre      ³ Data ³23.02.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Botao para alterar o filtro do browse                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedFiltro()

INCLUI    := .F.
lBtnFiltro:= .T.
CloseBrowse()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedExport³ Autor ³Eduardo Riera          ³ Data ³02.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de exportacao das notas fiscaiss eletronicas         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedExport(nTipo)

Local cIdEnt   	 := ""
Local aPerg   	 := {}
Local aParam  	 := {Space(If (TamSx3("F2_SERIE")[1] == 14,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(60),CToD(""),CToD(""),Space(14),Space(14)}
Local cParNfeExp := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEEXP"
Local lObrigat   := .F.
Local lUsaColab  := .F.
Local lCTe       := (FunName()$"SPEDCTE,TMSA500,TMSA200,TMSAE70,TMSA050")
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14

DEFAULT nTipo  := 1
lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )

lObrigat:=If(nTipo == 2,lObrigat:=.F.,.T.)

aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,lObrigat}) //"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,lObrigat}) //"Nota fiscal final"
aadd(aPerg,{6,STR0119,aParam[04],"",".T.","!Empty(mv_par04)",80,.T.,"Arquivos XML |*.XML","",GETF_RETDIRECTORY+GETF_LOCALHARD,.T.}) //"Diretório de destino"
aadd(aPerg,{1,STR0141,aParam[05],"",".T.","",".T.",50,lObrigat}) //"Data Inicial"
aadd(aPerg,{1,STR0142,aParam[06],"",".T.","",".T.",50,lObrigat}) //"Data Final"

If nTipo == 1 .Or. nTipo == 3 .Or. nTipo == 4 .Or. nTipo == 5
	aadd(aPerg,{1,STR0143,aParam[07],"",".T.","",".T.",50,.F.}) //"CNPJ Inicial"
	aadd(aPerg,{1,STR0144,aParam[08],"",".T.","",".T.",50,.F.}) //"CNPJ final"
EndIF

aParam[01] := ParamLoad(cParNfeExp,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeExp,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeExp,aPerg,3,aParam[03])
aParam[04] := ParamLoad(cParNfeExp,aPerg,4,aParam[04])

aParam[05] := ParamLoad(cParNfeExp,aPerg,5,aParam[05])
aParam[06] := ParamLoad(cParNfeExp,aPerg,6,aParam[06])

If nTipo == 1 .Or. nTipo == 3 .Or. nTipo == 4 .Or. nTipo == 5
	aParam[07] := ParamLoad(cParNfeExp,aPerg,7,aParam[07])
	aParam[08] := ParamLoad(cParNfeExp,aPerg,8,aParam[08])
EndIF

If IsReady(,,,lUsaColab)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt(lUsaColab)
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt)

			If ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,cParNfeExp,.T.,.T.)

				If lSdoc
					GetFiltroF3(@aParam,,aParam[05],aParam[06])
				EndIF

         		If nTipo == 1 .Or. nTipo == 3 .Or. (nTipo == 4 .And. !lUsaColab)  .Or. (nTipo == 5 .And. !lUsaColab)	//NFe - NFCe - CTe - MDFe - Mdfe/TMS
					Processa({|lEnd| SpedPExp(cIdEnt,aParam[01],aParam[02],aParam[03],aParam[04],lEnd,aParam[05],IIF(Empty(aParam[06]),dDataBase,aParam[06]),aParam[07],aParam[08],nTipo,,If(lSdoc,aParam[Len(aParam)],aParam[1]))},"Processando","Aguarde, exportando arquivos",.F.)
           		ElseIf nTipo == 2  //CCe
					Processa({|lEnd| SpedPExp(cIdEnt,aParam[01],aParam[02],aParam[03],aParam[04],lEnd,aParam[05],IIF(Empty(aParam[06]),dDataBase,aParam[06]),,,nTipo,,If(lSdoc,aParam[Len(aParam)],aParam[1]))},"Processando","Aguarde, exportando arquivos",.F.)
           		ElseIf nTipo == 4 .Or. nTipo == 5 .And. lUsaColab // Mdfe/TMS - TOTVSColab
            		Processa({|lEnd| ExportMdfe(cIdEnt,aParam[01],aParam[02],aParam[03],aParam[04],lEnd,aParam[05],IIF(Empty(aParam[06]),dDataBase,aParam[06]),aParam[07],aParam[08],nTipo,,If(lSdoc,aParam[Len(aParam)],aParam[1]))},"Processando","Aguarde, exportando arquivos",.F.)
            	EndIf
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

Static Function SpedPExp(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd,dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe,cSerMax)

Local aDeleta  := {}

Local cAlias	:= GetNextAlias()
Local cAnoInut  := ""
Local cAnoInut1 := ""
Local cCanc		:= ""
Local cChvIni  	:= ""
Local cChvFin	:= ""
Local cChvNFe  	:= ""
Local cCNPJDEST := Space(14)
Local cCondicao	:= ""
Local cDestino 	:= ""
Local cDrive   	:= ""
Local cIdflush  := cSerie+cNotaIni
Local cModelo  	:= ""
Local cNFes     := ""
Local cPrefixo 	:= ""
Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cXmlInut  := ""
Local cXml		:= ""
Local cWhere	:= ""
Local cXmlProt	:= ""
local cAviso    := ""
local cErro     := ""
local cTab		  := ""
local cCmpNum	  := ""
local cCmpSer	  := ""
local cCmpTipo  := ""
local cCmpLoja  := ""
local cCmpCliFor:= ""
local cCnpj	  := ""
Local cEventoCTe	:= ""
Local cRetEvento	:= ""
Local cRodapCTe  :=""
local cCabCTe    :=""
Local cIdEven	   := ""
local cVerMDfe		:= ""
local cNumMdfe		:= ""

Local lOk      	:= .F.
Local lFlush  	:= .T.
Local lFinal   	:= .F.
Local lClearFilter:= .F.
Local lExporta 	:= .F.
Local lUsaColab	:= .F.
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14

Local nHandle  	:= 0
Local nX        := 0
Local nY		:= 0
local nZ		:= 0

Local aInfXml	:= {}

Local oRetorno
Local oWS
Local oXML


Local lOkCanc		:= .f.

Default nTipo	:= 1
Default cNotaIni:=""
Default cNotaFim:=""
Default dDataDe:=CtoD("  /  /  ")
Default dDataAte:=CtoD("  /  /  ")
Default lCTe	:= IIf (FunName()$"SPEDCTE,TMSA200,TMSAE70,TMSA500,TMSA050",.T.,.F.)
Default cSerMax := cSerie

lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )

If nTipo == 3
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

If IntTMS() .and. lCTe//Altera o conteúdo da variavel quando for carta de correção para o CTE
	cTipoNfe := "SAIDA"
EndIf
ProcRegua(Val(cNotaFim)-Val(cNotaIni))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corrigi diretorio de destino                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SplitPath(cDirDest,@cDrive,@cDestino,"","")
cDestino := cDrive+cDestino
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia processamento                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While lFlush

	If ( nTipo == 1 .And. !lUsaColab ).Or. nTipo == 3 .Or. (nTipo == 4 .And. !lUsaColab) .Or. (nTipo == 5 .And. !lUsaColab)
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cIdInicial        := IIf(nTipo==4,'58'+cIdflush,cIdflush) // cNotaIni
		oWS:cIdFinal          := IIf(nTipo==4,'58'+cSerMax+cNotaFim,cSerMax+cNotaFim)
		oWS:dDataDe           := dDataDe
		oWS:dDataAte          := dDataAte
		oWS:cCNPJDESTInicial  := cCnpjDIni
		oWS:cCNPJDESTFinal    := cCnpjDFim
		oWS:nDiasparaExclusao := 0
		lOk:= oWS:RETORNAFX()
		oRetorno := oWS:oWsRetornaFxResult
		lOk := iif( valtype(lOk) == "U", .F., lOk )

		If lOk
			ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exporta as notas                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		    For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)

                //Ponto de Entrada para permitir filtrar as NF
                If ExistBlock("SPDNFE01")
                   If !ExecBlock("SPDNFE01",.f.,.f.,{oRetorno:OWSNOTAS:OWSNFES3[nX]})
                      loop
                   Endif
                Endif

		 		oXml    := oRetorno:OWSNOTAS:OWSNFES3[nX]
				oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
				cXML	:= ""
				If Type("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				ElseIF Type("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Else
	    			cCNPJDEST := ""
    			EndIf
    				cVerNfe := IIf(Type("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '')
	  				cVerCte := Iif(Type("oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT") <> "U", oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT, '')
	  				cVerMDfe:= Iif(Type("oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT") <> "U", oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT, '')

		 		If !Empty(oXml:oWSNFe:cProtocolo)
			    	cNotaIni := oXml:cID
					cIdflush := cNotaIni
			 		cNFes := cNFes+cNotaIni+CRLF
			 		cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id")
					cModelo := cChvNFe
					cModelo := StrTran(cModelo,"NFe","")
					cModelo := StrTran(cModelo,"CTe","")
					cModelo := StrTran(cModelo,"MDFe","")
					cModelo := SubStr(cModelo,21,02)

					Do Case
						Case cModelo == "57"
							cPrefixo := "CTe"
						Case cModelo == "65"
							cPrefixo := "NFCe"
						Case cModelo == "58"
							cPrefixo := "MDFe"
						OtherWise
							if '<cStat>301</cStat>' $ oXml:oWSNFe:cxmlPROT .or. '<cStat>302</cStat>' $ oXml:oWSNFe:cxmlPROT
								cPrefixo := "den"
							else
								cPrefixo := "NFe"
							endif
					EndCase

		 			cChvNFe	:= iif( cModelo == "58", SubStr(cChvNFe,5,44), SubStr(cChvNFe,4,44) )
					//--------------------------------------------------
					// Exporta MDFe - (Autorizada)
					//--------------------------------------------------
					if ( (cModelo=="58") .and. alltrim(FunName()) == 'SPEDMDFE' )
						nHandle	:= 0
			 			nHandle := FCreate(cDestino+cChvNFe+"-"+cPrefixo+".xml")
			 			if nHandle > 0
			 				cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
							cCab1 	+= '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVerMDfe+'">'
							cRodap	:= '</mdfeProc>
							FWrite(nHandle,AllTrim(cCab1))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
							FWrite(nHandle,AllTrim(cRodap))
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)
				 			cNumMdfe += cIdflush+CRLF
				 		endif
					//--------------------------------------------------
					// Exporta Legado
					//--------------------------------------------------
					elseif alltrim(FunName()) <> 'SPEDMDFE'

			 			nHandle := FCreate(cDestino+cChvNFe+"-"+cPrefixo+".xml")
			 			If nHandle > 0
			 				cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
			 				If cModelo == "57"
								//cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v'+cVerCte+'.xsd" versao="'+cVerCte+'">'
								cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
								cRodap := '</cteProc>'
							Else
								Do Case
									Case cVerNfe <= "1.07"
										cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
									Case cVerNfe >= "2.00" .And. "cancNFe" $ oXml:oWSNFe:cXML
										cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
									OtherWise
										cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
								EndCase
								cRodap := '</nfeProc>'
							EndIf
							FWrite(nHandle,AllTrim(cCab1))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
							FWrite(nHandle,AllTrim(cRodap))
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)

				 			cXML := AllTrim(cCab1)
							cXML += AllTrim(oXml:oWSNFe:cXML)
							cXML += AllTrim(oXml:oWSNFe:cXMLPROT)
							cXML += AllTrim(cRodap)
				 			If !Empty(cXML)
					 			If ExistBlock("FISEXPNFE")
		                   			ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
		               			Endif
				 			EndIF
				 		EndIf
				 	endif
			 	EndIf

			 	//----------------------------------------
			 	// Exporta MDF-e (Eventos)
			 	//----------------------------------------
				if (alltrim(FunName()) == 'SPEDMDFE')
					if ( (cModelo=="58") .and. (!empty(cChvNFe)) )
						//----------------------------------------
			 		 	// Executa o metodo NfeRetornaEvento()
						//----------------------------------------
						oWS:= WSNFeSBRA():New()
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= cIdEnt
						oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
						oWS:cEvenChvNFE	:= cChvNFe
						lOk				:= oWS:NFERETORNAEVENTO()

						if lOk
							if valType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"
								aDados := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento

								for nZ := 1 to len( aDados )
									//Zerando variaveis
									nHandle := 0
									nHandle := FCreate(cDestino + cChvNFe + "-" + cPrefixo + "_evento_" + alltrim(str(nZ)) + ".xml")
					 				if nHandle > 0
					 					cCab1 	:= '<?xml version="1.0" encoding="UTF-8"?>'
										cCab1 	+= '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVerMDfe+'">'
										cRodap	:= '</mdfeProc>
										fWrite(nHandle,allTrim(cCab1))
							 			fWrite(nHandle,allTrim(aDados[nZ]:cXML_RET))
							 			fWrite(nHandle,allTrim(aDados[nZ]:cXML_SIG))
										fWrite(nHandle,allTrim(cRodap))
							 			fClose(nHandle)
							 			aAdd(aDeleta,oXml:cID)
							 		endif
							 	next nZ
							endif
						endif
					endif
			 	else
				 	If ( oXml:OWSNFECANCELADA <> Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo) )
						cChave 	  := oXml:OWSNFECANCELADA:CXML
						If cModelo == "57" .and. cVerCte >='2.00'
							cChaveCc1 := At("<chCTe>",cChave)+7
						else
				 	   		cChaveCc1 := At("<chNFe>",cChave)+7
				 	   	endif
				 	   	cChaveCan := SubStr(cChave,cChaveCc1,44)

						oWS:= WSNFeSBRA():New()
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= cIdEnt
						oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
						oWS:cID_EVENTO	:= "110111"
						oWS:cChvInicial	:= cChaveCan
						oWS:cChvFinal	:= cChaveCan
						lOkCanc			:= oWS:NFEEXPORTAEVENTO()
						oRetEvCanc 	:= oWS:oWSNFEEXPORTAEVENTORESULT


						if lOkCanc

							ProcRegua(Len(oRetEvCanc:CSTRING))
							//---------------------------------------------------------------------------
							//| Exporta Cancelamento do Evento da Nf-e                                  |
							//---------------------------------------------------------------------------

						    For nY := 1 To Len(oRetEvCanc:CSTRING)
						 		cXml    := SpecCharc(oRetEvCanc:CSTRING[nY])
						 		oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
								If cModelo == "57" .and. cVerCte >='2.00'
						 			if Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
								       	cIdEven	:= 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
								  	elseIf Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
								  		cIdEven	:= 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
									endif

									If (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE")<>"U")
						 				cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
						 				cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
						 				cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE,.F.)
						 				cRodapCTe := '</procEventoCTe>'
						 				CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
									ElseIf (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO")<>"U")
						 				cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
						 				cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
						 				cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
						 				cRodapCTe := '</procEventoCTe>'
						 				CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
						 			EndIf

						 		else
									if Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
										cIdEven	:= oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
									else
										if Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID")<>"U"
											cIdEven  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
										EndIf
									endif
								endif


					 			nHandle := FCreate(cDestino+SubStr(cIdEven,3)+"-Canc.xml")
					 			if nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
						 			FClose(nHandle)
						 		endIf
						    Next nY
						Else
							cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id")
						 	cNotaIni := oXml:cID
							cIdflush := cNotaIni
					 		cNFes := cNFes+cNotaIni+CRLF
						 	If !"INUT"$oXml:oWSNFeCancelada:cXML
					 			nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can.xml")
					 			If nHandle > 0
					 				cCanc := oXml:oWSNFeCancelada:cXML
					 				If cModelo == "57"
					 					oXml:oWSNFeCancelada:cXML := '<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + oXml:oWSNFeCancelada:cXML + "</procCancCTe>"
					 				Else
					 					oXml:oWSNFeCancelada:cXML := '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + oXml:oWSNFeCancelada:cXML + "</procCancNFe>"
					 				EndIf
						 			FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
						 			FClose(nHandle)
						 			aadd(aDeleta,oXml:cID)
						 		EndIf
					 			nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can.xml")
					 			If nHandle > 0
						 			If cModelo == "57"
						 				FWrite(nHandle,'<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancCTe>")
						 			Else
										FWrite(nHandle,'<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancNFe>")
						 			EndIF
						 			FClose(nHandle)
						 		EndIf
							Else

		//						If Type("oXml:OWSNFECANCELADA:CXML")<>"U"
							 	    cXmlInut  := oXml:OWSNFECANCELADA:CXML
							 	    cAnoInut1 := At("<ano>",cXmlInut)+5
							 	    cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
							 	    cXmlProt  := EncodeUtf8(oXml:oWSNFeCancelada:cXMLPROT)
		//					 	EndIf
					 			nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,39)+"-ped-inu.xml")
					 			If nHandle > 0
						 			FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
						 			FClose(nHandle)
						 			aadd(aDeleta,oXml:cID)
						 		EndIf
					 			nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,39)+"-inu.xml")
					 			If nHandle > 0
						 			FWrite(nHandle,cXmlProt)
						 			FClose(nHandle)
						 		EndIf
						 	EndIf
						EndIf
					EndIf
				endif
				IncProc()
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui as notas                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN        := "TOTVS"
				oWS:cID_ENT           := cIdEnt
				oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0)
				oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:oWSNFEID          := NFESBRA_NFES2():New()
				oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
			    For nX := 1 To Len(aDeleta)
					aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
					Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX]
			    Next nX
				If !oWS:RETORNANOTAS()
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0046},3)
					lFlush := .F.
				EndIf
			EndIf
			aDeleta  := {}
		    If ( Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .And. Empty(cNfes) )
			   	Aviso("SPED",STR0106,{"Ok"})	// "Não há dados"
				lFlush := .F.
		    EndIf
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+STR0046,{"OK"},3)
			lFinal := .T.
		EndIf

		If lSdoc
			cIdflush := AllTrim(Substr(cIdflush,1,14) + Soma1(AllTrim(substr(cIdflush,15))))
		Else
			cIdflush :=  AllTrim(Substr(cIdflush,1,3) + Soma1(AllTrim(substr(cIdflush,4))))
		EndIf
		If lOk
			If cIdflush <= AllTrim(cNotaIni) .Or. Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .Or. Empty(cNfes) .Or. ;
			   cIdflush <= If(lSdoc,Substr(cNotaIni,1,14)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),15)))+Substr(Rtrim(cNotaIni),15),;
										Substr(cNotaIni,1,3)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),4)))+Substr(Rtrim(cNotaIni),4))// Importou o range completo
				lFlush := .F.
				If !Empty(cNfes)
					If Aviso("SPED",STR0152,{"Sim","Não"}) == 1	//"Solicitação processada com sucesso."
						if alltrim(FunName()) == 'SPEDMDFE'
							if empty(cNumMdfe)
								Aviso("SPED",STR0106,{"Ok"})	// "Não há dados"
							else
								Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNumMdfe,{"Ok"})
							endif
						else
							// Exporta Legado
							Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"Ok"})//STR0151-"XML Exportados para", "XML's Exportados para"
						endif
					EndIf
				else
					Aviso("SPED",STR0106,{"Ok"})	// "Não há dados"
				EndIf
			EndIf
		Else
			lFlush := .F.
		Endif
		delclassintf()
	ElseIf nTipo == 2  .Or. lUsaColab //Carta de Correcao e NF-e(QUANDO FOR TOTVS COLABORAÇÃO 2.0)

	        cWhere:="D_E_L_E_T_=' '"
	      If !Empty(cSerie)

	      		If lSdoc
	      			If cTipoNfe == "SAIDA"
			        	cWhere		+= " AND F2_SDOC ='"+SubStr(cSerie,1,3)+"'"
			        	cCondicao	+= AllTrim("F2_SDOC ='"+SubStr(cSerie,1,3)+"'")
		   	   		Else
		   	     		cWhere		+= " AND F1_SDOC ='"+SubStr(cSerie,1,3)+"'"
		        		cCondicao	+= AllTrim("F1_SDOC ='"+SubStr(cSerie,1,3)+"'")
		      		Endif
	      		Else
		        	If cTipoNfe == "SAIDA"
			        	cWhere		+= " AND F2_SERIE ='"+cSerie+"'"
			        	cCondicao	+= AllTrim("F2_SERIE ='"+cSerie+"'")
		   	   		Else
		   	     		cWhere		+= " AND F1_SERIE ='"+cSerie+"'"
		        		cCondicao	+= AllTrim("F1_SERIE ='"+cSerie+"'")
		      		Endif
				EndIf

			EndIf
	        If !Empty(cNotaIni)
	        	If cTipoNfe == "SAIDA"
		        	cWhere		+= " AND F2_DOC >='"+cNotaIni+"'"
		        	cCondicao 	+= AllTrim(" .AND. F2_DOC >='"+cNotaIni+"'")
		        Else
		        	cWhere		+= " AND F1_DOC >='"+cNotaIni+"'"
		        	cCondicao 	+= AllTrim(" .AND. F1_DOC >='"+cNotaIni+"'")
		        Endif
			EndIf
	        If !Empty(cNotaFim)
	        	If cTipoNfe == "SAIDA"
		       		cWhere		+= " AND F2_DOC <='"+cNotaFim+"'"
		        	cCondicao 	+= AllTrim(" .AND. F2_DOC <='"+cNotaFim+"'")
		        Else
		       		cWhere		+= " AND F1_DOC <='"+cNotaFim+"'"
		        	cCondicao 	+= AllTrim(" .AND. F1_DOC <='"+cNotaFim+"'")
		        Endif
			EndIf
			If !Empty(dDataDe)
	        	If cTipoNfe == "SAIDA"
					cWhere		+= " AND F2_EMISSAO >='"+DtoS(dDataDe)+"'"
		         	cCondicao 	+= " .AND. DTOS(F2_EMISSAO) >='"+DtoS(dDataDe)+"'"
		   		Else
					cWhere		+= " AND F1_EMISSAO >='"+DtoS(dDataDe)+"'"
		         	cCondicao 	+= " .AND. DTOS(F1_EMISSAO) >='"+DtoS(dDataDe)+"'"
		   		Endif
			EndIf
			If !Empty(dDataAte)
	        	If cTipoNfe == "SAIDA"
					cWhere		+= " AND F2_EMISSAO <='"+DtoS(dDataAte)+"'"
			      	cCondicao	+= " .AND. DTOS(F2_EMISSAO) <='"+DtoS(dDataAte)+"'"
			  	Else
					cWhere		+= " AND F1_EMISSAO <='"+DtoS(dDataAte)+"'"
			      	cCondicao	+= " .AND. DTOS(F1_EMISSAO) <='"+DtoS(dDataAte)+"'"
			  	Endif
			EndiF
			cWhere:="%"+cWhere+"%"
		#IFDEF TOP
        	If cTipoNfe == "SAIDA"
        		if lUsaColab
					BeginSql Alias cAlias
						SELECT F2_DOC, F2_SERIE, F2_TIPO, F2_CLIENTE, F2_LOJA
						FROM %Table:SF2%
						WHERE F2_FILIAL= %xFilial:SF2%
						AND	%Exp:cWhere%
					EndSql
					lExporta:=!(cAlias)->(Eof())
				else
					BeginSql Alias cAlias
						SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
						FROM %Table:SF2%
						WHERE F2_FILIAL= %xFilial:SF2%
						AND	%Exp:cWhere%
					EndSql
					SF2->(dbGoTo((cAlias)->RECINI))
					cChvIni := SF2->F2_CHVNFE
					SF2->(dbGoTo((cAlias)->RECFIN))
					cChvFin := SF2->F2_CHVNFE
					lExporta:=!(cAlias)->(Eof())
				endif
			Else
				if lUsaColab
					BeginSql Alias cAlias
						SELECT F1_DOC, F1_SERIE, F1_TIPO, F1_FORNECE, F1_LOJA
						FROM %Table:SF1%
						WHERE F1_FILIAL= %xFilial:SF1%
						AND	%Exp:cWhere%
					EndSql
					lExporta:=!(cAlias)->(Eof())
				else
					BeginSql Alias cAlias
						SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
						FROM %Table:SF1%
						WHERE F1_FILIAL= %xFilial:SF1%
						AND	%Exp:cWhere%
					EndSql
					SF1->(dbGoTo((cAlias)->RECINI))
					cChvIni := SF1->F1_CHVNFE
					SF1->(dbGoTo((cAlias)->RECFIN))
					cChvFin := SF1->F1_CHVNFE
					lExporta:=!(cAlias)->(Eof())
				endif
			Endif
		#ELSE
        	If cTipoNfe == "SAIDA"
				cAlias := "SF2"
				dbSetFilter({|| &cCondicao},cCondicao)
				if !lUsaColab
					(cAlias)->(dbGotop())
					cChvIni := SF2->F2_CHVNFE
					(cAlias)->(DbGoBottom())
					cChvFin := SF2->F2_CHVNFE
					lExporta:=!SF2->(Eof())
					(cAlias)->(dbClearFilter())
				else
					lClearFilter := .T.
					lExporta:=!SF2->(Eof())
				endif
			Else
				cAlias := "SF1"
				dbSetFilter({|| &cCondicao},cCondicao)
				If !lUsaColab
					(cAlias)->(dbGotop())
					cChvIni := SF1->F1_CHVNFE
					(cAlias)->(DbGoBottom())
					cChvFin := SF1->F1_CHVNFE
					lExporta:=!SF1->(Eof())
					(cAlias)->(dbClearFilter())
				else
					lClearFilter := .T.
					lExporta:=!SF1->(Eof())
				endif
			Endif
		#ENDIF

        If lExporta
        	If lUsaColab

				cCnpjDFim := iif(empty(cCnpjDFim),"99999999999999", cCnpjDFim)

        		(cAlias)->(dbGoTop())

        		While !(cAlias)->(Eof())

					if cTipoNfe == "SAIDA"
	        			cTab := 'F2_'
	        			cCmpCliFor := cTab+'CLIENTE'
	        		else
	        			cTab := 'F1_'
	        			cCmpCliFor := cTab+'FORNECE'
	        		endif

	        		cCmpNum 	:= cTab+'DOC'
	        		cCmpSer 	:= cTab+'SERIE'
	        		cCmpTipo	:= cTab+'TIPO'
	        		cCmpLoja	:= cTab+'LOJA'
	        		cPrefix := iif(nTipo == 1,IIF(lCTe,"CTe","NFe"),"CCe")

	        		//Tratamento para verificar se o CNPJ está no range inserido pelo usuário.
	        		lCnpj :=	.F.

					if cPrefix $ "CCe"
					 	lCnpj := .T.
					else

						If cTipoNfe == "SAIDA"
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							else
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							endif
						else
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							else
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							endif
						endif

						if cCnpj >= cCnpjDIni .And. cCnpj <= cCnpjDFim
							lCnpj := .T.
						endif
					endif

					If lCnpj
						cXML := ""

						aInfXml	:= {}
						aInfXml := ColExpDoc((cAlias)->&cCmpSer,(cAlias)->&cCmpNum,iif(nTipo == 1,IIF(lCTe,"CTE","NFE"),"CCE"),@cXml)
		 				/*
						 	aInfXml
						 	[1] - Logico se encotra documento .T.
						 	[2] - Chave do documento
						 	[3] - XML autorização - someente se autorizado
						 	[4] - XML Cancelamento Evento- somente se autorizado
						 	[5] - XML Ped. Inutilização - somente se autorizado
						 	[6] - XML Prot. Inutilização - somente se autorizado
						*/
						//Ponto de Entrada para permitir filtrar as NF
						If ExistBlock("SPDNFE01")
							If !ExecBlock("SPDNFE01",.f.,.f.,{aInfXml})
								(cAlias)->(dbSkip())
								loop
							Endif
	               	Endif
						//Encontrou documento
						if aInfXMl[1]

							if cPrefix == "CCe" .And. !Empty( aInfXMl[3] )
								nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-CCe.xml")
								cXML := aInfXMl[3]

								If nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
						 			FClose(nHandle)
					 			EndIf
					 			cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF

							elseif cPrefix $ "NFe|CTe"
								//Iinutilização
								if !Empty( aInfXMl[5] )
									cXmlInut  := aInfXMl[5]
									cAnoInut1 := At("<ano>",cXmlInut)+5
									cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
									cXmlProt  := aInfXMl[6]


							 		nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3,2)+cAnoInut+SubStr(aInfXMl[2],5,39)+"-ped-inu.xml")
						 			If nHandle > 0
							 			FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
							 			FClose(nHandle)
							 			aadd(aDeleta,oXml:cID)
							 		EndIf
						 			nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(aInfXMl[2],5,39)+".xml")
						 			If nHandle > 0
							 			FWrite(nHandle,cXmlProt)
							 			FClose(nHandle)
							 		EndIf
							 		cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
								//Cancelamento
								if !Empty( aInfXMl[4] )
									cXml    := SpecCharc(aInfXMl[4])
						 			nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-canc.xml")
						 			if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
							 			FClose(nHandle)
							 		endIf
							 		cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif

								if !Empty( aInfXML[3] )
									cXml    := SpecCharc(aInfXMl[3])

					 				If ExistBlock("FISEXPNFE")
			                   		ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
						 			EndIF

						 			nHandle := FCreate(cDestino+SubStr(aInfXMl[2],4)+"-"+cPrefix+".xml")
						 			if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
							 			FClose(nHandle)
							 		endIf

							 		cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
							endif
							IncProc()
						 endif
					endif
        			(cAlias)->(dbSkip())
        		enddo
        		If !Empty(cNfes)
	        		If Aviso("SPED",STR0152,{"Sim","Não"}) == 1	//"Solicitação processada com sucesso."
						Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{STR0114},3)//STR0151-"XML Exportados para", "XML's Exportados para"
					EndIf
				endif
				delclassintf()
			else
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN	:= "TOTVS"
				oWS:cID_ENT		:= cIdEnt
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cChvInicial	:= cChvIni
				oWS:cChvFinal	:= cChvFin
				lOk:= oWS:NFEEXPORTAEVENTO()
				oRetorno := oWS:oWSNFEEXPORTAEVENTORESULT

				If lOk

					ProcRegua(Len(oRetorno:CSTRING))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exporta as cartas                                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				    For nX := 1 To Len(oRetorno:CSTRING)
				 		cXml    := oRetorno:CSTRING[nX]
				 		cXml	 := EncodeUTF8(cXml)
				 		oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
						If Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
							cIdCCe	:= oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
						Elseif Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT")<> "U"
							cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
						Else
							cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_INFEVENTO:_ID:TEXT
						Endif

						If (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO")<>"U")
					 		cVerCte := Iif(Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_VERSAO:TEXT ") <> "U", oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_VERSAO:TEXT , '')
					 		cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
					 		cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
					 		cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
					 		cRodapCTe := '</procEventoCTe>'
					 		cXml:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
					    EndIf

			 			nHandle := FCreate(cDestino+SubStr(cIdCCe,3)+"-CCe.xml")
			 			If nHandle > 0
							FWrite(nHandle,AllTrim(cXml))
				 			FClose(nHandle)
				 		EndIf
						IncProc()
					    cNFes+=SubStr(cIdCCe,31,3)+"/"+SubStr(cIdCCe,34,9)+CRLF
				    Next nX

				   	If Aviso("SPED",STR0152,{"Sim","Não"}) == 1	//"Solicitação processada com sucesso."
						Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{STR0114},3) //STR0151-"XML Exportados para", "XML's Exportados para"
					EndIf
				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
					lFinal := .T.
				EndIF
				delclassintf()
			endif
		EndIf
		#IFDEF TOP
			If select (cAlias)>0
			 	(cAlias)->(dbCloseArea())
			EndIf
		#ENDIF
		lFlush := .F.
	EndIF
EndDo

Return(.T.)

Function EntAtivTss()
Return (SpedEntAtiv())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função para verificar se a empresa esta ativa ou não para o SPED NF-e³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function SpedEntAtiv()

Local cEntAtiv	:= AllTrim(GetNewPar("MV_SPEDENT","S"))
local cError	:= ""
Local lOk		:= .F.
Local lEntAtiva := .T.
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)

if( IsReady() )
	lOk := checkActiveEnt(, @cError)
endif

If (cEntAtiv $ " N" )
	Aviso("SPED",STR0154,{STR0114},3) //"Empresa desativada para operar no SPED! Entre em contato com o Administrador do sistema."
	lEntAtiva := .F.
EndIf

Return (lEntAtiva)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNSeRem³ Autor ³Cleber Stenio          ³ Data ³17.08.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal de Serviço eletronica      ³±±
±±³          ³para o TOTVS Service SPED                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNSeRemessa()

SpedNSeRe2()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNSeRe2³ Autor ³Cleber Stenio          ³ Data ³17.08.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal de Serviço eletronica      ³±±
±±³          ³para o TOTVS Service SPED - utilizada em personalizacoes    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie da NF                                          ³±±
±±³          ³ExpC2: Nota inicial                                         ³±±
±±³          ³ExpC3: Nota final                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNSeRe2(cSerie,cNotaIni,cNotaFim,cCombo1)

Local aArea       := GetArea()
Local aPerg       := {}
Local aParam      := {Space(If(TamSx3("F2_SERIE")[1] == 14,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(20),CtoD(""),CtoD("")}
Local aTexto      := {}
Local aXML        := {}
Local cRetorno    := ""
Local cIdEnt      := ""
Local cAmbiente   := ""
Local cVersaoNSe  := ""
Local cMonitorSEF := ""
Local cSugestao   := ""
Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local nX          := 0
Local lOk         := .T.
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
Local oWs
Local oWizard
Local cParNSeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNSEREM"
Local aCombo1:= {}

aadd(aCombo1,STR0176) //"1-Modelo BH"
aadd(aCombo1,STR0177) //"2-Modelo ISSNET"

If cSerie == Nil
	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNSeRem,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNSeRem,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNSeRem,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
	MV_PAR04 := aParam[04] := ParamLoad(cParNSeRem,aPerg,4,aParam[04])
Else
	MV_PAR01 := aParam[01] := cSerie
	MV_PAR02 := aParam[02] := cNotaIni
	MV_PAR03 := aParam[03] := cNotaFim
	MV_PAR04 := aParam[04] := cCombo1
EndIf

aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"
aadd(aPerg,{2,STR0175,aParam[04],aCombo1,60,".T.",.T.,".T."}) //"Modelo Xml"

If lSdoc
	aadd(aPerg,{1,"Dt. Emissão De"	,aParam[05],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"
	aadd(aPerg,{1,"Dt. Emissão Até"	,aParam[06],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"

	aParam[05] := PadR(ParamLoad(cParNSeRem,aPerg,5,aParam[05]),Len(SF2->F2_EMISSAO))
	aParam[06] := PadR(ParamLoad(cParNSeRem,aPerg,6,aParam[06]),Len(SF2->F2_EMISSAO))
EndIf

If IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt()

	If !Empty(cIdEnt)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o ambiente de execucao do Totvs Services SPED                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oWS := WsSpedCfgNFe():New()
		oWS:cUSERTOKEN    := "TOTVS"
		oWS:cID_ENT       := cIdEnt
		oWS:nAmbienteNse  := 0
		oWS:_URL          := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		lOk := oWS:CFGAMBIENTENSE()
		cAmbiente := oWS:cCfgAmbienteNSeResult
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem a versao de trabalho da NFe do Totvs Services SPED                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOk
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:cVersao    := "0.00"
			oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk := oWS:CFGVersaoNSe()
			cVersaoNSe     := oWS:cCfgVersaoNSeResult
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Interface                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lOk == .T. .or. lOk == Nil)
			aadd(aTexto,{})
			aTexto[1] := STR0171+" " //"Esta rotina tem como objetivo auxilia-lo na transmissão da Nota Fiscal de Serviço eletrônica para o serviço Totvs Services SPED. "
			aTexto[1] += STR0014+CRLF+CRLF //"Neste momento o Totvs Services SPED, está operando com a seguinte configuração: "
			aTexto[1] += STR0015+cAmbiente+CRLF //"Ambiente: "

			aadd(aTexto,{})

			DEFINE WIZARD oWizard ;
				TITLE STR0172;
				HEADER STR0019;
				MESSAGE STR0155;
				TEXT aTexto[1] ;
				NEXT {|| .T.} ;
				FINISH {||.T.}

			CREATE PANEL oWizard  ;
				HEADER STR0172 ;//"Assistente de transmissão da Nota Fiscal Eletrônica"
				MESSAGE ""	;
				BACK {|| .T.} ;
				NEXT {|| ParamSave(cParNSeRem,aPerg,"1"),Processa({|lEnd| cRetorno := SpedNSeTrf(aArea[1],aParam[1],aParam[2],aParam[3],aParam[4],cIdEnt,cAmbiente,cVersaoNSe,@lEnd,aParam[05],aParam[06])}),aTexto[02]:= cRetorno,.T.} ;
				PANEL
		    ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,oWizard:oMPanel[2],cParNSeRem,.T.,.T.)

			CREATE PANEL oWizard  ;
				HEADER STR0172;//"Assistente de configuração da Nota Fiscal Eletrônica"
				MESSAGE "";
				BACK {|| .T.} ;
				FINISH {|| .T.} ;
				PANEL
			@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
			ACTIVATE WIZARD oWizard CENTERED
			If AllTrim(aParam[04]) == "CT-e"
				TMS70INUT(aParam)
			EndIf
		EndIf
	EndIf
Else

	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsNSeRead³ Autor ³Cleber Stenio           ³ Data ³28.03.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se os Parametros da NSe foram preenchidos.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Regime Tibutação                                     ³±±
±±³          ³ExpC2: Simples Nacional                                     ³±±
±±³          ³ExpC3: Incentivador Cultural                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsNSeRead(nTrib,nSimples,nIncent)

Local oWS
Local cIdEnt   := ""
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lRetorno := .T.

cIdEnt := AllTrim(GetIdEnt())
If !Empty(cIdEnt)
		oWs:= WsSpedCfgNFe():New()
		oWs:cUSERTOKEN      := "TOTVS"
		oWs:cID_ENT         := cIdEnt
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWs:oWSPARNSE                      := SPEDCFGNFE_PARAMNSE():New()
		oWs:oWSPARNSE:cIncCult             := AllTrim(Str(nIncent))
		oWs:oWSPARNSE:cRegTrib             := AllTrim(Str(nTrib))
		oWs:oWSPARNSE:cSimpNac             := AllTrim(Str(nSimples))
		If oWs:CfgParamNSe()
			Aviso("SPED",oWS:cCfgParamNSEResult,{STR0114},3)
		Else
			lRetorno := .F.
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIf
EndIf
Return(lRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNSeTrf³ Autor ³Cleber Stenio          ³ Data ³16.09.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota de Serviço eletronica para o Totvs³±±
±±³          ³Service SPED                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Mensagem de retorno                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela da Mbrowse                           ³±±
±±³          ³ExpC2: Serie                                                ³±±
±±³          ³ExpC3: Nota inicial                                         ³±±
±±³          ³ExpC4: Nota final                                           ³±±
±±³          ³ExpC5: Id da entidade empresarial                           ³±±
±±³          ³ExpC6: Ambiente de emissao da NFe                           ³±±
±±³          ³ExpC7: Versa da NFe                                         ³±±
±±³          ³ExpL8: Controle de encerramento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SpedNSeTrf(cAlias,cSerie,cNotaIni,cNotaFim,cModXml,cIDEnt,cAmbiente,cVersao,lEnd,dDataDe,dDataAte)

Local aArea     := GetArea()
Local aNotas    := {}
Local aRetNotas := {}
Local cRetorno  := ""
Local aXml      := {}
Local cAliasSF3 := "SF3"
Local cCampos := ""
Local cSerWhere	 := ""
Local cSerId    := ""
Local cWhere    := ""
Local cAviso    := ""
Local cErro     := ""
Local lQuery    := .F.
Local lRetorno  := .T.
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local nW        := 0
Local cNewXML	:=""
Local nNFes     := 0
Local nXmlSize  := 0
Local dDataIni  := Date()
Local cHoraIni  := Time()
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local oWNSe

Default dDataDe := CtoD("")
Default dDataAte := CtoD("")

Private oNFSe

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina caso exista filtro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbClearFilter()
RetIndex(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa parametros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAmbiente   := SubStr(cAmbiente,1,1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cancela as notas do dia anterior                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SpedNSeCan(cEmpAnt,cFilAnt,cIdEnt,cAmbiente,cVersao)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as notas fiscais do dia                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(Val(cNotaFim)-Val(cNotaIni)+1)
dbSelectArea("SF3")
dbSetOrder(5)
#IFDEF TOP
	cWhere := "%(SubString(SF3.F3_CFO,1,1) >= '5')"
	cAliasSF3 := GetNextAlias()
	lQuery    := .T.

	If lSdoc
		If !Empty(dDataDe) .And. !Empty(dDataAte)
			cCampos += ", SF3.F3_SDOC"
			cSerWhere := Padr(cSerie,TamSx3("F3_SDOC")[1])
			cWhere += " AND SF3.F3_SDOC = '"+ cSerWhere + "' AND SF3.F3_EMISSAO >= '"+ DtoS(dDataDe) + "' AND SF3.F3_EMISSAO <= '"+ DtoS(dDataAte) + "'%"
		Else
			cCampos += ", SF3.F3_SDOC"
			cSerWhere := Padr(cSerie,TamSx3("F3_SDOC")[1])
			cWhere += " AND SF3.F3_SDOC = '"+ cSerWhere + "'%"
		EndIf
	Else
		cSerWhere := Padr(cSerie,TamSx3("F3_SERIE")[1])
		cWhere += " AND SF3.F3_SERIE = '"+ cSerWhere + "'%"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos que serao adicionados a query somente se existirem na base³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCampos)
		cCampos := "%%"
	Else
		cCampos := "% " + cCampos + " %"
	Endif

	BeginSql Alias cAliasSF3

	COLUMN F3_ENTRADA AS DATE
	COLUMN F3_DTCANC AS DATE

	SELECT	F3_FILIAL,F3_ENTRADA,F3_NFeLETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
			FROM %Table:SF3% SF3
			WHERE
			SF3.F3_FILIAL = %xFilial:SF3% AND
			SF3.F3_NFISCAL >= %Exp:cNotaIni% AND
			SF3.F3_NFISCAL <= %Exp:cNotaFim% AND
			%Exp:cWhere% AND
			SF3.F3_DTCANC = %Exp:Space(8)% AND
			SF3.%notdel%
	EndSql
	cWhere := ".T."
#ELSE
	MsSeek(xFilial("SF3")+cSerie+cNotaIni,.T.)
#ENDIF
cWhere := "(SubStr(F3_CFO,1,1) >= '5')"

If lSdoc
	cSerId := (cAliasSF3)->F3_SDOC
Else
	cSerId := (cAliasSF3)->F3_SERIE
EndIf

While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
	cSerId == cSerie .And.;
	(cAliasSF3)->F3_NFISCAL >= cNotaIni .And.;
	(cAliasSF3)->F3_NFISCAL <= cNotaFim

	dbSelectArea(cAliasSF3)
	If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5") .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL})==0

		IncProc("(1/2) "+STR0022+(cAliasSF3)->F3_NFISCAL) //"Preparando nota: "

		If "RPS"$(cAliasSF3)->F3_ESPECIE .And. Empty((cAliasSF3)->F3_DTCANC).And. &cWhere
			aadd(aNotas,{})
			nX := Len(aNotas)
			aadd(aNotas[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
			aadd(aNotas[nX],(cAliasSF3)->F3_ENTRADA)
			aadd(aNotas[nX],(cAliasSF3)->F3_SERIE)
			aadd(aNotas[nX],(cAliasSF3)->F3_NFISCAL)
			aadd(aNotas[nX],(cAliasSF3)->F3_CLIEFOR)
			aadd(aNotas[nX],(cAliasSF3)->F3_LOJA)
		EndIf
	EndIf
	dbSelectArea(cAliasSF3)
	dbSkip()

	If lSdoc
		cSerId := (cAliasSF3)->F3_SDOC
	Else
		cSerId := (cAliasSF3)->F3_SERIE
	EndIf

EndDo
If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
	dbSelectArea("SF3")
EndIf
ProcRegua(Len(aNotas))

oWs:= WsNFeSBra():New()
oWs:cUserToken := "TOTVS"
oWs:cID_ENT    := cIdEnt
oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
For nX := 1 To Len(aNotas)
	IncProc("(2/2) "+STR0023+aNotas[nX][4]) //"Transmitindo XML da nota: "
	aXml := ExecBlock("XmlNFeSef",.F.,.F.,aNotas[nX])
	nXmlSize2 := Len(aXML[2])
	If !Empty(aXML[2]) .And. nXmlSize2 <= TAMMAXXML
		nNFes++
		nY++
		oNFSe := XmlParser(aXML[2],"_",@cAviso,@cErro)

    	oWNSe:= WsSpedCfgNFe():New()
		oWNSe:cUSERTOKEN      := "TOTVS"
		oWNSe:cID_ENT         := cIdEnt
		oWNSe:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"

		If "1"$cModXml //BH ABRASF
			If oWNSe:GetParamNse()
	   		    If Type("oNFSe:_INFRPS")<>"U"
		    		If Type("oNFSe:_INFRPS:_REGIMEESPECIALTRIBUTACAO:TEXT")<>"U"
		    			oNFSe:_INFRPS:_REGIMEESPECIALTRIBUTACAO:TEXT := oWNSe:oWSGETPARAMNSERESULT:cREGTRIB
		    		EndIf
		    		If Type("oNFSe:_INFRPS:_OPTANTESIMPLESNACIONAL:TEXT")<>"U"
		    			oNFSe:_INFRPS:_OPTANTESIMPLESNACIONAL:TEXT := oWNSe:oWSGETPARAMNSERESULT:cSIMPNAC
		    		EndIf
		    		If Type("oNFSe:_INFRPS:_INCENTIVADORCULTURAL:TEXT")<>"U"
		    			oNFSe:_INFRPS:_INCENTIVADORCULTURAL:TEXT := oWNSe:oWSGETPARAMNSERESULT:cINCCULT
		    		EndIf
		 		EndIf
	    	EndIf

	    	aXML[2]:= XMLSaveStr(oNFSe:_INFRPS,.F.)

	    	//Quando o Regime é N.D.A retiro a tag do xml
			If Type("oNFSe:_INFRPS:_REGIMEESPECIALTRIBUTACAO:TEXT")<>"U"
				If oNFSe:_INFRPS:_REGIMEESPECIALTRIBUTACAO:TEXT=="7"

			    	nZ := At("<RegimeEspecialTributacao>",aXML[2])//Posição inicial da tag RegimeEspecialTributacao
		   			nW := At("</RegimeEspecialTributacao>",aXML[2])//Posição final da tag RegimeEspecialTributacao
			        cNewXML := SubStr(aXML[2],1,nZ-1)//Conteudo inicio do XML
					cNewXML := cNewXML + SubStr(aXML[2],nW+27,Len(aXML[2]))//Conteudo final do XML
					aXML[2] := cNewXML

		    	EndIf
   			EndIf

		Else //ISSNET
			If oWNSe:GetParamNse()
	   		    If Type("oNFSe:_TC_INFRPS")<>"U"
		    		If Type("oNFSe:_TC_INFRPS:_TC_REGIMEESPECIALTRIBUTACAO:TEXT")<>"U"
		    			oNFSe:_TC_INFRPS:_TC_REGIMEESPECIALTRIBUTACAO:TEXT := oWNSe:oWSGETPARAMNSERESULT:cREGTRIB
		    		EndIf
		    		If Type("oNFSe:_TC_INFRPS:_TC_OPTANTESIMPLESNACIONAL:TEXT")<>"U"
		    			oNFSe:_TC_INFRPS:_TC_OPTANTESIMPLESNACIONAL:TEXT := oWNSe:oWSGETPARAMNSERESULT:cSIMPNAC
		    		EndIf
		    		If Type("oNFSe:_TC_INFRPS:_TC_INCENTIVADORCULTURAL:TEXT")<>"U"
		    			oNFSe:_TC_INFRPS:_TC_INCENTIVADORCULTURAL:TEXT := oWNSe:oWSGETPARAMNSERESULT:cINCCULT
		    		EndIf
		 		EndIf
	    	EndIf

	    	aXML[2]:= XMLSaveStr(oNFSe:_TC_INFRPS,.F.)


	    	//Quando o Regime é N.D.A retiro a tag do xml
			If Type("oNFSe:_TC_INFRPS:_TC_REGIMEESPECIALTRIBUTACAO:TEXT")<>"U"
				If oNFSe:_TC_INFRPS:_TC_REGIMEESPECIALTRIBUTACAO:TEXT=="7"

			    	nZ := At("<tc:RegimeEspecialTributacao>",aXML[2])//Posição inicial da tag RegimeEspecialTributacao
		   			nW := At("</tc:RegimeEspecialTributacao>",aXML[2])//Posição final da tag RegimeEspecialTributacao
			        cNewXML := SubStr(aXML[2],1,nZ-1)//Conteudo inicio do XML
					cNewXML := cNewXML + SubStr(aXML[2],nW+30,Len(aXML[2]))//Conteudo final do XML
					aXML[2] := cNewXML

		    	EndIf
   			EndIf


		EndIf

		nXmlSize += Len(aXML[2])
		aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())

		aadd(aRetNotas,aNotas[nX])

		oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cID := aNotas[nX][3]+aNotas[nX][4]
		oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cXML:= aXML[2]
	ElseIf nXmlSize2 > TAMMAXXML
		Aviso("SPED ",STR0149+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+STR0150+aNotas[nX][4]+" / "+SubStr(aNotas[nX][3],1,3),{STR0114},3)
		nXmlSize2 := 0
	Else
		Aviso("SPED",STR0181,{STR0114},3)
		nXmlSize2 := 0
	EndIf
	If ((nY >=50 .Or. nX == Len(aNotas) .Or. nXmlSize>=TAMMAXXML) .And. nNFes > 0)
		If nXmlSize>0 .And. oWs:Remessa()
			If Len(oWs:oWsRemessaResult:oWSID:cString) <> nY
				cErro := STR0024+CRLF+CRLF //"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
			EndIf
			For nY := 1 To Len(aRetNotas)
				If Len(oWs:oWsRemessaResult:oWSID:cString) <> nY
					If aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][3]+aRetNotas[nY][4])==0
						cErro += "NSe: "+aRetNotas[nY][3]+aRetNotas[nY][4]+CRLF
					EndIf
				EndIf
		    	If aRetNotas[nY][1] == "0"
		    		If SF1->(FieldPos("F1_FIMP"))>0
			    		dbSelectArea("SF1")
			    		dbSetOrder(1)
			    		If MsSeek(xFilial("SF1")+aRetNotas[nY][4]+aRetNotas[nY][3]+aRetNotas[nY][5]+aRetNotas[nY][6]) .And. SF1->F1_FIMP$"N, "
		    			   RecLock("SF1")
		    			   SF1->F1_FIMP := IIF(aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][3]+AllTrim(aRetNotas[nY][4]))==0,"N","T")
		    			   MsUnlock()
		    			EndIf
					EndIf
		    	Else
		    		dbSelectArea("SF2")
		    		dbSetOrder(1)
		    		If MsSeek(xFilial("SF2")+aRetNotas[nY][4]+aRetNotas[nY][3]+aRetNotas[nY][5]+aRetNotas[nY][6]) .And. SF2->F2_FIMP$"N, "
	    			   RecLock("SF2")
	    			   SF2->F2_FIMP := IIF(aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][3]+AllTrim(aRetNotas[nY][4]))==0,"N","T")
	    			   MsUnlock()
	    			EndIf
		        EndIf
			Next nY
			oWs:= WsNFeSBra():New()
			oWs:cUserToken := "TOTVS"
			oWs:cID_ENT    := cIdEnt
			oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
			oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
			nY := 0
			nXmlSize := 0
			aRetNotas := {}
		Else
			cErro := GetWscError(3)
			DEFAULT cErro := STR0025 //"Erro indeterminado"
			lRetorno := .F.
			Exit
        EndIf
	EndIf
Next nX
If lRetorno
	cRetorno := STR0026+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
	cRetorno += STR0174+CRLF+CRLF //"Verifique se as notas foram autorizadas na SEFAZ, utilizando a rotina 'Monitor'. Antes de imprimir"
	cRetorno += STR0028+AllTrim(Str(nNFes,18))+STR0029+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
	cRetorno += cErro
Else
	cRetorno := STR0029+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
	cRetorno += cErro
EndIf

IF VALTYPE(bFiltraBrw) == "B"
	Eval(bFiltraBrw)
ENDIF
RestArea(aArea)

Return(cRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNSeCan³ Autor ³Cleber Stenio          ³ Data ³16.09.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de cancelamento da NFe para o Totvs Services SPED    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Empresa                                              ³±±
±±³          ³ExpC2: Filial                                               ³±±
±±³          ³ExpC3: Codigo da Entidade                                   ³±±
±±³          ³ExpC4: Ambiente                                             ³±±
±±³          ³ExpC5: Versao                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNSeCan(cCodEmp,cCodFil,cIdEnt,cAmbiente,cVersao)

MsgRun(STR0130,STR0156,{|| JobNSeCan(cIdEnt,cAmbiente,cVersao)}) //"Aguarde"###"Processando Transmissão NS-e"

Return

Static Function JobNSeCan(cIdEnt,cAmbiente,cVersao)
Local aArea     := GetArea()
Local aNotas    := {}
Local cIndice   := ""
Local aXml      := {}
Local cAliasSF3 := "SF3"
Local cWhere    := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cModelo   := "56"
Local lQuery    := .F.
Local lRetorno  := .T.
Local nX        := 0
Local nY        := 0
Local oWs

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa parametros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAmbiente   := SubStr(cAmbiente,1,1)

dbSelectArea("SF3")
dbSetOrder(5)
#IFDEF TOP
	If SF3->(FieldPos("F3_CODRSEF")) > 0
		cWhere := "%(SubString(SF3.F3_CFO,1,1) >= '5')"
		cWhere += " AND ( (SF3.F3_ESPECIE <> 'SPED' AND SF3.F3_CODRSEF NOT IN ('110','301','302','303','304','305','306'))"
		cWhere += " OR 	  (SF3.F3_ESPECIE = 'SPED' AND SF3.F3_CODRSEF NOT IN ('110','205','301','302')) )%"
	Else
   		cWhere := "%(SubString(SF3.F3_CFO,1,1) >= '5')%"
	Endif
	cAliasSF3 := GetNextAlias()
	lQuery    := .T.
	BeginSql Alias cAliasSF3

	COLUMN F3_ENTRADA AS DATE
	COLUMN F3_DTCANC AS DATE

	SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
			FROM %Table:SF3% SF3
			WHERE
			SF3.F3_FILIAL = %xFilial:SF3% AND
			SF3.F3_ENTRADA >= %Exp:dDataBase-30% AND
			SF3.F3_DTCANC  >= %Exp:dDataBase-30% AND
			%Exp:cWhere% AND
			SF3.%notdel%
	EndSql
	cWhere := ".T."
#ELSE
	cIndice := CriaTrab(,.F.)
	cWhere := "(SubStr(F3_CFO,1,1) >= '5')"
	IndRegua("SF3",cIndice,SF3->(IndexKey()),,"F3_FILIAL=='"+xFilial("SF3")+"' .AND. DTOS(F3_EMISSAO)>='"+DTOS(dDataBase-30)+"' .AND. DTOS(F3_DTCANC)>='"+DTOS(dDataBase-30)+"' .AND. "+cWhere)
	dbGotop()
#ENDIF
While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .and. !Empty((cAliasSF3)->F3_DTCANC)
	dbSelectArea(cAliasSF3)
	If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5") .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL})==0
		If "RPS"$(cAliasSF3)->F3_ESPECIE .And. &cWhere
			aadd(aNotas,{})
			nX := Len(aNotas)
			aadd(aNotas[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
			aadd(aNotas[nX],(cAliasSF3)->F3_ENTRADA)
			aadd(aNotas[nX],(cAliasSF3)->F3_SERIE)
			aadd(aNotas[nX],(cAliasSF3)->F3_NFISCAL)
			aadd(aNotas[nX],(cAliasSF3)->F3_CLIEFOR)
			aadd(aNotas[nX],(cAliasSF3)->F3_LOJA)
			aadd(aNotas[nX],"56")
		EndIf
	EndIf
	dbSelectArea(cAliasSF3)
	dbSkip()
EndDo
If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
	dbSelectArea("SF3")
Else
	RetIndex("SF3")
	FErase(cIndice+OrdBagExt())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transmite as NFe canceladas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWs:= WsNFeSBra():New()
oWs:cUserToken := "TOTVS"
oWs:cID_ENT    := cIdEnt
oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
For nX := 1 To Len(aNotas)
	cModelo := aNotas[nX][7]
	nY++
	aadd(oWs:oWsNFe:oWsNotas:oWSNFES,NFESBRA_NFES():New())
	oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cID := aNotas[nX][3]+aNotas[nX][4]
	oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= GetUFCode(SM0->M0_ESTCOB)+FsDateConv(aNotas[nX][2],"YYMM")+PADL(ALLTRIM(SM0->M0_CGC),14,"0")+cModelo+StrZero(Val(aNotas[nX][3]),3)+StrZero(Val(aNotas[nX][4]),9)+Inverte(StrZero(Val(aNotas[nX][4]),9))
	
	oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= 'Id="' +	oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML + Modulo11(oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML) + '"'
	If ExistBlock("FISCANNFE")
		oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML := ExecBlock("FISCANNFE",.F.,.F.,{oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML,aNotas[nX]})
	EndIf
	If nY >=50 .Or. nX == Len(aNotas)
		If oWs:CancelaNotas()
			oWs:= WsNFeSBra():New()
			oWs:cUserToken := "TOTVS"
			oWs:cID_ENT    := cIdEnt
			oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
			oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
			nY := 0
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
        EndIf
	EndIf
Next nX

RestArea(aArea)
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNSeCFG³ Autor ³Cleber Stenio          ³ Data ³18.08.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configura o Totvs Services para a nota fiscal eletronica    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNSeCFG()

Local oWizard
Local oCombo
Local oCombo1
Local oCombo2
Local oCombo3
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cCert     := Space(250)
Local cKey      := Space(250)
Local cModulo   := Space(250)
Local cPassWord := Space(24)
Local cCombo    := ""
Local cCombo1   := ""
Local cCombo2   := ""
Local cCombo3   := ""
Local cSlot     := Space(4)
Local cLabel    := Space(250)
Local cIdHex	:= ""
Local aTexto    := {}
Local aPerg     := {}
Local aParam    := {}
Local lUsaIdHex := GetNewPar("MV_A3IDHEX",.F.)

aadd(aParam,PadR(SuperGetMv("MV_RELSERV"),250))
If SuperGetMv("MV_RELAUTH",,.F.)
	aadd(aParam,PadR(SuperGetMv("MV_RELACNT",,""),250))
Else
	aadd(aParam,PadR(SuperGetMv("MV_RELFROM",,""),250))
EndIf
aadd(aParam,PadR(SuperGetMv("MV_RELPSW"),250))
aadd(aParam,PadR(SuperGetMv("MV_RELFROM",,""),250))
aadd(aParam,SuperGetMv("MV_RELAUTH",,.F.))
aadd(aParam,PadR("",250))

aadd(aPerg,{1,STR0085,aParam[1],"",".T.","",".T.",120,.F.})	//"Servidor SMTP"
aadd(aPerg,{1,STR0086,aParam[2],"",".T.","",".T.",120,.F.})	//"Login do e-mail"
aadd(aPerg,{1,STR0087,aParam[3],"",".T.","",".T.",120,.F.})	//"Senha"
aadd(aPerg,{1,STR0090,aParam[4],"",".T.","",".T.",120,.F.})	//"Conta de e-mail"
aadd(aPerg,{4,STR0088,aParam[5],STR0089,040,".T.",.F.})       //"Autenticação"###"Requerida"
aadd(aPerg,{1,STR0128,aParam[6],"",".T.","",".T.",120,.F.})	//"Conta de e-mail de notificação"


If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Interface                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aTexto,{})
	aTexto[1] := STR0038+CRLF //"Esta rotina tem como objetivo ajuda-lo na configuração da integração com o Protheus com o serviço Totvs Services SPED. "
	aTexto[1] += STR0039 //"O primeiro passo é configurar a conexão do Protheus com o serviço."

	aadd(aTexto,{})
	aTexto[2] := STR0040

	DEFINE WIZARD oWizard ;
		TITLE STR0041; //"Assistente de configuração da Nota Fiscal Eletrônica"
		HEADER STR0019; //"Atenção"
		MESSAGE STR0020; //"Siga atentamente os passos para a configuração da nota fiscal eletrônica."
		TEXT aTexto[1] ;
		NEXT {|| .T.} ;
		FINISH {||.T.}

	CREATE PANEL oWizard  ;
		HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
		MESSAGE ""	;
		BACK {|| .F.} ;
		NEXT {|| IsReady(cURL,3,.T.)} ;
		PANEL

	@ 010,010 SAY STR0042 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] //"Informe a URL do servidor Totvs Services"
	@ 025,010 GET cURL SIZE 270,010 PIXEL OF oWizard:oMPanel[2]

	CREATE PANEL oWizard  ;
		HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
		MESSAGE ""	;
		BACK {|| .T.} ;
		NEXT {|| IsCDReady(@oCombo:nAt,@cCert,@cKey,@cPassWord,@cSlot,@cLabel,@cModulo,@cIdHex)} ;
		PANEL

	@ 005,010 SAY STR0095 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o tipo de certificado digital"
	@ 005,105 COMBOBOX oCombo VAR cCombo ITEMS {STR0096,STR0097,STR0132} SIZE 120,010 OF oWizard:oMPanel[3] PIXEL //"Formato Apache(.pem)"###"Formato PFX(.pfx ou .p12)"###"HSM"
	@ 020,010 SAY STR0043 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo do certificado digital"
	@ 030,010 GET cCert SIZE 240,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt <> 3
	TButton():New( 030,250,STR0044,oWizard:oMPanel[3],{||cCert := cGetFile(IIF(oCombo:nAt == 1,STR0045,STR0098),STR0072,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) //"Drive:"###"Arquivos .PEM |*.PEM","Selecione o certificado"
	@ 050,010 SAY STR0046 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo da private key"
	@ 060,010 GET cKey SIZE 240,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 1
	TButton():New( 060,250,STR0044,oWizard:oMPanel[3],{||cKey := cGetFile(STR0045,STR0072,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) // //"Drive:"###"Arquivos .PEM |*.PEM","Selecione o certificado"
	@ 080,010 SAY STR0133 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"Slot do certificado digital"
	@ 080,100 GET cSlot SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3 PICTURE "9999"
	If lUsaIdHex
		@ 095,010 SAY STR0376 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"ID Hex do certificado digital"
		@ 095,100 GET cIdHex SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	Else
		@ 095,010 SAY STR0134 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"Label do certificado digital"
		@ 095,100 GET cLabel SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	EndIF
	@ 110,010 SAY STR0047 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe senha do arquivo digital"
	@ 110,110 GET cPassWord SIZE 060,010 PIXEL OF oWizard:oMPanel[3] PASSWORD
	@ 125,010 SAY STR0135 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo do modulo HSM"
	@ 125,120 GET cModulo SIZE 100,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	//TButton():New( 125,250,STR0044,oWizard:oMPanel[3],{||cKey := cGetFile(STR0136,STR0137,0,"",.T.,GETF_ONLYSERVER),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) // //"Drive:"###"Arquivos .DLL |*.DLL","Selecione o modulo"

	CREATE PANEL oWizard  ;
		HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
		MESSAGE ""	;
		BACK {|| oWizard:SetPanel(2),.T.} ;
		NEXT {|| IsMailReady(1,aParam[1],aParam[2],aParam[3],aParam[4],aParam[5],aParam[6])} ;
		PANEL

	ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,oWizard:oMPanel[4],"SPEDNFESMTP",.T.,.T.)


	CREATE PANEL oWizard  ;
		HEADER STR0169 ; //"Assistente de configuração da Nota Fiscal de Serviço Eletrônica"
		MESSAGE ""	;
		BACK {|| oWizard:SetPanel(2),.T.} ;
		NEXT {|| IsNSeRead(@oCombo1:nAt,@oCombo2:nAt,@oCombo3:nAt)} ;
		PANEL


	@ 005,010 SAY STR0160 SIZE 270,010 PIXEL OF oWizard:oMPanel[5] //"Informe o Regime Especial de Tributacao"
	@ 005,115 COMBOBOX oCombo1 VAR cCombo1 ITEMS {STR0161,STR0162,STR0163,STR0164,STR0178,STR0179,STR0180} SIZE 120,010 OF oWizard:oMPanel[5] PIXEL //"01 – Microempresa Municipal"###"02 – Estimativa"###"03 – Sociedade de Profissionais"###"04 – Cooperativa"###"05 – MEI – Simples Nacional"###"06 – ME EPP – Simples Nacional"###"00 - N.D.A."

	@ 020,010 SAY STR0165 SIZE 270,010 PIXEL OF oWizard:oMPanel[5] //"Optante Simples Nacional"
	@ 020,115 COMBOBOX oCombo2 VAR cCombo2 ITEMS {STR0166,STR0167} SIZE 120,010 OF oWizard:oMPanel[5] PIXEL //"1 – Sim"###"2 – Não"

	@ 035,010 SAY STR0168 SIZE 270,010 PIXEL OF oWizard:oMPanel[5] //"Incentivador Cultural"
	@ 035,115 COMBOBOX oCombo3 VAR cCombo3 ITEMS {STR0166,STR0167} SIZE 120,010 OF oWizard:oMPanel[5] PIXEL //"1 – Sim"###"2 – Não"


	CREATE PANEL oWizard  ;
		HEADER STR0041; //"Assistente de configuração da Nota Fiscal Eletrônica"
		MESSAGE "";
		BACK {|| oWizard:SetPanel(2),.T.} ;
		FINISH {|| lOk := .T.} ;
		PANEL
		@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[6]

	ACTIVATE WIZARD oWizard CENTERED
Else
	Help( "", 1, "SEMPERM" )
EndIf
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNSePar³ Autor ³Cleber Stenio          ³ Data ³16.09.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Parametriza o  Totvs Services para a nota fiscal eletronica ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNSePar()

Local oWs
Local aPerg  := {}
Local aParam := {"","","",0}
Local aCombo1:= {}
Local aCombo2:= {}
Local cCombo1:= ""
Local cCombo2:= ""
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cParNSePar := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNSEPAR"

aadd(aCombo1, STR0031) //"1-Produção"
aadd(aCombo1, STR0032) //"2-Homologação"
aadd(aCombo2, "1.00")
aadd(aCombo2, "9.99")

If IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cIdEnt := GetIdEnt()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o ambiente                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN    := "TOTVS"
	oWS:cID_ENT       := cIdEnt
	oWS:nAmbienteNSe  := 0
	oWS:_URL          := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:CFGAMBIENTENSE()
	cCombo1 := oWS:cCfgAmbienteNSeResult

	aadd(aPerg,{2,STR0035,cCombo1,aCombo1,120,".T.",.T.,".T."}) //"Ambiente"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem a versao da NFe                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:cVersao    := "0.00"
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:CfgVersaoNSe()
	cCombo2 := oWS:cCfgVersaoNSeResult
	aadd(aPerg,{2,STR0037+" NSe",cCombo2,aCombo2,120,".T.",.T.,".T."}) //"Versão"


	aParam := {SubStr(cCombo1,1,1),cCombo2}
	If ParamBox(aPerg,"SPED - NFe",aParam,,,,,,,cParNSePar,.T.,.F.)
		oWS := WsSpedCfgNFe():New()
		oWS:cUSERTOKEN    := "TOTVS"
		oWS:cID_ENT       := cIdEnt
		oWS:nAmbienteNSe  := Val(aParam[1])
		oWS:_URL          := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:CFGAMBIENTENSE()

		oWS:cUSERTOKEN := "TOTVS"
		oWS:cID_ENT    := cIdEnt
		oWS:cVersao    := aParam[2]
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:CFGVersaoNSe()

	EndIf
Else

	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFSe1Mn³ Autor ³Cleber Stenio         ³ Data ³25.08.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento da NFSe - por faixa                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFSe1Mnt()

Local cIdEnt   := ""
Local aPerg    := {}
Local aParam   := {Space(If(TamSx3("F2_SERIE")[1] == 14,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),CtoD(""),CtoD("")}
Local aSize    := {}
Local aObjects := {}
Local aListBox := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local cParNFSeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFSEREM"
Local dDataDe := CtoD("")
Local dDataAte := CtoD("")
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14

aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.}) //"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

aParam[01] := ParamLoad(cParNFSeRem,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNFSeRem,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNFSeRem,aPerg,3,aParam[03])

If lSdoc
	aadd(aPerg,{1,"Dt. Emissão De"	,aParam[04],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"
	aadd(aPerg,{1,"Dt. Emissão Até"	,aParam[05],"@R 99/99/9999",".T.","",".T.",35,.F.}) 			//"Data de Emissão"

	dDataDe  := aParam[05] := ParamLoad(cParNFSeRem,aPerg,4,aParam[04])
	dDataAte := aParam[06] := ParamLoad(cParNFSeRem,aPerg,5,aParam[05])
EndIf

dbSelectArea("SF3")
dbSetOrder(1)

If IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt()
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cIdEnt)

			If ParamBox(aPerg,"SPED - NSe",@aParam,,,,,,,cParNFSeRem,.T.,.T.)

				If lSdoc
					GetFiltroF3(@aParam,,dDataDe,dDataAte)
				EndIF

				aListBox := WsNFSeMnt(cIdEnt,1,aParam)
				If !Empty(aListBox)
					aSize := MsAdvSize()
					aObjects := {}
					AAdd( aObjects, { 100, 100, .t., .t. } )
					AAdd( aObjects, { 100, 015, .t., .f. } )

					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )

					DEFINE MSDIALOG oDlg TITLE "SPED - NSe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

					@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "",STR0049,STR0035,STR0050,STR0051,STR0052,STR0053; //"NF"###"Ambiente"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"Tempo SEF"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					oListBox:SetArray( aListBox )
					oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,5 ],aListBox[ oListBox:nAT,6 ],aListBox[ oListBox:nAT,7 ],aListBox[ oListBox:nAT,8 ]} }


					@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT STR0114   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
					@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT STR0054   		ACTION (Bt2NFSeMnt(aListBox[oListBox:nAT][09])) OF oDlg PIXEL SIZE 035,011 //"Mensagens"
					@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT STR0055   		ACTION (Bt3NFSeMnt(cIdEnt,aListBox[ oListBox:nAT,2 ])) OF oDlg PIXEL SIZE 035,011 //"Rec.XML"
					@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT STR0118 		ACTION (aListBox := WsNFSeMnt(cIdEnt,1,aParam),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					@ aPosObj[2,1],aPosObj[2,4]-200 BUTTON oBtn4 PROMPT STR0115  		ACTION (Bt3NFSeMnt(cIdEnt,aListBox[ oListBox:nAT,2 ],2)) OF oDlg PIXEL SIZE 035,011 //"Schema"
					ACTIVATE MSDIALOG oDlg
				EndIf
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

Static Function WsNFSeMnt(cIdEnt,nModelo,aParam)

Local aListBox := {}
Local aMsg     := {}
Local nX       := 0
Local nY       := 0
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOk      := .T.
Local oOk      := LoadBitMap(GetResources(), "ENABLE")
Local oNo      := LoadBitMap(GetResources(), "DISABLE")
Local oWS
Local oRetorno
Local cChave   :=""
Local cDat     :=""
Local cSerChv := ""
Local cNfChv  := ""
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
Private oXml

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN    := "TOTVS"
oWS:cID_ENT       := cIdEnt
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
If nModelo == 1

	If lSdoc
		oWS:cIdInicial    := aParam[01]+aParam[02]
		oWS:cIdFinal      := aParam[Len(aParam)]+aParam[03]
	Else
		oWS:cIdInicial    := aParam[01]+aParam[02]
		oWS:cIdFinal      := aParam[01]+aParam[03]
	EndIf

	lOk := oWS:MONITORFXNSE()
	oRetorno := oWS:oWsMonitorFxNSeResult
Else
	oWS:nIntervalo := Max(aParam[01],60)
	lOk := oWS:MONITORTEMPO()
	oRetorno := oWS:oWsMonitorTempoResult
EndIf
If lOk
	dbSelectArea("SF3")
	dbSetOrder(5)
    For nX := 1 To Len(oRetorno:oWSMONITORNSE)
  		aMsg := {}
 		oXml := oRetorno:oWSMONITORNSE[nX]
 		If Type("oXml:OWSERRO:OWSLOTENSE")<>"U"
	 		For nY := 1 To Len(	oXml:OWSERRO:OWSLOTENSE)
 				If oXml:OWSERRO:OWSLOTENSE[nY]:NLOTE<>0
	 				aadd(aMsg,{oXml:OWSERRO:OWSLOTENSE[nY]:NLOTE,oXml:OWSERRO:OWSLOTENSE[nY]:DDATALOTE,oXml:OWSERRO:OWSLOTENSE[nY]:CHORALOTE,;
	 							oXml:OWSERRO:OWSLOTENSE[nY]:CRECIBOSEFAZ,;
	 							oXml:OWSERRO:OWSLOTENSE[nY]:CCODENVLOTE,PadR(oXml:OWSERRO:OWSLOTENSE[nY]:CMSGENVLOTE,50),;
	 							oXml:OWSERRO:OWSLOTENSE[nY]:CCODRETRECIBO,PadR(oXml:OWSERRO:OWSLOTENSE[nY]:CMSGRETRECIBO,50),;
	 							oXml:OWSERRO:OWSLOTENSE[nY]:CCODRETNFE,PadR(oXml:OWSERRO:OWSLOTENSE[nY]:CMSGRETNFE,50000)})
				EndIf
				SF3->(dbSetOrder(5))
				If SF3->(MsSeek(xFilial("SF3")+oXml:Cid,.T.))
					If SF3->(FieldPos("F3_CODRSEF"))<>0 .And. Empty(SF3->F3_CODRSEF)
						RecLock("SF3")
						SF3->F3_CODRSEF:= oXml:OWSERRO:OWSLOTENSE[nY]:CCODRETNFE
						MsUnlock()
					EndIf
				EndIf
				//Nota de saida
				dbSelectArea("SF2")
				dbSetOrder(1)

				cSerChv 	:= If(lSdoc,SUBSTR(oXml:Cid,1,14),SUBSTR(oXml:Cid,1,3))
				cNfChv  	:= If(lSdoc,SUBSTR(oXml:Cid,15,Len(oXml:Cid)),SUBSTR(oXml:Cid,4,Len(oXml:Cid)))

				If SF2->(MsSeek(xFilial("SF2")+(cNfChv+cSerChv),.T.))
				    //Se for NFS-e e Tiver Numero da Nota da Prefeitura (Atualizo as yabelas do Protheus)
					If !Empty(oXml:CNUMNSE) .And. Empty(SF2->F2_NFELETR)
						//Atualizo SF2
						RecLock("SF2",.F.)
						cDat := Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+2,8)
						SF2->F2_NFELETR	:= Iif(Len(AllTrim(oXml:CNUMNSE))>8,Substr(oXml:CNUMNSE,Len(AllTrim(oXml:CNUMNSE))-7,Len(AllTrim(oXml:CNUMNSE))),Substr(oXml:CNUMNSE,1,Len(AllTrim(oXml:CNUMNSE))))
						SF2->F2_EMINFE	:= StoD(SubStr(cDat,1,4)+SubStr(cDat,5,2)+SubStr(cDat,7,2))
						SF2->F2_HORNFE	:= Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+11,5)
						SF2->F2_CODNFE	:= Substr(oXml:CPROTOCOLO,1,Len(oXml:CPROTOCOLO))
						SF2->F2_FIMP		:= "S"
						MsUnLock()

						//Atualizo SF3
						SF3->(dbSetOrder(4))
						cChave := xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE
						If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,.T.))
							Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
								RecLock("SF3",.F.)
								SF3->F3_NFELETR	:= Iif(Len(AllTrim(oXml:CNUMNSE))>8,Substr(oXml:CNUMNSE,Len(AllTrim(oXml:CNUMNSE))-7,Len(AllTrim(oXml:CNUMNSE))),Substr(oXml:CNUMNSE,1,Len(AllTrim(oXml:CNUMNSE))))
								SF3->F3_EMINFE	:= StoD(SubStr(cDat,1,4)+SubStr(cDat,5,2)+SubStr(cDat,7,2))
								SF3->F3_HORNFE	:= Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+11,5)
								SF3->F3_CODNFE	:= Substr(oXml:CPROTOCOLO,1,Len(oXml:CPROTOCOLO))
								MsUnLock()
						    SF3->(dbSkip())
						    EndDo
						EndIf

						//Atualizo SFT
						SFT->(dbSetOrder(1))
						cChave := xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
						If SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))
							Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
								RecLock("SFT",.F.)
								SFT->FT_NFELETR	:= Iif(Len(AllTrim(oXml:CNUMNSE))>8,Substr(oXml:CNUMNSE,Len(AllTrim(oXml:CNUMNSE))-7,Len(AllTrim(oXml:CNUMNSE))),Substr(oXml:CNUMNSE,1,Len(AllTrim(oXml:CNUMNSE))))
								SFT->FT_EMINFE	:= StoD(SubStr(cDat,1,4)+SubStr(cDat,5,2)+SubStr(cDat,7,2))
								SFT->FT_HORNFE	:= Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+11,5)
								SFT->FT_CODNFE	:= Substr(oXml:CPROTOCOLO,1,Len(oXml:CPROTOCOLO))
								MsUnLock()
								SFT->(dbSkip())
					    	EndDo
						EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se tiver o campo E1_NFELETR de nota fiscal 	 ³
							//³eletronica, grava o numero da NFe gerada na 	 ³
							//³prefeitura tambem no titulo (SE1)		 	 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							// Se tiver o campo E1_NFELETR de nota fiscal eletronica, grava o numero da NFe gerada na prefeitura tambem no titulo (SE1)
							If (SE1->(FieldPos("E1_NFELETR")) > 0)
								dbSelectArea("SE1")
								dbSetOrder(2)  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
								MsSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))

								While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
									RecLock("SE1",.F.)
									SE1->E1_NFELETR := SF2->F2_NFELETR
									MsUnlock()
                               
									Iif(FindFunction("J255AjNfe"), J255AjNfe(SE1->(Recno())), Nil)
									dbSkip()
								Enddo
							EndIf

					Endif

					If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := SUBSTR(oXml:OWSERRO:OWSLOTENSE[nY]:cHORALOTE,1,5)
						MsUnlock()
					EndIf
				//Procuro na Base com 9 posições
				ElseIf SF2->(MsSeek(xFilial("SF2")+(cNfChv+"   "+cSerChv),.T.))

				    //Se for NFS-e e Tiver Numero da Nota da Prefeitura (Atualizo as yabelas do Protheus)
					If !Empty(oXml:CNUMNSE) .And. Empty(SF2->F2_NFELETR)
						//Atualizo SF2
						cDat := Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+2,8)
						RecLock("SF2",.F.)
						SF2->F2_NFELETR	:= Iif(Len(AllTrim(oXml:CNUMNSE))>8,Substr(oXml:CNUMNSE,Len(AllTrim(oXml:CNUMNSE))-7,Len(AllTrim(oXml:CNUMNSE))),Substr(oXml:CNUMNSE,1,Len(AllTrim(oXml:CNUMNSE))))
						SF2->F2_EMINFE	:=  StoD(SubStr(cDat,1,4)+SubStr(cDat,5,2)+SubStr(cDat,7,2))
						SF2->F2_HORNFE	:= Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+11,5)
						SF2->F2_CODNFE	:= Substr(oXml:CPROTOCOLO,1,Len(oXml:CPROTOCOLO))
						SF2->F2_FIMP		:= "S"
						MsUnLock()

						//Atualizo SF3
						SF3->(dbSetOrder(4))
						cChave := xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE
						If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,.T.))
							Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
								RecLock("SF3",.F.)
								SF3->F3_NFELETR	:= Iif(Len(AllTrim(oXml:CNUMNSE))>8,Substr(oXml:CNUMNSE,Len(AllTrim(oXml:CNUMNSE))-7,Len(AllTrim(oXml:CNUMNSE))),Substr(oXml:CNUMNSE,1,Len(AllTrim(oXml:CNUMNSE))))
								SF3->F3_EMINFE	:= StoD(SubStr(cDat,1,4)+SubStr(cDat,5,2)+SubStr(cDat,7,2))
								SF3->F3_HORNFE	:= Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+11,5)
								SF3->F3_CODNFE	:= Substr(oXml:CPROTOCOLO,1,Len(oXml:CPROTOCOLO))
								MsUnLock()
						    SF3->(dbSkip())
						    EndDo
						EndIf

						//Atualizo SFT
						SFT->(dbSetOrder(1))
						cChave := xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
						If SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))
							Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
								RecLock("SFT",.F.)
								SFT->FT_NFELETR	:= Iif(Len(AllTrim(oXml:CNUMNSE))>8,Substr(oXml:CNUMNSE,Len(AllTrim(oXml:CNUMNSE))-7,Len(AllTrim(oXml:CNUMNSE))),Substr(oXml:CNUMNSE,1,Len(AllTrim(oXml:CNUMNSE))))
								SFT->FT_EMINFE	:= StoD(SubStr(cDat,1,4)+SubStr(cDat,5,2)+SubStr(cDat,7,2))
								SFT->FT_HORNFE	:= Substr(oXml:CRECOMENDACAO,at("/",oXml:CRECOMENDACAO)+11,5)
								SFT->FT_CODNFE	:= Substr(oXml:CPROTOCOLO,1,Len(oXml:CPROTOCOLO))
								MsUnLock()
								SFT->(dbSkip())
						  EndDo
					  EndIf

 							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se tiver o campo E1_NFELETR de nota fiscal 	 ³
							//³eletronica, grava o numero da NFe gerada na 	 ³
							//³prefeitura tambem no titulo (SE1)		 	 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							// Se tiver o campo E1_NFELETR de nota fiscal eletronica, grava o numero da NFe gerada na prefeitura tambem no titulo (SE1)
							If (SE1->(FieldPos("E1_NFELETR")) > 0)
								dbSelectArea("SE1")
								dbSetOrder(2)  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
								MsSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC))

								While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC)
									RecLock("SE1",.F.)
									SE1->E1_NFELETR := SF2->F2_NFELETR
									MsUnlock()
									Iif(FindFunction("J255AjNfe"), J255AjNfe(SE1->(Recno())), Nil)
									dbSkip()
								Enddo
							EndIf

				  Endif

					If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := SUBSTR(oXml:OWSERRO:OWSLOTENSE[nY]:cHORALOTE,1,5)
						MsUnlock()
					EndIf
				EndIf
 			Next nY
		EndIf
    	aadd(aListBox,{ IIf(Empty(oXml:cPROTOCOLO),oNo,oOk),;
    					oXml:cID,;
    					IIf(oXml:nAMBIENTE==1,STR0056,STR0057),; //"Produção"###"Homologação"
    					STR0058,; //"Normal"###"Contingência"
    					oXml:cPROTOCOLO,;
    					PadR(oXml:cRECOMENDACAO,250),;
    					oXml:cTEMPODEESPERA,;
    					oXml:nTEMPOMEDIOSEF,;
    					aMsg})
    Next nX
    If Empty(aListBox)
    	Aviso("SPED",STR0106,{STR0114})
    EndIf
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
EndIf
Return(aListBox)

Static Function Bt2NFSeMnt(aMsg)

Local aSize    := MsAdvSize()
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oDlg
Local oListBox
Local oBtn1

If !Empty(aMsg)
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER STR0060,STR0061,STR0062,STR0064,STR0065,STR0066,STR0067,STR0157,STR0158; //"Lote"###"Dt.Lote"###"Hr.Lote"###"Cod.Env.Lote"###"Msg.Env.Lote"###"Cod.Ret.Lote"###"Msg.Ret.Lote"###"Cod.Ret.NFSe"###"Msg.Ret.NFSe"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
	oListBox:SetArray( aMsg )
	oListBox:bLine := { || { aMsg[ oListBox:nAT,1 ],aMsg[ oListBox:nAT,2 ],aMsg[ oListBox:nAT,3 ],aMsg[ oListBox:nAT,5 ],aMsg[ oListBox:nAT,6 ],aMsg[ oListBox:nAT,7 ],aMsg[ oListBox:nAT,8 ],aMsg[ oListBox:nAT,9 ],PadR(aMsg[ oListBox:nAT,10 ],50)} }
	@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114         ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011
	@ aPosObj[2,1],aPosObj[2,4]-070 BUTTON oBtn1 PROMPT STR0170         ACTION Aviso("SPED",aMsg[ oListBox:nAT,10 ],{STR0114},3) OF oDlg PIXEL SIZE 028,011

	ACTIVATE MSDIALOG oDlg
EndIf
Return(.T.)

Static Function Bt3NFSeMnt(cIdEnt,cIdNFe,nTipo)

Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWS
Local cMsg     := ""
DEFAULT nTipo  := 1

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := cIdNfe
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

If oWS:RETORNANOTAS()
	If Len(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
		If nTipo == 1
			Do Case
				Case oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA <> Nil
					Aviso("SPED",oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML,{STR0114},3, Nil,Nil,Nil,.T. )
				OtherWise
					Aviso("SPED",oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML,{STR0114},3, Nil,Nil,Nil,.T. )
			EndCase
		Else
			cMsg := AllTrim(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML)
			If !Empty(cMsg)
				Aviso("SPED",@cMsg,{STR0114},3,/*cCaption2*/,/*nRotAutDefault*/,/*cBitmap*/,.T.)
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN     := "TOTVS"
				oWS:cID_ENT        := cIdEnt
				oWs:oWsNFe:oWSNOTAS:=  NFeSBRA_ARRAYOFNFeS():New()
				aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())
				oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cID := cIdNfe
				oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML:= EncodeUtf8(cMsg)
				oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
				If oWS:SchemaNSe()
					If Empty(oWS:oWSSCHEMANSERESULT:oWSNFES7[1]:cMENSAGEM)
						Aviso("SPED",STR0091,{STR0114})
					Else
						Aviso("SPED",IIF(Empty(oWS:oWSSCHEMANSERESULT:oWSNFES7[1]),STR0091,oWS:oWSSCHEMANSERESULT:oWSNFES7[1]:cMENSAGEM),{STR0114},3, Nil,Nil,Nil,.T. )
					EndIf
				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3, Nil,Nil,Nil,.T. )
				EndIf
			EndIf
		EndIf
	EndIf
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3,Nil,Nil,Nil,.T. )
EndIf
Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SpedNSeLeg³Autor  ³ Cleber Stenio         ³ Data ³16.09.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNSeLeg()
Local aLegenda := {}
				aCores    := {{"F1_FIMP==' ' .AND. AllTrim(F1_ESPECIE)=='SPED'",'DISABLE' },;	//NF não transmitida
							  {"F1_FIMP=='S','ENABLE'"},;									//NF Autorizada
							  {"F1_FIMP=='T','BR_AZUL'"},;									//NF Transmitida
							  {"F1_FIMP=='N','BR_PRETO'"}}									//NF nao autorizada

Aadd(aLegenda, {"ENABLE"    ,STR0078}) //"NF autorizada"
Aadd(aLegenda, {"DISABLE"   ,STR0079}) //"NF não transmitida"
Aadd(aLegenda, {"BR_AZUL"   ,STR0080}) //"NF Transmitida"
Aadd(aLegenda, {"BR_PRETO"  ,STR0081})	//"NF nao autorizada"
BrwLegenda(cCadastro,STR0117,aLegenda) //"Legenda"

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedSSAut ³ Autor ³ Adalberto SM          ³ Data ³06.04.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao Responsavel por Solicitar o Status dos CTe's de forma³±±
±±³          ³Automatica.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com os Doc. Autorizados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1. Filial 								                          ³±±
±±³          ³2. Lote		                                               ³±±
±±³          ³3. Tipo de Documento                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedSSAut(CFilOri,cLotNFC,cDocTms)
Local cIdEnt    := ''
local cUrl		:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local aParam    := {"","","","",""}
Local cQuery    := ''
Local cAlias    := GetNextAlias()
Local nTotSit   := 0
Local cSitCTE   := ''
Local aCTe      := {}
Local aAuxCte   := {}
Local nCount    := 0

Default cDocTms := ''

If (IsReady())

	If (FunName()$"TMSA200" .Or. FunName()$"TMSA500")
		cQuery := ''
		cQuery += " SELECT DT6_FILIAL, "
		cQuery += " DT6_FILDOC, "
		cQuery += " DT6_SERIE, "
		cQuery += " (MIN(DT6_DOC)) DT6_DOCMIN, "
		cQuery += " (MAX(DT6_DOC)) DT6_DOCMAX "
		cQuery += " FROM " + RetSqlName('DT6') + " DT6 "
		cQuery += " WHERE DT6_FILIAL = '" + xFilial('DT6') + "'"
		cQuery += " AND DT6_FILORI = '" + CFilOri + "'"
		cQuery += " AND DT6_LOTNFC = '" + cLotNFC + "'"
		cQuery += " AND DT6_DOCTMS = '" + cDocTms + "'"
		cQuery += " AND D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY DT6_FILIAL, DT6_FILDOC, DT6_SERIE "
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

		While (!(cAlias)->(Eof()))
			cIdEnt	  := GetIdEnt()
			aParam[01] := (cAlias)->DT6_SERIE
			aParam[02] := (cAlias)->DT6_DOCMIN
			aParam[03] := (cAlias)->DT6_DOCMAX
			aParam[04] := CFilOri
			aParam[05] := cLotNFC
			aAuxCTe	:= getListBox(cIdEnt, cUrl, aParam, 1, , .T.)
			For nCount := 1 To Len(aAuxCTe)
				If aScan(aCTe,{|x| x == aAuxCte[nCount] }) == 0
					aAdd(aCte,aAuxCte[nCount])
				EndIf
			Next nCount
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
	EndIf

EndIf

Return(aCTe)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjVerNfCup³Autor  ³ Vendas e CRM          ³ Data ³14.10.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Quando identificar uma nf sobre cupom alimenta o array de    ³±±
±±³          ³Notas com os dados do cupom fiscal.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaLoja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjVerNfCup(aNotas,cAliasSF3,aNfCup,lMontar,aMotCont)

Local aArea			:= GetArea()
Local nTamSerie     := TamSX3("F2_SERIE")[1] 	// Tamanho do campo L1_SERIE
Local nTamDoc       := TamSX3("F2_DOC")[1]	 	// Tamanho do campo L1_DOC
Local cNumDoc       := ""           		 	// Numero do Documento
Local cNumSerie     := ""						// Numero da Serie
Local nX			:= 0						// Contador
Local cF3Obs		:= ""						// Observacao gravada no Livro
Local lLJ130MN   	:= GetNewPar("MV_LJ130MN",.F.)	// Permite gerar uma nota para multiplos cupons

DEFAULT aMotCont	:= {}

If lMontar
	DbSelectArea(cAliasSF3)

	if UPPER("F - simples faturamento") $  UPPER((cAliasSF3)->F3_OBSERV )
		MDL->(dbSetOrder(1))
		if MDL->(MsSeek(xFilial("MDL")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE,.T.))
			cNumDoc     := MDL->MDL_CUPOM
			cNumSerie	:= MDL->MDL_SERCUP
		endif
		MsUnLock()
		MDL->(dbSkip())

	else

		//cF3Obs		:= (cAliasSF3)->F3_OBSERV
		//cNumDoc     := SubStr(cF3Obs,10,nTamDoc)
		//cNumSerie	:= SubStr(cF3Obs,11+nTamDoc,nTamSerie)
		cF3Obs	:= POSICIONE("SF2",1,xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"F2_NFCUPOM")
		cNumSerie	:= SubStr(cF3Obs,1,nTamSerie)
		cNumDoc	:= SubStr(cF3Obs,nTamSerie+1,nTamDoc)

	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda os dados da Nota para posteriormente retornar o numero    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aNfCup,{})
	nX := Len(aNfCup)
	aadd(aNfCup[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
	aadd(aNfCup[nX],(cAliasSF3)->F3_ENTRADA)
	aadd(aNfCup[nX],(cAliasSF3)->F3_SERIE)
	aadd(aNfCup[nX],(cAliasSF3)->F3_NFISCAL)
	aadd(aNfCup[nX],(cAliasSF3)->F3_CLIEFOR)
	aadd(aNfCup[nX],(cAliasSF3)->F3_LOJA)
	aadd(aNfCup[nX],cNumSerie )
	aadd(aNfCup[nX],cNumDoc )

	//Permite gerar uma nota para multiplos cupons
	If lLJ130MN .And. !Empty(cNumDoc) .And. !Empty(cNumSerie)
		aadd(aNotas,{})
		nX := Len(aNotas)
		aadd(aNotas[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
		aadd(aNotas[nX],(cAliasSF3)->F3_ENTRADA)
		aadd(aNotas[nX],(cAliasSF3)->F3_SERIE)
		aadd(aNotas[nX],(cAliasSF3)->F3_NFISCAL)
		aadd(aNotas[nX],(cAliasSF3)->F3_CLIEFOR)
		aadd(aNotas[nX],(cAliasSF3)->F3_LOJA)
		aadd(aNotas[nX],aMotCont)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona no array de notas os dados do cupom que originou a nota ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF3")
	DbSetOrder(6)
	If DbSeek( xFilial("SF3") + cNumDoc + cNumSerie)
		If ( AllTrim(SF3->F3_ESPECIE) == "CF" .OR. AllTrim(SF3->F3_ESPECIE) == "NFCE" .OR. AllTrim(SF3->F3_ESPECIE) == "SATCE" .OR. (LjAnalisaLeg(18)[1] .AND. "ECF" $ AllTrim(SF3->F3_ESPECIE) ) )
			aadd(aNotas,{})
			nX := Len(aNotas)
			aadd(aNotas[nX],IIF(SF3->F3_CFO<"5","0","1"))
			aadd(aNotas[nX],SF3->F3_ENTRADA)
			aadd(aNotas[nX],SF3->F3_SERIE)
			aadd(aNotas[nX],SF3->F3_NFISCAL)
			aadd(aNotas[nX],SF3->F3_CLIEFOR)
			aadd(aNotas[nX],SF3->F3_LOJA)
			aadd(aNotas[nX],aMotCont)
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Volta os dados da Nota sobre cupom para o Array aNotas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 to Len(aNotas)
		aNotas[nX] := aNfCup[nX]
	Next nX
EndIf

RestArea(aArea)
Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NfeVldAuto³ Autor ³ Roberto Souza         ³ Data ³15.02.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validação de transmissão para notas em modo automatico      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NfeVldAuto(aNotas,cAlias)
Local aNotasOk	:= {}
Local Ny		:= 0
Local cStatNf	:= " "+GetNewPar("MV_NFEAUTR","")
Local nX		:= 0

For nX := 1 To 2
	dbSelectArea(cAlias)
	dbSetOrder(1)
	For Ny := 1 to len(aNotas)
		If DbSeek(xFilial(cAlias)+aNotas[nY][4]+aNotas[nY][3]+aNotas[nY][5]+aNotas[nY][6])
			If ( (cAlias$"SF2" .And. SF2->F2_FIMP$ cStatNf) .or. (cAlias$"SF1" .And. SF1->F1_FIMP$ cStatNf .And. SF1->F1_FORMUL=="S" .And. !(SF1->F1_STATUS$"C|B")))//"N, "
				aadd(aNotasOk,aNotas[nY])
			Endif
		EndIf
	Next
	If cAlias == "SF1"
		cAlias := "SF2"
	Else
		cAlias := "SF1"
	Endif
Next

aNotas := aNotasOk

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³XMLRemessa³ Autor ³ Gustavo. G. Rueda     ³ Data ³24.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela envio do XML ao TSS                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function XMLRemessa(oWs,cErro,aRetNotas,nTotNf,nXmlSize,cIdEnt,cURL,lAuto,cIdErp)
Local nY
Local lRetorno	:= .T.
Local lTransmitida	:= .F.
Local cXmlTSSEsp		:= ""
Local lMvColESP		:= SuperGetMv( "MV_COLESP", .F., .F. )
Local lEspelho		:= .F.
Local cErroEsp 		:= ""

Default lAuto	:= .F.
Default cIdErp	:= ""

If nXmlSize>0 .And. oWs:Remessa()
	If Len(oWs:oWsRemessaResult:oWSID:cString) <> nTotNF
		cErro := STR0024+CRLF+CRLF //"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
	EndIf
	For nY := 1 To Len(aRetNotas)

		lTransmitida := aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][3]+AllTrim(aRetNotas[nY][4])) > 0

		//Grava na F3_CODRET = T |Transmitido|se existir o campo na SF3
			gravaCodRet( aRetNotas[nY] )

		If Len(oWs:oWsRemessaResult:oWSID:cString) <> nY
			If !lTransmitida
				cErro += "NFe: "+aRetNotas[nY][3]+aRetNotas[nY][4]+CRLF
			EndIf
			If aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][3]+aRetNotas[nY][4])==0 .and. lMvColESP
				cErro += "NFe: "+aRetNotas[nY][3]+aRetNotas[nY][4]+CRLF
			EndIf
		EndIf
		If aRetNotas[nY][1] == "0"
			If SF1->(FieldPos("F1_FIMP"))>0
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+aRetNotas[nY][4]+aRetNotas[nY][3]+aRetNotas[nY][5]+aRetNotas[nY][6]) .And. SF1->F1_FIMP$"N, "
					RecLock("SF1")
					SF1->F1_FIMP := IIF(lTransmitida,"T","N")
					MsUnlock()
				EndIf
			EndIf
		Else
			dbSelectArea("SF2")
			dbSetOrder(1)
 			If MsSeek(xFilial("SF2")+aRetNotas[nY][4]+aRetNotas[nY][3]+aRetNotas[nY][5]+aRetNotas[nY][6]) .And. SF2->F2_FIMP$"N, "
				RecLock("SF2")
				SF2->F2_FIMP := IIF(lTransmitida,"T","N")
				MsUnlock()
			EndIf
		EndIf

		//Geracao do espelho da nota apos transmissão do TSS
		If lTransmitida .And. lMvColESP
			cXmlTSSEsp	:= RetXmlNFe(cIdEnt, aRetNotas[nY][3]+aRetNotas[nY][4] )
			lEspelho := XmlColEsp(aRetNotas[nY][4],aRetNotas[nY][3],aRetNotas[nY][5],aRetNotas[nY][6],cIdErp,cXmlTSSEsp,@cErroEsp)
			If!lEspelho
				cErro += cErroEsp + CRLF + CRLF
			EndIf
		EndIf

	Next nY

	If ExistBlock("FISENVNFE")
		ExecBlock("FISENVNFE",.F.,.F.,{oWs:oWsRemessaResult:oWSID:cString})
	EndIf

	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
	nTotNF := 0
	nXmlSize := 0
	aRetNotas := {}
Else
	cErro := GetWscError(3)
	DEFAULT cErro := STR0025 //"Erro indeterminado"
	lRetorno := .F.
EndIf
Return lRetorno
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SpedNFeInut³ Autor ³Gustavo G. Rueda       ³ Data ³17.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que prepara a transmissao das NF-e(s)                |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedNFeInut( cAlias, nReg, nOpc, cModel, aAutoExec )
Local aArea       	:= 	GetArea()
Local aPerg       	:= 	{}
Local aParam      	:= 	{Space(If(TamSx3("F2_SERIE")[1] == 14,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(5)}
Local aTexto      	:= 	{}
Local aXML        	:= 	{}
Local cRetorno    	:= 	""
Local cIdEnt      	:= 	""
Local cModalidade 	:= 	""
Local cAmbiente   	:= 	""
Local cVersao     	:= 	""
Local cVersaoCTe  	:= 	""
Local cVersaoDpec 	:= 	""
Local cMonitorSEF 	:= 	""
Local cSugestao   	:= 	""
Local cURL        	:= 	PadR(GetNewPar("MV_SPEDURL","http://"),250)
local cError		:= ""
Local nX          	:= 	0
Local lOk         	:= 	.T.
Local lCte          := .F.
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
Local oWs
Local oWizard
Local cParNfeRem 	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEINUT"
Local lNext			:=	.T.
Local nModeloDef    := 0
Local lRetorno		:=.F.
Local lUsaColab 	:= .F.
Local cFunName		:= ""
Local lAuto         := .F.
Local lTransmitida  := .F.

Default cModel		:= "55"
Default aAutoExec   := {}

/*
    Posicoes do Array aAutoExec, utilizado quando rotina automatica:

    1 Serie da Inutilizacao
    2 Documento inicial
    3 Documento final
    4 Modelo da Nota Eletronica (NF-e, CT-e ou NFC-e)
    5 Rotina de Origem
    6 Flag se Inutilizacao ja transmitida
    7 Protocolo de inutilizacao
    8 Data de Inutilizacao
    9 Horario de Inutilizacao
    10 Retorno da Sefaz/Prefeitura
*/

lAuto := Len(aAutoExec) > 0 //Valida se rotina automatica

If lAuto
    cFunName := aAutoExec[5] //Posicao do nome da rotina

    //Se a variavel private de retorno do ExecAuto nao foi criada, efetua a inicializacao
    If Type("lMsErroAuto") == "U"
        Private lMsErroAuto := .F.
    EndIf

    lTransmitida := aAutoExec[6]
Else
    cFunName := FunName()
EndIf

If cFunName $ "SPEDCTE,TMSA200,TMSA500,TMSAE70,TMSA050"
	cModel := "57"
	lCte   := .T.
ElseIf cFunName == "LOJA701"
	cModel := "65"
	If !Empty(GetNewPar("MV_NFCEURL",""))
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Else
	cModel := "55"
EndIf

lUsaColab 	:= UsaColaboracao( IIF(lCte,"2","1") )

If lAuto
    MV_PAR01 := aParam[01] := PadR(aAutoExec[1],Len(SF2->F2_SERIE))
    MV_PAR02 := aParam[02] := PadR(aAutoExec[2],Len(SF2->F2_DOC))
    MV_PAR03 := aParam[03] := PadR(aAutoExec[3],Len(SF2->F2_DOC))
    MV_PAR04 := aParam[04] := AllTrim(aAutoExec[4])
Else
    MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfeRem,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
    MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfeRem,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
    MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfeRem,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
    MV_PAR04 := aParam[04] := AllTrim(ParamLoad(cParNfeRem,aPerg,4,aParam[04]))
EndIf

Do Case
	Case AllTrim(aParam[04]) == STR0329 //"NF-e"
		nModeloDef := 1
	Case AllTrim(aParam[04]) == "CT-e"
		nModeloDef := 2
	Otherwise
		nModeloDef := 1
EndCase

If !lAuto
    aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
    aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
    aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.})	//"Nota fiscal final"
    If lUsaColab
    	aadd(aPerg,{2,STR0328,nModeloDef,{IIf(lCte,"CT-e",STR0329)},30,,.T.})	//"Modelo do Documento"
    Else
    	aadd(aPerg,{2,STR0328,nModeloDef,{STR0329,"CT-e","NFC-e"},30,,.T.})	//"Modelo do Documento"
    EndIf
EndIf

If IsReady( ,,,lUsaColab ) .Or. lTransmitida
	If lTransmitida
	   lRetorno := .T.
	Else
    	If lUsaColab
    		If lCte
    			cAmbiente	:= ColGetPar("MV_AMBCTE","")+" - " +ColDescOpcao("MV_AMBCTE", ColGetPar("MV_AMBCTE","") )
    			cModalidade	:= ColGetPar("MV_MODCTE","")+" - " +ColDescOpcao("MV_MODCTE", ColGetPar("MV_MODCTE","") )
    			cVersao		:= ColGetPar("MV_VERCTE","2.00")
    		Else
    			cAmbiente	:= ColGetPar("MV_AMBIENT","")+" - " +ColDescOpcao("MV_AMBIENT", ColGetPar("MV_AMBIENT","") )
    			cModalidade	:= ColGetPar("MV_MODALID","")+" - " +ColDescOpcao("MV_MODALID", ColGetPar("MV_MODALID","") )
    			cVersao		:= ColGetPar("MV_VERSAO","4.00")
    		EndIf
    		lRetorno := lOk
    	Else
    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    		//³Obtem o codigo da entidade                                              ³
    		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    		cIdEnt := GetIdEnt(lUsaColab)

    		If !Empty(cIdEnt)
    			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    			//³Obtem o ambiente de execucao do Totvs Services SPED                     ³
    			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    			cAmbiente		:= getCfgAmbiente(@cError, cIdEnt, cModel)
    			lOk 			:= empty(cError)


    			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    			//³Obtem a modalidade de execucao do Totvs Services SPED                   ³
    			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    			If lOk
    				cModalidade		:= getCfgModalidade(@cError, cIdEnt, cModel)
    				lOk 			:= empty(cError)

    			EndIf


    			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    			//³Obtem a versao de trabalho da NFe do Totvs Services SPED                ³
    			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    			If lOk
    				cVersao			:= getCfgVersao(@cError, cIdEnt, cModel)
    				lOk 			:= empty(cError)

    			EndIf


    			If lOk
    				cVersaoCTe     := getCfgVersao(@cError, cIdEnt, "57")
    				lOk := empty(cError)

    			EndIf

    			If lOk
    				cVersaoDpec	   := getCfgVerDpec(@cError, cIdEnt)
    				lOk := empty(cError)

    			EndIf
    			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    			//³Verifica o status na SEFAZ                                              ³
    			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    			If lOk
    				oWS:= WSNFeSBRA():New()
    				oWS:cUSERTOKEN := "TOTVS"
    				oWS:cID_ENT    := cIdEnt
    				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
    				lOk := oWS:MONITORSEFAZMODELO()
    				If lOk
    					aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
    					For nX := 1 To Len(aXML)
    						If aXML[nX]:cModelo <> cModel
    							Loop
    						Endif
    						Do Case
    							Case aXML[nX]:cModelo == "55"
    								cMonitorSEF += "- NFe"+CRLF
    								cMonitorSEF += Space(6)+STR0017+cVersao+CRLF	//"Versao do layout: "
    								If !Empty(aXML[nX]:cSugestao)
    									cSugestao += STR0125+"(NFe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
    								EndIf

    							Case aXML[nX]:cModelo == "57"
    								cMonitorSEF += "- CTe"+CRLF
    								cMonitorSEF += Space(6)+STR0017+cVersaoCTe+CRLF	//"Versao do layout: "
    								If !Empty(aXML[nX]:cSugestao)
    									cSugestao += STR0125+"(CTe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
    								EndIf

    							Case aXML[nX]:cModelo == "65"
    								cMonitorSEF += "- NFCe"+CRLF
    								cMonitorSEF += Space(6)+STR0017+cVersao+CRLF	//"Versao do layout: "
    								If !Empty(aXML[nX]:cSugestao)
    									cSugestao += STR0125+"(NFCe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
    								EndIf
    						EndCase
    						cMonitorSEF += Space(6)+STR0129+": "+aXML[nX]:cVersaoMensagem+CRLF //"Versão da mensagem"
    						cMonitorSEF += Space(6)+STR0120+": "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF //"Código do Status"
    		                cMonitorSEF += Space(6)+STR0121+": "+aXML[nX]:cUFOrigem //"UF Origem"
    		                If !Empty(aXML[nX]:cUFResposta)
    			                cMonitorSEF += "("+aXML[nX]:cUFResposta+")"+CRLF //"UF Resposta"
    			   			Else
    			   				cMonitorSEF += CRLF
    			   			EndIf
    		                If aXML[nX]:nTempoMedioSEF <> Nil
    							cMonitorSEF += Space(6)+STR0071+": "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF //"Tempo de espera"
    						EndIf
    						If !Empty(aXML[nX]:cMotivo)
    							cMonitorSEF += Space(6)+STR0123+": "+aXML[nX]:cMotivo+CRLF //"Motivo"
    						EndIf
    						If !Empty(aXML[nX]:cObservacao)
    							cMonitorSEF += Space(6)+STR0124+": "+aXML[nX]:cObservacao+CRLF //"Observação"
    						EndIf
    					Next nX
    				EndIf
    			EndIf
    			lRetorno := lOk
    		Else
    			lRetorno := .F.
    		EndIf
	   EndIf
	EndIf
	If lRetorno
        If lAuto
            ProcInut(aParam,cParNfeRem,aPerg,@cRetorno,cURL,cIdEnt,cAmbiente,cModalidade,cVersao,@lNext, aAutoExec)
        Else
    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    		//³ Montagem da Interface                                                  ³
    		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    		aadd(aTexto,{})
    		If lUsaColab
    			aTexto[1] := "Esta rotina tem como objetivo auxilia-lo na inutilização da Nota Fiscal eletrônica através da geração do arquivo para transmissão via TOTVS Colaboração. "+CRLF+CRLF
    		Else
    			aTexto[1] := "Esta rotina tem como objetivo auxilia-lo na inutilização da Nota Fiscal eletrônica para o serviço Totvs Services SPED. "+CRLF+CRLF
    		EndIf
    		aTexto[1] += STR0014+CRLF+CRLF 			//"Neste momento o Totvs Services SPED, está operando com a seguinte configuração: "
    		aTexto[1] += STR0015+cAmbiente+CRLF 	//"Ambiente: "
    		aTexto[1] += STR0016+cModalidade+CRLF	//"Modalidade de emissão: "
    		If !lUsaColab
    			If !Empty(cSugestao)
    				aTexto[1] += CRLF
    				aTexto[1] += cSugestao
    				aTexto[1] += CRLF
    			Else
    				aTexto[1] += CRLF
    			EndIf
    			aTexto[1] += cMonitorSEF
    		EndIf

            aadd(aTexto,{})

    		DEFINE WIZARD oWizard ;
    			TITLE STR0018;
    			HEADER STR0019;
    			MESSAGE STR0020;
    			TEXT aTexto[1] ;
    			NEXT {|| .T.} ;
    			FINISH {||.T.}

    		CREATE PANEL oWizard  ;
    			HEADER "Assistente de inutilização da Nota Fiscal Eletrônica" ;
    			MESSAGE ""	;
    			BACK {|| .T.} ;
    			NEXT {|| aTexto[02] := ProcInut(aParam,cParNfeRem,aPerg,@cRetorno,cURL,cIdEnt,cAmbiente,cModalidade,cVersao,@lNext),lNext} ;
    			PANEL
    	    ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,oWizard:oMPanel[2],cParNfeRem,.T.,.T.)

    		CREATE PANEL oWizard  ;
    			HEADER STR0018;//"Assistente de configuração da Nota Fiscal Eletrônica"
    			MESSAGE "";
    			BACK {|| .T.} ;
    			FINISH {|| .T.} ;
    			PANEL
    			@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
    			ACTIVATE WIZARD oWizard CENTERED

    		If AllTrim(aParam[04]) == "CT-e"
    			TMS70INUT(aParam)
    		EndIf
    	EndIf
	EndIf

Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
Return lRetorno
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInut  ³ Autor ³Gustavo G. Rueda       ³ Data ³17.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que efetua a transmissao das NF-e(s) selecionadas    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInut(aParam,cParNfeRem,aPerg,cRetorno,cURL,cIdEnt,cAmbiente,cModalidade,cVersao,lRet,aAutoExec)

Local cModelo := ""
Local lAuto   := .F.

Default aAutoExec := {}

lAuto := Len(aAutoExec) > 0

Do Case
	Case aParam[4] == STR0329
		cModelo := "55"
	Case aParam[4] == "CT-e"
		cModelo := "57"
	Case aParam[4] == "NFC-e"
		cModelo := "65"
EndCase

lRet 	:= 	VldInut(aParam[1],aParam[2],aParam[3],cModelo, lAuto)

If lRet
	If lAuto
        cRetorno := SpedInut(cURL,cIdEnt,aParam[1],aParam[2],aParam[3],cAmbiente,cModalidade,cVersao,cModelo, aAutoExec)
    Else
	   ParamSave(cParNfeRem,aPerg,"1")
	   Processa({|lEnd| cRetorno := SpedInut(cURL,cIdEnt,aParam[1],aParam[2],aParam[3],cAmbiente,cModalidade,cVersao,cModelo)})
    EndIf
EndIf

Return cRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SpedInut  ³ Autor ³Gustavo G. Rueda       ³ Data ³17.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada pela SpedNFeInut que processa os parametros|±±
±±³          ³informados de Serie+Noda de+Nota ate efetuando as inutilizacoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SpedInut(cURL,cIdEnt,cSerie,cNotaIni,cNotaFim,cAmbiente,cModalidade,cVersao,cModelo,aAutoExec)
Local oWs
Local nX       := 0
Local nY       := 0
Local cNfsInut := ""
Local cErro    := ""
Local nNFes    := 0
Local cRetorno := ""
Local cMod     := ""
Local cDoc     := ""
Local lEndFis  := GetNewPar("MV_SPEDEND",.F.)
Local lContinua:= .F.
Local lUsaColab:= .F.
Local lCancOk  := .F.
Local cUFEnt   := IIF(!lEndFis,SM0->M0_ESTCOB,SM0->M0_ESTENT)
Local cCNPJEnt := SM0->M0_CGC
Local dDataIni := Date()
Local cHoraIni := Time()
Local nTam     := 0
Local cCliente := SuperGetMV("MV_INUTCLI", .F., "")
Local cProduto := SuperGetMV("MV_INUTPRO", .F., "")
Local cTES     := SuperGetMV("MV_INUTTES", .F., "")
Local cEspec   := "SPED"
Local cModTC	 := ""
Local aCabec   := {}
Local aItens   := {}
Local aLinha   := {}
Local aNFeCol  := {}
Local aInfXml  := {}
Local cSerID   := ""
Local lAuto    := .F.
Local lTransmitida := .F.

Default aAutoExec := {}

lAuto := Len(aAutoExec) > 0

If lAuto
    lTransmitida := aAutoExec[6]
    lContinua := .T.
Else
    //Verifica qual eh o modelo a ser enviado para o Totvs Colab 2.0 quando nao eh passado como parametro variavel lCte ou lMDfe.
    If cModelo <> "65"
    	cModTC := ModeloColab(cModelo)
    	lUsaColab := UsaColaboracao( cModTC )
    EndIf
	
    If lUsaColab
    	If	!Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim) .And. !Empty(cAmbiente) .And. ;
    	    !Empty(cModalidade) .And. !Empty(cVersao) .And. !Empty(cModelo)
    	    lContinua := .T.
    	EndIf
    Else
    	If	!Empty(cURL) .And. !Empty(cIdEnt) .And. !Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim) .And.;
    		!Empty(cAmbiente) .And. !Empty(cModalidade) .And. !Empty(cVersao) .And. !Empty(cModelo)
    		lContinua := .T.
    	EndIf
    EndIf
EndIf

If lContinua
	If cModelo == "57"
		cEspec  := "CTE"
	Elseif cModelo == "65"
		cEspec  := "NFCE"
	ElseIf cModelo == "55" .And. lUsaColab
		cEspec	:= "SPED"
	EndIf
	cModalidade	:=	Left(cModalidade,1)

	If !lTransmitida
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	//³ Transmite as NFe a serem inutilizadas                                  ³
    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If lUsaColab
    		oDoc := ColaboracaoDocumentos():new()
    		oDoc:cModelo	:= IIf(cModelo=="55","NFE",IIf(cModelo=="57","CTE",IIf(cModelo=="65","NFCE","")))
    		oDoc:cTipoMov	:= "1"
    	Else
    		oWs	:= WsNFeSBra():New()
    		oWs:cUserToken 		:= 	"TOTVS"
    		oWs:cID_ENT    		:= 	cIdEnt
    		oWS:_URL       		:= 	AllTrim(cURL)+"/NFeSBRA.apw"
    		oWs:oWsNFe:oWsNotas	:=  NFESBRA_ARRAYOFNFES():New()
    	EndIf
    EndIf

	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1") + cCliente)

	For nX := Val(cNotaIni) To Val(cNotaFim)
	 	If len(Alltrim(cNotaIni)) == len(Alltrim(cNotaFim))
	 		nTam := len(Alltrim(cNotaIni))
	 	Else
	 		nTam := TAMSX3('F2_DOC')[1]
	 	EndIf

	 	// Checa se a nota já existe na base, caso exista não realiza nada neste registro.
	 	DBSelectArea("SF3")
	 	DBGoTop()
	 	DBSetOrder(6)

		cSerId := SerieNfId("SF3",4,"F3_SERIE",dDataBase,cEspec,cSerie)

	 	If DBSeek(xFilial("SF3") + PadR(StrZero(nX, nTam), Len(SF3->F3_NFISCAL)) + cSerId)
	 	    If SubStr(SF3->F3_CFO,1,1) $ "1,2,3"
	 			If AllTrim(SF3->F3_ESPECIE) == cEspec .And.  SF3->F3_FORMUL == 'S'
	 	    		Loop
	 	  		EndIf
	 	  	ElseIf SubStr(SF3->F3_CFO,1,1) $ "5,6,7"
	 	    	If AllTrim(SF3->F3_ESPECIE) == cEspec
	 	    		Loop
	 	    	EndIf
	 		EndIf
	 	EndIf

	 	// Inclui a nota na base pela rotina automática MATA920
	 	aCabec := {}
	 	aItens := {}
	 	cDoc := PADR(StrZero(nX, nTam),TAMSX3('F2_DOC')[1])
		AADD(aCabec, {"F2_TIPO", "N", Nil})
		AADD(aCabec, {"F2_FORMUL", " ", Nil})
		AADD(aCabec, {"F2_DOC", PADR(StrZero(nX, nTam),TAMSX3('F2_DOC')[1]), Nil})
		AADD(aCabec, {"F2_SERIE", cSerie, Nil})
		AADD(aCabec, {"F2_EMISSAO", dDataBase, Nil})
		AADD(aCabec, {"F2_CLIENTE", SA1->A1_COD, Nil})
		AADD(aCabec, {"F2_LOJA", SA1->A1_LOJA, Nil})
		AADD(aCabec, {"F2_ESPECIE", cEspec, Nil})
		AADD(aCabec, {"F2_COND", "1", Nil})
		AADD(aCabec, {"F2_DESCONT", 0, Nil})
		AADD(aCabec, {"F2_FRETE", 0, Nil})
		AADD(aCabec, {"F2_SEGURO", 0, Nil})
		AADD(aCabec, {"F2_DESPESA", 0, Nil})
		aLinha := {}
		AADD(aLinha, {"D2_COD", cProduto, Nil})
		AADD(aLinha, {"D2_QUANT", 1, Nil})
		AADD(aLinha, {"D2_PRCVEN", 1, Nil})
		AADD(aLinha, {"D2_TOTAL", 1, Nil})
		AADD(aLinha, {"D2_TES", cTES, Nil})
		AADD(aItens, aLinha)

		MATA920(aCabec, aItens)

		// Exclui a nota na base pela rotina automática MATA920
		MATA920(aCabec, aItens, 5)

		cNfsInut += StrZero(Val(cSerie),3)+cDoc+CRLF
		nY++
		nNFes++

		If lTransmitida
            SF3->(RecLock("SF3", .F.))
            SF3->F3_PROTOC  := aAutoExec[7]     //Protocolo de inutilizacao
            SF3->F3_EMINFE  := aAutoExec[8]     //Data de inutilizacao
            SF3->F3_HORNFE  := aAutoExec[9]     //Hora de inutilizacao
            SF3->F3_CODRSEF := aAutoExec[10]    //Codigo Retorno
            SF3->F3_CODRET  := "M"              //Status
            SF3->F3_DESCRET := "Inutilização de número homologado" //Descricao
            SF3->(MsUnlock())
		Else
    		//TOTVS Colaboracao
    		If lUsaColab
    			cMod	 := IIf(cModelo == "55","NFE","CTE")
    			aInfXml := ColExpDoc(cSerId , cDoc , cMod )

    			// Se !aInfXml[1] retornar .F. esta correto não existe na base e se VldInut() .T. validado pode inutilizar.
    			If !aInfXml[1]

    				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    				//³ Adicionando no aNFe para manter o padrao das funcoes SpedCCeXml e ColEnvEvento³
    				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    				aNFeCol := {}
    				aAdd(aNFeCol,aInfXml[2])					//01 - Chave da Nfe
    				aAdd(aNFeCol,"")			 				//02 - em branco
    				aAdd(aNFeCol,cSerId) 					//03 - Serie
    				aAdd(aNFeCol,cDoc) 			//04 - Numero


    				cXml := ColInutTrans( aNFeCol , nil , cModelo )
    				ColEnvEvento( cMod , aNFeCol , cXml , nil , @cErro , .T. )
    				lCancOk := ColAtuTrans( /*cEntSai*/ , cSerId, cDoc ,/*cCliente*/,/*cLoja*/,/*lCTe*/,/*cChvCtg*/,/*nTpEmisCte*/)
    				If !Empty(cErro)
    					cErro += cErro+CRLF
    				EndIf
    			EndIf
         	Else
         	    // TOTVS Sped Service
    			aadd(oWs:oWsNFe:oWsNotas:oWSNFES,NFESBRA_NFES():New())
    			oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cID := cSerId+StrZero(nX,nTam)

    			If cVersao < "1.11"
    				oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= GetUFCode(cUFEnt)+FsDateConv(dDataBase,"YYMM")+cCNPJEnt+cModelo+StrZero(Val(cSerie),3)+StrZero(nX,9)+Inverte(StrZero(nX,nTam))
    			Else
    				oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= GetUFCode(cUFEnt)+FsDateConv(dDataBase,"YYMM")+cCNPJEnt+cModelo+StrZero(Val(cSerie),3)+StrZero(nX,9)+cModalidade+Inverte(StrZero(Val(SubStr(StrZero(nX,nTam),2,8)),8))
    			EndIf

    			oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= 'Id="' +	oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML + Modulo11(oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML) + '"'

    			If ExistBlock("FISINUNFE")
    				oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML := ExecBlock("FISINUNFE",.F.,.F.,{oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML,StrZero(Val(cSerie),3)+StrZero(nX,9)})
    			EndIf


    			If nY >=50 .Or. nX==Val(cNotaFim)
    				If oWs:CancelaNotas()
    					oWs:= WsNFeSBra():New()
    					oWs:cUserToken := "TOTVS"
    					oWs:cID_ENT    := cIdEnt
    					oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
    					oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
    					nY := 0
    				Else
    					cErro	+=	IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF
    		        EndIf
    			EndIf
    		EndIf
    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    		//³Array necessário para gravar  F3_CODRET quando existir    ³
    		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    		If !lUsaColab
    		DBSelectArea("SF3")
    	 	DBSetOrder(6)
     			If DBSeek(xFilial("SF3") + PadR(StrZero(nX, nTam), Len(cDoc)) + cSerie)
     			    aNotas   := {}
    				aadd(aNotas,IIF(SF3->F3_CFO<"5","0","1"))
    				aadd(aNotas,SF3->F3_ENTRADA)
    				aadd(aNotas,SF3->F3_SERIE)
    				aadd(aNotas,SF3->F3_NFISCAL)
    				aadd(aNotas,SF3->F3_CLIEFOR)
    				aadd(aNotas,SF3->F3_LOJA)
    			  	gravaCodRet( aNotas ) //Grava na F3_CODRET = T |Transmitido|se existir o campo na SF3
    			EndIf
    		EndIf
    	EndIf
	Next nX
EndIf

If !lAuto
    If lUsaColab
    	cRetorno := STR0491+CRLF 		//"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."
    	cRetorno += STR0492+CRLF+CRLF //"Verifique se os arquivos foram processados e autorizados na SEFAZ via TOTVS Colaboração, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
    Else
    	cRetorno := STR0184+CRLF	//"Você concluíu com sucesso o processo de transmissão das inutilizações do Protheus para o Totvs Services SPED."
    	cRetorno += STR0027+CRLF+CRLF 	//"Verifique se as notas foram autorizadas na SEFAZ, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
    EndIf

    cRetorno += STR0028+AllTrim(Str(nNFes,18))+STR0029+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
    cRetorno += cNfsInut

    If !Empty(cErro)
    	If lUsaColab
    		cRetorno := STR0490+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."
    	Else
    		cRetorno := CRLF+CRLF+STR0185+CRLF+CRLF	//"Houve erro durante o envio dos documentos de inutilização para o Totvs Services SPED."
    	EndIf
    	cRetorno += cErro
    EndIf
EndIf

Return(cRetorno)

Static Function VldInut(cSerie,cNFIni,cNFFim,cModelo,lAuto)

	Local lRet     := .T.
	Local cMsg     := ""
	Local cCliente := PADR(SuperGetMV("MV_INUTCLI", .F., ""),TAMSX3("A1_COD"   )[1])
	Local cProduto := PADR(SuperGetMV("MV_INUTPRO", .F., ""),TAMSX3("B1_COD"   )[1])
	Local cTES     := PADR(SuperGetMV("MV_INUTTES", .F., ""),TAMSX3("F4_CODIGO")[1])

	Default lAuto := .F.

	cMsg	+=	STR0186+CRLF+CRLF	//"Esta rotina tem como objetivo efetuar a inutilização dos documentos fiscais eletrônicos junto a SEFAZ."
	cMsg	+=	STR0187	//"Aconselhamos a utilização desta rotina somente em caráter emergencial e muito específico, onde houve salto de numeração de documento que não necessita de registro no sistema. Caso contrário, o fluxo normal de cancelamento de documentos fiscais deve ser efetuado no Protheus, onde a rotina de transmissão tem os recursos necessários para identificar se os documentos fiscais devem ser transmitidos normalmente, inutilizados ou cancelados na SEFAZ."

	If Empty(cNFIni) .Or. Empty(cNFFim) .Or. Empty(cModelo)
		Aviso("SPED",STR0188,{STR0114},3)	//"Informar os campos destacados em azul para prosseguir na transmissão. Os campos são obrigatórios."
		lRet	:=	.F.
	ElseIf cModelo <> "55" .And. cModelo <> "57" .And. cModelo <> "65"
		If lAuto
            Help( " ", 1, "Help",, STR0189, 1, 0 )
            lMsErroAuto := .T.
        Else
            Aviso("SPED",STR0189,{STR0114},3)	//"Funcionalidade permitida somente para notas fiscais eletrônicas modêlo '55'."
        EndIf
		lRet	:=	.F.
	// Checa se os parâmetros MV_INUTCLI, MV_INUTPRO e MV_INUTTES existem e estão populados
	ElseIf Empty(cCliente) .Or. Empty(cProduto) .Or. Empty(cTES)
		If lAuto
            Help( " ", 1, "Help",, STR0197 + CRLF + CRLF + STR0198, 1, 0 )
            lMsErroAuto := .T.
        Else
            Aviso("SPED", STR0197 + CRLF + CRLF + STR0198, {STR0114}, 3) // "Os parâmetros MV_INUTCLI, MV_INUTPRO e MV_INUTTES não foram encontrados ou estão com o conteúdo vazio." "Por favor corrija o problema criando e populando o conteúdo dos parâmetros."
		EndIf
		lRet := .F.
	Else
		// Checa se os códigos de cliente, produto e TES dos parâmetros existem na base
		DBSelectArea("SA1") // Clientes
		DBSetOrder(1)
		If !(SA1->(DBSeek(xFilial("SA1") + cCliente)))
			If lAuto
                Help( " ", 1, "Help",, STR0199 + cCliente + STR0200, 1, 0 )
                lMsErroAuto := .T.
            Else
                Aviso("SPED", STR0199 + cCliente + STR0200, {STR0114}, 3) // "O cliente de código " " declarado no parâmetro MV_INUTCLI não foi encontrado."
            EndIf
			lRet := .F.
		ElseIf SA1->A1_MSBLQL == "1"
			If lAuto
                Help( " ", 1, "Help",, STR0199 + cCliente + STR0454, 1, 0 )
                lMsErroAuto := .T.
            Else
                Aviso("SPED", STR0199 + cCliente + STR0454, {STR0114}, 3) // " declarado no parâmetro MV_INUTCLI,está bloqueiado para uso"
            EndIf
			lRet := .F.
		EndIf

		DBSelectArea("SB1") // Produtos
		DBSetOrder(1)
		If !(SB1->(DBSeek(xFilial("SB1") + cProduto)))
			If lAuto
                Help( " ", 1, "Help",, STR0201 + cProduto + STR0202, 1, 0 )
                lMsErroAuto := .T.
            Else
                Aviso("SPED", STR0201 + cProduto + STR0202, {STR0114}, 3) // "O produto de código " " declarado no parâmetro MV_INUTPRO não foi encontrado."
            EndIf
			lRet := .F.
		ElseIf SB1->B1_MSBLQL == "1"
			If lAuto
                Help( " ", 1, "Help",, STR0201 + cProduto + STR0455, 1, 0 )
                lMsErroAuto := .T.
            Else
                Aviso("SPED", STR0201 + cProduto + STR0455, {STR0114}, 3) // " declarado no parâmetro MV_INUTPRO,está bloqueiado para uso"
            EndIf
			lRet := .F.
		EndIf

		DBSelectArea("SF4") // TES
		DBSetOrder(1)
		If !(SF4->(DBSeek(xFilial("SF4") + cTES)))
			If lAuto
                Help( " ", 1, "Help",, STR0203 + cTES + STR0204, 1, 0 )
                lMsErroAuto := .T.
            Else
                Aviso("SPED", STR0203 + cTES + STR0204, {STR0114}, 3) // "O TES de código " " declarado no parâmetro MV_INUTTES não foi encontrado."
            EndIf
			lRet := .F.
		ElseIf SF4->F4_MSBLQL == "1"
			If lAuto
                Help( " ", 1, "Help",, STR0203 + cTES + STR0456, 1, 0 )
                lMsErroAuto := .T.
            Else
                Aviso("SPED", STR0203 + cTES + STR0456, {STR0114}, 3) // " declarado no parâmetro MV_INUTTES,está bloqueiado para uso"
            EndIf
			lRet := .F.
		EndIf

		If lRet .And. !lAuto
			Aviso("!!ATENÇÃO!!",cMsg,{STR0114},3)
			If Aviso("!!ATENÇÃO!!",STR0190+" '"+cNFIni+"' "+STR0191+" '"+cNFFim+"' "+STR0192+" '"+cSerie+"' ?"+CRLF+CRLF+"!!IMPORTANTE!!"+CRLF+STR0193,{STR0194,STR0195},3)==2	//"Confirma a inutilização da faixa de numeração dos documentos fiscais iniciada em"###"e finalizada em"###"da serie"###"ESSA EXECUTAÇÃO NÃO PODERÁ SER REVERTIDA VIA SISTEMA. OS DOCUMENTOS FISCAIS DESTA FAIXA FICARÃO INUTILIZADOS JUNTO A SEFAZ."###"Confirma"###"Cancela"
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf

Return lRet


//--------------------------------------------------------------
/*/{Protheus.doc} TFontEx
Classe auxiliar de TFont criada para otimizar a impressão

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
Class TFontEx From LongClassName
	DATA cClassName
	DATA oFont
	DATA aFntWidth

	METHOD New() Constructor
	METHOD GetTextWidht()
EndClass

//--------------------------------------------------------------
/*/{Protheus.doc} New
Método contrutor da classe

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
METHOD New( oDanfe,cName,nWidth,nHeight,lBold,lUnderline,lItalic ) Class TFontEx
Local nX
	::cClassName := 'TFontEx'
	// Cria fonte
	::oFont := TFont():New( cName,nWidth,nHeight,,lBold,,,,lUnderline,lItalic )

	// Alimenta vetor com as larguras desta fonte
	::aFntWidth := {}
	// Verifica binario para execução da rotina que retorna lagura da fonte
	If GetBuild() >= '7.00.081215P-20090316'
		//::aFntWidth := GetFontPixWidths( cName,Abs(nHeight),lBold,lItalic ) // OLD
	  oDanfe:GetFontWidths( ::oFont, ::aFntWidth )
	Else
 		For nX := 1 To 255
	 		Aadd( ::aFntWidth, oDanfe:GetTextWidth(Chr(nX),::oFont) )
		Next
	Endif
Return

//--------------------------------------------------------------
/*/{Protheus.doc} GetTextWidht
Retorna largura do texto baseado na fonte

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
METHOD GetTextWidht( cTexto ) Class TFontEx
Local nX
Local nWidht := 0
Local      nLen   := Len( AllTrim( cTexto ) )

For nX := 1 to nLen
	nWidht += ::aFntWidth[ Asc( SubStr( cTexto, nX, 1 ) ) ]
next nX

Return( nWidht )

//------------------------//------------------------//------------------------

// clone da funcao SPEDNFEID -- SPED_FW02.PRX (TSS)
Function NfeIdSPED(cXML,cAttId)
Local nAt  := 0
Local cURI := ""
Local nSoma:= Len(cAttId)+2

nAt := At(cAttId+'=',cXml)
cURI:= SubStr(cXml,nAt+nSoma)
nAt := At('"',cURI)
If nAt == 0
	nAt := At("'",cURI)
EndIf
cURI:= SubStr(cURI,1,nAt-1)
Return(cUri)

// clone da funcao localizada no donfe SPED_FW02.PRX (TSS)
Static Function GetUFCode(cUF,lForceUF)

Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}
DEFAULT lForceUF := .F.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][IIF(!lForceUF,2,1)]
	EndIf
Else
	cRetorno := aUF
EndIf
Return(cRetorno)

Function GetXMLNFE(cIdEnt,aIdNFe,cModalidade,cModelo)

Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local oWS
Local cRetorno   := ""
Local cProtocolo := ""
Local cRetDPEC   := ""
Local cProtDPEC  := ""
Local nX         := 0
Local nY         := 0
Local nL			 := 0
Local aRetorno   := {}
Local aResposta  := {}
Local aFalta     := {}
Local aExecute   := {}
Local nLenNFe
Local nLenWS
Local cDHRecbto  := ""
Local cDtHrRec   := ""
Local cDtHrRec1	 := ""
Local nDtHrRec1  := 0
Local lFlag      := .T.
Local dDtRecib	:=	CToD("")

Private oDHRecbto

Default cModelo:= "55"
If Empty(cModalidade)
	cModalidade := getCfgModalidade(@cError, cIdEnt, cModelo)

EndIf
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
nLenNFe := Len(aIdNFe)
For nX := 1 To nLenNFe
	aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","","",CToD("")})
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nX][4]+aIdNfe[nX][5]
Next nX
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

If oWS:RETORNANOTASNX()
	If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
		For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
			cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
			cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
			cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
			If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
				cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
				cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
			EndIf
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				oDHRecbto		:= XmlParser(cDHRecbto,"","","")
				cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
				oDHRecbto		:= NIL
				nDtHrRec1		:= RAT("T",cDtHrRec)

				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf
				dbSelectArea("SF2")
				dbSetOrder(1)
				If MsSeek(xFilial("SF2")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
						RecLock("SF1")
						SF1->F1_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
			EndIf
			nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
			If nY > 0
				aRetorno[nY][1] := cProtocolo
				aRetorno[nY][2] := cRetorno
				aRetorno[nY][4] := cRetDPEC
				aRetorno[nY][5] := cProtDPEC
				aRetorno[nY][6] := cDtHrRec1
				aRetorno[nY][7] := dDtRecib

				aadd(aResposta,aIdNfe[nY])
			EndIf
			cRetDPEC := ""
			cProtDPEC:= ""
		Next nX
		For nX := 1 To Len(aIdNfe)
			If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
				aadd(aFalta,aIdNfe[nX])
			EndIf
		Next nX
		If Len(aFalta)>0
			aExecute := GetXMLNFE(cIdEnt,aFalta,@cModalidade,cModelo)
		Else
			aExecute := {}
		EndIf
		For nX := 1 To Len(aExecute)
			nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
			If nY == 0
				aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
			Else
				aRetorno[nY][01] := aExecute[nX][01]
				aRetorno[nY][02] := aExecute[nX][02]
			EndIf
		Next nX
	EndIf
Else
	Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf

Return(aRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedConsCad
Função que monta a tela para realizar a consulta do contribuinte na SEFAZ

@author  Eduardo Silva
@since 13/06/2011
@version 1.0
/*/
//-----------------------------------------------------------------------

Function SpedConsCad()

Local cIE		:= Space(14)
Local cUF		:= Space(2)

Local oDlgKey, oBtnOut, oBtnCon

If IsReady()

	DEFINE FONT oFont BOLD

	DEFINE MSDIALOG oDlgKey TITLE STR0205 FROM 0,0 TO 140,305 PIXEL OF GetWndDefault() 										//"Consulta Contribuinte"

	@ 008,008 SAY STR0206 PIXEL FONT oFont OF oDlgKey 															 //"Informe os dados para a consulta"

	@ 023,010 SAY STR0207 PIXEL OF oDlgKey			     														 //"Estado:"
	@ 021,030 MSGET oGetUF VAR cUF OF oDlgKey SIZE 020, 009 PICTURE "@!" PIXEL F3 "12" VALID {|| If(Empty(cUF),(MsgInfo(STR0208),.F.),.T.) } //"Preencha o campo 'Estado'!"

	@ 037,010 SAY STR0209 PIXEL OF oDlgKey			     														 //"IE:"
	@ 035,018 MSGET oGetIE VAR cIE OF oDlgKey SIZE 040, 009 PIXEL VALID {|| If(Empty(cIE),(MsgInfo(STR0210),.F.),.T.) }				 //"Preencha o campo 'IE'!"

	@ 057,107 BUTTON oBtnCon PROMPT STR0211 SIZE 38,11 PIXEL ACTION (ConsCad(cIE,cUF),oDlgKey:End() ) OF oDlgKey  					//"Consultar"

	ACTIVATE DIALOG oDlgKey CENTERED

Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} ConsCad
Funcao realiza a consulta do contribuinte junto a SEFAZ.

@author  Eduardo Silva
@since 13/06/2011
@version 1.0

@param		cIE		Inscrição Estadual
			cUF         Unidade Federativa (Estado)
/*/
//-----------------------------------------------------------------------
Static Function ConsCad(cIE,cUF)

Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt    	:= ""
Local cRazSoci 	:= ""
Local cRegApur    := ""
Local cCnpj	      := ""
Local cCpf	      := ""
Local cSituacao   := ""
Local cPictCNPJ	:= ""

Local dIniAtiv    := Date()
Local dAtualiza	:= Date()

Local nX	    	:= {}

Private oWS

cIdEnt := GetIdEnt()


oWs:= WsNFeSBra() :New()
oWs:cUserToken    := "TOTVS"
oWs:cID_ENT		:= cIdEnt
oWs:cUF		:= cUF
oWs:cCNPJ		:= ""
oWs:cCPF		:= ""
oWs:cIE		:= Alltrim(cIE)
oWs:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

If oWs:CONSULTACONTRIBUINTE()

	If Type("oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE") <> "U"
		If ( Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE) > 0 )
			nX := Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)

			If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade) <> "U"
		   		dIniAtiv  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade
		   	Else
		   	     	dIniAtiv  := ""
			EndIf
			cRazSoci  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRazaoSocial
			cRegApur  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRegimeApuracao
			cCnpj	    := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCNPJ
			cCpf	    := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCPF
		   	cIe       := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIE
		   	cUf	    := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cUF
			cSituacao := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cSituacao

		  	If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao) <> "U"
			  	dAtualiza := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao
			Else
				dAtualiza := ""
			EndIf

			If ( cSituacao == "1" )
				cSituacao := STR0212 //"1 - Habilitado"
			ElseIf ( cSituacao == "0" )
				cSituacao := STR0213 //"0 - Não Habilitado"
			EndIf


			If ( !Empty(cCnpj) )
				cCnpj		:= cCnpj
				cPictCNPJ	:= "@R 99.999.999/9999-99"
			Else
				cCnpj		:= cCPF
				cPictCNPJ	:= "@R 999.999.999-99"
			EndIf




			DEFINE FONT oFont BOLD

			DEFINE MSDIALOG oDlgKey TITLE STR0214 FROM 0,0 TO 200,355 PIXEL OF GetWndDefault()  //"Retorno do Consulta Contribuinte"

			@ 008,010 SAY STR0215		 PIXEL FONT oFont OF oDlgKey    	//"Início das Atividades:"
			@ 008,072 SAY If(Empty(dIniAtiv),"",DtoC(dIniAtiv))	 PIXEL OF oDlgKey
			@ 008,115 SAY STR0216 		 PIXEL FONT oFont OF oDlgKey		//"UF:"
			@ 008,124 SAY cUf			 PIXEL OF oDlgKey
			@ 020,010 SAY STR0217		 PIXEL FONT oFont OF oDlgKey 		//"Razão Social:"
			@ 020,048 SAY cRazSoci		 PIXEL OF oDlgKey
			@ 032,010 SAY STR0218		 PIXEL FONT oFont OF oDlgKey  	//"CNPJ/CPF:"
			@ 032,040 SAY cCnpj		 PIXEL PICTURE cPictCNPJ OF oDlgKey
			@ 032,115 SAY STR0209		 PIXEL FONT oFont OF oDlgKey  	//"IE:"
			@ 032,123 SAY cIe			 PIXEL OF oDlgKey
			@ 044,010 SAY STR0219		 PIXEL FONT oFont OF oDlgKey  	//"Regime:"
			@ 044,035 SAY cRegApur		 PIXEL OF oDlgKey
			@ 056,010 SAY STR0220		 PIXEL FONT oFont OF oDlgKey  	//"Situação:"
			@ 056,038 SAY cSituacao		 PIXEL OF oDlgKey
			@ 068,010 SAY STR0221   	 PIXEL FONT oFont OF oDlgKey  	 //"Atualizado em:"
  			@ 068,055 SAY If(Empty(dAtualiza),"",DtoC(dAtualiza))	 PIXEL OF oDlgKey

			@ 80,137 BUTTON oBtnCon PROMPT STR0114 SIZE 38,11 PIXEL ACTION oDlgKey:End()	//"Ok"

			ACTIVATE DIALOG oDlgKey CENTERED

		EndIf
	EndIf
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedCLeRemessa³ Autor ³Renato Cruz Nagib  ³ Data ³17.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Capa de Lote eletronica para o Totvs   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias                                                ³±±
±±³          ³ExpC2: nReg                                                 ³±±
±±³          ³ExpC3: nOpc                                                 ³±±
±±³          ³ExpC4: cMarca(utilizado na Transmissao)                     ³±±
±±³          ³ExpC5: lInverte                                             ³±±
±±³          ³ExpC6: cID da Capa de Lote(utilizado na Retransmissao)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedCLeRemessa(cAlias,nReg,nOpc,cMarca,lInverte,cIDCLe,lCleTms,aOpcVeic,aDocs)

	Local aArea       := GetArea()
	Local aPerg       := {}
	Local aTexto      := {}
	Local cRetorno    := ""
	Local cIdEnt      := ""
	Local cAmbiente   := ""
	Local cVersao     := ""
	Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local lOk         := .T.
	Local oWs
	Local oWizard
	Local cAliasSF2 := GetNextAlias()
	Local lRedef:=.F.
	Local nX:=1
	Local aCapa:={}
	Local cTran:=.F.
	Local oCheckBox
	Local lRetran:=!Empty(cIDCLe)
	Local lTran:=.T.
	Local cWhere:=""
	Local aDocsTms  := {}

	Default lCleTms := .F.
	Default aOpcVeic:={}
	Default aDocs   :={{}}

	//Transmissao
	If !lCleTms
		If !lRetran

			If lInverte
				cWhere+="%SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_IDCLE ='' AND F2_CHVNFE<>'' AND F2_CLEOK <>'"+cMarca+"' "+cCondQry+"%"
			Else
				cWhere+="%SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_IDCLE =''  AND F2_CHVNFE<>'' AND SF2.F2_CLEOK ='"+cMarca+"'"+cCondQry+"%"
			EndIF

			BeginSql Alias cAliasSF2
				Column F2_EMISSAO As Date
				SELECT	F2_VEICUL1,F2_VEICUL2,F2_VEICUL3,F2_DOC,F2_SERIE,F2_EMISSAO,R_E_C_N_O_,F2_CHVNFE,F2_EST
				FROM %Table:SF2% SF2
				WHERE %Exp:cWhere% AND
				SF2.%notdel%
				ORDER BY 1,2,3
			EndSql
		//Retransmissao
		Else
			BeginSql Alias cAliasSF2
				Column F2_EMISSAO As Date
				SELECT	F2_VEICUL1,F2_VEICUL2,F2_VEICUL3,F2_DOC,F2_SERIE,F2_EMISSAO,R_E_C_N_O_,F2_CHVNFE,F2_EST
				FROM %Table:SF2% SF2
				WHERE SF2.F2_IDCLE = %Exp:cIDCLe% AND
				SF2.%notdel%
				ORDER BY 1,2,3
			EndSql
		EndIF

		(cAliasSF2)->(dbGotop())

		cChave:=(cAliasSF2)->F2_VEICUL1+(cAliasSF2)->F2_VEICUL2+(cAliasSF2)->F2_VEICUL3

		If Empty((cAliasSF2)->F2_VEICUL1)
			aadd(aOpcVeic,{STR0234,"","",.F.})//"Veículo não definido"
		Else
			aadd(aOpcVeic,{(cAliasSF2)->F2_VEICUL1,(cAliasSF2)->F2_VEICUL2,(cAliasSF2)->F2_VEICUL3,.T.})
		EndIf

		If (cAliasSF2)->(Eof())
			Return nil
		EndIf
		While (cAliasSF2)->(!Eof())
		   	If (cAliasSF2)->F2_VEICUL1+(cAliasSF2)->F2_VEICUL2+(cAliasSF2)->F2_VEICUL3 <> cChave
				nX++
				aadd(aDocs,{})
				If Empty((cAliasSF2)->F2_VEICUL1)
					aadd(aOpcVeic,{STR0234,"","",.F.})//"Veículo não definido"
				Else
					aadd(aOpcVeic,{(cAliasSF2)->F2_VEICUL1,(cAliasSF2)->F2_VEICUL2,(cAliasSF2)->F2_VEICUL3,.T.})
				EndIf
				aadd(aDocs[nX],{(cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE,(cAliasSF2)->F2_EMISSAO,(cAliasSF2)->R_E_C_N_O_,(cAliasSF2)->F2_EST,(cAliasSF2)->F2_CHVNFE})
				lRedef:=.T.
			Else
				aadd(aDocs[nX],{(cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE,(cAliasSF2)->F2_EMISSAO,(cAliasSF2)->R_E_C_N_O_,(cAliasSF2)->F2_EST,(cAliasSF2)->F2_CHVNFE})
			EndIf
			cChave:=(cAliasSF2)->F2_VEICUL1+(cAliasSF2)->F2_VEICUL2+(cAliasSF2)->F2_VEICUL3
			(cAliasSF2)->(dbSkip())
		End
	Else
		If lRetran
			BeginSql Alias cAliasSF2
				Column F2_EMISSAO As Date
				SELECT	F2_VEICUL1,F2_VEICUL2,F2_VEICUL3,F2_DOC,F2_SERIE,F2_EMISSAO,R_E_C_N_O_,F2_CHVNFE,F2_EST,F2_CLIENTE,F2_LOJA
				FROM %Table:SF2% SF2
				WHERE SF2.F2_IDCLE = %Exp:cIDCLe% AND
				SF2.%notdel%
				ORDER BY 1,2,3
			EndSql

			(cAliasSF2)->(dbGotop())

			If (cAliasSF2)->(Eof())
				Return nil
			EndIf
			While (cAliasSF2)->(!Eof())
				MontaCleTMS((cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE,(cAliasSF2)->R_E_C_N_O_,(cAliasSF2)->F2_EST,(cAliasSF2)->F2_CLIENTE,(cAliasSF2)->F2_LOJA,@aOpcVeic,@aDocsTms)
				(cAliasSF2)->(dbSkip())
			End
			aDocs   :=aDocsTms
		EndIf
	EndIf

	If IsReady()
		If !lCleTms
			If lRedef .Or.  aScan(aOpcVeic,{|X| X[4] == .F. }) > 0
				lOk:=CheckCLe(@aOpcVeic,@aDocs)
			Else
				aOpcVeic:=aOpcVeic[1]
				aDocs	:=aDocs[1]
			EndIf
		Else
			lOk    := .T.
		EndIf
		If lOk
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem o codigo da entidade                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cIdEnt := GetIdEnt()

			If !Empty(cIdEnt)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtem o ambiente de execucao do Totvs Services SPED                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oWS := WSWSCLE():New()
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:nNAMBIENTECLE  := 0
				oWS:cCVERSAOCLE:=""
				oWS:_URL       := AllTrim(cURL)+"/WSCLe.apw"
				lOk := oWS:CONFIGCLE()
				If lOk
					If Valtype(oWS:oWSCONFIGCLERESULT:cVERSAO) == "U" .Or. Valtype(oWS:oWSCONFIGCLERESULT:cAMBIENTE) == "U"
						oWS := WSWSCLE():New()
						oWS:cUSERTOKEN := "TOTVS"
						oWS:cID_ENT    := cIdEnt
						oWS:nNAMBIENTECLE  := 2
						oWS:cCVERSAOCLE:="1.00"
						oWS:_URL       := AllTrim(cURL)+"/WSCLe.apw"
						lOk := oWS:CONFIGCLE()
					EndIF
					If lOk
						cAmbiente	:= oWS:oWSCONFIGCLERESULT:cAMBIENTE
						cVersao		:= oWS:oWSCONFIGCLERESULT:cVERSAO
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Montagem da Interface                                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If(!lRetran,cIDCLe:=IDCLE(),"")
					If !Empty(cIDCLe)
						cModulo:=STR0240//"Faturamento"
						aadd(aTexto,{})
						aTexto[1] :=STR0241//"Esta rotina tem como objetivo auxilia-lo na transmissão da Capa de lote eletrônica para o serviço Totvs Services SPED. "
						aTexto[1] += STR0014+CRLF+CRLF //"Neste momento o Totvs Services SPED, está operando com a seguinte configuração: "
						aTexto[1] += STR0015+cAmbiente+CRLF //"Ambiente: "
						aTexto[1] += STR0017+cVersao+CRLF	//"Versao do Layout: "
						If !lCleTms
							aTexto[1] +=STR0242+cModulo//"Modulo:"
						EndIf
						aadd(aTexto,{})

						DEFINE WIZARD oWizard ;
							TITLE STR0243;//"Capa de lote eletrônica -CLe";
							HEADER STR0244;//"Assistente para transmissão da capa de lote eletrônica";
							MESSAGE STR0245;//"Configuração para a transmissão";
							TEXT aTexto[1] ;
							NEXT {|| .T.} ;
							FINISH {||.T.}
						CREATE PANEL oWizard  ;
							HEADER STR0246;//"Assistente de configuração da Capa de lote Eletrônica";
							MESSAGE STR0247;//"Dados da Capa de lote";
							BACK {|| .T.} ;
							NEXT {|| Processa({|lEnd| cRetorno:=SpedCLeTrf(@aOpcVeic,@aDocs,@cIDCLe,@lEnd,@lTran,lCleTms)}),AtualizaIDCLE(cIDCLe),aTexto[2]:=cRetorno,.T.} ;
							PANEL
							DEFINE FONT oBold BOLD
							@010,010 SAY	STR0324	PIXEL OF oWizard:oMPanel[2] FONT oBold  //Numero
							@010,036 SAY	Substr(cIDCLe,4)	PIXEL OF oWizard:oMPanel[2]
							@010,074 SAY	STR0249	PIXEL OF oWizard:oMPanel[2] FONT oBold  //Série
							@010,093 SAY	Substr(cIDCLe,1,3)	PIXEL OF oWizard:oMPanel[2]
							@010,110 SAY	STR0314	PIXEL OF oWizard:oMPanel[2] FONT oBold  //"UF Orígem: "
							@010,143 SAY	SM0->M0_ESTENT		PIXEL OF oWizard:oMPanel[2]
							@010,160 SAY	STR0226	PIXEL OF oWizard:oMPanel[2] FONT oBold//UF Destino
							@010,194 SAY	 aDocs[1,5]			PIXEL OF oWizard:oMPanel[2]
							@010,216 SAY	STR0325	PIXEL OF oWizard:oMPanel[2]  FONT oBold //Emissao
							@010,246 SAY	DtoC(Date())	PIXEL OF oWizard:oMPanel[2]
							@025,010 LISTBOX oListMonitor 	FIELDS HEADER STR0248,STR0249,STR0250,STR0251,STR0252 SIZE 270,080 PIXEL OF oWizard:oMPanel[2]//Nota fiscal,Serie,Emissão,Chave NF,Chave CLe
					        oListMonitor:SetArray(aDocs)
					        oListMonitor:bLine:={||	{	aDocs[oListMonitor:nAt][01],;
						        						aDocs[oListMonitor:nAt][02],;
						        						aDocs[oListMonitor:nAt][03],;
						        						aDocs[oListMonitor:nAt][06]	}}

							If !lCleTMS
								If POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[1],"DA3_TIPTRA") ==Padr("R",2)
									@110,010 SAY	STR0253	PIXEL OF oWizard:oMPanel[2] FONT oBold //"Placa Veículo: "
									@110,051 SAY 	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[1],"DA3_PLACA")	PIXEL OF oWizard:oMPanel[2]
									@120,010 SAY	STR0254	PIXEL OF oWizard:oMPanel[2] FONT oBold  //"UF Veiculo: "
									@120,043 SAY	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[1],"DA3_ESTPLA")	PIXEL OF oWizard:oMPanel[2]
									@110,090 SAY	STR0255	PIXEL OF oWizard:oMPanel[2] FONT oBold  //"Placa Carreta: "
									@110,131 SAY	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[2],"DA3_PLACA")	PIXEL OF oWizard:oMPanel[2]
									@120,090 SAY	STR0256	PIXEL OF oWizard:oMPanel[2] FONT oBold  //"UF Carreta: "
									@120,123 SAY	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[2],"DA3_ESTPLA")	PIXEL OF oWizard:oMPanel[2]
									@110,170 SAY	STR0257	PIXEL OF oWizard:oMPanel[2] FONT oBold  //"Placa Carreta2: "
									@110,214 SAY	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[3],"DA3_PLACA")	PIXEL OF oWizard:oMPanel[2]
									@120,170 SAY	STR0258	PIXEL OF oWizard:oMPanel[2] FONT oBold  //"UF Carreta2: "
									@120,207 SAY	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[3],"DA3_ESTPLA") PIXEL OF oWizard:oMPanel[2]
								Else
									@110,010 SAY	STR0259	PIXEL OF oWizard:oMPanel[2]  FONT oBold//"Ident Veículo:"
									@110,051 SAY 	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[1],"DA3_DESC")	PIXEL OF oWizard:oMPanel[2]
									@120,010 SAY	STR0260	PIXEL OF oWizard:oMPanel[2]  FONT oBold//"UF Veículo: "
									@120,043 SAY	POSICIONE("DA3",1,xFilial("DA3")+aOpcVeic[1],"DA3_ESTPLA")	PIXEL OF oWizard:oMPanel[2]
								EndIF
							EndIf

							If !lRetran
								@ 115,245 CHECKBOX oCheckBox VAR lTran PROMPT STR0261 OF oWizard:oMPanel[2] SIZE 040,040 MESSAGE STR0262//"Transmitir Capa de lote Sim/Não.Caso não marcada esta opção,a capa de lote ficará aguardando a transmissão "
							EndIf
						CREATE PANEL oWizard  ;
							HEADER STR0246;//"Assistente de configuração da Capa de lote Eletrônica"
							MESSAGE "";
							BACK {|| .T.} ;
							FINISH {|| .T.} ;
							PANEL
						@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
						ACTIVATE WIZARD oWizard CENTERED
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
	RestArea(aArea)
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedCLeTrf³ Autor ³Renato Cruz Nagib      ³ Data ³17.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Transmissao da capa de lote eletronica para o Totvs³±±
±±³          ³Service SPED                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Mensagem de retorno                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Array com os dados do veiculo                        ³±±
±±³          ³ExpC2: Array com os dados dos documentos                    ³±±
±±³          ³ExpC3: ID da capa de lote(passado para Retransmissao)       ³±±
±±³          ³ExpC3: lEnd                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedCLeTrf(aVeiculo,aDocs,cIDCLe,lEnd,lTran,lCleTms)

	Local cRetorno  	:= ""
	Local aXml      	:= {}
	Local lRetorno 	 	:= .T.
	Local nCLes     	:= 0
	Local dDataIni  	:= Date()
	Local cHoraIni  	:= Time()
	Local cURL      	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs
	Local nx
	Default lTran:=.T.
	Default lCleTms		:=.F.

	If Len(aVeiculo) > 0
		If lCleTms
			cIdEnt:= GetIdEnt()
		EndIf

		oWs:= WSWSCLE():New()
		oWs:cUSERTOKEN	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWs:cCLE_ID		:=cIDCLe
		oWS:_URL		:= AllTrim(cURL)+"/WSCLe.apw"
		If !lTran
			oWS:cCTRAN:="N"
		EndIf
		aXml := XmlCLeSef(aVeiculo,aDocs,lCleTms)
		nCLes:=aXML[1]
		nXmlSize2 := Len(aXML[2])

		If !Empty(aXML[2]) .And. nXmlSize2 <= TAMMAXXML
			oWs:cCLE:=aXML[2]
			lRetorno :=oWS:REMESSACLE()
		ElseIf !Empty(aXML[2]) .And. nXmlSize2 > TAMMAXXML
			Aviso("SPED",STR0149+ "("+cValToChar(nXmlSize2)+" Caracteres.)"+CRLF+CRLF+STR0150+aNotas[nX][4]+" / "+aNotas[nX][3],{STR0114},3)
		EndIf

		If lRetorno
			cRetorno :=STR0026+CRLF//"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED.
			cRetorno += STR0263+CRLF+CRLF//"Antes de imprimir,verifique se a capa de Lote foi autorizada na SEFAZ utilizando a rotina 'Monitor'."
			cRetorno += STR0264+AllTrim(Str(nCLes,18))+STR0029+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram capeadas "###" nota(s) em "
		 	If Alltrim(oWs:cCLE_ID) <> Alltrim(oWs:cREMESSACLERESULT)
				cRetorno+=STR0265+Alltrim(oWs:cCLE_ID)+STR0266//"A capa de Lote: "  " foi recusada,verifique a rotina Monitor para saber o motivo"
			EndIf
		 	For nx:=1 To Len(aDocs)
				SF2->(dbGoto(aDocs[nX][4]))
				RecLock("SF2")
				SF2->F2_IDCLE:=oWs:cCLE_ID
				SF2->(MsUnlock())
			Next
		Else
			cRetorno := STR0030+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
		EndIf
	Else
		cRetorno:=STR0267//"Nenhuma capa transmitida"
	EndiF
Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CheckCLe  ³ Autor ³Renato Cruz Nagib      ³ Data ³17.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra opcoes para a montagem da capa de lote               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Array com o veiculo e os documentos para transmissao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Array com os dados do veiculo                        ³±±
±±³          ³ExpC2: Array com os dados dos documentos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckCLe(aOpcVeic,aDocs)

	Local cMensagem:=""
	Local lRet:=.F.
	Local oVeic
	Local oDocs
	Local oOpctransp
	Local oVeiculo
	Local oCarreta
	Local oCarreta2
	Local oGrpVeic
	Local oGrpDocs
	Local oFnt
	Local cTamVeic:=Space(TAMSX3("DA3_COD")[1])
	Local cVeiculo:=cTamVeic
	Local cCarreta:=cTamVeic
	Local cCarreta2:=cTamVeic
	Local nOpcTransp
	Local nOpca
	Local aCapa:={}

	cMensagem:=STR0268+CRLF//"Para a transmissão da Capa de lote,deve-se definir o transporte a ser utilizado."
	cMensagem+=STR0269+CRLF//"Dentre as notas selecionadas,"
	cMensagem+=STR0270+CRLF	//"há notas que possuem veículos distintos ou ainda nao definidos.Você poderá definir da seguinte forma:"
	cMensagem+=STR0271+CRLF	//"1-Montar capa de lote para os documentos do veículo selecionado"
	cMensagem+=STR0272+CRLF	//"2-Montar capa de lote para todos os documentos Utilizando o veículo selecionado"
	cMensagem+=STR0273+CRLF	//"3-Definir veículo manualmente para todos os documentos"
	cMensagem+=STR0274		//"Deseja continuar?"

	If MsgYesNo(cMensagem)

		DEFINE MSDIALOG oDlg  TITLE STR0275 FROM 000,000 TO 510,850 PIXEL//"Definir Capa de Lote"
			@010,010 GROUP oGrpVeic TO 140,210 PROMPT STR0231		OF oDlg PIXEL//"Veículo"
			@010,215 GROUP oGrpDocs TO 140,415 PROMPT STR0276	OF oDlg PIXEL//"Documentos"

			@025,015 LISTBOX oVeic FIELDS HEADER STR0231,STR0232,STR0233 SIZE 190,110;//"Veículo","Carreta","Carreta2"
			ON CHANGE {||	oDocs:SetArraY(aDocs[oVeic:nAt]),;
							oDocs:bLine:={||{	aDocs[oVeic:nAt][oDocs:nAt][1],;
												aDocs[oVeic:nAt][oDocs:nAt][2],;
												aDocs[oVeic:nAt][oDocs:nAt][3],;
												aDocs[oVeic:nAt][oDocs:nAt][4]}},;
							oDocs:Refresh(),;
							(If(!aOpcVeic[oVeic:nAt][4],;
								(nOpcTransp:=3,oOpcTransp:Disable(),oVeiculo:Enable(),oCarreta:Enable(),oCarreta2:Enable(),oVeiculo:SetFOcus()),;
								(oOpcTransp:Enable())))}   OF oDlg PIXEL
			oVeic:SetArraY(aOpcVeic)
			oVeic:bLine:=	{||{	aOpcVeic[oVeic:nAt][1],;
									aOpcVeic[oVeic:nAt][2],;
									aOpcVeic[oVeic:nAt][3]}}

			@025,0220 LISTBOX oDocs FIELDS HEADER STR0248,STR0249,STR0250 SIZE 190,110 OF oDlg PIXEL//Nota fiscal,Serie,Emissão
			oDocs:SetArraY(aDocs[1])
			oDocs:bLine:=	{||{	aDocs[oDocs:nAt][1][1],;
									aDocs[oDocs:nAt][1][2],;
									aDocs[oDocs:nAt][1][3],;
									aDocs[oDocs:nAt][1][4];
								}}

			@150,010 RADIO oOpcTransp	VAR nOpcTransp WHEN (If(Len(aOpcVeic)==1 .And. !aOpcVeic[1][4],(nOpcTransp:=3,oOpcTransp:Disable(),oVeiculo:Enable(),oCarreta:Enable(),oCarreta2:Enable()),""))ITEMS	STR0271,STR0272,STR0273 SIZE 220,008 ON CHANGE {|| If(nOpcTransp == 3,(oVeiculo:Enable(),oCarreta:Enable(),oCarreta2:Enable(),oVeiculo:SetFocus()),(oVeiculo:Disable(),oCarreta:Disable(),oCarreta2:disable(),cVeiculo:=cTamVeic,cCarreta:=cTamVeic,cCarreta2:=cTamVeic)),oVeiculo:SetFocus()} PIXEL OF oDlg
			@185,010 SAY	STR0231	PIXEL OF oDlg//Veículo
			@185,040 MSGET	oVeiculo	VAR cVeiculo	F3 "DA3" PICTURE "@!"  SIZE 60,07 PIXEL OF oDlg
			@200,010 SAY	STR0232	PIXEL OF oDlg//"Carreta"
			@200,040 MSGET	oCarreta 	VAR cCarreta	F3 "DA3" PICTURE "@!" SIZE 60,10 PIXEL OF oDlg
			@215,010 SAY	STR0233	PIXEL OF oDlg//"Carreta2"
			@215,040 MSGET	oCarreta2	VAR cCarreta2	F3 "DA3" PICTURE "@!" SIZE 60,07 PIXEL OF oDlg

			oVeiculo:disable()
			oCarreta:disable()
			oCarreta2:disable()

			DEFINE SBUTTON FROM 230,010 TYPE 1 ENABLE OF oDlg ACTION (If((nOpcTransp==3 .And.(!NAOVAZIO(cVeiculo) .Or. !ExistCpo("DA3",cVeiculo,1))),oVeiculo:SetFocus(),(nOpca:=1,aCapa:=DefineCLe(aOpcVeic[oVeic:nAt],If(nOpcTransp==1,{aDocs[oVeic:nAt]},aDocs),nOpca,cVeiculo,cCarreta,cCarreta2,nOpcTransp),oDlg:End())))
			DEFINE SBUTTON FROM 230,055 TYPE 2 ENABLE OF oDlg ACTION (nOpca :=0,oDlg:End())
		ACTIVATE MSDIALOG oDlg CENTERED

    	If nOpca== 1
			aOpcVeic:=aCapa[1]
			aDocs	:=aCapa[2]
			lRet:=.T.
		EndIf
	EndIf
Return  lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DefineCLe ³ Autor ³Renato Cruz Nagib      ³ Data ³17.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Define o veiculo e os documentos para a capa de lote        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Array com o veiculo e os documentos para transmissao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: array com o veiculo posicionado                      ³±±
±±³          ³ExpC2: Array com todos os documentos                        ³±±
±±³          ³ExpC3: 1=confirma                                           ³±±
±±³          ³ExpC4: veiculo                                              ³±±
±±³          ³ExpC5: carreta                                              ³±±
±±³          ³ExpC6: carreta2                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DefineCLe(aOpcVeic,aDocs,nOpca,cVeiculo,cCarreta,cCarreta2,nOpcTransp)

	Local nX
	Local nY
	Local aRetDoc:={}
	Local aRetVeic:=aOpcVeic
	Local aArea:=SF2->(GetArea())
	If nOpca == 1
		If nOpcTransp ==3
			aRetVeic:={cVeiculo,cCarreta,cCarreta2}
		EndIf

		For nX:=1 To Len(aDocs)
			For nY:=1 To Len(aDocs[nX])
				SF2->(dbGoto(aDocs[nX][nY][4]))
				aadd(aRetDoc,aDocs[nX][nY])
				RecLock("SF2")
				SF2->F2_VEICUL1	:=aRetVeic[1]
				SF2->F2_VEICUL2	:=aRetVeic[2]
				SF2->F2_VEICUL3	:=aRetVeic[3]
				SF2->(MsUnlock())
			Next
		Next
	EndIf
	RestArea(aArea)
Return {aRetVeic,aRetDoc}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedCLeMnt³ Autor ³RENATO NAGIB           ³ Data ³16.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento da CLe - por faixa                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function SpedCLeMnt()

    Local cIdEnt
    Local oDlg
	Local aCle:={}
	Local nX
	Local aPerg:={}
	Local aLegenda:={}
	Local aParam:={Space(3),Space(09),Space(09)}
	Local cParCLeMon 	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDCLEMON"
	Local oListMonitor
	Local cAliasSF2 := GetNextAlias()
	Local aSize    := MsAdvSize()
	Local aObjects := {}
	Local aInfo    := {}
	Local aPosObj  := {}
	Local aArea:=SF2->(GetArea())
	Local lOk:=.F.
	Local lCleTMS:= Iif(FunName()$"TMSAE72,SPEDCTE",.T.,.F.)

	aadd(aPerg,{1,STR0249,aParam[01],"",".T.","",".T.",10,.T.})//"S[erie"
	aadd(aPerg,{1,STR0277,aParam[02],"",".T.","",".T.",30,.F.})//"Capa de"
	aadd(aPerg,{1,STR0278,aParam[03],"",".T.","",".T.",30,.F.})//"Capa At[e"

	Aadd(aLegenda, {"BR_VERDE"	,STR0279})//"Autorizada"
	Aadd(aLegenda, {"BR_AZUL"	,STR0281})//"Transmitida"
	Aadd(aLegenda, {"BR_LARANJA",STR0283})//"Aguardando Transmissão"
	Aadd(aLegenda, {"BR_CINZA"	,STR0280})//"Rejeitada"
	Aadd(aLegenda, {"BR_PRETO"	,STR0282})//"Erro de Schema"

    If ParamBox(aPerg,"SPED - CLe",@aParam,,,,,,,cParCLeMon,.T.,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIdEnt := GetIdEnt()
		aCle:=MontaCLe(cIdEnt,aParam,@lOk)

		If !lOk
			Aviso(STR0237,STR0321,{STR0114},3)//"Capa de lote","Houve um erro durante a consulta das capas de lote"
			Return nil
		ElseIf	Empty(aCle)
			Aviso(STR0237,STR0284,{STR0114},3)//"Capa de lote" "Não há dados"
			Return nil
		EndIF
	      //Atualização da SF2 com a chave da capa de lote
		For nX:=1 To Len(aCle)
			BeginSql Alias cAliasSF2
				SELECT	R_E_C_N_O_
				FROM %Table:SF2% SF2
				WHERE SF2.F2_IDCLE = %Exp:aCle[nX][2]% AND
				SF2.F2_FILIAL=%xFilial:SF2% AND
				SF2.%notdel%
			EndSql

			While (cAliasSF2)->(!Eof())
				If !Empty(aCle[nX][13])
					SF2->(dbGoTo((cAliasSF2)->R_E_C_N_O_))
					RecLock('SF2')
					SF2->F2_CHVCLE:=aCle[nX][13]
					SF2->(MsUnlock())
					(cAliasSF2)->(dbSkip())
				EndIf
			End
			If Select(cAliasSF2) > 0
				(cAliasSF2)->(dbCloseArea())
	    	EndIf
		Next

		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 015, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oDlg TITLE STR0285+cCadastro FROM aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL//Monitor Capa de Lote-

			@010,005 BUTTON	STR0286	SIZE 040, 010 PIXEL OF oDlg ACTION (If(!aCle[oListMonitor:nAt][04] $("12"),(SpedCleRemessa(,,,,,aCle[oListMonitor:nAt][02],lCleTMS),aCle:=MontaCLE(cIdEnt,aParam),RefreshMnt(@aCle,@oListMonitor,oDlg)),Alert(STR0323)))//&Transmitir
			@020,005 BUTTON	STR0287	SIZE 040, 010 PIXEL OF oDlg ACTION (VisualCLe(aCle[oListMonitor:nAt],lCleTMS))//&Visualizar
			If lCleTMS
				@030,005 BUTTON	STR0289	SIZE 040, 010 PIXEL OF oDlg ACTION (If(aCle[oListMonitor:nAt][04] $("3|4|5"),(ExcluiCLe(cIdEnt,aCle[oListMonitor:nAt][02]),aCle:=MontaCLE(cIdEnt,aParam),RefreshMnt(@aCle,@oListMonitor,oDlg)),Alert(STR0322)))//"&Excluir"
				@040,005 BUTTON	STR0290	SIZE 040, 010 PIXEL OF oDlg ACTION SpedDaCle()//"&Imprimir"
				@050,005 BUTTON	STR0291	SIZE 040, 010 PIXEL OF oDlg ACTION (aCle:=MontaCLE(cIdEnt,aParam),RefreshMnt(@aCle,@oListMonitor,oDlg))//"&Refresh"
				@060,005 BUTTON	STR0292	SIZE 040, 010 PIXEL OF oDlg ACTION SchemaCLe(cIdEnt,aCle[oListMonitor:nAt])//"S&chema"
				@070,005 BUTTON	STR0293	SIZE 040, 010 PIXEL OF oDlg ACTION 	BrwLegenda(STR0299,,aLegenda)//"&Legenda"
				@080,005 BUTTON	STR0294	SIZE 040, 010 PIXEL OF oDlg ACTION oDlg:End()//"&Sair"
				@090,050 LISTBOX oListMonitor 	FIELDS HEADER "",STR0249,STR0324,STR0295,STR0296,STR0297,STR0298,STR0231,STR0260,STR0232,STR0256,STR0233,STR0258,STR0325,STR0326  SIZE 580,400 PIXEL OF oDlg//Capa de Lote,Ambiente,Status,Descricao,Tipo Veiculo,Veículo,UF Veiculo,Carreta,UF Carreta,Carreta2,UF Carreta2,Emissao,Autorização
			Else
				@030,005 BUTTON	STR0288	SIZE 040, 010 PIXEL OF oDlg ACTION ModVeiculo(@oListMonitor,aCle)//"&Mod.Veiculo"
				@040,005 BUTTON	STR0289	SIZE 040, 010 PIXEL OF oDlg ACTION (If(aCle[oListMonitor:nAt][04] $("3|4|5"),(ExcluiCLe(cIdEnt,aCle[oListMonitor:nAt][02]),aCle:=MontaCLE(cIdEnt,aParam),RefreshMnt(@aCle,@oListMonitor,oDlg)),Alert(STR0322)))//"&Excluir"
				@050,005 BUTTON	STR0290	SIZE 040, 010 PIXEL OF oDlg ACTION SpedDaCle()//"&Imprimir"
				@060,005 BUTTON	STR0291	SIZE 040, 010 PIXEL OF oDlg ACTION (aCle:=MontaCLE(cIdEnt,aParam),RefreshMnt(@aCle,@oListMonitor,oDlg))//"&Refresh"
				@070,005 BUTTON	STR0292	SIZE 040, 010 PIXEL OF oDlg ACTION SchemaCLe(cIdEnt,aCle[oListMonitor:nAt])//"S&chema"
				@080,005 BUTTON	STR0293	SIZE 040, 010 PIXEL OF oDlg ACTION 	BrwLegenda(STR0299,,aLegenda)//"&Legenda"
				@090,005 BUTTON	STR0294	SIZE 040, 010 PIXEL OF oDlg ACTION oDlg:End()//"&Sair"
			EndIf
			@010,050 LISTBOX oListMonitor 	FIELDS HEADER "",STR0249,STR0324,STR0295,STR0296,STR0297,STR0298,STR0231,STR0260,STR0232,STR0256,STR0233,STR0258,STR0325,STR0326  SIZE 580,400 PIXEL OF oDlg//Capa de Lote,Ambiente,Status,Descricao,Tipo Veiculo,Veículo,UF Veiculo,Carreta,UF Carreta,Carreta2,UF Carreta2,Emissao,Autorização

	        oListMonitor:SetArray(aCle)
	        oListMonitor:bLine:={||	{aCle[oListMonitor:nAt][01],;
	        						Substr(aCle[oListMonitor:nAt][02],1,3),;
	        						Substr(aCle[oListMonitor:nAt][02],4,9),;
	        						aCle[oListMonitor:nAt][03],;
		       						aCle[oListMonitor:nAt][04],;
	        						aCle[oListMonitor:nAt][05],;
	        						aCle[oListMonitor:nAt][06],;
	        						aCle[oListMonitor:nAt][07],;
	        						aCle[oListMonitor:nAt][08],;
	        						aCle[oListMonitor:nAt][09],;
	        						aCle[oListMonitor:nAt][10],;
									aCle[oListMonitor:nAt][11],;
									aCle[oListMonitor:nAt][12],;
									aCle[oListMonitor:nAt][13],;
									aCle[oListMonitor:nAt][14],;
									aCle[oListMonitor:nAt][15]}}

		ACTIVATE MSDIALOG oDLg CENTERED
	EndIf
	RestArea(aArea)
Return nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontaCLE  ³ Autor ³RENATO NAGIB           ³ Data ³16.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³monta array para o monitoramento da capa de lote            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaCLE(cIdEnt,aParam,lOk)

	Local oWS
	Local oRetorno
	Local cStatus
	Local aCle:={}
	Local nX
	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cAviso:=""
	Local cErro:=""
	Local oAutorizada	:= LoadBitmap(GetResources(),"BR_VERDE")
	Local oRejeitada	:= LoadBitmap(GetResources(),"BR_CINZA")
	Local oTransmitida	:= LoadBitmap(GetResources(),"BR_AZUL")
	Local oAguarda		:= LoadBitmap(GetResources(),"BR_LARANJA")
	Local oErroSchema	:= LoadBitmap(GetResources(),"BR_PRETO")
	Local oStatus
	Local aTipos:={{'F',STR0300},{'D',STR0301},{'AE',STR0302},{'AQ',STR0303},{'O',STR0304}}//Ferroviario,Dutoviario,Aéreo,Aquaviario,Outro
	Private oXml

	If IsReady() .And. !Empty(cIdEnt)
		oWS:= WSWSCLE()	:New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/WSCLe.apw"
		oWS:cID_INI		:=aParam[1]+aParam[2]
		oWS:cID_FIN		:=aParam[1]+aParam[3]

		lOk := oWS:RETORNAFAIXA()
		If lOk
			oRetorno := oWS:oWSRETORNAFAIXARESULT

			For nX:=1 To Len(oRetorno:OWSCLEDADOS:OWSCLERET)
				oXml:=XmlParser(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:CXML_ERP,"_",@cAviso,cErro)
				cStatus:=Alltrim(Str(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:NSTATUS_TSS))
				If cStatus=="1"
					oStatus:=oTransmitido
				ElseIf cStatus == "2"
					oStatus:=oAutorizada
				ElseIf cStatus == "3"
					oStatus:=oErroSchema
				ElseIf cStatus == "4"
					oStatus:=oRejeitada
				ElseIf cStatus == "5"
					oStatus:=oAguarda
				EndIf
				aadd(aCle,Array(15))
				aCle[nX][1]:=oStatus
				aCle[nX][2]:=Substr(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:CID,1,12)
				aCle[nX][3]:=Ltrim(Str(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:NAMBIENTE))
				aCle[nX][4]:=Ltrim(Str(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:NSTATUS_TSS))
				Do Case
					Case aCle[nX][4] == "1"
						aCle[nX][5]:= Padr(STR0281,25)//Transmitida
					Case aCle[nX][4] == "2"
						aCle[nX][5]:= Padr(STR0279,25)//Autorizada
					Case aCle[nX][4] == "3"
						aCle[nX][5]:= Padr(STR0282,25)//Erro de Schema
					Case aCle[nX][4] == "4"
						aCle[nX][5]:= Substr(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:CDESCRICAO,1,Len(Alltrim(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:CDESCRICAO)))//Rejeitada
					Case aCle[nX][4] == "5"
						aCle[nX][5]:= Padr(STR0283,25)//Aguardandando transmissao
				EndCase
				If Type("oXml:_CLE:_MDTRANSP:_RODOVIARIO") <> "U"
					aCle[nX][06]:=STR0305
					aCle[nX][07]:=Alltrim(oXml:_CLE:_MDTRANSP:_RODOVIARIO:_PVEIC:TEXT)
					aCle[nX][08]:=Alltrim(oXml:_CLE:_MDTRANSP:_RODOVIARIO:_CUFVEIC:TEXT)
					If Type("oXml:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA") <> "U"
						aCle[nX][09]:=Alltrim(oXml:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA:TEXT)
						aCle[nX][10]:=Alltrim(oXml:_CLE:_MDTRANSP:_RODOVIARIO:_CUFCARRETA:TEXT)
        			Else
						aCle[nX][09]:=""
						aCle[nX][10]:=""
        			EndIF
					If Type("oXml:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA2") <> "U"
						aCle[nX][11]:=Alltrim(oXml:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA2:TEXT)
						aCle[nX][12]:=Alltrim(oXml:_CLE:_MDTRANSP:_RODOVIARIO:_CUFCARRETA2:TEXT)
        			Else
						aCle[nX][11]:=""
						aCle[nX][12]:=""
					EndiF
				ElseIf Type("oXml:_CLE:_MDTRANSP:_OUTRO") <> "U"
					nPos:=aScan(aTipos,{|X| X[1]==Alltrim(oXml:_CLE:_MDTRANSP:_OUTRO:_CMOD:TEXT)})
					aCle[nX][06]:=If(nPos>0,aTipos[aScan(aTipos,{|X| X[1]==Alltrim(oXml:_CLE:_MDTRANSP:_OUTRO:_CMOD:TEXT)}),2],"")
					aCle[nX][07]:=Alltrim(oXml:_CLE:_MDTRANSP:_OUTRO:_XIDENT:TEXT)
					aCle[nX][08]:=Alltrim(oXml:_CLE:_MDTRANSP:_OUTRO:_CUFTRANSPORTE:TEXT)
					aCle[nX][09]:=""
					aCle[nX][10]:=""
					aCle[nX][11]:=""
					aCle[nX][12]:=""
				EndIF
				aCle[nX][13]:=Alltrim(Str(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:NCHVCLE))
				aCle[nX][14]:=oRetorno:OWSCLEDADOS:OWSCLERET[nX]:DDATAERP
				aCle[nX][15]:=oRetorno:OWSCLEDADOS:OWSCLERET[nX]:DDATACLE
			Next
		EndIf
    EndIF
Return aCle
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ModVeiculo³ Autor ³RENATO NAGIB           ³ Data ³16.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³possibilita modificacao do veiculo para capas de lote       ³±±
±±³          ³rejeitadas ou com erro de Schema                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModVeiculo(oListMonitor,aCle)

	Local cAliasSF2 := GetNextAlias()
	Local oVeic
	Local oCar
	Local oCar2
	Local oDlg
	Local cVeic:=Space(8)
	Local cCar:=Space(8)
	Local cCar2:=Space(8)
	Local nOpca:=0
	Local cID:=aCle[oListMonitor:nAt][2]
	Local aArea:=SF2->(GetArea())

	If aCle[oListMonitor:nAt][4] $'3|4|5'

		DEFINE MSDIALOG oDlg TITLE STR0306 FROM 000,000 TO 200,345 PIXEL//"Redefinir Veículo"
			@025,015 SAY	STR0231	OF oDlg PIXEL//"Veículo"
			@025,040 MSGET	oVeic VAR cVeic F3 "DA3" VALID 	OF oDlg  	SIZE 050,008 PIXEL
			@040,015 SAY	STR0232	OF oDlg PIXEL
			@040,040 MSGET	oCar VAR cCar F3 "DA3"	SIZE 050,008 PIXEL OF oDlg
			@055,015 SAY	STR0233	OF oDlg PIXEL//Carreta
			@055,040 MSGET	oCar2 VAR cCar2 F3 "DA3"	 SIZE 050,008 PIXEL OF oDlg
			@010,010 GROUP oGrpVeic TO 080,160 PROMPT STR0306	OF oDlg PIXEL//"Redefinir Veículo"
			DEFINE SBUTTON FROM 085,010 TYPE 1 ENABLE OF oDlg ACTION (If((NAOVAZIO(cVeic) .AND. ExistCpo("DA3",cVeic,1)),(nOpca:=1,oDlg:End()),oVeic:SetFocus()))
			DEFINE SBUTTON FROM 085,040 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
		ACTIVATE MSDIALOG oDLg CENTERED

		If nOpca == 1
			BeginSql Alias cAliasSF2
				SELECT	R_E_C_N_O_
				FROM %Table:SF2% SF2
				WHERE SF2.F2_IDCLE = %Exp:cID% AND
				SF2.F2_FILIAL=%xFilial:SF2% AND
				SF2.%notdel%
			EndSql

			While (cAliasSF2)->(!Eof())
				SF2->(dbGoto((cAliasSF2)->R_E_C_N_O_))
				RecLock("SF2")
				SF2->F2_VEICUL1:=cVeic
				SF2->F2_VEICUL2:=cCar
				SF2->F2_VEICUL3:=cCar2
				MSUnLock()
				(cAliasSF2)->(dbSkip())
			End
			(cAliasSF2)->(dbCloseArea())
		EndIF
	Else
		Alert(STR0307)//"Capa de lote não pode ser modificada"
	EndIf
	RestArea(aArea)
Return nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedCLePar³ Autor ³RENATO NAGIB           ³ Data ³16.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³configuracao do ambiente e versao da capa de lote           ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedCLePar()

	Local oWs
	Local aPerg  := {}
	Local aParam := {"","","",0}
	Local aCombo1:= {}
	Local aCombo2:= {}
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local nTempo := 0
	Local cParCLePar := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPECLEPAR"
	Local nX
	Local cCombo1 := ""
	Local cCombo2 := ""
	Local lOk	:= .F.
	Local aParamAtu:=Array(Len(aPergCle))
	aadd(aCombo1,STR0031) //"1-Produção"
	aadd(aCombo1,STR0032) //"2-Homologação"
	aadd(aCombo2,"1.00") //"1-Normal"
	aadd(aCombo2,) //"2-Contingên

	If IsReady()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cIdEnt := GetIdEnt()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o ambiente                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oWS := WSWSCLE():New()
		oWS:cUSERTOKEN := "TOTVS"
		oWS:cID_ENT    := cIdEnt
		oWS:nNAMBIENTECLE  := 0
		oWS:cCVERSAOCLE:=""
		oWS:_URL       := AllTrim(cURL)+"/WSCLe.apw"
		lOk := oWS:CONFIGCLE()
		If lOk
			If Valtype(oWS:oWSCONFIGCLERESULT:CAMBIENTE) <> "U"
				cCombo1 :=oWS:oWSCONFIGCLERESULT:CAMBIENTE
			Else
				cCombo1 :="2-Homologacao"
			EndIf
			If ValType(oWS:oWSCONFIGCLERESULT:CVERSAO) <> "U"
				cCombo2	:=oWS:oWSCONFIGCLERESULT:CVERSAO
			Else
				cCombo2	:="1.00"
			EndIF
		EndIf
		aadd(aPerg,{2,STR0035,cCombo1,aCombo1,120,".T.",.T.,".T."}) //"Ambiente"
		aadd(aPerg,{2,STR0037,cCombo2,aCombo2,120,".T.",.T.,".T."}) //"Versao"

		For nX := 1 to Len(aPergCle)
			aParamAtu [nX] := &("MV_PAR"+StrZero(nX,2))
		Next nX

		If ParamBox(aPerg,"SPED - CLe",aParam,,,,,,,cParCLePar,.T.,.F.)
			oWS := WSWSCLE():New()
			oWS:cUSERTOKEN		:= "TOTVS"
			oWS:cID_ENT			:=cIdEnt
			oWS:nNAMBIENTECLE	:=Val(Substr(aParam[1],1,1))
			oWS:cCVERSAOCLE		:=aParam[2]
			oWS:_URL			:= AllTrim(cURL)+"/WSCLe.apw"
			lOk := oWS:CONFIGCLE()
			If lOk
				Aviso(STR0237,STR0308,{STR0114},3)//"Capa de lote","Configuração efetuada com sucesso"
			Else
				Aviso(STR0237,STR0309,{STR0114},3)//"Capa de lote","Houve um erro durante a configuracão da capa de lote"
			EndIf
			For nX := 1 to Len(aParamAtu)
				&("MV_PAR"+StrZero(nX,2)):=aParamAtu[nX]
			Next nX
		EndIF
	EndIF
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SpedCLeLeg³Autor  ³ Renato Nagib          ³ Data ³06.06.20117³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³legenda de Status para markbrowse com as NFes                ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedCLeLeg()

	Local aLegenda := {}

	Aadd(aLegenda, {"ENABLE"	,STR0311})//"NFe capeada"
	Aadd(aLegenda, {"BR_AZUL"	,STR0312}) //"NFe com Transporte definido"
	Aadd(aLegenda, {"DISABLE"	,STR0310})//"NFe não capeada"

	BrwLegenda(cCadastro,STR0117,aLegenda) //"Legenda"

Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IDCLE     ³Autor  ³ Renato Nagib          ³ Data ³06.06.20117³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Apresenta tela para escolha da serie e numero de documneto   ³±±
±±³          ³a ser utilizado.                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IDCLE()

	Local oDlg
	Local oBold
	Local oBmp
	Local oQual
	Local cVarQ
	Local aSerie:={}
	Local cIdCle

	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))
	If SX5->(dbSeek(xFilial()+'78'))
		While SX5->X5_TABELA =='78'
			aadd(aSerie,{Substr(SX5->X5_CHAVE,1,3),Substr(SX5->X5_DESCRI,1,9)})
			SX5->(dbSkip())
		End
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0313 FROM 000,0000 TO 264,378  PIXEL //"Capas de lote"
		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
		@  0, -25 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 55, 1000 NOBORDER WHEN .F. PIXEL
		@ 14, 30 TO 16 ,400 LABEL '' OF oDlg PIXEL
		@ 03, 40 SAY STR0237  FONT oBold PIXEL//"Capa de lote"
		@ 025,040 LISTBOX oQual VAR cVarQ;
		FIELDS HEADER STR0249,STR0237 SIZE 140,080  ON DBLCLICK lEditCell( aSerie, oQual, "@!", 2 ) NOSCROLL PIXEL//Serie,Capa de lote
		oQual:SetArray(aSerie)
		oQual:bLine := {|| {aSerie[oQual:nAT,1],aSerie[oQual:nAT,2]}}
		DEFINE SBUTTON FROM 113,119 TYPE 1 ENABLE ACTION (cIdCle:=aSerie[oQual:nAT][1]+aSerie[oQual:nAT][2],If(ValidaID(cIdCle),oDlg:End(),lEditCell( aSerie, oQual, "@!", 2 ))) OF oDlg PIXEL
		DEFINE SBUTTON FROM 113,150 TYPE 2 ENABLE ACTION (cIdCle:="",oDlg:End()) OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg  CENTERED

Return cIDCLe

Static Function ValidaID(cIdCle)

	Local lRet:=.T.
	Local aArea:=SF2->(GetArea())
	Local cAliasSF2 := GetNextAlias()

	BeginSql Alias cAliasSF2
		SELECT	COUNT(*) AS REGISTRO
		FROM %Table:SF2% SF2
		WHERE SF2.F2_IDCLE = %Exp:cIdCle% AND
		SF2.F2_FILIAL=%xFilial:SF2% AND
		SF2.%notdel%
	EndSql

	If (cAliasSF2)->REGISTRO > 0
		Alert(STR0327)//"Já existe Capa de Lote para o Número informado"
		lRet:=.F.
   	EndIf

	(cAliasSF2)->(dbCloseArea())

	RestArea(aArea)
Return lRet

Static Function AtualizaIDCLe(cIdCle)

	Local nTamNF
	Local lAlpha:=.F.
	Local cASC:="0123456789ABCDEFGHIJKLMNOPQRSTUVXYWZ"
	Local nIni:=""
	Local nX
	Default cIdCle:=""

	cChave:=Padr(Substr(cIdCle,1,3)	,TAMSX3("X5_CHAVE")[1])
	cIdCle:=Substr(cIdCle,4)

	For nX:=1 To Len(Alltrim(cIdCle))
		If !Substr(cIdCle,nX,1) $  "0123456789"
			lAlpha:=.T.
			Exit
		EndIf
	Next

	If !lAlpha
		cNovo:=STRZERO(Val(cIdCle)+1,Len(cIdCle))
	Else
		nTamNF:=Len(Alltrim(cIdCle))
		nPos:=AT(Substr(cIdCle,nTamNF,1),cASC)
		While (nPos==Len(cASC) .Or. nPos==0) .AND. nTamNF>0
			nIni+="0"
			nTamNF--
			nPos:=AT(Substr(cIdCle,nTamNF,1),cASC)
		End
		If Len(nIni) < Len(cIdCle)
			cNovo:=Substr(cIdCle,1,nTamNF-1)+Substr(cASC,nPos+1,1)+nIni
			cNovo:=PADL(cNovo,Len(cIdCle))
			cNovo:=STRTRAN(cNovo,"",'0')
		Else
			cNovo:=nIni
		EndIf
	EndIF

	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))
	If SX5->(dbSeek(xFilial()+'78'+cChave))
		RecLock("SX5")
		SX5->X5_DESCRI:=cNovo
		SX5->X5_DESCSPA:=cNovo
		SX5->X5_DESCENG:=cNovo
		SX5->(MsUnlock())
	EndIf
Return nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VisualCLe ³Autor  ³ Renato Nagib          ³ Data ³06.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualizacao da capa de lote                                 ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VisualCLe(aCle,lCleTMS)

	Local cAliasSF2:=GetNextAlias()
	Local aListCLE:={}
	Local oDlg
	Local cIdCle
	Local cPlVeic
	Local cUFVeic
	Local cPlCar
	Local cUFCar
	Local cPlCar2
	Local cUFCar2
	Local cUFOrigem
	Local cUFDestino
	Local oBold
	Local cAliasDTC:= ""
	Local cQuery   := ""

	Default lCleTMS:= .F.

	cIdCle		:=aCLe[2]
	cPlVeic		:=aCLe[7]
	cUFVeic		:=aCLe[8]
	cPlCar		:=aCLe[9]
	cUFCar		:=aCLe[10]
	cPlCar2		:=aCLe[11]
	cUFCar2		:=aCLe[12]
	dDataEmissao:=DtoC(aCLe[14])
	dDataAutori	:=DtoC(aCLe[15])

	BeginSql Alias cAliasSF2
		Column F2_EMISSAO As Date
		SELECT	F2_IDCLE,F2_VEICUL1,F2_VEICUL2,F2_VEICUL3,F2_EST,F2_DOC,F2_SERIE,F2_EMISSAO,F2_CHVNFE,F2_CHVCLE,R_E_C_N_O_,F2_FILIAL,F2_CLIENTE,F2_LOJA
		FROM %Table:SF2% SF2
		WHERE SF2.F2_IDCLE = %Exp:cIdCle% AND
		SF2.F2_FILIAL=%xFilial:SF2% AND
		SF2.%notdel%
		ORDER BY 1,2,3
	EndSql

	cUFOrigem:=SM0->M0_ESTENT
	cUFDestino:=(cAliasSF2)->F2_EST

	While (cAliasSF2)->(!Eof())
		If lCleTMS
			cAliasDTC := GetNextAlias()
			cQuery := "SELECT DT6_DOC, DT6_SERIE, DTC_NUMNFC, DTC_SERNFC, DTC_EMINFC, DTC_NFEID FROM "
			cQuery += RetSqlName('DT6')+" DT6 "
			cQuery += " INNER JOIN " + RetSqlName("DTC") + " DTC "
			cQuery += "      ON (DTC.DTC_FILIAL = '"+xFilial('DTC')+"'"
			cQuery += "      AND DTC.DTC_FILDOC = DT6.DT6_FILDOC "
			cQuery += "      AND DTC.DTC_DOC = DT6.DT6_DOC "
			cQuery += "      AND DTC.DTC_SERIE = DT6.DT6_SERIE "
			cQuery += "      AND DTC.D_E_L_E_T_ = ' ') "
			cQuery += "    WHERE DT6.DT6_FILIAL  = '" + xFilial('DT6') + "' "
			cQuery += "      AND DT6.DT6_FILDOC     = '" + (cAliasSF2)->F2_FILIAL + "' "
			cQuery += "      AND DT6.DT6_DOC     = '" + (cAliasSF2)->F2_DOC + "' "
			cQuery += "      AND DT6.DT6_SERIE   = '" + (cAliasSF2)->F2_SERIE + "' "
			cQuery += "      AND DT6.DT6_CLIDEV = '" + (cAliasSF2)->F2_CLIENTE + "' "
			cQuery += "      AND DT6.DT6_LOJDEV  = '" + (cAliasSF2)->F2_LOJA + "' "
			cQuery += "      AND DT6.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDTC,.T.,.T.)

			TcSetField(cAliasDTC,"DTC_EMINFC", "D", 8, 0)
			While (cAliasDTC)->(!Eof())
				aadd(aListCLE,{(cAliasDTC)->DTC_NUMNFC,(cAliasDTC)->DTC_SERNFC,(cAliasDTC)->DTC_EMINFC,(cAliasDTC)->DTC_NFEID,(cAliasSF2)->F2_CHVCLE})
				(cAliasDTC)->(DbSkip())
			EndDo
			(cAliasDTC)->(dbCloseArea())
		Else
			aadd(aListCLE,{(cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE,(cAliasSF2)->F2_EMISSAO,(cAliasSF2)->F2_CHVNFE,(cAliasSF2)->F2_CHVCLE})
		EndIf
		(cAliasSF2)->(dbSkip())
	End
    If Empty(aListCLE)
		Aviso(STR0237,STR0284,{STR0114},3)//"Capa de lote","Não há dados"
		Return Nil
    EndIf
	DEFINE MSDIALOG oDlg TITLE STR0285+cCadastro FROM  000,000 TO 490,700 PIXEL//Monitor Capa de Lote-
		DEFINE FONT oBold BOLD
		@015,010 SAY	STR0324	PIXEL OF oDlg FONT oBold//Numero
		@015,036 SAY	Substr(cIdCle,4)	PIXEL OF  oDlg
		@015,074 SAY	STR0249	PIXEL OF oDlg FONT oBold //Série
		@015,093 SAY	Substr(cIdCle,1,3)	PIXEL OF oDlg
		@015,110 SAY	STR0314	PIXEL OF oDlg FONT oBold//UF Origem
		@015,143 SAY	cUFOrigem			PIXEL OF oDlg
		@015,160 SAY	STR0226	PIXEL OF oDlg FONT oBold//"UF Destino: "
		@015,193 SAY	cUFDestino			PIXEL OF oDlg
		@015,207 SAY	STR0325	PIXEL OF oDlg FONT oBold  // "Emissão: "
		@015,237 SAY	dDataEmissao		PIXEL OF oDlg
		@015,270 SAY	STR0326 PIXEL OF oDlg FONT oBold  //"Autorização: "
		@015,309 SAY	dDataAutorização PIXEL OF oDlg
		If aCLe[6]==STR0305
			@200,020 SAY	STR0253	PIXEL OF oDlg FONT oBold//"Placa Veículo: "
			@200,061 SAY 	cPlVeic				PIXEL OF oDlg
			@210,020 SAY	STR0254	PIXEL OF oDlg FONT oBold//"UF Veiculo: "
			@210,053 SAY	cUFVeic				PIXEL OF oDlg
			@200,100 SAY	STR0255	PIXEL OF oDlg FONT oBold//"Placa Carreta: "
			@200,142 SAY	cPlCar				PIXEL OF oDlg
			@210,100 SAY	STR0256	PIXEL OF oDlg FONT oBold//"UF Carreta: "
			@210,133 SAY	cUFCar				PIXEL OF oDlg
			@200,180 SAY	STR0257	PIXEL OF oDlg FONT oBold//"Placa Carreta2: "
			@200,224 SAY	cPlCar2				PIXEL OF oDlg
			@210,180 SAY	STR0258		PIXEL OF oDlg FONT oBold//"UF Carreta2: "
			@210,217 SAY	cUFCar2				PIXEL OF oDlg
		Else
			@200,020 SAY	STR0259	PIXEL OF oDlg FONT oBold//"Ident Veículo:"
			@200,061 SAY 	cPlVeic				PIXEL OF oDlg
			@210,020 SAY	STR0260	PIXEL OF oDlg FONT oBold//"UF Veículo: "
			@210,053 SAY	cUFVeic				PIXEL OF oDlg
		EndIf
		@030,010 LISTBOX oListMonitor 	FIELDS HEADER STR0248,STR0249,STR0250,STR0251,STR0252 SIZE 330,150 PIXEL OF oDlg//Nota Fiscal,Série,Emissão,Chave NF,Chave CLe
		@190,010 GROUP	oGrpVeic TO 225,340 PROMPT STR0315  OF oDlg PIXEL//"Dados do Transporte"
		DEFINE SBUTTON FROM 230,310 TYPE 1 ENABLE ACTION (oDlg:End()) OF oDlg
        oListMonitor:SetArray(aListCLE)
        oListMonitor:bLine:={||	{aListCLE[oListMonitor:nAt][01],;
        						aListCLE[oListMonitor:nAt][02],;
        						aListCLE[oListMonitor:nAt][03],;
        						aListCLE[oListMonitor:nAt][04],;
        						aListCLE[oListMonitor:nAt][05]}}

	ACTIVATE MSDIALOG oDLg CENTERED
Return nil
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ExcluiCle ³Autor  ³ Renato Nagib          ³ Data ³06.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao do Schema da CLe                                   ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ExcluiCle(cIdEnt,cIdCle)

	Local oWS
	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oListMonitor
	Local cAliasSF2 := GetNextAlias()
	Local nX
	Local cMsg:=""
	Local aCle:={}
	Local nId

	If MsgYesNo(STR0316,STR0237)//Confirma Exclusão?,Capa de lote
		oWS := WSWSCLE():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:cID_INI		:=cIdCle
		oWS:cID_FIN		:=cIdCle
		oWS:_URL		:= AllTrim(cURL)+"/WSCLe.apw"
		lOk := oWS:DELETACLE()
		If lOk
			oRetorno:=oWS:oWSDELETACLERESULT:OWSCLES:OWSCLE
			 For nX:=1 To Len(oRetorno)
				aadd(aCle,oRetorno[nX]:CID+"-"+oRetorno[nX]:CMSG+CRLF)

			 	BeginSql Alias cAliasSF2
					SELECT	R_E_C_N_O_
					FROM %Table:SF2% SF2
					WHERE SF2.F2_IDCLE = %Exp:oRetorno[nX]:CID% AND
					SF2.F2_FILIAL=%xFilial:SF2% AND
					SF2.%notdel%
				EndSql
				While (cAliasSF2)->(!Eof())
					SF2->(dbGoTo((cAliasSF2)->R_E_C_N_O_))
					RecLock("SF2")
					SF2->F2_IDCLE:=""
					SF2->(MsUnlock())
					(cAliasSF2)->(dbSkip())
				End
				(cAliasSF2)->(dbCloseArea())
			Next

			If Empty(aCle)
				Aviso(STR0237,STR0284,{STR0114},3)//"Capa de lote","Não há dados"
				Return Nil
			EndIf

			DEFINE MSDIALOG oDlg TITLE STR0317 FROM 0,0 TO 240,500 PIXEL//"Exclusão de capa de lote"
				@ 10,10 LISTBOX oLbx VAR nId ITEMS aCle SIZE 230,95 OF oDlg PIXEL
				DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTER
		Else
			Aviso(STR0237,STR0318,{STR0114},3)//Houve um erro durante a Exclusão da capa de lote,Capa de lote"
		EndIf
    EndIf

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SchemaCLe ³Autor  ³ Renato Nagib          ³ Data ³06.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao do Schema da CLe                                   ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SchemaCLe(cIdEnt,aCle)

	Local cIdCLe:=aCLe[2]
	Local oWS
	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)

	If IsReady() .And. !Empty(cIdEnt)
		oWS:= WSWSCLE()	:New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/WSCLe.apw"
		oWS:cID_INI		:=cIdCLe
		oWS:cID_FIN		:=cIdCLe


		If oWS:RETORNAFAIXA()
			oRetorno := oWS:oWSRETORNAFAIXARESULT
			Aviso("SPED",oRetorno:OWSCLEDADOS:OWSCLERET[1]:CXML_ERP,{STR0114})
			oWS:= WSWSCLE():New()
			oWS:_URL		:= AllTrim(cURL)+"/WSCLe.apw"
			oWS:cUSERTOKEN	:= "TOTVS"
			oWS:cID_ENT		:= cIdEnt
			oWS:cCLE_ID		:= cIdCLe
			oWS:cCLE		:=Encode64(oRetorno:OWSCLEDADOS:OWSCLERET[1]:CXML_ERP)
			If oWS:SCHEMACLE()
				If oWS:cSCHEMACLERESULT == cIdCLe
					Aviso("SPED",STR0091,{STR0114})
				Else
					Aviso("SPED",oWS:cSCHEMACLERESULT,{STR0114},3)
				EndIf
			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
			EndIf
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIF
    EndIf
Return

Static Function RefreshMnt(aCle,oListMonitor,oDlg)


	Local cAliasSF2 := GetNextAlias()
	Local nX

      //Atualização da SF2 com a chave da capa de lote
	For nX:=1 To Len(aCle)
		BeginSql Alias cAliasSF2
			SELECT	R_E_C_N_O_
			FROM %Table:SF2% SF2
			WHERE SF2.F2_IDCLE = %Exp:aCle[nX][2]% AND
			SF2.F2_FILIAL=%xFilial:SF2% AND
			SF2.%notdel%
		EndSql

		While (cAliasSF2)->(!Eof())
			If !Empty(aCle[nX][13])
				SF2->(dbGoTo((cAliasSF2)->R_E_C_N_O_))
				RecLock('SF2')
				SF2->F2_CHVCLE:=aCle[nX][13]
				SF2->(MsUnlock())
				(cAliasSF2)->(dbSkip())
			EndIf
		End
		If Select(cAliasSF2) > 0
			(cAliasSF2)->(dbCloseArea())
    	EndIf
	Next

	oListMonitor:SetArray(aCle)
	oListMonitor:bLine:={||	{	aCle[oListMonitor:nAt][01],;
	       						Substr(aCle[oListMonitor:nAt][02],1,3),;
	       						Substr(aCle[oListMonitor:nAt][02],4,9),;
	       						aCle[oListMonitor:nAt][03],;
	       						aCle[oListMonitor:nAt][04],;
	       						aCle[oListMonitor:nAt][05],;
	       						aCle[oListMonitor:nAt][06],;
	       						aCle[oListMonitor:nAt][07],;
	       						aCle[oListMonitor:nAt][08],;
	       						aCle[oListMonitor:nAt][09],;
	       						aCle[oListMonitor:nAt][10],;
								aCle[oListMonitor:nAt][11],;
	       						aCle[oListMonitor:nAt][12],;
	       						aCle[oListMonitor:nAt][13],;
								aCle[oListMonitor:nAt][14],;
								aCle[oListMonitor:nAt][15]}}
								oListMonitor:nAt:=1
								If(Empty(aCle),oDlg:End(),"")
								oListMonitor:Refresh()
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³XmlCLeSef ³ Autor ³Renato Nagib           ³ Data ³28.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de geracao do xml para a capa de Lote                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function XmlCLeSef(aVeiculo,aDocs, lCleTms)

	local cString:=""
	local nChave	:=Len(aDocs)
	local cUFDestino:=aDocs[1][5]
	local nX
	local nNFes:=0
	local cTpTra:= ""
	Default lCleTms := .F.

	/*
	+-----------------+
	|Montagem do XML  |
	+-----------------+
	*/
	cString:='<CLe xmlns="http://www.portalfiscal.inf.br/nfe">'
	/*
	+----------------------+
	|Dados do transportador|
	+----------------------+
	*/
	cString+='  <transportador>'
	cString+='    <CNPJ>'+SM0->M0_CGC+'</CNPJ>'
	cString+='    <xNome>'+Alltrim(SM0->M0_NOME)+'</xNome>'
	cString+='    <xFant>'+Alltrim(SM0->M0_NOMECOM)+'</xFant>'
	cString+='  </transportador>'
	/*
	+----------------------+
	|Tipo de transporte    |
	+----------------------+
	*/

	cString+='<mdTransp>'

	dbSelectArea("DA3")
	DA3->(dbSetOrder(1))
	If DA3->(dbSeek(xFilial("DA3")+aVeiculo[1]))
		If getTpTransporte(DA3->DA3_TIPTRA) == "R" .Or. lCleTMS
			cString+='<rodoviario>'
			cString+='<pVeic>'+AllTrim(DA3->DA3_PLACA)+'</pVeic>'
			cString+='<cUFVeic>'+Alltrim(DA3->DA3_ESTPLA)+'</cUFVeic>'
			If DA3->(dbSeek(xFilial()+aVeiculo[2]))
				cString+='<pCarreta>'+AllTrim(DA3->DA3_PLACA)+'</pCarreta>'
				cString+='<cUFCarreta>'+Alltrim(DA3->DA3_ESTPLA)+'</cUFCarreta>'
			EndIf
			If DA3->(dbSeek(xFilial()+aVeiculo[3]))
				cString+='<pCarreta2>'+AllTrim(DA3->DA3_PLACA)+'</pCarreta2>'
				cString+='<cUFCarreta2>'+Alltrim(DA3->DA3_ESTPLA)+'</cUFCarreta2>'
			EndIf
			cString+='</rodoviario>'
		Else
			cString+='<outro>'
			cString+='<cMod>'+getTpTransporte(DA3->DA3_TIPTRA)+'</cMod>'
			cString+='<cUFTransporte>'+Alltrim(DA3->DA3_ESTPLA)+'</cUFTransporte>'
			cString+='<xIdent>'+Alltrim(DA3->DA3_DESC)+'</xIdent>'
			cString+='</outro>'
		EndiF
	EndIf
	cString+='</mdTransp>'

	/*
	+-----------------------+
	|UF de Origem da entrega|
	+-----------------------+
	*/
	cString+='<cUFOrigem>'+SM0->M0_ESTENT+'</cUFOrigem>'
	/*
	+------------------------+
	|UF de destino da entrega|
	+------------------------+
	*/
	cString+=  '<cUFDestino>'+cUFDestino+'</cUFDestino>'
	/*
	+------------------------+
	|Chaves da NFes          |
	+------------------------+
	*/
	cString+='<det>'
	For nX:=1 To nChave
		cString+='<chvAcesso>'+aDocs[nX,6]+'</chvAcesso>'
		nNFes++
	Next
	cString+='</det>'
	cString+='</CLe>'

Return {nNFes,EncodeUTF8(cString)}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedDaCle ³ Autor ³Renato Nagib           ³ Data ³28.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de chamada do WS de impressao da DANCLE              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SpedDaCle()

	Local cIdEnt := GetIdEnt()
	Local oDaCle
	Local nDevice
	Local cFilePrint := "DACLE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
	Local oSetup
	Local aDevice  := {}
	Local cSession     := GetPrinterSession()
	Local nRet := 0

	AADD(aDevice,"DISCO") // 1
	AADD(aDevice,"SPOOL") // 2
	AADD(aDevice,"EMAIL") // 3
	AADD(aDevice,"EXCEL") // 4
	AADD(aDevice,"HTML" ) // 5
	AADD(aDevice,"PDF"  ) // 6

	nLocal       	:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nOrientation 	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	cDevice     	:= fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
	nPrintType      := aScan(aDevice,{|x| x == cDevice })

	If IsReady()

		lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
		oDaCle := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)

		// ----------------------------------------------
		// Cria e exibe tela de Setup Customizavel
		// OBS: Utilizar include "FWPrintSetup.ch"
		// ----------------------------------------------
		//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
		nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
		If ( !oDaCle:lInJob )
			oSetup := FWPrintSetup():New(nFlags, "DaCle")
			// ----------------------------------------------
			// Define saida
			// ----------------------------------------------
			oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
			oSetup:SetPropert(PD_ORIENTATION , nOrientation)
			oSetup:SetPropert(PD_DESTINATION , nLocal)
			oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
			oSetup:SetPropert(PD_PAPERSIZE   , 2)

		EndIf

		// ----------------------------------------------
		// Pressionado botão OK na tela de Setup
		// ----------------------------------------------
		If oSetup:Activate() == PD_OK // PD_OK =1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Salva os Parametros no Profile             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	        fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
	        fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

	        // Configura o objeto de impressão com o que foi configurado na interface.
	        oDaCle:setCopies( val( oSetup:cQtdCopia ) )

			PrtCleSef(cIdEnt,oDaCle, oSetup, cFilePrint)
		Else
			MsgInfo("Relatório cancelado pelo usuário.")
			Return
		Endif

	EndIf
	oDaCle := Nil
	oSetup := Nil
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PrtCleSef ³ Autor ³ Renato Nagib          ³ Data ³29.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³      Impressão da DACLE no formato Retrato                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PrtCleSef(cIdEnt,oDaCle,oSetup,cFilePrint)

	Local aArea     := GetArea()
	Local lExistCle := .F.

	oDaCle:SetResolution(78) //Tamanho estipulado para a DaCle
	oDaCle:SetPortrait()
	oDaCle:SetPaperSize(DMPAPER_A4)
	oDaCle:SetMargin(60,60,60,60)
	oDaCle:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER

	// ----------------------------------------------
	// Define saida de impressão
	// ----------------------------------------------
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oDaCle:nDevice := IMP_SPOOL
		// ----------------------------------------------
		// Salva impressora selecionada
		// ----------------------------------------------
		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oDaCle:cPrinter := oSetup:aOptions[PD_VALUETYPE]
	ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oDaCle:nDevice := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------
		oDaCle:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
	Endif

	/*
	// ----------------------------------------------
	// Nova ordem obrigatória para abertura do relatório
	// ----------------------------------------------
	oDaCle:SetResolution(78) // 78dpi
	oDaCle:SetPortrait() // Retrato ou Paisagem
	oDaCle:SetPaperSize(DMPAPER_A4)
	oDaCle:SetMargin(70,70,70,70) // Em pixels: nEsquerda, nSuperior, nDireita, nInferior
	// ----------------------------------------------
	*/

	Private PixelX := oDaCle:nLogPixelX()
	Private PixelY := oDaCle:nLogPixelY()

	RptStatus({|lEnd| DaCleProc(@oDaCle,@lEnd,cIdEnt,@lExistCle)},"Imprimindo DaCle...")

	If lExistCle
		oDaCle:Preview()//Visualiza antes de imprimir
	Else
		Aviso("DaCle","Nenhuma CL-e a ser impressa nos parametros utilizados.",{"OK"},3)
	EndIf
	FreeObj(oDaCle)
	oDaCle := Nil
	RestArea(aArea)
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DaCleProc ³ Autor ³ Renato Nagib          ³ Data ³29.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da DaCle no formato Retrato³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DaCleProc(oDaCle,lEnd,cIdEnt,lExistCle)

	Local cAviso     := ""
	Local cErro      := ""
	Local nX         := 0
	Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
	Local aCle:={"",,}
	Local cNaoAut:=""
	Local aPerg:={}
	Local aParam:={Space(3),Space(09),Space(09)}
	Local cParDaCle	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"DACLE"

	aadd(aPerg,{1,STR0249,aParam[01],"",".T.","",".T.",10,.T.})//"S[erie"
	aadd(aPerg,{1,STR0277,aParam[02],"",".T.","",".T.",30,.F.})//"Capa de"
	aadd(aPerg,{1,STR0278,aParam[03],"",".T.","",".T.",30,.F.})//"Capa At[e"

    If ParamBox(aPerg,"SPED - CLe",@aParam,,,,,,,cParDaCle,.T.,.T.)

		oWS:= WSWSCLE()	:New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/WSCLe.apw"
		oWS:cID_INI		:=aParam[1]+aParam[2]
		oWS:cID_FIN		:=aParam[1]+aParam[3]

		lOk := oWS:RETORNAFAIXA()
		If lOk
			oRetorno := oWS:oWSRETORNAFAIXARESULT
			For nX:=1 To Len(oRetorno:OWSCLEDADOS:OWSCLERET)
				aCle[1]:=oRetorno:OWSCLEDADOS:OWSCLERET[nX]:NCHVCLE
				aCle[2]:=XmlParser(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:CXML_ERP,"_",@cAviso,cErro)
				aCle[3]:=oRetorno:OWSCLEDADOS:OWSCLERET[nX]:DDATACLE
				If Empty(cAviso) .And. Empty(cErro)
					If aCle[1] <> 0
						ImpCle(@oDaCle,aCle)
						lExistCle := .T.
					Else
						cNaoAut+=Alltrim(oRetorno:OWSCLEDADOS:OWSCLERET[nX]:cID)+CRLF
					EndIf
				EndIf
           	Next
		Else
			Aviso("DaCle","Houve um erro durante a impressao do DaCle.",{"OK"},3)
		EndIf
	EndIf
	If !Empty(cNaoAut)
		Aviso("SPED","As seguintes Capas de lote não foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
	EndIF
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±³          ³ExpC2: String com o XML da NFe                              ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCle(oDaCle,aCle)

	PRIVATE oFont10N   := TFontEx():New(oDaCle,"Times New Roman",08,08,.T.,.T.,.F.)// 1
	PRIVATE oFont07N   := TFontEx():New(oDaCle,"Times New Roman",06,06,.T.,.T.,.F.)// 2
	PRIVATE oFont07    := TFontEx():New(oDaCle,"Times New Roman",06,06,.F.,.T.,.F.)// 3
	PRIVATE oFont08    := TFontEx():New(oDaCle,"Times New Roman",07,07,.F.,.T.,.F.)// 4
	PRIVATE oFont08N   := TFontEx():New(oDaCle,"Times New Roman",06,06,.T.,.T.,.F.)// 5
	PRIVATE oFont09N   := TFontEx():New(oDaCle,"Times New Roman",08,08,.T.,.T.,.F.)// 6
	PRIVATE oFont09    := TFontEx():New(oDaCle,"Times New Roman",08,08,.F.,.T.,.F.)// 7
	PRIVATE oFont10    := TFontEx():New(oDaCle,"Times New Roman",09,09,.F.,.T.,.F.)// 8
	PRIVATE oFont11    := TFontEx():New(oDaCle,"Times New Roman",10,10,.F.,.T.,.F.)// 9
	PRIVATE oFont12    := TFontEx():New(oDaCle,"Times New Roman",11,11,.F.,.T.,.F.)// 10
	PRIVATE oFont11N   := TFontEx():New(oDaCle,"Times New Roman",10,10,.T.,.T.,.F.)// 11
	PRIVATE oFont18N   := TFontEx():New(oDaCle,"Times New Roman",17,17,.T.,.T.,.F.)// 12
	PRIVATE OFONT12N   := TFontEx():New(oDaCle,"Times New Roman",11,11,.T.,.T.,.F.)// 12

	PrtDaCle(@oDaCle,aCle)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtDaCle  ³ Autor ³Renato Nagib           ³ Data ³29.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do formulario DaCle grafico conforme laytout no   ³±±
±±³          ³formato retrato                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrtDaCle()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                          ³±±
±±³          ³ExpO2: Objeto da NFe                                        ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtDaCle(oDaCle,aCle)


	Local nX
	Local nChvNFe:=0
	Local nCont:=0
	Local lImprime:=.T.
	Private aDadosCle:=aCle
	Private aChvNfe:={}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao do objeto grafico                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oDaCle == Nil
		lPreview := .T.
		oDaCle 	:= FWMSPrinter():New("DaCle", IMP_SPOOL)
		oDaCle:SetPortrait()
		oDaCle:Setup()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao da pagina do objeto grafico                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDaCle:StartPage()
	nHPage := oDaCle:nHorzRes()
	nHPage *= (300/PixelX)
	nHPage -= HMARGEM
	nVPage := oDaCle:nVertRes()
	nVPage *= (300/PixelY)
	nVPage -= VBOX


	If Type("aDadosCle[2]:_CLE:_DET:_CHVACESSO") <> "A"
		aChvNfe:={aDadosCle[2]:_CLE:_DET:_CHVACESSO}
	Else
		aChvNfe:=aDadosCle[2]:_CLE:_DET:_CHVACESSO
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLogoD := GetSrvProfString("Startpath","") + "DACLE" + cEmpAnt + cFilAnt + ".BMP"
	If !File(cLogoD)
		cLogoD	:= GetSrvProfString("Startpath","") + "DACLE" + cEmpAnt + ".BMP"
		If !File(cLogoD)
			lImprime:= .F.
		EndIf
	EndIf

	oDaCle:Box(000,000,060,200,"-6")
	If lImprime
		oDaCle:SayBitmap( 005,050,cLogoD,080,050)
	EndIf

	//CABECALHO DA SEFAZ
	oDaCle:Box(000,200,060,400,"-6")
	oDaCle:Say(020,235,"SECERETARIA DE ESTADO DA",oFont12:oFont)
	oDaCle:Say(032,280,"FAZENDA",oFont12:oFont)
	oDaCle:Say(044,225,"CAPA DE LOTE ELETRÔNICA - CLe",oFont12:oFont)

	//CODIGO DE BARRAS
	oDaCle:Box(000,380,060,600,"-6")
	nFontSize := 28
	oDaCle:Code128C(047,385,Alltrim(STR(aDadosCle[1])), nFontSize )

	//DADOS DO TRANSPORTADOR
	cCGC:=TransForm(aDadosCle[2]:_CLE:_TRANSPORTADOR:_CNPJ:TEXT,If(Len(aDadosCle[2]:_CLE:_TRANSPORTADOR:_CNPJ:TEXT) <> 14,"@r 999.999.999-99","@r 99.999.999/9999-99"))
	cRazao:=aDadosCle[2]:_CLE:_TRANSPORTADOR:_XNOME:TEXT
	//CGC
	oDaCle:Box(061,000,090,150,"-6")
	oDaCle:Say(072,005,"CNPJ / CPF",oFont11:oFont)
	oDaCle:Say(085,010,cCGC,oFont11:oFont)
	//RAZAO SOCIAL
	oDaCle:Box(061,150,090,450,"-6")
	oDaCle:Say(072,155,"Razao Social / Nome",oFont12:oFont)
	oDaCle:Say(085,155,cRazao,oFont12:oFont)

	//CHAVE DA CAPA DE LOTE
	oDaCle:Box(061,450,090,600,"-6")
	oDaCle:Say(072,455,"Chave Capa de Lote",oFont12:oFont)
	oDaCle:Say(085,455,Alltrim(STR(aDadosCle[1])),oFont12:oFont)

	//DATA CADASTRO
	oDaCle:Box(091,000,120,150,"-6")
	oDaCle:Say(102,005,"Data Cadastro",oFont12:oFont)
	oDaCle:Say(115,005,DtoC(aDadosCle[3]),oFont12:oFont)

	//MODALIDADE TRANSPORTE
	oDaCle:Box(091,150,120,300,"-6")
	oDaCle:Say(102,155,"Modalidade Transporte",oFont12:oFont)
	oDaCle:Say(115,155,If(Type("aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO") <> "U","RODOVIARIO","OUTROS"),oFont12:oFont)

	//SITUACAO DA CAPA DE LOTE
	oDaCle:Box(091,300,120,450,"-6")
	oDaCle:Say(102,305,"Situacao da Capa de Lote",oFont12:oFont)
	oDaCle:Say(115,305,"EM ABERTO",oFont12:oFont)

	//QUANTIDADE DANFES
	nCle:=3
	oDaCle:Box(091,450,120,600,"-6")
	oDaCle:Say(102,455,"Quantidade DANFEs",oFont12:oFont)
	oDaCle:Say(115,455,Alltrim(Str(Len(aChvNfe))),oFont12:oFont)

	//DADOS DO VEICULO
	oDaCle:Box(121,000,150,150,"-6")
	oDaCle:Say(132,005,"Dados do Veiculo / UF",oFont12:oFont)
	If Type("aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO") <> "U"
		oDaCle:Say(145,005,aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_PVEIC:TEXT+" / ",oFont12:oFont)
		oDaCle:Say(145,050,aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_CUFVEIC:TEXT,oFont12:oFont)
	ElseIf Type("aDadosCle[2]:_CLE:_MDTRANSP:_OUTRO") <> "U"
		oDaCle:Say(145,005,aDadosCle[2]:_CLE:_MDTRANSP:_OUTRO:_XIDENT:TEXT+" / ",oFont12:oFont)
		oDaCle:Say(145,050,aDadosCle[2]:_CLE:_MDTRANSP:_OUTRO:_CUFTRANSPORTE:TEXT,oFont12:oFont)
	EndIF

	//PLACA DA CARRETA
	oDaCle:Box(121,150,150,300,"-6")
	oDaCle:Say(132,155,"Placa Carreta 1 / UF",oFont12:oFont)
	If Type("aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA") <> "U"
		oDaCle:Say(145,155,aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA:TEXT+" / ",oFont12:oFont)
		oDaCle:Say(145,205,aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_CUFCARRETA:TEXT,oFont12:oFont)
	EndIf

	//PLACA DA CARRETA 2
	oDaCle:Box(121,300,150,450,"-6")
	oDaCle:Say(132,305,"Placa Carreta 2 / UF",oFont12:oFont)
	If Type("aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA2") <> "U"
		oDaCle:Say(145,305,aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_PCARRETA2:TEXT+" / ",oFont12:oFont)
		oDaCle:Say(145,355,aDadosCle[2]:_CLE:_MDTRANSP:_RODOVIARIO:_CUFCARRETA2:TEXT,oFont12:oFont)
	EndIf

	//UF ORIGEM/DESTINO
	oDaCle:Box(121,450,150,600,"-6")
	oDaCle:Say(132,455,"UF Origem / UF Destino",oFont12:oFont)
	oDaCle:Say(145,455,aDadosCle[2]:_CLE:_CUFORIGEM:TEXT+" / "+aDadosCle[2]:_CLE:_CUFDESTINO:TEXT,oFont12:oFont)

	//CHAVES DAS DANFES
	oDaCle:Box(151,000,170,600,"-6")
	oDaCle:Say(164,200,"CHAVES DAS NOTAS FISCAIS ELETRÔNICAS",oFont11N:oFont)

	nLinha:=0
	nLinIni:=171
	nMaxPage:=70
	For nX:=1 To Len(aChvNfe)
		nChvNFe++
		nCont++
		If nCont > nMaxPage
			oDaCle:EndPage()
			oDaCle:StartPage()
			nCont:=1
			nLinha:=0
			nLinIni:=010
			nMaxPage:=86
		EndIF
		If nX % 2 <> 0
			If nCont == 1
				oDaCle:Box(nLinIni+nLinha,000,190+nLinha,300,"-6")
				oDaCle:Box(nLinIni+nLinha,300,190+nLinha,600,"-6")
			Else
				oDaCle:Box(nLinIni-1+nLinha,000,190+nLinha,300,"-6")
				oDaCle:Box(nLinIni-1+nLinha,300,190+nLinha,600,"-6")
			EndIf
			oDaCle:Say(nLinIni+10+nLinha,035,aChvNfe[nX]:TEXT,oFont12:oFont)	//aChvNfe[nX]:TEXT
		Else
			oDaCle:Say(nLinIni+10+nLinha,335,aChvNfe[nX]:TEXT,oFont12:oFont)
			nLinha+=20
		EndIf
	Next

	oDaCle:EndPage()

Return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewSchemaMsg
Função que monta tela com tratamento de erro de schema.

@author Henrique Brugugnoli
@since 25/07/2011
@version 1.0

@param	aMessages	Array com as mensagens
/*/
//-----------------------------------------------------------------------
Static Function ViewSchemaMsg( aMessages )

Local cTag			:= ""
Local cDesc			:= ""
Local cHierarquia   := ""
Local cDica			:= ""
Local cErro			:= ""

Local oTree

Local lIsSame	:= .F.

Local nX

DEFINE MSDIALOG oDlg TITLE STR0335 FROM 0,0 TO 300,500 PIXEL  //"Mensagens de Schema X Possibilidades"

@ 000, 000 MSPANEL oPanelLeft OF oDlg SIZE 085, 000
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ 000, 000 MSPANEL oPanelRight OF oDlg SIZE 000, 000
oPanelRight:Align := CONTROL_ALIGN_ALLCLIENT

oTree := xTree():New(000,000,000,000,oPanelLeft,,,)
oTree:Align := CONTROL_ALIGN_ALLCLIENT

oTree:AddTree(STR0336,,,"PARENT",,,) //"Mensagens"

For nX := 1 to len(aMessages)

	cCargo := aMessages[nX]:cTag

	oMessage := aMessages[nX]

	If ( oTree:TreeSeek(cCargo) )
		oTree:addTreeItem(STR0337,"BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) //"Possibilidade"
	Else
		If ( nX > 1 )
			oTree:EndTree()
		EndIf

		oTree:AddTree(cCargo,"f10_verm.png","f10_verm.png",cCargo,,,,,)
		oTree:addTreeItem(STR0337,"BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) 	//"Possibilidade"
	EndIf

Next nX

oTree:EndTree()

DEFINE FONT oFont BOLD

@ 005, 010 SAY oSay PROMPT STR0334 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Tag:"
@ 005, 024 SAY oTag PROMPT cTag OF oPanelRight PIXEL SIZE 040, 015

@ 020, 010 SAY oSay PROMPT STR0297+":" OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //Descrição:
@ 020, 042 SAY oDesc PROMPT cDesc OF oPanelRight PIXEL SIZE 110, 015

@ 035, 010 SAY oSay PROMPT STR0333 OF oPanelRight PIXEL FONT oFont SIZE 040, 015   //"Hierarquia:"
@ 035, 043 SAY oHierarquia PROMPT cHierarquia OF oPanelRight PIXEL SIZE 150, 015

@ 050, 010 SAY oSay PROMPT STR0332 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Dica:"
@ 050, 026 SAY oDica PROMPT cDica OF oPanelRight PIXEL SIZE 150, 015

@ 065, 010 SAY oSay PROMPT STR0331 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Erro Técnico:"
@ 065, 050 SAY oErro PROMPT cErro OF oPanelRight PIXEL SIZE 100, 055

@ 133, 097 BUTTON oBtn PROMPT STR0330 SIZE 030, 010 ACTION CreateLog( aMessages ) OF oPanelRight PIXEL //"Gerar Log"
@ 133, 130 BUTTON oBtn PROMPT STR0294 SIZE 028, 010 ACTION oDlg:end() OF oPanelRight PIXEL //"Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SchemaRefreshTree
Função que atualiza as informações da tela de schema.

@author Henrique Brugugnoli
@since 25/07/2011
@version 1.0

@param	@cTag		 Nome da tag
		@cDesc		 Descrição da tag
		@cHierarquia Pai da tag
		@cDica		 Dica do erro ocorrido
		@cErro		 Erro técnico
		aMessage	 Array com todas as tags e suas mensagens
		oTree		 Objeto com a árvore (XTree) de possibilidades

@return .T.
/*/
//-----------------------------------------------------------------------
Static Function SchemaRefreshTree( cTag, cDesc, cHierarquia, cDica, cErro, aMessage, oTree )

Local nPos	:= 0

nPos := Val(Substr(oTree:GetCargo(),At("|",oTree:GetCargo())+1))

cTag		:= aMessage[nPos]:cTag
cDesc		:= aMessage[nPos]:cDesc
cHierarquia	:= aMessage[nPos]:cParent
cDica		:= aMessage[nPos]:cLog
cErro		:= aMessage[nPos]:cErro

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} CreateLog
Função criará em disco um arquivo xml Log dos erros de schema.

@author Henrique Brugugnoli
@since 26/01/2011
@version 1.0

@param	aMessage	Array com todas as tags e suas mensagens

/*/
//-----------------------------------------------------------------------
Static Function CreateLog( aMessage )

Local cDir		:= cGetFile( "*.xml", STR0338+" XML", 1, "C:\", .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),, .T. )
Local cFile		:= "schemalog_"+DtoS(Date())+StrTran(Time(),":","")+".xml"

Local nHandle
Local nX

If ( !Empty(cDir) )

	nHandle := FCreate(cDir+cFile)

	If ( nHandle > 0 )

		FWrite(nHandle,"<schemalog>")

		For nX := 1 to len(aMessage)

			FWrite(nHandle,"<possibilidade item='"+AllTrim(Str(nX))+"'>")
			FWrite(nHandle,"<tag>")
			FWrite(nHandle,aMessage[nX]:cTag)
			FWrite(nHandle,"</tag>")
			FWrite(nHandle,"<descricao>")
			FWrite(nHandle,EncodeUTF8(aMessage[nX]:cDesc))
			FWrite(nHandle,"</descricao>")
			FWrite(nHandle,"<hierarquia>")
			FWrite(nHandle,aMessage[nX]:cParent)
			FWrite(nHandle,"</hierarquia>")
			FWrite(nHandle,"<dica>")
			FWrite(nHandle,EncodeUTF8(aMessage[nX]:cLog))
			FWrite(nHandle,"</dica>")
			FWrite(nHandle,"<erro>")
			FWrite(nHandle,aMessage[nX]:cErro)
			FWrite(nHandle,"</erro>")
			FWrite(nHandle,"</possibilidade>")

		Next nX

		FWrite(nHandle,"</schemalog>")
		FClose(nHandle)

		If ( MsgYesNo( STR0339 + cDir + cFile + CRLF + STR0340 ) ) //"Arquivo de LOG gerado com sucesso em: " # "Deseja abrir a pasta onde o arquivo foi gerado?"
			ShellExecute ( "OPEN", cDir, "", cDir, 1 )
		EndIf

	Else
		MsgInfo(STR0341) //"Não foi possível criar o arquivo."
	EndIf

Else
	MsgInfo(STR0342) //"Deve ser informado um diretório para ser salvo o arquivo de LOG."
EndIf

Return
//-----------------------------------------------------------------------
/*/{Protheus.doc} SPEDNFE
Função que limpa todas as tags de uma determinada string.

Exemplos Validados:
Ex.1: <id item="0000000001" ped="123456"/><div uM="UN"/><entg/><dest/><ctl/><ref/>
Ex.2: <versao>00</versao><transmissor/><receptor/><especieNF>55</especieNF><fabEntrega>3288</fabEntrega><prevEntrega>20160404</prevEntrega>
Ex.3: <id item="0000000001" ped="123456"/><versao>00</versao><transmissor/><receptor/><especieNF>55</especieNF><fabEntrega>3288</fabEntrega><prevEntrega>20160404</prevEntrega>
Ex.4: <id item="0000000001" ped="123456"/><div uM="UN"/><entg/><dest/><ctl/><ref/>Mensagem Nota Fiscal Eletronica C5_MENPAD
Ex.5: <versao>00</versao><transmissor codigo="111111              " nome="NOME TRANSM         "/><receptor codigo="COD RECEP           " nome="NOME RECEP          "/><especieNF>55</especieNF><fabEntrega>3288</fabEntrega><prevEntrega>20160407</prevEntrega><Invoice>000001              </Invoice>Mensagem para Nota Fiscal - C5_MENNOTA
Ex.6: <![CDATA[<id item="0000000001" ped="123456"/><div uM="UN"/><entg/><dest/><ctl/><ref/>]]>
Ex.7: <![CDATA[<versao>00</versao><transmissor/><receptor/><especieNF>55</especieNF><fabEntrega>3288</fabEntrega><prevEntrega>20160404</prevEntrega>]]>
Ex.8: <![CDATA[<id item="0000000001" ped="123456"/><versao>00</versao><transmissor/><receptor/><especieNF>55</especieNF><fabEntrega>3288</fabEntrega><prevEntrega>20160404</prevEntrega>]]>
Ex.9: <![CDATA[<versao>00</versao><transmissor codigo="COD TRANSM" nome="NOME TRANSM"/><receptor codigo="COD RECEP" nome="NOME RECEP"/><especieNF>55</especieNF><fabEntrega>3288</fabEntrega><prevEntrega>20160411</prevEntrega>]]>Mens.p/Nota
Ex.0: <![CDATA[<versao>00</versao><transmissor codigo="111111              " nome="NOME TRANSM         "/><receptor codigo="COD RECEP           " nome="NOME RECEP          "/><especieNF>55</especieNF><fabEntrega>3288</fabEntrega><prevEntrega>20160407</prevEntrega><Invoice>000001              </Invoice>]]>Mensagem para Nota Fiscal - C5_MENNOTA
@author Marcos Taranta
@since 02/08/2011
@version 1.0

@param	cString		String a ser limpa.
		lConteudo	Limpa o conteúdo dentro das variáveis também.

@return cRetorno	String somente texto, sem nenhuma tag.
/*/
//-----------------------------------------------------------------------
Function stripTags(cString, lConteudo)

	Local cNome     := ""
	Local cRetorno  := ""
	Local cRetorno	:= cString

	Local nAt		:= 0
	Local nAtFinal  := 0
	Local nX        := 0

	Local cTAG

	Local cConteudo
	Local nPosDATA
	Local nPosIni
	Local nPosFin
	PARAMTYPE 0 VAR cString		AS CHARACTER
	PARAMTYPE 1 VAR lConteudo	AS LOGICAL

	nPosDATA := at('<![CDATA[',cString)

	if(nPosDATA <> 0)
		nPosIni := at('<',subStr(cString,nPosDATA+1))+1
		nPosFin := rat("]]>",cString)
		cString := subStr(cString,nPosIni,nPosFin-nPosIni) + subStr(cString, nPosFin + len("]]>"))
	endIf
	nAt := at("<", cString)

	If nAt <> 0
		// Exclui a tag e seu conteúdo
		// Verifica se não é uma tag de fechamento solta pela string e se irá excluir o conteúdo da tag
		If !(subStr(cString, nAt + 1, 1) $ "/|<|>") .And. lConteudo == .T.
			nX := nAt + 1
			While subStr(cString, nX, 1) <> " " .And. subStr(cString, nX, 1) <> "" .And. subStr(cString, nX, 1) <> ">"
				cNome += subStr(cString, nX, 1)
				nX++
			EndDo

			nAtFinal := at("</" + cNome, cString)
			// Achou o fechamento da tag
			If nAtFinal <> 0
				nX := nAtFinal
				While subStr(cString, nX, 1) <> ">" .And. !Empty(subStr(cString, nX, 1))
					nX++
				EndDo
				nAtFinal := nX
			// Não achou a tag de fechamento, exclui apenas a tag de abertura solta
			Else
				nAtFinal := at(">", cString)
				If nAtFinal == 0
					nAtFinal := at("<", cString)
				Endif
			EndIf
		// Exclui somente a tag
		Else
			If !(subStr(cString, nAt + 1, 1) $ "/|<|>") .And. lConteudo == .F.
				nX := nAt + 1
				While subStr(cString, nX, 1) <> " " .And. subStr(cString, nX, 1) <> "" .And. subStr(cString, nX, 1) <> ">" .And. subStr(cString, nX, 1) <> "/"
					cNome += subStr(cString, nX, 1)
					nX++
				EndDo

				nAtFinal := at("</" + cNome, cString)
				If nAtFinal <> 0
					nX := nAtFinal
					While subStr(cString, nX, 1) <> ">" .And. !Empty(subStr(cString, nX, 1))
						nX++
					EndDo
					nAtFinal := nX
				Else
					nAtFinal := at(">", cString)
					If nAtFinal == 0
						nAtFinal := at("<", cString)
					Endif
				EndIf
			endIf

			cMsg	:= iif(type("cMsg")<>"U",cMsg,"")
			cTAG	:= subStr(cString, nat, len(">")+nAtFinal-(nat))

			if(at("</" + cNome, cTAG) > 0)
				nX := at(">", cTAG)
				nX++

				// busca os valores para o tipo de tag: <id></id>
				cMsg += cNome + "="
				cConteudo := ""
				While subStr(cTAG, nX, 1) <> "<"
					cConteudo += subStr(cTAG, nX, 1)
					nX++
				EndDo

				// Tratamento de data para previsao de entrega
				if(allTrim(upper(cNome)) == 'PREVENTREGA')
					cConteudo := subStr(cConteudo,7,2) + "/" +;
								subStr(cConteudo,5,2) + "/" +;
								subStr(cConteudo,1,4)
				endif

				cMsg += cConteudo + " "
			else
				// busca os valores para o tipo de tag: <id/>
				nX++
				While subStr(cTAG, nX, 1) <> "" .and. subStr(cTAG, nX, 1) <> "/" .and. subStr(cTAG, nX, 1) <> ">"
					cMsg += subStr(cTAG, nX, 1)
					nX++
				EndDo
				cMsg := cMsg + " "
			endIf
		EndIf

		cRetorno := subStr(cString, 0, nAt - 1) + subStr(cString, nAtFinal + 1)
	EndIf

	// Chamada recursiva para limpar mais ocorrências que sobrem de tags.
	If at("<", cRetorno) <> 0
		cRetorno := stripTags(cRetorno, lConteudo)
	EndIf

	if(!lConteudo)
		cRetorno := strTran(cMsg,'"','')
	endIf
Return cRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetInfoFunc
Funcao para verificar a existencia de uma função ou programa no rpo.

@author Renato Nagib
@since 19/08/2011
@version 1.0

@param		cNome		nome da Funcao ou programa a ser verificado
			cTipo		tipo da busca.'P' para busca de Programas(Fontes PRW/PRX) e 'F' para busca de funcoes.

@return		aRetorno	Array com as informaçoes da função ou programa
			aRetorno[1]- retorno logico indicado a existencia da funcao ou parametro
			aRetorno[2]-Tipo da funcao(quando utilizado passada como parametro)
			aRetorno[3]-Data do fonte compilado com a função
			aRetorno[4]-Hora da compilação
			aRetorno[5]-nome da Funcao
/*/
//-----------------------------------------------------------------------
Function GetInfoFunc(cNome,cTipo)

	Local aRet
	local aRetorno:=Array(5)
	Local nCount
	Local aType
	Local aFile
	Local aLine
	Local aDate
	Local aTime

	aRet := GetFuncArray('*', aType, aFile, aLine, aDate,aTime)

	If UPPER(cTipo) == 'P'
		nPos:=aScan(aFile,{|X| UPPER(X) == UPPER(Alltrim(cNome))})
		If nPos > 0
			aRetorno[1]:=.T.
			aRetorno[2]:=""
			aRetorno[3]:=aDate[nPos]
			aRetorno[4]:=aTime[nPos]
			aRetorno[5]:=""
		Else
			aRetorno[1]:=.F.
			aRetorno[2]:=""
			aRetorno[3]:=""
			aRetorno[4]:=""
			aRetorno[5]:=""
		EndIf
	ElseIf UPPER(cTipo) == 'F'
		nPos:=aScan(aRet,{|X| UPPER(X) == UPPER(Alltrim(cNome))})
		If nPos > 0
			aRetorno[1]:=.T.
			aRetorno[2]:=aType[nPos]
			aRetorno[3]:=aDate[nPos]
			aRetorno[4]:=aTime[nPos]
			aRetorno[5]:=aRet[nPos]
		Else
			aRetorno[1]:=.F.
			aRetorno[2]:=""
			aRetorno[3]:=""
			aRetorno[4]:=""
			aRetorno[5]:=""
		EndIf
	EndIf
RETURN aRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedCCeRemessa
Função de remessa da Carta de Correcao Eletronica

@author Sergio S. Fuzinaka
@since 04.08.2011
@version 1.00

@param	Null
/*/
//-----------------------------------------------------------------------
Function SpedCCeRemessa(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
local aCfgCCe		:= {}
Local cNfeDoc		:= IIf ((cAlias == "SF2"),Alltrim((cAlias)->F2_DOC) + " / " + SubStr((cAlias)->F2_SERIE,1,3), Alltrim((cAlias)->F1_DOC) + " / " + SubStr((cAlias)->F1_SERIE,1,3))
Local nLimite		:= IIf ((cAlias == "SF2"),Val(Right(RTrim((cAlias)->F2_IDCCE),2)),Val(Right(RTrim((cAlias)->F1_IDCCE),2)))		//Limite do numero de eventos
Local aNfe			:= {}
Local cAmbiente		:= ""
Local cVerLayout	:= "1.00"
Local cVerLayEven	:= "1.00"
Local cVerEven		:= "1.00"
Local cVerCCe		:= "1.00"
Local cHoraVeraoCCe	:= "2"	// Horario de verao: 1-Sim ### 2-Nao
Local cHorarioCCe	:= "2"	// Horario: 1-Fernando de Noronha ### 2-Brasilia ### 3-Manaus
Local aTexto		:= {}
Local lOk			:= .T.
Local cIdEnt		:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
local cError		:=  ""
Local nX			:= 0
Local cTexto		:= ""//Space(1000)
Local cRetorno    	:= ""
Local oWs
Local oWizard
Local lUsaColab := UsaColaboracao("1")

// Verifica se a entidade foi configurada e o limite por eventos
If IsReady(,,,lUsaColab) .And. nLimite < 20

	// Dados da Nfe
	If cAlias == "SF2"
		aNfe := {	(cAlias)->F2_CHVNFE		,; //01 - Chave da Nfe
					(cAlias)->(Recno())		,; //02 - Recno
					(cAlias)->F2_SERIE		,; //03 - Serie
					(cAlias)->F2_DOC}		      //04 - Numero
	Else
		aNfe := {	(cAlias)->F1_CHVNFE		,;	//01-Chave da Nfe
					(cAlias)->(Recno())		,; //02 - Recno
					(cAlias)->F1_SERIE		,; //03 - Serie
					(cAlias)->F1_DOC}		      //04 - Numero
	EndIf

	DEFINE FONT oBold BOLD

	// Obtem o codigo da entidade
	cIdEnt := GetIdEnt(lUsaColab)

	If !Empty(cIdEnt)

		if lUsaColab
			cAmbiente		:= ColGetPar("MV_AMBIENT","")
			cVerLayout		:= ColGetPar("MV_CCEVLAY","1.00")
			cVerLayEven	:= ColGetPar("MV_EVENTOV","1.00")
			cVerEven		:= ColGetPar("MV_LAYOUTV","1.00")
			cVerCCe 		:= ColGetPar("MV_CCEVER","1.00")
			cHoraVeraoCCe := ColGetPar("MV_HRVERAO","")
			cHorarioCCe 	:= 	ColGetPar("MV_HORARIO","")

			lOk				:= .t.
		else
			// Obtem o ambiente da carta de correcao
			oWS:=WsSpedCfgNfe():New()
			oWS:cUSERTOKEN 	  	:= "TOTVS"
			oWS:cID_ENT    		:= cIdEnt
			oWS:nAMBIENTECCE	:= 0
			oWS:cVERCCELAYOUT	:= "1.00"
			oWS:cVERCCELAYEVEN	:= "1.00"
			oWS:cVERCCEEVEN		:= "1.00"
			oWS:cVERCCE			:= "1.00"
			oWS:cHORAVERAOCCE	:= "2"
			oWS:cHORARIOCCE		:= "2"
			oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"

			aCfgCCe := getCfgCCe(@cError, cIdEnt)
			lOk:= empty(cError)

		endif
		If lOk
			if !lUsaColab
				// Ambiente
				If Valtype(aCfgCCe[1]) <> "U"
					cAmbiente := aCfgCCe[1]
				Else
					cAmbiente := STR0349	//"2-Homologacao"
				EndIf
				// Versao do leiaute
				If ValType(aCfgCCe[8]) <> "U"
					cVerLayout := aCfgCCe[8]
				Else
					cVerLayout := "1.00"
				EndIF
				// Versao do leiaute do evento
				If ValType(aCfgCCe[7]) <> "U"
					cVerLayEven := aCfgCCe[7]
				Else
					cVerLayEven := "1.00"
				EndIF
				// Versao do evento
				If ValType(aCfgCCe[6]) <> "U"
					cVerEven := aCfgCCe[6]
				Else
					cVerEven := "1.00"
				EndIF
				// Versao da carta de correcao
				If ValType(aCfgCCe[5]) <> "U"
					cVerCCe := aCfgCCe[5]
				Else
					cVerCCe := "1.00"
				EndIF
				// Horario de verao
				If ValType(aCfgCCe[3]) <> "U"
					cHoraVeraoCCe := aCfgCCe[3]
				Else
					cHoraVeraoCCe := "2"
				EndIF
				// Horario
				If ValType(aCfgCCe[2]) <> "U"
					cHorarioCCe := aCfgCCe[2]
				Else
					cHorarioCCe := "2"
				EndIF
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da Interface                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aTexto,{})
			aTexto[1] := STR0357+" " 						//"Esta rotina tem como objetivo auxilia-lo na transmissão da Carta de Correção Eletrônica para o serviço Totvs Services SPED."
			aTexto[1] += STR0358+CRLF+CRLF 					//"O registro de uma nova Carta de Correção substitui a anterior, sendo assim a nova Carta de Correção deverá conter todas as correções a serem consideradas. "
			aTexto[1] += STR0374+CRLF+CRLF 					//"Totvs Services SPED está operando com a seguinte configuração: "
			aTexto[1] += STR0015+cAmbiente+CRLF 			//"Ambiente: "
			aTexto[1] += STR0350+": "+cVerLayout+CRLF		//"Versao do layout"
			aTexto[1] += STR0351+": "+cVerLayEven+CRLF		//"Versao do layout do evento"
			aTexto[1] += STR0352+": "+cVerEven+CRLF			//"Versao do evento"
			aTexto[1] += STR0361+": "+cVerCCe+CRLF	 		//"Versao da carta de correcao"
			aTexto[1] += STR0369+": "+cHoraVeraoCCe+CRLF	//"Horario de verao"
			aTexto[1] += STR0370+": "+cHorarioCCe+CRLF		//"Horario"
			aadd(aTexto,{})

			DEFINE WIZARD oWizard ;
				TITLE STR0355;		//"Assistente de transmissão da Carta de Correcao Eletronica"
				HEADER STR0019;		//"Atencao"
				MESSAGE STR0356;	//"Siga atentamente os passos para a configuracao da Carta de Correcao Eletronica."
				TEXT aTexto[1] ;
				NEXT {|| .T.} ;
				FINISH {||.T.}

			CREATE PANEL oWizard  ;
				HEADER STR0355 ;	//"Assistente de transmissão da Carta de Correcao Eletronica"
				MESSAGE ""	;
				BACK {|| .T.} ;
				NEXT {|| IIf(SpedCCeTexto(@cTexto,1000,.T.),(Processa({|lEnd| cRetorno := SpedCCeTrf(aNfe,cTexto,cAlias)}),.T.),.F.)} ;
				PANEL

			// Nota Fiscal/Serie
			@ 003,005 SAY STR0248+" / "+STR0249 FONT oBold OF oWizard:oMPanel[2] PIXEL
			@ 003,070 SAY cNfeDoc OF oWizard:oMPanel[2] PIXEL

			@ 015,005 SAY STR0368 SIZE 250,10 PIXEL  FONT oBold OF oWizard:oMPanel[2]	//"Descreva a correção a ser considerada (sem acentuação)"
			@ 025,005 GET cTexto MEMO SIZE 275,100 PIXEL OF oWizard:oMPanel[2]

			CREATE PANEL oWizard  ;
				HEADER STR0355;		//"Assistente de transmissão da Carta de Correcao Eletronica"
				MESSAGE "";
				BACK {|| .T.} ;
				FINISH {|| .T.} ;
				PANEL

			@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]

			ACTIVATE WIZARD oWizard CENTERED
		EndIf

	EndIf

Else

	If nLimite >= 20

		Aviso("SPED",STR0372,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

	Else

		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

	Endif

EndIf

Return

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpedCCeTrf
Função que transmite a carta de correcao eletronica

@author Sergio S. Fuzinaka
@since 04.08.2011
@version 1.00

@param	Null

/*/
//--------------------------------------------------------------------------------------------
Static Function SpedCCeTrf(aNfe,cTexto,cAlias)

Local cXml      := ""
Local cIdEven	:= ""
Local cRetorno  := ""
Local lRetorno	:= .F.
Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local dDataIni	:= Date()
Local cHoraIni	:= Time()
Local cErro		:= ""
Local cIdEnt	:= ""
Local nEnvio	:= 0
Local nRegSF2	:= aNfe[2]
Local lUsaColab := UsaColaboracao("1")

// Verifica se a entidade foi configurada e o limite por eventos
If IsReady(,,,lUsaColab)

	// Obtem o codigo da entidade
	cIdEnt := GetIdEnt(lUsaColab)

	// Monta o Xml
	cXml := SpedCCeXml(aNfe,cTexto)

	if lUsaColab
		if ColEnvEvento("CCE",aNfe,cXml,@cIdEven,@cErro)
			SpedAtuEvento(1,nRegSF2,cIdEven,cAlias)
			nEnvio++
			lRetorno:= .T.
		endif
	else
		// Chamado do metodo e envio
		oWs:= WsNFeSBra():New()
		oWs:cUserToken	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWs:cXML_LOTE	:= cXml
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

		If oWs:NfeRemessaEvento()
			If Type("oWS:oWsNfeRemessaEventoResult:cString[1]") <> "U"
				cIdEven := oWS:oWsNfeRemessaEventoResult:cString[1]
				If !Empty(cIdEven)
					SpedAtuEvento(1,nRegSF2,cIdEven,cAlias)
					nEnvio++
					lRetorno:= .T.
				Endif
			Endif
		Else
			lRetorno:= .F.
			cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Endif
	endif

	If lRetorno
		cRetorno := IIF(lUsaColab,STR0491,STR0026)+CRLF //"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."#"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
		cRetorno += STR0359+CRLF+CRLF //"Verifique se o evento foi vinculado a NF-e na SEFAZ, utilizando a rotina 'Monitor'."
		cRetorno += Left(STR0360,16)+cValToChar(nEnvio)+Substr(STR0360,16)+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foi transmitido 0/1 evento em "
	Else
		cRetorno := iif(lUsaColab,STR0490,STR0030)+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."#"Houve erro durante a transmissão para o Totvs Services SPED."
		cRetorno += cErro
	EndIf

Else

	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

Endif

Return(cRetorno)

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpedCCeXml
Função que monta o Xml da Carta de Correcao para envio

@author Sergio S. Fuzinaka
@since 05.08.2011
@version 1.00

@param	Null

/*/
//--------------------------------------------------------------------------------------------
Function SpedCCeXml(aNfe,cTextCCe,cTpEvento,cProt,cTipo,cChave,cMunicipio,lCte)

Local cXml			:= ""
Local aUf			:= {}
local aCfgCCe		:= {}
Local cCnpj		:= SM0->M0_CGC
Local cData		:= Dtos(Date())
Local cHora		:= Time()
Local cDhEvento	:= ""
Local cCodOrgao	:= ""
Local cAmbiente	:= "2"
Local cVerLayout	:= "1.00"
Local cVerLayEven	:= "1.00"
Local cVerEven		:= "1.00"
Local cVerCCe 		:= "1.00"
Local cHrVerao		:= "2"
Local cHorario		:= "2"
Local cIdEnt		:= ""
Local cURL 		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cUTC			:= "03:00"	//Brasilia
local cError	:= ""
Local nPosUf		:= 0
Local cSeqEven		:= "01"
Local nLote		:= 1
Local cIdEvento	:= ""
Local cUF			:= Upper(Left(LTrim(SM0->M0_ESTENT),2))
Local cDescEvento := ""
Local cChvNfe		:= ""
Local lMDfe			:= .F.
Local lHVerao   	:=.F.			        	                  // Horario de Verão    .F. sem horario de verão/ .T. com horario de verão
Local lErpHverao	:= GetNewPar("MV_HVERAO",.F.)   		  // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local lUsaColab		:= .F.

Local aData		:={}         				    			  //Array da função FwTimeUF

Default cTpEvento	:= "110110"	//CCe
Default cProt			:= ""
Default cTipo 		:= ""
Default cChave		:= ""
Default cMunicipio	:= ""
Default lCte		:= .F.

If (Empty(cTipo) .Or. lCte) .And. Len(aNfe) > 0
	cChvNfe := aNfe[1]
ElseIf cTipo=="MDF"
	cChvNfe := cChave
	lMDfe := .T.
EndIf
if cTpEvento $ "210200-210210-210220-210240"
	lUsaColab := UsaColaboracao("4") //MDF-e eventos
Else
lUsaColab := UsaColaboracao( IIF(lCte,"2",IIF(lMDFe,"5","1")) )
EndIf

If cTpEvento == "110110"
	cDescEvento := "Carta de Correcao"
ElseIf cTpEvento == "110111"
	cDescEvento := "Cancelamento"			//Cancelamento NFe / MDFe
ElseIf cTpEvento == "110112"
	cDescEvento := "Encerramento"			//MDF-e Encerramento
ElseIf cTpEvento == "210200"
	cDescEvento := "Confirmacao da Operacao"
ElseIf cTpEvento == "210210"
	cDescEvento := "Ciencia da Operacao"
ElseIf cTpEvento == "210220"
	cDescEvento := "Desconhecimento da Operacao"
ElseIf cTpEvento == "210240"
	cDescEvento := "Operacao nao Realizada"
ElseIf cTpEvento == "110114"
	cDescEvento := "Inclusao Condutor"
EndIf

// Verifica se a entidade foi configurada e o limite por eventos
If IsReady(,,,lUsaColab)

	// Obtem o codigo da entidade
	cIdEnt := GetIdEnt(lUsaColab)

	if lUsaColab
		If cTipo == "MDF"
			cAmbiente		:= ColGetPar("MV_AMBMDF","2")
			cVerLayout		:= ColGetPar("MV_VLAYMDF","3.00")
			cVerLayEven	:= ColGetPar("MV_EVENMDF","3.00")
			cVersaoMdf		:= ColGetPar("MV_VERMDF","3.00")
		ElseIf lCte
			cAmbiente		:= ColGetPar("MV_AMBICTE","")
			cVerLayout		:= ColGetPar("MV_VLAYCTE","2.00")
			cVerLayEven	:= ColGetPar("MV_EVENCTE","2.00")
			cVerEven		:= ColGetPar("MV_LAYOCTE","2.00")
			cVerCCe 		:= ColGetPar("MV_VERSCTE","2.00")
		Else
			cAmbiente		:= ColGetPar("MV_AMBIENT","")
			cVerLayout		:= ColGetPar("MV_CCEVLAY","1.00")
			cVerLayEven	:= ColGetPar("MV_EVENTOV","1.00")
			cVerEven		:= ColGetPar("MV_LAYOUTV","1.00")
			cVerCCe 		:= ColGetPar("MV_CCEVER","1.00")
		EndIf
		cHrVerao		:= ColGetPar("MV_HRVERAO","2")
		cHorario	 	:= ColGetPar("MV_HORARIO","2")

		If cTpEvento == "110110"
			cSeqEven 	:= ColSeqCCe(aNfe)
		ElseIF cTpEvento == "110114"
			cSeqEven := ColSeqIncC(aNfe)	//Inclusao de condutor
		Else
			cSeqEven	:= "01"
		EndIf

		lOk				:= .T.
	else
		// Obtem o ambiente de configuracao
		oWS:=WsSpedCfgNfe():New()
		oWS:cUSERTOKEN 	  	:= "TOTVS"
		oWS:cID_ENT    		:= cIdEnt
		oWS:nAMBIENTECCE	:= 0	// Atribuicao de '0', efetua a consulta do metodo
		oWS:cVERCCELAYOUT	:= ""
		oWS:cVERCCELAYEVEN	:= ""
		oWS:cVERCCEEVEN		:= ""
		oWS:cVERCCE			:= ""
		oWS:cHORAVERAOCCE	:= ""
		oWS:cHORARIOCCE		:= ""
		oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"


		aCfgCCe := getCfgCCe(@cError, cIdEnt )

		lOk:= empty(cError)
		If lOk
			cAmbiente	:= Left(aCfgCCe[1],1)
			cVerLayout	:= aCfgCCe[8]
			cVerLayEven	:= aCfgCCe[7]
			cVerEven	:= aCfgCCe[6]
			cVerCCe		:= aCfgCCe[5]
			cHrVerao 	:= Left(aCfgCCe[3],1)
			cHorario 	:= Left(aCfgCCe[2],1)

			Default cAmbiente	:= "2"
			Default cVerLayout	:= "1.00"
			Default cVerLayEven	:= "1.00"
			Default cVerEven	:= "1.00"
			Default cVerCCe 	:= "1.00"
			Default cHrVerao	:= "2"
			Default cHorario	:= "2"
		Endif

		// Obtem o numero sequencial do evento
		If lOk
			oWS:= WSNFeSBRA():New()
			oWS:cUSERTOKEN	:= "TOTVS"
			oWS:cID_ENT		:= cIdEnt
			oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
			oWS:cCHVNFE		:= cChvNfe
			oWS:cTpEvento		:= cTpEvento

			lOk:=oWS:NFERETORNASEQEVENTO()

			If lOk
				cSeqEven := StrZero(oWs:nNfeRetornaSeqEventoResult,2)
			Endif
		Endif
	endif

	If lOk

		// Montagem do ID do evento
		cIdEvento := "ID"+cTpEvento+cChvNfe+cSeqEven

		// Tratamento da numeracao do lote
		nLote := ( GetNewPar("MV_LOTEVEN",0) + 1 )
		If !PutMv("MV_LOTEVEN",nLote)
			SX6->(RecLock("SX6",.T.))
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := "MV_LOTEVEN"
			SX6->X6_TIPO    := "N"
			SX6->X6_DESCRIC := "Lote do Evento"
			SX6->(MsUnLock())
			PutMv("MV_LOTEVEN",nLote)
		EndIf

		// Tabela do IBGE
		aUf := SpedTabIBGE()

		// Codigo do Orgao
		nPosUf := aScan(aUf,{|x| Upper(x[1]) == cUF})
		If nPosUf > 0
			cCodOrgao := aUf[nPosUf][4]
		Endif

		// Data e Hora do Evento - Formato: 2011-07-27T14:17:00-03:00 (UTC)
		If FindFunction("FwTimeUF")

			If cHrVerao == "1"			//1-Sim ### 2-Nao
				lHVerao   :=.T.
			else
		   		lHVerao   :=.F.
			EndIF

			If cHorario == "1"		//Fernando de Noronha
				cUF  := "FERNANDO DE NORONHA"
			Endif

			If !lErpHverao
			   lErpHverao := lHVerao
			Endif

			aData := FwTimeUF(cUF,,lErpHVerao)

			cdata		:= aData[1]
			cData		:= Dtos(Date())
			cData		:= Substr(cData,1,4)+"-"+Substr(cData,5,2)+"-"+Substr(cData,7,2)

			cHora		:= aData[2]
		Else
			cData		:= Substr(cData,1,4)+"-"+Substr(cData,5,2)+"-"+Substr(cData,7,2)

			cHora		:= Time()
		EndIf
		If cHrVerao == "1"			//1-Sim ### 2-Nao
			If cHorario == "1"		//Fernando de Noronha
				cUtc := "01:00"
			ElseIf cHorario == "2"	//Brasilia
				cUtc := "02:00"
			ElseIf	cHorario == "4"	//Acre
				cUtc := "04:00"
			Else
				cUtc := "03:00"		//Manaus
			Endif
		Else
			If cHorario == "1"		//Fernando de Noronha
				cUtc := "02:00"
			ElseIf cHorario == "2"	//Brasilia
				cUtc := "03:00"
			ElseIf	cHorario == "4"	//Acre
				cUtc := "05:00"
			Else
				cUtc := "04:00"		//Manaus
			Endif
		Endif

		cDHEvento 	:=cData
		cDHEvento 	+= "T"
		cDHEvento 	+= cHora
		If !(cTipo == "MDF") .And. !lCTe
			cDHEvento 	+= "-"
			cDHEvento	+= cUtc
		Else
			If (lCTe .And. cVerLayout = "3.00")
				cDHEvento 	+= "-"
				cDHEvento	+= cUtc
			EndIf
			If (cTipo == "MDF" .And. cVersaoMdf = "3.00")
				cDHEvento 	+= "-"
				cDHEvento	+= cUtc
			EndIf
		EndIf

		// Tratamento do Texto para correcao da carta
		cTextCCe := Alltrim(cTextCCe)
		cTextCCe := StrTran(cTextCCe,Chr(10),"")
		cTextCCe := StrTran(cTextCCe,Chr(13),"")
		If Len(cTextCCe) > 1000
			cTextCCe := Left(cTextCCe,1000)
		Endif

		// Montagem do Xml

		cXml := iif(!lUsaColab,"<envEvento>","")

		if !lUsaColab
			// Versao do layout
			cXml +=	"<versao>"
			cXml += cVerLayout
			cXml += "</versao>"

			// Lote do evento

			cXml +=	"<idLote>"
			cXml += cValToChar(nLote)
			cXml += "</idLote>"

		endif


			If !lUsaColab
				cXml += "<evento>"
			ElseIf lUsaColab .And. Empty(cTipo) .And. !lCte
				cXml +=	 '<evento versao="'+cVerLayEven+'" xmlns="http://www.portalfiscal.inf.br/nfe">'
			ElseIf lUsaColab .And. ( Alltrim(cTipo) == "MDF" )
				cXml +=	 '<eventoMDFe versao="'+cVerLayEven+'" xmlns="http://www.portalfiscal.inf.br/mdfe">'
			ElseIf lUsaColab .And. lCte
				cXml +=	 '<eventoCTe versao="'+cVerLayEven+'" xmlns="http://www.portalfiscal.inf.br/cte">'
			EndIf

				if !lUsaColab
					// Versao do layout do evento
					cXml +=	"<versao>"
					cXml += cVerLayEven
					cXml += "</versao>"
				endif

				cXml += iif(!lUsaColab,"<infEvento>",'<infEvento Id="'+cIdEvento+'">')
					if !lUsaColab
						// ID+Tipo evento+Chave Nfe+Sequencia do evento
						cXml += "<Id>"
						cXml += cIdEvento
						cXml += "</Id>"
					endif

					// Codigo do Orgao - Tabela IBGE
					cXml += "<cOrgao>"
					cXml += cCodOrgao
					cXml += "</cOrgao>"

					// Ambiente: 1-Producao ### 2-Homologacao
					cXml += "<tpAmb>"
					cXml += cAmbiente
					cXml += "</tpAmb>"

					If Len(AllTrim(cCnpj))==14
						cXml += "<CNPJ>"+Alltrim(cCnpj)+"</CNPJ>"
					Else
						cXml += "<CPF>"+Alltrim(cCnpj)+"</CPF>"
					endif

					// Chave da Nf-e
					If (cTipo == "MDF")
						cXml += "<chMDFe>"
						cXml += cChvNfe
						cXml += "</chMDFe>"
					ElseIf lCte
						cXml += "<chCTe>"
						cXml += cChvNfe
						cXml += "</chCTe>"
					Else
						cXml += "<chNFe>"
						cXml += cChvNfe
						cXml += "</chNFe>"
					EndIf

					cXml += "<dhEvento>"
					cXml += cDHEvento
					cXml += "</dhEvento>"

					// Tipo do Evento
					// 110110 - Carta de Correcao Eletronica
					// 110111 - Cancelamento NFe
					// MD-e
					//210200 – Confirmação da Operação
					//210210 – Ciência da Operação
					//210220 – Desconhecimento da Operação
					//210240 – Operação não Realizada

					cXml += "<tpEvento>"
					cXml += cTpEvento
					cXml += "</tpEvento>"

					// Sequencia do evento
					cXml += "<nSeqEvento>"
					If cTipo == "MDF"
						cXml += cValToChar(cSeqEven)
					Else
						cXml += cValToChar(Val(cSeqEven))
					EndIf
					cXml += "</nSeqEvento>"

					// Versao do evento
					If Empty(cTipo) .And. !lCte
						cXml += "<verEvento>"
						cXml += cVerEven
						cXml += "</verEvento>"
					EndIf

					If !lUsaColab
						cXml += "<detEvento>"
					ElseIf lUsaColab .And. Empty(cTipo) .And. !lCte
						cXml += '<detEvento versao="'+cVerCCe+'">'
					ElseIf lUsaColab .And. ( Alltrim(cTipo) == "MDF" )
						cXml += '<detEvento versaoEvento="'+cVersaoMdf+'">'
					ElseIf lUsaColab .And. lCte
						cXml += '<detEvento versaoEvento="'+cVerCCe+'">'
						cXml += '<evCancCTe>'
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Processo NAO Totvs Colaboracao 2.0                                     ³
					//³                                                                        ³
					//³ CCe - Carta de Correcao                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lUsaColab

						// Versao da carta de correcao
						cXml += "<versao>"
						cXml += cVerCCe
						cXml += "</versao>"

						cXml += '<descEvento>'+cDescEvento+'</descEvento>'

						// Texto livre de correcao da carta
						cXml += "<xCorrecao>"
						cXml += cTextCCe
						cXml += "</xCorrecao>"

						// Condicoes de uso da carta de correcao - texto fixo
						cXml += "<xCondUso>"
						cXml += "A Carta de Correcao e disciplinada pelo paragrafo 1o-A do art. 7o do Convenio S/N, de 15 de dezembro de 1970 e pode ser utilizada para regularizacao de erro ocorrido na emissao de documento fiscal, desde que o erro nao esteja relacionado com: I - as variaveis que determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da operacao ou da prestacao; II - a correcao de dados cadastrais que implique mudanca do remetente ou do destinatario; III - a data de emissao ou de saida."
						cXml += "</xCondUso>"

					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ TOTVS Colaboracao 2.0                                                  ³
						//³                                                                        ³
						//³ MDFe - Manifesto Eletronico de Documentos Fiscais                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Alltrim(cTipo) == "MDF"


							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ MDFe - Cancelamento e MD-e Operacao não realizada                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Alltrim(cTpEvento) $ '110111'
								cXml += '<evCancMDFe>'
								cXml += '<descEvento>'+cDescEvento+'</descEvento>'
								cXml += '<nProt>'+cProt+'</nProt>'
								// Justificativa do Cancelamento - e Operacao não realizada
								If !Empty(cTextCCe) .And. Len(cTextCCe)<255 .And. Len(cTextCCe)>15
									cXml += '<xJust>'+cTextCCe+'</xJust>'
								ElseIf Alltrim(cTpEvento) == "110111"
									If cTipo == "MDF"
										cXml += "<xJust>Cancelamento de Manifesto eletronico de Documentos Fiscais por emissao indevida</xJust>"
									Else
										cXml += "<xJust>Cancelamento de nota fiscal eletronica por emissao indevida</xJust>"
									EndIf
								EndIF
								cXml += '</evCancMDFe>'
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ MDFe - Encerramento                                                    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							ElseIf Alltrim(cTpEvento) $ '110112'
								cXml += '<evEncMDFe>'
								cXml += '<descEvento>'+cDescEvento+'</descEvento>'
								cXml += '<nProt>'+cProt+'</nProt>'
								cXml += '<dtEnc>'+SubStr(cDHEvento,1,10)+'</dtEnc>'
								cXml += '<cUF>'+cCodOrgao+'</cUF>'
								cXml += '<cMun>'+cMunicipio+'</cMun>'
								cXml += '</evEncMDFe>'
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ MDFe - inclusao de condutor              			                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							ElseIf Alltrim(cTpEvento) $ '110114'
								cXml += '<evIncCondutorMDFe>'
								cXml += '<descEvento>'+cDescEvento+'</descEvento>'
								cXml += '<condutor>'
								cXml += '<xNome>'+Alltrim(cNomeCon)+'</xNome>'
								cXml += '<CPF>'+Alltrim(cCPFCon)+'</CPF>'
								cXml += '</condutor>'
								cXml += '</evIncCondutorMDFe>'
							EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Processo padrao - CCe                                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf cTpEvento $ "110110"

							//Descricao do Evento
							cXml += '<descEvento>'+cDescEvento+'</descEvento>'

							// Texto livre de correcao da carta
							cXml += "<xCorrecao>"
							cXml += cTextCCe
							cXml += "</xCorrecao>"

							// Condicoes de uso da carta de correcao - texto fixo
							cXml += "<xCondUso>"
							cXml += "A Carta de Correcao e disciplinada pelo paragrafo 1o-A do art. 7o do Convenio S/N, de 15 de dezembro de 1970 e pode ser utilizada para regularizacao de erro ocorrido na emissao de documento fiscal, desde que o erro nao esteja relacionado com: I - as variaveis que determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da operacao ou da prestacao; II - a correcao de dados cadastrais que implique mudanca do remetente ou do destinatario; III - a data de emissao ou de saida."
							cXml += "</xCondUso>"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Processo padrao - Cancelamento NFe / MD-e Operacao não realizada       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf cTpEvento $ "110111-210240"

							cXml += '<descEvento>'+cDescEvento+'</descEvento>'
							if cTpEvento <> '210240'
								cXml += '<nProt>'+cProt+'</nProt>'
							endif
							// Justificativa do Cancelamento - e Operacao não realizada
							If !Empty(cTextCCe) .And. Len(cTextCCe)<255 .And. Len(cTextCCe)>15
								cXml += '<xJust>'+cTextCCe+'</xJust>'
							ElseIf cTpEvento == "110111"
								cXml += "<xJust>Cancelamento de nota fiscal eletronica por emissao indevida</xJust>"
							EndIf
						Else
							cXml += '<descEvento>'+cDescEvento+'</descEvento>'
						EndIf
					EndIf
					If lCte
						cXml += '</evCancCTe>'
					EndIf
					cXml += "</detEvento>"
				cXml += "</infEvento>"

			// Fechando tag Evento
			If (cTipo == "MDF")
				cXml += '</eventoMDFe>'
			ElseIf lCte
				cXml += '</eventoCTe>'
			Else
				cXml += "</evento>"
			EndIf

		cXml += iif(!lUsaColab,"</envEvento>","")

	Else

		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)

	Endif

Else

	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

EndIF

Return cXml

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedCCeMnt
Função que monitora os eventos da carta de correcao

@author Sergio S. Fuzinaka
@since 05.08.2011
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedCCeMnt(cAlias,nReg,nOpc,lCte)

Local cIdEnt	:= ""
Local aListBox 	:= {}
Local cIdEvento	:= IIF (cAlias == "SF2",(cAlias)->F2_IDCCE,(cAlias)->F1_IDCCE)
Local cDocNfe	:= IIF (cAlias == "SF2",(cAlias)->F2_DOC,(cAlias)->F1_DOC)
Local cSerieDoc := IIF (cAlias == "SF2",(cAlias)->F2_SERIE,(cAlias)->F1_SERIE)
Local cEstDoc	:= IIF (cAlias == "SF2",(cAlias)->F2_EST,(cAlias)->F1_EST)
Local lUsaColab	:= .F.
Local dEmissao	:= DtoC(IIF(cAlias == "SF2",(cAlias)->F2_EMISSAO,(cAlias)->F1_EMISSAO))
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4

Default lCte	:= .F.
lUsaColab := UsaColaboracao(IIF(lCte,"2","1"))
DEFINE FONT oBold BOLD

// Verifica se a entidade foi configurada
If IsReady(,,,lUsaColab)

	cIdEnt := GetIdEnt(lUsaColab)

	If !Empty(cIdEnt) .And. !Empty(cIdEvento)

		aListBox := SpedWsCCeMnt(cIdEvento,nReg,cAlias,lCte)

		If !Empty(aListBox)

			DEFINE MSDIALOG oDlg TITLE "SPED - CCe" From 10,10 TO 450,1012 OF oMainWnd PIXEL

			@015,010 SAY	STR0324	PIXEL OF oDlg FONT oBold	//Numero
			@015,036 SAY	cDocNfe						PIXEL OF  oDlg
			@015,074 SAY	STR0249	PIXEL OF oDlg FONT oBold	//Série
			@015,093 SAY	SubStr(cSerieDoc,1,3)					PIXEL OF oDlg
			@015,118 SAY	STR0314	PIXEL OF oDlg FONT oBold	//UF
			@015,151 SAY	cEstDoc			PIXEL OF oDlg
			@015,180 SAY	STR0325	PIXEL OF oDlg FONT oBold	//Dt. Emissao
			@015,213 SAY	dEmissao					PIXEL OF oDlg

			If Len(aListBox[1]) > 6
				@030,010 LISTBOX oListBox 	FIELDS HEADER "",STR0050,STR0362,STR0295,STR0364,STR0365, "Tentativas", "Obsevacao" SIZE 480,150 PIXEL OF oDlg	//"Protocolo ID Evento Ambiente Status do Evento Retorno da Transmissao Retorno Processamento do Evento"
			Else
				@030,010 LISTBOX oListBox 	FIELDS HEADER "",STR0050,STR0362,STR0295,STR0364,STR0365 SIZE 480,150 PIXEL OF oDlg	//"Protocolo ID Evento Ambiente Status do Evento Retorno da Transmissao Retorno Processamento do Evento"
			EndIf	

	        oListBox:SetArray(aListBox)

			If Len(aListBox[1]) > 6
				oListBox:bLine:={||	{aListBox[oListBox:nAt][01],;
										aListBox[oListBox:nAt][02],;
										aListBox[oListBox:nAt][03],;
										aListBox[oListBox:nAt][04],;
										aListBox[oListBox:nAt][05],;
										aListBox[oListBox:nAt][06],;
										aListBox[oListBox:nAt][07],;
										aListBox[oListBox:nAt][08];
										}}
			Else
				oListBox:bLine:={||	{aListBox[oListBox:nAt][01],;
	        						aListBox[oListBox:nAt][02],;
	        						aListBox[oListBox:nAt][03],;
	        						aListBox[oListBox:nAt][04],;
	        						aListBox[oListBox:nAt][05],;
									aListBox[oListBox:nAt][06]}}
			EndIf	
			@ 200,400 BUTTON oBtn1 PROMPT STR0118	ACTION (aListBox := SpedWsCCeMnt(cIdEvento,nReg,cAlias,lCte),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
			@ 200,455 BUTTON oBtn2 PROMPT STR0294	ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"

			ACTIVATE MSDIALOG oDLg CENTERED

		EndIf

	EndIf

Else

	Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

EndIf

Return

 //-----------------------------------------------------------------------
/*/{Protheus.doc} SpedWsCCePar
Função que executa os webservices de consulta da CC-e

@author Sergio S. Fuzinaka
@since 05.08.2011
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function SpedWsCCeMnt(cIdEvento,nReg,cAlias,lCte)

Local oWS			:= Nil
Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")

Local nLote			:= 0

Local cAmbiente	:= ""
Local cProtocolo	:= ""
Local cDocNfe		:= IIF (cAlias == "SF2",(cAlias)->F2_DOC,(cAlias)->F1_DOC)
Local cSerieDoc 	:= IIF (cAlias == "SF2",(cAlias)->F2_SERIE,(cAlias)->F1_SERIE)
Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt		:= ""
Local cStatus		:= ""
Local cStatRetEnv	:= ""
Local cStatRetEven	:= ""
Local cStatRet		:= ""
Local cIDEvenRet		:= ""
Local cMsg				:= ""

Local lOk      		:= .T.
local lUsaColab		:= .F.

Local nStatPos		:= 0
Local aListBox		:= {}
Local aDadosCol
Local aStatus		:= {	{1,"1-Evento recebido"},;
							{2,"2-Evento assinado"},;
							{3,"3-Evento com falha no schema XML"},;
							{4,"4-Evento transmitido"},;
							{5,"5-Evento com problemas"},;
							{6,"6-Evento vinculado"	} }

Local cTenConsInd	:=	""
Local cObsConsInd	:=	""


Default cIdEvento := ""
Default lCte := .F.

Private oXmlCCe, oDados

lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )

cIdEnt := GetIdEnt(lUsaColab)

If IsReady(,,,lUsaColab)

	if lUsaColab

		aDadosCol		:= ColMonitCCe(cSerieDoc,cDocNfe,@cMsg,lCte)
		if !Empty( aDadosCol )
			//[1]-Protocolo
			cProtocolo	:= aDadosCol[1]
			//[2]-Id do CCE
			cIDEvenRet := aDadosCol[2]
			//[3]-Ambiente
			cAmbiente	:= aDadosCol[3]
			//[4]-Status evento
			cStatus	:= aDadosCol[4]
			//[5]-Status retorno transmissão
			cStatRet	:= aDadosCol[5]

			// Evento registrado e vinculado a NF-e
			If	!Empty( cProtocolo )
				SpedAtuEvento(2,nReg,,cAlias)
			Endif

		endif

		lOk := .T.

	else
		// Executa o metodo NfeRetornaEvento()
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cID_EVENTO	:= cIdEvento
		lOk:=oWS:NFERETORNAEVENTO()
	endif

	If lOk
		if !lUsaColab
			// Tratamento do retorno do evento
			If ValType(oWS:oWsNfeRetornaEventoResult) <> "U" .And. ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"

				oDados := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento[1]

				If ( nStatPos := aScan(aStatus,{ |x| x[1] == oDados:nStatus}) ) > 0
					cStatus := aStatus[nStatPos][2]
				Endif
				cIDEvenRet	:= oDados:cId_Evento
				nLote 		:= oDados:nLote
				cAmbiente	:= Alltrim(Str(oDados:nAmbiente))		//1-Producao ### 2-Homologacao

				If Type("oDados:oWSWS01ConsumoIndevido") <> "U"
					cTenConsInd	:=	oDados:oWSWS01ConsumoIndevido:cTENTATIVAS
					cObsConsInd	:=	oDados:oWSWS01ConsumoIndevido:cOBSERVACAO
				Else
					cTenConsInd	:=	cObsConsInd	:=	""	
				EndIf

				If oDados:nStatus > 2

					// Retorno da transmissao
					cStatRetEnv := cValToChar(oDados:nCStat)+" - "+Alltrim(oDados:cXMotivo)

					// Retorno do processamento do evento
					If oDados:nCStatEven > 0
						cStatRetEven := cValToChar(oDados:nCStatEven)+" - "+Alltrim(oDados:cXMotivoEven)

						// Evento registrado e vinculado a NF-e
						If oDados:nCStatEven == 135
							cProtocolo := StrZero(oDados:nProt,15)
							SpedAtuEvento(2,nReg,,cAlias)
						Endif
					Endif

				Else
					cXmlRet := ""
				Endif

				cAmbiente:= IIf(cAmbiente == "1",STR0031,STR0032)

				If Empty(cStatRetEven)
					cStatRet := cStatRetEnv
				Else
					cStatRet := cStatRetEven
				Endif

				AADD( aListBox, {	IIf(Empty(cProtocolo),oNo,oOk),;
								cProtocolo,;
								cIDEvenRet,;
								cAmbiente,;		//[04] 1-Producao ### 2-Homologacao
								cStatus,;		//[05] Status do evento
								cStatRet,;		//[06] Status retorno da transmissao
								cTenConsInd,;
								cObsConsInd;
								})		
			EndIf

		Else

			cAmbiente:= IIf(cAmbiente == "1",STR0031,STR0032)
			AADD( aListBox, {	IIf(Empty(cProtocolo),oNo,oOk),;
							cProtocolo,;
							cIDEvenRet,;
							cAmbiente,;		//[04] 1-Producao ### 2-Homologacao
							cStatus,;		//[05] Status do evento
							cStatRet,;		//[06] Status retorno da transmissao
							cTenConsInd,;
							cObsConsInd;
							})		

		Endif

	    If Empty(aListBox)
	    	Aviso("SPED",STR0106+" "+cMsg,{STR0114})
	    EndIf

	Else

		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)

	EndIf

Else

	Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

EndIf

Return(aListBox)

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedCCePar
Função que parametriza o Protheus para a Carta de Correcao Eletronica

@author Sergio S. Fuzinaka
@since 03.08.2011
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedCCePar(nEvento,lAtuParam,cModel,lEpp)

Local oWs
Local aPerg  	:= {}
Local aParam 	:= {"","","","","","",""}
local aCfgCCe	:= {}
Local aCombo1	:= {}	//Ambiente
Local aCombo2	:= {}	//Versao do leiaute
Local aCombo3	:= {}	//Versao do leiaute do evento
Local aCombo4	:= {}	//Versao do evento
Local aCombo5	:= {}	//Versao da carta de correcao
Local aCombo6	:= {}	//Horario de verao: 1-Sim###2-Nao
Local aCombo7	:= {}	//Horario: 1-Fernando de Noronha###2-Brasilia###3-Manaus
Local aCombo8   := {}   //Versão da Manifestação

//Parametrização para EPP
Local aCombo9   := {}   //Versão EPP
Local aCombo10  := {}   //Versão Evento EPP
Local aCombo11  := {}   //Versão Layout Evento EPP
Local aCombo12  := {}   //Versão EPP LAyout

Local cCombo1	:= STR0349	//"2-Homologacao"
Local cCombo2	:= "1.00"
Local cCombo3	:= "1.00"
Local cCombo4	:= "1.00"
Local cCombo5	:= "1.00"
Local cCombo6	:= "2"
Local cCombo7	:= "2"
Local cCombo8 := "1.01"
Local cCombo9 := "1.00"
Local cCombo10:= "1.00"
Local cCombo11:= "1.00"
Local cCombo12:= "1.00"
Local cVersaoTSS := ""

Local cIdEnt 	:= ""
Local cURL   	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
local cModTC	:= ""

Local nTempo 	:= 0
Local cParCCePar:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDCCEPAR"
Local cParMANPar:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDMANPAR"
local cError	:= ""
Local nX
Local aParamAtu	:= {}
Local lUsaColab	:= .F.
Local lAdminNfe  := GetNewPar("MV_ADMNFE",.T.)

Default nEvento     := 0
Default lAtuParam	:= .T.
Default cModel	 := "55"
Default lEpp	:= .F.

//---------------------------------
// Tratamento da NFCe para o Loja
//---------------------------------
If cModel == "65"
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
EndIf

If cModel <> "65"
	cModTC := ModeloColab(cModel)
	lUsaColab := UsaColaboracao( cModTC )
EndIf

if cModel == "55"
	if nEvento <> 5
		lUsaColab	:= UsaColaboracao("1")
	else
		//MDe
		lUsaColab	:= UsaColaboracao("4")
	endif
endif

// Versao TSS
If !lUsaColab
   cVersaoTSS := StrTran(getVersaoTSS(),".","")
Endif
// Ambiente
AADD(aCombo1,STR0348)	//"1-Producao"
AADD(aCombo1,STR0349)	//"2-Homologacao"

// Versao do leiaute
AADD(aCombo2,"1.00")

// Versao do leiaute do evento
AADD(aCombo3,"1.00")

// Versao do evento
AADD(aCombo4,"1.00")

// Versao da carta de correcao
AADD(aCombo5,"1.00")

// Horario de verao
AADD(aCombo6,"1-Sim")
AADD(aCombo6,"2-Nao")

// Horario
AADD(aCombo7,"1-Fernando de Noronha")
AADD(aCombo7,"2-Brasilia")
AADD(aCombo7,"3-Manaus")
AADD(aCombo7,"4-Acre")

// Versao da Manifestação
If ( Left(LTrim(cVersaoTSS),2) <> "12" .And. Val(cVersaoTSS) >= 271 ) .Or. ( Left(LTrim(cVersaoTSS),2) == "12" .And. Val(cVersaoTSS) >= 121016 )
   AADD(aCombo8,"1.01")	// Nova Consulta (NT2014/002 - Maio de 2017)
Else
   AADD(aCombo8,"1.00")
Endif

If lEpp

	//Versão EPP
	AADD(aCombo9,"1.00")
	//Versão Evento EPP
	AADD(aCombo10,"1.00")
	//Versão Layout Evento EPP
	AADD(aCombo11,"1.00")
	//Versão EPP LAyout
	AADD(aCombo12,"1.00")


EndIF

if ( lAdminNfe .And. PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0 ) .Or. !lAdminNfe
If lAtuparam
	aParamAtu:=	Array(Len(aPergEvento))
EndIf

If IsReady(,,,lUsaColab)
	if lUsaColab
		if nEvento <> 5
			ColParametros("CCE")
		else
			ColParametros("MDE")
		endif

	else
		// Obtem o codigo da entidade
		cIdEnt := GetIdEnt()

		// Obtem o ambiente de configuracao
		oWS:=WsSpedCfgNfe():New()
		oWS:cUSERTOKEN 	  	:= "TOTVS"
		oWS:cID_ENT    		:= cIdEnt
		oWS:nAMBIENTECCE	:= 0
		oWS:cVERCCELAYOUT	:= "1.00"
		oWS:cVERCCELAYEVEN	:= "1.00"
		oWS:cVERCCEEVEN		:= "1.00"
		oWS:cVERCCE			:= "1.00"
		oWS:cHORAVERAOCCE	:= "2-Nao"
		oWS:cHORARIOCCE		:= "2-Brasilia"
		oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"

			aCfgCCe := getCfgCCe(@cError, cIdEnt)
			lOk:= empty(cError)

		If lOk
				// Ambiente
				If Valtype(aCfgCCe[1]) <> "U"
					cCombo1 := aCfgCCe[1]
				Else
					cCombo1 := STR0349	//"2-Homologacao"
				EndIf
				// Versao do leiaute
				If ValType(aCfgCCe[8]) <> "U"
					cCombo2	:= aCfgCCe[8]
				Else
					cCombo2	:= "1.00"
				EndIF
				// Versao do leiaute do evento
				If ValType(aCfgCCe[7]) <> "U"
					cCombo3	:= aCfgCCe[7]
				Else
					cCombo3	:= "1.00"
				EndIF
				// Versao do evento
				If ValType(aCfgCCe[6]) <> "U"
					cCombo4	:= aCfgCCe[6]
				Else
					cCombo4	:= "1.00"
				EndIF
				// Versao da carta de correcao
				If ValType(aCfgCCe[5]) <> "U"
					cCombo5	:= aCfgCCe[5]
				Else
					cCombo5	:= "1.00"
				EndIF
				// Horario de verao
				If ValType(aCfgCCe[3]) <> "U"
					cCombo6	:= aCfgCCe[3]
				Else
					cCombo6	:= "2-Nao"
				EndIF
				// Horario
				If ValType(aCfgCCe[2]) <> "U"
					cCombo7	:= aCfgCCe[2]
				Else
					cCombo7	:= "2-Brasilia"
				EndIF
		EndIf
		If ( nEvento == 5 )
			oWs:= WSMANIFESTACAODESTINATARIO():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cIDENT	     := cIdEnt
			oWs:cAMBIENTE	 := ""
			oWs:cVERSAO      := ""
			oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
			lOkManifes:=oWs:CONFIGURARPARAMETROS()

			If lOkManifes
				// Ambiente
				If Valtype(oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE) <> "U"
					cCombo1 := IIF(Alltrim(oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE) == "2",STR0349,STR0348)
				Else
					cCombo1 := STR0349	//"2-Homologacao"
				EndIf
				// Versao da Manifestação
				If Valtype(oWs:OWSCONFIGURARPARAMETROSRESULT:CVERSAO) <> "U"
					cCombo8 := oWs:OWSCONFIGURARPARAMETROSRESULT:CVERSAO
				Else
					cCombo8 := "1.01"
				EndIf
			EndIf
	  	Endif

		AADD(aPerg,{2,STR0035,cCombo1,aCombo1,120,".T.",.T.,".T."}) //"Ambiente"
		AADD(aPerg,{2,STR0350,cCombo2,aCombo2,120,".T.",.T.,".T."}) //"Versao do leiaute"
		AADD(aPerg,{2,STR0351,cCombo3,aCombo3,120,".T.",.T.,".T."}) //"Versao do leiaute do evento"
		AADD(aPerg,{2,STR0352,cCombo4,aCombo4,120,".T.",.T.,".T."}) //"Versao do evento"
		If ( nEvento <> 5 )
			AADD(aPerg,{2,STR0361,cCombo5,aCombo5,120,".T.",.T.,".T."}) //"Versao da carta de correcao
		Else
			AADD(aPerg,{2,"Versao da Manisfestacao",cCombo8,aCombo8,120,".T.",.T.,".T."}) //"Versao da manisfestacao"
		Endif
		AADD(aPerg,{2,STR0369,cCombo6,aCombo6,120,".T.",.T.,".T."}) //"Horario de verao
			AADD(aPerg,{2,STR0370,cCombo7,aCombo7,120,".T.",.T.,".T."}) //"Horario

		IF lEpp

			AADD(aPerg,{2,'Versão EPP',cCombo9,aCombo9,120,".T.",.T.,".T."}) //Versão EPP

			AADD(aPerg,{2,'Versão Evento EPP',cCombo10,aCombo10,120,".T.",.T.,".T."}) //Versão Evento EPP

			AADD(aPerg,{2,'Versão Layout Evento EPP',cCombo11,aCombo11,120,".T.",.T.,".T."}) //Versão Layout Evento EPP

			AADD(aPerg,{2,'Versão EPP Layout',cCombo12,aCombo12,120,".T.",.T.,".T."}) //Versão EPP LAyout

		EndIF

		If lAtuparam
			For nX := 1 to Len(aPergEvento)
				aParamAtu[nX] := &("MV_PAR"+StrZero(nX,2))
			Next nX
		EndIf

		If lEpp
			aParam := {cCombo1,cCombo2,cCombo3,cCombo4,cCombo5,cCombo6,cCombo7,cCombo9,cCombo10,cCombo11,cCombo12}
		Else
			aParam := {cCombo1,cCombo2,cCombo3,cCombo4,cCombo5,cCombo6,cCombo7}
		Endif

		If ParamBox(aPerg,"Eventos",aParam,,,,,,,Iif(nEvento == 5,cParMANPar,cParCCePar),.T.,.F.)

				If lEpp
					getCfgCCe(	@cError, cIdEnt, Val(Substr(aParam[1],1,1)), aParam[2], aParam[3], aParam[4],;
								IIf(nEvento == 5,"1.00",aParam[5]), Left(aParam[6],1), Left(aParam[7],1),, aParam[8] ,aParam[9] ,aParam[10] , aParam[11],lEpp)
				Else

					getCfgCCe(	@cError, cIdEnt, Val(Substr(aParam[1],1,1)), aParam[2], aParam[3], aParam[4],;
								IIf(nEvento == 5,"1.00",aParam[5]), Left(aParam[6],1), Left(aParam[7],1))
				EndIF

				lOk := empty(@cError)

			If (nEvento == 5)
				oWs:= WSMANIFESTACAODESTINATARIO():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cIDENT	     := cIdEnt
				oWs:cAMBIENTE	 := Substr(aParam[1],1,1)
				oWs:cVERSAO      := aParam[5]
				oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
				oWs:CONFIGURARPARAMETROS()
			EndIF
			If lOk
				Aviso("Eventos",STR0346,{STR0114},3)	//"Carta de Correcao","Configuração efetuada com sucesso"
			Else
				Aviso("Eventos",STR0347,{STR0114},3)	//"Carta de Correcao","Houve um erro durante a configuracão"
			EndIf
			If lAtuparam
				For nX := 1 to Len(aParamAtu)
					&("MV_PAR"+StrZero(nX,2)):=aParamAtu[nX]
				Next nX
			EndIf
		EndIF
	endif

Else

	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

EndIF
Else
		Help( "", 1, "SEMPERM" )
Endif

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedAtuEvento
Função que atualiza a tabela SF2 e SF1 com o ID do evento

@author Sergio S. Fuzinaka
@since 04.08.2011
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function SpedAtuEvento(nOpc,nRecno,cIdEven,cAlias,cEvento)

Default nOpc 	:= 1
	Default cIdEven	:= IIF (cAlias == "SF2",SF2->F2_IDCCE,SF1->F1_IDCCE)
	Default cEvento	:= "110110"

If cAlias == "SF2"
	SF2->(dbGoTo(nRecno))
	SF2->(RecLock("SF2",.F.))
		If cEvento == "110110"
			If nOpc == 1				// Grava o ID da CCe
				SF2->F2_IDCCE := cIdEven
			Else
				SF2->F2_EVENFLG	:= "1"	// Grava o flag de vinculo
			Endif

		ElseIf cEvento == "110999"
			If nOpc = 1
				SF2->F2_CODRGS	:= 'T'//registro transmitido
				SF2->F2_IDRGS	:= cIdEven
			ElseIf nOpc == 2
				SF2->F2_CODRGS	:= 'S'//registro autorizado(NF vinculada)
			ElseIf nOpc == 3
				SF2->F2_CODRGS	:= 'N'//registro rejeitado
			ElseIf nOpc == 4
				SF2->F2_CODRGS := 'M'//cancelmanto transmitido
			ElseIF 	nOpc == 5
				SF2->F2_CODRGS := 'R'//cancelamento rejeitado
			ElseIF 	nOpc == 6
				SF2->F2_CODRGS := 'C'//cancelamneto autorizado
			EndIF
		EndIF

		SF2->(MsUnlock())
	Else

		SF1->(dbGoTo(nRecno))
		SF1->(RecLock("SF1",.F.))

		If cEvento == "110110"
			If nOpc == 1				// Grava o ID da CCe
				SF1->F1_IDCCE := cIdEven
			Else
				SF1->F1_EVENFLG	:= "1"	// Grava o flag de vinculo
			Endif

		ElseIf cEvento == "110999"
			If nOpc = 1
				SF1->F1_CODRGS	:= 'T'
				SF1->F1_IDRGS	:= cIdEven
			ElseIf nOpc == 2
				SF1->F1_CODRGS	:= 'S'
			ElseIf nOpc == 3
				SF1->F1_CODRGS	:= 'N'
			ElseIf nOpc == 4
				SF1->F1_CODRGS := 'M'
			ElseIF 	nOpc == 5
				SF1->F1_CODRGS := 'R'
			ElseIF 	nOpc == 6
				SF1->F1_CODRGS := 'C'
			EndIF
		EndIf
		SF1->(MsUnlock())
	EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedCCeTexto
Função que valida o tamanho minimo do texto

@author Sergio S. Fuzinaka
@since 04.08.2011
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedCCeTexto(cTexto,nLimTam,lMantem)

Local lRet := .T.

Default nLimTam := 1000
Default lMantem := .F.

// Tratamento do Texto para correcao da carta
cTexto := Alltrim(cTexto)
cTexto := StrTran(cTexto,Chr(10),"")
cTexto := StrTran(cTexto,Chr(13),"")
cTexto := StrTran(cTexto,Chr(135),"&Amp;")
cTexto := StrTran(cTexto,Chr(198),"&atilde;")


//Ponto de entrada para customizar o texto utilizado na CC-e OU validar o texto digitado pelo usuario
If ExistBlock("SPDCCeTx")
	lRet := U_SPDCCeTx(@cTexto)
EndIf

If Len(cTexto) > nLimTam .and. !lMantem
	cTexto := Left(cTexto,nLimTam)
Endif

If Len(cTexto) < 15 .or. Len(cTexto) > nLimTam
	MsgAlert(STR0373+" e máximo de "+cValToChar(nLimTam)+".  "+"Tamanho utilizado:  "+(cValToChar(Len(cTexto)))+"   caracteres.   ","SPED") //"Texto com minímo de 15 caracteres"
	lRet := .F.
Endif

Return( lRet )

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedCCeLeg
Função que demonstra a legenda das cores da mbrowse

@author Sergio S. Fuzinaka
@since 04.08.2011
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedCCeLeg()

Local aLegenda := {}

AADD(aLegenda, {"ENABLE"	,STR0353}) //"NF vinculada"
AADD(aLegenda, {"BR_CINZA"	,STR0354}) //"NF nao vinculada"

BrwLegenda(cCadastro,STR0117,aLegenda) //"Legenda"

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedTabIBGE
Função que retorna a tabela do IBGE

@author Sergio S. Fuzinaka
@since 09.08.2011
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedTabIBGE()

Local aUf 	:= {}

AADD(aUf,{"RO", "Rondonia"				, "Rondônia"			, "11"})
AADD(aUf,{"AC", "Acre"					, "Acre"				, "12"})
AADD(aUf,{"AM", "Amazonas"				, "Amazonas"			, "13"})
AADD(aUf,{"RR", "Roraima"				, "Rorâima"				, "14"})
AADD(aUf,{"PA", "Para"					, "Pará"				, "15"})
AADD(aUf,{"AP", "Amapa"					, "Amapá"				, "16"})
AADD(aUf,{"TO", "Tocantis"				, "Tocantis"			, "17"})
AADD(aUf,{"MA", "Maranhao"				, "Maranhão"			, "21"})
AADD(aUf,{"PI", "Piaui"					, "Piauí"				, "22"})
AADD(aUf,{"CE", "Ceara"					, "Ceará"				, "23"})
AADD(aUf,{"RN", "Rio Grande do Norte"	, "Rio Grande do Norte"	, "24"})
AADD(aUf,{"PB", "Paraiba"				, "Paraíba"				, "25"})
AADD(aUf,{"PE", "Pernambuco"			, "Pernambuco"			, "26"})
AADD(aUf,{"AL", "Alagoas"				, "Alagoas"				, "27"})
AADD(aUf,{"MG", "Minas Gerais"			, "Minas Gerais"		, "31"})
AADD(aUf,{"ES", "Espirito Santo"		, "Espírito Santo"		, "32"})
AADD(aUf,{"RJ", "Rio de Janeiro"		, "Rio de Janeiro"		, "33"})
AADD(aUf,{"SP", "Sao Paulo"				, "São Paulo"			, "35"})
AADD(aUf,{"PR", "Parana"				, "Paraná"				, "41"})
AADD(aUf,{"SC", "Santa Catarina"		, "Santa Catarina"		, "42"})
AADD(aUf,{"RS", "Rio Grande do Sul"		, "Rio Grande do Sul"	, "43"})
AADD(aUf,{"MS", "Mato Grosso do Sul"	, "Mato Grosso do Sul"	, "50"})
AADD(aUf,{"MT", "Mato Grosso"			, "Mato Grosso"			, "51"})
AADD(aUf,{"GO", "Goias"					, "Goiás"				, "52"})
AADD(aUf,{"DF", "Distrito Federal"		, "Distrito Federal"	, "53"})
AADD(aUf,{"SE", "Sergipe"				, "Sergipe"				, "28"})
AADD(aUf,{"BA", "Bahia"					, "Bahia"				, "29"})
AADD(aUf,{"EX", "Exterior"				, "Exterior"			, "99"})

aUf := Asort(aUf,,,{|x,y| x[1] < y[1]})

Return aUf
//-----------------------------------------------------------------------
/*/{Protheus.doc} RetCodDene
Função que retorna os codigos de uso denegado

@author Natalia Sartori
@since 01.03.2012
@version 1.00

@Return	cString - retorna os códigos de uso denegado da NFe/CTe

/*/
//-----------------------------------------------------------------------

Function RetCodDene()

Local cString := "'110','301','205','302','303','304','305','306'"

Return cString




//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedRGSRemessa
Funcao para a transmissao do registro de saida Siare(MG)

@author reanto Nagib
@since 16/03/2012
@version 1.0

@param	@cAlias		Alias da tabela
		@nReg		Registro posicionado no alias
		@nOpc		Opacao da rotina
		@cMarca		Dica do erro ocorrido
		@lInverte	inversao da selecao Markbrowse
		cIDRGS		ID de identificacao do registro passado na retransmissao


@return .T.
/*/
//-----------------------------------------------------------------------
Function SpedRGSRemessa(cAlias,nReg,nOpc,cMarca,lInverte)

	Local aArea			:= GetArea()
	Local aNfe			:= {}
	Local aTexto		:= {}
	Local aListBox		:= {}
	local aCfgCCe		:= {}
	Local cRetorno  	:= ""
	Local cAmbiente		:= ""
	Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cVerLayout	:= "1.00"
	Local cSerie		:= Space(3)
	Local cNumero		:= Space(12)
	Local cHora			:= Time()
	Local cVeic			:= Space(8)
	Local cCar			:= Space(8)
	Local cCar2			:= Space(8)
	Local cVias			:= Space(1)
	Local cIdEnt		:= ""
	Local cAliasTemp	:= GetNextAlias()
	Local cWhere		:= ""
	local cError		:= ""
	Local dData			:= Date()

	Local lOk			:= .T.
	Local lContingencia	:= .F.

	Local nX			:= 0

	Local oWs
	Local oWizard
	Local oContgencia


	// Verifica se a entidade foi configurada e o limite por eventos
	If IsReady()

		If lInverte
			If cAlias == "SF2"
				cSelect:="%F2_DOC,F2_SERIE,F2_EMISSAO,R_E_C_N_O_,F2_CHVNFE,F2_EST%"
				cWhere += "%F2_FILIAL='"+xFilial("SF2")+"' AND F2_CODRGS NOT IN('T','S','M') AND F2_CHVNFE<>' ' AND F2_FLAGRGS <>'"+cMarca+"' AND "+cCondQry+"%"
			ElseIf cAlias == "SF1"
				cSelect := "%F1_DOC,F1_SERIE,F1_EMISSAO,R_E_C_N_O_,F1_CHVNFE,F1_EST%"
				cWhere += "%F1_FILIAL='"+xFilial("SF1")+"' AND F1_CODRGS NOT IN('T','S','M') AND F1_CHVNFE<>' ' AND F1_FLAGRGS <>'"+cMarca+"' AND "+cCondQry+"%"
			EndIf
		Else
			If cAlias == "SF2"
				cSelect:="%F2_DOC,F2_SERIE,F2_EMISSAO,R_E_C_N_O_,F2_CHVNFE,F2_EST%"
				cWhere += "%F2_FILIAL='"+xFilial("SF2")+"' AND F2_CHVNFE<>' ' AND F2_FLAGRGS ='"+cMarca+"'  AND "+cCondQry+"%"
			ElseIf cAlias == "SF1"
				cSelect := "%F1_DOC,F1_SERIE,F1_EMISSAO,R_E_C_N_O_,F1_CHVNFE,F1_EST%"
				cWhere += "%F1_FILIAL='"+xFilial("SF1")+"'   AND F1_CHVNFE<>' ' AND F1_FLAGRGS ='"+cMarca+"' AND F1_FORMUL ='S' AND "+cCondQry+"%"
			EndIf
		EndIF

		If cAlias == "SF2"

			BeginSql Alias cAliasTemp
				SELECT	%Exp:cSelect%
				FROM %Table:SF2%
				WHERE %Exp:cWhere% AND
				%notdel%
				ORDER BY 3,2,1
			EndSql

	    ElseIf cAlias == "SF1"

			BeginSql Alias cAliasTemp
				SELECT	%Exp:cSelect%
				FROM %Table:SF1%
				WHERE %Exp:cWhere% AND
				%notdel%
				ORDER BY 3,2,1
			EndSql

	    EndiF
		(cAliasTemp)->(dbGotop())

		If (cAliasTemp)->(Eof())
			MsgInfo(STR0397)//"Nenhum registro á transmitir "
			Return nil
		EndIf

		While (cAliasTemp)->(!Eof())
			If cAlias == "SF2"
			   	aadd(aListBox,{	Stod((cAliasTemp)->F2_EMISSAO),;
								(cAliasTemp)->F2_SERIE,;
							   	(cAliasTemp)->F2_DOC,;
								Space(3),;	//Serie formulario de seguranca
								Space(9),;	//Numero formulario
								Space(1),; //Vias
								(cAliasTemp)->F2_CHVNFE})

				AADD(ANfe,{(cAliasTemp)->F2_CHVNFE,;	//01-Chave da Nfe
				    (cAliasTemp)->R_E_C_N_O_})

			ElseIf cAlias == "SF1"
			   	aadd(aListBox,{	Stod((cAliasTemp)->F1_EMISSAO),;
								(cAliasTemp)->F1_SERIE,;
							   	(cAliasTemp)->F1_DOC,;
								Space(3),;	//Serie formulario de seguranca
								Space(9),;	//Numero formulario
								Space(1),; //Vias
								(cAliasTemp)->F1_CHVNFE})

				AADD(ANfe,{(cAliasTemp)->F1_CHVNFE,;	//01-Chave da Nfe
				    (cAliasTemp)->R_E_C_N_O_})
			EndIF

			(cAliasTemp)->(dbSkip())
		End


		// Obtem o codigo da entidade
		cIdEnt := GetIdEnt()

		If !Empty(cIdEnt)

			If cVersaoTSS < "2.07"
				// Obtem o ambiente de configuracao
				oWS:=WsSpedCfgNfe():New()
				oWS:cUSERTOKEN 	  	:= "TOTVS"
				oWS:cID_ENT    		:= cIdEnt
				oWS:nAMBIENTECCE	:= 0
				oWS:cVERCCELAYOUT	:= "1.00"
				oWS:cVERCCELAYEVEN	:= "1.00"
				oWS:cVERCCEEVEN		:= "1.00"
				oWS:cVERCCE			:= "1.00"
				oWS:cHORAVERAOCCE	:= "2-Nao"
				oWS:cHORARIOCCE		:= "2-Brasilia"
				oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"

				aCfgCCe := getCfgCCe(@cError, cIdEnt)
				lOk		:= empty(cError)

				If lOk

					// Ambiente
					If Valtype(aCfgCCe[1]) <> "U"
						cAmbiente := aCfgCCe[1]
					Else
						cAmbiente := STR0349	//"2-Homologacao"
					EndIf
					// Versao do leiaute
					If ValType(aCfgCCe[8]) <> "U"
						cVerLayout	:= aCfgCCe[8]
					Else
						cVerLayout	:= "1.00"
					EndIF
				EndIf
			EndIf


			If lOk

				// Montagem da Interface
				aadd(aTexto,{})
				aTexto[1] := STR0377//"Esta rotina tem como objetivo auxilia-lo na transmissão do registro de saida Eletrônico para o serviço Totvs Services SPED."+" " 						//"Esta rotina tem como objetivo auxilia-lo na transmissão da Carta de Correção Eletrônica para o serviço Totvs Services SPED."

				If cVersaoTSS < "2.07"
					aTexto[1] += STR0374+CRLF+CRLF//"Totvs Services SPED está operando com a seguinte configuração: "
					aTexto[1] += STR0015+cAmbiente+CRLF	//"Ambiente: "
				EndIf

				aadd(aTexto,{})

				DEFINE FONT oBold BOLD

				DEFINE WIZARD oWizard ;
					TITLE STR0378;//Assistente de transmissão do registro de saída eletrônico
					MESSAGE STR0379;//"Siga atentamente os passos para a configuração do registrro de saída."
					TEXT aTexto[1] ;
					NEXT {|| .T.} ;
					FINISH {||.T.}

				CREATE PANEL oWizard ;
					HEADER STR0378;//Assistente de transmissão do registro de saída eletrônico
					MESSAGE "";
					BACK {|| .T.} ;
					NEXT {|| Processa({|lEnd| cRetorno := SpedRGSTrf(aNFe,dData,cHora,cVeic,cCar,cCar2,cVias,cSerie,cNumero,cAlias,lContingencia)}),.T.} ;
					PANEL

					@005,005	SAY	STR0380	SIZE 040,10	PIXEL	FONT oBold OF oWizard:oMPanel[2] COLOR CLR_BLUE  //Data saida
					@005,090	SAY	STR0381	SIZE 040,10	PIXEL	FONT oBold OF oWizard:oMPanel[2]//Hora saída
					@020,005	SAY	STR0231	SIZE 040,10	PIXEL	FONT oBold OF oWizard:oMPanel[2]//"Veículo"
					@035,005	SAY	STR0232	SIZE 040,10	PIXEL	FONT oBold OF oWizard:oMPanel[2]//Carreta
  					@050,005	SAY	STR0233	SIZE 040,10	PIXEL	FONT oBold OF oWizard:oMPanel[2]//Carreta2

					@005,040	MSGET oData	VAR dData	SIZE 035,008	OF oWizard:oMPanel[2]	PIXEL VALID (!Empty(dData) .And. ValidDate(@oData,@dData,lContingencia)) PICTURE "99/99/99"
					@005,125	MSGET oHora	VAR cHora	SIZE 035,008	OF oWizard:oMPanel[2]	PIXEL VALID (!Empty(cHora)) PICTURE "99:99:99"
					@020,040	MSGET oVeic	VAR	cVeic	SIZE 050,008	OF oWizard:oMPanel[2]	PIXEL VALID (Empty(cVeic) .Or. ExistCpo("DA3",cVeic,1))	F3 "DA3"
					@035,040	MSGET oCar	VAR cCar	SIZE 050,008	OF oWizard:oMPanel[2]	PIXEL VALID (Empty(cVeic) .Or. ExistCpo("DA3",cVeic,1) ) 	F3 "DA3"
					@050,040	MSGET oCar2	VAR cCar2 	SIZE 050,008	OF oWizard:oMPanel[2]	PIXEL VALID (Empty(cVeic) .Or. ExistCpo("DA3",cVeic,1))	F3 "DA3"

					If lContingencia
						@065,000 GROUP oGrpForm TO 135,280  PROMPT STR0382	OF oWizard:oMPanel[2] PIXEL//"Informações de contigência"
 						@075,005 LISTBOX oListBox 	FIELDS HEADER STR0325,STR0249,STR0248,STR0383,STR0384,STR0385 SIZE 270,055 ON DBLCLICK 	If(Alltrim(Str(oListBox:nColPos))$"4|5|6|",lEditCell( aListBox, oListBox, "@!",oListBox:nColPos),nil)  PIXEL OF oWizard:oMPanel[2]//Emissao,Série,Nota Fiscal,Sèrie Formulário,Nº Formulário,Nº Vias

				        oListBox:SetArray(aListBox)
				        oListBox:bLine:={||	{aListBox[oListBox:nAt][01],;
				        					 aListBox[oListBox:nAt][02],;
				        					 aListBox[oListBox:nAt][03],;
				        					 aListBox[oListBox:nAt][04],;
				        					 aListBox[oListBox:nAt][05],;
											 aListBox[oListBox:nAt][06]}}

                    EndIf

				CREATE PANEL oWizard  ;
					HEADER STR0378;//Assistente de transmissão do registro de saída eletrônico
					MESSAGE "";
					BACK {|| .T.} ;
					FINISH {|| .T.} ;
					PANEL

				@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]

				ACTIVATE WIZARD oWizard CENTERED
		   EndIf

		EndIf

	Else

	   //	Aviso("SPED",STR0372,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf

Return

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpedRGSTrf
Função que transmite o registro de saida

@author Renato Nagib
@since 20.03.2012
@version 1.00

@param	aNfe			chave e recno da nota fiscal
		dData			data do registro de saida
		cHora			hora do registro de saida
		cVeic			veiculo
		cCar			carreta
		cCar2			carreta2
		cVias			numero de vias do formulario de seguranca
		cSerie			serie do fomulario de seguranca
		cNumero 		numero do formulario de seguranca
		cAlias			Alias da tabela
		lContingencia	Informa se esta em contingencia

@return	cRetorno -resultado do processamento

/*/
//--------------------------------------------------------------------------------------------
Static Function SpedRGSTrf(aNfe,dData,cHora,cVeic,cCar,cCar2,cVias,cSerie,cNumero,cAlias,lContingencia)

	Local cXml      := ""
	Local cRetorno  := ""
	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cHoraIni	:= Time()
	Local cErro		:= ""
	Local cIdEnt	:= ""
	Local dDataIni	:= Date()
	Local lRetorno	:= .F.
	Local nEnvio	:= 0
	Local nX		:= 0

	// Verifica se a entidade foi configurada
	If IsReady()

		// Obtem o codigo da entidade
		cIdEnt := GetIdEnt()

		// Monta o Xml
		cXml := SpedRGSXml(aNfe,dData,cHora,cVeic,cCar,cCar2,cVias,cSerie,cNumero,cAlias,lContingencia)

		// Chamado do metodo e envio
		oWs:= WsNFeSBra():New()
		oWs:cUserToken	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWs:cXML_LOTE	:= cXml
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

		If oWs:RemessaEvento()
			If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
				If Type("oWS:oWsRemessaEventoResult:cString") <> "A"
					aRetorno:={oWS:oWsRemessaEventoResult:cString}
				Else
					aRetorno:=oWS:oWsRemessaEventoResult:cString
				EndIf

				For nX:=1  To Len(aNfe)
					nPos:=aScan(aRetorno,{|X| Substr(X,9,44) ==aNfe[nX][1]})
					If nPos > 0
						SpedAtuEvento(1,aNfe[nX][2],aRetorno[nPos],cAlias,"110999")
						nEnvio++
					EndIf
				Next
				lRetorno:= .T.
			Endif
		Else
			lRetorno:= .F.
			cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Endif

		If lRetorno
			cRetorno := STR0026+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
			cRetorno += STR0359+CRLF+CRLF //"Verifique se o evento foi vinculado a NF-e na SEFAZ, utilizando a rotina 'Monitor'."
			cRetorno += Left(STR0360,16)+cValToChar(nEnvio)+Substr(STR0360,16)+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foi transmitido 0/1 evento em "
		Else
			cRetorno := STR0030+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
			cRetorno += cErro
		EndIf

	Else

		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

	Endif

Return(cRetorno)

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidDate
Função para validacao da data e hora do registro de saida

@author Rebato Nagib
@since 20.03.2012
@version 1.00

@param	oData			Get da data do registro de saida
		dData			data do registro de saida
		lContingencia	informa se esta em contingencia
@return	cRetorno -resultado do processamento

/*/
//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidDate
Função pavalidacao da data de saida do registro de saida

@author Renato Nagib
@since 20.03.2012
@version 1.00

@param	oData			get da data
		dData			data do registro
		lContigencia	indica se esta em contigencia

@return Logico
/*/
//-------------------------------------------------------------------------------------------
Static Function ValidDate(oData,dData,lContingencia)

	Local lReturn := .T.

	If dData < Date() .And. !lContingencia
    	MsgInfo(STR0386)//"A data de Saída não pode ser inferior a data atual"
		dData := Date()
		oData:SetFocus()
		lReturn := .F.
	ElseIf dData > Date()+3
    	MsgInfo(STR0387)//"A data de Saída não pode ser Superior a 3 dias da data atual"
		dData := Date()
		oData:SetFocus()
		lReturn := .F.
	EndIf

Return lReturn

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpedRGSXml
Função pa amontagem do xml do registro de saida

@author Renato Nagib
@since 20.03.2012
@version 1.00

@param	aNfe			chave e recno da nota fiscal
		dData			data do registro de saida
		cHora			hora do registro de saida
		cVeic			veiculo
		cCar			carreta
		cCar2			carreta2
		cVias			numero de vias do formulario de seguranca
		cSerie			serie do fomulario de seguranca
		cNumero 		numero do formulario de seguranca
		cAlias			Alias da tabela
		lContingencia	Informa se esta em contingencia

@return	cXml -resultado do processamento

/*/
//--------------------------------------------------------------------------------------------
Static Function SpedRGSXml(aNfe,dData,cHora,cVeic,cCar,cCar2,cVias,cSerie,cNumero,cAlias,lContingencia)

	Local cXml	:= ""
	Local cData	:= ""
	Local nX	:= 0

	cData := dToS(dData)
	cData :=Substr(cData,1,4)+"-"+Substr(cData,5,2)+"-"+Substr(cData,7,2)
	dbSelectArea("DA3")
	DA3->(dbSetOrder(1))

	If DA3->(dbSeek(xFilial("DA3")+cVeic))
		cVeic:=AllTrim(DA3->DA3_PLACA)+"-"+AllTrim(DA3->DA3_ESTPLA)
	EndIf

	If DA3->(dbSeek(xFilial("DA3")+cCar))
		cCar:=AllTrim(DA3->DA3_PLACA)+"-"+AllTrim(DA3->DA3_ESTPLA)
	EndIf

	If DA3->(dbSeek(xFilial("DA3")+cCar2))
		cCar2:=AllTrim(DA3->DA3_PLACA)+"-"+AllTrim(DA3->DA3_ESTPLA)
	EndIF

	cXml+='<envEvento>'
	cXml+='<eventos>'

	For nX:=1 To Len(aNfe)
		cXml+='<detEvento>'
		cXml+='<tpEvento>110999</tpEvento>'
		cXml+='<chNFe>'+Alltrim(aNfe[nX][1])+'</chNFe>'
		cXml+='<dataSaida>'+cData+'</dataSaida>'
		cXml+='<horaSaida>'+cHora+'</horaSaida>'

		If !Empty(cVeic)
			cXml+='<placaVeiculo>'+cVeic+'</placaVeiculo>'
		EndIf

		If !Empty(cCar)
			cXml+='<placaCarreta>'+cCar+'</placaCarreta>'
		EndIf

		If !Empty(cCar2)
			cXml+='<placaCarreta2>'+cCar2+'</placaCarreta2>'
		EndIF

		If lContingencia
			cXml+='<numeroFormularioSeguranca>'+cNumero+'</numeroFormularioSeguranca>'
			cXml+='<serieFormularioSeguranca>'+cSerie+'</serieFormularioSeguranca>'
			cXml+='<quantidadeVias>'+cVias+'</quantidadeVias>'
		EndIf

		cXml+='</detEvento>'
	Next
	cXml+='</eventos>'
	cXml+='</envEvento>'

Return cXml


//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedRGSMnt
Função que monitora os o registro de saida

@author Renato Nagib
@since 20.03.2012
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedRGSMnt(cAlias,nReg,nOpc)

	Local aPerg		:= {}
	Local aListBox 	:= {}
	Local aParam	:={Space(3),Space(09),Space(09)}
	Local aSize		:= MsAdvSize()
	Local aObjects	:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aArea		:=GetArea()
	Local cIdEnt	:= ""
	Local cIdEvento	:= IIF (cAlias == "SF2",(cAlias)->F2_IDCCE,(cAlias)->F1_IDCCE)
	Local cParRGSMnt:= SM0->M0_CODIGO+SM0->M0_CODFIL+"RGSMnt"
	Local dEmissao	:= DtoC(IIF(cAlias == "SF2",(cAlias)->F2_EMISSAO,(cAlias)->F1_EMISSAO))
	Local cChvIni	:= ""
	Local cChvFin	:= ""
	Local cWhere	:= ""
	Local cAliasTemp:=GetNextAlias()
	Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
	Local oWS
	Local oDlg
	Local oListBox
	Local oBtn1
	Local oBtn2
	Local oBtn3
	Local oBtn4

	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParRGSMnt,aPerg,1,aParam[01]),If(lSdoc,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE)))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParRGSMnt,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParRGSMnt,aPerg,3,aParam[03]),Len(SF2->F2_DOC))

	// Verifica se a entidade foi configurada
	If IsReady()

		cIdEnt := GetIdEnt()

		If !Empty(cIdEnt)

			aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
			aadd(aPerg,{1,STR0011,aParam[02],"",,"",".T.",30,.F.})	//"Nota fiscal inicial"
			aadd(aPerg,{1,STR0012,aParam[03],"",,"",".T.",30,.F.}) 	//"Nota fiscal final"

			If ParamBox(aPerg,"SPED - RGS",aParam,,,,,,,cParRGSMnt,.T.,.T.)


				If cAlias == "SF2"
					If lSdoc
						cWhere += "%F2_FILIAL='"+xFilial("SF2")+"' AND F2_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F2_SDOC = '"+MV_PAR01+"' AND F2_IDRGS <> ' '%"
					Else
						cWhere += "%F2_FILIAL='"+xFilial("SF2")+"' AND F2_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F2_SERIE = '"+MV_PAR01+"' AND F2_IDRGS <> ' '%"
					EndIf

					BeginSql Alias cAliasTemp
						SELECT	MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
						FROM %Table:SF2%
						WHERE %Exp:cWhere% AND
						%notdel%
					EndSql
			    ElseIf cAlias == "SF1"

					If lSdoc
						cWhere += "%F1_FILIAL='"+xFilial("SF1")+"' AND F1_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F1_SDOC = '"+MV_PAR01+"' AND F1_IDRGS <> ' '%"
					Else
						cWhere += "%F1_FILIAL='"+xFilial("SF1")+"' AND F1_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F1_SERIE = '"+MV_PAR01+"' AND F1_IDRGS <> ' '%"
					EndIf

					BeginSql Alias cAliasTemp
						SELECT	MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
						FROM %Table:SF1%
						WHERE %Exp:cWhere% AND
						%notdel%
					EndSql
			    EndiF

				(cAliasTemp)->(dbGotop())

				If (cAliasTemp)->(Eof())
					MsgInfo(STR0398)//"Nenhum registro à monitorar "
					Return nil
				EndIf

				If cAlias == "SF2"
					SF2->(dbGoTo((cAliasTemp)->RECINI))
					cChvIni := SF2->F2_CHVNFE
					SF2->(dbGoTo((cAliasTemp)->RECFIN))
					cChvFin := SF2->F2_CHVNFE
				ElseIf cAlias == "SF1"
					SF1->(dbGoTo((cAliasTemp)->RECINI))
					cChvIni := SF1->F1_CHVNFE
					SF1->(dbGoTo((cAliasTemp)->RECFIN))
					cChvFin := SF1->F1_CHVNFE
				EndIF
				(cAliasTemp)->(dbCloseArea())
				RestArea(aArea)


				aListBox := SpedWsRGSMnt(cChvIni,cChvFin,cAlias)

				If !Empty(aListBox)

					AAdd( aObjects, { 100, 100, .t., .t. } )
					AAdd( aObjects, { 100, 015, .t., .f. } )
					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )

					DEFINE FONT oBold BOLD
					//DEFINE MSDIALOG oDlg TITLE STR0285+cCadastro FROM aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL//Monitor Capa de Lote-
					DEFINE MSDIALOG oDlg TITLE "SPED - RGS" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

					@010,010 LISTBOX oListBox 	FIELDS HEADER "",STR0050,STR0362,STR0295,STR0364,STR0393,STR0399,STR0400 SIZE 617,406 PIXEL OF oDlg	//"Protocolo ID Evento Ambiente Status do Evento mensagem  StausCanc Mensagem Canc"

			        oListBox:SetArray(aListBox)
			        oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;//legenda
			        						Alltrim(aListBox[oListBox:nAt][02]),;//protocolo
			        						Alltrim(aListBox[oListBox:nAt][03]),;//id evento
											Alltrim(Str(aListBox[oListBox:nAt][04])),;//ambiente
											Alltrim(aListBox[oListBox:nAt][05]),;//status evento
											Alltrim(aListBox[oListBox:nAt][06]),;//mensagem
											Alltrim(aListBox[oListBox:nAt][07]),;//Status canc
											Alltrim(aListBox[oListBox:nAt][08])}}//mensagem can											}}


					@ 390,535 BUTTON oBtn1 PROMPT STR0118		ACTION (aListBox := SpedWsRGSMnt(cChvIni,cChvFin,cAlias),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					@ 390,490 BUTTON oBtn3 PROMPT "Historico"	ACTION Aviso("SPED",aListBox[oListBox:nAt][09],{STR0114}) OF oDlg PIXEL SIZE 035,011 //"OK"
					@ 390,580 BUTTON oBtn2 PROMPT STR0294		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"

					ACTIVATE MSDIALOG oDLg CENTERED

				EndIf
	        EndIF
		EndIf

	Else

		Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

	EndIf

Return

 //-----------------------------------------------------------------------
/*/{Protheus.doc} SpedWsRGSPar
Função que executa os webservices de consulta da CC-e

@author Renato Nagib
@since 20.03.2012
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function SpedWsRGSMnt(cChvIni,cChvFin,cAlias)


	Local aArea			:= GetArea()
	Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
	Local oNo			:= LoadBitMap(GetResources(), "DISABLE")
	Local aListBox		:= {}
	Local cURL     		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local lOk      		:= .T.
	Local cIdEnt		:= GetIdEnt()
	Local nRegSF2		:= 0
	Local cAliasSF2		:= GetNextAlias()
	Local nX			:= 0
	Local nOpcUpd		:= 0
	Private oXmlCCe
	Private oDados
	Private oWS			:= Nil

	If IsReady()

		// Executa o metodo NfeRetornaEvento()
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cEVENTO		:="110999"
		oWS:cCHVINICIAL	:= cChvIni
		oWS:cCHVFINAL	:= cChvFin
		lOk:=oWS:NFEMONITORLOTEEVENTO()

		If lOk

			// Tratamento do retorno do evento
			If Type("oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento") <> "U"

				If Valtype(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "A"
					aMonitor := {oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento}
				Else
					aMonitor := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
				EndIF

				For nX:=1 To Len(aMonitor)
					AADD( aListBox, {	If(aMonitor[nX]:nStatus <> 6 .And. aMonitor[nX]:nStatus <> 7 ,oNo,oOk),;
										If(aMonitor[nX]:nProtocolo <> 0 ,Alltrim(Str(aMonitor[nX]:nProtocolo)),""),;
										aMonitor[nX]:cId_Evento,;
										aMonitor[nX]:nAmbiente,;
										Alltrim(Str(aMonitor[nX]:nStatus)),;
										aMonitor[nX]:cMensagem,;
										If(Type("aMonitor["+Str(nX)+"]:nStatusCanc")	<> "U",Alltrim(Str(aMonitor[nX]:nStatusCanc))  ,""),;
										If(Type("aMonitor["+Str(nX)+"]:cMensagemCanc") <> "U",aMonitor[nX]:cMensagemCanc,""),;
										aMonitor[nX]:cCMotEven})
					//Atualizacao do Status do registro de saida
					nOpcUpd := 0
					If aListBox[nX][5]		== "3" .Or. aListBox[nX][5] == "5"
						nOpcUpd :=	3
					ElseIf aListBox[nX][5] == "6"  .And. Empty(aListBox[nX][7])
						nOpcUpd := 2
					ElseIf aListBox[nX][7] == "1"
						nOpcUpd := 4
					ElseIf aListBox[nX][7] == "3"
						nOpcUpd := 5
					ElseIf aListBox[nX][7] == "2"
						nOpcUpd := 6
					EndIF

					cIdEven := aMonitor[nX]:cId_Evento
					If cAlias == "SF2"
						BeginSql Alias cAliasSF2
							SELECT R_E_C_N_O_
							FROM %Table:SF2%
							WHERE F2_IDRGS = %Exp:aMonitor[nX]:cId_Evento%
						EndSql

				    ElseIf cAlias == "SF1"
						BeginSql Alias cAliasSF2
							SELECT R_E_C_N_O_
							FROM %Table:SF1%
							WHERE F1_IDRGS = %Exp:aMonitor[nX]:cId_Evento%
						EndSql
				    EndiF

					If (cAliasSF2)->(!Eof())
						nRegSF2 :=(cAliasSF2)->R_E_C_N_O_

						If nOpcUpd > 0
							SpedAtuEvento(nOpcUpd,nRegSF2,cIdEven,cAlias,"110999")
						EndIF
					EndIf
					(cAliasSF2)->(dbCloseArea())
					cAliasSF2:=GetNextAlias()
				Next
                RestArea(aArea)
		   Else
			   Aviso("SPED",STR0106,{STR0114})
		   EndIF

		Else

			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)

		EndIf

	Else

		Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

	EndIf

Return(aListBox)

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedRGSLeg
Função que demonstra a legenda das cores da mbrowse

@author Renato nagib
@since 20.03.2012
@version 1.00

@param	Nil

/*/
//-----------------------------------------------------------------------
Function SpedRGSLeg()

Local aLegenda := {}

AADD(aLegenda, {"DISABLE"		,STR0354})//NF nao vinculada
AADD(aLegenda, {"BR_AZUL"		,STR0401})//Evento Transmitido
AADD(aLegenda, {"BR_CINZA"		,STR0402})//Evento rejeitado
AADD(aLegenda, {"ENABLE"		,STR0353}) //NF vinculada
AADD(aLegenda, {"BR_LARANJA"	,STR0403})//Evento cancelado
AADD(aLegenda, {"BR_PRETO"		,STR0404})//"Cancelemanto rejeitado
AADD(aLegenda, {"BR_AMARELO"	,STR0405})//Cancelamento autorizado

BrwLegenda(cCadastro,STR0117,aLegenda)

Return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedCancRGS
Função que demonstra a legenda das cores da mbrowse

@author Renato nagib
@since 20.03.2012
@version 1.00

@param	cAlias	Alias corrente
		nReg	recno atual
		nOpc opcao da MarkBrowse

@return		nil
/*/
//-----------------------------------------------------------------------

Function SpedCancRGS(cAlias,nReg,nOpc)

	Local aArea			:= GetArea()
	Local aNfe			:= {}
	Local aTexto		:= {}
	Local aPerg			:= {}
	Local aParam   		:={Space(3),Space(09),Space(09)}
	local aCfgCCe		:= {}
	Local cRetorno  	:= ""
	Local cAmbiente		:= ""
	Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cVerLayout	:= "1.00"
	Local cIdEnt		:= ""
	Local cAliasTemp		:= GetNextAlias()
	Local cWhere		:= ""
	Local cTexto		:= ""
	Local cParRGSCan	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"RGSCan"
	local cError		:= ""
	Local lOk			:= .T.
	Local lContingencia	:= .F.
	Local lSdoc     := TamSx3("F2_SERIE")[1] == 14

	Local nX			:= 0

	Local oWs
	Local oWizard

	// Verifica se a entidade foi configurada e o limite por eventos
	If IsReady()


		MV_PAR01 := aParam[01] := PadR(ParamLoad(cParRGSCan,aPerg,1,aParam[01]),If(lSdoc,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE)))
		MV_PAR02 := aParam[02] := PadR(ParamLoad(cParRGSCan,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
		MV_PAR03 := aParam[03] := PadR(ParamLoad(cParRGSCan,aPerg,3,aParam[03]),Len(SF2->F2_DOC))


		aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.T.})	//"Serie da Nota Fiscal"
		aadd(aPerg,{1,STR0011,aParam[02],"",,"",".T.",30,.T.})	//"Nota fiscal inicial"
		aadd(aPerg,{1,STR0012,aParam[03],"",,"",".T.",30,.T.}) 	//"Nota fiscal final"


		If ParamBox(aPerg,"SPED - RGS",aParam,,,,,,,cParRGSCan,.T.,.T.)
			If cAlias == "SF2"
				cSelect:="%R_E_C_N_O_ AS REC,F2_CHVNFE AS CHAVE_NFE%"

				If lSdoc
					cWhere += "%F2_FILIAL='"+xFilial("SF2")+"' AND F2_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F2_SDOC = '"+MV_PAR01+"' AND F2_CODRGS='S'%"
				Else
					cWhere += "%F2_FILIAL='"+xFilial("SF2")+"' AND F2_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F2_SERIE = '"+MV_PAR01+"' AND F2_CODRGS='S'%"
				EndIf

				BeginSql Alias cAliasTemp
					SELECT	%Exp:cSelect%
					FROM %Table:SF2%
					WHERE %Exp:cWhere% AND
					%notdel%
				EndSql
		    ElseIf cAlias == "SF1"
				cSelect := "%R_E_C_N_O_ AS REC,F1_CHVNFE AS CHAVE_NFE%"

				If lSdoc
					cWhere += "%F1_FILIAL='"+xFilial("SF1")+"' AND F1_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F1_SDOC = '"+MV_PAR01+"' AND F1_CODRGS='S'%"
				Else
					cWhere += "%F1_FILIAL='"+xFilial("SF1")+"' AND F1_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND F1_SERIE = '"+MV_PAR01+"' AND F1_CODRGS='S'%"
				EndIf

				BeginSql Alias cAliasTemp
					SELECT	%Exp:cSelect%
					FROM %Table:SF1%
					WHERE %Exp:cWhere% AND
					%notdel%
				EndSql
		    EndiF

			(cAliasTemp)->(dbGotop())

			If (cAliasTemp)->(Eof())
				MsgInfo(STR0406)
				Return nil
			EndIf

			While (cAliasTemp)->(!Eof())
				AADD(ANfe,{(cAliasTemp)->CHAVE_NFE,(cAliasTemp)->REC})
				(cAliasTemp)->(dbSkip())
			End

			(cAliasTemp)->(dbCloseArea())
			RestArea(aArea)

			// Obtem o codigo da entidade
			cIdEnt := GetIdEnt()

			If !Empty(cIdEnt)

				If cVersaoTSS < "2.07"
					// Obtem o ambiente de configuracao
					oWS:=WsSpedCfgNfe():New()
					oWS:cUSERTOKEN 	  	:= "TOTVS"
					oWS:cID_ENT    		:= cIdEnt
					oWS:nAMBIENTECCE	:= 0
					oWS:cVERCCELAYOUT	:= "1.00"
					oWS:cVERCCELAYEVEN	:= "1.00"
					oWS:cVERCCEEVEN		:= "1.00"
					oWS:cVERCCE			:= "1.00"
					oWS:cHORAVERAOCCE	:= "2-Nao"
					oWS:cHORARIOCCE		:= "2-Brasilia"
					oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"

					aCfgCCe := getCfgCCe(@cError, cIdEnt)
					lOk:= empty(cError)

					If lOk
						// Ambiente
						If Valtype(aCfgCCe[1]) <> "U"
							cAmbiente := aCfgCCe[1]
						Else
							cAmbiente := STR0349	//"2-Homologacao"
						EndIf
					EndIf
				EndIf

				If lOk

					// Montagem da Interface
					aadd(aTexto,{})
					aTexto[1] := STR0407+" "//"Esta rotina tem como objetivo auxilia-lo na transmissão do cancelamento do registro de saida Eletrônico para o serviço Totvs Services SPED."

					If cVersaoTSS < "2.07"
						aTexto[1] += STR0374+CRLF+CRLF//"Totvs Services SPED está operando com a seguinte configuração: "
						aTexto[1] += STR0015+cAmbiente+CRLF	//"Ambiente: "
					EndIf

					aadd(aTexto,{})

					DEFINE FONT oBold BOLD

					DEFINE WIZARD oWizard ;
						TITLE STR0408;//"Assistente para transmissão do cancelamento do registro de saída eletrônico"
						MESSAGE STR0379;//"Siga atentamente os passos para a configuração do registro de saída."
						TEXT aTexto[1] ;
						NEXT {|| .T.} ;
						FINISH {||.T.}

					CREATE PANEL oWizard ;
						HEADER STR0408; //"Assistente para transmissão do cancelamento do registro de saída eletrônico";
						MESSAGE "";
						BACK {|| .T.} ;
						NEXT {|| Processa({|lEnd| cRetorno := SpedRGSCanc(aNfe,@cTexto)}),.T.} ;
						PANEL

						@ 015,005 SAY STR0409 SIZE 250,10 PIXEL  FONT oBold OF oWizard:oMPanel[2]	//"Motivo do cancelamento"
						@ 025,005 GET cTexto MEMO VALID SpedRgsTexto(@cTexto) SIZE 275,100 PIXEL OF oWizard:oMPanel[2]

					CREATE PANEL oWizard  ;
						HEADER STR0378;//Assistente de transmissão do registro de saída eletrônico
						MESSAGE "";
						BACK {|| .T.} ;
						FINISH {|| .T.} ;
						PANEL

					@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]

					ACTIVATE WIZARD oWizard CENTERED
			   EndIf

			EndIf
       EndIf

	Else

		If nLimite >= 20

			Aviso("SPED",STR0372,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

		Else

			Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

		Endif

	EndIf

Return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedRGSCanc
Função que demonstra a legenda das cores da mbrowse

@author Renato nagib
@since 20.03.2012
@version 1.00

@param	aNfe	dados da NFe
				aNfe[X][1]	Recno da nota
				aNfe[X][2]	Chave da Nfe
		cMotivo	motivo do cancelamento


@return	cRetorno	retorno com a mensagem do cancelamento
/*/
//-----------------------------------------------------------------------
Static Function SpedRGSCanc(aNfe,cMotivo)

	Local cXml      := ""
	Local cIdEven	:= ""
	Local cRetorno  := ""
	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cHoraIni	:= Time()
	Local cErro		:= ""
	Local cIdEnt	:= ""
	Local cAlias	:=Alias()
	Local dDataIni	:= Date()
	Local lRetorno	:= .F.
	Local nEnvio	:= 0
	Local nRegSF2	:= 0
	Local nX		:= 0

	// Verifica se a entidade foi configurada
	If IsReady()

		// Obtem o codigo da entidade
		cIdEnt := GetIdEnt()

		// Chamado do metodo e envio
		oWs:= WsNFeSBra():New()
		oWs:cUserToken	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

		For nx:=1 To Len(aNfe)
			// Monta o Xml
			cXml+='<cancelarSaida>'
			cXml+='<cancelaSaida>'
			cXml+='<saidasNfe>'
			cXml+='<chaveAcesso>'+aNfe[nX][1]+'</chaveAcesso>'
			cXml+='<motivo>'+cMotivo+'</motivo>'
			cXml+='</saidasNfe>'
			cXml+='</cancelaSaida>'
			cXml+='</cancelarSaida>'

			oWs:oWSXMLCANCREGSAIDA:cXml		:= cXml
	        cXml:=""
			If oWs:CancelarRegistroSaida()
				If Type("oWS:oWsCancelarRegistroSaidaResult") <> "U" .And. !Empty(oWS:oWsCancelarRegistroSaidaResult)
					cResult:=Alltrim(oWS:oWsCancelarRegistroSaidaResult:CNFE_CHV)
					nPos:=aScan(aNfe,{ |X| Alltrim(X[1]) == cResult} )
					If nPos > 0
						SpedAtuEvento(4,aNfe[nX][2],cResult,cAlias,"110999")
						nEnvio++
					EndIf

					lRetorno:= .T.
				Endif
			Else
				lRetorno:= .F.
				cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			Endif

			Delclassintf()
		Next

		If lRetorno
			If nEnvio == Len(aNfe)
				cRetorno := STR0026+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
				cRetorno += STR0410+CRLF+CRLF //"Verifique se o evento foi cancelado na SEFAZ, utilizando a rotina 'Monitor'."
				cRetorno += Left(STR0360,16)+cValToChar(nEnvio)+Substr(STR0360,16)+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foi transmitido 0/1 evento em "
			ElseIF nEnvio < Len(aNfe)
				cRetorno := STR0411+CRLF
				cRetorno += Left(STR0360,16)+cValToChar(nEnvio)+Substr(STR0360,16)+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foi transmitido 0/1 evento em "
			EndIF
		Else
			cRetorno := STR0030+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
			cRetorno += cErro
		EndIf

	Else

		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

	Endif

Return(cRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedRGSTexto
Função para formatacao do texto do motivo do cancelamento

@author Renato nagib
@since 20.03.2012
@version 1.00

@param	cTexto	texto a ser formatado

@return	Nil
/*/
//-----------------------------------------------------------------------
Static Function SpedRGSTexto(cTexto)

	// Tratamento do Texto para correcao da carta
	cTexto := Alltrim(cTexto)
	cTexto := StrTran(cTexto,Chr(10),"")
	cTexto := StrTran(cTexto,Chr(13),"")

	If Len(cTexto) > 1000
		cTexto := Left(cTexto,1000)
	Endif

Return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} ExecWSRet
Executa um método validando seu retorno.

@param		oWS		Objeto do serviço.
@param		cMetodo	Nome do método a ser invocado.

@return		nil

@author		Marcos Taranta
@since		24/05/2012
@version	11.7
/*/
//-----------------------------------------------------------------------
Function ExecWSRet( oWS, cMetodo )

Local bBloco	:= {||}

Local lRetorno	:= .F.

Private oWS2

DEFAULT oWS		:= NIL
DEFAULT cMetodo	:= ""

If ( ValType(oWS) <> "U" .And. !Empty(cMetodo) )

	oWS2 := oWS

	If ( Type("oWS2") <> "U" )
		bBloco 	:= &("{|| oWS2:"+cMetodo+"() }")
		lRetorno:= eval(bBloco)

		If ( lRetorno == NIL )
			lRetorno := .F.
		EndIf

	EndIf

EndIf

Return lRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} SPEDRastro2
Funcao criada para retornar para matxfis a informação da UF e aliquota da
nota original de entrada quando o produto possuir rastro por sublote

@param		cNumLote	Número do SubLote.
@param		cLoteClt	Número do lote.
@param 		cProduto    Codigo do produto
@param 		nBaseIcm	Base de ICMS (como referencia)
@param 		nValICM		Valor do ICMS (como referencia)
@param		lFCI		Se atende Ajuste SINIEF 12/2012 (FCI)
@param 		cCodFCI		Número da FCI da SD1(como referencia)
@param 		lCalcMed	Se será efetuado o cálculo da Base e ICMS ST pela média
@param 		nAlqICM		Alíquota do ICMS
@param 		nAlqII		Alíquota do Imposto de Importação
@param 		lLei2741	INdica se a função foi chamada para processar a lei da transparência.

@return		nil

@author		Natalia Sartori
@since		27/02/2012
@version	11.7
/*/
//----------------------------------------------------------------------
Function SPEDRastro2(cNumLote,cLoteCtl,cProduto,nBaseIcm,nValICM,lFCI,cCodFCI,lCalcMed,nAlqICM, nAlqII,lLei2741,cCodOrig,cCstICMS,nAliqSTMe,nTotSai,cQntSai,nValSTMe,nValST,nValII,nBfcpant,nAfcpant,nVfcpant,cArmazem)
Local aArea		 := GetArea()
Local aRetRastro	:= {}

Local cSeek		:= ""
Local cSeek1	:= ""
Local cAliasSFT	:= GetNextAlias()
Local cAliasSD5	:= GetNextAlias()
Local cItem		:= ""
Local cNumCQ		:= ""
Local cLocCQ    := PADR(SuperGetMV("MV_CQ"),TAMSX3("D7_LOCAL")[1])  //adequo o conteudo padrão "98" para "98 "
Local cNfiscal	:= ""
Local cSerie		:= ""
Local cCliFor		:= ""
Local cLoja		:= ""
Local cLoteRastro	:= ""
Local lRastroNF := .F.
Local cLoteQry := ""


Default cCodFCI	:= ""
Default lFCI	:= .F.
Default lCalcMed:= .F.
DEFAULT nAlqICM	:= 0
DEFAULT nAlqII	:= 0
DEFAULT lLei2741:= .F.
DEFAULT cCodOrig := ""
DEFAULT cCstICMS := ""
DEFAULT nAliqSTMe := 0
DEFAULT nTotSai	:= 0
DEFAULT cQntSai  	:= ""
DEFAULT nValSTMe := 0
DEFAULT nValST  	:= 0
DEFAULT nValII  	:= 0
DEFAULT nBfcpant	:= 0
DEFAULT nAfcpant	:= 0
DEFAULT nVfcpant	:= 0
DEFAULT cArmazem	:= ""

	If Empty(cArmazem)
		dbSelectArea("SB1")
		dbSetOrder(1)
		MsSeek(xFilial("SB1")+cProduto)
		If SB1->(FieldPos("B1_LOCPAD"))>0
			cArmazem:= SB1->B1_LOCPAD
		EndIf
	EndIf


	dbSelectArea("SB8")
	dbSetOrder(2)
	If MsSeek(xFilial("SB8")+cNumLote+cLoteCtl+cProduto)

		//Tratamento SD7 para integracao com sigaquality
		dbSelectArea("SD7")
		SD7->(dbSetOrder(1))
		cNumCQ := PADR(SB8->B8_DOC,LEN(SD7->D7_NUMERO))
		If SD7->(MsSeek(SB8->B8_FILIAL+cNumCQ+cProduto+cLocCQ))
			cNfiscal	:= SD7->D7_DOC
			cSerie 	:= SD7->D7_SERIE
			cCliFor	:= SD7->D7_FORNECE
			cLoja 		:= SD7->D7_LOJA
		Else
			//Validações chamado TQWWGC - Nestle
			If FindFunction("RastroToNF") .And. Len(aRetRastro := RastroToNF(cLoteCtl,cNumLote,cProduto,cArmazem)) > 0

				cNfiscal	:= aRetRastro[1][1]
				cSerie		:= aRetRastro[1][2]
				cCliFor		:= aRetRastro[1][3]
				cLoja		:= aRetRastro[1][4]
				cLoteRastro := aRetRastro[1][8]
				lRastroNF	:= .T.

				if 	cLoteRastro <> cLoteCtl
					//Posiciona no lote original, para pegar os valores corretos
					SB8->(MsSeek(xFilial("SB8")+cNumLote+cLoteRastro+cProduto))
				endif				
			Else
				cNfiscal	:= SB8->B8_DOC
				cSerie		:= SB8->B8_SERIE
				cCliFor		:= SB8->B8_CLIFOR
				cLoja 		:= SB8->B8_LOJA
			EndIf
		EndIf

		cSeek	:= cCliFor+cLoja+cSerie+cNfiscal
		If lRastroNF
			cSeek1	:= cNfiscal+cSerie+cCliFor+cLoja+cProduto+cLoteRastro+cNumLote
		Else
			cSeek1	:= cNfiscal+cSerie+cCliFor+cLoja+cProduto+cLoteCtl+cNumLote
		EndIf

	EndIf
	cLoteQry := Iif(lRastroNF, cLoteRastro, cLoteCtl)

	If lFCI
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				BeginSql Alias cAliasSD5
					SELECT D5_NUMLOTE
						FROM %Table:SD5% SD5
						WHERE
						SD5.D5_FILIAL = %xFilial:SD5% AND
						SD5.%NotDel% AND
						D5_PRODUTO	=%Exp:cProduto% AND
						D5_CLIFOR	=%Exp:cCliFor% AND
						D5_LOJA		=%Exp:cLoja% AND
						D5_LOTECTL = %Exp:cLoteQry%
				EndSql

				If (cAliasSD5)->(!Eof())
					cNumLote	:=(cAliasSD5)->D5_NUMLOTE
					cSeek1		:= cNfiscal+cSerie+cCliFor+cLoja+cProduto+cLoteCtl+cNumLote
				EndIf
				(cAliasSD5)->(DBCLOSEAREA())
			Else
		#ENDIF
				DbSelectArea("SD5")
				SD5->(DbSetOrder(2))
				SD5->(MsSeek(xFilial("SD5")+cProduto))
				While !SD5->(Eof()) .And. SD5->D5_FILIAL==xFilial("SD5") .And. SD5->D5_CLIFOR==cCliFor .And. SD5->D5_LOJA==cLoja
					cNumLote	:= SD5->D5_NUMLOTE
					cSeek1		:= cNfiscal+cSerie+cCliFor+cLoja+cProduto+cLoteCtl+cNumLote
					SD5->(dbSkip())
				End
		#IFDEF TOP
			EndIf
		#ENDIF

	EndIf

	dbSelectArea("SD1")
	dbSetOrder(11)

	If !Empty(cSeek1) .AND. MsSeek(xFilial("SD1")+cSeek1)
		If lFCI
		   cItem:= SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM+cProduto
		   If SD1->(FieldPos("D1_FCICOD"))<>0
		   		cCodFCI:= SD1->D1_FCICOD
		   		cCodOrig := Substr(SD1->D1_CLASFIS,1,1)
		   EndIf
		Else
			If !Empty (SD1->D1_BASNDES) .AND. !Empty (SD1->D1_ICMNDES)
				nBaseIcm   := (SD1->D1_BASNDES / SB8->B8_QTDORI)
				nValICM    := (SD1->D1_ICMNDES / SB8->B8_QTDORI)
				nAlqICM    := SD1->D1_ALQNDES
				
			Else
				If !Empty (SD1->D1_BRICMS) .AND. !Empty (SD1->D1_VALANTI)
					nBaseIcm   := (SD1->D1_BRICMS / SB8->B8_QTDORI)
					nValICM    := (SD1->D1_VALANTI / SB8->B8_QTDORI)
					nAlqICM    := SD1->D1_ALIQSOL
				
				
				ElseIf	!Empty (SD1->D1_BRICMS) .AND. !Empty (SD1->D1_ICMSRET)
					nBaseIcm   := (SD1->D1_BRICMS / SB8->B8_QTDORI)
					nValICM    := (SD1->D1_ICMSRET / SB8->B8_QTDORI)
					nAlqICM    := SD1->D1_ALIQSOL			
				Endif	
			Endif
		EndIf

        	nBfcpant   := IIf(SD1->(ColumnPos("D1_BFCPANT")) > 0,SD1->D1_BFCPANT,0)/SB8->B8_QTDORI
        	nAfcpant   := IIf(SD1->(ColumnPos("D1_AFCPANT")) > 0,SD1->D1_AFCPANT,0)
        	nVfcpant   := IIf(SD1->(ColumnPos("D1_VFCPANT")) > 0,SD1->D1_VFCPANT,0)/SB8->B8_QTDORI
       
            If  nBfcpant == 0 .and.  nAfcpant == 0 .and.  nVfcpant == 0
            	nBfcpant   := IIf(SD1->(ColumnPos("D1_BSFCPST")) > 0,SD1->D1_BSFCPST,0)/SB8->B8_QTDORI
            	nAfcpant   := IIf(SD1->(ColumnPos("D1_ALFCPST")) > 0,SD1->D1_ALFCPST,0)
        		nVfcpant   := IIf(SD1->(ColumnPos("D1_VFECPST")) > 0,SD1->D1_VFECPST,0)/SB8->B8_QTDORI
            Endif
       
		IF lLei2741 .AND. !Empty(cSeek1)
          IF cCstICMS = '60'
		      //nAlqICM = 100*(D1_ICMSRET / D1_BRICMS)  //  Calculo da aliquota do ICM
		      //  Calculo da aliquota do ICMS RETIDO
		      nAlqICM :=  ( ( (D1_ICMSRET / D1_QUANT ) * cQntSai   ) / nTotSai) * 100
		      nValST	:= ( (D1_ICMSRET / D1_QUANT ) * cQntSai   )
		      nAlqII     := SD1->D1_ALIQII
		      nValII	   := SD1->D1_II
		   ELSE
   	         nAlqICM    := SD1->D1_PICM
		      nValST	   := SD1->D1_ICMSRET
			  nAlqII     := SD1->D1_ALIQII
			  nValII	   := SD1->D1_II
   		   ENDIF
		Endif
	EndIf



		IF !lLei2741 //Quando a função for chamada para lei da transparência, não será necessáro buscar SFT.
			If !lFCI
				If Len (cSeek)>0 .AND. nBaseIcm==0 .AND. nValICM==0 .And. SF4->F4_ART274 == "1"

					BeginSql Alias cAliasSFT
						SELECT FT_BASERET,FT_ICMSRET,FT_PRODUTO,FT_ALQNDES,FT_VALANTI,FT_ALIQSOL,FT_BFCPANT,FT_AFCPANT,FT_VFCPANT,FT_BSFCPST,FT_ALFCPST,FT_VFECPST
							FROM %Table:SFT% SFT
							WHERE
							SFT.FT_FILIAL = %xFilial:SFT% AND
							SFT.%NotDel% AND
							FT_NFISCAL	=%Exp:cNfiscal% AND
							FT_SERIE  	=%Exp:cSerie% AND
							FT_TIPOMOV	=%Exp:"E" % AND
							FT_CLIEFOR	=%Exp:cCliFor% AND
							FT_LOJA	=%Exp:cLoja% AND
							FT_ITEM	=%Exp:SD1->D1_ITEM% AND
							FT_PRODUTO	=%Exp:cProduto%
					EndSql
					
					If (cAliasSFT)->(!Eof())
						
						If (cAliasSFT)->FT_BASERET > 0 .And. (cAliasSFT)->FT_VALANTI > 0
							nBaseIcm:=(cAliasSFT)->FT_BASERET/SB8->B8_QTDORI
					 		nValICM	:=(cAliasSFT)->FT_VALANTI/SB8->B8_QTDORI
					 		nAlqICM	:=(cAliasSFT)->FT_ALIQSOL
						
						ElseIf (cAliasSFT)->FT_BASERET > 0 .And. (cAliasSFT)->FT_ICMSRET > 0
							nBaseIcm:=(cAliasSFT)->FT_BASERET/SB8->B8_QTDORI
					 		nValICM	:=(cAliasSFT)->FT_ICMSRET/SB8->B8_QTDORI
					 		nAlqICM := iIf((cAliasSFT)->FT_ALQNDES > 0,(cAliasSFT)->FT_ALQNDES,(cAliasSFT)->FT_ALIQSOL)
						EndIf
						
						nBfcpant   := IIf((cAliasSFT)->(ColumnPos("FT_BFCPANT")) > 0,(cAliasSFT)->FT_BFCPANT,0)/SB8->B8_QTDORI
						nAfcpant   := IIf((cAliasSFT)->(ColumnPos("FT_AFCPANT")) > 0,(cAliasSFT)->FT_AFCPANT,0)
						nVfcpant   := IIf((cAliasSFT)->(ColumnPos("FT_VFCPANT")) > 0,(cAliasSFT)->FT_VFCPANT,0)/SB8->B8_QTDORI	
						
						If  nBfcpant == 0 .and.  nAfcpant == 0 .and.  nVfcpant == 0
							nBfcpant   := IIf((cAliasSFT)->(ColumnPos("FT_BSFCPST")) > 0,(cAliasSFT)->FT_BSFCPST,0)/SB8->B8_QTDORI
							nAfcpant   := IIf((cAliasSFT)->(ColumnPos("FT_ALFCPST")) > 0,(cAliasSFT)->FT_ALFCPST,0)
							nVfcpant   := IIf((cAliasSFT)->(ColumnPos("FT_VFECPST")) > 0,(cAliasSFT)->FT_VFECPST,0)/SB8->B8_QTDORI
						EndIf
					
					EndIf
					
					(cAliasSFT)->(DBCLOSEAREA())

				Else
					dbSelectArea("SFT")
					dbSetOrder(4)
					If MsSeek(xFilial("SFT")+"E" + cSeek)
						If SFT->FT_BASERET > 0 .and. SFT->FT_VALANTI > 0
							nBaseIcm   := (SFT->FT_BASERET / SB8->B8_QTDORI)
					 		nValICM	:= (SFT->FT_VALANTI/SB8->B8_QTDORI)
					 		nAlqICM	:= (SFT->FT_ALIQSOL) 
						
						ElseIf SFT->FT_BASERET > 0 .And. SFT->FT_ICMSRET > 0
							nBaseIcm   := (SFT->FT_BASERET / SB8->B8_QTDORI)
							nValICM    := (SFT->FT_ICMSRET / SB8->B8_QTDORI)
							nAlqICM := iIf(SFT->FT_ALQNDES > 0,SFT->FT_ALQNDES,SFT->FT_ALIQSOL)
						EndIf
						
						nBfcpant   := IIf(SFT->(ColumnPos("FT_BFCPANT")) > 0,SFT->FT_BFCPANT,0)/SB8->B8_QTDORI
						nAfcpant   := IIf(SFT->(ColumnPos("FT_AFCPANT")) > 0,SFT->FT_AFCPANT,0)
						nVfcpant   := IIf(SFT->(ColumnPos("FT_VFCPANT")) > 0,SFT->FT_VFCPANT,0)/SB8->B8_QTDORI		
						
						If  nBfcpant == 0 .and.  nAfcpant == 0 .and.  nVfcpant == 0
							nBfcpant   := IIf(SFT->(ColumnPos("FT_BSFCPST")) > 0,SFT->FT_BSFCPST,0)/SB8->B8_QTDORI
							nAfcpant   := IIf(SFT->(ColumnPos("FT_ALFCPST")) > 0,SFT->FT_ALFCPST,0)
							nVfcpant   := IIf(SFT->(ColumnPos("FT_VFECPST")) > 0,SFT->FT_VFECPST,0)/SB8->B8_QTDORI	
						EndIf
					EndIf
				EndIf
			Else
				dbSelectArea("SFT")
				dbSetOrder(1)
				If MsSeek(xFilial("SFT")+"E" + cItem )
					
					If SFT->FT_BASERET > 0  .and. SFT->FT_VALANTI > 0
						nBaseIcm   := (SFT->FT_BASERET / SB8->B8_QTDORI)
					 	nValICM	:= (SFT->FT_VALANTI/SB8->B8_QTDORI)
					 	nAlqICM	:= (SFT->FT_ALIQSOL) 
					 ElseIf SFT->FT_BASEICM > 0 .And. SFT->FT_ICMSRET > 0
						nBaseIcm   := (SFT->FT_BASEICM / SB8->B8_QTDORI)
						nValICM    := (SFT->FT_ICMSRET / SB8->B8_QTDORI)
						nAlqICM := iIf(SFT->FT_ALQNDES > 0,SFT->FT_ALQNDES,SFT->FT_ALIQSOL)
					EndIf	
				
					nBfcpant   := IIf(SFT->(ColumnPos("FT_BFCPANT")) > 0,SFT->FT_BFCPANT,0)/SB8->B8_QTDORI
					nAfcpant   := IIf(SFT->(ColumnPos("FT_AFCPANT")) > 0,SFT->FT_AFCPANT,0)
					nVfcpant   := IIf(SFT->(ColumnPos("FT_VFCPANT")) > 0,SFT->FT_VFCPANT,0)/SB8->B8_QTDORI		
						
					If  nBfcpant == 0 .and.  nAfcpant == 0 .and.  nVfcpant == 0
						nBfcpant   := IIf(SFT->(ColumnPos("FT_BSFCPST")) > 0,SFT->FT_BSFCPST,0)/SB8->B8_QTDORI
						nAfcpant   := IIf(SFT->(ColumnPos("FT_ALFCPST")) > 0,SFT->FT_ALFCPST,0)
						nVfcpant   := IIf(SFT->(ColumnPos("FT_VFECPST")) > 0,SFT->FT_VFECPST,0)/SB8->B8_QTDORI	
					EndIf
				EndIf
			EndIf
		EndIF 

	If lCalcMed .And. !lFCI
		CalcMedia(Iif((cLoteRastro <> cLoteCtl).And. lRastroNF,cLoteRastro,cLoteCtl),cProduto,@nBaseIcm,@nValICM,@nAliqSTMe,cQntSai, nTotSai,@nValSTMe,@nBfcpant,@nAfcpant,@nVfcpant)
	Endif

RestArea(aArea)
Return()

//-----------------------------------------------------------------------
/*/{Protheus.doc} TSSAtuSX6
Atualiza parametros do SX6

@param		[1] - Ambiente
			[2] - Modalidade
			[3] - Versao
			[4] - Contingencia
			[5] - Tempo de espera

@return		nil

@author		Sergio S. Fuzinaka
@since		15.05.2013
@version	11.7
/*/
//-----------------------------------------------------------------------
Static Function TSSAtuSX6( aParam )

// Ambiente da NFC-e
If !PutMv("MV_AMBNFCE",Substr(Alltrim(aParam[1]),1,1))
	SX6->(RecLock("SX6",.T.))
	SX6->X6_FIL		:= xFilial("SX6")
	SX6->X6_VAR		:= "MV_AMBNFCE"
	SX6->X6_TIPO	:= "C"
	SX6->X6_DESCRIC	:= "Ambiente da NFC-e"
	SX6->X6_CONTEUD	:= Substr(Alltrim(aParam[1]),1,1)
	SX6->X6_CONTSPA	:= Substr(Alltrim(aParam[1]),1,1)
	SX6->X6_CONTENG	:= Substr(Alltrim(aParam[1]),1,1)
	SX6->X6_PROPRI	:= "S"
	SX6->X6_PYME	:= "S"
	SX6->(MsUnLock())
EndIf

// Modalidade da NFC-e
If !PutMv("MV_MODNFCE",Substr(Alltrim(aParam[2]),1,1))
	SX6->(RecLock("SX6",.T.))
	SX6->X6_FIL		:= xFilial("SX6")
	SX6->X6_VAR		:= "MV_MODNFCE"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Modalidade da NFC-e"
	SX6->X6_CONTEUD := Substr(Alltrim(aParam[2]),1,1)
	SX6->X6_CONTSPA := Substr(Alltrim(aParam[2]),1,1)
	SX6->X6_CONTENG := Substr(Alltrim(aParam[2]),1,1)
	SX6->X6_PROPRI	:= "S"
	SX6->X6_PYME	:= "S"
	SX6->(MsUnLock())
EndIf

// Versao da NFC-e
If !PutMv("MV_VERNFCE",Alltrim(aParam[3]))
	SX6->(RecLock("SX6",.T.))
	SX6->X6_FIL		:= xFilial("SX6")
	SX6->X6_VAR		:= "MV_VERNFCE"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Versao da NFC-e"
	SX6->X6_CONTEUD := Alltrim(aParam[3])
	SX6->X6_CONTSPA := Alltrim(aParam[3])
	SX6->X6_CONTENG := Alltrim(aParam[3])
	SX6->X6_PROPRI	:= "S"
	SX6->X6_PYME	:= "S"
	SX6->(MsUnLock())
EndIf

Return Nil
//-----------------------------------------------------------------------
/*/{Protheus.doc} CalcMedia
Funcao criada para que seja possível realizar o cálculo pela média da Base
do ICMS ST e do ICMS ST cobrado anteriormente por Substituição Tributária

@param		cLoteClt	Número do lote.
@param 		cProduto    Codigo do produto
@param 		nBaseIcm	Base de ICMS (como referencia)
@param 		nValICM		Valor do ICMS (como referencia)

@return		nil

@author		Simone dos Santos de Oliveira
@since		03/09/2013
@version	11.7
/*/
//-----------------------------------------------------------------------
Function CalcMedia(cLoteCtl,cProduto,nBaseIcm,nValICM,nAliqSTMe,cQntSai, nTotSai, nValSTMe,nBfcpant,nAfcpant,nVfcpant)

Local aAreaSFT  := SFT->(GetArea())

Local nBsIcmsST := 0
Local nIcmsST	:= 0
Local nCont	:= 0
Local nBase	:= 0
Local nICM		:= 0
Local nAliqSTMe :=0

Local cAliasSD1	:= GetNextAlias()
Local cField := ""

DEFAULT nTotSai	:= 0
DEFAULT cQntSai := ""
DEFAULT nValSTMe := 0
DEFAULT nBfcpant := 0
DEFAULT nAfcpant := 0
DEFAULT nVfcpant := 0

//Inclusão de campos na query
cField := "%"

If SD1->(ColumnPos("D1_BASNDES"))<>0
	cField  +=",D1_BASNDES"
EndIf

If SD1->(ColumnPos("D1_ICMNDES"))<>0
	cField  +=",D1_ICMNDES"
EndIf

If SD1->(ColumnPos("D1_BFCPANT"))<>0
	cField  +=",D1_BFCPANT"
EndIf

If SD1->(ColumnPos("D1_AFCPANT"))<>0
	cField  +=",D1_AFCPANT"
EndIf

If SD1->(ColumnPos("D1_VFCPANT"))<>0
	cField  +=",D1_VFCPANT"
EndIf

If SD1->(ColumnPos("D1_BSFCPST"))<>0
	cField  +=",D1_BSFCPST"
EndIf

If SD1->(ColumnPos("D1_ALFCPST"))<>0
	cField  +=",D1_ALFCPST"
EndIf

If SD1->(ColumnPos("D1_VFECPST"))<>0
	cField  +=",D1_VFECPST"
EndIf

cField += "%"

BeginSql Alias cAliasSD1
         SELECT D1_DOC,D1_SERIE,D1_QUANT, D1_FORNECE, D1_LOJA, D1_ITEM,D1_II , D1_BASEICM ,D1_ICMNDES, D1_COD %Exp:cField%
         FROM %Table:SD1% SD1
         WHERE
         SD1.D1_FILIAL = %xFilial:SD1% AND
         SD1.%NotDel% AND
         D1_COD =%Exp:cProduto % AND
         D1_LOTECTL =%Exp:cLoteCtl %
EndSql


(cAliasSD1)->(DBGOTOP())

nBfcpant := 0
nAfcpant := 0
nVfcpant := 0

While (cAliasSD1)->(!Eof())
      If ((cAliasSD1)->(ColumnPos("D1_BASNDES")) > 0 .And. (cAliasSD1)->D1_BASNDES > 0) .And. ((cAliasSD1)->(ColumnPos("D1_ICMNDES")) > 0 .And. (cAliasSD1)->D1_ICMNDES > 0)
         nBase   :=(cAliasSD1)->D1_BASNDES/(cAliasSD1)->D1_QUANT
         nICM    :=(cAliasSD1)->D1_ICMNDES/(cAliasSD1)->D1_QUANT

         nBsIcmsST += nBase
         nIcmsST   += nICM
        
          	nBfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_BFCPANT")) > 0,(cAliasSD1)->D1_BFCPANT,0) /(cAliasSD1)->D1_QUANT
          	nAfcpant   := IIf((cAliasSD1)->(ColumnPos("D1_AFCPANT")) > 0,(cAliasSD1)->D1_AFCPANT,0)
          	nVfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_VFCPANT")) > 0,(cAliasSD1)->D1_VFCPANT,0) /(cAliasSD1)->D1_QUANT
          	
          	If  nBfcpant == 0 .and.  nAfcpant == 0 .and.  nVfcpant == 0
          		nBfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_BSFCPST")) > 0,(cAliasSD1)->D1_BSFCPST,0) /(cAliasSD1)->D1_QUANT
          		nAfcpant   := IIf((cAliasSD1)->(ColumnPos("D1_ALFCPST")) > 0,(cAliasSD1)->D1_ALFCPST,0)
          		nVfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_VFECPST")) > 0,(cAliasSD1)->D1_VFECPST,0) /(cAliasSD1)->D1_QUANT 
            EndIf


         nCont++
      Else
         SFT->(dbSetOrder(1))
         // FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
         If SFT->(MsSeek(xFilial("SFT")+"E"+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM+(cAliasSD1)->D1_COD))

            If SFT->FT_BASERET <> 0
            	nBase   := (SFT->FT_BASERET / (cAliasSD1)->D1_QUANT)
            	nICM    := (SFT->FT_ICMSRET / (cAliasSD1)->D1_QUANT)

            	nBsIcmsST += nBase
 			 	nIcmsST    += nICM
            Endif



            If (cAliasSD1)->D1_II <> 0
			     //nBase   :=(cAliasSD1)->D1_II /(cAliasSD1)->D1_QUANT
		         //nICM    :=(cAliasSD1)->D1_ICMNDES/(cAliasSD1)->D1_QUANT

		        nBase   :=(cAliasSD1)->D1_BASEICM /(cAliasSD1)->D1_QUANT
		        nICM   :=(cAliasSD1)->D1_II /(cAliasSD1)->D1_QUANT
		        nBsIcmsST  += nBase
		        nIcmsST    += nICM
            Endif
            
            	nBfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_BFCPANT")) > 0,(cAliasSD1)->D1_BFCPANT,0) /(cAliasSD1)->D1_QUANT
		  		nAfcpant   := IIf((cAliasSD1)->(ColumnPos("D1_AFCPANT")) > 0,(cAliasSD1)->D1_AFCPANT,0)
				nVfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_VFCPANT")) > 0,(cAliasSD1)->D1_VFCPANT,0) /(cAliasSD1)->D1_QUANT
            
               	If  nBfcpant == 0 .and.  nAfcpant == 0 .and.  nVfcpant == 0
               		nBfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_BSFCPST")) > 0,(cAliasSD1)->D1_BSFCPST,0) /(cAliasSD1)->D1_QUANT
               		nAfcpant   := IIf((cAliasSD1)->(ColumnPos("D1_ALFCPST")) > 0,(cAliasSD1)->D1_ALFCPST,0)
               		nVfcpant   += IIf((cAliasSD1)->(ColumnPos("D1_VFECPST")) > 0,(cAliasSD1)->D1_VFECPST,0) /(cAliasSD1)->D1_QUANT
          		EndIf
            nCont++

         EndIf
      EndIf
     (cAliasSD1)->(dbSkip())
EndDo


(cAliasSD1)->(DBCLOSEAREA())

//Realiza o cálculo médio
If nBsIcmsST > 0 .And. nIcmsST > 0
	nBaseIcm := (nBsIcmsST / nCont)
	nValICM  := (nIcmsST / nCont)

      //Tratamento Lei Transparência
    If !Empty(cQntSai) .And. nTotSai > 0
    	nAliqSTMe := ( (nValICM * cQntSai   ) / nTotSai) * 100
    	nValSTMe  :=  nValICM
    EndIf
EndIf

If nBfcpant > 0 .And. nVfcpant > 0
	nBfcpant := (nBfcpant / nCont)
	nVfcpant := (nVfcpant / nCont)
EndIf

RestArea(aAreaSFT)
Return()



//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedEpecPar
Função que parametriza o Protheus para o evento CTE EPEC, Carta de Correcao e Cancelamento

@Fabio Marchiori Sampaio
@since 07.11.2013
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedEpecPar()

Local oWs
Local aPerg  	:= {}
Local aParam 	:= {"","","","","","",""}
local aCfgCCe	:= {}
local aCfgEpecCTe := {}
Local aCombo1	:= {}	//Ambiente
Local aCombo2	:= {}	//VersaoGeralEPEC
Local aCombo3	:= {}	//VersaoEvenEPEC
Local aCombo4	:= {}	//VersaoGeralCanc
Local aCombo5	:= {}	//VersaoEvenCanc
Local aCombo6	:= {}	//Versao CC-e
Local aCombo7	:= {}	//Versao Evento CC-e
Local aCombo8	:= {}	//Horario de verao: 1-Sim###2-Nao
Local aCombo9	:= {}	//Horario: 1-Fernando de Noronha###2-Brasilia###3-Manaus
Local aCombo10 := {}	//Versão Evento Desacordo
Local aCombo11 := {}	//Versão Evento Desacordo

Local cCombo1	:= STR0349	//"2-Homologacao"
Local cCombo2	:= "2.00"
Local cCombo3	:= "2.00"
Local cCombo4	:= "2.00"
Local cCombo5	:= "2.00"
Local cCombo6	:= "2.00"
Local cCombo7	:= "2.00"
Local cCombo8	:= "1"
Local cCombo9	:= "2"
Local cCombo10:= "3.00"
Local cCombo11:= "3.00"
Local cIdEnt 	:= ""
Local cURL   	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
local cError	:= ""
Local cParEPECPar:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDEPECPAR"
Local lOkCCe	:= .F.
Local lAdminNfe  := GetNewPar("MV_ADMNFE",.T.)
Local lUsaColab := UsaColaboracao("2")

// Ambiente
AADD(aCombo1,STR0348)	//"1-Producao"
AADD(aCombo1,STR0349)	//"2-Homologacao"

// Versao Geral EPEC
AADD(aCombo2,"2.00")
AADD(aCombo2,"3.00")

// Versao Evento EPEC
AADD(aCombo3,"2.00")
AADD(aCombo3,"3.00")

// Versao Geral Cancelamento
AADD(aCombo4,"2.00")
AADD(aCombo4,"3.00")

// Versao Evento de Cancelamento
AADD(aCombo5,"2.00")
AADD(aCombo5,"3.00")

// Versao CC-e
AADD(aCombo6,"2.00")
AADD(aCombo6,"3.00")

// Versao Evento CC-e
AADD(aCombo7,"2.00")
AADD(aCombo7,"3.00")

// Horario de verao
AADD(aCombo8,"1-Sim")
AADD(aCombo8,"2-Nao")

// Horario
AADD(aCombo9,"1-Fernando de Noronha")
AADD(aCombo9,"2-Brasilia")
AADD(aCombo9,"3-Manaus")
AADD(aCombo9,"4-Acre")
// Versao Geral Desacordo
AADD(aCombo10,"3.00")
// Versao Evento Desacordo
AADD(aCombo11,"3.00")

if lUsaColab
	//REALIZA A CONFIGURAÇÃO DOS PARAMETRO DO TOTVS COLABORAÇÃO 3.0
	if ( lAdminNfe .And. PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0 ) .Or. !lAdminNfe
		ColParametros( "CCE" )
	else
		Help( "", 1, "SEMPERM" )
	endif
Else
	If ( !lAdminNfe .or. PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0 )

		If IsReady()

			// Obtem o codigo da entidade
			cIdEnt := GetIdEnt()

			// Obtem aVersao do CTe
			cVersaoCTe := getCfgVersao(@cError, cIdEnt, "57")
			lOk := empty(cError)


			// Obtem aVersao Epec do CTe
			aCfgEpecCTe := getCfgEpecCte()
			lOk := empty(cError)

			// Utilizado o embiente do CCe
			// Pela necessidade de se acessar o mesmo parametro de ambiente da NFe
			aCfgCCe := getCfgCCe(@cError, cIdEnt)
			lOkCCe := empty(cError)

			If lOk .And. lOkCCe

				// Ambiente
				If Valtype(aCfgCCe[1]) <> "U"
					cCombo1 := aCfgCCe[1]
				Else
					cCombo1 := STR0349	//"2-Homologacao"
				EndIf

				If Valtype(aCfgEpecCTe[1]) <> "U"
					cCombo2 :=  aCfgEpecCTe[1]
				EndIf

				If Valtype(aCfgEpecCTe[2]) <> "U"
					cCombo3 := aCfgEpecCTe[2]
				EndIf

				If Valtype(aCfgEpecCTe[3]) <> "U"
					cCombo4 := aCfgEpecCTe[3]
				EndIf

				If Valtype(aCfgEpecCTe[4]) <> "U"
					cCombo5 := aCfgEpecCTe[4]
				EndIf

				If ValType(aCfgEpecCTe[5]) <> "U"
					cCombo6	:= aCfgEpecCTe[5]
				Else
					cCombo6	:= "2.00"
				EndIf

				If ValType(aCfgEpecCTe[6]) <> "U"
					cCombo7	:= aCfgEpecCTe[6]
				Else
					cCombo7	:= "2.00"
				EndIf

				If ValType(aCfgEpecCTe[12]) <> "U"
					cCombo8	:= aCfgEpecCTe[12]
				Else
					cCombo8	:= "2-Nao"
				EndIf

				// Horario
				If ValType(aCfgEpecCTe[11]) <> "U"
					cCombo9	:= Substr(aCfgEpecCTe[11], 1, 1)
				Else
					cCombo9	:= "2"
				EndIf
				If ValType(aCfgEpecCTe[13]) <> "U"
					cCombo10	:= aCfgEpecCTe[13]
				Else
					cCombo10	:= "3.00"
				EndIf

				If ValType(aCfgEpecCTe[14]) <> "U"
					cCombo11	:= aCfgEpecCTe[14]
				Else
					cCombo11	:= "3.00"
				EndIf

				AADD(aPerg,{2,STR0035,cCombo1,aCombo1,120,".T.",.T.,".T."}) //"Ambiente"

				If !FwIsInCallStack("MATA103")
					AADD(aPerg,{2,STR0461,cCombo2,aCombo2,120,".T.",.T.,".T."}) //""Versão do leiaute EPEC"
					AADD(aPerg,{2,STR0462,cCombo3,aCombo3,120,".T.",.T.,".T."}) //"Versão do evento EPEC"
					AADD(aPerg,{2,STR0463,cCombo4,aCombo4,120,".T.",.T.,".T."}) //"Versão do leiaute Canc"
					AADD(aPerg,{2,STR0464,cCombo5,aCombo5,120,".T.",.T.,".T."}) //"Versão do evento de Canc."
					AADD(aPerg,{2,STR0361,cCombo6,aCombo6,120,".T.",.T.,".T."}) //"Versão CC-e"
					AADD(aPerg,{2,STR0352 + " CC-e",cCombo7,aCombo7,120,".T.",.T.,".T."}) //"Versão do evento CC-e"
				Endif

				AADD(aPerg,{2,STR0369,cCombo8,aCombo8,120,".T.",.T.,".T."}) //"Horario de Verao"
				AADD(aPerg,{2,STR0370,Val(cCombo9),aCombo9,120,".T.",.T.,".T."}) //"Horario"
				AADD(aPerg,{2,STR0352 + " Geral Desacordo",cCombo10,aCombo10,120,".T.",.T.,".T."}) //"Versão do evento Desacordo"
				AADD(aPerg,{2,STR0352 + " Desacordo",cCombo11,aCombo11,120,".T.",.T.,".T."}) //"Versão do evento Desacordo"

				If !FwIsInCallStack("MATA103")
					aParam := {cCombo1, cCombo2, cCombo3, cCombo4, cCombo5, cCombo6, cCombo7, cCombo8, cCombo9, cCombo10,cCombo11}
				Else
					aParam := {cCombo1, cCombo8, cCombo9, cCombo10,cCombo11}
				Endif

				If ParamBox(aPerg,"Eventos",aParam,,,,,,,cParEPECPar,.T.,.F.)

					//Configuração do Epec CTe
					If !FwIsInCallStack("MATA103")
						getCfgEpecCte(@cError, cIdEnt, aParam[2], aParam[3], aParam[4], aParam[5], aParam[6], aParam[7], "", "", 0, aParam[8], aParam[9],aParam[10],aParam[11])
					Else
						getCfgEpecCte(@cError, cIdEnt,,,,,,,"","",0,aParam[2],aParam[3],aParam[4],aParam[5])
					Endif

				EndIf
			EndIf

		Else

			Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

		EndIf
	Else
		Help( "", 1, "SEMPERM" )
	EndIf
EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} TransCanc
Função de envio do Cancelamento da NFe ao TSS

@Natalia Sartori
@since 09.12.2013
@version 1.00

@param	aNotas 		[1] Conteudo do campo F3_ENTRADA
               		[2] Conteudo do campo F3_SERIE
               		[3] Conteudo do campo F3_NFISCAL
		       		[4] Conteudo do campo F3_ESPECIE
		       		[5] Conteudo do campo F3_CODRSEF
		aRetorno	Retorna o range de NFe transmitidas
		lAutoNF	Identifica se esta sendo chamado por Rotina Automatica
/*/
//-----------------------------------------------------------------------
Function TransCanc(aNotas , aRetorno , lAutoNF, lCTe)

Local aRetCol		:= {}
Local aHist      	:= {}
Local aHistRet		:= {}
Local aRetorno		:= {}
Local aNFeCol		:= {}
Local cAmbiente		:= ""
Local cAviso		:= ""
Local cLabelEven	:= ""
Local cDoc			:= ""
Local cErro			:= ""
Local cError		:= ""
Local cIdEnt		:= ""
Local cMod			:= ""
Local cTipoMov		:= "1"
Local cModalidade	:= ""
Local cModelo		:= ""
Local cSerie		:= ""
Local cTpEvento		:= "110111"
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cXJust		:= ""
Local lCancela		:= .F.
Local lCancOk		:= .F.
Local lInutiliza	:= .F.
Local lNfeCancEven	:= GetNewPar("MV_NFECAEV",.T.)	//-- Cancelamento de NF-e por Evento
Local lOk			:= .F.
Local lUsaColab		:= .F.
Local lArqGer		:= .F.
Local lXjust		:= GetNewPar("MV_INFXJUS","") == "S"
Local nX			:= 0
Local nY			:= 0
Local nz			:= 0
Local oDoc
Local oWs

Default lCTe := .F.

	cMod			:= IIF(lCTe, "CTE", "NFE")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preparando variaveis para validações do ambiente de cancelamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lUsaColab		:= UsaColaboracao( IIF(lCte,"2","1") )
	cIdEnt 			:= GetIdEnt(lUsaColab)
	//-------------------------------------------------------------------
	/*
						[1] Conteudo do campo F3_ENTRADA
						[2] Conteudo do campo F3_SERIE
						[3] Conteudo do campo F3_NFISCAL
						[4] Conteudo do campo F3_ESPECIE
						[5] Conteudo do campo F3_CODRSEF
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TOTVS Colaboracao                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaColab
		cModelo := IIf(cMod=="NFE","55","57")
		oDoc := ColaboracaoDocumentos():new()
		oDoc:cModelo 	:= IIf(cModelo=="55","NFE",IIf(cModelo=="57","CTE",""))
		oDoc:cTipoMov	:= cTipoMov
		For nX:=1 to Len(aNotas)
			cXjust 		:= ""
			cSerie		:= aNotas[nX][2]
			cDoc		:= aNotas[nX][3]
			cMod	 	:= IIf(cModelo == "55","NFE","CTE")
			cIdErp 	:= aNotas[nX][2] + aNotas[nX][3] + FwGrpCompany()+FwCodFil()
			aHist:= {}
			aAdd (aHist, FwCodFil())
			aAdd (aHist, cMod	)
			aAdd (aHist, cTipoMov)
			aAdd (aHist,cIdErp)
			aInfXml	:= ColExpDoc(cSerie , cDoc , cMod )
			aHistRet := GetHistCKQ (cIdErp,aHist)


			If aInfXml[1] //Consta documento
				//Chave | Xml Autorizado
				If ( !Empty(aInfXml[2]) .And. !Empty(aInfXml[3]) .And. aInfXml[8] $ "100")
					lCancela := .T.
					// Xml Cancelamento | Xml Inutilizacao = Se retornado nao pode transmitir o cancelamento/inutilizacao porque ja foi transmitido
				ElseIf !Empty(aInfXml[4]) .Or. !Empty(aInfXml[6])
					lCancela := .F.
					// Contingencia = Quando eh retornado CSTAT igual a "1" eh retornado a chave do Documento para realizar o Cancelamento
				Elseif (!Empty(aInfXml[2]) .And. Empty(aInfXml[3]) .And. Empty(aInfXml[4]) .And. Empty(aInfXml[5]) .And. Empty(aInfXml[6]) )
					lCancela 	:= .F.
					lInutiliza	:= .F.
					// Rejeitado = Documento transmitido e rejeitado
				Else
					lInutiliza := .T.
				EndIf
				//Inutilizacao
			Else
				lInutiliza := .T.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Justificativa do cancelamento MV_INFXJUS = S                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInutiliza
			    cAviso	:= 'Inutilizacao de NF-e como Evento'
				cXjust := "Motivo de inutilizacao nota " + cSerie + "-" + cDoc
			ElseIf lCancela
				cAviso	:= 'Cancelamento de NF-e como Evento'
				cXjust := "Motivo de cancelamento nota " + cSerie + "-" + cDoc
			EndIF
			IF  ((aHistRet[1][2]) .And. ('2' $ aHistRet[1][8]))
				If lXjust
				cLabelEven := iif(lInutiliza,"Inutilização de NF-e como Evento","Cancelamento de NF-e como Evento")
					While .T.
					If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 3,cLabelEven,,, .T.) == 1
							If SpedCCeTexto(cXjust,250)
								lGera := .T.
								Exit
							Else
								Loop
							Endif
						Else
						lGera := .F. // Cancelada a operação de cancelamento
							Exit
						Endif
					Enddo
				Else
					lGera := .T.
				EndIf
				If lGera

					If lCancela .Or. lInutiliza
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Adicionando no aNFe para manter o padrao das funcoes SpedCCeXml e ColEnvEvento³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aNFeCol := {}
						aAdd(aNFeCol,aInfXml[2]) 				//01 - Chave da Nfe
						aAdd(aNFeCol,"")			 				//02 - em branco
						aAdd(aNFeCol,cSerie) 					//03 - Serie
						aAdd(aNFeCol,cDoc) 						//04 - Numero
						oDoc:cNomeArq := "" 		// Limpando o nome do Arq. pois sera criado outro arquivo.
						If lCancela
							cXml := SpedCCeXml( aNFeCol , cXjust , cTpEvento , aInfXml[7] , , , , lCte )
						lArqGer := ColEnvEvento( cMod , aNFeCol , cXml ,  , @cErro )
						If lArqGer
								lCancOk := ColAtuTrans( /*cEntSai*/ , cSerie, cDoc ,/*cCliente*/,/*cLoja*/,/*lCTe*/,/*cChvCtg*/,/*nTpEmisCte*/)
							endif
						ElseIf lInutiliza
							cXml := ColInutTrans( aNFeCol , cXjust , cModelo )
						lArqGer := ColEnvEvento( cMod , aNFeCol , cXml , nil , @cErro , lInutiliza )
						If lArqGer
							lCancOk := ColAtuTrans( /*cEntSai*/ , cSerie, cDoc ,/*cCliente*/,/*cLoja*/,/*lCTe*/,/*cChvCtg*/,/*nTpEmisCte*/)
						EndIf
					EndIF
				EndIF
					conout(cErro) //"004/025 - Mesmo documento ainda está aguardando o processamento, verificar se os arquivos estão sendo processados corretamente."
				EndIf
				conout(cErro)
			EndIF
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ WS - TSS                                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else

		If IsReady()

			//Obtem o ambiente de execucao do TSS
			If !Empty(cIdEnt)
					cAmbiente := getCfgAmbiente(@cError, cIdEnt)
					lOk := empty(cError)


				//Obtem a modalidade de transmissão da NFe
				If lOk
						cModalidade    := getCfgModalidade(@cError, cIdEnt, "55")
						lOk := empty(cError)

				EndIf

				cAmbiente   := SubStr(cAmbiente,1,1)
				cModalidade := SubStr(cModalidade,1,1)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transmite as NFe cancelada                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oWs:= WsNFeSBra():New()
				oWs:cUserToken := "TOTVS"
				oWs:cID_ENT    := cIdEnt
				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
				oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
				If Len(aNotas) > 0
					For nX := 1 To Len(aNotas)

						cModelo := IIF(lAutoNF .And. aNotas[nX][4] == "57", aNotas[nX][4], AModNot(aNotas[nX][4]))

						cXjust := ""
						nY++
						aadd(oWs:oWsNFe:oWsNotas:oWSNFES,NFESBRA_NFES():New())
						oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cID := aNotas[nX][2]+aNotas[nX][3]
						oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= GetUFCode(SM0->M0_ESTCOB)+FsDateConv(aNotas[nX][1],"YYMM")+SM0->M0_CGC+cModelo+StrZero(Val(aNotas[nX][2]),3)+StrZero(Val(aNotas[nX][3]),9)+cModalidade+Inverte(StrZero(Val(SubStr(aNotas[nX][3],2,8)),8))
						oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML:= 'Id="' +	oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML + Modulo11(oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML) + '"'

						If empty(allTrim(aNotas[nX][5]))
							cAviso := allTrim ( "Motivo de inutilizacao nota " + aNotas[nX][2] + " " + aNotas[nX][3])
						Else
							cAviso := allTrim ("Motivo de cancelamento nota " + aNotas[nX][2] + " " + aNotas[nX][3])
						EndIf

						If lXjust .and. aNotas[nX][5] $ "100" .And. cModelo != "57" .And. !lAutoNF  //lAutoNF - so vai entrar aqui se NAO for Rotina Automatica (AutoNfe)
							//-- Tratamento do Cancelamento por Evento
							If lNfeCancEven .And. !(Empty(AllTrim(aNotas[nX][5])) )
								While .T.
									If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 3,"Cancelamento de NF-e como Evento",,, .T.) == 1
										If SpedCCeTexto(cXjust,250)
											oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML += '<xJust>xJust="'+cXjust+'"</xJust>'
											Exit
										Else
											Loop
										Endif
									Else
										Exit
									Endif
								Enddo
							Else
								If Aviso(cAviso, @cXjust, {"Confirmar", "Cancelar"}, 4,,,, .T.) == 1 .And. !Empty(cXjust)
									oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML += '<xJust>xJust="'+cXjust+'"</xJust>'
								Endif
							Endif
						ElseIf ExistBlock("FISCANNFE")
							oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML := ExecBlock("FISCANNFE",.F.,.F.,{oWs:oWsNFe:oWsNotas:oWSNFES[nY]:cXML,aNotas[nX]})
						EndIf
						If nY >=50 .Or. nX == Len(aNotas)
							If oWs:CancelaNotas()
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ aRetorno - eh alimentado com as notas transmitidas para o cancelamento ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If len(Ows:OWsCancelaNotasResult:OwsId:cString) > 0
									For nZ:= 1 To len(Ows:OWsCancelaNotasResult:OwsId:cString)
										cRetorno := Ows:OWsCancelaNotasResult:OwsId:cString[nZ]
										aadd(aRetorno, cRetorno )
									Next nZ
								EndIf
								oWs:= WsNFeSBra():New()
								oWs:cUserToken := "TOTVS"
								oWs:cID_ENT    := cIdEnt
								oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
								oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
								nY := 0
								lCancOk := .T.
							Else
								Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
							EndIf
						EndIf
					Next nX
				EndIf
			EndIf
		EndIf
	EndIf

Return lCancOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} ChamaMonit
Função de monitoramento de notas

@Natalia Sartori
@since 09.12.2013
@version 1.00

@param	aInfNotas 	Array contendo as seguintes posições:
					[1] Série
					[2] Número nota inicial
					[3] Número nota final
@Return aListBox    Array com o retorno do monitoramento
/*/
//-----------------------------------------------------------------------
Function ChamaMonit(aInfNotas,nTpMonitor,cModelo, lCte, lMsg, lMDFe, lTMS)

local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local aRetNotas		:= {}
Local cIdEnt		:= ""
Local lUsaColab		:= .F.
Default cModelo 	:= '55'
Default nTpMonitor	:=  1
Default lMsg		:= .T.
Default lCTE		:= .F.
Default lMDFe		:= .F.
Default lTMS		:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preparando variaveis para validações do ambiente de cancelamento       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lUsaColab		:= UsaColaboracao( IIF(lCte,"2","1") )
cIdEnt 		:= GetIdEnt(lUsaColab)
//-------------------------------------------------------------------
	If Len(aInfNotas) > 0
		If IsReady(,,,lUsaColab)
				If lUsaColab
					//aRetNotas := colNfeMonProc( aInfNotas, nTpMonitor, cModelo, lCTE,.T., lMDfe, lTMS ,lUsaColab )
					aRetNotas := getListBox(cIdEnt, cUrl, aInfNotas, nTpMonitor, cModelo, lCTE, lMsg, lMDFe, lTMS,lUsaColab)
				else
					aRetNotas := getListBox(cIdEnt, cUrl, aInfNotas, nTpMonitor)
				endif
	EndIf
EndIf

Return aRetNotas

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpedCCeCTe
Função que transmite carta de correcao para CTe

@author Fabio Marchiori Sampaio
@since 28.11.2013
@version 1.00

@param	cXml

@return	cRetorno -resultado do processamento

/*/
//--------------------------------------------------------------------------------------------
Function SpedCCeCTe(cXml, aCTe)

	Local cRetorno  := ""
	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cHoraIni	:= Time()
	Local cErro		:= ""
	Local cIdEnt	:= ""
	Local dDataIni	:= Date()
	Local lRetorno	:= .F.
	Local nEnvio	:= 0
	Local cAlias	:= "SF2"
	Local cIdEven	:= ""

	// Verifica se a entidade foi configurada
	If IsReady(,,,lUsaColab)

		// Obtem o codigo da entidade
		cIdEnt := GetIdEnt(lUsaColab)

		If !Empty(cIdEnt)

			If lUsaColab
				If ColEnvEvento("CCE",aCte,cXml,@cIdEven,@cErro,,,.T.)
					SpedAtuEvento(1,aCte[2],cIdEven,cAlias)
					nEnvio++
					lRetorno:= .T.
				EndIf
			Else
				// Chamado do metodo e envio
				oWs:= WsNFeSBra():New()
				oWs:cUserToken	:= "TOTVS"
				oWs:cID_ENT		:= cIdEnt
				oWs:cXML_LOTE	:= cXml
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

				If oWs:RemessaEvento()
					If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
						aRetorno:=oWS:oWsRemessaEventoResult:cString
						SpedAtuEvento(1,aCTe[2],aRetorno[1],cAlias,"110110")
						lRetorno:= .T.
					EndIf
				Else
					lRetorno:= .F.
					cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				Endif
			Endif
		Endif
		If lRetorno
			cRetorno := STR0026+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
			cRetorno += STR0359+CRLF+CRLF //"Verifique se o evento foi vinculado a NF-e na SEFAZ, utilizando a rotina 'Monitor'."
			cRetorno += Left(STR0360,16)+cValToChar(nEnvio)+Substr(STR0360,16)+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foi transmitido 0/1 evento em "
		Else
			If lUsaColab
				cRetorno := "Houve erro durante a transmissão para o Totvs Colaboração 2.0."+CRLF+CRLF
			Else
				cRetorno := STR0030+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
			EndIf
			cRetorno += cErro
		EndIf
		Aviso("SPED",cRetorno,{STR0114},3)
	Else
		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	Endif

Return(lRetorno)

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} retQueryTrans
Retorna a string da query para transmissao dos documentos.

@author Sergio S. Fuzinaka
@since 06/02/2014
@version 12

@param	lAutoNFe		- Novo Auto NF-e
@param	cModelo			- Modelo do documento:	55 - NF-e
														57 - CT-e

@return cQuery			- String da query

/*/
//--------------------------------------------------------------------------------------------
Function retQueryTrans( lAutoNFe, cNotaIni, cNotaFim, cSerie, cModelo, lAutomato )

Local cQuery		:= ""
Local cEspecie		:= ""
local cBanco 			:= Alltrim(Upper(TCGetDb()))
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
local nDias 		:= 60 // Tratamento para performance da query, monitorar apenas 60 dias antes da data-base
local dDatabase	:= Date()
local dDatafil	:= SToD ("  /  /  ")
Default lAutomato := .F.


Default lAutoNFe	:= .F.
Default cModelo		:= "55"
dDatafil := (dDataBase-nDias)

//-- Montagem da query
cQuery := "SELECT F3_FILIAL, F3_ENTRADA, F3_NFELETR, F3_CFO, F3_FORMUL, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, "
cQuery += "F3_LOJA, F3_ESPECIE, F3_DTCANC, F3_OBSERV, F3_CHVNFE, F3_CODNFE "

If lSdoc
	cQuery += ",F3_SDOC"
EndIF

cQuery += "FROM " + RetSqlName("SF3") + " "
cQuery += "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "

If SubStr(cBanco,1,6) == "ORACLE"
	cQuery += "((SUBSTR(F3_CFO,1,1) < '5' AND F3_FORMUL = 'S') OR (SUBSTR(F3_CFO,1,1) >= '5')) AND "
Else
	cQuery += "((SUBSTRING(F3_CFO,1,1) < '5' AND F3_FORMUL = 'S') OR (SUBSTRING(F3_CFO,1,1) >= '5')) AND "
Endif

If lSdoc
	cQuery += "F3_SDOC = '" + cSerie + "' AND "
Else
	cQuery += "F3_SERIE = '" + cSerie + "' AND "
EndIf

If cModelo == "55"
	cEspecie := "SPED"
Else
	cEspecie := "CTE"
Endif

cQuery += "F3_ESPECIE = '" + cEspecie + "' AND "

If lAutoNFe .and. !lAutomato

	If SF3->(FieldPos("F3_CODRET")) > 0
		cQuery += "F3_CODRET = ' ' AND "
	Endif

	If SF3->(FieldPos("F3_CODRSEF")) > 0
		cQuery += "F3_CODRSEF = ' ' AND "
	Endif
   	cQuery += "F3_ENTRADA >= '" + Dtos(dDatafil) + "' AND "
	cQuery += "F3_DTCANC = '" + Space(8) + "' AND "

	If SubStr(cBanco,1,6) == "ORACLE"
		cQuery += "D_E_L_E_T_ = ' ' "
	Else
		cQuery += "D_E_L_E_T_ = ' ' "
	Endif

	cQuery += "ORDER BY F3_NFISCAL"

Else

	cQuery += "F3_NFISCAL >= '" + cNotaIni + "' AND "
	cQuery += "F3_NFISCAL <= '" + cNotaFim + "' AND "
	cQuery += "F3_DTCANC = '" + Space(8) + "' AND "

	If SubStr(cBanco,1,6) == "ORACLE"
		cQuery += "D_E_L_E_T_ = ' ' "
	Else
		cQuery += "D_E_L_E_T_ = ' '"
	Endif

Endif

conout("query transmissao: " + cQuery)

return( cQuery )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodRet
Lê o flag de transmissao Auto NF-e
@author GetCodRet
@author  Cleiton Genuino
@since   02/12/2015
@version 11
/*/
//-------------------------------------------------------------------
static function GetCodRet( aRetNotas , cModelo )
local aArea 		:= GetArea()
local aAreaSF3	:= SF3->(GetArea())
local lGetCodRet 	:= .F.
Local cEspecie	:= ""
default cModelo		:= "55"
	//-------------------------------------------
	// Necessário quando a serie usada não especificada no MV_ESPECIE
	// Neste caso a epecie não é gravada no F3_ESPECIE
	//-------------------------------------------
	If cModelo == "55"
		cEspecie := "SPED"
	Else
		cEspecie := "CTE"
	Endif
If len (aRetNotas) > 0
	If SF3->(FieldPos("F3_CODRET")) > 0
			SF3->( dbSetOrder(4) )//F3_FILIAL, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE,
			If SF3->( dbSeek( xFilial("SF3")+aRetNotas[5]+aRetNotas[6]+aRetNotas[4]+aRetNotas[3] ) )
			If (SF3->F3_CODRET <> "T") .And. ( cEspecie $ 'SPED|CTE' )
					lGetCodRet := .T.
				Endif
			Endif
	Endif
Endif
RestArea( aAreaSF3 )
RestArea( aArea )
return lGetCodRet

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaCodRet
Grava flag de transmissao Auto NF-e

@author  Sergio S. Fuziaka
@since   10/02/2014
@version 12
/*/
//-------------------------------------------------------------------
static function gravaCodRet( aRetNotas )

local aArea 	:= GetArea()
local aAreaSF3	:= SF3->(GetArea())
local lContinua	:= .F.

If SF3->(FieldPos("F3_CODRET")) > 0
	//---------------------------------------------------------
	// Validacao Array
	//---------------------------------------------------------
	if ( len(aRetNotas) > 0 )
		if ( len(aRetNotas[3]) > 0 )
			if ( len(aRetNotas[4]) > 0 )
				if ( len(aRetNotas[5]) > 0 )
					if ( len(aRetNotas[6]) > 0 )
						lContinua := .T.
					endif
				endif
			endif
		endif
	endif
	//---------------------------------------------------------
	// Realizado alteracao para atualizar todos os registros
	// da SF3 para aquele documento.
	// @data: 24/08/2018 @autor: Douglas Parreja
	//---------------------------------------------------------
	if lContinua
	SF3->( dbSetOrder(4) )
		if ( SF3->( dbSeek( xFilial("SF3")+aRetNotas[5]+aRetNotas[6]+aRetNotas[4]+aRetNotas[3])) )
			while ( !SF3->(eof()) .and. ;
				SF3->(F3_CLIEFOR) == aRetNotas[5] .and. ;
					SF3->(F3_LOJA) == aRetNotas[6] .and. ;
						SF3->(F3_NFISCAL) == aRetNotas[4] .and. ;
							SF3->(F3_SERIE) == aRetNotas[3] .and. ;
								alltrim(SF3->F3_CODRET) <> "T" )
				SF3->(recLock("SF3",.F.))
		SF3->F3_CODRET := "T"	// Transmitido
				SF3->(msUnlock())
				SF3->(dbSkip())
			endDo
		endif
	Endif
Endif

RestArea( aAreaSF3 )
RestArea( aArea )

return

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} getListBox
Função que excuta monitorametno e retorna array para o listbox

@author Renato nagib
@since 11.02.2014
@version 1.00

@param		cIdEnt			Entidade do TSS para processamento
			cUrl			endereço do Web Wervice no TSS
			aParam			Parametro para a busca dos docuemtnos no TSS, de acordo com o tipo nTpMonitor
			nTpMonitor		tipo do monitor
			cModelo		modelo do documento
			lCte			indica se o modelo é Cte
			lMsg			habilita exibição de mensagem

@return	aListBox		array para o listBox

/*/
//--------------------------------------------------------------------------------------------
static function getListBox(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, lMsg, lMDfe, lTMS,lUsaColab)

	local aLote			:= {}
	local aListBox			:= {}
	local aRetorno			:= {}
	local cId				:= ""
	local cProtocolo		:= ""
	local cRetCodNfe		:= ""
	local cAviso			:= ""
	local cSerie			:= ""
	local cNota			:= ""

	local nAmbiente		:= ""
	local nModalidade		:= ""
	local cRecomendacao	:= ""
	local cTempoDeEspera	:= ""
	local nTempomedioSef	:= ""
	local nX				:= 0


	local oOk				:= LoadBitMap(GetResources(), "ENABLE")
	local oNo				:= LoadBitMap(GetResources(), "DISABLE")

	local cTenConsInd		:= ""
	local cObsConsInd		:= ""

	default lUsaColab		:= .F.
	default lMsg			:= .T.
	default lCte			:= .F.
	default lMDfe		:= .F.
	default cModelo		:= IIf(lCte,"57",IIf(lMDfe,"58","55"))
	default lTMS			:= .F.

	if cModelo <> "65"
		lUsaColab := UsaColaboracao( IIf(lCte,"2",IIf(lMDFe,"5","1")) )
	endif

	if 	lUsaColab
		//processa monitoramento por tempo
		aRetorno := colNfeMonProc( aParam, nTpMonitor, cModelo, lCte, @cAviso, lMDfe, lTMS ,lUsaColab )
	else
		//processa monitoramento
		aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso)
	endif

	if empty(cAviso)

		for nX := 1 to len(aRetorno)

			cId				:= aRetorno[nX][1]
			cSerie			:= aRetorno[nX][2]
			cNota			:= aRetorno[nX][3]
			cProtocolo		:= aRetorno[nX][4]
			cRetCodNfe		:= aRetorno[nX][5]
			nAmbiente		:= aRetorno[nX][7]
			nModalidade	:= aRetorno[nX][8]
			cRecomendacao	:= aRetorno[nX][9]
			cTempoDeEspera:= aRetorno[nX][10]
			nTempomedioSef:= aRetorno[nX][11]
			aLote			:= aRetorno[nX][12]
			cTenConsInd		:= aRetorno[nX][15]
			cObsConsInd		:= aRetorno[nX][16]

			aadd(aListBox,{	iif(empty(cProtocolo) .Or.  cRetCodNfe $ RetCodDene(),oNo,oOk),;
								cId,;
								if(nAmbiente == 1,STR0056,STR0057),; //"Produção"###"Homologação"
								IIF(lUsaColab,iif(nModalidade==1,STR0058,STR0059),IIf(nModalidade ==1 .Or. nModalidade == 4 .Or. nModalidade == 6,STR0058,STR0059)),; //"Normal"###"Contingência"
								cProtocolo,;
								cRecomendacao,;
								cTempoDeEspera,;
								nTempoMedioSef,;
								aLote,;
								cTenConsInd,;
								cObsConsInd;
							})
		next

	    if Empty(aListBox) .and. lMsg .and. !lCte
	    	Aviso("SPED",STR0106,{STR0114})
	    endIf

	elseif !lCTe .And. lMsg
		aviso("SPED", cAviso,{STR0114},3)
	endif

return aListBox

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpecCharc
Função que retira os caracteres especiais de um texto

@author Leonardo Kichitaro
@since 01.04.2014
@version 1.00

@param	cTexto			Texto para retirar caracteres especiais

@return	cTexto			Texto sem caracteres especiais

/*/
//--------------------------------------------------------------------------------------------
Static Function SpecCharc(cTexto)

Local nI		:= 0
Local aCarac 	:= {}

Aadd(aCarac,{"Á","A"})
Aadd(aCarac,{"À","A"})
Aadd(aCarac,{"Â","A"})
Aadd(aCarac,{"Ã","A"})
Aadd(aCarac,{"á","a"})
Aadd(aCarac,{"à","a"})
Aadd(aCarac,{"â","a"})
Aadd(aCarac,{"ã","a"})
Aadd(aCarac,{"É","E"})
Aadd(aCarac,{"Ê","E"})
Aadd(aCarac,{"é","e"})
Aadd(aCarac,{"ê","e"})
Aadd(aCarac,{"Í","I"})
Aadd(aCarac,{"í","i"})
Aadd(aCarac,{"Ó","O"})
Aadd(aCarac,{"Ô","O"})
Aadd(aCarac,{"Õ","O"})
Aadd(aCarac,{"ó","o"})
Aadd(aCarac,{"ô","o"})
Aadd(aCarac,{"õ","o"})
Aadd(aCarac,{"Ú","U"})
Aadd(aCarac,{"ú","u"})
Aadd(aCarac,{"Ç","C"})
Aadd(aCarac,{"ç","c"})


// Ignora caracteres Extendidos da tabela ASCII
For nI := 128 To 255
	Aadd(aCarac,{Chr(nI)," "})  // Tab
Next nI

For nI := 1 To Len(aCarac)
	If aCarac[nI, 1] $ cTexto
		cTexto := StrTran(cTexto, aCarac[nI,1], aCarac[nI,2])
	EndIf
Next nI

Return cTexto

Function CalcMedII(cLoteCtl,cProduto,nBaseIcm2,nValICM2,nAliqSTMe2)

Local aAreaSFT  := SFT->(GetArea())

Local nBsIcmsST := 0
Local nIcmsST	:= 0
Local nCont	:= 0
Local nBase	:= 0
Local nICM		:= 0
Local nAliqSTMe :=0

Local cAliasSD1	:= GetNextAlias()
Local cField := ""


//Inclusão de campos na query
cField := "%"

If SD1->(FieldPos("D1_BASNDES"))<>0
	cField  +=",D1_BASNDES"
EndIf

If SD1->(FieldPos("D1_ICMNDES"))<>0
	cField  +=",D1_ICMNDES"
EndIf


cField += "%"

BeginSql Alias cAliasSD1
         SELECT D1_DOC,D1_SERIE,D1_QUANT, D1_FORNECE, D1_LOJA, D1_ITEM, D1_II, D1_COD %Exp:cField%
         FROM %Table:SD1% SD1
         WHERE
         SD1.D1_FILIAL = %xFilial:SD1% AND
         SD1.%NotDel% AND
         D1_COD =%Exp:cProduto % AND
         D1_LOTECTL =%Exp:cLoteCtl %
EndSql


(cAliasSD1)->(DBGOTOP())

While (cAliasSD1)->(!Eof())

      nBase   :=(cAliasSD1)->D1_II /(cAliasSD1)->D1_QUANT
      nICM    :=(cAliasSD1)->D1_ICMNDES/(cAliasSD1)->D1_QUANT

      nBsIcmsST += nBase
      nIcmsST   += nICM

      nCont++

     (cAliasSD1)->(dbSkip())
EndDo


//Realiza o cálculo médio O II RETIDO.
If nBsIcmsST > 0
	nBaseIcm2  := (nBsIcmsST / nCont)
    nValICM2  := (nIcmsST / nCont)
    nAliqSTMe2:= SD2->D2_VALICM + SD2->D2_VALIPI + SD2->D2_VALIMP1 +;
                SD2->D2_VALIMP2 + SD2->D2_VALIMP3 + SD2->D2_VALIMP4 +;
                SD2->D2_VALIMP5 + SD2->D2_VALIMP6  //Retirado nValICM2
EndIf



RestArea(aAreaSFT)

(cAliasSD1)->(DBCLOSEAREA())

Return

static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)
//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpecCharc
Função que retorna tipo de transporte aceito pela caa de lote

@author Renato Nagib
@since 12.08.2014
@version 1.00

@param	cTipoTra			tipo do transporte

@return	cRetTpTra		Tipo do transporte valido para capa de lote

/*/
//--------------------------------------------------------------------------------------------
static function getTpTransporte(cTipoTra)

	local cRetTpTra:=""

	cTipoTra := alltrim(cTipoTra)

	do case
		case cTipoTra $ "1|R"
			cRetTpTra := "R"
		case cTipoTra $ "2|AE"
			cRetTpTra := 	"AE"
		case cTipoTra $ "3|AQ"
			cRetTpTra := 	"AQ"
	endCase
return cRetTpTra


static function ModeloColab(cModelo)

	local 	 cModTC := ""
	default cModelo := ""

	if cModelo == "55" .Or. Empty(cModelo)
		cModTC := "1"			// NFE
	elseIf cModelo == "57"
		cModTC := "2"			// CTE
	elseIf cModelo == "58"
		cModTC := "5"			// MDFE

	endIf

return cModTC

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFiltroF3
Função que retorna o pre filtro das NFS quando a base utiliza o conceito _SDOC

@author Fabio V. Santana
@since 05.05.2015
@version 1.00

@param	aParam - Filtro digitado de NFS
@param	lCancel - Retorna Notas canceladas

@return	cSerMax - Serie Maxima

/*/
//--------------------------------------------------------------------------------------------
Static Function GetFiltroF3(aParam,lCancel,dDataDe,dDataAte)

Local cAliasSF3 	:=	""
Local cWhere  	:= 	""

Default lCancel := .F.
Default dDataDe := ""
Default dDataAte := ""

If !Empty(dDataDe) .And. !Empty(dDataAte)
	//Se for verdadeiro, incluo as notas canceldas no retorno do filtro
	If lCancel
		cWhere := "%(SF3.F3_EMISSAO >= '"+ DtoS(dDataDe) + "' AND SF3.F3_EMISSAO <= '"+ DtoS(dDataAte) + "') AND "
		cWhere += " SF3.F3_CODRSEF NOT IN ('101', '102') AND %"
	Else
		cWhere := "% SF3.D_E_L_E_T_= ' ' AND (SF3.F3_EMISSAO >= '"+ DtoS(dDataDe) + "' AND SF3.F3_EMISSAO <= '"+ DtoS(dDataAte) + "') AND %"
	EndIf
Else
	//Se for verdadeiro, incluo as notas canceldas no retorno do filtro
	If lCancel
		cWhere := "% SF3.F3_CODRSEF NOT IN ('101', '102') AND %"
	Else
		cWhere := "% SF3.D_E_L_E_T_= ' ' AND %"
	EndIf
EndIf

cAliasSF3 := GetNextAlias()
BeginSql Alias cAliasSF3

SELECT
	MIN(F3_SERIE) AS MINIMO, MAX(F3_SERIE) AS MAXIMO
FROM
	%Table:SF3% SF3
WHERE
	%Exp:cWhere%
	SF3.F3_FILIAL  =  %xFilial:SF3% AND
	SF3.F3_NFISCAL >=	 %Exp:aParam[02]% AND
	SF3.F3_NFISCAL <=	 %Exp:aParam[03]% AND
	SF3.F3_SDOC 	 = 	 %Exp:aParam[01]%
EndSql

If !Eof()
	//Altero a serie do parametro, para a MENOR serie encontrada na query
	aParam[01] := (cAliasSF3)->MINIMO
	//Adiciono a query maxima no array
	Aadd(aParam,(cAliasSF3)->MAXIMO)
Else
	//Adiciono a Serie maxima no array
	Aadd(aParam,aParam[01])
EndIf
Return (aParam)


//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlColEsp
Função funcao para enviar o espelho da nota para NeoGrid

@author Leonardo Kichitaro
@since 04.05.2015

@param	cNota		Nota fiscal
		cSerie		Serie da nota fiscal
		cCliente	Cliente
		cLoja		Loja
		cIdErp		Id do ERP
		cXml		XML nfesefaz

@return	Nil

/*/
//--------------------------------------------------------------------------------------------
Static Function XmlColEsp(cNota,cSerie,cCliente,cLoja,cIdErp,cXml, cErroEsp)

Local oEsp		:= Nil
Local cXmlEsp	:= ""
Local lEspelho	:= .F.

Default cErroEsp  := ""

cXmlEsp := ExecBlock("NFEspNeo",.F.,.F.,{cXml,cSerie,cNota,cCliente,cLoja})

If !Empty(cXmlEsp)
	oEsp := ColaboracaoDocumentos():new()
	oEsp:cModelo 	:= "EDI"
	oEsp:cTipoMov	:= "1"

	oEsp:cModelo 	:= "EDI"
	oEsp:cNumero	:= cNota	// Numero do Documento
	oEsp:cSerie		:= cSerie	// Serie do Documento
	oEsp:cIdErp 	:= cIdErp	// ID Erp
	oEsp:cXml		:= cXmlEsp	// XML
	oEsp:cTipoMov	:= "1"		// Tipo de Movimento 1-Saida / 2-Recebimento
	oEsp:cQueue		:= "006"	// Codigo Queue (006 - Espelho da Nota)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Metodo Transmitir                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lEspelho := oEsp:transmitir()

	If !lEspelho
		cErroEsp := "Não foi possível transmitir o espelho da nota"+CRLF+oEsp:cMsgErr
	EndIf
EndIf

Return( lEspelho )

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetXmlNFe
Função funcao para retornar o XML da NFe transmitida pelo TSS

@author Anderson Silva
@since 29.04.2016

@param	cIdEnt	Codigo da entidade
		cIdNFe	Id da NFe que será feito a validação de schema


@return cXml XML da NFe transmitida pelo TSS

/*/
//--------------------------------------------------------------------------------------------
Static Function RetXmlNFe(cIdEnt,cIdNfe)

Local oWS
Local cXML	:= ""
Local cURL	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := cIdNfe
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

If oWS:RETORNANOTAS()
	If Len(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
		cXML := oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
	EndIf
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
EndIf

Return( cXML )

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetHoraUTC
Função funcao para retornar Time Zone UTC de Acordo com o especificado nos parâmetros do CT-e

@author Felipe Barbiere
@since 17.01.2017

@param	cIdEnt	Codigo da entidade

@return cRet - Time Zone

/*/
//--------------------------------------------------------------------------------------------
Static Function TZoneUTC(cIdEnt)

Local cError	:= ""
Local cRet 	:= ""
Local aCfgCTe := ""
Local lUsaColab := UsaColaboracao("2")


If !lUsaColab

	aCfgCTe := getCfgEpecCte(@cError, cIdEnt)

	If Empty(cError)
		If Left(aCfgCTe[12],1) == "1"					//Horario de Verão -> 1-Sim ### 2-Nao
			If Substr(aCfgCTe[11], 1, 1) == "1"		//Fernando de Noronha
				cRet := "-01:00"
			ElseIf Substr(aCfgCTe[11], 1, 1) == "2"	//Brasilia
				cRet := "-02:00"
			ElseIf	Substr(aCfgCTe[11], 1, 1) == "4"	//Acre
				cRet := "-04:00"
			Else
				cRet := "-03:00"						//Manaus
			Endif
		Else
			If Substr(aCfgCTe[11], 1, 1) == "1"		//Fernando de Noronha
				cRet := "-02:00"
			ElseIf Substr(aCfgCTe[11], 1, 1) == "2"	//Brasilia
				cRet := "-03:00"
			ElseIf	Substr(aCfgCTe[11], 1, 1) == "4"	//Acre
				cRet := "-05:00"
			Else
				cRet := "-04:00"						//Manaus
			Endif
		Endif
	EndIf
Else
	cRet := Substr(colDtHrUTC(),20 ,6)
EndIf

Return( cRet )
//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedDesMnt
Função que monitora os eventos do Evento de Desacordo

@author Felipe Barbieri
@since 23.03.2017
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedDesMnt(cAliasDes)

Local cIdEnt	:= ""
Local aListBox	:= {}
Local cIdEvento	:= '610110'
Local cEstDoc		:= ""
Local lUsaColab	:= .F.
Local dEmissao	:= CtoD("//")
Local cDoc			:= ""
Local cSerie		:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4

Default cAliasDes := ""

If Empty(cAliasDes)
	If IsInCallStack("MATA103")
		cAliasDes := "SF1"
	Elseif IsInCallStack("TMSA500")
		cAliasDes := "DT6"
	Endif
Endif

If cAliasDes == "SF1"
	cEstDoc	:= SF1->F1_IDDES
	dEmissao	:= SF1->F1_EMISSAO
	cDoc		:= SF1->F1_DOC
	cSerie		:= SF1->F1_SERIE
Elseif cAliasDes == "DT6"
	cEstDoc	:= DT6->DT6_IDDES
	dEmissao	:= DT6->DT6_DATEMI
	cDoc		:= DT6->DT6_DOC
	cSerie		:= DT6->DT6_SERIE
Endif

lUsaColab := UsaColaboracao("2")

DEFINE FONT oBold BOLD

	aListBox := SpedWsDes(cAliasDes)

	If !Empty(aListBox)

			DEFINE MSDIALOG oDlg TITLE "Monitor - Evento Desacordo" From 10,10 TO 450,1012 OF oMainWnd PIXEL

			@015,010 SAY	STR0324			PIXEL OF oDlg FONT oBold	//Numero
			@015,036 SAY	cDoc				PIXEL OF oDlg
			@015,074 SAY	STR0249			PIXEL OF oDlg FONT oBold	//Série
			@015,093 SAY	cSerie				PIXEL OF oDlg

			@030,010 LISTBOX oListBox 	FIELDS HEADER "",STR0050,STR0362,STR0295,STR0364,STR0365 SIZE 480,150 PIXEL OF oDlg	//"Protocolo ID Evento Ambiente Status do Evento Retorno da Transmissao Retorno Processamento do Evento"

			oListBox:SetArray(aListBox)
			oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;
									aListBox[oListBox:nAt][02],;
									aListBox[oListBox:nAt][03],;
									aListBox[oListBox:nAt][04],;
									aListBox[oListBox:nAt][05],;
									aListBox[oListBox:nAt][06]}}

			@ 200,400 BUTTON oBtn1 PROMPT STR0118	ACTION (aListBox := SpedWsDes(cAliasDes),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
			@ 200,455 BUTTON oBtn2 PROMPT STR0294	ACTION (SpedHlpDes(cAliasDes), oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"OK"

			ACTIVATE MSDIALOG oDLg CENTERED
		EndIf
Return

/*/{Protheus.doc} SpedHlpDes
Informativo para o usuario excluir CTE após evento
de desacordo for vinculado.

@author Rodrigo M Pontes
@since 23.03.2017
@version 1.00

@param	Null
/*/

Static Function SpedHlpDes(cAliasDes)

If cAliasDes == "SF1"
	Help(,,'EVDESACORDO',,STR0505, 1, 0) //"É recomendavel que exclua o CTE após a confirmação do evento. O CTE continuara com todas seus lançamentos ativos até que seja excluido."
Endif

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedDesMnt
Função que monitora os eventos do Evento de Desacordo

@author Felipe Barbieri
@since 23.03.2017
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function SpedWsDes(cAliasDes)

Local cIdEnt	:= ""
Local aListBox	:= {}
Local cIdEvento	:= '610110'
Local cEstDoc		:= ""
Local lUsaColab	:= .F.
Local dEmissao	:= CtoD("//")
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWS
Local oListBox
Local lOk 			:= .F.
Local aStatus		:= {	{1,"1-Evento recebido"},;
							{2,"2-Evento assinado"},;
							{3,"3-Evento com falha no schema XML"},;
							{4,"4-Evento transmitido"},;
							{5,"5-Evento com problemas"},;
							{6,"6-Evento vinculado"	} }
Local nStatPos		:= 0
Local cStatus			:= ""
Local cStatRetEven	:= ""
Local cStatRet		:= ""
Local cStatRetEnv		:= ""
Local cProtocolo     := ""
Local cChvCte			:= ""
Local oOk				:= LoadBitMap(GetResources(), "ENABLE")
Local oNo				:= LoadBitMap(GetResources(), "DISABLE")

If cAliasDes == "SF1"
	cEstDoc	:= SF1->F1_IDDES
	dEmissao	:= SF1->F1_EMISSAO
	cChvCte	:= SF1->F1_CHVNFE
Elseif cAliasDes == "DT6"
	cEstDoc	:= DT6->DT6_IDDES
	dEmissao	:= DT6->DT6_DATEMI
	cChvCte	:= DT6->DT6_CHVCTE
Endif

lUsaColab := UsaColaboracao("2")

DEFINE FONT oBold BOLD

// Verifica se a entidade foi configurada
If IsReady(,,,lUsaColab)

	cIdEnt := GetIdEnt(lUsaColab)
	If !Empty(cIdEnt)

		// Executa o metodo NfeRetornaEvento()
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL			:= AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cEVENTO		:="610110"
		oWS:cCHVINICIAL	:= cChvCte
		oWS:cCHVFINAL		:= cChvCte
		lOk := oWS:NFEMONITORLOTEEVENTO()

		If lOk
			// Tratamento do retorno do evento
			If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U" .And. ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"

				oDados := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento[1]

				If ( nStatPos := aScan(aStatus,{ |x| x[1] == oDados:nStatus}) ) > 0
					cStatus := aStatus[nStatPos][2]
				Endif
				cIDEvenRet	:= oDados:cId_Evento
				nLote 		:= oDados:nLote
				cAmbiente	:= Alltrim(Str(oDados:nAmbiente))		//1-Producao ### 2-Homologacao

				If oDados:nStatus > 2

					// Retorno da transmissao
					cStatRetEnv := cValToChar(oDados:nCSTATENV) + " - " + Alltrim(oDados:cCMOTENV)

					// Retorno do processamento do evento
					If oDados:nCStatEven > 0
						cStatRetEven := cValToChar(oDados:nCStatEven)+" - "+Alltrim(oDados:cCMotEven)

						// Evento registrado e vinculado a NF-e
						If oDados:nCStatEven == 135
							cProtocolo := StrZero(oDados:nProtocolo,15)
							If cEstDoc <> '6'
								If cAliasDes == "SF1"
									If RecLock('SF1',.F.)
										SF1->F1_IDDES  := AllTrim(Str(oDados:nStatus))

										If AllTrim(Str(oDados:nStatus)) == "6"
											SF1->F1_STATUS := "E" // Evento desacordo vinculado
										Elseif AllTrim(Str(oDados:nStatus)) == "5" .Or. AllTrim(Str(oDados:nStatus)) == "3"
											SF1->F1_STATUS := "F" // Evento desacordo rejeição
										Endif

										SF1->(MsUnLock())
									Endif
								Elseif cAliasDes == "DT6"
									If RecLock('DT6',.F.)
										DT6->DT6_IDDES  := AllTrim(Str(oDados:nStatus))
										DT6->(MsUnLock())
									Endif
								Endif
							EndIf
						ElseIf oDados:nCStatEven >= 201 //Rejeição
							If cEstDoc <> '6'
								If cAliasDes == "SF1"
									If RecLock('SF1',.F.)
										SF1->F1_IDDES  := AllTrim(Str(oDados:nStatus))

										If AllTrim(Str(oDados:nStatus)) == "6"
											SF1->F1_STATUS := "E" // Evento desacordo vinculado
										Elseif AllTrim(Str(oDados:nStatus)) == "5" .Or. AllTrim(Str(oDados:nStatus)) == "3"
											SF1->F1_STATUS := "F" // Evento desacordo rejeição
										Endif

										SF1->(MsUnLock())
									Endif
								Elseif cAliasDes == "DT6"
									If RecLock('DT6',.F.)
										DT6->DT6_IDDES  := AllTrim(Str(oDados:nStatus))
										DT6->(MsUnLock())
									Endif
								Endif
							EndIf
						Endif
					Endif

				Else
					cXmlRet := ""
				Endif

				cAmbiente := IIf(cAmbiente == "1",STR0031,STR0032)

				If Empty(cStatRetEven)
					cStatRet := cStatRetEnv
				Else
					cStatRet := cStatRetEven
				Endif

				AADD( aListBox, {	IIf(Empty(cProtocolo),oNo,oOk),;
								cProtocolo,;
								cIDEvenRet,;
								cAmbiente,;		//[04] 1-Producao ### 2-Homologacao
								cStatus,;		//[05] Status do evento
								cStatRet})		//[06] Status retorno da transmissao
			EndIf
		EndIf
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return aListBox

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedContAutoPar
Função que parametriza o Protheus para a Contingencia Automatica

@author Sergio S. Fuzinaka
@since 25.04.2017
@version 12.1.017

@param	Null

/*/
//-----------------------------------------------------------------------
Function SpedContAutoPar()

Local oWs
Local aPerg  	:= {}
Local aRet		:= {}
Local aParam 	:= {"",""}
Local cModel	:= "55"

Local aCombo1	:= {}	// Habilitado: 0-Nao ou 1-Sim
Local aCombo2	:= {}	// Modalidade: 5-EPEC

Local cCombo1	:= ""
Local cCombo2	:= ""

Local cIdEnt 	:= ""
Local cURL 		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lUsaColab	:= .F.
Local cParCAPar	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"AUTOCONT"

Local lAdminNfe  := GetNewPar("MV_ADMNFE",.T.)

// Obtem o Modelo do Documento
If FunName() $ "SPEDCTE,TMSA200,TMSA500,TMSAE70,TMSA050"
	cModel := "57"
Else
	cModel := "55"
Endif

// Habilitado
AADD(aCombo1,"0-Nao")
AADD(aCombo1,"1-Sim")

// Modalidade
AADD(aCombo2,"5-EPEC")

if cModel == "55"
	lUsaColab := UsaColaboracao("1")
else
	lUsaColab := UsaColaboracao("2")
endif

if lUsaColab

	Aviso("SPED", "Implementacao nao realizada para TOTVS Colaboracao !!!",{STR0114},3)

ElseIf cModel == "57"

	Aviso("SPED", "Implementacao nao realizada para o modelo 57-CT-e !!!",{STR0114},3)

ElseIf cModel == "55"

	if !lAdminNfe .Or. ( lAdminNfe .And. PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0 )

		If IsReady()

			// Obtem o codigo da entidade
			cIdEnt		:= GetIdEnt()

			// Título do Parambox
			cCadastro	:= " Contingência Automática - Entidade: " + cIdEnt + " - TSS: "+ cVersaoTSS

            // Consulta a configuração da Contingencia Automatica
			If (getCfgAutoCont( "0", cIdEnt, cModel, , , @aRet ) )
				cCombo1 := aRet[1] + IIf(aRet[1] == "0","-Nao","-Sim")
				cCombo2 := aRet[2] + IIf(aRet[2] == "5","-EPEC","")
			Else
				cCombo1 := "0-Nao"
				cCombo2 := "5-EPEC"
			Endif

			aadd(aPerg,{2,"Habilita",cCombo1,aCombo1,120,".T.",.T.,".T."}) // Habilita: 0-Nao ou 1-Sim
			aadd(aPerg,{2,"Modalidade",cCombo2,aCombo2,120,".T.",.T.,".T."}) // Modalidade: 5-EPEC

			If ParamBox(aPerg,"TOTVS Web Service",aParam,,,,,,,cParCAPar,.F.,.F.)

				// Atualiza a configuração da Contingencia Automatica
				If !getCfgAutoCont( "1", cIdEnt, cModel, Left(aParam[1],1), Left(aParam[2],1) )
					Aviso("SPED","Falha na gravacao das configuracoes !!!",{STR0114},3)
				Endif

			Endif

		Else

			Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"

		endif

	Else

		Help( "", 1, "SEMPERM" )

	Endif

Else

	Aviso("SPED", "Implementacao nao realizada para o modelo [" + cModel + "] !!!",{STR0114},3)

Endif

Return

static function getDescMod(cModalidade)

    local cDescModaliade :=  ""

    do case
        case(cModalidade == "5")
            cDescModaliade := "5-EPEC"
    endcase

return cDescModaliade

static function BtmCaution(oTBitmap1, lEnable)

    if( oTBitmap1 <> nil )
        oTBitmap1:lVisible := lEnable
        oTBitmap1:refresh()
    endif

return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedCleRelt
Limpa arquivos temporarios .rel da pasta MV_RELT

@author Bruno Seiji
@since 04.12.2017
@version 12.1.17

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function SpedCleRelt()
Local cPath		:= SuperGetMV('MV_RELT',,"\SPOOL\")
Local aArquivos := {}
Local nX		:= 0
Local cNome		:= ""

aArquivos := Directory(cPath + "*.rel", "D")

For nX := 1 to Len(aArquivos)
	cNome := LOWER(aArquivos[nX,1])
	If AT("danfe", cNome) > 0
		FERASE(cPath + cNome)
	EndIf
Next nX

Return
//-------------------------------------------------------------------------
/*/{Protheus.doc} FIntegNfTaf
Função responsável pelo envio do documento fiscal eletrônico para o TAF após
o retorno do TSS com a chave eletrônica.

@Param	aDocSFT    -> Array com a chave do documento fiscal para integração
		lTAFVldAmb -> Controle do ERP para saber se a integração online pode ser realizada

@author	 Rodrigo Aguilar
@since	 16/02/2017
/*/
//-------------------------------------------------------------------------
Static Function FIntegNfTaf( aDocSFT, lTAFVldAmb )

 //-----------------------------------------------------------
// Chama Job para intregacao NATIVA do documento fiscal no TAF
//-----------------------------------------------------------
If lTAFVldAmb
    StartJob( 'DocFisxTAF', GetEnvServer(), .F., cEmpAnt, cFilAnt , aDocSFT )
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ConNfeAut³ Autor ³Valter da Silva        ³ Data ³18.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que verifica se a Nfe esta Autorizado                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ConNfeAut(cAlias)

Local cIdEnt     := ""
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMensagem  := ""
Local cProtocolo := ""
Local cCodRet		:= ""
Local cAviso		:= ""
Local lAut			:= .F.
Local oWS

Local aParam		:= {}
Local aRetorno	:= {}
Local aAreaSF3  	:= {}

Private lUsaColab := UsaColaboracao("1")
If IsReady(,,,lUsaColab)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := GetIdEnt(lUsaColab)
	If !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lUsaColab
			aadd(aParam,{SF3->F3_SERIE+SF3->F3_NFISCAL})

			aRetorno:= colNfeMonProc(aParam, 2, "55", .F., @cAviso)
			cMensagem := ""
			if Len(aRetorno) > 0
				If !Empty (Alltrim (aRetorno[1][5])) .And. !Empty (Alltrim (aRetorno[1][6]))
					If Empty (Alltrim (aRetorno[1][4]))
						cMensagem += iif(aRetorno[1][9]<> nil,aRetorno[1][9],"")
					EndIf
					cCodRet	:= Alltrim(aRetorno[1][5])
				Else
					cMensagem+= iif(aRetorno[1][9]<> nil,aRetorno[1][9],"")
				EndIf
				
				IF  "215" $ cMensagem 
					cCodRet := "215"
				ElseIf  "217" $ cMensagem
					cCodRet := "217"
				EndIf
				
			else
				cCodRet := "215"
			endif
		else
			If !Empty(cIdEnt)
				oWs:= WsNFeSBra():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cID_ENT      := cIdEnt
				oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
				oWs:cNFECONSULTAPROTOCOLOID := (cAlias)->F3_SERIE+(cAlias)->F3_NFISCAL
				If oWs:ConsultaProtocoloNfe()
					cCodRet := oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE
				Else
					IF  "215" $ GetWscError(1)    //215|Rejeição: Falha no schema XML
						cCodRet := "215"
					ElseIf "217" $ GetWscError(1)
						cCodRet := "217"         //217|Rejeição: NF-e não consta na base de dados da SEFAZ
					EndIf
				EndIf
			Endif
		EndIf
			
		aAreaSF3  	:= SF3->(GetArea())							
					
		DbSelectArea( "SF3" )
		DbSetOrder(4) 
		If DbSeek( xFilial("SF3") + (cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA+(cAlias)->F3_NFISCAL+(cAlias)->F3_SERIE)
			RecLock("SF3",.F.)
			SF3->F3_CODRSEF := cCodRet
    		MsUnlock()
    	EndIf
		RestArea(aAreaSF3)
		
	Else
		Conout(STR0021)//Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Conout(STR0021)//Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

If  cCodRet  == '100' //100|Autorizado o uso da NF-e
	lAut:=.T.
Else
	Conout (STR0406 +" "+STR0170+": "+cCodRet) //	 "Nenhum registro à cancelar"
EndIf

Return lAut


function setDocChv(cDocChv)
	__cDocChv := cDocChv
return
function getDocChv()
return __cDocChv
