#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

User Function MAWSLINX80()
Local oBrowse     := Nil
Private cCadastro := "LOG de Integração"
Private aRotina   := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SZ0')
oBrowse:SetDescription("LOG de Integração")
oBrowse:SetAttach( .T. )

If nModulo <> 73
	oBrowse:SetOpenChart( .F. )
EndIf			  

oBrowse:Activate()

Return(.T.)

Static Function ModelDef()
Local oModel
Local oStruSZ0 := FWFormStruct(1,'SZ0', /*bAvalCampo*/,/*lViewUsado*/ )

oModel := MPFormModel():New('MAWSLNX80', /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
oModel:AddFields('SZ0MASTER',/*cOwner*/,oStruSZ0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription("LOG de Integração")

Return oModel

Static Function ViewDef()   
Local oView  
Local oModel   := FWLoadModel('MAWSLNX80')
Local oStruSZ0 := FWFormStruct( 2,'SZ0')  
   

oView := FWFormView():New()
oView:SetContinuousForm()
oView:SetModel(oModel)
oView:AddField('VIEW_SZ0',oStruSZ0,'SZ0MASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_SZ0','TELA') 

Return oView

Static Function MenuDef() 
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar'       ACTION 'VIEWDEF.MAWSLNX80' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'          ACTION 'VIEWDEF.MAWSLNX80' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'          ACTION 'VIEWDEF.MAWSLNX80' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'          ACTION 'VIEWDEF.MAWSLNX80' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'         ACTION 'VIEWDEF.MAWSLNX80' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copia'            ACTION 'VIEWDEF.MAWSLNX80' OPERATION 9 ACCESS 0

Return(aRotina)



