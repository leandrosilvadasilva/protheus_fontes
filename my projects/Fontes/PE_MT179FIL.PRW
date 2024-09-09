#Include 'PROTHEUS.CH'

	/*/{Protheus.doc} MT179FIL
	(long_description)
	Ponto de Entrada para filtro da natela Central de Compras
	@type  Function
	@author user Jeferson Silva
	@since 20/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function MT179FIL()

Local cFilSB1 := PARAMIXB[1]
Local cFilDb5 := PARAMIXB[2]
Local cPerg   := 'MT179FIL'

u_PutSX1(cPerg, "01", "Marca de:"                             ,"MV_PAR01", "MV_CH1", "C" , 2 ,0     , "G", '', "ZX"  , '',        '',    '',  '',  '',  '', "Marca de Produtos")
u_PutSX1(cPerg, "02", "Marca Ate:"                            ,"MV_PAR02", "MV_CH2", "C" , 2 ,0     , "G", '', "ZX"  , '',        '',    '',  '',  '',  '', "Marca de Produtos")

Pergunte(cPerg,.T.)

cFilSB1 := Substr(Alltrim(cFilSB1),1,Len(Alltrim(cFilSB1))-1)
cFilSB1 += " AND B1_MARCA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' %"


Return ({cFilSB1,cFilDb5})
