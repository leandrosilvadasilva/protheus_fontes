#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} U_MT450MAN()
    Local lRetorno := .T.
    
    (long_description)
    @type  Function
    @author user
    @since 12/04/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function U_MT450MAN()
Local lRetorno      := .T.
Local aArea         := FWGetArea()
Local lPessoaFisica := .T.  // GetAdvFVal( "SA1", "A1_PESSOA", FWxFilial("SA1") + SC9->( C9_CLIENTE + C9_LOJA ), 1, "" ) == "F"
Local cMsgNoYes     := '<font color="#0FFF00" size="20">Confirma ?</font>'
Local cMsgInfo      := '<font color="#FF000F" size="20">Pedido não será Liberado</font>'
Local lComInterface := !IsBlind()

    If lComInterface

        If lPessoaFisica  
        
            F22->(dbSelectArea("F22"))
            If F22->( !MsSeek( FWxFilial( "F22" ) + SC9->( C9_CLIENTE + C9_CLIENTE ) ) )       

                If !FWAlertNoYes( cMsgNoYes, "Cliente foi incluido no Configurador de Tributos ?" )

                    //  FSA172FAC({"CLIENTE", SC9->C9_CLIENTE, SC9->C9_CLIENTE})
                    FwAlertInfo( cMsgInfo )
                    lRetorno := .F.
                EndIf        
            EndIf
        EndIf
    EndIf

FWRestArea( aArea )
Return lRetorno
