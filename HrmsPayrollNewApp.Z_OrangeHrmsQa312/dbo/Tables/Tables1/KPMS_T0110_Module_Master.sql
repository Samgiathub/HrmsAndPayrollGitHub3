CREATE TABLE [dbo].[KPMS_T0110_Module_Master] (
    [Module_Id]    INT          NOT NULL,
    [Module_Name]  VARCHAR (50) NULL,
    [IsActive]     BIT          NULL,
    [CreatedBy_ID] INT          NULL,
    [Created_Date] DATETIME     NULL,
    [Modify_Date]  DATETIME     NULL,
    [Cmp_Id]       INT          NULL,
    CONSTRAINT [PK_KPMS_T0110_Module_Master] PRIMARY KEY CLUSTERED ([Module_Id] ASC)
);

