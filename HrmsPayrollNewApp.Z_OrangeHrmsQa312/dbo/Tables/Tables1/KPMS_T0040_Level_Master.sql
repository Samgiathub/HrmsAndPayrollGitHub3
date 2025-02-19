CREATE TABLE [dbo].[KPMS_T0040_Level_Master] (
    [Cmp_ID]       INT          NOT NULL,
    [Level_ID]     INT          NOT NULL,
    [Level_Code]   VARCHAR (5)  NOT NULL,
    [Level_Name]   VARCHAR (20) NOT NULL,
    [IsActive]     INT          CONSTRAINT [DF_KPMS_T0040_Level_Master_IsActive] DEFAULT ((1)) NOT NULL,
    [User_ID]      INT          NOT NULL,
    [Created_Date] DATETIME     CONSTRAINT [DF_KPMS_T0040_Level_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Modify_Date]  DATETIME     NULL,
    [level_Grp_Id] INT          NULL,
    CONSTRAINT [PK_KPMS_T0040_Level_Master] PRIMARY KEY CLUSTERED ([Level_ID] ASC) WITH (FILLFACTOR = 95)
);

