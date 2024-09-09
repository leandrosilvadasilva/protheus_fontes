#include 'protheus.ch'
#Include "TopConn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MAH0182  º Autor ³Ednei Rosa da Silva  º Data ³ 21-06-2021  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Matriz de cliente x vendedor. 						      º±±
±±ºDescricao ³ Relaciona quais vendedores atendem um determinado cliente  º±±
±±ºDescricao ³ baseado por tipo, marca e grupo de produto. 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ MAH0182()                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function MAH0182()

Local bOK  := "U_MAH0182A(M->ZA7_CODCLI, M->ZA7_LOJCLI ,M->ZA7_MARCA,M->ZA7_CODGRU,M->ZA7_CODVEN)"

AxCadastro("ZA7","Matriz de Cliente x Vendedor",,bOK)


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MAH0182A  º Autor ³Ednei Rosa da Silva  º Data ³ 21-06-2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica a integridade 								      º±±
±±ºDescricao ³ Verifica se ja existe essse registro na base de dados     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ MAH0182A()                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MAH0182A(cCliente, cLoja ,cMarca,cGrupo,cVendedor)

Local lOk		:= .F.
Local cAliasX	:= GetNextAlias()


IF  EMPTY(cCliente)
    ALERT ('Preencha o codigo do cliente!') 
	lOk := .F.
	return lOk
ENDIF
IF  EMPTY(cLoja)
    ALERT ('Preencha a loja do cliente!') 
	lOk := .F.
	return lOk
ENDIF
IF  EMPTY(cMarca)
    ALERT ('Preencha a marca do produto!') 
	lOk	:= .F.
	return lOk
ENDIF
IF  EMPTY(cGrupo)
    ALERT ('Preencha o grupo do produto!') 
	lOk := .F.
	return lOk
ENDIF
IF  EMPTY(cVendedor)
    ALERT ('Preencha o vendedor para o cliente!') 
	lOk := .F.
	return lOk
ENDIF

IF INCLUI 
	// Verifica se ja existe essse registro na base de dados 
	BeginSql  Alias cAliasX
	SELECT COUNT(ZA7_CODCLI) QTD_REG
	FROM %Table:ZA7% ZA7
	WHERE 
	  ZA7_CODCLI    = %Exp:cCliente%  AND  
	  ZA7_LOJCLI    = %Exp:cLoja% AND 
	  ZA7_MARCA     = %Exp:cMarca% AND 
	  ZA7_CODGRU    = %Exp:cGrupo% AND 
	  ZA7_CODVEN    = %Exp:cVendedor% AND 
	  ZA7.%notdel%  
	EndSql
	  // verifi se e xiste registro
	  IF (cAliasX)->QTD_REG>0
	     lOk		:= .T.
	  Endif
	( cAliasX  )->( dbCloseArea() )
ENDIF

return lOk 






