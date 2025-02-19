CREATE TABLE [dbo].[T0115_WO_Approval_Main] (
    [WO_Approval_Id]    NUMERIC (18) NOT NULL,
    [WO_Application_Id] NUMERIC (18) NULL,
    [Cmp_Id]            NUMERIC (18) NULL,
    [Emp_Id]            NUMERIC (18) NULL,
    [S_Emp_Id]          NUMERIC (18) NULL,
    [Approval_Date]     DATETIME     CONSTRAINT [DF_T0115_WO_Approval_Main_Approval_Date] DEFAULT (getdate()) NOT NULL,
    [Approva_Status]    CHAR (1)     NULL,
    [Login_Id]          NUMERIC (18) NULL,
    [Month]             NUMERIC (18) NULL,
    [Year]              NUMERIC (18) NULL,
    CONSTRAINT [PK_T0115_WO_Approval_Main] PRIMARY KEY CLUSTERED ([WO_Approval_Id] ASC) WITH (FILLFACTOR = 80)
);

