CREATE TABLE [dbo].[KPMS_T0040_GoalStatus_Master] (
    [Status_ID]   INT          IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]      INT          NULL,
    [Status_Name] VARCHAR (20) NOT NULL,
    [GalAlt_id]   INT          NULL,
    CONSTRAINT [PK_KPMS_T0040_GoalStatus_Master] PRIMARY KEY CLUSTERED ([Status_ID] ASC) WITH (FILLFACTOR = 95)
);

