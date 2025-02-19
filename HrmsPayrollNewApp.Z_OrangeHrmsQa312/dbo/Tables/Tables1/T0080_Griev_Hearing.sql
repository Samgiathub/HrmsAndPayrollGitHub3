CREATE TABLE [dbo].[T0080_Griev_Hearing] (
    [GH_ID]           INT             NOT NULL,
    [Cmp_ID]          INT             NULL,
    [G_AllocationID]  INT             NULL,
    [G_StatusID]      INT             NULL,
    [HearingDate]     DATETIME        NULL,
    [HearingLocation] NVARCHAR (MAX)  NULL,
    [GHContactNo]     NVARCHAR (MAX)  NULL,
    [CDTM]            DATETIME        NULL,
    [UDTM]            DATETIME        NULL,
    [Log]             NVARCHAR (MAX)  NULL,
    [GHComments]      NVARCHAR (200)  NULL,
    [DocName]         NVARCHAR (2000) NULL,
    CONSTRAINT [PK_T0080_Griev_Hearing] PRIMARY KEY CLUSTERED ([GH_ID] ASC) WITH (FILLFACTOR = 80)
);

