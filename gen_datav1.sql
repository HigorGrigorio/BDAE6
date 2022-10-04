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
    L_CURSOR        SYS_REFCURSOR;
 --
 -- An auxiliar row of PLANILHA_EXCEL, to fetch refCursor data.
    IT              PLANILHA_EXCEL%ROWTYPE;
 --
 -- Global instance for counters.
    L_COUNT         NUMBER := 0;
 --
 -- Global instance for BASONIMO group.
    L_BASONIMOS     VARCHAR2(255) := NULL;
 --
 -- Global instance from unique BASONIMO.
    L_BASONIMO      VARCHAR2(255) := NULL;
 --
 -- Global instance for BASONIMO group.
    L_AUTHOR        VARCHAR2(255) := NULL;
 --
 -- Global instance from unique BASONIMO.
    L_AUTHORS       VARCHAR2(255) := NULL;
 --
 -- Global auxliars id's for insertion in tables.
    L_ID1           NUMBER := 0;
    L_ID2           NUMBER := 0;
    L_ID3           NUMBER := 0;
 --
 -- dictionary to relate names with acronyms of federal units.
    L_UF_DICT       DICT;
 --
 -- dictionary to relate names with acronyms of categories.
    L_CATEGORY_DICT DICT;
 --
 -- dictionary to relate names with acronyms of types of units o conservation.
    L_TUC_DICT      DICT;
