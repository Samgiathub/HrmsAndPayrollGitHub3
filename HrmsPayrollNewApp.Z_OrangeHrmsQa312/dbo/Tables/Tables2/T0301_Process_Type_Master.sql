CREATE TABLE [dbo].[T0301_Process_Type_Master] (
    [Process_Type_Id]  NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_id]           NUMERIC (18)   CONSTRAINT [DF_T0301_Process_Type_Master_Cmp_id] DEFAULT ((0)) NOT NULL,
    [Process_Type]     VARCHAR (500)  NULL,
    [Ad_Id_Multi]      VARCHAR (5000) CONSTRAINT [DF_T0301_Process_Type_Master_Ad_Id_Multi] DEFAULT ('') NULL,
    [modify_Date]      DATETIME       CONSTRAINT [DF_T0301_Process_Type_Master_modify_Date] DEFAULT (getdate()) NOT NULL,
    [Sort_Id]          NUMERIC (18)   CONSTRAINT [DF_T0301_Process_Type_Master_Sort_Id] DEFAULT ((0)) NOT NULL,
    [Ad_Name_Multi]    VARCHAR (MAX)  NULL,
    [Loan_Id_Multi]    VARCHAR (5000) CONSTRAINT [DF_T0301_Process_Type_Master_Loan_Id_Multi] DEFAULT ('') NOT NULL,
    [Loan_Name_Multi]  VARCHAR (5000) CONSTRAINT [DF_T0301_Process_Type_Master_Loan_Name_Multi] DEFAULT ('') NOT NULL,
    [Leave_Id_Multi]   VARCHAR (5000) CONSTRAINT [DF_T0301_Process_Type_Master_Leave_Id_Multi] DEFAULT ('') NOT NULL,
    [Leave_Name_Multi] VARCHAR (5000) CONSTRAINT [DF_T0301_Process_Type_Master_Leave_Name_Multi] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_T0301_Process_Type_Master] PRIMARY KEY CLUSTERED ([Process_Type_Id] ASC) WITH (FILLFACTOR = 80)
);

