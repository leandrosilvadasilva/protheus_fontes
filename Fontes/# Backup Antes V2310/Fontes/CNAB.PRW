#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAGNOS    ºAutor  ³OSMIL MICROSIGA     º Data ³  12/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PROGRAMA PARA TRATAMENTO DO NOSSO NUMERO                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 - HOSPITAL SANTA CRUZ                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PAGNOS()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt( "_RETNOS," )

//// RETORNA O NOSSO NUMERO QUANDO COM VALOR NO E2_CODBAR, E ZEROS QUANDO NAO
//// TEM VALOR POSICAO ( 142 - 150 )

IF SUBS( SE2->E2_CODBAR, 01, 3 ) != "237"
    _RETNOS := "000000000"
Else
    _RETNOS := SUBS(SE2->E2_CODBAR,28,9)
EndIf

Return( _RETNOS )

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAGCAR    ºAutor  ³Osmil Squarcine     º Data ³  12/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PROGRAMA PARA SELECIONAR A CARTEIRA NO CODIGO DE BARRAS     º±±
±±º          ³QUANDO NAO TIVER TEM QUE SER COLOCADO "00"                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 - HOSPITAL SANTA CRUZ                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PAGCAR()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt( "_RETCAR," )

////  PROGRAMA PARA SELECIONAR A CARTEIRA NO CODIGO DE BARRAS QUANDO
////  NAO TIVER TEM QUE SER COLOCADO "00"

IF SUBS( SE2->E2_CODBAR, 01, 3 ) != "237"
   _Retcar := "000"
Else
   _Retcar := "0" + SUBS(SE2->E2_CODBAR,24,2)
EndIf

Return( _Retcar )

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAGDOC    ºAutor  ³OSMIL SQUARCINE     º Data ³  12/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ GRAVACAO DE INFORMACOES COMPLEMENTARES                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 - HOSPITAL SANTA CRUZ                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// INFORMAÇÕES COMPLEMENTARES
User Function PAGDOC()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt( "_Doc,_Mod," )
/////  PROGRAMA GRAVAR AS INFORMACOES COMPLEMENTARES
/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (374-413)

_Mod := SUBSTR( SEA->EA_MODELO, 1, 2 )

IF _Mod == "  "
   IF SUBSTR( SE2->E2_CODBAR, 1, 3 ) == "237"
      _Mod == "30"
   ELSE
      _Mod == "31"
   ENDIF
ENDIF

DO CASE
   CASE _Mod == "03" .OR. _Mod == "07" .OR. _Mod == "08"
	    /*_Doc := IIF(SA2->A2_CGCPG==SM0->M0_CGC,"D","C")+"000000"+"01"+"01"+SPACE(29)*/
        _Doc := IIF( SA2->A2_CGC == "03094114000136", "D", "C" ) + "000000" + "01" + "01" + SPACE( 29 )
   CASE _Mod == "31"
        _Doc := SUBSTR( SE2->E2_CODBAR, 20, 25 ) + SUBSTR( SE2->E2_CODBAR, 5, 1 ) + SUBSTR( SE2->E2_CODBAR, 4, 1 ) + SPACE( 13 )
   OTHERWISE
        _Doc := SPACE( 40 )
ENDCASE

Return( _Doc )       

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CODBAR    ºAutor  ³Osmil Squarcine     º Data ³  12/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PROGRAMA PARA TRATAMENTO DO CAMPO E2_CODBAR PARA UTILIZACAOº±±
±±º          ³ DO PAGFOR                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - HOSPITAL SANTA CRUZ                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

