#include 'protheus.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CI_M040      || Autor: Luciano Corrêa        || Data: 26/11/09  ||
||-------------------------------------------------------------------------||
|| Descrição: Importação do Ativo Fixo                                     ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CI_M040()

Private cPerg		:= 'CI_M040'
Private cCadastro	:= OemToAnsi( 'Importação Ativo Fixo' )
Private aSays		:= {}
Private aButtons	:= {}
Private nOpca		:= 0

u_PutSX1( cPerg	, "01"	, "Arquivo a Importar:"		, "mv_par01", "mv_ch1"	, "C"		, 99						, 0			, "G"		, ""	, 			, 			,				,				 ,			,			,			,		, 			)

Pergunte( cPerg, .F. )

aAdd( aSays, OemToAnsi( 'Este programa vai importar os Bens e Saldos do Ativo Fixo' ) )
aAdd( aSays, OemToAnsi( 'pela leitura do arquivo texto informados nos parâmetros.' ) )

aAdd( aButtons, { 5, .t., {|| Pergunte( cPerg, .T. ) } } )
aAdd( aButtons, { 1, .t., {|o| nOpca := 1, If( gpconfOK(), FechaBatch(), nOpca:=0 ) } } )
aAdd( aButtons, { 2, .t., {|o| FechaBatch() } } )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	
	Processa( { |lEnd| CI040Bem( mv_par01 ) }, cCadastro )
EndIf

Return


********************************************************************************
Static Function CI040Bem( cArqTxt )

Local aArea		:= GetArea()
Local nImp		:= 0
Local nErr		:= 0

Local nHdl, cBuffer, nTamFile
Local cLinha, aLinha

