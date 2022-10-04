CREATE TABLE UNIDADE_CONSERVACAO_FEDERAL(
    ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    ID_UNIDADE_FEDERAL NUMBER NOT NULL,
    ID_UNIDADE_CONSERVACAO NUMBER NOT NULL,
    FOREIGN KEY (ID_UNIDADE_CONSERVACAO) REFERENCES UNIDADE_CONSERVACAO(ID),
    FOREIGN KEY (ID_UNIDADE_FEDERAL) REFERENCES UNIDADE_FEDERAL(ID),
    PRIMARY KEY(ID)
);