///--------------------------------------------------------------------------\
//| Função: CODBAR				Autor: Osmil Squarcine       Data: 12/06/05  |
//|--------------------------------------------------------------------------|
//| Essa Função foi desenvolvida com base no Manual do Bco. Itaú e no RDMAKE:|
//| CODBARVL - Autor: Vicente Sementilli - Data: 26/02/1997.                 |
//|--------------------------------------------------------------------------|
//| Descrição: Função para Validação de Código de Barras (CB) e Representação|
//|            Numérica do Código de Barras - Linha Digitável (LD).	         |
//|                                                                          |
//|            A LD de Bloquetos possui três Digitos Verificadores (DV) que  |
//|				são consistidos pelo Módulo 10, além do Dígito Verificador   |
//|				Geral (DVG) que é consistido pelo Módulo 11. Essa LD têm 47  |
//|            Dígitos.                                                      |
//|                                                                          |
//|            A LD de Títulos de Concessinárias do Serviço Público e IPTU   |
//|				possui quatro Digitos Verificadores (DV) que são consistidos |
//|            pelo Módulo 10, além do Digito Verificador Geral (DVG) que    |
//|            também é consistido pelo Módulo 10. Essa LD têm 48 Dígitos.   |
//|                                                                          |
//|            O CB de Bloquetos e de Títulos de Concessionárias do Serviço  |
//|            Público e IPTU possui apenas o Dígito Verificador Geral (DVG) |
//|            sendo que a única diferença é que o CB de Bloquetos é         |
//|            consistido pelo Módulo 11 enquanto que o CB de Títulos de     |
//|            Concessionárias é consistido pelo Módulo 10. Todos os CB´s    |
//|            têm 44 Dígitos.                                               |
//|                                                                          |
//|            Para utilização dessa Função, deve-se criar o campo E2_CODBAR,|
//|            Tipo Caracter, Tamanho 48 e colocar na Validação do Usuário:  |
//|            EXECBLOCK("CODBAR",.T.).                                      |
//|                                                                          |
//|            Utilize também o gatilho com a Função CONVLD() para converter |
//|            a LD em CB.													 |
//\--------------------------------------------------------------------------/

USER FUNCTION CODBAR()

SETPRVT( "cStr, lRet, cTipo, nConta, nMult, nVal, nDV, cCampo, i, nMod, nDVCalc" )

// Retorna .T. se o Campo estiver em Branco.
IF VALTYPE( M->E2_CODBAR ) == NIL .OR. EMPTY( M->E2_CODBAR )
	RETURN(.T.)
ENDIF

cStr := LTRIM( RTRIM( M->E2_CODBAR ) )

// Se o Tamanho do String for 45 ou 46 está errado! Retornará .F.
lRet := IF( LEN( cStr ) == 45 .OR. LEN( cStr ) == 46, .F., .T. )

// Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
// necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.
cStr := IF( LEN( cStr ) < 44, cStr + REPL( "0", 47 - LEN( cStr ) ), cStr )

// Verifica se a LD é de (B)loquetos ou (C)oncessionárias/IPTU. Se for CB retorna (I)ndefinido.
cTipo := IF( LEN( cStr ) == 47, "B", IF( LEN( cStr ) == 48, "C", "I" ) )

// Verifica se todos os dígitos são numérios.
FOR i := LEN( cStr ) TO 1 STEP -1
	lRet := IF( SUBSTR( cStr, i, 1 ) $ "0123456789", lRet, .F. )
NEXT

IF LEN( cStr ) == 47 .AND. lRet
	// Consiste os três DV´s de Bloquetos pelo Módulo 10.
	nConta  := 1
	
	WHILE nConta <= 3
		nMult  := 2
		nVal   := 0
		nDV    := VAL( SUBSTR( cStr, IF( nConta == 1, 10, IF( nConta == 2, 21, 32 ) ), 1 ) )
		cCampo := SUBSTR( cStr, IF( nConta == 1, 1, IF( nConta == 2, 11, 22 ) ), IF( nConta == 1, 9, 10 ) )
		
		FOR i := LEN( cCampo ) TO 1 STEP -1
			nMod  := VAL( SUBSTR( cCampo, i, 1 ) ) * nMult
			nVal  := nVal + IF( nMod > 9, 1, 0 ) + ( nMod - IF( nMod > 9, 10, 0 ) )
			nMult := IF( nMult == 2, 1, 2 )
		NEXT
		
		nDVCalc := 10 - MOD( nVal, 10 )
		// Se o DV Calculado for 10 é assumido 0 (Zero).
		nDVCalc := IF( nDVCalc == 10, 0, nDVCalc )
		lRet    := IF( lRet,( nDVCalc == nDV ), .F. )
		nConta  := nConta + 1
	ENDDO
	
	// Se os DV´s foram consistidos com sucesso (lRet=.T.), converte o número para CB para consistir o DVG.
	cStr := IF( lRet, SUBSTR( cStr, 1, 4 ) + SUBSTR( cStr, 33, 15 ) + SUBSTR( cStr, 5, 5 ) + SUBSTR( cStr, 11, 10 ) + SUBSTR( cStr, 22, 10 ), cStr )

