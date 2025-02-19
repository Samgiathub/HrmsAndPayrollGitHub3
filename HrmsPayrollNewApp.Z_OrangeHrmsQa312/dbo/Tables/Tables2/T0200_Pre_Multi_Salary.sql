CREATE TABLE [dbo].[T0200_Pre_Multi_Salary] (
    [Row_Id]           NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Salary_Parameter] VARCHAR (2000)  NULL,
    [is_Manual]        TINYINT         NULL,
    [Emp_id]           NUMERIC (18)    NULL,
    [Cmp_id]           NUMERIC (18, 2) NULL,
    [For_date]         DATETIME        NULL,
    [From_date]        DATETIME        NULL,
    [To_Date]          DATETIME        NULL,
    [ID]               VARCHAR (200)   NULL,
    [BackEnd_Salary]   TINYINT         NULL,
    [Processed]        INT             NULL,
    [UserId]           NUMERIC (18)    NULL,
    [Date]             DATETIME        NULL,
    [StartTime]        DATETIME        NULL,
    [EndTime]          DATETIME        NULL,
    CONSTRAINT [PK_T0200_Pre_Salary] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 95)
);

