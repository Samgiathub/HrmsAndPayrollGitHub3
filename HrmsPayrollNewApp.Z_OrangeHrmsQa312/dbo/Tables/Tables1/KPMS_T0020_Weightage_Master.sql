CREATE TABLE [dbo].[KPMS_T0020_Weightage_Master] (
    [Cmp_ID]         INT          NOT NULL,
    [Weightage_ID]   INT          NOT NULL,
    [Weightage_Code] VARCHAR (5)  NOT NULL,
    [Weightage_Type] VARCHAR (20) NOT NULL,
    [IsActive]       INT          CONSTRAINT [DF_KPMS_T0020_Weightage_Master_IsActive] DEFAULT ((1)) NOT NULL,
    [User_ID]        INT          NOT NULL,
    [Created_Date]   DATETIME     CONSTRAINT [DF_KPMS_T0020_Weightage_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Modify_Date]    DATETIME     NULL,
    CONSTRAINT [PK_KPMS_T0020_Weightage_Master] PRIMARY KEY CLUSTERED ([Weightage_ID] ASC) WITH (FILLFACTOR = 95)
);

