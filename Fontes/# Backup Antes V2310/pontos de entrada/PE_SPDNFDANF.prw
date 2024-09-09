#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
user function SPDNFDANF()
local cNota      := ParamIXB[1]
local cSerie     := ParamIXB[2]
local cChaveNfe  := ParamIXB[3]
local cPasta     := "C:\relato\"
Local cArea	     :=""
Local cQueryZ    :=""
Local cTipo      :=""
Local cEmaSol    :=""

ConOut(" Nota   : " + cNota)
ConOut(" Serie  : " + cSerie)
ConOut(" Chave  : " + cChaveNfe)
   
cQueryZ:=""   
cQueryZ+=" select D2_PEDIDO, "
cQueryZ+=" D2_FILIAL, "
cQueryZ+=" D2_TES, "
cQueryZ+=" D2_EMISSAO, "
cQueryZ+=" C5_NUM, "
cQueryZ+=" C5_FILIAL, "
cQueryZ+=" C5_VEND1,  "
cQueryZ+=" A3_EMAIL, "
cQueryZ+=" C5_ZCLIRET, "
cQueryZ+=" C5_ZLOJRET, "
cQueryZ+=" SA1.A1_COD,  "
cQueryZ+=" SA1.A1_LOJA,  "
cQueryZ+=" SA1.A1_ZEMAOPM  "	   
cQueryZ+=" from SD2010 SD2 " 
cQueryZ+=" Inner Join SC5010 SC5 ON ( SD2.D2_PEDIDO=SC5.C5_NUM AND SD2.D2_FILIAL=SC5.C5_FILIAL) "
cQueryZ+=" Inner Join SA3010 SA3 ON ( SC5.C5_VEND1=SA3.A3_COD) "
cQueryZ+=" Inner Join SA1010 SA1 ON ( SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA ) "
cQueryZ+=" WHERE       "
cQueryZ+=" SD2.D_E_L_E_T_<>'*' "
cQueryZ+=" AND  SC5.D_E_L_E_T_<>'*' "
cQueryZ+=" AND  SC5.D_E_L_E_T_<>'*' "
cQueryZ+=" AND  SD2.D2_DOC='" + cNota  + "'"
cQueryZ+=" AND  SD2.D2_SERIE='" +  cSerie  + "'"
cQueryZ := ChangeQuery(cQueryZ)			
	
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQueryZ), (cArea := GetNextAlias()), .F., .T. )
dbSelectArea(cArea)
//D2_TES IN ('697','722','')
If len(cChaveNfe)<>44
	
	ConOut(" NF nao autorizada Doc/Serie/Chave : " +cNota+'/'+cSerie+'/'+cChaveNfe)
	
	return nil

ENDIF


If DtoS(dDataBase)<> (cArea)->D2_EMISSAO

	return nil

endif   


If !ExistDir( "C:\relato" )
	MakeDir( "C:\relato" )
EndIf
cTipo:=''
cEmaSol:=''

IF (cArea)->D2_TES $ AllTrim(GETMV("ES_TESOPME"))
	cTipo:='remessa'
	u_zGerDanfe(cNota, cSerie, cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A3_EMAIL,(cArea)->A1_COD,(cArea)->A1_LOJA,'S',(cArea)->C5_FILIAL,(cArea)->C5_NUM)    
else

	cTipo:='faturamento'
	// Email do cliente solicitante 
	IF cRetNat((cArea)->C5_NUM,(cArea)->C5_FILIAL)='111102'
		cEmaSol := ''
	else
		cEmaSol:=cEcliRet( (cArea)->C5_ZCLIRET,(cArea)->C5_ZLOJRET)
		
	ENDIF
	

	u_zGerDanfe(cNota, cSerie, cPasta,(cArea)->C5_FILIAL+' - '+(cArea)->C5_NUM,cTipo,(cArea)->A1_ZEMAOPM+';'+(cArea)->A3_EMAIL+cEmaSol,(cArea)->A1_COD,(cArea)->A1_LOJA,'S',(cArea)->C5_FILIAL,(cArea)->C5_NUM) 
endif 
         
(cArea)->( dbCloseArea() )
return nil


Static Function cRetNat( cPedido,cFilPed)
Local cNatRet    := ""
Local cAliasTMP3 := 'TMP3'

BeginSql Alias cAliasTMP3
	SELECT C5_NATUREZ 
	FROM %Table:SC5% SC5 
	WHERE C5_FILIAL = %Exp:cFilPed%
	  AND C5_NUM    = %Exp:cPedido%
	  AND SC5.%notdel%
EndSql

cNatRet  := AllTrim((cAliasTMP3)->C5_NATUREZ )

(cAliasTMP3)->( dbCloseArea() )
Return( cNatRet )

// Email do cliente solicitante do retorno
Static Function cEcliRet( cCliente,cLoja)
Local cEmail     := ""
Local cAliasTMP4 := 'TMP4'

BeginSql Alias cAliasTMP4
	SELECT A1_ZEMAOPM 
	FROM %Table:SA1% SA1 
	WHERE A1_COD     = %Exp:cCliente%
	  AND A1_LOJA    = %Exp:cLoja%
	  AND SA1.%notdel%
EndSql

cEmail  := AllTrim((cAliasTMP4)->A1_ZEMAOPM)

(cAliasTMP4)->( dbCloseArea() )
Return( cEmail )



