#INCLUDE "TOTVS.CH"

User Function MAGATIPIDE()
Local nBaseIPI    := SD1->D1_BASEIPI
Local nValIPI     := SD1->D1_VALIPI
Local nPosVlTotal := GetPosSD1("D1_TOTAL" )   // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_OPER' })
Local nPosVlII    := GetPosSD1("D1_II" )      // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_LOCAL' })
Local nPosBaseIPI := GetPosSD1("D1_BASEIPI" ) // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_OPER' })
Local nPosTES     := GetPosSD1("D1_TES" )     // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_OPER' })
Local nPosValIPI  := GetPosSD1("D1_VALIPI" )     // aScan(aHeader,{|x| AllTrim(x[2]) = 'D1_OPER' })

    nBaseIPI := aCols[ n, nPosBaseIPI ]
    nValIPI  := aCols[ n, nPosValIPI ] 

    MaFisRef("IT_TES","MT100",M->D1_TES)

    If NaoVazio( SF1->F1_HAWB )  .and.  aCols[ n, nPosVlII ]  > 0

        nBaseIPI := aCols[ n, nPosVlTotal ] + aCols[ n, nPosVlII ]
        aCols[ n, nPosBaseIPI ] := nBaseIPI
        aCols[ n, nPosValIPI  ] := nValIPI
    EndiF

    //MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
    //MaAvalTes( "E", aCols[ n, nPosTES ] )  .And.  MaFisRef( "IT_TES","MT100", aCols[ n, nPosTES ] )

    a:=0
Return nBaseIPI

