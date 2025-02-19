CREATE TABLE [dbo].[T0050_Emp_Wise_Fun_Checklist] (
    [Checklist_Fun_ID]       NUMERIC (18)   NOT NULL,
    [Cmp_ID]                 NUMERIC (18)   NULL,
    [Emp_ID]                 NUMERIC (18)   NULL,
    [Fill_Date]              DATETIME       NULL,
    [Training_ID]            NUMERIC (18)   NULL,
    [Tran_ID]                NUMERIC (18)   NULL,
    [Fill_Up_Checklist]      VARCHAR (2000) NULL,
    [Not_Req_Checklist]      VARCHAR (2000) NULL,
    [Fill_Details]           VARCHAR (1000) NULL,
    [Modify_Date]            DATETIME       NULL,
    [Modify_By]              NUMERIC (18)   NULL,
    [Ip_Address]             VARCHAR (30)   NULL,
    [Passing_Flag]           TINYINT        DEFAULT ((0)) NOT NULL,
    [Tran_Feedback_ID]       NUMERIC (18)   DEFAULT ((0)) NOT NULL,
    [Training_attempt_count] TINYINT        NULL,
    PRIMARY KEY CLUSTERED ([Checklist_Fun_ID] ASC)
);

