#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "TbiConn.ch" 

//Opcoes ExecAuto 
#Define PD_INCLUIR 3 
#Define PD_ALTERAR 4 
#Define PD_EXCLUIR 5   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ MAHTRG10 ณ Autor ณ Ednei R. Silva      ณ Data ณ MAR/2020   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ WS inclusao de inventario.                                 ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Especifico MA  Hospitalar                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ                          ULTIMAS ALTERACOES                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ Motivo da Alteracao                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSRESTFUL MAHADDSB7 DESCRIPTION "Incluir SB7" 

WSDATA	B7_FILIAL   AS STRING // ok(4)  NOT NULL,
WSDATA	B7_COD      AS STRING // ok(20) NOT NULL,
WSDATA	B7_LOCAL    AS STRING // ok(2)  NOT NULL,
WSDATA	B7_DOC      AS STRING // ok(9)  NOT NULL,
WSDATA	B7_QUANT    AS STRING // ok	    NOT NULL,
WSDATA	B7_DTVALID  AS STRING // ok(8)  NOT NULL,
WSDATA	B7_DATA     AS STRING // ok(8)  NOT NULL,
WSDATA	B7_LOTECTL  AS STRING // ok(30) NOT NULL,
WSDATA	B7_NUMDOC   AS STRING // ok(9)  NOT NULL,
WSDATA	B7_IDINV    AS STRING // ok(80) NOT NULL,


   



WSMETHOD POST DESCRIPTION "Incluir SB7." WSSYNTAX "/" 
	
