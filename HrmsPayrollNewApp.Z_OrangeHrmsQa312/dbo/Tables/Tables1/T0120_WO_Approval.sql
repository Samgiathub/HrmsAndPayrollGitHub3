CREATE TABLE [dbo].[T0120_WO_Approval] (
    [WO_Approval_Id]    NUMERIC (18) NOT NULL,
    [WO_Application_Id] NUMERIC (18) NULL,
    [Cmp_Id]            NUMERIC (18) NULL,
    [Emp_Id]            NUMERIC (18) NULL,
    [S_Emp_Id]          NUMERIC (18) NULL,
    [Approval_Date]     DATETIME     CONSTRAINT [DF_T0120_WO_Approval_Approval_Date] DEFAULT (getdate()) NOT NULL,
    [WO_Date]           DATETIME     NULL,
    [WO_Day]            VARCHAR (30) NULL,
    [No_Of_Days]        NVARCHAR (5) NULL,
    [New_WO_Date]       DATETIME     NULL,
    [New_WO_Day]        VARCHAR (30) NULL,
    [Status]            VARCHAR (1)  NULL,
    [Login_Id]          NUMERIC (18) NULL,
    [Month]             NUMERIC (18) NULL,
    [Year]              NUMERIC (18) NULL,
    [System_Date]       DATETIME     CONSTRAINT [DF_T0120_WO_Approval_System_Date] DEFAULT (getdate()) NOT NULL
);

