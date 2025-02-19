CREATE TABLE [dbo].[KPMS_T0020_Dependency_Master] (
    [Cmp_ID]          INT          CONSTRAINT [DF_KPMS_T0020_Dependency_Master_Cmp_ID] DEFAULT ((1)) NOT NULL,
    [Dependency_ID]   INT          NOT NULL,
    [Dependency_Code] VARCHAR (5)  NOT NULL,
    [Dependency_Type] VARCHAR (20) NOT NULL,
    [IsActive]        INT          CONSTRAINT [DF_KPMS_T0020_Dependency_Master_IsActive] DEFAULT ((1)) NOT NULL,
    [User_ID]         INT          NOT NULL,
    [Created_Date]    DATETIME     CONSTRAINT [DF_KPMS_T0020_Dependency_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Modify_Date]     DATETIME     NULL,
    CONSTRAINT [PK_KPMS_T0020_Dependency_Master] PRIMARY KEY CLUSTERED ([Dependency_ID] ASC) WITH (FILLFACTOR = 95)
);