BEGIN
 --
 -- Initialize the dictionary of federal units.
    L_UF_DICT('AC') := 'Acre';
    L_UF_DICT('AL') := 'Alagoas';
    L_UF_DICT('AP') := 'Amapá';
    L_UF_DICT('AM') := 'Amazonas';
    L_UF_DICT('BA') := 'Bahia';
    L_UF_DICT('CE') := 'Ceará';
    L_UF_DICT('DF') := 'Distrito Federal';
    L_UF_DICT('ES') := 'Espirito Santo';
    L_UF_DICT('GO') := 'Goiais';
    L_UF_DICT('MA') := 'Maranhão';
    L_UF_DICT('MT') := 'Mato Grosso';
    L_UF_DICT('MS') := 'Mato Grosso do Sul';
    L_UF_DICT('PA') := 'Pará';
    L_UF_DICT('PB') := 'Paraíba';
    L_UF_DICT('PR') := 'Paraná';
    L_UF_DICT('PE') := 'Pernambuco';
    L_UF_DICT('PI') := 'Piauí';
    L_UF_DICT('RJ') := 'Rio de Janeiro';
    L_UF_DICT('RN') := 'Rio Grande do Norte';
    L_UF_DICT('RS') := 'Rio Grande do Sul';
    L_UF_DICT('RO') := 'Rondônia';
    L_UF_DICT('RR') := 'Roraima';
    L_UF_DICT('SC') := 'Santa Catarina';
    L_UF_DICT('SP') := 'São Paulo';
    L_UF_DICT('SE') := 'Sergipe';
    L_UF_DICT('MG') := 'Minar Gerais';
    L_UF_DICT('TO') := 'Tocatins';
 --
 -- Initialize the dictionary of categories.
    L_CATEGORY_DICT('EN') := 'Em Perigo';
    L_CATEGORY_DICT('VU') := 'Vulnerável';
    L_CATEGORY_DICT('CR') := 'Em Perigo Crítico';
    L_CATEGORY_DICT('LC') := 'Segura';
    L_CATEGORY_DICT('NT') := 'Quase Ameaçada';
    L_CATEGORY_DICT('EW') := 'Extinta na Natureza';
    L_CATEGORY_DICT('EX') := 'Extinta';
 --
 -- Initialize the dictionary of types of conservation units.
    L_TUC_DICT('US') := 'Uso Sustentável';
    L_TUC_DICT('PI') := 'Proteção Integral';
 --
 -- Opening cursor with PLANILHA_ECXEL data.
    OPEN L_CURSOR FOR
        SELECT
            "A1"."UC"        "UC",
            "A1"."TIPOUC"    "TIPOUC",
            "A1"."ESFERA"    "ESFERA",
            "A1"."UF"        "UF",
            "A1"."MUNICIPIO" "MUNICIPIO",
            "A1"."BIOMA"     "BIOMA",
            "A1"."FAMILIA"   "FAMILIA",
            "A1"."ESPECIE"   "ESPECIE",
            "A1"."AUTOR"     "AUTOR",
            "A1"."CATEGORIA" "CATEGORIA"
        FROM
            "EC2022GRUPO01"."PLANILHA_EXCEL" "A1";
 -- iterate over L_CURSOR data.
    LOOP
 -- fecth a data row in the auliar row.
        FETCH L_CURSOR INTO IT;
 -- break point
        EXIT WHEN L_CURSOR%NOTFOUND;
 --
 -- ! ALGORITM TO INSERT VALUES INTO TABLE WITHOUT FOREIGN KEYS.
 -- 1. Checks by references of value into table.
 -- 2. If not found references, inserts a new value into table, otherwise dont insert.
 --
 -- * NOTE: To insert a new value into tables with foreign keys, not is necessary
 -- * verify if value exits into the foreign table, because the value has already
 -- * been inserted if it does not exist, due to the insertion sequence.
 --
 -- ! ALGORITM TO INSERT VALUES INTO TABLE WITH FOREIGN KEYS.
 -- 1. Checks by references of value into table.
 -- 2. If not found references.
 --     2.1 Select a ID into auxiliar variable for each foreign key in the table.
 --     2.2 Insert a new value into table relates id's with foreing keys.
 --
 -- ! ALGORITM TO INSERT VALUES INTO ASSOCIATION TABLE.
 -- 1. Select a ID into auxiliar variable for each foreign key in the table.
 -- 2. Insert a new value into table relates id's with foreing keys.
 --
 -- ------------------------------------------------------ --
 --                       CATEGORIA                        --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            CATEGORIA
        WHERE
            SIGLA=IT.CATEGORIA;
        IF L_COUNT = 0 THEN
            INSERT INTO CATEGORIA (
                NOME,
                SIGLA
            ) VALUES (
                L_CATEGORY_DICT(IT.CATEGORIA),
                IT.CATEGORIA
            );
            DBMS_OUTPUT.PUT_LINE('Inserting a new value into CATEGORIA ['
                || IT.CATEGORIA
                || ']');
        END IF;
 --
 -- The field IT.AUTOR composes data from BASONIMO, AUTHOR tables and
 -- relates this data. The treatment for the data of these tables is
 -- done in the same block.
 -- FORMAT OF FIELD:
 -- BASONIMO: .*,
 -- AUTOR: .*,
 -- BASONIMOS: BASONIMO [& BASONIMO_VAL]
 -- AUTORS: AUTOR [& AUTOR_VAL]
 -- FIELD_VAL: (BASONIMOS) AUTORS
 -- where [ANY] represents a optional value.
 --
 -- ------------------------------------------------------ --
 --                       BASONIMO                         --
 -- ------------------------------------------------------ --
        SELECT
            REPLACE( REPLACE(REGEXP_SUBSTR ( IT.AUTOR,
            '\(.*\)'),
            '(',
            ''),
            ')',
            '') INTO L_BASONIMOS
        FROM
            DUAL;
 --
 -- Look over BASONIMOS.
 --
        FOR I IN(
            SELECT
                TRIM(REGEXP_SUBSTR( L_BASONIMOS,
                '[^&]+',
                1,
                LEVEL)) VAL
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(L_BASONIMOS,
                '[^&]+',
                1,
                LEVEL) IS NOT NULL
        ) LOOP
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
            IF I.VAL IS NOT NULL THEN
                SELECT
                    COUNT(1) INTO L_COUNT
                FROM
                    BASONIMO
                WHERE
                    NOME=I.VAL;
                IF L_COUNT = 0 THEN -- Not exists
                    INSERT INTO BASONIMO (
                        NOME
                    ) VALUES (
                        I.VAL
                    );
                    DBMS_OUTPUT.PUT_LINE('Inserting a new value into BASONIMO ['
                        || I.VAL
                        || ']');
                END IF;
            END IF;
        END LOOP;
 -- ------------------------------------------------------ --
 --                        AUTOR                           --
 -- ------------------------------------------------------ --
 -- Remove a basomios from data.
        SELECT
            REPLACE( IT.AUTOR,
            ('(' || L_BASONIMOS || ')' ),
            '' ) INTO L_AUTHORS
        FROM
            DUAL;
 -- Look over authors.
        FOR I IN (
            SELECT
                TRIM(REGEXP_SUBSTR( L_AUTHORS,
                '[^&]+',
                1,
                LEVEL)) VAL
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(L_AUTHORS,
                '[^&]+',
                1,
                LEVEL) IS NOT NULL
        ) LOOP
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
            IF I.VAL IS NOT NULL THEN
                SELECT
                    COUNT(1) INTO L_COUNT
                FROM
                    AUTOR
                WHERE
                    NOME=I.VAL;
                IF L_COUNT = 0 THEN -- Not exists
                    INSERT INTO AUTOR (
                        NOME
                    ) VALUES (
                        I.VAL
                    );
                    DBMS_OUTPUT.PUT_LINE('Inserting a new value into AUTOR ['
                        || I.VAL
                        || ']');
                END IF;
            END IF;
        END LOOP;
 -- ------------------------------------------------------ --
 --                      BIOMA_IBGE                       --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
 --
 -- There are specific cases that need for replacement.
 -- Replace 'AMAZONIA' with 'AMAZÔNIA'
        IF IT.BIOMA = 'AMAZONIA' THEN
            SELECT
                REPLACE(IT.BIOMA,
                'AMAZONIA',
                'AMAZÔNIA')INTO IT.BIOMA
            FROM
                DUAL;
 -- Replace 'MATA ATLANTICA' with 'MATA ATLÂNTICA'
        ELSIF IT.BIOMA = 'MATA ATLANTICA' THEN
            SELECT
                REPLACE(IT.BIOMA,
                'MATA ATLANTICA',
                'MATA ATLÂNTICA') INTO IT.BIOMA
            FROM
                DUAL;
        END IF;
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            BIOMA_IBGE
        WHERE
            NOME=IT.BIOMA;
        IF L_COUNT = 0 THEN
            INSERT INTO BIOMA_IBGE (
                NOME
            ) VALUES (
                IT.BIOMA
            );
            DBMS_OUTPUT.PUT_LINE('Inserting a new value into BIOMA_IBGE ['
                || IT.BIOMA
                || ']');
        END IF;
 -- ------------------------------------------------------ --
 --                    FAMILIA_BOTANICA                    --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            FAMILIA_BOTANICA
        WHERE
            NOME=IT.FAMILIA;
        IF L_COUNT = 0 THEN
            INSERT INTO FAMILIA_BOTANICA(
                NOME,
                ID_BIOMA_IBGE
            ) VALUES (
                IT.FAMILIA,
                (SELECT ID FROM BIOMA_IBGE WHERE NOME=IT.BIOMA)
            );
            DBMS_OUTPUT.PUT_LINE('Inserting a new value into FAMILIA_BOTANICA ['
                || IT.FAMILIA
                || ']');
        END IF;
 -- ------------------------------------------------------ --
 --                        PLANTA                          --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            PLANTA
        WHERE
            NOME_CIENTIFICO=IT.ESPECIE;
        IF L_COUNT = 0 THEN -- Not exists reference.
            INSERT INTO PLANTA(
                NOME_CIENTIFICO,
                ID_FAMILIA_BOTANICA,
                ID_CATEGORIA
            ) VALUES (
                IT.ESPECIE,
                (SELECT ID FROM FAMILIA_BOTANICA WHERE NOME=IT.FAMILIA),
                (SELECT ID FROM CATEGORIA WHERE SIGLA=IT.CATEGORIA)
            );
            DBMS_OUTPUT.PUT_LINE('Inserting a new value into PLANTA ['
                || IT.ESPECIE
                || ']');
        END IF;
 -- ------------------------------------------------------ --
 --                      AUTOR_PLANTA                      --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
 -- It is necessary to fetch the id that corresponds to each value,
 -- then check if there is such a pair in the table AUTOR_PLANTA.
 --
 -- As there can be several authors, it is necessary to iterate over the line.
        FOR I IN (
            SELECT
                TRIM(REGEXP_SUBSTR( L_AUTHORS,
                '[^&]+',
                1,
                LEVEL)) VAL
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(L_AUTHORS,
                '[^&]+',
                1,
                LEVEL) IS NOT NULL
        ) LOOP
 -- Id of AUTOR.
            SELECT
                ID INTO L_ID1
            FROM
                AUTOR
            WHERE
                NOME = I.VAL;
 -- Id of PLANTA.
            SELECT
                ID INTO L_ID2
            FROM
                PLANTA
            WHERE
                NOME_CIENTIFICO = IT.ESPECIE;
 -- Check for pair into table.
            SELECT
                COUNT(1) INTO L_COUNT
            FROM
                AUTOR_PLANTA
            WHERE
                (ID_AUTOR = L_ID1)
                AND (ID_PLANTA = L_ID2);
            IF L_COUNT = 0 THEN -- No pair found in table.
                INSERT INTO AUTOR_PLANTA (
                    ID_AUTOR,
                    ID_PLANTA
                ) VALUES (
                    L_ID1,
                    L_ID2
                );
                DBMS_OUTPUT.PUT_LINE('Inserting a new value into AUTOR_PLANTA ['
                    || I.VAL
                    || ', '
                    || IT.ESPECIE
                    || '] : ['
                    || L_ID1
                    || ', '
                    || L_ID2
                    || ']');
            END IF;
        END LOOP;
 -- ------------------------------------------------------ --
 --                    BASONIMO_PLANTA                     --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
 -- As there can be several basononyms, it is necessary to iterate over the line.
        SELECT
            LENGTH(L_BASONIMOS) INTO L_COUNT
        FROM
            DUAL;
        IF L_COUNT > 0 THEN
            FOR I IN (
                SELECT
                    TRIM(REGEXP_SUBSTR( L_BASONIMOS,
                    '[^&]+',
                    1,
                    LEVEL)) VAL
                FROM
                    DUAL
                CONNECT BY
                    REGEXP_SUBSTR( L_BASONIMOS,
                    '[^&]+',
                    1,
                    LEVEL) IS NOT NULL
            ) LOOP
 -- Id of BASONIMO.
                SELECT
                    ID INTO L_ID1
                FROM
                    BASONIMO
                WHERE
                    NOME = I.VAL;
 -- Id of PLANTA.
                SELECT
                    ID INTO L_ID2
                FROM
                    PLANTA
                WHERE
                    NOME_CIENTIFICO = IT.ESPECIE;
 -- Check for pair into table.
                SELECT
                    COUNT(1) INTO L_COUNT
                FROM
                    BASONIMO_PLANTA
                WHERE
                    (ID_BASONIMO = L_ID1)
                    AND (ID_PLANTA = L_ID2);
                IF L_COUNT = 0 THEN -- No pair found in table.
                    INSERT INTO BASONIMO_PLANTA (
                        ID_BASONIMO,
                        ID_PLANTA
                    ) VALUES (
                        L_ID1,
                        L_ID2
                    );
                    DBMS_OUTPUT.PUT_LINE('Inserting a new value into BASONIMO_PLANTA ['
                        || I.VAL
                        || ', '
                        || IT.ESPECIE
                        || '] : ['
                        || L_ID1
                        || ', '
                        || L_ID2
                        || ']');
                END IF;
            END LOOP;
        END IF;
 -- ------------------------------------------------------ --
 --                 TIPO_UNIDADE_CONSERVACAO               --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            TIPO_UNIDADE_CONSERVACAO
        WHERE
            SIGLA=IT.TIPOUC;
        IF L_COUNT = 0 THEN
            INSERT INTO TIPO_UNIDADE_CONSERVACAO (
                SIGLA,
                NOME
            ) VALUES(
                IT.TIPOUC,
                L_TUC_DICT(IT.TIPOUC)
            );
            DBMS_OUTPUT.PUT_LINE('Inserting a new value into TIPO_UNIDADE_CONSERVACAO ['
                || IT.TIPOUC
                || ']');
        END IF;
 -- ------------------------------------------------------ --
 --                        ESFERA                          --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            ESFERA
        WHERE
            NOME=IT.ESFERA;
        IF L_COUNT = 0 THEN
            INSERT INTO ESFERA (
                NOME
            ) VALUES (
                IT.ESFERA
            );
            DBMS_OUTPUT.PUT_LINE('Inserting a new value into ESFERA ['
                || IT.ESFERA
                || ']');
        END IF;
 -- ------------------------------------------------------ --
 --                   UNIDADE_FEDERAL                      --
 -- ------------------------------------------------------ --
 -- The values ​​of the federative units are separated by '/',
 -- then it is necessary to separate them and iterate over each value.
        FOR I IN (
            SELECT
                TRIM(REGEXP_SUBSTR(IT.UF,
                '[^/]+',
                1,
                LEVEL)) VAL
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(IT.UF,
                '[^/]+',
                1,
                LEVEL) IS NOT NULL
        ) LOOP
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
            SELECT
                COUNT(1) INTO L_COUNT
            FROM
                UNIDADE_FEDERAL
            WHERE
                SIGLA=I.VAL;
            IF L_COUNT = 0 THEN
                INSERT INTO UNIDADE_FEDERAL (
                    SIGLA,
                    NOME
                ) VALUES (
                    I.VAL,
                    L_UF_DICT(I.VAL)
                );
                DBMS_OUTPUT.PUT_LINE('Inserting a new value into UNIDADE_FEDERAL ['
                    || I.VAL
                    || ']');
            END IF;
        END LOOP;
 -- ------------------------------------------------------ --
 --                       MUNICIPIO                         --
 -- ------------------------------------------------------ --
 -- The values of the MUNICIPIO are separated by ',',
 -- so it is necessary to separate them and iterate over each value.
        FOR I IN (
            SELECT
                REPLACE(TRIM(REGEXP_SUBSTR(IT.MUNICIPIO,
                '[^,]+',
                1,
                LEVEL)),
                '.',
                '') VAL
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(IT.MUNICIPIO,
                '[^,]+',
                1,
                LEVEL) IS NOT NULL
        ) LOOP
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
 -- ! EM ALGUMAS LINHAS DA TABELA TEM UM BENDITO DE 'mais .*'.
 -- ! REPRESENTA A QUANTIDADE DE MUNICIPIOS QUE NÃO COUBERAM NA LINHA.
            SELECT
                REGEXP_COUNT(I.VAL,
                '^mais .*',
                1) INTO L_COUNT
            FROM
                DUAL;
            IF L_COUNT = 0 THEN -- ignore sentence.
                SELECT
                    COUNT(1) INTO L_COUNT
                FROM
                    MUNICIPIO
                WHERE
                    NOME=I.VAL;
                IF L_COUNT = 0 THEN
                    INSERT INTO MUNICIPIO (
                        NOME
                    ) VALUES (
                        I.VAL
                    );
                    DBMS_OUTPUT.PUT_LINE('Inserting a new value into MUNICIPIO ['
                        || I.VAL
                        || ']');
                END IF;
            END IF;
        END LOOP;
 --
 -- ------------------------------------------------------ --
 --                   UNIDADE_CONSERVACAO                  --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            UNIDADE_CONSERVACAO
        WHERE
            NOME = IT.UC;
        IF L_COUNT = 0 THEN -- No reference found.
 -- Id of ESFERA.
            SELECT
                ID INTO L_ID1
            FROM
                ESFERA
            WHERE
                NOME = IT.ESFERA;
 -- Id of TIPO_UNIDADE_CONSERVACAO.
            SELECT
                ID INTO L_ID2
            FROM
                TIPO_UNIDADE_CONSERVACAO
            WHERE
                SIGLA = IT.TIPOUC;
 -- Id of BIOMA_IBGE.
            SELECT
                ID INTO L_ID3
            FROM
                BIOMA_IBGE
            WHERE
                NOME = IT.BIOMA;
 -- Insert values.
            INSERT INTO UNIDADE_CONSERVACAO(
                NOME,
                ID_ESFERA,
                ID_TIPO_UNIDADE_CONSERVACAO,
                ID_BIOMA_IBGE
            ) VALUES (
                IT.UC,
                L_ID1,
                L_ID2,
                L_ID3
            );
            DBMS_OUTPUT.PUT_LINE( 'Inserting a new value into UNIDADE_CONSERVACAO ['
                || IT.UC
                || ', '
                || L_ID1
                || ', '
                || L_ID2
                || ', '
                || L_ID3
                || ']' );
        END IF;
 -- ------------------------------------------------------ --
 --             UNIDADE_CONSERVACAO_MUNICIPIO              --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
        FOR I IN (
            SELECT
                REPLACE(TRIM(REGEXP_SUBSTR(IT.MUNICIPIO,
                '[^,]+',
                1,
                LEVEL)),
                '.',
                '') VAL
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(IT.MUNICIPIO,
                '[^,]+',
                1,
                LEVEL) IS NOT NULL
        ) LOOP
 -- ! EM ALGUMAS LINHAS DA TABELA TEM UM BENTIDO DE 'mais .*'.
 -- ! REPRESENTA A QUANTIDADE DE MUNICPIOS QUE NÃO COUBERAM NA LINHA.
            SELECT
                REGEXP_COUNT(I.VAL,
                '^mais .*',
                1) INTO L_COUNT
            FROM
                DUAL;
            IF L_COUNT = 0 THEN -- ignore sentence.
 -- Id of UNIDADE_CONSERVACAO.
                SELECT
                    ID INTO L_ID1
                FROM
                    UNIDADE_CONSERVACAO
                WHERE
                    NOME = IT.UC;
 -- Id of MUNICIPIO.
                SELECT
                    ID INTO L_ID2
                FROM
                    MUNICIPIO
                WHERE
                    NOME = I.VAL;
 -- Check for pair into table.
                SELECT
                    COUNT(1) INTO L_COUNT
                FROM
                    UNIDADE_CONSERVACAO_MUNICIPIO
                WHERE
                    (ID_UNIDADE_CONSERVACAO = L_ID1)
                    AND (ID_MUNICIPIO = L_ID2);
                IF L_COUNT = 0 THEN -- No pair found in table.
                    INSERT INTO UNIDADE_CONSERVACAO_MUNICIPIO (
                        ID_UNIDADE_CONSERVACAO,
                        ID_MUNICIPIO
                    ) VALUES (
                        L_ID1,
                        L_ID2
                    );
                    DBMS_OUTPUT.PUT_LINE('Inserting a new value into UNIDADE_CONSERVACAO_MUNICIPIO ['
                        || IT.UC
                        || ', '
                        || I.VAL
                        || '] : ['
                        || L_ID1
                        || ', '
                        || L_ID2
                        || ']');
                END IF;
            END IF;
        END LOOP;
 -- ------------------------------------------------------ --
 --             UNIDADE_CONSERVACAO_FEDERAL            --
 -- ------------------------------------------------------ --
 -- Look for a reference in the table. If the value does not exist,
 -- insert the value in the table.
 --
 -- Id of UNIDADE_CONSERVACAO.
        SELECT
            ID INTO L_ID1
        FROM
            UNIDADE_CONSERVACAO
        WHERE
            NOME = IT.UC;
 --
 -- The values ​​of the federative units are separated by '/',
 -- then it is necessary to separate them and iterate over each value.
        FOR I IN (
            SELECT
                TRIM(REGEXP_SUBSTR(IT.UF,
                '[^/]+',
                1,
                LEVEL)) VAL
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(IT.UF,
                '[^/]+',
                1,
                LEVEL) IS NOT NULL
        ) LOOP
 -- Id of UNIDADE_FEDERAL.
            SELECT
                ID INTO L_ID2
            FROM
                UNIDADE_FEDERAL
            WHERE
                SIGLA = I.VAL;
 -- Check for pair into table.
            SELECT
                COUNT(1) INTO L_COUNT
            FROM
                UNIDADE_CONSERVACAO_FEDERAL
            WHERE
                (ID_UNIDADE_CONSERVACAO = L_ID1)
                AND (ID_UNIDADE_FEDERAL = L_ID2);
            IF L_COUNT = 0 THEN -- No pair found in table.
                INSERT INTO UNIDADE_CONSERVACAO_FEDERAL (
                    ID_UNIDADE_CONSERVACAO,
                    ID_UNIDADE_FEDERAL
                ) VALUES (
                    L_ID1,
                    L_ID2
                );
                DBMS_OUTPUT.PUT_LINE('Inserting a new value into UNIDADE_CONSERVACAO_FEDERAL ['
                    || IT.UC
                    || ', '
                    || I.VAL
                    || '] : ['
                    || L_ID1
                    || ', '
                    || L_ID2
                    || ']');
            END IF;
        END LOOP;
    END LOOP;
 -- end iteration data
    CLOSE L_CURSOR;
END;