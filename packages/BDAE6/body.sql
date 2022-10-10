CREATE OR REPLACE PACKAGE BODY BDAE6 IS
   --
    PROCEDURE INSERT_CATEGORIA_IF_NOT_EXIST(
        RV_NOME IN VARCHAR2,
        RV_SIGLA IN VARCHAR2
    ) AS
        L_COUNT NUMBER;
    BEGIN
 -- check if the values already exist in the database.
        SELECT
            COUNT(1) INTO L_COUNT
        FROM
            CATEGORIA
        WHERE
            UPPER(UTILITY.REMOVE_ACCENTS(NOME)) = UPPER(UTILITY.REMOVE_ACCENTS(RV_NOME))
            AND UPPER(UTILITY.REMOVE_ACCENTS(SIGLA)) = UPPER(UTILITY.REMOVE_ACCENTS(RV_SIGLA));
 --
        IF L_COUNT = 0 THEN
            INSERT INTO CATEGORIA(
                NOME,
                SIGLA
            ) VALUES (
                RV_NOME,
                RV_SIGLA
            );
        END IF;
    END;



END;