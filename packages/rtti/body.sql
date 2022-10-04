CREATE OR REPLACE PACKAGE BODY RTTI IS
 --
 --
 --
    FUNCTION TYPE_OF(
        RV_FIELD IN VARCHAR2
    ) RETURN VARCHAR2 IS
        LFA_ARGS WWV_FLOW_T_VARCHAR2;
        LV_TYPE  VARCHAR2(32767);
    BEGIN
        LFA_ARGS := UTILITY.EXPLODE(RV_FIELD, '.');
        IF LFA_ARGS.COUNT < 2 THEN
            RAISE_APPLICATION_ERROR(-20000, 'Invalid number of parameters. The format of the parameter must be one of the following: TABLE.FIELD');
        END IF;
 --
        SELECT
            COALESCE(DATA_TYPE,
            NULL) INTO LV_TYPE
        FROM
            ALL_TAB_COLUMNS
        WHERE
            UPPER(UTILITY.REMOVE_ACCENTS(TABLE_NAME)) = UPPER(UTILITY.REMOVE_ACCENTS(LFA_ARGS(1)))
            AND UPPER(UTILITY.REMOVE_ACCENTS(COLUMN_NAME)) = UPPER(UTILITY.REMOVE_ACCENTS(LFA_ARGS(2)));
        RETURN LV_TYPE;
 --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Unknown table or column.');
    END;
 --
 --
 --
END;