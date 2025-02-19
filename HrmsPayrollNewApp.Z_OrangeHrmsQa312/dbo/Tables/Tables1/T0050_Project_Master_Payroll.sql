CREATE TABLE [dbo].[T0050_Project_Master_Payroll] (
    [Tran_Id]            NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]             NUMERIC (18)   NOT NULL,
    [Project_Name]       VARCHAR (5000) NOT NULL,
    [Project_Manager_Id] NUMERIC (18)   CONSTRAINT [DF_T0050_Project_Master_Payroll_Project_Manager_Id] DEFAULT ((0)) NOT NULL,
    [Customer_Name]      VARCHAR (MAX)  NULL,
    [Site_Id]            VARCHAR (MAX)  NULL,
    [Remarks]            VARCHAR (MAX)  NULL,
    [Modify_Date]        DATETIME       CONSTRAINT [DF_Table_1_modify_Date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0050_Project_Master_Payroll] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

