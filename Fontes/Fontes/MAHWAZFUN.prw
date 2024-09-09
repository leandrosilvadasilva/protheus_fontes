#Include "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NoCharEsp �Autor  � Totvs              � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � Retirar caracteres especiais.                              ���
�������������������������������������������������������������������������͹��
���Uso       � Fontes WebService                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function NoCharEsp(cString)

	Local cChar  := ""
	Local nX     := 0 
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "�����"+"�����"
	Local cCircu := "�����"+"�����"
	Local cTrema := "�����"+"�����"
	Local cCrase := "�����"+"�����" 
	Local cTio   := "����"
	Local cCecid := "��"
	
	Local cMaior := ">"     
	Local cMenor := "<"     
	
	For nX := 1 To Len( cString )
	
		cChar := SubStr(cString, nX, 1)
	
		IF cChar $ cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
	
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf                                       
			
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf		
			nY:= At(cChar,cTio)
			If nY > 0          
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			EndIf		
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf  
			
		Endif
	Next
	
	If cMaior $ cString 
		cString := StrTran( cString, cMaior, " " ) 
	EndIf
	If cMenor $ cString 
		cString := StrTran( cString, cMenor, " " )
	EndIf
	                        
	cString := StrTran( cString, CRLF, " " )
	
	cString := StrTran( cString, "&", "e" ) 
	
	cString := StrTran( cString, "'", " " ) 
	
	cString := StrTran( cString, '"', " " ) 
	 
	cString := StrTran( cString, ";", " " ) 
	                 
	For nX := 1 To Len( cString )     
	
		cChar := SubStr( cString, nX, 1 )
		
		If Asc( cChar ) == 47 //Para permitir a barra "/"
			Loop
		EndIf
		
		If ( Asc(cChar) < 48 ) .Or. ;  // numeros 48-57
		   ( Asc(cChar) > 57 .And. Asc(cChar) < 65 ) .Or.;  // letras 65-90
		   ( Asc(cChar) > 90 .And. Asc(cChar) < 97 ) .Or.;  // letras 97-122
		   ( Asc(cChar) > 122 ) 
		   
			cString := StrTran( cString, cChar, " ")
			
		EndIf
		
	Next nX       
        
Return( cString )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � RotLock       � Autor �Julio Witwer     � Data �           ���
�������������������������������������������������������������������������͹��
���Descricao � Trava para operacao critica                                ���
�������������������������������������������������������������������������͹��
���Sintaxe   � RotLock(cKey)                                              ���
�������������������������������������������������������������������������͹��
���Parametros� ExpC1 - Chave que sera utilizada para criar arquivo de     ���
���          � controle das travas.                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function RotLock(cKey,nTentativas)

	__ccArq := cKey+".LCK"
	
	nCont := 1     
	
	While (__nnLock := fcreate(__ccArq)) == -1
	    If KillApp()
	        conout("RotLock abort on "+procname(1))
	        __nnLock := -1
	    Endif      
	    nCont++
	    If nCont > nTentativas   
	    	
	    	Conout( cKey + " - RotLock excedeu tentativas")		
	    	Exit
	    Endif
	    sleep(1000)
	Enddo
	
Return( __nnLock <> -1 )                                                                            


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � RotUnlock     � Autor �Julio Witwer     � Data �           ���
�������������������������������������������������������������������������͹��
���Descricao � Destrava a operacao critica                                ���
�������������������������������������������������������������������������͹��
���Sintaxe   � RotUnlock()                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function RotUnlock()
	
	If __nnLock != -1
	    fclose(__nnLock)
	    ferase(__ccArq)
	Endif
	
Return( .T. )

user Function sToZoho(cURL,cJson)
	//Local cUrl := ''//TODO insira aqui a sua url do slack, similar a https://hooks.slack.com/services/TSN3MSKFD/BTG0YNAMQ/M1bSfoBKUEyUX4uc7DezlC
	Local nTimeOut := 120
	Local aHeadOut := {}
	Local cHeadRet := ""
	Local sPostRet := ""


	
	aadd(aHeadOut,'Content-type: application/json')
	//For _ni := 1 to len(aMsg)
		sPostRet := HttpPost(cURL,,cJson,nTimeOut,aHeadOut,@cHeadRet)
	//next
	if !empty(sPostRet)
		conout("HttpPost Ok")
		varinfo("WebPage", sPostRet)
	else
		conout("HttpPost Failed.")
		varinfo("Header", cHeadRet)
	Endif
Return .T.
