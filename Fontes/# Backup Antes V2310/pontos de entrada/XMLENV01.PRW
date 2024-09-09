#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} XMLENV01
description
@type function
@version  
@author dwt.luciano
@since 09/03/2023
@return variant, return_description
/*/
User Function XMLENV01()
Local aParam := {}
Local aProd := PARAMIXB[1] // Dados do produto
Local aDest := PARAMIXB[4] // Dados do tomador
Local aNota := PARAMIXB[5] // Dados da nota
Local aDupl := PARAMIXB[6] // Dados da duplicata
Local aDeduz := PARAMIXB[7] // Valores
Local aTotal := PARAMIXB[8] // Valor total
Local aISSQN := PARAMIXB[9] // Valor dos impostos
Local aAIDF := PARAMIXB[10] // Dados tabela AIDF
Local aInterm := PARAMIXB[11] // Dados do intermediário
Local aRetido := PARAMIXB[12] // Valores retidos
Local aDeducao := PARAMIXB[13] // Valores dedução
Local aConstr := PARAMIXB[14] // Dados construção civil

Local cMensCli := PARAMIXB[2] // Mensagem cliente
Local cMensFis := PARAMIXB[3] // Mensagem fiscal

    // -- DWT Luciano 20230209
      // Para o Municipio de Brasilia a serie obrigatoriamente tem que ser  3,  e
      // efetuamos um  workaround  onde temos a SERIE no Protheus como  003
    If FwCodFil() == "0107"
    
        aNota[ 1 ] := cValToChar( Val( aNota[1] ) )
    EndIf

    aParam := {aProd,cMensCli,cMensFis,aDest,aNota,aDupl,aDeduz,aTotal,aISSQN,aAIDF,aInterm,aRetido,aDeducao,aConstr}

Return aParam

