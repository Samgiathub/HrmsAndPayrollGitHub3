CREATE TABLE [dbo].[T0090_EMP_DEPENDANT_DETAIL_Clone] (
    [Emp_ID]       NUMERIC (18)    NOT NULL,
    [Row_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]       NUMERIC (18)    NOT NULL,
    [Name]         VARCHAR (100)   NOT NULL,
    [RelationShip] VARCHAR (20)    NOT NULL,
    [BirthDate]    DATETIME        NULL,
    [D_Age]        NUMERIC (18, 1) NULL,
    [Address]      VARCHAR (1000)  NULL,
    [Share]        NUMERIC (18, 2) NULL,
    [Is_Resi]      NUMERIC (18, 1) NULL,
    [NomineeFor]   VARCHAR (30)    NULL,
    [System_Date]  DATETIME        NOT NULL,
    [Login_Id]     NUMERIC (18)    NOT NULL
);

