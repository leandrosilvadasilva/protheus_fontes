#include "protheus.ch"     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta acesso na AO4                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGASUL                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function crmacesso()                                                     
Local oDlg

// Monta a tela para o processamento
DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Ajusta acessos a clientes CRM" ) FROM 148,66 TO 364,568 PIXEL
	@ 12,17 TO 76,236 LABEL OemtoAnsi("Objetivo") OF oDlg PIXEL 
	@ 21,22 SAY OemToAnsi("Este programa tem por objetivo ajustar o acesso dos usuarios do CRM a base de clientes, com base no campo Vendedor do cadastro de clientes. Atualiza a tabela AO4.") OF oDlg PIXEL Size 208,48

	DEFINE SBUTTON FROM 082,017 TYPE 1  ENABLE OF oDlg ACTION Processa( { |lEnd| Executa() } , "Atualizando acessos..." )
	DEFINE SBUTTON FROM 082,050 TYPE 2  ENABLE OF oDlg ACTION oDlg:End()
ACTIVATE DIALOG oDlg CENTER
Return NIL



Static Function Executa()       

SA3->(dbSetOrder(1))	// A3_FILIAL+A3_COD  
AO3->(dbSetOrder(1))	// AO3_FILIAL+AO3_CODUSR 
AO4->(dbSetOrder(1)) 	// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR

dbSelectArea('SA1')
dbGotop()      
Procregua(Lastrec())    
nDel := 0
nInc := 0      
Do While ! SA1->( Eof() )
	
	// verifica se tem vendedor no SA1
	If !Empty(SA1->A1_VEND)
		                  
		// localiza o vendedor
		If SA3->( dbSeek(xFilial('SA3')+SA1->A1_VEND , .F. ) )         
		
			// posiciona em AO3
			If !(AO3->( dbSeek(xFilial('AO3')+SA3->A3_CODUSR) ))  	// AO3_FILIAL+AO3_CODUSR     
				Alert("Usuario codigo: "+SA3->A3_CODUSR+" do cadastro do vendedor: "+SA3->A3_COD+" "+SA3->A3_NOME+" nao encontrado no cadastro de usuarios CRM. Acerte este cadastro e rode a rotina novamente.")
				Exit 
			Endif		

			// limpa registros de AO4
//			AO4->( dbSeek(xFilial('AO4')+'SA1'+PadR( '01  '+SA1->A1_COD+SA1->A1_LOJA , Len(AO4->AO4_CHVREG)) , .F. ) )		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
//			Do While ! AO4->( Eof() ) .and. AO4->AO4_FILIAL+AO4->AO4_ENTIDA+AO4->AO4_CHVREG == xFilial('AO4')+'SA1'+PadR( '01  '+SA1->A1_COD+SA1->A1_LOJA , Len(AO4->AO4_CHVREG))
//				AO4->(RecLock('AO4', .f.))
//			   		AO4->(dbDelete())
//				AO4->( MsUnlock() )
//				AO4->( dbSkip() ) 
//				nDel++
//			EndDo
			                                                          	
			// adiciona novo registro em AO4
			If AO4->( !dbSeek(xFilial('AO4')+'SA1'+PadR( '01  '+SA1->A1_COD+SA1->A1_LOJA , Len(AO4->AO4_CHVREG)) + SA3->A3_CODUSR , .F. ) )		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
	  			AO4->(RecLock('AO4', .T.))
		   			AO4->AO4_FILIAL := xFilial('AO4')
					AO4->AO4_ENTIDA := 'SA1'
					AO4->AO4_CHVREG := '01  '+SA1->A1_COD+SA1->A1_LOJA
					AO4->AO4_CODUSR := SA3->A3_CODUSR
					AO4->AO4_CTRLTT := .T.
					AO4->AO4_IDESTN := AO3->AO3_IDESTN
					AO4->AO4_NVESTN := AO3->AO3_NVESTN
					AO4->AO4_TPACES := '1'
					AO4->AO4_PRIORI := '0'
				AO4->( MsUnlock() )
				nInc++
			Endif	
		EndIf
		
	Endif
	
	IncProc()
	SA1->( dbSkip() )
EndDo           
      
MsgInfo("Processamento finalizado! Foram deletados "+str(nDel)+" registros da tabela AO4. Foram inseridos "+str(nInc)+" registros na tabela AO4")
	
Return NIL