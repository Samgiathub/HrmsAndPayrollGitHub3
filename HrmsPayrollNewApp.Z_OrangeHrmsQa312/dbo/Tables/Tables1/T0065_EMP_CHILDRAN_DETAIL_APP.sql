CREATE TABLE [dbo].[T0065_EMP_CHILDRAN_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT          NOT NULL,
    [Emp_Application_ID] INT             NOT NULL,
    [Row_ID]             INT             NOT NULL,
    [Cmp_ID]             INT             NOT NULL,
    [Name]               VARCHAR (100)   NOT NULL,
    [Gender]             CHAR (1)        NOT NULL,
    [Date_Of_Birth]      DATETIME        NULL,
    [C_Age]              NUMERIC (18, 1) NULL,
    [Relationship]       VARCHAR (50)    NULL,
    [Is_Resi]            NUMERIC (1)     NULL,
    [Is_Dependant]       TINYINT         NULL,
    [Image_Path]         VARCHAR (100)   NULL,
    [Pan_Card_No]        VARCHAR (20)    NULL,
    [Adhar_Card_No]      VARCHAR (20)    NULL,
    [Approved_Emp_ID]    INT             NULL,
    [Approved_Date]      DATETIME        NULL,
    [Rpt_Level]          INT             NULL,
    CONSTRAINT [FK_T0065_EMP_CHILDRAN_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

