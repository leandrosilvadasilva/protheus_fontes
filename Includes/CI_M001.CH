//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Constantes de Codigos de Bancos no BACEN         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define BRASIL     "001"
#Define SANTANDER  "033"
#Define BANRISUL   "041"
#Define CAIXA      "104"
#Define BRADESCO   "237"
#Define ITAU       "341"
#Define HSBC       "399"
#Define SAFRA      "422"
#Define FIBRA      "224"
#Define SICREDI    "748"
#Define REDASSET   "761"
#Define ABC        "246"
#Define VOTORANTIM "655"
#Define NORDESTE   "004"
#Define CITIBANK   "745"
#Define BBM        "107"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Array Bancos Homologados e Digitos Verificadores ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define BANCO_HML	{;
					{ BRASIL    , "9" },;
					{ SANTANDER , "7" },;
					{ BANRISUL  , "8" },;
					{ CAIXA     , "0" },;
					{ BRADESCO  , "2" },;
					{ ITAU      , "7" },;
					{ HSBC      , "9" },;
					{ SAFRA     , "7" },;
					{ FIBRA     , "0" },;
					{ SICREDI   , "X" },;
					{ REDASSET  , "0" },;
					{ ABC       , "1" },;
					{ VOTORANTIM, "0" },;
					{ NORDESTE  , "3" },;
					{ CITIBANK  , "5" },;
					{ BBM       , "0" };
					}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Posicoes Dados no Array aCedente                 ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define TAM_CED     08	//-- Tamanho Array aCedente
