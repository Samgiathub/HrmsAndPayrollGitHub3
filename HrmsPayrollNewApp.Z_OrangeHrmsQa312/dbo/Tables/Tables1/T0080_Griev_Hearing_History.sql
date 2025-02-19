CREATE TABLE [dbo].[T0080_Griev_Hearing_History] (
    [GHH_ID]           INT             NOT NULL,
    [Cmp_ID]           INT             NULL,
    [G_HearingID]      INT             NULL,
    [G_StatusID]       INT             NULL,
    [Last_HearingDate] DATETIME        NULL,
    [Next_HearingDate] DATETIME        NULL,
    [GHHComments]      NVARCHAR (1000) NULL,
    [GHHDocName]       NVARCHAR (200)  NULL,
    [CDTM]             DATETIME        NULL,
    [UDTM]             DATETIME        NULL,
    [Log]              NVARCHAR (MAX)  NULL,
    [GHHLocation]      NVARCHAR (1000) NULL,
    [GHHContact]       NUMERIC (10)    NULL,
    [G_AllocationID]   INT             NULL,
    CONSTRAINT [PK_T0080_Griev_Hearing_History] PRIMARY KEY CLUSTERED ([GHH_ID] ASC) WITH (FILLFACTOR = 80)
);

