CREATE TABLE [dbo].[T0350_Exit_Clearance_Approval_Detail] (
    [Tran_id]         NUMERIC (18)    CONSTRAINT [DF_T0350_Exit_Clearance_Approval_Detail_Tran_id] DEFAULT ((0)) NOT NULL,
    [Cmp_id]          NUMERIC (18)    CONSTRAINT [DF_T0350_Exit_Clearance_Approval_Detail_Cmp_id] DEFAULT ((0)) NOT NULL,
    [Approval_id]     NUMERIC (18)    CONSTRAINT [DF_T0350_Exit_Clearance_Approval_Detail_Approval_id] DEFAULT ((0)) NOT NULL,
    [Clearance_id]    NUMERIC (18)    CONSTRAINT [DF_T0350_Exit_Clearance_Approval_Detail_Clearance_id] DEFAULT ((0)) NOT NULL,
    [Recovery_Amt]    NUMERIC (18, 2) CONSTRAINT [DF_T0350_Exit_Clearance_Approval_Detail_Recovery_Amt] DEFAULT ((0)) NOT NULL,
    [Remarks]         VARCHAR (250)   NULL,
    [Attachment_path] VARCHAR (MAX)   NULL,
    [Not_Applicable]  TINYINT         NOT NULL,
    [Status]          VARCHAR (50)    NULL
);

