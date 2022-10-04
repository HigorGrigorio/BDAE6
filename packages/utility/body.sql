CREATE OR REPLACE PACKAGE BODY UTILITY IS
 --
 --
 --
    FUNCTION HAS_VALUE(
        RV_TABLE IN VARCHAR2,
        RV_FIELD IN VARCHAR2,
        RV_VALUE IN VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN 0;
    END;
 --
 --E
 --
    FUNCTION EXPLODE(
        RV_STRING IN VARCHAR2,
        RV_DELIMITER IN VARCHAR2
    ) RETURN WWV_FLOW_T_VARCHAR2 AS
    BEGIN
        RETURN APEX_STRING.SPLIT(RV_STRING, RV_DELIMITER);
    END;
 --
 --
 --
    FUNCTION EXPLODE(
        RV_STRING IN VARCHAR2,
        RV_DELIMITER IN VARCHAR2,
        RN_LIMIT IN NUMBER
    ) RETURN WWV_FLOW_T_VARCHAR2 AS
    BEGIN
        RETURN APEX_STRING.SPLIT(RV_STRING, RV_DELIMITER, RN_LIMIT);
    END;
 --
 --
 --
    FUNCTION REMOVE_ACCENTS(
        RV_STRING IN VARCHAR2
    ) RETURN STRING IS
        LC_TRANSLETED VARCHAR2(32767);
    BEGIN
        SELECT
            TRANSLATE ( RV_STRING,
            'ŠŽŠŽŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝÅÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝŸ',
            'SZSZYACEIOUAEIOUAEIOUAOEUIONYAACEIOUAEIOUAEIOUAOEUIONYY') INTO LC_TRANSLETED
        FROM
            DUAL;
        RETURN LC_TRANSLETED;
    END;
 --
 --
 --
    FUNCTION EXTRACT_SUBSTRS(
        RV_COMPLETE_STRING IN VARCHAR2,
        RV_START IN VARCHAR2,
        RV_END IN VARCHAR2
    ) RETURN WWV_FLOW_T_VARCHAR2 IS
        LAV_STR  APEX_T_VARCHAR2;
        LV_REGEX VARCHAR(255);
    BEGIN
        LV_REGEX := '(\'
            || RV_START
            || ')(.+?)(\'
            || RV_END
            || ')';
        SELECT
            REPLACE(REPLACE(REGEXP_SUBSTR(RV_COMPLETE_STRING,
            LV_REGEX,
            1,
            LEVEL),
            RV_END,
            ''),
            RV_START,
            '') BULK COLLECT INTO LAV_STR
        FROM
            DUAL
        CONNECT BY
            REGEXP_SUBSTR(RV_COMPLETE_STRING,
            LV_REGEX,
            1,
            LEVEL) IS NOT NULL;
        RETURN LAV_STR;
    END;
 --
 --
 --
    FUNCTION IS_NUMBER(
        RV_VALUE IN VARCHAR2
    ) RETURN NUMBER IS
        LN_N NUMBER;
    BEGIN
        LN_N := TO_NUMBER(RV_VALUE);
        RETURN 1;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            RETURN 0;
    END;
END;