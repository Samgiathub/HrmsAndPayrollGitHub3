CREATE TABLE [dbo].[KPMS_T0040_Level_Group_Master] (
    [Level_Group_ID]   INT           IDENTITY (1, 1) NOT NULL,
    [Level_Group_Name] VARCHAR (300) NOT NULL,
    [cmp_id]           INT           NULL,
    CONSTRAINT [PK_KPMS_T0040_Level_Group_Master] PRIMARY KEY CLUSTERED ([Level_Group_ID] ASC) WITH (FILLFACTOR = 95)
);

