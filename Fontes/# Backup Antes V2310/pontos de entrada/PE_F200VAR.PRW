#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} F200VAR
Manipular as informa��es (vari�veis) no retorno do Cnab a Receber (FINA200). 

@PARAMIXB aDados[1] = N�mero do T�tulo    | Variavel de origem: cNumTit
          aDados[2] = Data da Baixa       | Variavel de origem: dBaixa
		  aDados[3] = Tipo do T�tulo 	  | Variavel de origem: cTipo
		  aDados[4] = Nosso N�mero 		  | Variavel de origem: cNsNum
          aDados[5] = Valor da Despesa    | Variavel de origem: nDespes
          aDados[6] = Valor do Desconto   | Variavel de origem: nDescont
          aDados[7] = Valor do Abatimento | Variavel de origem: nAbatim
          aDados[8] = Valor Recebido  	  | Variavel de origem: nValRec
          aDados[9] = Juros 			  | Variavel de origem: nJuros
          aDados[10] = Multa 			  | Variavel de origem: nMulta
          aDados[11] = Outras Despesas    | Variavel de origem: nOutrDesp
          aDados[12] = Valor do Credito   | Variavel de origem: nValCc
          aDados[13] = Data do Credito    | Variavel de origem: dDataCred
          aDados[14] = Ocorr�ncia         | Variavel de origem: cOcorr
          aDados[15] = Motivo do banco    | Variavel de origem: cMotBan
          aDados[16] = Linha Inteira      | Variavel de origem: xBuffer
          aDados[17] = Data de Vencimento | Variavel de origem: dDtVc

/*/
//-------------------------------------------------------------------------------

User Function F200VAR()
Local aDados := PARAMIXB

    VarInfo( "Dados Retorno CNAB", aDados )
    VarInfo( "Dados Retorno CNAB", nValRec )    
    VarInfo( "Dados Retorno CNAB", nJuros )    
    
    nValRec := nValRec + nJuros
    
    VarInfo( "Dados Retorno CNAB", nValRec )

Return(aDados)


