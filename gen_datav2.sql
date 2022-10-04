SET SERVEROUTPUT ON;

DECLARE
 -- A DICTIONARY type associate fields that cannot be filled automatically
   TYPE DICT IS
      TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);
 --
 -- Stack type for manipulate events.
 -- TYPE stack_t IS VARRAY(500) OF VARCHAR2;
 --
 -- The cursor for iterater over the PLANILHA_EXCEL data.
   LC_CURSOR        SYS_REFCURSOR;
 --
 -- An auxiliar row of PLANILHA_EXCEL, to fetch refCursor data.
   LR_ROW           PLANILHA_EXCEL%ROWTYPE;
 --
 -- Global instance for counters.
   LN_COUNT         NUMBER := 0;
 --
 -- Global instance for BASONIMO group.
   LV_BASONIMOS     APEX_T_VARCHAR2 := NULL;
 --
 --
 -- Global instance from unique BASONIMO.
   LV_AUTHORS       APEX_T_VARCHAR2 := NULL;
 --
 -- Global instance from unique insertion.
   LV_VALUE         VARCHAR2(32767) := NULL;
 --
 -- Global auxliars id's for insertion in tables.
   LN_ID1           NUMBER := 0;
   LN_ID2           NUMBER := 0;
   LN_ID3           NUMBER := 0;
 --
 -- dictionary to relate names with acronyms of federal units.
   LD_UF_DICT       DICT;
 --
 -- dictionary to relate names with acronyms of categories.
   LD_CATEGORY_DICT DICT;
 --
 -- dictionary to relate names with acronyms of types of units o conservation.
   LD_TUC_DICT      DICT;