Local cArqLog	:= SubStr( cArqTxt, 1, RAt( '\', cArqTxt ) - 1 ) + "\LOG_ATF_" + GravaData( dDataBase, .F., 5 ) + StrTran( Time(), ':', '' ) + '.txt'
Local nHdlLog, cText

Private nBytesProc
Private nTamBloco

Private aAutoCab		:= {}
Private aAutoItens		:= {}
Private aAutoAux		:= {}
Private lMsHelpAuto		:= .F.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .F.

If !File( cArqTxt )
	
	MsgStop( 'O arquivo a ser importado não foi localizado!', cCadastro )
	
	Return
EndIf

nHdl := fOpen( cArqTxt, 0 )		// abre o arquivo

If nHdl == -1
	
	MsgStop( 'O arquivo de nome ' + AllTrim( cArqTxt ) + ' não pode ser aberto! Verifique os parâmetros.', cCadastro )
	
	Return
EndIf

nTamBloco := 13								// numero de delimitadores + caracteres de fim de linha...
cBuffer  := Space( nTamBloco )				// define o tamanho do buffer (cada bloco)

nTamFile := fSeek( nHdl, 0, 2 )				// verifica o numero de bytes do arquivo
fSeek( nHdl, 0, 0 )							// retorna ao início do arquivo

ProcRegua( nTamFile / nTamBloco )			// calcula o numero de blocos

nBytesProc := 0

// le a primeira linha do arquivo
LeLinha( nHdl, @cLinha, @cBuffer )

// carrega linha do arquivo em um array
aLinha := ListAsArray( cLinha, ';' )

If Len( aLinha ) < nTamBloco
	
	fClose( nHdl )
	
	// renomeia o arquivo
	fRename( cArqTxt, SubStr( cArqTxt, 1, At( '.', cArqTxt) ) + 'err' )
	
	MsgStop( 'O arquivo de nome ' + AllTrim( cArqTxt ) + ' nao é válido! Verifique os parâmetros.', cCadastro )
	
	Return
EndIf

// le a próxima linha do arquivo... descartando a primeira do cabeçalho...
LeLinha( nHdl, @cLinha, @cBuffer )

// carrega linha do arquivo em um array
aLinha	:= ListAsArray( cLinha, ';' )


nHdlLog := fCreate( cArqLog )

If fError() <> 0
	
	ApMsgStop( 'Erro ao criar o arquivo ' + cArqLog + '. Código do erro: ' + Str( fError() ) )
	Return
EndIf

fWrite( nHdlLog , Replicate( '=', 80 ) + CRLF )
fWrite( nHdlLog , 'INICIANDO O LOG - I M P O R T A C A O   D E   D A D O S' + CRLF )
fWrite( nHdlLog , Replicate( '-', 80 ) + CRLF )
fWrite( nHdlLog , 'DATABASE...........: ' + DtoC( dDataBase ) + CRLF )
fWrite( nHdlLog , 'DATA...............: ' + DtoC( Date() ) + CRLF )
fWrite( nHdlLog , 'HORA...............: ' + Time() + CRLF )
fWrite( nHdlLog , 'ENVIRONMENT........: ' + GetEnvServer() + CRLF )
fWrite( nHdlLog , 'PATH...............: ' + GetSrvProfString( 'StartPath', '' ) + CRLF )
fWrite( nHdlLog , 'ROOT...............: ' + GetSrvProfString( 'RootPath', '' ) + CRLF )
fWrite( nHdlLog , 'VERSÃO.............: ' + GetVersao() + CRLF )
fWrite( nHdlLog , 'MÓDULO.............: ' + 'SIGA' + cModulo + CRLF )
fWrite( nHdlLog , 'EMPRESA / FILIAL...: ' + SM0->M0_CODIGO + '/' + SM0->M0_CODFIL + CRLF )
fWrite( nHdlLog , 'NOME EMPRESA.......: ' + Capital( Trim( SM0->M0_NOME ) ) + CRLF )
fWrite( nHdlLog , 'NOME FILIAL........: ' + Capital( Trim( SM0->M0_FILIAL ) ) + CRLF )
fWrite( nHdlLog , 'USUÁRIO............: ' + cUserName + CRLF )
fWrite( nHdlLog , 'PROGRAMA...........: ' + FunName() + CRLF )
fWrite( nHdlLog , 'ARQUIVO IMPORT.....: ' + cArqTxt + CRLF )
fWrite( nHdlLog , Replicate( '-', 80 ) + CRLF )
//		           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//		           0         1         2         3         4         5         6         7         8         9         0         1         2         3
//		           99   9999999999 9999  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxx   XXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXX
fWrite( nHdlLog , 'Fil  Codigo           Descricao do Bem                           Ocorrencia                                                       ' + CRLF )
fWrite( nHdlLog , Replicate( '-', 80 ) + CRLF )

While !Empty( cLinha )
	
	IncProc()

	aAutoCab	:= {{ 'N1_FILIAL'	, aLinha[ 6 ]				, Nil }, ;
					{ 'N1_GRUPO'	, aLinha[ 7 ]				, Nil }, ;
					{ 'N1_PATRIM'	, aLinha[ 10 ]				, Nil }, ;
					{ 'N1_CBASE'	, aLinha[ 2 ]				, Nil }, ;
					{ 'N1_ITEM'		, aLinha[ 8 ]				, Nil }, ;
					{ 'N1_QUANTD'	, Val( aLinha[ 11 ] )		, Nil }, ; 
					{ 'N1_AQUISIC'	, CToD( aLinha[ 1 ] )		, Nil }, ;
					{ 'N1_DESCRIC'	, aLinha[ 5 ]				, Nil }, ;
					{ 'N1_CHAPA'	, aLinha[ 3 ]				, Nil }, ;
					{ 'N1_STATUS'	, aLinha[ 12 ]				, Nil }, ;
					{ 'N1_VLAQUIS'	, Val( aLinha[ 13 ] )		, Nil }, ; 
					{ 'N1_CODCIAP'	, aLinha[ 4 ]				, Nil }, ;
					{ 'N1_NFISCAL'	, aLinha[ 9 ]				, Nil }}
					/*
					{ 'N1_CALCPIS'	, aLinha[ 14 ]				, Nil }, ;
					{ 'N1_MESCPIS'	, Val( aLinha[ 15 ] )		, Nil }, ; 
					{ 'N1_CSTPIS'	, aLinha[ 16 ]				, Nil }, ;
					{ 'N1_ALIQPIS'	, Val( aLinha[ 17 ] )		, Nil }, ; 
					{ 'N1_CSTCOFI'	, aLinha[ 18 ]				, Nil }, ;
					{ 'N1_ALIQCOF'	, Val( aLinha[ 19 ] )		, Nil }, ; 
					{ 'N1_CODBCC'	, aLinha[ 20 ]				, Nil }, ;
					{ 'N1_DETPATR'	, aLinha[ 21 ]				, Nil }, ;
					{ 'N1_UTIPATR'	, aLinha[ 22 ]				, Nil }, ;
					{ 'N1_CBCPIS'	, aLinha[ 23 ]				, Nil }}
					*/
					
	aAutoItens	:= {}
	
	aAutoAux	:= {{ 'N3_TIPO'		, aLinha[ 23 ]				, Nil }, ;
					{ 'N3_HISTOR'	, aLinha[ 22 ]				, Nil }, ;
					{ 'N3_TPSALDO'	, aLinha[ 25 ]				, Nil }, ;
					{ 'N3_DINDEPR'	, CToD( aLinha[ 21 ] )		, Nil }, ;
					{ 'N3_CCONTAB'	, aLinha[ 17 ]				, Nil }, ;
					{ 'N3_CUSTBEM'	, aLinha[ 20 ]				, Nil }, ;
					{ 'N3_CDEPREC'	, aLinha[ 18 ]				, Nil }, ;
					{ 'N3_CCDESP'	, aLinha[ 16 ]				, Nil }, ;
					{ 'N3_CCDEPR'	, aLinha[ 15 ]				, Nil }, ;
					{ 'N3_CDESP'	, aLinha[ 19 ]				, Nil }, ;
					{ 'N3_VORIG1'	, Val( aLinha[ 28 ] )		, Nil }, ;
					{ 'N3_VRDACM1'	, Val( aLinha[ 29 ] )		, Nil }, ;
					{ 'N3_TPDEPR'	, aLinha[ 24 ]				, Nil }, ;
					{ 'N3_TXDEPR1'	, Val( aLinha[ 26 ] )		, Nil }, ;
					{ 'N3_VMXDEPR'	, Val( aLinha[ 27 ] )		, Nil }, ;
					{ 'N3_AQUISIC'	, CToD( aLinha[ 14 ] )		, Nil }}
					/*
					{ 'N3_VORIG2'	, Val( aLinha[ 30 ] )		, Nil }, ;
					{ 'N3_TXDEPR2'	, Val( aLinha[ 31 ] )		, Nil }, ;
					{ 'N3_VORIG3'	, Val( aLinha[ 32 ] )		, Nil }, ;
					{ 'N3_TXDEPR3'	, Val( aLinha[ 33 ] )		, Nil }, ;
					{ 'N3_TXDEPR4'	, Val( aLinha[ 34 ] )		, Nil }, ;
					{ 'N3_TXDEPR5'	, Val( aLinha[ 35 ] )		, Nil }, ;
					{ 'N3_VRDACM2'	, Val( aLinha[ 36 ] )		, Nil }, ;
					{ 'N3_VRDACM3'	, Val( aLinha[ 37 ] )		, Nil }, ;
					*/*

	aAdd( aAutoItens, aAutoAux )

	VarInfo( "SN1", aAutoCab )
	VarInfo( "SN3", aAutoAux )
	
	lMsErroAuto		:= .F.
	
	MSExecAuto( {|x,y,z| ATFA012( x, y, z ) }, aAutoCab, aAutoItens, 3 )
	
	If lMsErroAuto

		cText	:= PadR( aLinha[ 1 ], 2 ) + '   ' + PadR( aLinha[ 4 ], 10 ) + ' ' + PadR( aLinha[ 5 ], 4 ) + '  ' + PadR( aLinha[ 8 ], 40 ) + '   '
		cText	+= 'ERRO - Falha na importação dos dados' 
		
		fWrite( nHdlLog , cText + CRLF )
		
		mostraErro()

		aLog	:= GetAutoGRLog()
		
		aEval( aLog, {|x| fWrite( nHdlLog , Space( 18 ) + x + CRLF ) } )
		
		fWrite( nHdlLog , Replicate( '-', 80 ) + CRLF )
		
		//MostraErro()

		nErr	++
	Else
		
		cText	:= PadR( aLinha[ 1 ], 2 ) + '   ' + PadR( aLinha[ 4 ], 10 ) + ' ' + PadR( aLinha[ 5 ], 4 ) + '  ' + PadR( aLinha[ 8 ], 40 ) + '   '
		cText	+= 'OK - Registro importado com sucesso' 

		fWrite( nHdlLog , cText + CRLF )
		
		nImp	++
	EndIf
		
	// le a próxima linha do arquivo
	LeLinha( nHdl, @cLinha, @cBuffer )
	
	// carrega linha do arquivo em um array
	aLinha	:= ListAsArray( cLinha, ';' )
	
End

// O handle do arquivo texto deve ser fechado
fClose(nHdl)

// renomeia o arquivo
fRename( cArqTxt, SubStr( cArqTxt, 1, At( '.', cArqTxt) ) + 'ok' )


fWrite( nHdlLog , Replicate( '-', 80 ) + CRLF )
fWrite( nHdlLog , 'Bens Importados:  ' + Transform( nImp, '@E 999,999,999' ) + CRLF )
fWrite( nHdlLog , 'Erros Detectados: ' + Transform( nErr, '@E 999,999,999' ) + CRLF )

fClose( nHdlLog )

ApMsgInfo( 'Verifique o arquivo de log: ' + cArqLog, cCadastro )

RestArea( aArea )

Return

********************************************************************************
Static Function LeLinha( nHdl, cLinha, cBuffer)

Local nPosCR := 0, nBtLidos := 1, nMove, nQtdInc, nJ

cLinha := ""

// le os blocos ate encontrar o fim de linha (CR)
While nPosCR == 0 .and. nBtLidos > 0
	
	nBtLidos := fRead( nHdl, @cBuffer, nTamBloco )
	nPosCR   := AT( Chr( 13 ), cBuffer )
	If nPosCR > 0
		cLinha += Substr( cBuffer, 1, nPosCR - 1 )
	Else
		cLinha += cBuffer
	EndIf
End

// posiciona no inicio da proxima linha
If nPosCR > 0
	
	nMove := ( Len( cBuffer ) - nPosCR - 1 ) * -1
	fSeek( nHdl, nMove, 1 )
EndIf	

// Incremento a regua conforme quantidade de bytes lidos
nBytesProc += Len( cLinha ) + 2
nQtdInc := Int( nBytesProc / nTamBloco )

If nQtdInc > 0
	
	For nJ := 1 To nQtdInc
		IncProc()
	Next
	nBytesProc := nBytesProc % nTamBloco
Endif	

Return nBtLidos > 0

********************************************************************************
Static Function ListAsArray( cList, cDelimiter, nTamArr )

Local nPos            // Position of _cDelimiter in _cList
Local aList:={}

// Loop while there are more items to extract
While ( nPos := AT( cDelimiter, cList ) ) <> 0
	
	// Add the item to _aList and remove it from _cList
	aAdd( aList, SubStr( cList, 1, nPos - 1 ) )
	cList := SubStr( cList, nPos + 1 )
End
aAdd( aList, cList )                         // Add final element

Return( aList )
