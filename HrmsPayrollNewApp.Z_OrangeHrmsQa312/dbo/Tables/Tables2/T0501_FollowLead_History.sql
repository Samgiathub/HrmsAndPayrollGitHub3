CREATE TABLE [dbo].[T0501_FollowLead_History] (
    [Tran_ID]       NUMERIC (18) NOT NULL,
    [LEAD_ID]       NUMERIC (18) NULL,
    [Assigned_TO]   NUMERIC (18) NULL,
    [Assigned_Date] DATETIME     NULL,
    [CmpID]         NUMERIC (18) NULL,
    [Modified_By]   NUMERIC (18) NULL,
    [Modified_Date] DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

