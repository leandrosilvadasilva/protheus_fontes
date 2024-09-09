#INCLUDE 'TOTVS.ch'

/*--------------------------------------------------------------------------------------------------*
| Func:  SF1140I()                                                     							                |
| Autor: Valmor Marchi                                              								                |
| Data:  08/02/2022                                                   								              |
| Desc:  Este ponto de entrada pertence à rotina de PRÉ-NOTA (MATA140). Ele é executado na inclusão |
|        e alteração da Pré-Nota de Entrada                                                        |
|		                                                                          					            |
|																								                                                  	|
| Alterações .:  /                                                            					            |
*--------------------------------------------------------------------------------------------------*/

User Function SF1140I()
    Local _aPreNF := {}
    Local _nX := 0
    Local _sTpNf := cTipo
    Local _sNumNF := cNFiscal
    Local _sFormProp := cFormul
    Local _sSerie := cSerie
    Local _dEmissao := dDEmissao
    Local _sCodForn := cA100For
    Local _sLojaForn := cLoja
    Local _sEspecie := cEspecie
    Local _sUFForn := cUFOrigP

    Local tipoValid := .T. // TIPOS VALIDOS PARA INGEGRAÇÃO = M1, M2, M3, M4, M5


    /*PARAMIXB[1]: Informa se está sendo realizada a inclusão do pré-documento de entrada.
      PARAMIXB[2]: informa se está sendo realizada alteração do pré-documento de entrada.
    */
    For _nX := 1 to len(aCols)
      //Envia alterações de cadastro para o WMS (AKR)
      
      If !(aCols[_nX,Len(aHeader)+1]) //IATAN EM 28/07/2022 - NÃO ENVIAR PARA O WMS ITENS DELETADOS

        _sNomeForn := Posicione("SA2",1,xFilial("SA2")+_sCodForn+_sLojaForn, "A2_NOME")
        produto    := POSICIONE("SB1", 1, XFILIAL("SB1")+GdFieldGet("D1_COD",_nX), "B1_DESC")

       // IATAN EM 20/07/2023 - SOMENTE OS TIPOS ABAIXO DEVEM SER INTEGRADOS CONFORME REGRA DEFINIDA PELO EDER
       // IATAN EM 10/08/2023 - INCLUITO ESPECIE SPED DO CABECALHO DA NOTA
        IF SB1->B1_TIPO $ "M1-M2-M3-M4-M5" .AND. ALLTRIM(SF1->F1_ESPECIE) = 'SPED'

        ELSE
            tipoValid := .F.
            CONOUT("SAINDO DA ROTINA POIS OS PRDUTOS NÃO POSSUEM TIPO ENTRE M1,M2,M3,M4,M5 OU ESPECIE = SPED")
            RETURN
        ENDIF
        
        AADD(_aPreNF,{{"FILIAL", CEMPANT+CFILANT},;
                    {"NUMDOC", _sNumNF},;
                    {"SERIEDOC", _sSerie},;
                    {"EMISSAO" , _dEmissao},;
                    {"NROITEM" , GdFieldGet("D1_ITEM",_nX)},;
                    {"CODITEM" , GdFieldGet("D1_COD",_nX)},;
                    {"DESCITEM", Posicione("SB1",1,xFilial("SB1")+GdFieldGet("D1_COD",_nX),"B1_DESC")},;  
                    {"REFERENCIA", GdFieldGet("D1_COD",_nX)},; //Opcional
                    {"TAMANHO"   , ""},;   // Opcional
                    {"CODFORNEC" , _sCodForn + _sLojaForn},;
                    {"NOMEFORNEC", _sNomeForn},;  
                    {"CODFABRIC" , ""},;  //Opcional  
                    {"NOMEFABRIC", ""},; //Opcional
                    {"QTDE"      , GdFieldGet("D1_QUANT",_nX)},;
                    {"DOCSTATUS" , "O"},;  // O: Aberto, C: Fechado 
                    {"TIPO"      , ""},;      //Opcional
                    {"DATAFABRIC", GdFieldGet("D1_DFABRIC",_nX)},;      //Opcional
                    {"DATAVALID" , GdFieldGet("D1_DTVALID",_nX)},;      //Opcional
                    {"LOTE"      , GdFieldGet("D1_LOTECTL",_nX)};    //Opcional 
        })
      ENDIF
    Next


    //Envia os dados do cliente para o WMS
    U_MAPWMS05(_aPreNF)

Return