ENDIF

IF LEN( cStr ) == 48 .AND. lRet
	// Consiste os quatro DV´s de Títulos de Concessionárias de Serviço Público e IPTU pelo Módulo 10.
	nConta  := 1
	
	WHILE nConta <= 4
		nMult  := 2
		nVal   := 0
		nDV    := VAL( SUBSTR( cStr, IF( nConta == 1, 12, IF( nConta == 2, 24, IF( nConta == 3, 36, 48 ) ) ), 1 ) )
		cCampo := SUBSTR( cStr, IF( nConta == 1, 1, IF( nConta == 2, 13, IF( nConta == 3, 25, 37 ) ) ), 11 )
		
		FOR i := 11 TO 1 STEP -1
			nMod  := VAL( SUBSTR( cCampo, i, 1 ) ) * nMult
			nVal  := nVal + IF( nMod > 9, 1, 0 ) + ( nMod - IF( nMod > 9, 10, 0 ) )
			nMult := IF( nMult == 2, 1, 2 )
		NEXT
		
		nDVCalc := 10 - MOD( nVal, 10 )
		
		// Se o DV Calculado for 10 é assumido 0 (Zero).
		nDVCalc := IF( nDVCalc == 10, 0, nDVCalc )
		lRet    := IF( lRet,( nDVCalc == nDV ), .F. )
		nConta  := nConta + 1
	ENDDO
	
	// Se os DV´s foram consistidos com sucesso (lRet=.T.), converte o número para CB para consistir o DVG.
	cStr := IF( lRet, SUBSTR( cStr, 1, 11 ) + SUBSTR( cStr, 13, 11 ) + SUBSTR( cStr, 25, 11 ) + SUBSTR( cStr, 37, 11 ), cStr )

ENDIF

IF LEN( cStr ) == 44 .AND. lRet
	IF cTipo $ "BI"
		// Consiste o DVG do CB de Bloquetos pelo Módulo 11.
		nMult  := 2
		nVal   := 0
		nDV    := VAL( SUBSTR( cStr, 5, 1 ) )
		cCampo := SUBSTR( cStr, 1, 4 ) + SUBSTR( cStr, 6, 39 )
		
		FOR i := 43 TO 1 STEP -1
			nMod  := VAL( SUBSTR( cCampo, i, 1 ) ) * nMult
			nVal  := nVal + nMod
			nMult := IF( nMult == 9, 2, nMult + 1 )
		NEXT
		
		nDVCalc := 11 - MOD( nVal, 11 )
		
		// Se o DV Calculado for 0,10 ou 11 é assumido 1 (Um).
		nDVCalc := IF( nDVCalc == 0 .OR. nDVCalc == 10 .OR. nDVCalc == 11, 1, nDVCalc )
		lRet    := IF( lRet, ( nDVCalc == nDV ), .F. )
		
		// Se o Tipo é (I)ndefinido E o DVG NÂO foi consistido com sucesso (lRet=.F.), tentará
		// consistir como CB de Título de Concessionárias/IPTU no IF abaixo.
	ENDIF
	
	IF cTipo == "C" .OR. ( cTipo == "I" .AND. !lRet )
		// Consiste o DVG do CB de Títulos de Concessionárias pelo Módulo 10.
		lRet   := .T.
		nMult  := 2
		nVal   := 0
		nDV    := VAL( SUBSTR( cStr, 4, 1 ) )
		cCampo := SUBSTR( cStr, 1, 3 ) + SUBSTR( cStr, 5, 40 )
	
		FOR i := 43 TO 1 STEP -1
			nMod  := VAL( SUBSTR( cCampo, i, 1 ) ) * nMult
			nVal  := nVal + IF( nMod > 9, 1, 0 ) + ( nMod - IF( nMod > 9, 10, 0 ) )
			nMult := IF( nMult == 2, 1, 2 )
		NEXT
		
		nDVCalc := 10 - MOD( nVal, 10 )
		
		// Se o DV Calculado for 10 é assumido 0 (Zero).
		nDVCalc := IF( nDVCalc == 10, 0, nDVCalc )
		lRet    := IF( lRet,( nDVCalc == nDV ), .F. )
	ENDIF
