CREATE TABLE [dbo].[KPMS_T0040_Frequency_Master] (
    [Cmp_ID]         INT          CONSTRAINT [DF_KPMS_T0040_Frequency_Master_Cmp_ID] DEFAULT ((1)) NOT NULL,
    [Frequency_ID]   INT          NOT NULL,
    [Frequency_Code] VARCHAR (5)  NOT NULL,
    [Frequency]      VARCHAR (20) NOT NULL,
    [IsActive]       INT          CONSTRAINT [DF_KPMS_T0040_Frequency_Master_IsActive] DEFAULT ((1)) NOT NULL,
    [User_ID]        INT          NOT NULL,
    [Created_Date]   DATETIME     CONSTRAINT [DF_KPMS_T0040_Frequency_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Modify_Date]    DATETIME     NULL,
    CONSTRAINT [PK_KPMS_T0040_Frequency_Master] PRIMARY KEY CLUSTERED ([Frequency_ID] ASC) WITH (FILLFACTOR = 95)
);