BEGIN
 --
 -- Initialize the dictionary of federal units.
   LD_UF_DICT('AC') := 'Acre';
   LD_UF_DICT('AL') := 'Alagoas';
   LD_UF_DICT('AP') := 'Amapá';
   LD_UF_DICT('AM') := 'Amazonas';
   LD_UF_DICT('BA') := 'Bahia';
   LD_UF_DICT('CE') := 'Ceará';
   LD_UF_DICT('DF') := 'Distrito Federal';
   LD_UF_DICT('ES') := 'Espirito Santo';
   LD_UF_DICT('GO') := 'Goiais';
   LD_UF_DICT('MA') := 'Maranhão';
   LD_UF_DICT('MT') := 'Mato Grosso';
   LD_UF_DICT('MS') := 'Mato Grosso do Sul';
   LD_UF_DICT('PA') := 'Pará';
   LD_UF_DICT('PB') := 'Paraíba';
   LD_UF_DICT('PR') := 'Paraná';
   LD_UF_DICT('PE') := 'Pernambuco';
   LD_UF_DICT('PI') := 'Piauí';
   LD_UF_DICT('RJ') := 'Rio de Janeiro';
   LD_UF_DICT('RN') := 'Rio Grande do Norte';
   LD_UF_DICT('RS') := 'Rio Grande do Sul';
   LD_UF_DICT('RO') := 'Rondônia';
   LD_UF_DICT('RR') := 'Roraima';
   LD_UF_DICT('SC') := 'Santa Catarina';
   LD_UF_DICT('SP') := 'São Paulo';
   LD_UF_DICT('SE') := 'Sergipe';
   LD_UF_DICT('MG') := 'Minar Gerais';
   LD_UF_DICT('TO') := 'Tocatins';
 --
 -- Initialize the dictionary of categories.
   LD_CATEGORY_DICT('EN') := 'Em Perigo';
   LD_CATEGORY_DICT('VU') := 'Vulnerável';
   LD_CATEGORY_DICT('CR') := 'Em Perigo Crítico';
   LD_CATEGORY_DICT('LC') := 'Segura';
   LD_CATEGORY_DICT('NT') := 'Quase Ameaçada';
   LD_CATEGORY_DICT('EW') := 'Extinta na Natureza';
   LD_CATEGORY_DICT('EX') := 'Extinta';
 --
 -- Initialize the dictionary of types of conservation units.
   LD_TUC_DICT('US') := 'Uso Sustentável';
   LD_TUC_DICT('PI') := 'Proteção Integral';
 --
 -- Opening cursor with PLANILHA_ECXEL data.
   OPEN LC_CURSOR FOR
      SELECT
         "PLANILHA_EXCEL"."UC"        "UNIDADE_CONSERVACAO",
         "PLANILHA_EXCEL"."TIPOUC"    "TIPO_UNIDADE_CONSERVACAO",
         "PLANILHA_EXCEL"."ESFERA"    "ESFERA",
         "PLANILHA_EXCEL"."UF"        "UNIDADE_FEDERAL",
         "PLANILHA_EXCEL"."MUNICIPIO" "MUNICIPIO",
         "PLANILHA_EXCEL"."BIOMA"     "BIOMA",
         "PLANILHA_EXCEL"."FAMILIA"   "FAMILIA_BOTANICA",
         "PLANILHA_EXCEL"."ESPECIE"   "ESPECIE",
         "PLANILHA_EXCEL"."AUTOR"     "AUTOR",
         "PLANILHA_EXCEL"."CATEGORIA" "CATEGORIA"
      FROM
         "EC2022GRUPO01"."PLANILHA_EXCEL" "PLANILHA_EXCEL";
 -- iterate over LC_CURSOR data.
   LOOP
 -- fecth a data row in the auliar row.
      FETCH LC_CURSOR INTO LR_ROW;
 -- break point
      EXIT WHEN LC_CURSOR%NOTFOUND;
 --
 -- ------------------------------------------------------ --
 --                       CATEGORIA                        --
 -- ------------------------------------------------------ --
 --
      DBMS_OUTPUT.PUT_LINE(LR_ROW.CATEGORIA );
 /*
    UTILITY.INSERTS_WHEN_NOT_EXIST('CATEGORIA', 'SIGLA, NOME', LR_ROW.CATEGORIA
      || ', '
      || LD_CATEGORY_DICT( LR_ROW.CATEGORIA ));*/
 -- ------------------------------------------------------ --
 --                       BASONIMO                         --
 -- ------------------------------------------------------ --
 -- LV_BASONIMOS := UTILITY.EXTRACT_SUBSTRS(LR_ROW.AUTOR, '(', ')');
 --    RANGES.INSERTS_WHEN_NOT_EXIST('TAB_TEST', 'VAL', APEX_STRING.JOIN(LV_BASONIMOS, ''), '&');
 -- ------------------------------------------------------ --
 --                        AUTOR                           --
 -- ------------------------------------------------------ --
      LV_AUTHORS := UTILITY.EXTRACT_NOT_MATCH_SUBSTRS(LR_ROW.AUTOR, '(', ')');
      FOR I IN 1..LV_AUTHORS.COUNT LOOP
         
         RANGES.INSERTS_WHEN_NOT_EXIST('TAB_TEST', 'VAL', APEX_STRING.JOIN(UTILITY.EXPLODE(), ' '), '&');
      END LOOP;
 -- ------------------------------------------------------ --
 --                      BIOMA_IBGE                        --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                    FAMILIA_BOTANICA                    --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                        PLANTA                          --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                      AUTOR_PLANTA                      --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                    BASONIMO_PLANTA                     --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                 TIPO_UNIDADE_CONSERVACAO               --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                        ESFERA                          --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                   UNIDADE_FEDERAL                      --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                       MUNICIPIO                         --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --                   UNIDADE_CONSERVACAO                  --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --             UNIDADE_CONSERVACAO_MUNICIPIO              --
 -- ------------------------------------------------------ --
 -- ------------------------------------------------------ --
 --             UNIDADE_CONSERVACAO_FEDERAL            --
 -- ------------------------------------------------------ --
   END LOOP;
 -- Close the cursor for data;
   CLOSE LC_CURSOR;
END;