ENDIF

IF !lRet
	HELP( " ", 1, "ONLYNUM" )
ENDIF

RETURN( lRet )

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONVLD    ºAutor  ³Osmil Squarcine     º Data ³  12/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CONVERSAO DE LINHA DIGITAVEL PARA CODIGO DE BARRAS          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 - HOSPITAL SANTA CRUZ                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

///--------------------------------------------------------------------------\
//| Função: CONVLD				Autor: Microsiga            Data: 19/10/2003 |
//|--------------------------------------------------------------------------|
//| Descrição: Função para Conversão da Representação Numérica do Código de  |
//|            Barras - Linha Digitável (LD) em Código de Barras (CB).       |
//|                                                                          |
//|            Para utilização dessa Função, deve-se criar um Gatilho para o |
//|            campo E2_CODBAR, Conta Domínio: E2_CODBAR, Tipo: Primário,    |
//|            Regra: EXECBLOCK("CONVLD",.T.), Posiciona: Não.               |
//|                                                                          |
//|            Utilize também a Validação do Usuário para o Campo E2_CODBAR  |
//|            EXECBLOCK("CODBAR",.T.) para Validar a LD ou o CB.            |
//\--------------------------------------------------------------------------/

USER FUNCTION CONVLD()

SETPRVT( "cStr" )

cStr := LTRIM( RTRIM( M->E2_CODBAR ) )

IF VALTYPE( M->E2_CODBAR ) == NIL .OR. EMPTY( M->E2_CODBAR )
	// Se o Campo está em Branco não Converte nada.
	cStr := ""
ELSE
	// Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
	// necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.
	cStr := IF( LEN( cStr ) < 44, cStr + REPL( "0", 47 - LEN( cStr ) ), cStr )
ENDIF

DO CASE
	CASE LEN( cStr ) == 47
		cStr := SUBSTR( cStr, 1, 4 ) + SUBSTR( cStr, 33, 15 ) + SUBSTR( cStr, 5, 5 ) + SUBSTR( cStr, 11, 10 ) + SUBSTR( cStr, 22, 10 )
	CASE LEN( cStr ) == 48
		cStr := SUBSTR( cStr, 1, 11 ) + SUBSTR( cStr, 13, 11 ) + SUBSTR( cStr, 25, 11 ) + SUBSTR( cStr, 37, 11 )
	OTHERWISE
		cStr := cStr + SPACE( 48 - LEN( cStr ) )
ENDCASE

RETURN( cStr )

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATORVENC() ºAutor  ³ Filipe Bertol º Data ³  16/02/102   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Refere-se a posição 6 a 9 do código de barras ou os 4 (quatro)  ±±
±±       ³ primeiros caracteres do 5º campo da Linha Digitável, quando     ±±
±±       ³ diferente de zeros.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGASUL                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FATORVENC()
	
	Local  cCodBar := AllTrim( SE2->E2_CODBAR  )
	Local  cRet    := ''
	
	// Linha Digitavel
	If ( Len( cCodBar ) > 44 ) .And. !( "0" $ Substr( cCodBar, 34, 4 ) )
		cRet := Substr( cCodBar, 34, 4 )
	Else
		// Codigo de Barra pelo Leitor 44 posicoes                                                                                                                                                                                                                                            
		cRet := Substr( cCodBar, 6, 4 )
	EndIf        	

Return( cRet )

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAGVAL    ºAutor  ³OSMIL SQUARCINE     º Data ³  31/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PROGRAMA PARA TRATAMENTO DO ENVIO DO VALOR NO PAGFOR        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 - HOSPITAL SANTA CRUZ                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// VALOR DO DOCUMENTO
User Function PAGVAL()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// *** Variáveis ***
// Private _VALOR := 0
Public _VALOR := 0 

/// VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19, NO ARQUIVO E
/// DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DE BARRA VAI O VALOR DO SE2
_VALOR := Replicate( "0", 15 )

IF SUBSTR( SE2->E2_CODBAR, 1, 3 ) == "   "
    _VALOR :=  STRZERO( ( SE2->E2_SALDO * 100 ),15 ,0 )
Else
    _VALOR  :=  "0" + SUBSTR( SE2->E2_CODBAR, 6, 14 )
Endif

Return( _VALOR )    

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
