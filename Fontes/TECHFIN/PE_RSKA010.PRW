#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
    {Protheus.doc} PE_RSKA010
    Ponto de Entrada MVC para Controle de Documentos de Saída OFF Balance
    @author 
    @since 99/99/9999
    @version P12

    IDs dos Pontos de Entrada
    -------------------------

    MODELPRE 			Antes da alteração de qualquer campo do modelo. (requer retorno lógico)
    MODELPOS 			Na validação total do modelo (requer retorno lógico)

    FORMPRE 			Antes da alteração de qualquer campo do formulário. (requer retorno lógico)
    FORMPOS 			Na validação total do formulário (requer retorno lógico)

    FORMLINEPRE 		Antes da alteração da linha do formulário GRID. (requer retorno lógico)
    FORMLINEPOS 		Na validação total da linha do formulário GRID. (requer retorno lógico)

    MODELCOMMITTTS 		Apos a gravação total do modelo e dentro da transação
    MODELCOMMITNTTS 	Apos a gravação total do modelo e fora da transação

    FORMCOMMITTTSPRE 	Antes da gravação da tabela do formulário
    FORMCOMMITTTSPOS 	Apos a gravação da tabela do formulário

    FORMCANCEL 			No cancelamento do botão.

    BUTTONBAR 			Para acrescentar botoes a ControlBar

    MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

    Parametros passados para os pontos de entrada:
    PARAMIXB[1] - Objeto do formulário ou model, conforme o caso.
    PARAMIXB[2] - Id do local de execução do ponto de entrada
    PARAMIXB[3] - Id do formulário


    --->> Importante: esse  PE  deve ser compilado no  RPO  do  SCHEDULE  onde está rodando o  JOB  do Mais Negocios

    TODO
        [ ] - Melhoria em iuum cenario que já  "comittou", ous eja, implmentar para outros  eventos do  MVC
              Observando o  SC5->C5_XWMS  que se tiver  ==  "S",  desconsiderar e o fluxo do processo


/*/
User Function RSKA010() 
Local aParam      := PARAMIXB
Local aArea       := GetArea()
Local cIdPonto    := aParam[2]
Local xRet        := .T.
Local mensagem    := ""
Local cChaveAR0   := ""

	If cIdPonto == "MODELCOMMITNTTS"
		
    	VarInfo( "RSKA010 MODELCOMMITNTTS 111", Funname() + " - " + ProcName() + " - AR0->AR0_STATUS: " + AR0->AR0_STATUS )
		If AR0->AR0_STATUS == "2"

    	    VarInfo( "RSKA010 MODELCOMMITNTTS 222", Funname() + " - " + ProcName() + " - AR0->AR0_STATUS: " + AR0->AR0_STATUS )

            cChaveAR0 := AR0->( AR0_FILPED + AR0_NUMPED )

            /*
            SC9->(dbSelectArea("SC9"))
            SC9->(dbSetOrder(1))
            If SC9->(DbSeek( cChaveAR0 ))

                RecLock("SC9",.F.)
                C9_BLCRED := ""
                SC9->( MsUnlock() )
            EndIf
            */
            
            SC5->(dbSelectArea("SC5"))
            SC5->(dbSetOrder(1))
            If SC5->(DbSeek( cChaveAR0 ))

                VarInfo( "RECNO", SC5->(RECNO()) )
                retorno := U_MAPWMS07( SC5->(RECNO()), @mensagem)

                IF retorno == .T. .AND. !EMPTY(ALLTRIM(mensagem))

                    RecLock("SC5",.F.)
                    SC5->C5_XWMS	:= "S"  
                    SC5->C5_XMSGWMS	:= mensagem
                    SC5->( MsUnlock() )

                    VarInfo( "RSKA010 MODELCOMMITNTTS 333", Funname() + " - " + ProcName() + " - AR0->AR0_STATUS: " + AR0->AR0_STATUS ) 
                Else

                    VarInfo( "RSKA010 MODELCOMMITNTTS 444", Funname() + " - " + ProcName() + " - AR0->AR0_STATUS: " + AR0->AR0_STATUS )
                    VarInfo( "retorno", retorno )                                    
                    VarInfo( "mensagem", mensagem )                                    
                EndIf
            else
                
                VarInfo( "RSKA010 MODELCOMMITNTTS 555", Funname() + " - " + ProcName() + " - AR0->AR0_STATUS: " + AR0->AR0_STATUS )                
            EndIf
		EndIf
	EndIf

RestArea( aArea )
FWFreeArray( aArea )
Return xRet
