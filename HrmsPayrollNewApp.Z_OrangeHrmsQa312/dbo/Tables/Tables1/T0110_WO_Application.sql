CREATE TABLE [dbo].[T0110_WO_Application] (
    [WO_Application_Id] NUMERIC (18) NOT NULL,
    [Cmp_Id]            NUMERIC (18) NULL,
    [Emp_Id]            NUMERIC (18) NULL,
    [Application_Date]  DATETIME     CONSTRAINT [DF_T0110_WO_Application_Application_Date] DEFAULT (getdate()) NOT NULL,
    [WO_Date]           DATETIME     NULL,
    [WO_Day]            VARCHAR (30) NULL,
    [No_Of_Days]        NVARCHAR (5) NULL,
    [New_WO_Date]       DATETIME     NULL,
    [New_WO_Day]        VARCHAR (30) NULL,
    [Status]            VARCHAR (1)  NULL,
    [Login_Id]          NUMERIC (18) NULL,
    [Month]             NUMERIC (18) NULL,
    [Year]              NUMERIC (18) NULL,
    [System_Date]       DATETIME     CONSTRAINT [DF_T0110_WO_Application_System_Date] DEFAULT (getdate()) NOT NULL,
    [Sup_Emp_Id]        NUMERIC (18) CONSTRAINT [DF_T0110_WO_Application_Sup_Emp_Id] DEFAULT ((0)) NOT NULL
);

