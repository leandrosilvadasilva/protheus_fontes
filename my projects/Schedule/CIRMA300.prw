#include 'protheus.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Fun��o: CIRMA300     || Autor: Luciano Corr�a        || Data: 11/07/19  ||
||-------------------------------------------------------------------------||
|| Descri��o: Job para Refazer Saldo Atual (MATA300)                       ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
���������������������������������������������������������������������������*/
User Function CIRMA300()

Local nI
Local lBat		:= .T.	//-- Define que a rotina ser� executada em Batch
Local aListaFil	:= {}	//-- Carrega Lista com as Filiais a serem processadas
//Local aParAuto	:= {}	//-- Carrega a lista com os par�metros

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Empresa Logada: ' + cEmpAnt )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Filial Logada: ' + cFilAnt )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Usu�rio Logado: ' + cUserName )

For nI := 1 to 8
	
	VarInfo( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] MV_PAR' + StrZero( nI, 2 ), &( 'MV_PAR' + StrZero( nI, 2 ) ) )
	
	//aAdd( aParAuto, &( 'MV_PAR' + StrZero( nI, 2 ) ) )
Next nI

SM0->( dbSetOrder( 1 ) )
// conforme solicita��o do Ednei, deve ser executado o saldo atual somente da filial agendada...
/*
SM0->( dbSeek( cEmpAnt, .F. ) )

While SM0->( !EoF() ) .and. SM0->M0_CODIGO == cEmpAnt
	
	//aAdd( aListaFil, SM0->M0_CODFIL )
	aAdd( aListaFil, { .T., SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_CGC, .F. } )
	
	SM0->( dbSkip() )
End
*/
SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )

aAdd( aListaFil, { .T., SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_CGC, .F. } )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Chamando MATA300' )
Conout( '----------------------------------------------------------------------' )

MSExecAuto( { |x| MATA300(x) }, lBat, aListaFil )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Finalizando Job' )
Conout( '----------------------------------------------------------------------' )

Return

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Fun��o: SchedDef     || Autor: Luciano Corr�a        || Data: 11/07/19  ||
||-------------------------------------------------------------------------||
|| Descri��o: Fun��o para configura��o de Par�metros no Agendamento        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
���������������������������������������������������������������������������*/
Static Function SchedDef()

Local aOrd		:= {}
Local aParam	:= {}

aParam	:= { "P", "MTA300", "", aOrd, }

Return( aParam )
