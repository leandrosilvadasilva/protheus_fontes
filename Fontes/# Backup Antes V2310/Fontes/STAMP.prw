#INCLUDE 'TOTVS.CH' 
#INCLUDE 'TBICONN.CH' 
//https://centraldeatendimento.totvs.com/hc/pt-br/articles/4412666016919-Cross-Segmentos-TOTVS-Backoffice-Linha-Protheus-ADVPL-Por-que-os-campos-S-T-A-M-P-e-I-N-S-D-T-n%C3%A3o-est%C3%A3o-sendo-criados-no-banco-de-dados
user function stamp()
  prepare environment empresa "01" filial "01" 
  TCCONfig("SETUSEROWSTAMP=ON") 
  TCCONfig("SETUSEROWINSDT=ON")
  TCCONfig("SETAUTOSTAMP=ON") 
  TCConfig("SETAUTOINSDT=ON" ) 
  TCRefresh("DA1010") 
  TCRefresh("DA0010") 
  DbSelectArea("DA1") 
  DbSelectArea("DA0") 
  TCCONfig("SETUSEROWSTAMP=OFF") 
  TCCONfig("SETAUTOSTAMP=OFF")
  TCCONfig("SETUSEROWINSDT=ON") 
  TCConfig("SETAUTOINSDT=OFF" ) 
return
  
  //Local nI, cConfig, aConfig
   
  /*TCLink()
   
  cConfig := TCConfig( 'ALL_CONFIG_OPTIONS' )
   
  aConfig := StrTokArr( cConfig, ';' )
  For nI := 1 to len( aConfig )
    conout( aConfig[nI] )
  Next
  TCConfig( 'SETAUTOSTAMP=ON' ) 
    msginfo("STAMP"+" : "+TCConfig( 'GETAUTOSTAMP' ))
    TCConfig( 'SETAUTOINSDT=ON' ) 
    msginfo("INSDT"+" : "+TCConfig( 'SETAUTOINSDT' ))
  TCConfig( 'SETAUTOSTAMP=OFF' ) 
  TCConfig( 'SETAUTOINSDT=OFF' ) 
  msginfo(TCConfig( 'GETAUTOSTAMP' ))
  msginfo(TCConfig( 'GETAUTOINSDT' ))  
  TCUnlink()*/
return
