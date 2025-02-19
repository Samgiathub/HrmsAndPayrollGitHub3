CREATE TABLE [dbo].[T0200_PRE_SALARY_backup_10082022] (
    [Row_Id]           NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Salary_Parameter] VARCHAR (2000)  NULL,
    [is_Manual]        TINYINT         NULL,
    [Cmp_id]           NUMERIC (18, 2) NULL,
    [From_date]        DATETIME        NULL,
    [To_Date]          DATETIME        NULL,
    [ID]               VARCHAR (200)   NULL,
    [BackEnd_Salary]   TINYINT         NULL,
    [Processed]        INT             NULL
);

