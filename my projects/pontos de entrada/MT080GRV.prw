#Include "Protheus.ch"


User Function MT080GRV()

Local lIntegAKR		:= SuperGetMV("MAPWMS09A",,.T.) // Integra TES para AKR via API.
Local cFILTESAKR	:= SuperGetMV("MAPWMS09B",,"0101") // Filtra Filial do cad. TES para AKR via API.

If ( INCLUI .Or. ALTERA )

    // ---------------------------------------------
    // 1º Integra TES para AKR avia API.
    // ---------------------------------------------
    If ( lIntegAKR )
    
        If AllTrim(cFilAnt) == AllTrim(cFILTESAKR)
            //DESATIVADO POR IATAN EM 23/06/2022 PORQUE NÃO VAMOS MAIS UTILIZAR TES ... VAMOS UTILIZAR OPERAÇÕES
            //U_MAPWMS09( SF4->( Recno() ) /*, nOperation*/ )
        
        EndIf 
    EndIf 

EndIf 

Return()
