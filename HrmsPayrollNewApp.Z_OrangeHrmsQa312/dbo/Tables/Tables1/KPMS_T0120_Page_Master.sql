CREATE TABLE [dbo].[KPMS_T0120_Page_Master] (
    [Page_Id]      INT          NOT NULL,
    [Page_Name]    VARCHAR (50) NULL,
    [IsActive]     BIT          NULL,
    [CreatedBy_ID] INT          NULL,
    [Created_Date] DATETIME     CONSTRAINT [DF_KPMS_T0120_Page_Master_Created_Date] DEFAULT (getdate()) NULL,
    [Modify_Date]  DATETIME     NULL,
    [Module_Id]    INT          NULL,
    [Cmp_Id]       INT          NULL,
    CONSTRAINT [PK_KPMS_T0120_Page_Master] PRIMARY KEY CLUSTERED ([Page_Id] ASC)
);

