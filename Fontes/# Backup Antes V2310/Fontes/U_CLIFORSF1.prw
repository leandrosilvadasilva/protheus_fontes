/*=================================================================================================
* Programa...: CLIFORSF1.PRW  
* Descricao..: Fun��o para identificar no Browse o Cliente ou o Fornecedor
* Obs........: conforme o tipo da Nota de Entrada  
* Autor......: Valdir Pereira  
* Data.......: Jan/2008
*--------------------------------------------------------------------------------------------------
*/
USER FUNCTION CLIFORSF1()

Local cAreaAnt:=alias(),;
aAreaSA1:=SA1->(Getarea()),;
aAreaSA2:=SA2->(Getarea())
Local nNome

IF SF1->F1_TIPO $ 'N\I\P\C'
   nNome:=POSICIONE("SA2",1,XFILIAL("SA2")+SF1->F1_FORNECE,"A2_NOME")                       
 
Else

	nNome:=POSICIONE("SA1",1,XFILIAL("SA1")+SF1->F1_FORNECE,"A1_NOME") 
Endif
 
// Restaura o ambiente
Restarea(aAreaSA1)
Restarea(aAreaSA2)
dbSelectArea(cAreaAnt) 
return (nNome)
