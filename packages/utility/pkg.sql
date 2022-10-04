CREATE OR REPLACE PACKAGE UTILITY IS
 /*
    Checks if has value into reference into table.  
    Returns 1 if reference exists, 0 otherwise.
*/
    FUNCTION HAS_VALUE(
        RV_TABLE IN VARCHAR2,
        RV_FIELD IN VARCHAR2,
        RV_VALUE IN VARCHAR2
    ) RETURN NUMBER;
 /*
    */
    FUNCTION EXPLODE(
        RV_STRING IN VARCHAR2,
        RV_DELIMITER IN VARCHAR2
    ) RETURN WWV_FLOW_T_VARCHAR2;
 /*
    */
    FUNCTION EXPLODE (
        RV_STRING IN VARCHAR2,
        RV_DELIMITER IN VARCHAR2,
        RN_LIMIT IN NUMBER
    ) RETURN WWV_FLOW_T_VARCHAR2;
 /*
    */
    FUNCTION REMOVE_ACCENTS(
        RV_STRING IN VARCHAR2
    ) RETURN STRING;
 /*
    */
    FUNCTION EXTRACT_SUBSTRS (
        RV_COMPLETE_STRING IN VARCHAR2,
        RV_START IN VARCHAR2,
        RV_END IN VARCHAR2
    ) RETURN WWV_FLOW_T_VARCHAR2;
 /*
    */
    FUNCTION IS_NUMBER(
        RV_VALUE IN VARCHAR2
    ) RETURN NUMBER;
END;