#include 'protheus.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CIRMA330     || Autor: Luciano Corrêa        || Data: 11/07/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Job para Recálculo do Custo Médio (MATA330)                  ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CIRMA330()

Local nI
Local lBat		:= .T.	//-- Define que a rotina será executada em Batch
Local aListaFil	:= {}	//-- Carrega Lista com as Filiais a serem processadas
Local lCPParte	:= .F.	//-- Define que não será processado o custo em partes
Local aParAuto	:= {}	//-- Carrega a lista com os parâmetros

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA330] Iniciando Job' )
Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA330] Empresa Logada: ' + cEmpAnt )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA330] Filial Logada: ' + cFilAnt )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA330] Usuário Logado: ' + cUserName )

For nI := 1 to 21
	
	VarInfo( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA330] MV_PAR' + StrZero( nI, 2 ), &( 'MV_PAR' + StrZero( nI, 2 ) ) )
	
	aAdd( aParAuto, &( 'MV_PAR' + StrZero( nI, 2 ) ) )
Next nI

SM0->( dbSetOrder( 1 ) )
// conforme solicitação do Ednei, deve ser executado o custo médio somente da filial agendada...
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
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA330] Chamando MATA330' )
Conout( '----------------------------------------------------------------------' )

MSExecAuto( { |w,x,y,z| MATA330(w,x,y,z) }, lBat, aListaFil, lCPParte, aParAuto )

Conout( '----------------------------------------------------------------------' )
Conout( '[' + DtoC( Date() ) + ' ' + Time() + '] [U_CIRMA330] Finalizando Job' )
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

aParam	:= { "P", "MTA330", "", aOrd, }

Return( aParam )