END WSRESTFUL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ POST     บAutor  ณ Ednei Silva        บ Data ณ  Ago/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para incluir Pedido de venda.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MA Hospitalar                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE MAHADDSB7

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local oJson 
	Local cTipo     :=""
	Local cCtrEnde	:=""
	Local cNserie	:=""
	Local cLocaliz	:=""
	Local cEmpInv   := ""
	Local cFilInv   := "" 
	Local nCont     :=0
	Local cDOC      :=""
	Local dUiltCont :=""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
    ConOut('01')
	::SetContentType("application/json")//Define o tipo de retorno do metodo	
				
	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
	
		lOk := .F.
		SetRestFault( 1, "Nao foi possivel processar a estrutura Json." )	

	Else

		cTipo	:=cBusca('SB1010', 'B1_TIPO','B1_COD', oJson:B7_COD )
		cCtrEnde:=cBusca('SB1010', 'B1_LOCALIZ','B1_COD', oJson:B7_COD )
		IF cCtrEnde='S'
			cNserie	 :=cBusca2('BF_NUMSERI',oJson:B7_FILIAL,oJson:B7_COD,oJson:B7_LOCAL,oJson:B7_LOTECTL )
			cLocaliz :=cBusca2('BF_LOCALIZ',oJson:B7_FILIAL,oJson:B7_COD,oJson:B7_LOCAL,oJson:B7_LOTECTL )
		End
		
		If Empty( oJson:B7_FILIAL )
			lOk := .F.	 				
	 		SetRestFault( 89, "Campo obrigatorio: Filial." )
		Endif
		
		If Empty( oJson:B7_COD )
			lOk := .F.	 				
	 		SetRestFault( 90, "Campo obrigatorio: Codigo." )
		Endif  
		
		If Empty( oJson:B7_LOCAL )
			lOk := .F.	 				
	 		SetRestFault( 91, "Campo obrigatorio: Armazem" )
		Endif  
		
		If Empty( oJson:B7_DOC )
		    lOk := .F.	 				
	 		SetRestFault( 92, "Campo obrigatorio: Documento." )
		Endif 
		 
		If Empty( oJson:B7_QUANT ) 
		    lOk := .F.	 				
	 		SetRestFault( 93, "Campo obrigatorio: Quantidade." )
		Endif 	
		
		If Empty( oJson:B7_LOTECTL ) 
			lOk := .F.	 				
	 		SetRestFault( 94, "Campo obrigatorio: Lote." )
		Endif 
		
		If Empty( oJson:B7_DTVALID) 
		    lOk := .F.	 				
	 		SetRestFault( 95, "Campo obrigatorio: Validade." )
		Endif 
		If Empty( oJson:B7_NUMDOC) 
		    lOk := .F.	 				
	 		SetRestFault( 96, "Campo obrigatorio: Numero Doc." )
		Endif 
		If Empty( oJson:B7_DATA) 
		    lOk := .F.	 				
	 		SetRestFault( 97, "Campo obrigatorio: Validade." )
		Endif 
	    If Empty( oJson:B7_IDINV) 
		    lOk := .F.	 				
	 		SetRestFault( 97, "Campo obrigatorio: Identificador." )
		Endif 
	      
      IF lOk
	    dUiltCont:=dBusca4(oJson:B7_FILIAL,oJson:B7_COD,oJson:B7_LOCAL)
	    IF EMPTY(dUiltCont)
	       dUiltCont:=oJson:B7_DATA
	    Endif 	
	    cDOC :="" 
	    cDOC :='INV'+SUBSTR(dUiltCont,7,2)+SUBSTR(dUiltCont,5,2)+SUBSTR(dUiltCont,3,2)
	    nCont:=0
	    nCont:=nBusca3(oJson:B7_FILIAL,oJson:B7_COD,oJson:B7_LOCAL,cDOC,oJson:B7_DTVALID,dUiltCont,oJson:B7_LOTECTL) 
		ConOut(" nCont depois da busca3 "+str(nCont))
		If  nCont> 0
		    nCont:= nCont+1
		    ConOut(" nCont antes do delB7 "+str(nCont))
		    
		    delB7(oJson:B7_FILIAL,oJson:B7_COD,oJson:B7_LOCAL,cDOC,oJson:B7_DTVALID,dUiltCont,oJson:B7_LOTECTL)    	
		else
		    nCont:=1
		endif
		   	cEmpInv:=""
		   	cFilInv:=""
		   	cEmpInv:= substr(oJson:B7_FILIAL,1,2)
		   	cFilInv:= oJson:B7_FILIAL        
	        ConOut(Repl("-",80))
	        ConOut(PadC(OemToAnsi("Inclusao de inventario"),80))
			
	        RpcClearEnv()
	        RpcSetType( 3 )
	        RpcSetenv( cEmpInv,cFilInv,,,,GetEnvServer(),{"SB7"} )
	        
	        dbSelectArea('SB7')
	        dbSetOrder(1)
	        If RecLock('SB7', .t.)
	        	SB7->B7_FILIAL:=oJson:B7_FILIAL
	        	SB7->B7_TIPO:=cTipo		 
	        	SB7->B7_COD:=oJson:B7_COD 
	        	SB7->B7_DOC:=cDOC
	        	SB7->B7_QUANT:=Val(oJson:B7_QUANT)
	        	SB7->B7_LOCAL:=oJson:B7_LOCAL  
	        	SB7->B7_LOTECTL:=oJson:B7_LOTECTL
	        	SB7->B7_DTVALID:=SToD(oJson:B7_DTVALID)
	        	SB7->B7_LOCALIZ:=IIF(cCtrEnde='S',AllTrim(cLocaliz),'')
	        	SB7->B7_NUMSERI:=IIF(cCtrEnde='S',AllTrim(cNserie) ,'')
	        	SB7->B7_NUMDOC:=oJson:B7_NUMDOC
	        	SB7->B7_ORIGEM:="MATA270" 
	        	SB7->B7_STATUS:="01"  
	        	SB7->B7_IDINV:=oJson:B7_IDINV
	        	SB7->B7_DATA:=SToD(dUiltCont)
	        	SB7->B7_USERAPP:=SUBSTR(oJson:B7_IDINV,1,AT('@',oJson:B7_IDINV)-1)
	        	SB7->B7_ZCONT:=AllTrim(str(nCont))
	        EndIf
			MsUnLock()
	        
	        ConOut(PadC("Automatic routine successfully ended", 80))
			::SetResponse('{')
			::SetResponse('"Retorno"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse('OK')
			::SetResponse('"')
			::SetResponse('}')
	        
	        dbSelectArea('SB7')			
		EndIf
	EndIf
	
Return( lOk )

static function cBusca(cTabela, cCampo, cCampo1, cSearch)

Local cInfo  :=""
Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ+=" SELECT " + cCampo +" CAMPO " 
cQueryZ+=" FROM " + cTabela 
cQueryZ+=" WHERE "
cQueryZ+=cCampo1+"='" + cSearch + "'"
cQueryZ+=" AND "+cTabela+".D_E_L_E_T_ <> '*' "
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
IF (cArea)->CAMPO<>""
	cInfo:=(cArea)->CAMPO
endif
(cArea)->( dbCloseArea() )
return cInfo


static function cBusca2(cCampo, cFilB7,cProduto,cLocalB7,cLoteB7)

Local cInfo  :=""
Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ+=" SELECT " + cCampo +" CAMPO "  
cQueryZ+=" FROM SBF010 " 
cQueryZ+=" WHERE "
cQueryZ+=" 	   BF_FILIAL='"+cFilB7+ "'"
cQueryZ+=" AND BF_PRODUTO   ='" + cProduto + "'"
cQueryZ+=" AND BF_LOCAL     ='" + cLocalB7 + "'"
cQueryZ+=" AND BF_LOTECTL   ='" + cLoteB7  + "'"
cQueryZ+=" AND SBF010.D_E_L_E_T_ <> '*' "
cQueryZ := ChangeQuery(cQueryZ)			
	

dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
IF (cArea)->CAMPO<>""
	cInfo:=(cArea)->CAMPO
endif
(cArea)->( dbCloseArea() )
return cInfo


static function nBusca3(cB7_FILIAL,cB7_COD,cB7_LOCAL,cB7_DOC,cB7_DTVALID,cB7_DATA,cB7_LOTECTL)

Local nInfo  :=0
Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ+=" SELECT COUNT(B7_ZCONT) B7_ZCONT "  
cQueryZ+=" FROM SB7010 "
cQueryZ+=" WHERE "
cQueryZ+=" B7_FILIAL       ='" +cB7_FILIAL+ "' "
cQueryZ+=" AND B7_COD      ='" +cB7_COD+ "'"
cQueryZ+=" AND B7_LOCAL    ='" +cB7_LOCAL+ "'"
cQueryZ+=" AND B7_DOC      ='" +cB7_DOC+ "'"
cQueryZ+=" AND B7_DTVALID  ='" +cB7_DTVALID+ "'"
cQueryZ+=" AND B7_DATA     ='" +cB7_DATA+ "'"
cQueryZ+=" AND B7_LOTECTL  ='" +cB7_LOTECTL+ "'"
cQueryZ+=" AND D_E_L_E_T_ <> '*' "
memowrite("\maEmailBlk\sb7Ednei.txt",cQueryZ)
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
IF (cArea)->B7_ZCONT>0
	nInfo:=(cArea)->B7_ZCONT
endif
(cArea)->( dbCloseArea() )
return nInfo


static function dBusca4(cB7_FILIAL,cB7_COD,cB7_LOCAL)

Local dInfo  :=""
Local cArea	 :=""
Local cQueryZ:=""

cQueryZ:=""
cQueryZ+=" SELECT B2_DTINV "  
cQueryZ+=" FROM SB2010 "
cQueryZ+=" WHERE "
cQueryZ+=" B2_FILIAL       ='" +cB7_FILIAL+ "' "
cQueryZ+=" AND B2_COD      ='" +cB7_COD+ "'"
cQueryZ+=" AND B2_LOCAL    ='" +cB7_LOCAL+ "'"
cQueryZ+=" AND D_E_L_E_T_ <> '*' "
//memowrite("\maEmailBlk\sb7Edneidata.txt",cQueryZ)
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
IF !EMPTY((cArea)->B2_DTINV)
	dInfo:=(cArea)->B2_DTINV
endif
(cArea)->( dbCloseArea() )
return dInfo




static function delB7(cB7_FILIAL,cB7_COD,cB7_LOCAL,cB7_DOC,cB7_DTVALID,cB7_DATA,cB7_LOTECTL)

Local nRet:=0
Local cQuery2:=""

cQuery2:=""
cQuery2+=" UPDATE SB7010 SET  "
cQuery2+=" D_E_L_E_T_='*' "
cQuery2+=" WHERE "
cQuery2+=" B7_FILIAL       ='" +cB7_FILIAL+ "' "
cQuery2+=" AND B7_COD      ='" +cB7_COD+ "'"
cQuery2+=" AND B7_LOCAL    ='" +cB7_LOCAL+ "'"
cQuery2+=" AND B7_DOC      ='" +cB7_DOC+ "'"
cQuery2+=" AND B7_DTVALID  ='" +cB7_DTVALID+ "'"
cQuery2+=" AND B7_DATA     ='" +cB7_DATA+ "'"
cQuery2+=" AND B7_LOTECTL  ='" +cB7_LOTECTL+ "'"
cQuery2+=" AND D_E_L_E_T_ <> '*' "
//memowrite("\maEmailBlk\sb7EdneiDEL.txt",cQuery2)
nRet:=TcSqlExec(cQuery2)
If nRet<>0
	ConOut("Erro ao atualizar nome do medico no pedido" + TCSQLERROR())
Endif


return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RemovCharบAutor  ณ Augusto Ribeiro	 บ Data ณ  08/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Remove caracter especial                                   ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC Function RemovChar(cRet)
Local cRet

cRet	:= upper(cRet)

cRet	:= STRTRAN(cRet,"ม","A")
cRet	:= STRTRAN(cRet,"ษ","E")
cRet	:= STRTRAN(cRet,"อ","I")
cRet	:= STRTRAN(cRet,"ำ","O")
cRet	:= STRTRAN(cRet,"ฺ","U")
cRet	:= STRTRAN(cRet,"ภ","A")
cRet	:= STRTRAN(cRet,"ศ","E")
cRet	:= STRTRAN(cRet,"ฬ","I")
cRet	:= STRTRAN(cRet,"า","O")
cRet	:= STRTRAN(cRet,"ู","U")
cRet	:= STRTRAN(cRet,"ร","A")
cRet	:= STRTRAN(cRet,"ี","O")
cRet	:= STRTRAN(cRet,"ฤ","A")
cRet	:= STRTRAN(cRet,"ห","E")
cRet	:= STRTRAN(cRet,"ฯ","I")
cRet	:= STRTRAN(cRet,"ึ","O")
cRet	:= STRTRAN(cRet,"Ü","U")
cRet	:= STRTRAN(cRet,"ย","A")
cRet	:= STRTRAN(cRet,"ส","E")
cRet	:= STRTRAN(cRet,"ฮ","I")
cRet	:= STRTRAN(cRet,"ิ","O")
cRet	:= STRTRAN(cRet,"Û","U")
cRet	:= STRTRAN(cRet,"ว","C")   

Return(cRet)

