CREATE TABLE [dbo].[T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY] (
    [Row_id]       INT           IDENTITY (1, 1) NOT NULL,
    [Emp_id]       INT           NOT NULL,
    [Old_R_Emp_id] INT           NOT NULL,
    [New_R_Emp_id] INT           NOT NULL,
    [Cmp_id]       INT           NOT NULL,
    [Change_date]  DATETIME      CONSTRAINT [DF_T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY_Change_date] DEFAULT (getdate()) NOT NULL,
    [Comment]      NVARCHAR (50) NULL
);

