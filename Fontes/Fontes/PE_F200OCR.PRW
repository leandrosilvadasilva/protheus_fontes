#Include 'Protheus.ch'

User Function F200OCR()
Reclock("SE5",.f.)
IF AllTrim(SE5->E5_TIPODOC)='DB'
	IF AllTrim(SE5->E5_BANCO)='001'
	    //SE5->E5_DTDISPO := DataValida(DToS(DaySum(StoD(SE5->E5_DATA),1)),.T.)
	    SE5->E5_DTDISPO := DataValida(DaySum(SE5->E5_DATA,1),.T.) 
	ENDIF
ENDIF
msUnlock()

Return