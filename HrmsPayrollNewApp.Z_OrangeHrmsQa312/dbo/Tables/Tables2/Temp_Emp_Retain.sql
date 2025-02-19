CREATE TABLE [dbo].[Temp_Emp_Retain] (
    [Cmp_id]           NUMERIC (18)    NULL,
    [Emp_ID]           NUMERIC (18)    NULL,
    [Branch_ID]        NUMERIC (18)    NULL,
    [Grd_ID]           NUMERIC (18)    NULL,
    [Join_Date]        DATETIME        NULL,
    [Start_Date]       DATETIME        NULL,
    [End_Date]         DATETIME        NULL,
    [Period]           NUMERIC (18, 2) NULL,
    [Basic_Salary]     NUMERIC (18, 2) NULL,
    [mode]             VARCHAR (50)    NULL,
    [Amount]           NUMERIC (18, 2) NULL,
    [Net_Amount]       NUMERIC (18, 2) NULL,
    [Ad_id]            NUMERIC (18)    NULL,
    [Other_Amount]     NUMERIC (18, 2) NULL,
    [Tran_Id]          INT             NULL,
    [Emp_Ret_Count]    INT             NULL,
    [MonLock_Trans_Id] INT             NULL
);

