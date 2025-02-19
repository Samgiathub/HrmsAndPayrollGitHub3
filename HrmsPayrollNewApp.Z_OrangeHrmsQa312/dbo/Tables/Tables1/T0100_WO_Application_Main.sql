CREATE TABLE [dbo].[T0100_WO_Application_Main] (
    [WO_Application_Id]  NUMERIC (18) NOT NULL,
    [Cmp_Id]             NUMERIC (18) NULL,
    [Emp_Id]             NUMERIC (18) NULL,
    [S_Emp_Id]           NUMERIC (18) NULL,
    [Application_Date]   DATETIME     CONSTRAINT [DF_T0100_WO_Application_Main_Application_Date] DEFAULT (getdate()) NOT NULL,
    [Application_Status] CHAR (1)     NULL,
    [Login_Id]           NUMERIC (18) NULL,
    [Month]              NUMERIC (18) NULL,
    [Year]               NUMERIC (18) NULL,
    CONSTRAINT [PK_T0100_WO_Application_Main] PRIMARY KEY CLUSTERED ([WO_Application_Id] ASC) WITH (FILLFACTOR = 80)
);

