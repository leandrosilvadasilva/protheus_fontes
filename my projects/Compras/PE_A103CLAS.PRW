#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A103CLAS
Permite manipular os itens da aCols de entradas
@type function
@version 1.0 
@author DWT Luciano
@since 15/12/2023
@see https://tdn.totvs.com/display/public/PROT/A103CLAS+-+Permite+manipular+o+Item+do+Acols
/*/
User function A103CLAS()
Local cALiasSD1     := PARAMIXB[1]
Local aArea         := FWGetArea()
Local nPosTES       := GetPosSD1("D1_TES" ) // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_OPER' })
Local nPosProduto   := GetPosSD1("D1_COD" ) // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_LOCAL' })
Local nPosItem      := GetPosSD1("D1_ITEM" ) // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_ITEM' })
Local nPosDtValid   := GetPosSD1("D1_DTVALID" ) // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_ITEM' })

Local lNotaEIC      := (SF1->F1_IMPORT == "S" .or. AllTrim(SF1->F1_ORIGEM) == "SIGAEIC" .or. !Empty(SF1->F1_HAWB))
Local lPrimeiraNota := SF1->F1_TIPO == "N"
Local nTamACols     := Len( aCols )
Local lExecAuto     := l103Auto

    // Se não vir por  EXECAUTO
    If !lExecAuto

        If  lNotaEIC  .and.  lPrimeiraNota

            // Variavel publica da Especie do documento que tem que vir como SPED quado for a primeira nota
            cEspecie := "SPED"

            cTes := DecideQualTES( nPosProduto, nPosTES, nTamACols )
            aCols[ nTamACols, nPosTES ] := cTes

            A103Trigger('D1_TES')
            If ExistTrigger('D1_TES') // verifica se existe trigger para este campo
                RunTrigger(2,Len(aCols),,"D1_TES") 
            EndIf
            
            A103Trigger('D1_CLASFIS')
            If ExistTrigger('D1_CLASFIS') // verifica se existe trigger para este campo
                RunTrigger(2,Len(aCols),,"D1_CLASFIS") 
            endIf

            aCols[ nTamACols, nPosDtValid ] := YearSum( DDEMISSAO, 10 )
        EndIf
	EndIf

FWRestArea( aArea )
Return 

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 26/12/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function DecideQualTES( nPosProduto, nPosTES, nTamACols )
Local lRetorno  := .T.
Local cProduto  := aCols[ nTamACols, nPosProduto ]
Local cQuery    := ""
Local cAliasSYD := GetNextAlias()
Local nqtdReg   := 0
Local nPercIPI  := 0
Local cTES      := aCols[ nTamACols, nPosTES ] 
Local nIPIPerc  := 0

    BEGINSQL Alias cAliasSYD 

        SELECT SYD.YD_PER_COF, SYD.YD_VLU_COF, SYD.YD_TEC, SB1.B1_COD, SB1.B1_POSIPI, SB1.B1_IPI
          FROM %Table:SYD% SYD, %Table:SB1% SB1
         WHERE 1=1
           AND SYD.%NotDel% AND SB1.%NotDel%
           AND SYD.YD_FILIAL = %xFilial:SYD% AND SB1.B1_FILIAL = %xFilial:SB1%
           AND SB1.B1_COD = %Exp:cProduto% 
           AND SB1.B1_POSIPI = SYD.YD_TEC
           AND (YD_PER_COF >0 OR YD_VLU_COF >0)           
    ENDSQL

	cQuery := GetLastQuery()[2]	
	count to nQtdReg
    (cAliasSYD)->(dbGoTop())

    If nQtdReg > 0

        nPercIPI := (cAliasSYD)->YD_PER_COF
        nIPIPerc := (cAliasSYD)->B1_IPI

        If nPercIPI == 9.65  

            If nIPIPerc > 0

                cTES := "392"
            Else

                cTES := '393'
            EndIf
        ElseIf nPercIPI == 10.65

            If nIPIPerc > 0

                cTES := "394"
            Else

                cTES := '395'
            EndIf
        EndIf      
    EndIF

    (cAliasSYD)->(dbCloseArea())    

Return cTES



