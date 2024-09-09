#include 'protheus.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CIRMA300     || Autor: Luciano Corrêa        || Data: 11/07/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Job para Refazer Saldo Atual (MATA300)                       ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CIRMA300()

Local nI
Local lBat		:= .T.	//-- Define que a rotina será executada em Batch
Local aListaFil	:= {}	//-- Carrega Lista com as Filiais a serem processadas
//Local aParAuto	:= {}	//-- Carrega a lista com os parâmetros

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Empresa Logada: ' + cEmpAnt )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Filial Logada: ' + cFilAnt )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] Usuário Logado: ' + cUserName )

For nI := 1 to 8
	
	VarInfo( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA300] MV_PAR' + StrZero( nI, 2 ), &( 'MV_PAR' + StrZero( nI, 2 ) ) )
	
	//aAdd( aParAuto, &( 'MV_PAR' + StrZero( nI, 2 ) ) )
Next nI

SM0->( dbSetOrder( 1 ) )
// conforme solicitação do Ednei, deve ser executado o saldo atual somente da filial agendada...
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
|| Função: SchedDef     || Autor: Luciano Corrêa        || Data: 11/07/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Função para configuração de Parâmetros no Agendamento        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function SchedDef()

Local aOrd		:= {}
Local aParam	:= {}

aParam	:= { "P", "MTA300", "", aOrd, }

Return( aParam )
