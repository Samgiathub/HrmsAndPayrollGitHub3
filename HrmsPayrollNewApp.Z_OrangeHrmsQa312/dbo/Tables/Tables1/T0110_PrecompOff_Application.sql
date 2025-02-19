CREATE TABLE [dbo].[T0110_PrecompOff_Application] (
    [PreCompOff_App_ID]   NUMERIC (18)    CONSTRAINT [DF_T0110_PrecompOff_Application_PreCompOff_App_ID] DEFAULT ((0)) NOT NULL,
    [PreCompOff_App_date] DATETIME        NULL,
    [cmp_ID]              NUMERIC (18)    CONSTRAINT [DF_T0110_PrecompOff_Application_cmp_ID] DEFAULT ((0)) NOT NULL,
    [Emp_ID]              NUMERIC (18)    CONSTRAINT [DF_T0110_PrecompOff_Application_Emp_ID] DEFAULT ((0)) NOT NULL,
    [S_Emp_ID]            NUMERIC (18)    CONSTRAINT [DF_T0110_PrecompOff_Application_S_Emp_ID] DEFAULT ((0)) NOT NULL,
    [From_Date]           DATETIME        NULL,
    [To_Date]             DATETIME        NULL,
    [Period]              NUMERIC (18, 2) CONSTRAINT [DF_T0110_PrecompOff_Application_Period] DEFAULT ((0)) NOT NULL,
    [Remarks]             NVARCHAR (350)  NULL,
    [App_Status]          CHAR (1)        NULL
);

