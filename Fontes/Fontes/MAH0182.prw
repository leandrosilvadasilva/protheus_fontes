#include 'protheus.ch'
#Include "TopConn.ch"


/*/
�����������������������������������������������������������������������������
���Programa  �MAH0182  � Autor �Ednei Rosa da Silva  � Data � 21-06-2021  ���
�������������������������������������������������������������������������͹��
���Descricao � Matriz de cliente x vendedor. 						      ���
���Descricao � Relaciona quais vendedores atendem um determinado cliente  ���
���Descricao � baseado por tipo, marca e grupo de produto. 				  ���
�������������������������������������������������������������������������͹��
���Sintaxe   � MAH0182()                                                  ���
�����������������������������������������������������������������������������
/*/


User Function MAH0182()

Local bOK  := "U_MAH0182A(M->ZA7_CODCLI, M->ZA7_LOJCLI ,M->ZA7_MARCA,M->ZA7_CODGRU,M->ZA7_CODVEN)"

AxCadastro("ZA7","Matriz de Cliente x Vendedor",,bOK)


Return


/*/
�����������������������������������������������������������������������������
���Programa  �MAH0182A  � Autor �Ednei Rosa da Silva  � Data � 21-06-2021 ���
�������������������������������������������������������������������������͹��
���Descricao � Verifica a integridade 								      ���
���Descricao � Verifica se ja existe essse registro na base de dados     ���
�������������������������������������������������������������������������͹��
���Sintaxe   � MAH0182A()                                                 ���
�����������������������������������������������������������������������������
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






