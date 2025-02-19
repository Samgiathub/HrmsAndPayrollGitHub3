CREATE TABLE [dbo].[KPMS_T0020_BatchYear_Detail] (
    [Batch_Detail_Id] INT           NOT NULL,
    [Batch_Title]     VARCHAR (300) NULL,
    [From_Date]       SMALLDATETIME NULL,
    [To_Date]         SMALLDATETIME NULL,
    [Cmp_Id]          INT           NULL,
    [IsActive]        INT           CONSTRAINT [DF_KPMS_T0020_BatchYear_Detail_IsActive] DEFAULT ((0)) NULL,
    [IsDefault]       BIT           CONSTRAINT [DF_KPMS_T0020_BatchYear_Detail_IsDefault] DEFAULT ((1)) NULL,
    [GoalScheme_Id]   INT           NULL,
    CONSTRAINT [PK_KPMS_T0020_BatchYear_Detail] PRIMARY KEY CLUSTERED ([Batch_Detail_Id] ASC) WITH (FILLFACTOR = 95)
);

