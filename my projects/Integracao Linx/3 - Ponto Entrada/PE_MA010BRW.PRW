#INCLUDE "TOTVS.CH"

User Function MT010BRW()
Local aButtons := {} // botões a adicionar
Local aLinx    := {}

	aAdd( aLinx, {  'Integra Produto', 'U_MAWSLNX10( SB1->B1_COD )', 1, 3 } )
	aAdd( aLinx, {  'Integra Estoque', 'U_MAWSLNX30( SB1->B1_COD )', 1, 3 } )

	aAdd( aButtons, {  'Integracao LINX', aLinx, 0, 8 } )

Return( aButtons )

