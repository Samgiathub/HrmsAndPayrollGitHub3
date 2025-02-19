CREATE TABLE [dbo].[T0080_Griev_Application_Allocation] (
    [G_Allocation_ID]  INT            NOT NULL,
    [Cmp_ID]           INT            NULL,
    [CommitteeID]      INT            NULL,
    [Griev_TypeID]     INT            NULL,
    [Griev_CatID]      INT            NULL,
    [Griev_PriorityID] INT            NULL,
    [Griev_StatusID]   INT            NULL,
    [Comments]         NVARCHAR (MAX) NULL,
    [File_Name]        NVARCHAR (MAX) NULL,
    [CDTM]             DATETIME       NULL,
    [UDTM]             DATETIME       NULL,
    [Log]              NVARCHAR (MAX) NULL,
    [GrievAppID]       INT            NULL,
    CONSTRAINT [PK_T0080_Griev_Application_Allocation] PRIMARY KEY CLUSTERED ([G_Allocation_ID] ASC) WITH (FILLFACTOR = 80)
);

