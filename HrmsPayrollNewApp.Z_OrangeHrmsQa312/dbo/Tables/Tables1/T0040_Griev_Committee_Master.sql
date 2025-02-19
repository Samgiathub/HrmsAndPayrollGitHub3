CREATE TABLE [dbo].[T0040_Griev_Committee_Master] (
    [GC_ID]            INT            NOT NULL,
    [Com_Name]         VARCHAR (100)  NULL,
    [Effective_Date]   DATETIME       NULL,
    [Cmp_id]           INT            NULL,
    [State_ID]         NVARCHAR (MAX) NULL,
    [District_ID]      NVARCHAR (MAX) NULL,
    [Tehsil_ID]        NVARCHAR (MAX) NULL,
    [Branch_ID]        NVARCHAR (MAX) NULL,
    [Vertical_ID]      NVARCHAR (MAX) NULL,
    [SubVertical_ID]   NVARCHAR (MAX) NULL,
    [Business_Sgmt_ID] NVARCHAR (MAX) NULL,
    [Chairperson_id]   INT            NULL,
    [NodelHR_id]       INT            NULL,
    [CommitteeMem_ID]  NVARCHAR (MAX) NULL,
    [Is_Active]        INT            CONSTRAINT [GCM_Is_Active] DEFAULT (N'1') NULL,
    [CDTM]             DATETIME       NULL,
    [UDTM]             DATETIME       NULL,
    [Log]              NVARCHAR (MAX) NULL,
    [BranchName]       NVARCHAR (MAX) NULL,
    [CommMemText]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0040_Griev_Committee_Master] PRIMARY KEY CLUSTERED ([GC_ID] ASC) WITH (FILLFACTOR = 80)
);

