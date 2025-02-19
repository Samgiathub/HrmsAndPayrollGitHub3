CREATE TABLE [dbo].[T0250_IT_Acknowledge_No] (
    [Row_Id]                NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]                NUMERIC (18)    NOT NULL,
    [Login_Id]              NUMERIC (18)    NOT NULL,
    [Transaction_Id]        NUMERIC (18)    NULL,
    [Financial_Year]        NVARCHAR (50)   NULL,
    [First_Qaurter_No]      NVARCHAR (200)  NULL,
    [Second_Qaurter_No]     NVARCHAR (200)  NULL,
    [Third_Qaurter_No]      NVARCHAR (200)  NULL,
    [Fourth_Qaurter_No]     NVARCHAR (200)  NULL,
    [Sysdate]               DATETIME        NULL,
    [First_Qaurter_Amount]  NUMERIC (18, 2) NULL,
    [Second_Qaurter_Amount] NUMERIC (18, 2) NULL,
    [Third_Qaurter_Amount]  NUMERIC (18, 2) NULL,
    [Fourth_Qaurter_Amount] NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0250_IT_Acknowledge_No] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80)
);

