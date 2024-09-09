

#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


USER FUNCTION ZA9()

Local cFiltro   := ""
PRIVATE cAlias   := 'ZA9'
PRIVATE cCadastro := "Cadastro Filial x Centro de Custo x Aprovador"
PRIVATE aRotina   := {}
//Private aCores := {} 


    AADD(aRotina, { "Pesquisar" , "AxPesqui", 0, 1 })
    AADD(aRotina, { "Visualizar", "AxVisual", 0, 2 })
    AADD(aRotina, { "Incluir"   , "U_ZA9INC", 0, 3 })
    AADD(aRotina, { "Alterar"   , "AxAltera", 0, 3 })
    AADD(aRotina, { "Excluir"   , "AxDeleta", 0, 5 })

dbSelectArea("ZA9")
dbSetOrder(1)
mBrowse( ,,,,"ZA9",,,,,,,,,,,,,,cFiltro)

RETURN NIL


USER FUNCTION ZA9INC()

    ALTERA := .F.

RETURN AxInclui("ZA9",0,3,,,,"U_ZA9VAL()")


User Function ZA9VAL()

    lRet := .F.
    aArea := GetArea()

    DbSelectArea("ZA9")
    DbSetOrder(1)
    DbGoTop()

    If dbSeek(xFilial("ZA9")+M->ZA9_CC)  // Se achou retorna F pois não pode dar chave duplicada
        lRet := .F. 
        alert("Já existe o cadastro desse Centro de Custo nesta Filial.")
    Else
        lRet := .T.
    Endif

RestArea(aArea)

Return(lRet)
