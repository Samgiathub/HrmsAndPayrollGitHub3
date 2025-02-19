CREATE TABLE [dbo].[T0251_REPORT_SETTING] (
    [Tran_Id]          NUMERIC (18)   NOT NULL,
    [Cmp_id]           NUMERIC (18)   NOT NULL,
    [Report_Name]      NVARCHAR (200) NOT NULL,
    [Report_File_Name] NVARCHAR (200) NOT NULL,
    [modify_date]      DATETIME       CONSTRAINT [DF_T0251_REPORT_SETTING_modify_date] DEFAULT (getdate()) NOT NULL,
    [Format]           NUMERIC (18)   CONSTRAINT [DF_T0251_REPORT_SETTING_Format] DEFAULT ((0)) NOT NULL
);

