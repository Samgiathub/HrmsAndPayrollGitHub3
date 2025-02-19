CREATE TABLE [dbo].[T9999_IT_Employe_History] (
    [Tran_Id]        NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]         NUMERIC (18)    NULL,
    [Emp_Id]         NUMERIC (18)    NULL,
    [IT_Id]          NUMERIC (18)    NULL,
    [IT_Name]        VARCHAR (350)   NULL,
    [Financial_Year] VARCHAR (50)    NULL,
    [Login_Id]       NUMERIC (18)    NULL,
    [For_Date]       DATETIME        NULL,
    [Amount]         NUMERIC (18, 2) NULL,
    [Amount_Ess]     NUMERIC (18, 2) NULL,
    [Details_1]      VARCHAR (MAX)   NULL,
    [Details_2]      VARCHAR (MAX)   NULL,
    [Details_3]      VARCHAR (MAX)   NULL,
    [Comments]       VARCHAR (MAX)   NULL,
    [Flag]           NUMERIC (18)    NULL,
    [System_date]    DATETIME        CONSTRAINT [DF_T9999_IT_Employe_History_System_date] DEFAULT (getdate()) NOT NULL,
    [Is_Verified]    TINYINT         CONSTRAINT [DF_T9999_IT_Employe_History_Is_Verified] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T9999_IT_Employe_History] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_T9999_IT_Employe_History_CmpId_FinYear_IsVerified_EmpId_SystemDate]
    ON [dbo].[T9999_IT_Employe_History]([Cmp_Id] ASC, [Financial_Year] ASC, [Is_Verified] ASC)
    INCLUDE([Emp_Id], [System_date]) WITH (FILLFACTOR = 80);

