CREATE TABLE [dbo].[T0115_PreCompOff_Approval_Level] (
    [Tran_ID]             NUMERIC (18)    CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_Tran_ID] DEFAULT ((0)) NOT NULL,
    [cmp_ID]              NUMERIC (18)    CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_cmp_ID] DEFAULT ((0)) NOT NULL,
    [PreCompOff_App_ID]   NUMERIC (18)    CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_PreCompOff_App_ID] DEFAULT ((0)) NOT NULL,
    [PrecompOff_App_Date] DATETIME        NULL,
    [PreCompOff_Apr_Date] DATETIME        NULL,
    [Emp_ID]              NUMERIC (18)    CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_Emp_ID] DEFAULT ((0)) NOT NULL,
    [S_Emp_ID]            NUMERIC (18)    NOT NULL,
    [From_Date]           DATETIME        NULL,
    [To_Date]             DATETIME        NULL,
    [Period]              NUMERIC (18, 2) CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_Period] DEFAULT ((0)) NOT NULL,
    [Remarks]             NVARCHAR (250)  NULL,
    [Approval_Status]     CHAR (1)        NULL,
    [RPT_Level]           TINYINT         CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_RPT_Level] DEFAULT ((0)) NULL,
    [Final_Approval]      TINYINT         CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_Final_Approval] DEFAULT ((0)) NULL,
    [Is_FWD_REJECT]       TINYINT         CONSTRAINT [DF_T0115_PreCompOff_Approval_Level_Is_FWD_REJECT] DEFAULT ((0)) NULL
);

