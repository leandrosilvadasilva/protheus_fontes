#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
    {Protheus.doc} PE_RSKA020
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
/*/
User Function RSKA020() 
Local aParam      := PARAMIXB
Local aArea       := GetArea()
Local aAreaAC9    := AC9->( GetArea() )
Local aAreaACB    := ACB->( GetArea() )
Local cIdPonto    := aParam[2]
Local cFileDoc    := ""
Local xRet        := .T.

Local cNewFileDoc := ""
Local cChaveNFE   := ""
Local cDirPDFWMS  := SuperGetMV( "ES_DIRWMS", .F., "\pdf_wms\boleto\" )

	If cIdPonto == "MODELCOMMITNTTS"
		
		// VarInfo( "RSKA020 MODELCOMMITNTTS", Funname() + " - " + ProcName() + " - AR1->AR1_STATUS: " + AR1->AR1_STATUS )
		If AR1->AR1_STATUS == "2"

			AC9->( DBSetOrder(2) )    //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
			ACB->( DBSetOrder(1) )    //ACB_FILIAL+ACB_CODOBJ
			If AC9->( DBSeek( xFilial( "AC9" ) + "AR1" + xFilial( "AR1" ) + xFilial( "AR1" ) + AR1->AR1_COD ) )

				If ACB->( DBSeek( xFilial( "ACB" ) + AC9->AC9_CODOBJ ) ) .And. AllTrim( Upper( ACB->ACB_DESCRI ) ) == "BOLETO"

					cFileDoc := lower( Alltrim( MsDocPath() + "\" + ACB->ACB_OBJETO ) )

                    cChaveNFE   := AR1->AR1_CHVNFE + ".pdf"
                    cNewFileDoc := cChaveNFE

                    // VarInfo( "RSKA020 MODELCOMMITNTTS", cNewFileDoc + " " + cDirPDFWMS + cNewFileDoc )

                    __CopyFile( cFileDoc, cDirPDFWMS + cNewFileDoc )

					If ReadFile( cFileDoc )                    

                        // Renomeia o arquibo boleto em PDF para o nome do arquivo como  chave nfe
                           // nome arquivo padrão mais negocio: 010100000001_boleto.pdf
                           // nome arquivo padrão para o WMS  : 43230904078043000140550040001332541193383639.pdf

                        cChaveNFE   := AR1->AR1_CHVNFE + "__.pdf"
                        cNewFileDoc := lower( Alltrim( MsDocPath() + "\" + cChaveNFE ) )

                        If !( __CopyFile( cFileDoc, cDirPDFWMS + cNewFileDoc ) )

                            // Grava LOG usando a função  fError()
                        EndIf
					Else
						
                        // Grava LOG usando FWFILEIOBASE():error()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

RestArea( aArea )
RestArea( aAreaAC9 )
RestArea( aAreaACB )

FWFreeArray( aArea )
FWFreeArray( aAreaAC9 )
FWFreeArray( aAreaACB )

Return xRet


Static Function ReadFile( cArquivo )
Local lRetorno := .F. AS BOOLEAN
Local oFile    := NIL AS OBJECT

	oFile := FWFileReader():New( cArquivo )

	If (oFile:Open())

		oFile:Close()
        lRetorno := .T.	
	EndIf

FreeObj( oFile )
Return lRetorno