#Define CED_NOME    01	//-- Nome da Empresa
#Define CED_CNPJ    02	//-- CNPJ
#Define CED_END     03	//-- Endereco
#Define CED_COMPL   04	//-- Complemento Endereco
#Define CED_BAIRRO  05	//-- Bairro
#Define CED_MUN     06	//-- Cidade
#Define CED_EST     07	//-- Estado
#Define CED_CEP     08	//-- CEP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Posicoes Dados no Array aBanco                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define TAM_BCO     33	//-- Tamanho Array aBanco
#Define BCO_NUMBCO  01	//-- Numero Banco no BACEN
#Define BCO_DVBCO   02	//-- Digito Banco
#Define BCO_NUMAGE  03	//-- Numero Agencia
#Define BCO_DVAGE   04	//-- Digito Agencia
#Define BCO_NUMCTA  05	//-- Numero Conta
#Define BCO_DVCTA   06	//-- Digito Conta
#Define BCO_SUBCTA  07	//-- Subconta
#Define BCO_NOMBCO  08	//-- Nome do Banco
#Define BCO_CODEMP  09	//-- Codigo Cedente
#Define BCO_CARTEIR 10	//-- Codigo da Carteira
#Define BCO_VARIAC  11	//-- Variacao da Carteira
#Define BCO_BCOFORM 12	//-- Banco Formatada
#Define BCO_AGEFORM 13	//-- Agencia Formatada
#Define BCO_CTAFORM 14	//-- Conta Formatada
#Define BCO_AGECTA  15	//-- Agencia/Conta Formatados
#Define BCO_MSG1    16	//-- Formula Mensagem 1
#Define BCO_MSG2    17	//-- Formula Mensagem 2
#Define BCO_MSG3    18	//-- Formula Mensagem 3
#Define BCO_MSG4    19	//-- Formula Mensagem 4
#Define BCO_MSG5    20	//-- Formula Mensagem 5
#Define BCO_MSG6    21	//-- Formula Mensagem 6
#Define BCO_LOCPAG  22	//-- Mensagem Local de Pagamento
#Define BCO_BCOCOR  23	//-- Numero Banco Correspondente no BACEN
#Define BCO_DVBCOR  24	//-- Digito Banco Correspondente
#Define BCO_AGECOR  25	//-- Numero Agencia Correspondente
#Define BCO_DVAGCO  26	//-- Digito Agencia Correspondente
#Define BCO_NCTACO  27	//-- Numero Conta Correspondente
#Define BCO_DVCTCO  28	//-- Digito Conta Correspondente
#Define BCO_NOMCOR  29	//-- Nome do Banco Correspondente
#Define BCO_POSTO   30	//-- Codigo do Posto do Beneficiario (uso exclusivo SICREDI)
#Define BCO_ACEITE  31	//-- Aceite ( S = Sim ou N = Nao )
#Define BCO_USOBCO  32	//-- Uso do Banco
#Define BCO_MBCARD  33	//-- Uso do Banco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Posicoes Dados no Array aSacado                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define TAM_SAC     10	//-- Tamanho Array aSacado
#Define SAC_NOME    01	//-- Razao Social
#Define SAC_CNPJ    02	//-- CNPJ/CPF
#Define SAC_END     03	//-- Endereco
#Define SAC_COMPL   04	//-- Complemento Endereco
#Define SAC_BAIRRO  05	//-- Bairro
#Define SAC_MUN     06	//-- Cidade
#Define SAC_EST     07	//-- Estado
#Define SAC_CEP     08	//-- CEP
#Define SAC_CONTATO 09	//-- Contato
#Define SAC_EMAIL   10	//-- Email

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Posicoes Dados no Array aAvalista                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define TAM_AVA     08	//-- Tamanho Array aAvalista
#Define AVA_NOME    01	//-- Razao Social
#Define AVA_CNPJ    02	//-- CNPJ/CPF
#Define AVA_END     03	//-- Endereco
#Define AVA_COMPL   04	//-- Complemento Endereco
#Define AVA_BAIRRO  05	//-- Bairro
#Define AVA_MUN     06	//-- Cidade
#Define AVA_EST     07	//-- Estado
#Define AVA_CEP     08	//-- CEP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Posicoes Dados no Array aTitulo                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define TAM_TIT      27	//-- Tamanho Array aTitulo
#Define TIT_PREF     01	//-- Prefixo da NF
#Define TIT_NUM      02	//-- Numero do Titulo
#Define TIT_PARC     03	//-- Parcela
#Define TIT_TIPO     04	//-- Tipo do Titulo
#Define TIT_ESPECIE  05	//-- Especie Documento
#Define TIT_NNUM     06	//-- Nosso Numero
#Define TIT_DVNNUM   07	//-- DV Nosso Numero
#Define TIT_NNUMFORM 08	//-- Linha Digitavel
#Define TIT_DTEMI    09	//-- Data da Emissao do Titulo
#Define TIT_DTPROC   10	//-- Data da Emissao do Boleto
#Define TIT_DTVCTO   11	//-- Data do Vencimento
#Define TIT_VALOR    12	//-- Valor do Titulo
#Define TIT_IRRF     13	//-- IRRF
#Define TIT_ISS      14	//-- ISS
#Define TIT_INSS     15	//-- INSS
#Define TIT_PIS      16	//-- PIS
#Define TIT_COFINS   17	//-- COFINS
#Define TIT_CSLL     18	//-- CSLL
#Define TIT_DECRES   19	//-- Abatimentos
#Define TIT_ACRESC   20	//-- Acrescimos
#Define TIT_ABATIM   21	//-- Abatimentos
#Define TIT_CODBAR   22	//-- Codigo de Barras
#Define TIT_LINDIG   23	//-- Linha Digitavel
#Define TIT_MSGS     24	//-- Mensagens / Instrucoes
#Define TIT_LOCPAG   25 //-- Mensagem Local de Pagamento
#Define TIT_RECSE1   26	//-- Recno do Titulo no SE1
#Define TIT_RECSA1   27	//-- Recno do Cliente no SA1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Constantes Nomes de Campos / Conteudos Fixos     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#Define STRBOL000 ""
#Define STRBOL001 "Local Pagamento"
#Define STRBOL002 "Vencimento"
#Define STRBOL003 "Beneficiário"
#Define STRBOL004 "CNPJ/CPF"
#Define STRBOL005 "Agencia/Codigo do Beneficiário"
#Define STRBOL006 "Data Documento"
#Define STRBOL007 "Numero do Documento"
#Define STRBOL008 "Especie Documento"
#Define STRBOL009 "Aceite"
#Define STRBOL010 "Data Processamento"
#Define STRBOL011 "Nosso Numero"
#Define STRBOL012 "Uso do Banco"
#Define STRBOL013 "Carteira"
#Define STRBOL014 "Especie"
#Define STRBOL015 "Quantidade"
#Define STRBOL016 "Valor"
#Define STRBOL017 "(=) Valor Documento"
#Define STRBOL018 "Instruções (Todas as Informações deste bloqueto sao de EXCLUSIVA responsabilidade do Beneficiário)"
#Define STRBOL034 "Instruções (Todas as Informações deste bloqueto sao de EXCLUSIVA responsabilidade do Sacador/Avalista)"
#Define STRBOL019 "(-) Descontos/Abatimentos"
#Define STRBOL020 "(-) Outras Deduções"
#Define STRBOL021 "(+) Multa/Mora"
#Define STRBOL022 "(+) Outros Acrescimos"
#Define STRBOL023 "(=) Valor Cobrado"
#Define STRBOL024 "Pagador:"
#Define STRBOL025 "CNPJ/CPF:"
#Define STRBOL026 "Endereco:"
#Define STRBOL027 "Sacador/Avalista:"
#Define STRBOL028 "Codigo de Baixa:"
#Define STRBOL029 "Endereco Beneficiário/Sacador Avalista"
#Define STRBOL033 "Valor do Documento"
#Define STRBOL030 "Recibo do Pagador"
#Define STRBOL031 "Autenticação Mecanica / FICHA DE COMPENSAÇÃO"
#Define STRBOL032 "Autenticação Mecanica"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Pictures de Dados                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Define PICT_CNPJ   "@R 99.999.999/9999-99"
#Define PICT_CPF    "@R 999.999.999-99"
#Define PICT_CEP    "@R 99.999-9999"
#Define PICT_BANCO  "@R NNN-N"
#Define PICT_LINDIG "@R 99999.99999 99999.999999 99999.999999 9 99999999999999"
#Define PICT_VALOR  "@E 99,999,999.99"

#Define CRLF		Chr(13)+Chr(10)

/*
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
*/
