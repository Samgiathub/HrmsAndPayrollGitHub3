CREATE TABLE [dbo].[T0120_PreCompOff_Approval] (
    [PreCompOff_Apr_ID] NUMERIC (18)    CONSTRAINT [DF_T0120_PreCompOff_Approval_PreCompOff_Apr_ID] DEFAULT ((0)) NOT NULL,
    [cmp_ID]            NUMERIC (18)    CONSTRAINT [DF_T0120_PreCompOff_Approval_cmp_ID] DEFAULT ((0)) NOT NULL,
    [PreCompOff_App_ID] NUMERIC (18)    CONSTRAINT [DF_T0120_PreCompOff_Approval_PreCompOff_App_ID] DEFAULT ((0)) NOT NULL,
    [Emp_ID]            NUMERIC (18)    CONSTRAINT [DF_T0120_PreCompOff_Approval_Emp_ID] DEFAULT ((0)) NOT NULL,
    [S_Emp_ID]          NUMERIC (18)    NOT NULL,
    [From_Date]         DATETIME        NULL,
    [To_Date]           DATETIME        NULL,
    [Period]            NUMERIC (18, 2) CONSTRAINT [DF_T0120_PreCompOff_Approval_Period] DEFAULT ((0)) NOT NULL,
    [Remarks]           NVARCHAR (250)  NULL,
    [Approval_Status]   CHAR (1)        NULL
);

