#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"

/*
    IATAN EM 20/07/2022
*/

User Function MTA140MNU 
    aAdd(aRotina,{ "Integrar WMS", "U_ENVWMS", 0 , 2, 0, .F.})  
Return

USER FUNCTION ENVWMS

    Local _aPreNF := {}

    IF ALLTRIM(SF1->F1_ESPECIE) <> 'SPED'

        ALERT("Somente o tipo 'SPED' pode ser integrado para o WMS.") 
        ALERT("INTEGRAÇÃO LIBERADA TEMPORARIAMENTE PARA TESTES")
        //RETURN

    ENDIF



	cQuery := " SELECT * FROM " + RetSqlName("SD1" ) + " SD1 " 
    cQuery += " WHERE D_E_L_E_T_ <> '*' AND D1_FILIAL = '" + SF1->F1_FILIAL + "' AND D1_DOC = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"' AND D1_FORNECE = '"+SF1->F1_FORNECE+"' AND D1_LOJA = '"+SF1->F1_LOJA+"'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_SD1",.T.,.T. )
    DbSelectArea("TRB_SD1")
    DbGoTop( )

    While TRB_SD1->(!EOF())

      _sNomeForn := Posicione("SA2",1,xFilial("SA2")+TRB_SD1->D1_FORNECE+TRB_SD1->D1_LOJA, "A2_NOME")
      
        // iatan em 20/07/2023
        IF ALLTRIM(TRB_SD1->D1_TP) $ "M1-M2-M3-M4-M5-AI"

        ELSE

            ALERT("Somente os tipos de produto 'M1,M2,M3,M4,M5,AI' podem ser integrados para o WMS.") 
            ALERT("INTEGRAÇÃO LIBERADA TEMPORARIAMENTE PARA TESTES")
            //RETURN

        ENDIF

      AADD(_aPreNF,{{"FILIAL", CEMPANT+CFILANT},;
                  {"NUMDOC", TRB_SD1->D1_DOC},;
                  {"SERIEDOC", TRB_SD1->D1_SERIE},;
                  {"EMISSAO" , STOD(TRB_SD1->D1_EMISSAO)},;
                  {"NROITEM" , TRB_SD1->D1_ITEM},;
                  {"CODITEM" , TRB_SD1->D1_COD},;
                  {"DESCITEM", Posicione("SB1",1,xFilial("SB1")+TRB_SD1->D1_COD,"B1_DESC")},;  
                  {"REFERENCIA", TRB_SD1->D1_COD},; //Opcional
                  {"TAMANHO"   , ""},;   // Opcional
                  {"CODFORNEC" , TRB_SD1->D1_FORNECE + TRB_SD1->D1_LOJA},;
                  {"NOMEFORNEC", _sNomeForn},;  
                  {"CODFABRIC" , ""},;  //Opcional  
                  {"NOMEFABRIC", ""},; //Opcional
                  {"QTDE"      , TRB_SD1->D1_QUANT},;
                  {"DOCSTATUS" , "O"},;  // O: Aberto, C: Fechado 
                  {"TIPO"      , ""},;      //Opcional
                  {"DATAFABRIC", STOD(TRB_SD1->D1_DFABRIC)},;      //Opcional
                  {"DATAVALID" , STOD(TRB_SD1->D1_DTVALID)},;      //Opcional
                  {"LOTE"      , TRB_SD1->D1_LOTECTL};    //Opcional 
      })


        TRB_SD1->(dbSkip())
    EndDo
    TRB_SD1->(dbCloseArea())
    
        //Envia os dados do cliente para o WMS
    retorno := U_MAPWMS05(_aPreNF)

    IF retorno[1] == .T.
        alert("SUCESSO NO ENVIO AO WMS")
    ELSE
        ALERT("ERRO NO ENVIO AO WMS.")
        ALERT(retorno[2])
    ENDIF

RETURN


// IATN EM 18/05/2023
Static Function validaTipo()
  Local _cQry := ""
  Local _bContinua := .T.

  _cQry := " SELECT D1_DOC, D1_SERIE, D1_FORNECE,D1_ITEM, D1_COD, D1_QUANT, D1_LOTECTL, D1_QUANT1, D1_LOTE1, D1_CONFWMS "
  _cQry += "   FROM SD1010 SD1 INNER JOIN SF1010 SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA "
  _cQry += "   WHERE SD1.D_E_L_E_T_ <> '*' AND SF1.D_E_L_E_T_ <> '*'  "
  _cQry += "    AND D1_DOC = '"+SF1->F1_DOC+"' "
  _cQry += "    AND D1_SERIE = '"+SF1->F1_SERIE+"' "
  _cQry += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'"
 // _cQry += "    AND F1_ESPECIE = 'SPED' "
 // _cQry += "    AND D1_TP IN ('M1', 'M2', 'M3', 'M4', 'M5') "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SD1",.T.,.T. )
  
  While (_SD1->(!EOF()))
    IF _SD1->D1_TP $ "M1-M2-M3-M4-M5-AI"

    ELSE
        _bContinua := .F.
    ENDIF
    _SD1->(DbSkip())
  End
  _SD1->(DBCloseArea())

Return _bContinua
