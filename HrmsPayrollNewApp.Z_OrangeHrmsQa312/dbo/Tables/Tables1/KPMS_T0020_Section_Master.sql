CREATE TABLE [dbo].[KPMS_T0020_Section_Master] (
    [Cmp_ID]       INT           NOT NULL,
    [Section_ID]   INT           IDENTITY (1, 1) NOT NULL,
    [Section_Name] VARCHAR (300) NOT NULL,
    [IsActive]     INT           CONSTRAINT [DF_KPMS_T0020_Section_Master_IsActive] DEFAULT ((1)) NOT NULL,
    [User_ID]      INT           NOT NULL,
    [Created_Date] DATETIME      CONSTRAINT [DF_KPMS_T0020_Section_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Modify_Date]  DATETIME      NULL,
    CONSTRAINT [PK_KPMS_T0020_Section_Master] PRIMARY KEY CLUSTERED ([Section_ID] ASC) WITH (FILLFACTOR = 95)
);

