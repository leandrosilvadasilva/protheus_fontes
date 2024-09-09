#include "protheus.ch"     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Copia privilegios de um usuario do CRM para outro          º±±
±±º  		 ³ atualizando a tabela AO4                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGASUL                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MAHA030()                                                     
Local oDlg
Private cPerg := "MAH030"
                
// Cria grupo de perguntas
CriaSx1( cPerg )

// Monta a tela para o processamento
DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Copia de privilegios de usuarios do CRM" ) FROM 148,66 TO 364,568 PIXEL
	@ 12,17 TO 76,236 LABEL OemtoAnsi("Objetivo") OF oDlg PIXEL 
	@ 21,22 SAY OemToAnsi("Este programa tem por objetivo copiar os privilegios de um determinado usuario do CRM para outro usuario.") OF oDlg PIXEL Size 208,48

	DEFINE SBUTTON FROM 082,017 TYPE 1  ENABLE OF oDlg ACTION Processa( { |lEnd| Executa() } , "Copiando acessos..." )
	DEFINE SBUTTON FROM 082,050 TYPE 2  ENABLE OF oDlg ACTION oDlg:End()
ACTIVATE DIALOG oDlg CENTER
Return NIL



Static Function Executa()       
Local cUserOri,cUserDest,cNomeOri,cNomeDest,cIDESTN,nNVESTN,lContinua

If Pergunte(cPerg,.T.)            

	// Usuarios do CRM origem e destino
	cUserOri := mv_par01
	cUserDest := mv_par02                                      
                             
 	// Usuario origem
 	lContinua := .T.
	dbSelectArea("AO3")
	dbSetOrder(1)	// AO3_FILIAL+AO3_CODUSR 
	If dbSeek( xFilial('AO3')+cUserOri , .F. )  	// AO3_FILIAL+AO3_CODUSR     
		cNomeOri := USRRETNAME( AO3->AO3_CODUSR )
	Else	                                   
		Alert("Usuario origem nao encontrado!")
	 	lContinua := .F.
	Endif
	
 	// Usuario destino
	If lContinua
		dbSelectArea("AO3")
		dbSetOrder(1)	// AO3_FILIAL+AO3_CODUSR 
		If dbSeek( xFilial('AO3')+cUserDest , .F. )  	// AO3_FILIAL+AO3_CODUSR     
			cNomeDest := USRRETNAME( AO3->AO3_CODUSR )
			cIDESTN := AO3->AO3_IDESTN
			nNVESTN := AO3->AO3_NVESTN		
		Else	
			Alert("Usuario destino nao encontrado!")
		 	lContinua := .F.
		Endif        
	Endif	
         
 	// Validacao dos parametros
	If cUserOri == cUserDest
		Alert("Usuario destino nao pode ser igual ao usuario origem")
		lContinua := .F.
	Endif
                               
	// Inicia processamento
	If lContinua

		If MsgYesNo( "Confirma copia dos privilegios do usuario " + cUserOri + " " + Alltrim(cNomeOri) + " para o usuario " + cUserDest + " " + Alltrim(cNomeDest) + "?" )
	    
			// Pesquisa os registros cujo usuario de origem possui permissao 
			cCount := " SELECT COUNT(*) QTDREG"
			cSelect := " SELECT * "
			cFrom := " FROM " + RetSQLName("AO4") + " AO4"
			cWhere := " WHERE AO4_FILIAL = '" + xFilial("AO4")	+ "'"
			cWhere += " AND	AO4.AO4_CODUSR = '" + cUserOri + "'"	
			cWhere += "	AND	AO4.D_E_L_E_T_ <> '*'"
			cQuery := ChangeQuery(cCount+cFrom+cWhere)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRAB1", .F., .T.)
			nQtdReg := TRAB1->QTDREG
			dbCloseArea()             
//			Alert(cQuery)

			cQuery := ChangeQuery(cSelect+cFrom+cWhere)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRAB1", .F., .T.)
//			Alert(cQuery)
			TcSetField( "TRAB1", "AO4_CTRLTT" , TamSX3("AO4_CTRLTT")[3] , TamSX3("AO4_CTRLTT")[1] , TamSX3("AO4_CTRLTT")[2] )
			TcSetField( "TRAB1", "AO4_NVESTN" , TamSX3("AO4_NVESTN")[3] , TamSX3("AO4_NVESTN")[1] , TamSX3("AO4_NVESTN")[2] )                                                 

			ProcRegua(nQtdReg)
            
            // Faz a copia de cada registro de privilegio
            dbGoTop()
            nInc := 0
            Do While !Eof()
                                        
			    dbSelectArea("AO4")
				dbSetOrder(1) 	// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
				If !dbSeek( TRAB1->AO4_FILIAL + TRAB1->AO4_ENTIDA + TRAB1->AO4_CHVREG + cUserDest , .F. )		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR		    
			    
				    Reclock("AO4",.T.)
			   			AO4->AO4_FILIAL := TRAB1->AO4_FILIAL
						AO4->AO4_ENTIDA := TRAB1->AO4_ENTIDA
						AO4->AO4_CHVREG := TRAB1->AO4_CHVREG
						AO4->AO4_CODUSR := cUserDest
						AO4->AO4_CTRLTT := TRAB1->AO4_CTRLTT
						AO4->AO4_IDESTN := cIDESTN
						AO4->AO4_NVESTN := nNVESTN
						AO4->AO4_TPACES := TRAB1->AO4_TPACES
						AO4->AO4_PRIORI := TRAB1->AO4_PRIORI
				    MsUnlock()
				    
				    nInc++ 
				    
				Endif       
				    
			    IncProc()
                 
            	dbSelectArea("TRAB1")
            	dbSkip()
            	
            Enddo
                       
			dbCloseArea()	 
			MsgInfo("Processamento finalizado! Foram copiados "+str(nInc)+" permissoes de acesso!")          
			
		Endif
				
	Endif
	
Endif
	
Return NIL
                            

// Cria o grupo de perguntas
Static Function CriaSx1( cPerg )
Local cValid   := ""
Local cF3      := "AO3"
Local cPicture := ""
Local cDef01   := ""
Local cDef02   := ""
Local cDef03   := ""
Local cDef04   := ""
Local cDef05   := ""

u_PutSX1(cPerg, "01", "Usuario Origem"    ,"MV_PAR01", "MV_CH0", TamSX3("AO3_CODUSR")[3]  , TamSX3("AO3_CODUSR")[1]  , TamSX3("AO3_CODUSR")[1]  , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Usuario origem")
u_PutSX1(cPerg, "02", "Usuario Destino"   ,"MV_PAR02", "MV_CH1", TamSX3("AO3_CODUSR")[3]  , TamSX3("AO3_CODUSR")[1]  , TamSX3("AO3_CODUSR")[1]  , "G", cValid,       cF3, cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Usuario destino")

Return NIL

