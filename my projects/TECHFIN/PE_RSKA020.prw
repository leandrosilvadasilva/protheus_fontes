#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
    {Protheus.doc} PE_RSKA020
    Ponto de Entrada MVC para Controle de Documentos de Sa�da OFF Balance
    @author 
    @since 99/99/9999
    @version P12

    IDs dos Pontos de Entrada
    -------------------------

    MODELPRE 			Antes da altera��o de qualquer campo do modelo. (requer retorno l�gico)
    MODELPOS 			Na valida��o total do modelo (requer retorno l�gico)

    FORMPRE 			Antes da altera��o de qualquer campo do formul�rio. (requer retorno l�gico)
    FORMPOS 			Na valida��o total do formul�rio (requer retorno l�gico)

    FORMLINEPRE 		Antes da altera��o da linha do formul�rio GRID. (requer retorno l�gico)
    FORMLINEPOS 		Na valida��o total da linha do formul�rio GRID. (requer retorno l�gico)

    MODELCOMMITTTS 		Apos a grava��o total do modelo e dentro da transa��o
    MODELCOMMITNTTS 	Apos a grava��o total do modelo e fora da transa��o

    FORMCOMMITTTSPRE 	Antes da grava��o da tabela do formul�rio
    FORMCOMMITTTSPOS 	Apos a grava��o da tabela do formul�rio

    FORMCANCEL 			No cancelamento do bot�o.

    BUTTONBAR 			Para acrescentar botoes a ControlBar

    MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

    Parametros passados para os pontos de entrada:
    PARAMIXB[1] - Objeto do formul�rio ou model, conforme o caso.
    PARAMIXB[2] - Id do local de execu��o do ponto de entrada
    PARAMIXB[3] - Id do formul�rio


    --->> Importante: esse  PE  deve ser compilado no  RPO  do  SCHEDULE  onde est� rodando o  JOB  do Mais Negocios
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
                           // nome arquivo padr�o mais negocio: 010100000001_boleto.pdf
                           // nome arquivo padr�o para o WMS  : 43230904078043000140550040001332541193383639.pdf

                        cChaveNFE   := AR1->AR1_CHVNFE + "__.pdf"
                        cNewFileDoc := lower( Alltrim( MsDocPath() + "\" + cChaveNFE ) )

                        If !( __CopyFile( cFileDoc, cDirPDFWMS + cNewFileDoc ) )

                            // Grava LOG usando a fun��o  fError()
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

