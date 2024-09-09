#INCLUDE "TOTVS.CH"

User Function MA010BUT()

	Local aButtons := {} // botões a adicionar
	
	AAdd(aButtons,{ 'NOTE',{| |  U_MAWSLNX10( SB1->B1_COD ) }, '* Envia LINX', 'Integracao LINX' } )
	//Iatan em 09/06/2023
    AAdd(aButtons,{ 'NOTE',{| |  U_MAWSLNX30( SB1->B1_COD ) }, 'Integra Estoque', 'Integra Estoque' } )

Return (aButtons)

