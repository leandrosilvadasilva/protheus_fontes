#Include 'totvs.ch'

/*/{Protheus.doc} DBSELECAREA
    (long_description)
    @type  Function
    @author user
    @since 12/09/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
USER Function DBSELECAREA
    
    rpcSetEnv('01','0101','leandro.silva','','FAT','DBSELECAREA' )


    dbSelectArea("SA1")
    dbSelectArea("SB1")


    nAreaSA1    := select(SA1)

    rpcClearEnv()

Return 
