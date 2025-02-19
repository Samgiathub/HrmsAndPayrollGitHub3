CREATE TABLE [dbo].[KPMS_T0020_Band_Master] (
    [Cmp_ID]       INT          NOT NULL,
    [Band_ID]      INT          NOT NULL,
    [Band_Code]    VARCHAR (5)  NOT NULL,
    [Band_Name]    VARCHAR (20) NOT NULL,
    [IsActive]     INT          CONSTRAINT [DF_KPMS_T0020_Band_Master_IsActive] DEFAULT ((0)) NOT NULL,
    [User_ID]      INT          NOT NULL,
    [Created_Date] DATETIME     CONSTRAINT [DF_KPMS_T0020_Band_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Modify_Date]  DATETIME     NULL,
    CONSTRAINT [PK_KPMS_T0020_Band_Master] PRIMARY KEY CLUSTERED ([Band_ID] ASC) WITH (FILLFACTOR = 95)
);

