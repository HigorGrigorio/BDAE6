CREATE OR REPLACE PACKAGE BDAE6 IS

    PROCEDURE INSERT_CATEGORIA_IF_NOT_EXIST(
        RV_NOME IN VARCHAR2,
        RV_SIGLA IN VARCHAR2
    );

END;